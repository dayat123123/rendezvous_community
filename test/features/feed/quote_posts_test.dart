import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/widgets/community_notification_settings.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/gen/community_localizations.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';

Map<String, dynamic> _quotedJson({bool available = true}) => available
    ? {
        'id': 'q-1',
        'available': true,
        'author_id': 'u-9',
        'username': 'olt_research',
        'display_name': 'OLT Research',
        'avatar_url': null,
        'is_verified': true,
        'is_official': true,
        'body': r'Analisa $BBCA kuartal ini',
        'sentiment': 'bullish',
        'attachments': [
          {'path': 'posts/u-9/a.png', 'mime': 'image/png', 'width': 800, 'height': 400},
        ],
        'stocks': ['BBCA'],
        'created_at': '2026-11-27T03:00:00+00:00',
      }
    : {'id': 'q-1', 'available': false};

class _QuoteFeed extends FakeFeedRepository implements QuoteRepository {
  final quotes = <Map<String, Object?>>[];

  @override
  Future<Post> createQuote({
    required String quotedPostId,
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    String? clientId,
    CommentAudience? commentAudience,
  }) async {
    quotes.add({'quoted': quotedPostId, 'body': body, 'clientId': clientId});
    return Post(id: 'p-new', author: me, body: body, createdAt: now, cursor: 'c');
  }

  @override
  Future<Paged<Post>> postQuotes(String postId, {String? cursor, int limit = 20}) async => Paged([
    Post(id: 'p-q', author: alice, body: 'Kutipan dari Alice', createdAt: now, cursor: 'c1'),
  ]);
}

class _NoMedia extends Fake implements MediaRepository {}

Post _post({QuotedPost? quoted, bool canQuote = true, int quoteCount = 0}) => Post(
  id: 'p-1',
  author: alice,
  body: 'Setuju dengan analisa ini',
  createdAt: now,
  cursor: 'c',
  quotedPost: quoted,
  canQuote: canQuote,
  quoteCount: quoteCount,
);

Future<void> _pump(WidgetTester tester, Widget child, {FakeFeedRepository? feed}) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(feed: feed),
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('FeedPostModel quotes', () {
    test('parses the quoted post, quote count, and can_quote', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'quoted_post': _quotedJson(),
        'quote_count': 3,
        'can_quote': true,
      }).toEntity();
      final quoted = post.quotedPost!;
      expect(quoted.available, isTrue);
      expect(quoted.author?.username, 'olt_research');
      expect(quoted.authorIsOfficial, isTrue);
      expect(quoted.sentiment, Sentiment.bullish);
      expect(quoted.stockCodes, ['BBCA']);
      expect(quoted.image?.path, 'posts/u-9/a.png');
      expect(post.quoteCount, 3);
      expect(post.canQuote, isTrue);
    });

    test('keeps an unavailable quote without content and defaults old servers', () {
      final gone = FeedPostModel.fromJson({...feedRow('p-1'), 'quoted_post': _quotedJson(available: false)}).toEntity();
      expect(gone.quotedPost, const QuotedPost(id: 'q-1', available: false));
      final old = FeedPostModel.fromJson(feedRow('p-2')).toEntity();
      expect(old.quotedPost, isNull);
      expect(old.quoteCount, 0);
      expect(old.canQuote, isFalse);
    });
  });

  group('FeedRepositoryImpl quotes', () {
    late MockApi api;

    setUp(() => api = mockApi());

    test('createQuote sends p_quoted_post_id to create_post', () async {
      when(() => api.rpcRows('create_post', any())).thenAnswer(
        (_) async => [
          {...feedRow('p-new'), 'quoted_post': _quotedJson()},
        ],
      );
      final post = await FeedRepositoryImpl(api).createQuote(quotedPostId: 'q-1', body: 'Setuju @Budi');
      final params = verify(() => api.rpcRows('create_post', captureAny())).captured.single as Map<String, Object?>;
      expect(params['p_quoted_post_id'], 'q-1');
      expect(params['p_body'], 'Setuju @budi');
      expect(params.containsKey('p_poll'), isFalse);
      expect(post.quotedPost?.id, 'q-1');
    });

    test('postQuotes pages with the last cursor', () async {
      when(() => api.rpcRows('post_quotes', any())).thenAnswer(
        (_) async => [feedRow('a', cursor: 'c-a'), feedRow('b', cursor: 'c-b')],
      );
      final page = await FeedRepositoryImpl(api).postQuotes('q-1', limit: 2);
      final params = verify(() => api.rpcRows('post_quotes', captureAny())).captured.single as Map<String, Object?>;
      expect(params, {'p_post_id': 'q-1', 'p_cursor': null, 'p_limit': 2});
      expect(page.items.map((p) => p.id), ['a', 'b']);
      expect(page.nextCursor, 'c-b');
    });
  });

  group('ComposeCubit quotes', () {
    test('posts a quote through QuoteRepository and turns polls off', () async {
      final feed = _QuoteFeed();
      final cubit = ComposeCubit(feed: feed, media: _NoMedia(), quoted: const QuotedPost(id: 'q-1'));
      addTearDown(cubit.close);
      expect(cubit.state.canAddPoll, isFalse);
      cubit.addPoll();
      expect(cubit.state.poll, isNull);
      final post = await cubit.submit('  Setuju  ');
      expect(post?.id, 'p-new');
      expect(feed.quotes.single['quoted'], 'q-1');
      expect(feed.quotes.single['body'], 'Setuju');
      expect(cubit.state.quoted?.id, 'q-1');
    });

    test('fails clearly when the repository cannot quote', () async {
      final cubit = ComposeCubit(feed: FakeFeedRepository(), media: _NoMedia(), quoted: const QuotedPost(id: 'q-1'));
      addTearDown(cubit.close);
      expect(await cubit.submit('Setuju'), isNull);
      expect((cubit.state.error! as CommunityException).code, 'quote_unsupported');
    });
  });

  group('PostCard quotes', () {
    testWidgets('shows the quoted post and the quote button', (tester) async {
      final quoted = FeedPostModel.fromJson({...feedRow('p-1'), 'quoted_post': _quotedJson()}).toEntity().quotedPost;
      await _pump(
        tester,
        PostCard(post: _post(quoted: quoted, quoteCount: 2), onLike: () {}),
        feed: _QuoteFeed(),
      );
      expect(find.byType(QuotedPostCard), findsOneWidget);
      expect(find.textContaining('Analisa'), findsOneWidget);
      expect(find.byTooltip('Kutip'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows an unavailable quote without content', (tester) async {
      await _pump(
        tester,
        PostCard(
          post: _post(quoted: const QuotedPost(id: 'q-1', available: false)),
          onLike: () {},
        ),
        feed: _QuoteFeed(),
      );
      expect(find.text('Postingan ini tidak tersedia.'), findsOneWidget);
    });

    testWidgets('hides the quote button when quoting is not allowed or not supported', (tester) async {
      await _pump(tester, PostCard(post: _post(canQuote: false), onLike: () {}), feed: _QuoteFeed());
      expect(find.byTooltip('Kutip'), findsNothing);
      await _pump(tester, PostCard(post: _post(), onLike: () {}), feed: FakeFeedRepository());
      expect(find.byTooltip('Kutip'), findsNothing);
    });

    testWidgets('the quote button opens the composer with the post attached', (tester) async {
      await _pump(tester, PostCard(post: _post(), onLike: () {}), feed: _QuoteFeed());
      await tester.tap(find.byTooltip('Kutip'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(QuotedPostCard), findsOneWidget);
      expect(find.text('Tambahkan pendapat Anda'), findsOneWidget);
    });
  });

  test('notification settings label the quote type', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    expect(notificationTypeLabel(l10n, 'quote'), 'Kutipan');
    expect(l10n.notifQuotedPost('Ani'), 'Ani mengutip postingan Anda');
  });
}
