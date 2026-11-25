import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/network/realtime_gateway.dart';
import 'package:rendezvous_community/src/features/config/data/models/client_config_model.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../support/mock_api.dart';

class _MockRealtime extends Mock implements RealtimeGateway {}

const _missing = CommunityException(CommunityErrorKind.unknown, code: 'PGRST202');

Map<String, dynamic> _reactorRow(String id, {String emoji = '🔥', bool me = false}) => {
  'id': id,
  'username': 'user_$id',
  'display_name': 'User $id',
  'avatar_url': null,
  'is_verified': id == 'u-2',
  'is_official': false,
  'is_me': me,
  'is_following': true,
  'emoji': emoji,
  'reacted_at': '2026-11-20T03:00:00+00:00',
  'cursor': 'cur-$id',
};

void main() {
  late MockApi api;

  setUp(() => api = mockApi());

  group('FeedPostModel reactions', () {
    test('parses my_reaction and reaction_summary when the server sends them', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'liked_by_me': true,
        'my_reaction': '🔥',
        'reaction_summary': [
          {'emoji': '🔥', 'count': 2},
          {'emoji': '👍', 'count': 1},
        ],
      }).toEntity();
      expect(post.myReaction, '🔥');
      expect(post.reactionSummary, const [
        PostReactionCount(emoji: '🔥', count: 2),
        PostReactionCount(emoji: '👍', count: 1),
      ]);
    });

    test('maps the stored like to the thumbs up emoji', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'liked_by_me': true,
        'my_reaction': 'like',
        'reaction_summary': [
          {'emoji': 'like', 'count': 3},
        ],
      }).toEntity();
      expect(post.myReaction, '👍');
      expect(post.reactionSummary.single, const PostReactionCount(emoji: '👍', count: 3));
    });

    test('derives reactions from likes when an older server omits them', () {
      final liked = FeedPostModel.fromJson({...feedRow('p-1'), 'liked_by_me': true}).toEntity();
      expect(liked.myReaction, '👍');
      expect(liked.reactionSummary, const [PostReactionCount(emoji: '👍', count: 3)]);
      final none = FeedPostModel.fromJson({...feedRow('p-2'), 'like_count': 0}).toEntity();
      expect(none.myReaction, isNull);
      expect(none.reactionSummary, isEmpty);
    });

    test('a null my_reaction with an empty summary means no reactions', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'like_count': 0,
        'my_reaction': null,
        'reaction_summary': <Object?>[],
      }).toEntity();
      expect(post.myReaction, isNull);
      expect(post.reactionSummary, isEmpty);
    });

    test('skips malformed and empty summary entries', () {
      final post = FeedPostModel.fromJson({
        ...feedRow('p-1'),
        'reaction_summary': [
          {'emoji': '😂', 'count': 2},
          {'emoji': '', 'count': 4},
          {'emoji': '😮', 'count': 0},
          'junk',
          {'emoji': '❤️', 'count': 1},
        ],
      }).toEntity();
      expect(post.reactionSummary.map((r) => r.emoji), ['😂', '❤️']);
    });

    test('directly built posts still expose an effective reaction view', () {
      final post = Post(
        id: 'p-1',
        author: const UserSummary(id: 'u-1', username: 'budi'),
        body: 'x',
        likeCount: 2,
        likedByMe: true,
        createdAt: DateTime.utc(2026),
        cursor: 'c',
      );
      expect(post.effectiveReaction, '👍');
      expect(post.effectiveReactionSummary, const [PostReactionCount(emoji: '👍', count: 2)]);
    });
  });

  group('client config', () {
    test('postReactions defaults to the built-in set and follows post_reactions', () {
      final fallback = ClientConfigModel.fromJson({'config': <String, dynamic>{}}).toEntity();
      expect(fallback.postReactions, defaultPostReactions);
      final custom = ClientConfigModel.fromJson({
        'config': {
          'post_reactions': ['👍', '🔥'],
        },
      }).toEntity();
      expect(custom.postReactions, ['👍', '🔥']);
    });
  });

  group('setPostReaction', () {
    test('calls set_post_reaction and returns the server row', () async {
      when(() => api.rpcRows('set_post_reaction', any())).thenAnswer(
        (_) async => [
          {
            ...feedRow('p-1'),
            'like_count': 4,
            'liked_by_me': true,
            'my_reaction': '🔥',
            'reaction_summary': [
              {'emoji': '👍', 'count': 3},
              {'emoji': '🔥', 'count': 1},
            ],
          },
        ],
      );
      final post = await FeedRepositoryImpl(api).setPostReaction('p-1', '🔥');
      final params = verify(() => api.rpcRows('set_post_reaction', captureAny())).captured.single;
      expect(params, {'p_post_id': 'p-1', 'p_emoji': '🔥'});
      expect(post!.myReaction, '🔥');
      expect(post.likeCount, 4);
    });

    test('removing sends a null emoji and tolerates an empty result', () async {
      when(() => api.rpcRows('set_post_reaction', any())).thenAnswer((_) async => []);
      final post = await FeedRepositoryImpl(api).setPostReaction('p-1', '');
      final params = verify(() => api.rpcRows('set_post_reaction', captureAny())).captured.single;
      expect(params, {'p_post_id': 'p-1', 'p_emoji': null});
      expect(post, isNull);
    });

    test('falls back to the like row when the RPC is missing', () async {
      when(() => api.rpcRows('set_post_reaction', any())).thenThrow(_missing);
      when(() => api.insert('reactions', any())).thenAnswer((_) async {});
      when(() => api.delete('reactions', any())).thenAnswer((_) async {});
      final repo = FeedRepositoryImpl(api);

      expect(await repo.setPostReaction('p-1', '👍'), isNull);
      verify(
        () => api.insert('reactions', {'user_id': 'u-1', 'target_type': 'post', 'target_id': 'p-1', 'type': 'like'}),
      ).called(1);

      expect(await repo.setPostReaction('p-1', null), isNull);
      verify(() => api.delete('reactions', {'user_id': 'u-1', 'target_type': 'post', 'target_id': 'p-1'})).called(1);
    });

    test('other emojis report that reactions are unavailable on an older server', () async {
      when(() => api.rpcRows('set_post_reaction', any())).thenThrow(_missing);
      await expectLater(
        FeedRepositoryImpl(api).setPostReaction('p-1', '🔥'),
        throwsA(isA<CommunityException>().having((e) => e.code, 'code', postReactionsUnavailableCode)),
      );
      verifyNever(() => api.insert(any(), any()));
    });

    test('server errors other than a missing RPC are rethrown', () async {
      when(
        () => api.rpcRows('set_post_reaction', any()),
      ).thenThrow(const CommunityException(CommunityErrorKind.invalidInput, code: 'invalid_reaction'));
      await expectLater(
        FeedRepositoryImpl(api).setPostReaction('p-1', '👍'),
        throwsA(isA<CommunityException>().having((e) => e.code, 'code', 'invalid_reaction')),
      );
    });

    test('FeedRepositoryImpl is a PostReactionRepository', () {
      expect(FeedRepositoryImpl(api), isA<PostReactionRepository>());
    });
  });

  group('postReactors', () {
    test('maps rows, clamps the limit and pages by cursor', () async {
      when(
        () => api.rpcRows('post_reactors', any()),
      ).thenAnswer((_) async => [_reactorRow('u-2', me: true), _reactorRow('u-3', emoji: 'like')]);
      final page = await FeedRepositoryImpl(api).postReactors('p-1', emoji: '🔥', limit: 2, cursor: 'c0');
      final params = verify(() => api.rpcRows('post_reactors', captureAny())).captured.single;
      expect(params, {'p_post_id': 'p-1', 'p_emoji': '🔥', 'p_limit': 2, 'p_cursor': 'c0'});
      expect(page.items, hasLength(2));
      final first = page.items.first;
      expect(first.user.name, 'User u-2');
      expect(first.user.isVerified, isTrue);
      expect(first.isMe, isTrue);
      expect(first.isFollowing, isTrue);
      expect(first.emoji, '🔥');
      expect(first.reactedAt, DateTime.utc(2026, 11, 20, 3));
      expect(page.items.last.emoji, '👍');
      expect(page.nextCursor, 'cur-u-3');
    });

    test('a short page ends paging and the limit stays within 1 to 50', () async {
      when(() => api.rpcRows('post_reactors', any())).thenAnswer((_) async => [_reactorRow('u-2')]);
      final page = await FeedRepositoryImpl(api).postReactors('p-1', limit: 500);
      final params = verify(() => api.rpcRows('post_reactors', captureAny())).captured.single as Map;
      expect(params['p_limit'], 50);
      expect(params['p_emoji'], isNull);
      expect(page.hasMore, isFalse);
    });

    test('a missing RPC surfaces the unavailable error', () async {
      when(() => api.rpcRows('post_reactors', any())).thenThrow(_missing);
      await expectLater(
        FeedRepositoryImpl(api).postReactors('p-1'),
        throwsA(isA<CommunityException>().having((e) => e.code, 'code', postReactionsUnavailableCode)),
      );
    });
  });

  group('watchPosts', () {
    test('realtime updates carry the reaction summary when the row has it', () async {
      final realtime = _MockRealtime();
      final controller = StreamController<PostgresChangePayload>();
      addTearDown(controller.close);
      when(
        () => realtime.tableChanges(
          table: 'posts',
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => controller.stream);
      final changes = <PostChange>[];
      final sub = FeedRepositoryImpl(api, realtime).watchPosts().listen(changes.add);
      addTearDown(sub.cancel);

      PostgresChangePayload update(Map<String, dynamic> extra) => PostgresChangePayload(
        schema: 'public',
        table: 'posts',
        commitTimestamp: DateTime.utc(2026),
        eventType: PostgresChangeEvent.update,
        newRecord: {
          'id': 'p-1',
          'author_id': 'u-1',
          'like_count': 3,
          'comment_count': 1,
          'created_at': '2026-11-20T03:00:00+00:00',
          ...extra,
        },
        oldRecord: const {},
        errors: null,
      );

      controller
        ..add(
          update({
            'reaction_summary': [
              {'emoji': '❤️', 'count': 2},
              {'emoji': 'like', 'count': 1},
            ],
          }),
        )
        ..add(update(const {}));
      await pumpEventQueue();

      final withSummary = changes.first as PostUpdated;
      expect(withSummary.reactionSummary, const [
        PostReactionCount(emoji: '❤️', count: 2),
        PostReactionCount(emoji: '👍', count: 1),
      ]);
      expect((changes.last as PostUpdated).reactionSummary, isNull);
    });
  });
}
