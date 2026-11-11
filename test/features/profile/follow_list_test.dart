import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/profile/data/repositories/profile_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';

const _cici = UserSummary(id: 'u-c', username: 'cici', displayName: 'Cici');
const _dodi = UserSummary(id: 'u-d', username: 'dodi', displayName: 'Dodi');
const _me = UserSummary(id: 'u-me', username: 'saya', displayName: 'Saya');

FollowListEntry _entry(UserSummary user, {bool following = false, bool followsMe = false, bool isMe = false}) =>
    FollowListEntry(user: user, isFollowing: following, followsMe: followsMe, isMe: isMe, cursor: 'c-${user.id}');

class _Profiles extends Fake implements ProfileRepository, FollowListRepository {
  final pages = <String, Paged<FollowListEntry>>{};
  final calls = <String>[];
  final followed = <String>[];
  Object? listError;
  Object? followError;
  bool blocked = false;
  bool official = false;

  @override
  Future<Paged<FollowListEntry>> followList(
    String userId,
    FollowListKind kind, {
    String? cursor,
    int limit = 30,
  }) async {
    final key = '${kind.name}:$userId:${cursor ?? '-'}';
    calls.add(key);
    final error = listError;
    if (error != null) throw error;
    return pages[key] ?? const Paged([]);
  }

  @override
  Future<void> follow(String userId) async {
    final error = followError;
    if (error != null) throw error;
    followed.add('+$userId');
  }

  @override
  Future<void> unfollow(String userId) async {
    final error = followError;
    if (error != null) throw error;
    followed.add('-$userId');
  }

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => UserProfile(
    user: alice.copyWith(isOfficial: official),
    followerCount: 3,
    followingCount: 2,
    postCount: 0,
    createdAt: now,
    isMe: false,
    isFollowing: false,
    followsMe: false,
    isBlocked: blocked,
  );
}

class _ProfilesWithoutLists extends Fake implements ProfileRepository {
  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => UserProfile(
    user: alice,
    followerCount: 3,
    followingCount: 2,
    postCount: 0,
    createdAt: now,
    isMe: false,
    isFollowing: false,
    followsMe: false,
    isBlocked: false,
  );
}

class _EmptyFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => const Paged([]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required ProfileRepository profiles,
  CommunityCallbacks callbacks = const CommunityCallbacks(),
}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(feed: _EmptyFeed(), profiles: profiles, callbacks: callbacks),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _rowOf(String name) => find.ancestor(of: find.text(name), matching: find.byType(InkWell)).first;

void main() {
  group('repository', () {
    test('reads one page of followers and keeps the cursor when the page is full', () async {
      final api = mockApi();
      when(() => api.rpcRows('get_follow_list', any())).thenAnswer(
        (_) async => [
          {
            'id': 'u-c',
            'username': 'cici',
            'display_name': 'Cici',
            'avatar_url': null,
            'is_verified': true,
            'is_official': true,
            'is_me': false,
            'is_following': true,
            'follows_me': true,
            'followed_at': '2026-11-11T02:00:00Z',
            'cursor': 'c-1',
          },
          {
            'id': 'u-me',
            'username': 'saya',
            'display_name': null,
            'avatar_url': null,
            'is_verified': false,
            'is_official': false,
            'is_me': true,
            'is_following': false,
            'follows_me': false,
            'followed_at': '2026-11-11T01:00:00Z',
            'cursor': 'c-2',
          },
        ],
      );

      final page = await ProfileRepositoryImpl(
        api,
      ).followList('u-a', FollowListKind.followers, cursor: 'c-0', limit: 2);

      verify(
        () => api.rpcRows('get_follow_list', {
          'p_user_id': 'u-a',
          'p_kind': 'followers',
          'p_cursor': 'c-0',
          'p_limit': 2,
        }),
      ).called(1);
      final first = page.items.first;
      expect(first.user.username, 'cici');
      expect(first.user.isVerified, isTrue);
      expect(first.user.isOfficial, isTrue);
      expect(first.isFollowing, isTrue);
      expect(first.followsMe, isTrue);
      expect(first.followedAt, DateTime.utc(2026, 11, 11, 2));
      expect(page.items.last.isMe, isTrue);
      expect(page.nextCursor, 'c-2');
    });

    test('has no next page when the server returns fewer rows than asked', () async {
      final api = mockApi();
      when(() => api.rpcRows('get_follow_list', any())).thenAnswer(
        (_) async => [
          {
            'id': 'u-d',
            'username': 'dodi',
            'is_me': false,
            'is_following': false,
            'follows_me': false,
            'cursor': 'c-9',
          },
        ],
      );

      final page = await ProfileRepositoryImpl(api).followList('u-a', FollowListKind.following);

      verify(
        () => api.rpcRows('get_follow_list', {
          'p_user_id': 'u-a',
          'p_kind': 'following',
          'p_cursor': null,
          'p_limit': 30,
        }),
      ).called(1);
      expect(page.hasMore, isFalse);
    });
  });

  group('CommunityFollowList', () {
    testWidgets('shows followers with the right button for each row', (tester) async {
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged([
          _entry(_cici, following: true),
          _entry(_dodi, followsMe: true),
          _entry(bob),
          _entry(_me, isMe: true),
        ]);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);

      expect(profiles.calls, ['followers:u-a:-']);
      expect(find.descendant(of: _rowOf('Cici'), matching: find.text('Mengikuti')), findsOneWidget);
      expect(find.descendant(of: _rowOf('Dodi'), matching: find.text('Ikuti balik')), findsOneWidget);
      expect(find.descendant(of: _rowOf('Dodi'), matching: find.text('Mengikuti Anda')), findsOneWidget);
      expect(find.descendant(of: _rowOf('Bob'), matching: find.text('Ikuti')), findsOneWidget);
      expect(find.descendant(of: _rowOf('Saya'), matching: find.byType(ButtonStyleButton)), findsNothing);
    });

    testWidgets('follows and unfollows from the list', (tester) async {
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged([_entry(_dodi, followsMe: true), _entry(_cici, following: true)]);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.text('Ikuti balik'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: _rowOf('Cici'), matching: find.text('Mengikuti')));
      await tester.pumpAndSettle();

      expect(profiles.followed, ['+u-d', '-u-c']);
      expect(find.descendant(of: _rowOf('Dodi'), matching: find.text('Mengikuti')), findsOneWidget);
      expect(find.descendant(of: _rowOf('Cici'), matching: find.text('Ikuti')), findsOneWidget);
    });

    testWidgets('reverts the button and shows an error when following fails', (tester) async {
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged([_entry(bob)])
        ..followError = const CommunityException(CommunityErrorKind.network);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.text('Ikuti'));
      await tester.pumpAndSettle();

      expect(find.descendant(of: _rowOf('Bob'), matching: find.text('Ikuti')), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('switches to the following tab and loads it once', (tester) async {
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged([_entry(_cici)])
        ..pages['following:u-a:-'] = Paged([_entry(_dodi, following: true)]);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.widgetWithText(Tab, 'Mengikuti'));
      await tester.pumpAndSettle();

      expect(find.text('Dodi'), findsOneWidget);
      expect(profiles.calls, ['followers:u-a:-', 'following:u-a:-']);

      await tester.tap(find.widgetWithText(Tab, 'Pengikut'));
      await tester.pumpAndSettle();
      expect(find.text('Cici'), findsOneWidget);
      expect(profiles.calls, ['followers:u-a:-', 'following:u-a:-']);
    });

    testWidgets('opens on the following tab when asked', (tester) async {
      final profiles = _Profiles()..pages['following:u-a:-'] = Paged([_entry(_dodi)]);
      await _pump(
        tester,
        const CommunityFollowList(userId: 'u-a', initialKind: FollowListKind.following),
        profiles: profiles,
      );

      expect(profiles.calls, ['following:u-a:-']);
      expect(find.text('Dodi'), findsOneWidget);
    });

    testWidgets('loads the next page near the end of the list', (tester) async {
      final first = [
        for (var i = 0; i < 30; i++) _entry(UserSummary(id: 'u-$i', username: 'user$i', displayName: 'Orang $i')),
      ];
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged(first, nextCursor: 'c-u-29')
        ..pages['followers:u-a:c-u-29'] = Paged([_entry(_dodi)]);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);

      await tester.drag(find.byType(Scrollable).last, const Offset(0, -5000));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(profiles.calls, ['followers:u-a:-', 'followers:u-a:c-u-29']);
      expect(find.text('Dodi'), findsOneWidget);
    });

    testWidgets('shows an empty message for each tab', (tester) async {
      final profiles = _Profiles();
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);
      expect(find.text('Belum ada pengikut.'), findsOneWidget);

      await tester.tap(find.widgetWithText(Tab, 'Mengikuti'));
      await tester.pumpAndSettle();
      expect(find.text('Belum mengikuti siapa pun.'), findsOneWidget);
    });

    testWidgets('shows an error with retry', (tester) async {
      final profiles = _Profiles()..listError = const CommunityException(CommunityErrorKind.network);
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: profiles);
      expect(find.byType(CommunityErrorView), findsOneWidget);

      profiles
        ..listError = null
        ..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Cici'), findsOneWidget);
    });

    testWidgets('opens the profile when a row is tapped', (tester) async {
      UserSummary? opened;
      final profiles = _Profiles()..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await _pump(
        tester,
        const CommunityFollowList(userId: 'u-a'),
        profiles: profiles,
        callbacks: CommunityCallbacks(onUserTap: (_, user) => opened = user),
      );

      await tester.tap(find.text('Cici'));
      expect(opened?.id, 'u-c');
    });

    testWidgets('followListEntry builder replaces each row', (tester) async {
      final seen = <CommunityFollowListEntryDetails>[];
      final profiles = _Profiles()
        ..pages['followers:u-a:-'] = Paged([_entry(_dodi, followsMe: true), _entry(_me, isMe: true)]);
      await _pump(
        tester,
        CommunityFollowList(
          userId: 'u-a',
          builders: CommunityProfileBuilders(
            followListEntry: (context, d, fallback) {
              seen.add(d);
              return Text('row:${d.user.username}:${d.buttonLabel}');
            },
          ),
        ),
        profiles: profiles,
      );

      expect(find.text('row:dodi:Ikuti balik'), findsOneWidget);
      expect(find.text('row:saya:'), findsOneWidget);
      final dodi = seen.firstWhere((d) => d.user.id == 'u-d');
      expect(dodi.kind, FollowListKind.followers);
      expect(dodi.following, isFalse);
      expect(dodi.followsMe, isTrue);
      expect(dodi.onToggleFollow, isNotNull);
      expect(seen.firstWhere((d) => d.isMe).onToggleFollow, isNull);
    });
  });

  group('kinds', () {
    testWidgets('a single kind shows only that list without tabs', (tester) async {
      final profiles = _Profiles()..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await _pump(
        tester,
        const CommunityFollowList(userId: 'u-a', kinds: [FollowListKind.followers]),
        profiles: profiles,
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(Tab), findsNothing);
      expect(find.text('Cici'), findsOneWidget);
      expect(profiles.calls, ['followers:u-a:-']);
    });

    testWidgets('falls back to the first allowed kind when initialKind is not allowed', (tester) async {
      final profiles = _Profiles()..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await _pump(
        tester,
        const CommunityFollowList(
          userId: 'u-a',
          kinds: [FollowListKind.followers],
          initialKind: FollowListKind.following,
        ),
        profiles: profiles,
      );

      expect(profiles.calls, ['followers:u-a:-']);
      expect(find.text('Cici'), findsOneWidget);
    });

    testWidgets('the default still shows both tabs', (tester) async {
      await _pump(tester, const CommunityFollowList(userId: 'u-a'), profiles: _Profiles());

      expect(find.byType(Tab), findsNWidgets(2));
    });
  });

  group('official accounts', () {
    testWidgets('the header hides the following count', (tester) async {
      await _pump(tester, const CommunityUserProfile(userId: 'u-a'), profiles: _Profiles()..official = true);

      expect(find.text('Pengikut'), findsOneWidget);
      expect(find.text('Mengikuti'), findsNothing);
    });

    testWidgets('the follower count opens a followers-only list', (tester) async {
      final profiles = _Profiles()
        ..official = true
        ..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await _pump(tester, const CommunityUserProfile(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.text('Pengikut'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityFollowList), findsOneWidget);
      expect(find.byType(Tab), findsNothing);
      expect(find.text('Cici'), findsOneWidget);
      expect(profiles.calls, ['followers:u-a:-']);
    });

    testWidgets('the details offer no following list', (tester) async {
      CommunityProfileDetails? seen;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: 'u-a',
          builders: CommunityProfileBuilders(
            header: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
        profiles: _Profiles()..official = true,
      );

      expect(seen!.onOpenFollowers, isNotNull);
      expect(seen!.onOpenFollowing, isNull);
    });
  });

  group('profile stats', () {
    testWidgets('tapping the follower count opens the followers list', (tester) async {
      final profiles = _Profiles()..pages['followers:u-a:-'] = Paged([_entry(_cici)]);
      await _pump(tester, const CommunityUserProfile(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.text('Pengikut'));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityFollowList), findsOneWidget);
      expect(find.text('Cici'), findsOneWidget);
      expect(profiles.calls, ['followers:u-a:-']);
    });

    testWidgets('tapping the following count opens the following tab', (tester) async {
      final profiles = _Profiles()..pages['following:u-a:-'] = Paged([_entry(_dodi)]);
      await _pump(tester, const CommunityUserProfile(userId: 'u-a'), profiles: profiles);

      await tester.tap(find.descendant(of: find.byType(Row), matching: find.text('Mengikuti')).first);
      await tester.pumpAndSettle();

      expect(find.text('Dodi'), findsOneWidget);
      expect(profiles.calls, ['following:u-a:-']);
    });

    testWidgets('the header details expose the list openers', (tester) async {
      CommunityProfileDetails? seen;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: 'u-a',
          builders: CommunityProfileBuilders(
            header: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
        profiles: _Profiles(),
      );

      expect(seen!.onOpenFollowers, isNotNull);
      expect(seen!.onOpenFollowing, isNotNull);
    });

    testWidgets('counts are not tappable for a blocked profile', (tester) async {
      CommunityProfileDetails? seen;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: 'u-a',
          builders: CommunityProfileBuilders(
            header: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
        profiles: _Profiles()..blocked = true,
      );

      expect(seen!.onOpenFollowers, isNull);
      expect(seen!.onOpenFollowing, isNull);
    });

    testWidgets('counts are not tappable when the host repository has no follow lists', (tester) async {
      CommunityProfileDetails? seen;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: 'u-a',
          builders: CommunityProfileBuilders(
            header: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
        profiles: _ProfilesWithoutLists(),
      );

      expect(seen!.onOpenFollowers, isNull);
      await tester.tap(find.text('Pengikut'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityFollowList), findsNothing);
    });
  });
}
