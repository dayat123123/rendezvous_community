import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_updates.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/reply_composer.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

class _ControlledFeed extends FakeFeedRepository implements CommentControlRepository {
  CommentAudience account = CommentAudience.followers;
  final created = <CommentAudience?>[];
  final changes = <(String, CommentAudience)>[];
  Object? createError;

  @override
  Future<Post> createPost({
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    PollDraft? poll,
    String? clientId,
    CommentAudience? commentAudience,
  }) async {
    final failure = createError;
    if (failure != null) throw failure;
    created.add(commentAudience);
    return Post(id: 'p-new', author: me, body: body, createdAt: now, cursor: 'c', commentAudience: commentAudience);
  }

  @override
  Future<CommentAudience> getCommentAudience() async => account;

  @override
  Future<CommentAudience> setCommentAudience(CommentAudience audience) async => account = audience;

  @override
  Future<Post> setPostCommentAudience(String postId, CommentAudience audience) async {
    changes.add((postId, audience));
    return samplePost(id: postId).copyWith(
      commentAudience: audience,
      commentRestriction: audience == CommentAudience.off ? CommentAudience.off : null,
      canComment: audience != CommentAudience.off,
    );
  }
}

class _NoMedia extends Fake implements MediaRepository {}

Map<String, dynamic> _row({
  Object? canComment,
  Object? audience,
  Object? restriction,
  Object? commentCount = 7,
  bool withControls = true,
}) => {
  ...feedRow('p-1'),
  'comment_count': commentCount,
  if (withControls) ...{
    'can_comment': canComment,
    'comment_audience': audience,
    'comment_restriction': restriction,
  },
};

Future<void> _pumpCard(WidgetTester tester, Post post, {PostCommentAudienceSaver? onCommentAudience}) =>
    pumpFeatureApp(
      tester,
      SingleChildScrollView(
        child: PostCard(post: post, onLike: () {}, onCommentAudience: onCommentAudience),
      ),
    );

void main() {
  group('FeedPostModel', () {
    test('reads comment controls from the server', () {
      final post = FeedPostModel.fromJson(
        _row(canComment: false, audience: null, restriction: 'followers'),
      ).toEntity();
      expect(post.canComment, isFalse);
      expect(post.commentRestriction, CommentAudience.followers);
      expect(post.commentAudience, isNull);
      expect(post.commentsOff, isFalse);
    });

    test('keeps comments open when the server has no comment controls yet', () {
      final post = FeedPostModel.fromJson(_row(withControls: false)).toEntity();
      expect(post.canComment, isTrue);
      expect(post.commentAudience, isNull);
      expect(post.commentRestriction, isNull);
    });

    test('hides the comment count from other people when comments are off', () {
      final post = FeedPostModel.fromJson(
        _row(canComment: false, restriction: 'off', commentCount: null),
      ).toEntity();
      expect(post.commentsOff, isTrue);
      expect(post.commentCountHidden, isTrue);
      expect(post.commentCount, 0);
    });

    test('the owner keeps seeing the count when comments are off', () {
      final post = FeedPostModel.fromJson(
        _row(canComment: false, audience: 'off', restriction: 'off'),
      ).toEntity();
      expect(post.commentsOff, isTrue);
      expect(post.commentCountHidden, isFalse);
      expect(post.commentCount, 7);
    });

    test('a blocked viewer cannot comment and gets no audience hint', () {
      final post = FeedPostModel.fromJson(_row(canComment: false, restriction: 'blocked')).toEntity();
      expect(post.canComment, isFalse);
      expect(post.commentRestriction, isNull);
    });
  });

  group('FeedRepositoryImpl comment controls', () {
    late MockApi api;
    late FeedRepositoryImpl repo;

    setUp(() {
      api = mockApi();
      repo = FeedRepositoryImpl(api);
    });

    test('createPost sends the chosen audience', () async {
      when(() => api.rpcRows('create_post', any())).thenAnswer((_) async => [feedRow('p-new')]);
      await repo.createPost(body: 'Halo', commentAudience: CommentAudience.followingAndFollowers);
      final params = verify(() => api.rpcRows('create_post', captureAny())).captured.single as Map<String, Object?>;
      expect(params['p_comment_audience'], 'following_and_followers');
    });

    test('createPost leaves the audience to the account default when none is chosen', () async {
      when(() => api.rpcRows('create_post', any())).thenAnswer((_) async => [feedRow('p-new')]);
      await repo.createPost(body: 'Halo');
      final params = verify(() => api.rpcRows('create_post', captureAny())).captured.single as Map<String, Object?>;
      expect(params.containsKey('p_comment_audience'), isFalse);
    });

    test('createPost retries without the audience on a server without comment controls', () async {
      var calls = 0;
      when(() => api.rpcRows('create_post', any())).thenAnswer((invocation) async {
        final params = invocation.positionalArguments[1] as Map<String, Object?>;
        calls++;
        if (params.containsKey('p_comment_audience')) {
          throw const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202');
        }
        return [feedRow('p-new')];
      });
      final post = await repo.createPost(body: 'Halo', commentAudience: CommentAudience.off);
      expect(post.id, 'p-new');
      expect(calls, 2);
    });

    test('reads and saves the account setting', () async {
      when(() => api.rpcValue('get_comment_settings', any())).thenAnswer((_) async => {'audience': 'followers'});
      when(
        () => api.rpcValue('set_comment_audience', {'p_audience': 'following'}),
      ).thenAnswer((_) async => {'audience': 'following'});
      expect(await repo.getCommentAudience(), CommentAudience.followers);
      expect(await repo.setCommentAudience(CommentAudience.following), CommentAudience.following);
    });

    test('changes the audience of one post', () async {
      when(
        () => api.rpcRows('set_post_comment_audience', {'p_post_id': 'p-1', 'p_audience': 'off'}),
      ).thenAnswer((_) async => [_row(canComment: false, audience: 'off', restriction: 'off')]);
      final post = await repo.setPostCommentAudience('p-1', CommentAudience.off);
      expect(post.commentAudience, CommentAudience.off);
      expect(post.canComment, isFalse);
    });
  });

  group('ComposeCubit', () {
    test('starts from the account setting and posts the chosen audience', () async {
      final feed = _ControlledFeed();
      final cubit = ComposeCubit(feed: feed, media: _NoMedia());
      await cubit.loadCommentAudience();
      expect(cubit.state.effectiveCommentAudience, CommentAudience.followers);
      cubit.setCommentAudience(CommentAudience.off);
      await cubit.submit('Post tanpa komentar');
      expect(feed.created, [CommentAudience.off]);
      expect(cubit.state.effectiveCommentAudience, CommentAudience.followers);
      await cubit.close();
    });

    test('leaves the audience to the server when the user does not change it', () async {
      final feed = _ControlledFeed();
      final cubit = ComposeCubit(feed: feed, media: _NoMedia());
      await cubit.loadCommentAudience();
      await cubit.submit('Post biasa');
      expect(feed.created, [null]);
      await cubit.close();
    });

    test('hides the choice when the repository has no comment controls', () async {
      final cubit = ComposeCubit(feed: FakeFeedRepository(), media: _NoMedia());
      await cubit.loadCommentAudience();
      expect(cubit.state.canChooseCommentAudience, isFalse);
      await cubit.close();
    });
  });

  group('applyPostUpdate', () {
    final base = samplePost(author: alice).copyWith(commentCount: 3);

    test('hides comments from viewers when the owner turns them off', () {
      final updated = applyPostUpdate(
        base,
        const PostUpdated('p-1', likeCount: 1, commentCount: 4, deleted: false, commentsOff: true),
        currentUserId: me.id,
      );
      expect(updated.commentsOff, isTrue);
      expect(updated.canComment, isFalse);
      expect(updated.commentCount, 0);
    });

    test('keeps counts flowing for the owner', () {
      final owned = samplePost().copyWith(commentAudience: CommentAudience.off, commentRestriction: CommentAudience.off);
      final updated = applyPostUpdate(
        owned,
        const PostUpdated('p-1', likeCount: 1, commentCount: 4, deleted: false, commentsOff: true),
        currentUserId: me.id,
      );
      expect(updated.commentCount, 4);
    });

    test('asks for a fresh copy when comments come back on for a viewer', () {
      final off = base.copyWith(canComment: false, commentRestriction: CommentAudience.off);
      const on = PostUpdated('p-1', likeCount: 1, commentCount: 4, deleted: false, commentsOff: false);
      expect(shouldReloadAfterUpdate(off, on), isTrue);
      expect(shouldReloadAfterUpdate(base, on), isFalse);
    });
  });

  group('PostCard', () {
    testWidgets('the owner can turn comments off from the post menu', (tester) async {
      final saved = <CommentAudience>[];
      final post = samplePost().copyWith(commentAudience: CommentAudience.everyone);
      await _pumpCard(
        tester,
        post,
        onCommentAudience: (_, audience) async {
          saved.add(audience);
          return true;
        },
      );
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(find.text('Atur siapa yang bisa berkomentar'), findsOneWidget);
      await tester.tap(find.text('Matikan komentar'));
      await tester.pumpAndSettle();
      expect(saved, [CommentAudience.off]);
      expect(find.text('Komentar dimatikan.'), findsOneWidget);
    });

    testWidgets('the owner picks an audience from a dialog', (tester) async {
      final saved = <CommentAudience>[];
      final post = samplePost().copyWith(commentAudience: CommentAudience.everyone);
      await _pumpCard(
        tester,
        post,
        onCommentAudience: (_, audience) async {
          saved.add(audience);
          return true;
        },
      );
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atur siapa yang bisa berkomentar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      await tester.tap(find.byKey(const ValueKey('comment-audience-followers')));
      await tester.pumpAndSettle();
      expect(saved, [CommentAudience.followers]);
      expect(find.text('Pengaturan komentar disimpan.'), findsOneWidget);
    });

    testWidgets('cancelling the audience dialog keeps the post as it is', (tester) async {
      final saved = <CommentAudience>[];
      final post = samplePost().copyWith(commentAudience: CommentAudience.everyone);
      await _pumpCard(
        tester,
        post,
        onCommentAudience: (_, audience) async {
          saved.add(audience);
          return true;
        },
      );
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atur siapa yang bisa berkomentar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(saved, isEmpty);
    });

    testWidgets('other people do not get the comment controls', (tester) async {
      await _pumpCard(
        tester,
        samplePost(author: alice),
        onCommentAudience: (_, _) async => true,
      );
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(find.text('Matikan komentar'), findsNothing);
      expect(find.text('Atur siapa yang bisa berkomentar'), findsNothing);
    });

    testWidgets('the comment button is disabled and the count hidden when comments are off', (tester) async {
      final post = samplePost(
        author: alice,
      ).copyWith(commentCount: 0, canComment: false, commentRestriction: CommentAudience.off);
      await _pumpCard(tester, post);
      expect(find.byIcon(Icons.comments_disabled_outlined), findsOneWidget);
      expect(find.byTooltip('Komentar dinonaktifkan'), findsOneWidget);
    });
  });

  group('CommentReplyComposer', () {
    Future<void> pumpComposer(WidgetTester tester, Post post) async {
      final cubit = CommentThreadCubit(
        feed: FakeFeedRepository(),
        comments: FakeCommentRepository(),
        postId: post.id,
        fetchPost: false,
        initialPost: post,
      );
      addTearDown(cubit.close);
      await pumpFeatureApp(tester, BlocProvider.value(value: cubit, child: const CommentReplyComposer()));
    }

    testWidgets('explains who can comment instead of showing the field', (tester) async {
      await pumpComposer(
        tester,
        samplePost(author: alice).copyWith(canComment: false, commentRestriction: CommentAudience.followers),
      );
      expect(find.text('Hanya pengikut @alice yang bisa berkomentar'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('says comments are turned off', (tester) async {
      await pumpComposer(
        tester,
        samplePost(author: alice).copyWith(canComment: false, commentRestriction: CommentAudience.off),
      );
      expect(find.text('Komentar dinonaktifkan'), findsOneWidget);
    });

    testWidgets('keeps the field when the viewer may comment', (tester) async {
      await pumpComposer(tester, samplePost(author: alice));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('slot builder replaces the explanation', (tester) async {
      final cubit = CommentThreadCubit(
        feed: FakeFeedRepository(),
        comments: FakeCommentRepository(),
        postId: 'p-1',
        fetchPost: false,
        initialPost: samplePost(author: alice).copyWith(canComment: false, commentRestriction: CommentAudience.off),
      );
      addTearDown(cubit.close);
      await pumpFeatureApp(
        tester,
        CommunityFeedBuildersScope(
          builders: CommunityFeedBuilders(
            commentRestriction: (context, details, fallback) => Text('custom: ${details.commentsOff}'),
          ),
          child: BlocProvider.value(value: cubit, child: const CommentReplyComposer()),
        ),
      );
      expect(find.text('custom: true'), findsOneWidget);
    });
  });

  group('CommentThreadCubit', () {
    test('locks the composer after the server says comments are off', () async {
      final comments = _FailingComments();
      final cubit = CommentThreadCubit(
        feed: FakeFeedRepository(),
        comments: comments,
        postId: 'p-1',
        fetchPost: false,
        initialPost: samplePost(author: alice),
      );
      expect(await cubit.send('Halo'), isFalse);
      expect(cubit.state.post?.canComment, isFalse);
      expect(cubit.state.post?.commentsOff, isTrue);
      await cubit.close();
    });

    test('clears loaded comments when the owner turns comments off', () async {
      final cubit = CommentThreadCubit(
        feed: _ControlledFeed(),
        comments: FakeCommentRepository(),
        postId: 'p-1',
        fetchPost: false,
        initialPost: samplePost().copyWith(commentAudience: CommentAudience.everyone),
      );
      await cubit.load();
      expect(cubit.state.comments, isNotEmpty);
      expect(await cubit.setCommentAudience(cubit.state.post!, CommentAudience.off), isTrue);
      expect(cubit.state.comments, isEmpty);
      expect(cubit.state.post?.commentsOff, isTrue);
      await cubit.close();
    });
  });

  testWidgets('settings page saves who can comment on new posts', (tester) async {
    final feed = _ControlledFeed();
    await pumpFeatureApp(tester, const CommunityCommentAudienceSettings(), dependencies: FakeDependencies(feed: feed));
    await tester.pumpAndSettle();
    expect(find.text('Izinkan komentar dari'), findsOneWidget);
    expect(find.text('Matikan komentar'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('account-comment-audience-everyone')));
    await tester.pumpAndSettle();
    expect(feed.account, CommentAudience.everyone);
    expect(find.text('Pengaturan komentar disimpan.'), findsOneWidget);
  });

  test('maps the new error codes to readable text', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    expect(
      l10n.errorMessage(const CommunityException(CommunityErrorKind.forbidden, code: 'comments_off')),
      'Komentar untuk postingan ini sudah dinonaktifkan.',
    );
    expect(
      l10n.errorMessage(const CommunityException(CommunityErrorKind.forbidden, code: 'comments_restricted')),
      'Anda tidak termasuk yang boleh berkomentar di postingan ini.',
    );
  });
}

class _FailingComments extends FakeCommentRepository {
  @override
  Future<ThreadComment> createComment({required String postId, String? parentId, required String body}) async =>
      throw const CommunityException(CommunityErrorKind.forbidden, code: 'comments_off');
}
