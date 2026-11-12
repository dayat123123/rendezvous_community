import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/poll_editor.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';

import '../../support/fakes.dart';
import '../../support/legal_fakes.dart';

final _topComment = comment(
  'k-1',
  depth: 0,
  path: '000000000001',
  body: 'Setuju, support kuat di 9.800',
).copyWith(likeCount: 12);

Post _post({ThreadComment? top, int comments = 5}) => Post(
  id: 'p-1',
  author: alice,
  body: r'Analisis $BBCA hari ini',
  commentCount: comments,
  createdAt: now.subtract(const Duration(hours: 1)),
  cursor: 'c',
  topComment: top,
);

class _QueryFeed extends FakeFeedRepository implements FeedQueryRepository {
  _QueryFeed([List<Post>? posts]) : posts = posts ?? [_post()];

  final List<Post> posts;
  final queries = <(FeedScope, CommunityFeedSort, bool, String?)>[];
  final plain = <FeedScope>[];
  var pinnedCalls = 0;
  final changes = StreamController<PostChange>.broadcast();

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async {
    plain.add(scope);
    return Paged(posts);
  }

  @override
  Future<Paged<Post>> queryFeed(
    FeedScope scope, {
    CommunityFeedSort sort = CommunityFeedSort.latest,
    bool mediaOnly = false,
    String? filter,
    String? cursor,
    int limit = 20,
  }) async {
    queries.add((scope, sort, mediaOnly, cursor));
    return Paged(posts);
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async {
    pinnedCalls++;
    return const [];
  }

  @override
  Stream<PostChange> watchPosts({String? postId}) => changes.stream;

  Future<void> close() => changes.close();
}

class _PlainFeed extends FakeFeedRepository {
  final scopes = <FeedScope>[];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async {
    scopes.add(scope);
    return Paged([_post()]);
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

Future<void> _pumpFeed(WidgetTester tester, Widget child, {FakeFeedRepository? feed}) async {
  tester.view.physicalSize = const Size(600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpCommunity(tester, child, dependencies: FakeDependencies(feed: feed));
}

Future<void> _openComposer(
  WidgetTester tester, {
  String? initialStock,
  Sentiment? sentiment,
  CommunityComposerAction? action,
}) async {
  await pumpCommunity(
    tester,
    Builder(
      builder: (context) => TextButton(
        onPressed: () => showCommunityComposer(
          context,
          initialStock: initialStock,
          initialSentiment: sentiment,
          initialAction: action,
        ),
        child: const Text('tulis'),
      ),
    ),
  );
  await tester.tap(find.text('tulis'));
  await tester.pumpAndSettle();
}

bool _tagSelected(WidgetTester tester, String label) =>
    tester.widget<CommunityTag>(find.widgetWithText(CommunityTag, label)).selected;

void main() {
  group('feed sort and media filter', () {
    testWidgets('CommunityFeedList asks the server for the sorted watchlist media feed', (tester) async {
      final feed = _QueryFeed();
      await _pumpFeed(
        tester,
        const CommunityFeedList(
          scope: FeedScope.stocks(['BBCA', 'TLKM']),
          emptyMessage: 'Kosong',
          sort: CommunityFeedSort.top,
          mediaOnly: true,
        ),
        feed: feed,
      );

      expect(feed.queries.single, (const FeedScope.stocks(['BBCA', 'TLKM']), CommunityFeedSort.top, true, null));
      expect(feed.plain, isEmpty);
      expect(feed.pinnedCalls, 0);
      expect(find.text(r'Analisis $BBCA hari ini'), findsOneWidget);
    });

    testWidgets('the default sort keeps the plain feed call and pinned posts', (tester) async {
      final feed = _QueryFeed();
      await _pumpFeed(
        tester,
        const CommunityFeedList(scope: FeedScope.forYou(), emptyMessage: 'Kosong'),
        feed: feed,
      );

      expect(feed.plain, [const FeedScope.forYou()]);
      expect(feed.queries, isEmpty);
      expect(feed.pinnedCalls, 1);
    });

    test('a repository without FeedQueryRepository still loads with the plain feed', () async {
      final feed = _PlainFeed();
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.official(), sort: CommunityFeedSort.top);
      addTearDown(cubit.close);

      await cubit.load();

      expect(feed.scopes, [const FeedScope.official()]);
      expect(cubit.state.posts.single.id, 'p-1');
    });

    test('new posts are not announced on a Top feed', () async {
      final feed = _QueryFeed();
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global(), sort: CommunityFeedSort.top);
      addTearDown(cubit.close);
      await cubit.load();

      feed.changes.add(PostInserted('p-9', authorId: 'u-b', body: 'Baru', createdAt: now));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.newPosts, 0);
    });

    test('a watchlist feed counts new posts that tag one of its stocks', () async {
      final feed = _QueryFeed();
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.stocks(['bbca', 'TLKM']));
      addTearDown(cubit.close);
      await cubit.load();

      feed.changes
        ..add(PostInserted('p-8', authorId: 'u-b', body: r'Pantau $TLKM', createdAt: now))
        ..add(PostInserted('p-9', authorId: 'u-b', body: r'Bahas $GOTO', createdAt: now));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.newPosts, 1);
    });
  });

  group('top comment preview', () {
    testWidgets('the card previews the top comment and opens the post in navigate mode', (tester) async {
      await _pumpFeed(
        tester,
        const CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'Kosong'),
        feed: _QueryFeed([_post(top: _topComment)]),
      );

      expect(find.text('Setuju, support kuat di 9.800'), findsOneWidget);
      expect(find.text('Lihat semua 5 komentar'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('top-comment-p-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostDetail), findsOneWidget);
    });

    testWidgets('in inline mode the preview opens the comments under the card', (tester) async {
      await _pumpFeed(
        tester,
        const CommunityFeedList(
          scope: FeedScope.global(),
          emptyMessage: 'Kosong',
          postOpenMode: CommunityPostOpenMode.inlineComments,
        ),
        feed: _QueryFeed([_post(top: _topComment)]),
      );

      await tester.tap(find.byKey(const ValueKey('top-comment-p-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostDetail), findsNothing);
      expect(find.byType(CommunityPostComments), findsOneWidget);
      expect(find.byKey(const ValueKey('top-comment-p-1')), findsNothing);
    });

    testWidgets('posts without comments show no preview', (tester) async {
      await _pumpFeed(
        tester,
        const CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'Kosong'),
        feed: _QueryFeed([_post(comments: 0)]),
      );

      expect(find.byKey(const ValueKey('top-comment-p-1')), findsNothing);
    });

    testWidgets('the topComment builder receives the comment and the open action', (tester) async {
      CommunityPostDetails? seen;
      await _pumpFeed(
        tester,
        CommunityFeedList(
          scope: const FeedScope.global(),
          emptyMessage: 'Kosong',
          builders: CommunityFeedBuilders(
            topComment: (context, d, fallback) {
              seen = d;
              return TextButton(onPressed: d.onOpenComments, child: Text('top ${d.topComment!.id}'));
            },
          ),
        ),
        feed: _QueryFeed([_post(top: _topComment)]),
      );

      expect(find.text('top k-1'), findsOneWidget);
      expect(seen!.topComment!.likeCount, 12);
      expect(seen!.onOpenComments, isNotNull);
    });
  });

  group('composer entry points', () {
    testWidgets('initialSentiment selects the sentiment', (tester) async {
      await _openComposer(tester, sentiment: Sentiment.bearish);

      expect(_tagSelected(tester, 'Bearish'), isTrue);
      expect(_tagSelected(tester, 'Bullish'), isFalse);
    });

    testWidgets('initialAction poll opens the poll editor', (tester) async {
      await _openComposer(tester, action: CommunityComposerAction.poll);

      expect(find.byType(PollEditor), findsOneWidget);
    });

    testWidgets('initialAction cashtag starts a stock tag after the initial stock', (tester) async {
      await _openComposer(tester, initialStock: 'bbca', action: CommunityComposerAction.cashtag);

      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, r'$BBCA $');
      expect(field.controller!.selection.baseOffset, 7);
    });

    testWidgets('initialAction image opens the image picker', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/file_selector'),
        (call) async {
          calls.add(call.method);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/file_selector'),
          null,
        ),
      );

      await _openComposer(tester, action: CommunityComposerAction.image);

      expect(calls, ['openFile']);
    });

    testWidgets('quick actions on the compose card open the composer in that mode', (tester) async {
      await pumpCommunity(tester, const CommunityComposePromptCard());

      await tester.tap(find.widgetWithText(TextButton, 'Bullish'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityComposePost), findsOneWidget);
      expect(_tagSelected(tester, 'Bullish'), isTrue);
    });

    testWidgets('the composePrompt builder receives the quick actions', (tester) async {
      CommunityComposePromptDetails? seen;
      await pumpCommunity(
        tester,
        CommunityFeedBuildersScope(
          builders: CommunityFeedBuilders(
            composePrompt: (context, d, fallback) {
              seen = d;
              return const SizedBox();
            },
          ),
          child: const CommunityComposePromptCard(initialStock: 'BBCA'),
        ),
      );

      expect(seen!.quickActions.map((a) => a.sentiment ?? a.action), [
        Sentiment.bullish,
        Sentiment.bearish,
        CommunityComposerAction.image,
        CommunityComposerAction.poll,
      ]);
      expect(seen!.onComposeWith, isNotNull);
    });
  });
}
