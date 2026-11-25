import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_updates.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/features/search/presentation/cubit/search_cubit.dart';
import 'package:rendezvous_community/src/features/trending/presentation/cubit/trending_cubit.dart';

import '../../support/fakes.dart';

Post _post({
  String id = 'p-1',
  int likeCount = 0,
  bool likedByMe = false,
  String? myReaction,
  List<PostReactionCount> summary = const [],
}) => Post(
  id: id,
  author: alice,
  body: 'Analisis',
  likeCount: likeCount,
  likedByMe: likedByMe,
  myReaction: myReaction,
  reactionSummary: summary,
  createdAt: now,
  cursor: 'cur-$id',
);

class _ListFeed extends FakeReactionFeedRepository {
  _ListFeed(this.posts);

  final List<Post> posts;

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(posts);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _PlainListFeed extends FakeFeedRepository {
  _PlainListFeed(this.posts);

  final List<Post> posts;

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(posts);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Trending implements TrendingRepository {
  _Trending(this.posts);

  final List<Post> posts;

  @override
  Future<TrendingSnapshot> trending({TrendWindow window = TrendWindow.day}) async =>
      TrendingSnapshot(window: window, posts: posts);

  @override
  Future<StockSentiment> stockSentiment(String stockCode) => throw UnimplementedError();
}

class _Search implements SearchRepository {
  _Search(this.posts);

  final List<Post> posts;

  @override
  Future<SearchResults> search(
    String query, {
    SearchType type = SearchType.all,
    String? cursor,
    int limit = 20,
  }) async => SearchResults(query: query, type: type, posts: posts);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('applyPostReaction', () {
    test('adding a reaction bumps the count and summary', () {
      final next = applyPostReaction(
        _post(likeCount: 2, summary: const [PostReactionCount(emoji: '👍', count: 2)]),
        '🔥',
      );
      expect(next.myReaction, '🔥');
      expect(next.likedByMe, isTrue);
      expect(next.likeCount, 3);
      expect(next.reactionSummary, const [
        PostReactionCount(emoji: '👍', count: 2),
        PostReactionCount(emoji: '🔥', count: 1),
      ]);
    });

    test('changing the emoji keeps the count and re-sorts by count then emoji order', () {
      final next = applyPostReaction(
        _post(
          likeCount: 3,
          likedByMe: true,
          myReaction: '👍',
          summary: const [
            PostReactionCount(emoji: '👍', count: 2),
            PostReactionCount(emoji: '🔥', count: 1),
          ],
        ),
        '🔥',
      );
      expect(next.likeCount, 3);
      expect(next.reactionSummary, const [
        PostReactionCount(emoji: '🔥', count: 2),
        PostReactionCount(emoji: '👍', count: 1),
      ]);

      final tie = applyPostReaction(
        _post(
          likeCount: 2,
          likedByMe: true,
          myReaction: '🔥',
          summary: const [
            PostReactionCount(emoji: '🔥', count: 1),
            PostReactionCount(emoji: '😂', count: 1),
          ],
        ),
        '❤️',
      );
      expect(tie.reactionSummary.map((r) => r.emoji), ['❤️', '😂']);
    });

    test('removing drops empty entries and clears the like state', () {
      final next = applyPostReaction(
        _post(
          likeCount: 1,
          likedByMe: true,
          myReaction: '😮',
          summary: const [PostReactionCount(emoji: '😮', count: 1)],
        ),
        null,
      );
      expect(next.myReaction, isNull);
      expect(next.likedByMe, isFalse);
      expect(next.likeCount, 0);
      expect(next.reactionSummary, isEmpty);
    });

    test('re-sending the active emoji is a no-op and like maps to the thumbs up', () {
      final post = _post(likeCount: 1, likedByMe: true, myReaction: '👍');
      expect(applyPostReaction(post, 'like'), same(post));
      expect(applyPostReaction(post, '👍'), same(post));
    });

    test('posts from an older server derive the thumbs up from likes', () {
      final next = applyPostReaction(_post(likeCount: 2, likedByMe: true), '❤️');
      expect(next.likeCount, 2);
      expect(next.reactionSummary, const [
        PostReactionCount(emoji: '👍', count: 1),
        PostReactionCount(emoji: '❤️', count: 1),
      ]);
    });

    test('realtime updates bring the server summary', () {
      final post = _post(likeCount: 1, likedByMe: true, myReaction: '🔥');
      final updated = applyPostUpdate(
        post,
        const PostUpdated(
          'p-1',
          likeCount: 2,
          commentCount: 0,
          deleted: false,
          reactionSummary: [
            PostReactionCount(emoji: '🔥', count: 1),
            PostReactionCount(emoji: '😂', count: 1),
          ],
        ),
      );
      expect(updated.likeCount, 2);
      expect(updated.myReaction, '🔥');
      expect(updated.reactionSummary.map((r) => r.emoji), ['🔥', '😂']);

      final legacy = applyPostUpdate(
        _post(likeCount: 1, likedByMe: true, summary: const [PostReactionCount(emoji: '👍', count: 1)]),
        const PostUpdated('p-1', likeCount: 3, commentCount: 0, deleted: false),
      );
      expect(legacy.reactionSummary, const [PostReactionCount(emoji: '👍', count: 3)]);
    });
  });

  group('FeedCubit.react', () {
    test('updates optimistically and then takes the server row', () async {
      final feed = _ListFeed([_post()]);
      final gate = feed.reactionGate = Completer<void>();
      feed.onReact = (id, emoji) => _post(
        likeCount: 5,
        likedByMe: true,
        myReaction: '🔥',
        summary: const [PostReactionCount(emoji: '🔥', count: 5)],
      ).copyWith(cursor: 'server');
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global());
      addTearDown(cubit.close);
      await cubit.load();

      final pending = cubit.react(cubit.state.posts.single, '🔥');
      final optimistic = cubit.state.posts.single;
      expect(optimistic.myReaction, '🔥');
      expect(optimistic.likeCount, 1);
      expect(optimistic.reactionSummary, const [PostReactionCount(emoji: '🔥', count: 1)]);
      gate.complete();
      await pending;

      expect(feed.reactions, [('p-1', '🔥')]);
      final saved = cubit.state.posts.single;
      expect(saved.likeCount, 5);
      expect(saved.cursor, 'cur-p-1');
    });

    test('rolls back and reports the error', () async {
      final feed = _ListFeed([_post(likeCount: 1, likedByMe: true, myReaction: '👍')]);
      feed.reactionError = const CommunityException(CommunityErrorKind.rateLimited, code: 'rate_limited');
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global());
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.react(cubit.state.posts.single, '😂');

      final post = cubit.state.posts.single;
      expect(post.myReaction, '👍');
      expect(post.likeCount, 1);
      expect(cubit.state.actionErrorId, 1);
    });

    test('toggleLike reacts with the thumbs up or removes any reaction', () async {
      final feed = _ListFeed([_post(), _post(id: 'p-2', likeCount: 1, likedByMe: true, myReaction: '😢')]);
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global());
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.toggleLike(cubit.state.posts.first);
      await cubit.toggleLike(cubit.state.posts.last);

      expect(feed.reactions, [('p-1', '👍'), ('p-2', null)]);
      expect(cubit.state.posts.first.myReaction, '👍');
      expect(cubit.state.posts.last.myReaction, isNull);
      expect(cubit.state.posts.last.likeCount, 0);
    });

    test('re-sending the active emoji does not call the server', () async {
      final feed = _ListFeed([_post(likeCount: 1, likedByMe: true, myReaction: '🔥')]);
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global());
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.react(cubit.state.posts.single, '🔥');
      expect(feed.reactions, isEmpty);
    });

    test('repositories without reactions fall back to like and unlike', () async {
      final feed = _PlainListFeed([_post(), _post(id: 'p-2', likeCount: 1, likedByMe: true)]);
      final cubit = FeedCubit(feed: feed, scope: const FeedScope.global());
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.react(cubit.state.posts.first, '👍');
      await cubit.react(cubit.state.posts.last, null);
      expect(feed.likes, ['p-1']);
      expect(feed.unlikes, ['p-2']);

      await cubit.react(cubit.state.posts.first, '🔥');
      expect(cubit.state.posts.first.myReaction, '👍');
      expect(cubit.state.actionErrorId, 1);
      expect((cubit.state.actionError! as CommunityException).code, postReactionsUnavailableCode);
    });
  });

  group('other cubits', () {
    test('CommentThreadCubit reacts to the opened post', () async {
      final feed = FakeReactionFeedRepository();
      final cubit = CommentThreadCubit(
        feed: feed,
        comments: FakeCommentRepository(),
        postId: 'p-1',
        initialPost: _post(),
        fetchPost: false,
      );
      addTearDown(cubit.close);

      await cubit.react(cubit.state.post!, '😮');
      expect(cubit.state.post!.myReaction, '😮');
      expect(cubit.state.post!.likeCount, 1);

      feed.reactionError = const CommunityException(CommunityErrorKind.forbidden, code: 'blocked');
      await cubit.react(cubit.state.post!, '😂');
      expect(cubit.state.post!.myReaction, '😮');

      feed.reactionError = null;
      await cubit.togglePostLike();
      expect(feed.reactions.last, ('p-1', null));
      expect(cubit.state.post!.myReaction, isNull);
    });

    test('TrendingCubit reacts optimistically and rolls back', () async {
      final feed = FakeReactionFeedRepository();
      final cubit = TrendingCubit(_Trending([_post()]), feed: feed);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.react(cubit.state.snapshot!.posts.single, '❤️');
      expect(cubit.state.snapshot!.posts.single.myReaction, '❤️');

      feed.reactionError = Exception('boom');
      await cubit.react(cubit.state.snapshot!.posts.single, null);
      expect(cubit.state.snapshot!.posts.single.myReaction, '❤️');
      expect(cubit.state.actionErrorId, 1);
    });

    test('SearchCubit reacts optimistically and takes the server row', () async {
      final feed = FakeReactionFeedRepository()
        ..onReact = (id, emoji) => _post(likeCount: 9, likedByMe: true, myReaction: emoji);
      final cubit = SearchCubit(search: _Search([_post()]), feed: feed, debounce: Duration.zero);
      addTearDown(cubit.close);
      cubit.setQuery('bbca');
      await cubit.submit();

      await cubit.react(cubit.state.results!.posts.single, '😢');
      expect(cubit.state.results!.posts.single.myReaction, '😢');
      expect(cubit.state.results!.posts.single.likeCount, 9);
      await cubit.toggleLike(cubit.state.results!.posts.single);
      expect(feed.reactions.last, ('p-1', null));
    });
  });
}
