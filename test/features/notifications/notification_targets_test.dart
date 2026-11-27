import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

AppNotification _n(
  NotificationType type,
  Map<String, Object?> payload, {
  int count = 1,
  int actors = 1,
  UserSummary? actor = alice,
}) => AppNotification(
  id: 'n-${type.name}',
  type: type,
  actor: actor,
  payload: payload,
  eventCount: count,
  actorCount: actors,
  createdAt: DateTime.utc(2026, 11, 27),
  cursor: 'c',
);

class _Taps {
  final posts = <String>[];
  final threads = <String>[];
  final users = <String>[];

  CommunityCallbacks get callbacks => CommunityCallbacks(
    onPostTap: (_, id) => posts.add(id),
    onThreadTap: (_, id, root) => threads.add('$id/$root'),
    onUserTap: (_, user) => users.add(user.id),
  );
}

Future<void> _open(WidgetTester tester, _Taps taps, bool Function(BuildContext context) open) async {
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  await pumpFeatureApp(
    tester,
    Builder(
      builder: (context) => TextButton(onPressed: () => open(context), child: const Text('open')),
    ),
    dependencies: FakeDependencies(callbacks: taps.callbacks),
    features: features,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('notification targets', () {
    final cases = <(String, AppNotification, String)>[
      (
        'a reply to my comment opens the thread of my comment',
        _n(NotificationType.reply, {
          'post_id': 'p-1',
          'comment_id': 'c-2',
          'parent_id': 'c-1',
          'scope': 'comment',
        }, count: 3),
        'thread p-1/c-1',
      ),
      (
        'a comment on my post opens that comment',
        _n(NotificationType.reply, {'post_id': 'p-1', 'comment_id': 'c-3', 'scope': 'post'}),
        'thread p-1/c-3',
      ),
      (
        'a nested comment on my post opens the comment it answers',
        _n(NotificationType.reply, {'post_id': 'p-1', 'comment_id': 'c-4', 'parent_id': 'c-9', 'scope': 'post'}),
        'thread p-1/c-9',
      ),
      (
        'several comments on my post open the post',
        _n(NotificationType.reply, {'post_id': 'p-1', 'comment_id': 'c-3', 'scope': 'post'}, count: 2),
        'post p-1',
      ),
      (
        'a like on my comment opens that comment',
        _n(NotificationType.like, {'post_id': 'p-5', 'target_type': 'comment', 'target_id': 'c-5'}),
        'thread p-5/c-5',
      ),
      (
        'a reaction on my post opens the post',
        _n(NotificationType.like, {'post_id': 'p-5', 'target_type': 'post', 'target_id': 'p-5'}),
        'post p-5',
      ),
      (
        'a mention in a reply opens the comment it answers',
        _n(NotificationType.mention, {'post_id': 'p-6', 'comment_id': 'c-6', 'parent_id': 'c-1'}),
        'thread p-6/c-1',
      ),
      (
        'a mention in a comment opens that comment',
        _n(NotificationType.mention, {'post_id': 'p-6', 'comment_id': 'c-6'}),
        'thread p-6/c-6',
      ),
      ('a mention in a post opens the post', _n(NotificationType.mention, {'post_id': 'p-7'}), 'post p-7'),
      (
        'one new post from someone I follow opens the post',
        _n(NotificationType.followedPost, {'post_id': 'p-8', 'author_id': alice.id}),
        'post p-8',
      ),
      (
        'several new posts from someone I follow open their profile',
        _n(NotificationType.followedPost, {'post_id': 'p-8', 'author_id': alice.id}, count: 2),
        'user ${alice.id}',
      ),
      (
        'one new follower opens their profile',
        _n(NotificationType.follow, {'follower_id': alice.id}),
        'user ${alice.id}',
      ),
    ];

    for (final (name, notification, expected) in cases) {
      testWidgets(name, (tester) async {
        final taps = _Taps();
        await _open(tester, taps, (context) => openCommunityNotification(context, notification));
        expect(
          [
            for (final p in taps.posts) 'post $p',
            for (final t in taps.threads) 'thread $t',
            for (final u in taps.users) 'user $u',
          ],
          [expected],
        );
      });
    }

    testWidgets('several new followers open my followers list', (tester) async {
      final taps = _Taps();
      final notification = _n(NotificationType.follow, {'follower_id': alice.id}, actors: 3);
      await _open(tester, taps, (context) => openCommunityNotification(context, notification));

      expect(taps.users, isEmpty);
      final list = tester.widget<CommunityFollowList>(find.byType(CommunityFollowList));
      expect(list.userId, me.id);
      expect(list.kinds, [FollowListKind.followers]);
    });
  });

  group('push targets', () {
    final cases = <(String, Map<String, Object?>, String)>[
      (
        'a reply push opens the thread of my comment',
        {'type': 'reply', 'post_id': 'p-1', 'comment_id': 'c-2', 'parent_id': 'c-1', 'scope': 'comment'},
        'thread p-1/c-1',
      ),
      (
        'a like push on my comment opens that comment',
        {'type': 'like', 'post_id': 'p-5', 'target_type': 'comment', 'target_id': 'c-5'},
        'thread p-5/c-5',
      ),
      ('a mention push in a post opens the post', {'type': 'mention', 'post_id': 'p-7'}, 'post p-7'),
    ];

    for (final (name, data, expected) in cases) {
      testWidgets(name, (tester) async {
        final taps = _Taps();
        await _open(tester, taps, (context) => openCommunityPush(context, {'source': 'rendezvous_community', ...data}));
        expect([for (final p in taps.posts) 'post $p', for (final t in taps.threads) 'thread $t'], [expected]);
      });
    }
  });
}
