import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/reply_composer.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

class _AccountFeed extends FakeFeedRepository implements CommentControlRepository, CommentSettingsRepository {
  _AccountFeed({this.settings = const CommentSettings(audience: CommentAudience.followers)});

  CommentSettings settings;
  final created = <CommentAudience?>[];
  final reloaded = <String>[];
  final allOffCalls = <bool>[];
  final _changes = StreamController<CommentSettings>.broadcast();
  List<Post> posts = const [];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(posts);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];

  @override
  Future<Post?> getPost(String postId) async {
    reloaded.add(postId);
    return posts.firstWhere((p) => p.id == postId).copyWith(commentsOffByAccount: false, canComment: true);
  }

  @override
  Future<Post> createPost({
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    PollDraft? poll,
    String? clientId,
    CommentAudience? commentAudience,
  }) async {
    created.add(commentAudience);
    return Post(id: 'p-new', author: me, body: body, createdAt: now, cursor: 'c');
  }

  @override
  Future<CommentAudience> getCommentAudience() async => settings.audience;

  @override
  Future<CommentAudience> setCommentAudience(CommentAudience audience) async {
    settings = settings.copyWith(audience: audience);
    return audience;
  }

  @override
  Future<Post> setPostCommentAudience(String postId, CommentAudience audience) async =>
      samplePost(id: postId).copyWith(commentAudience: audience);

  @override
  Future<CommentSettings> getCommentSettings() async => settings;

  @override
  Future<CommentSettings> setAllCommentsOff(bool off) async {
    allOffCalls.add(off);
    settings = settings.copyWith(allOff: off);
    _changes.add(settings);
    return settings;
  }

  @override
  Stream<CommentSettings> watchCommentSettings() => _changes.stream;
}

class _NoMedia extends Fake implements MediaRepository {}

Post _own(String id) => samplePost(id: id).copyWith(commentAudience: CommentAudience.everyone, commentCount: 3);

void main() {
  group('model', () {
    test('comments turned off from the account reach the owner', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'can_comment': false,
        'comment_audience': 'everyone',
        'comment_restriction': 'off',
        'comments_off_by_account': true,
      }).toEntity();
      expect(post.commentsOffByAccount, isTrue);
      expect(post.commentsOff, isTrue);
      expect(post.commentCountHidden, isFalse);
      expect(post.commentAudience, CommentAudience.everyone);
    });

    test('older servers leave the account switch off', () {
      final post = FeedPostModel.fromJson(feedRow('p-1')).toEntity();
      expect(post.commentsOffByAccount, isFalse);
    });
  });

  group('FeedRepositoryImpl', () {
    late MockApi api;
    late FeedRepositoryImpl repo;

    setUp(() {
      api = mockApi();
      repo = FeedRepositoryImpl(api);
    });

    test('reads the account switch', () async {
      when(
        () => api.rpcValue('get_comment_settings', any()),
      ).thenAnswer((_) async => <String, dynamic>{'audience': 'followers', 'all_off': true});
      expect(
        await repo.getCommentSettings(),
        const CommentSettings(audience: CommentAudience.followers, allOff: true),
      );
    });

    test('knows when the server has no account switch yet', () async {
      when(
        () => api.rpcValue('get_comment_settings', any()),
      ).thenAnswer((_) async => <String, dynamic>{'audience': 'everyone'});
      expect((await repo.getCommentSettings()).allOffAvailable, isFalse);
    });

    test('saves the switch and tells listeners', () async {
      when(
        () => api.rpcValue('set_all_comments_off', {'p_off': true}),
      ).thenAnswer((_) async => <String, dynamic>{'audience': 'everyone', 'all_off': true});
      final seen = <CommentSettings>[];
      final sub = repo.watchCommentSettings().listen(seen.add);
      final saved = await repo.setAllCommentsOff(true);
      await pumpEventQueue();
      expect(saved.allOff, isTrue);
      expect(seen.single.allOff, isTrue);
      await sub.cancel();
    });
  });

  group('ComposeCubit', () {
    test('locks the audience while comments are off on every post', () async {
      final feed = _AccountFeed(settings: const CommentSettings(audience: CommentAudience.followers, allOff: true));
      final cubit = ComposeCubit(feed: feed, media: _NoMedia());
      await cubit.loadCommentAudience();
      expect(cubit.state.commentsAllOff, isTrue);
      cubit.setCommentAudience(CommentAudience.everyone);
      expect(cubit.state.commentAudience, isNull);
      await cubit.submit('Post saat komentar mati');
      expect(feed.created, [null]);
      expect(cubit.state.commentsAllOff, isTrue);
      await cubit.close();
    });
  });

  group('FeedCubit', () {
    test('locks own posts at once and reloads them when comments come back', () async {
      final feed = _AccountFeed()..posts = [_own('p-mine'), samplePost(id: 'p-other', author: alice)];
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global(), currentUserId: () => me.id);
      await cubit.load();
      await feed.setAllCommentsOff(true);
      await pumpEventQueue();
      final mine = cubit.state.posts.firstWhere((p) => p.id == 'p-mine');
      final other = cubit.state.posts.firstWhere((p) => p.id == 'p-other');
      expect(mine.commentsOffByAccount, isTrue);
      expect(mine.canComment, isFalse);
      expect(other.commentsOff, isFalse);
      await feed.setAllCommentsOff(false);
      await pumpEventQueue();
      expect(feed.reloaded, ['p-mine']);
      expect(cubit.state.posts.firstWhere((p) => p.id == 'p-mine').commentsOffByAccount, isFalse);
      await cubit.close();
    });
  });

  group('CommentThreadCubit', () {
    test('hides the thread of an own post when comments go off everywhere', () async {
      final feed = _AccountFeed()..posts = [_own('p-1')];
      final cubit = CommentThreadCubit(
        feed: feed,
        comments: FakeCommentRepository(),
        postId: 'p-1',
        fetchPost: false,
        initialPost: _own('p-1'),
      );
      await cubit.load();
      expect(cubit.state.comments, isNotEmpty);
      await feed.setAllCommentsOff(true);
      await pumpEventQueue();
      expect(cubit.state.comments, isEmpty);
      expect(cubit.state.post?.commentsOffByAccount, isTrue);
      await cubit.close();
    });
  });

  group('widgets', () {
    testWidgets('the owner gets no per-post controls while the account switch is on', (tester) async {
      final post = lockOwn(_own('p-1'));
      await pumpFeatureApp(
        tester,
        SingleChildScrollView(
          child: PostCard(post: post, onLike: () {}, onCommentAudience: (_, _) async => true),
        ),
      );
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(find.text('Matikan komentar'), findsNothing);
      expect(find.text('Nyalakan komentar'), findsNothing);
      expect(find.text('Atur siapa yang bisa berkomentar'), findsNothing);
    });

    testWidgets('the owner is told where to turn comments back on', (tester) async {
      final cubit = CommentThreadCubit(
        feed: FakeFeedRepository(),
        comments: FakeCommentRepository(),
        postId: 'p-1',
        fetchPost: false,
        initialPost: lockOwn(_own('p-1')),
      );
      addTearDown(cubit.close);
      await pumpFeatureApp(tester, BlocProvider.value(value: cubit, child: const CommentReplyComposer()));
      expect(
        find.text('Komentar dimatikan untuk semua postingan Anda. Nyalakan lagi di pengaturan komunitas.'),
        findsOneWidget,
      );
    });

    testWidgets('settings switch turns comments off everywhere and locks the audience choice', (tester) async {
      final feed = _AccountFeed();
      await pumpFeatureApp(
        tester,
        const SingleChildScrollView(child: CommunityCommentAudienceSettings()),
        dependencies: FakeDependencies(feed: feed),
      );
      await tester.pumpAndSettle();
      expect(find.text('Matikan komentar di semua postingan'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('account-comments-all-off')));
      await tester.pumpAndSettle();
      expect(feed.allOffCalls, [true]);
      expect(find.text('Komentar dimatikan di semua postingan.'), findsOneWidget);
      final tile = tester.widget<RadioListTile<CommentAudience>>(
        find.byKey(const ValueKey('account-comment-audience-everyone')),
      );
      expect(tile.enabled, isFalse);
      await tester.tap(find.byKey(const ValueKey('account-comments-all-off')));
      await tester.pumpAndSettle();
      expect(feed.allOffCalls, [true, false]);
    });

    testWidgets('settings hide the switch on servers without it', (tester) async {
      final feed = _AccountFeed(settings: const CommentSettings(allOffAvailable: false));
      await pumpFeatureApp(
        tester,
        const SingleChildScrollView(child: CommunityCommentAudienceSettings()),
        dependencies: FakeDependencies(feed: feed),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('account-comments-all-off')), findsNothing);
      expect(find.text('Izinkan komentar dari'), findsOneWidget);
    });
  });

  test('maps invalid_comment_setting', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    expect(
      l10n.errorMessage(const CommunityException(CommunityErrorKind.invalidInput, code: 'invalid_comment_setting')),
      'Pengaturan komentar tidak valid.',
    );
  });
}

Post lockOwn(Post post) => post.copyWith(
  commentsOffByAccount: true,
  canComment: false,
  commentRestriction: CommentAudience.off,
);
