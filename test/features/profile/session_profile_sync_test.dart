import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/app/community_current_user.dart';
import 'package:rendezvous_community/src/core/auth/auth_bridge_client.dart';
import 'package:rendezvous_community/src/core/auth/token_manager.dart';
import 'package:rendezvous_community/src/features/profile/data/repositories/profile_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';

const _oldUser = {'id': 'u-1', 'username': 'budi', 'display_name': 'Budi', 'avatar_url': null, 'is_verified': true};

Map<String, dynamic> _profileRow({
  String name = 'Budi Baru',
  String? avatar = 'https://cdn.test/avatars/u-1/new.png',
}) => {
  'id': 'u-1',
  'username': 'budi',
  'display_name': name,
  'avatar_url': avatar,
  'is_verified': true,
  'created_at': '2026-11-01T00:00:00Z',
  'is_me': true,
};

class _Bridge {
  _Bridge(this.now);

  DateTime now;
  Map<String, Object?> user = Map.of(_oldUser);
  int calls = 0;

  http.Response respond(http.Request request) {
    calls++;
    return http.Response(
      jsonEncode({
        'access_token': 'jwt-$calls',
        'expires_at': now.add(const Duration(minutes: 15)).millisecondsSinceEpoch ~/ 1000,
        'user': user,
      }),
      200,
      request: request,
    );
  }
}

class _UserFeed extends FakeDependencies implements CommunityUserChanges {
  _UserFeed(this.user);

  final _changes = StreamController<UserSummary?>.broadcast();
  UserSummary? user;

  @override
  UserSummary? get currentUser => user;

  @override
  Stream<UserSummary?> get userChanges => _changes.stream;

  void change(UserSummary next) {
    user = next;
    _changes.add(next);
  }
}

void main() {
  const fresh = UserSummary(
    id: 'u-1',
    username: 'budi',
    displayName: 'Budi Baru',
    avatarUrl: 'https://cdn.test/avatars/u-1/new.png',
    isVerified: true,
  );

  group('TokenManager.updateSessionUser', () {
    late _Bridge bridge;
    late DateTime now;

    TokenManager build() {
      now = DateTime.utc(2026, 11, 11, 9);
      bridge = _Bridge(now);
      return TokenManager(
        bridge: AuthBridgeClient(
          baseUrl: 'http://localhost:8000/bridge/v1',
          anonKey: 'anon',
          httpClient: MockClient((request) async => bridge.respond(request)),
        ),
        tokenProvider: () async => 'host-token',
        clock: () => now,
      );
    }

    test('replaces only the user, keeps the token and expiry, and emits the new session', () async {
      final tokens = build();
      addTearDown(tokens.dispose);
      final before = await tokens.refresh();
      final emitted = <SocialSession?>[];
      final sub = tokens.sessionChanges.listen(emitted.add);
      addTearDown(sub.cancel);

      tokens.updateSessionUser(fresh);
      await pumpEventQueue();

      final after = tokens.currentSession!;
      expect(after.user, fresh);
      expect(after.accessToken, before.accessToken);
      expect(after.expiresAt, before.expiresAt);
      expect(await tokens.accessToken(), before.accessToken);
      expect(bridge.calls, 1);
      expect(emitted, [after]);
    });

    test('ignores a user with another id', () async {
      final tokens = build();
      addTearDown(tokens.dispose);
      final before = await tokens.refresh();
      final emitted = <SocialSession?>[];
      final sub = tokens.sessionChanges.listen(emitted.add);
      addTearDown(sub.cancel);

      tokens.updateSessionUser(fresh.copyWith(id: 'u-2'));
      await pumpEventQueue();

      expect(tokens.currentSession, before);
      expect(emitted, isEmpty);
    });

    test('does nothing without a session or after dispose', () async {
      final tokens = build();
      final emitted = <SocialSession?>[];
      final sub = tokens.sessionChanges.listen(emitted.add);

      tokens.updateSessionUser(fresh);
      await pumpEventQueue();
      expect(tokens.currentSession, isNull);
      expect(emitted, isEmpty);

      await tokens.refresh();
      await sub.cancel();
      await tokens.dispose();
      tokens.updateSessionUser(fresh);
    });

    test('a refresh served from the bridge cache keeps the edited name and photo', () async {
      final tokens = build();
      addTearDown(tokens.dispose);
      await tokens.refresh();
      tokens.updateSessionUser(fresh);

      final refreshed = await tokens.refresh();

      expect(refreshed.accessToken, 'jwt-2');
      expect(refreshed.user.displayName, 'Budi Baru');
      expect(refreshed.user.avatarUrl, fresh.avatarUrl);
      expect(tokens.currentSession!.user.name, 'Budi Baru');
    });

    test('newer data from the bridge wins again once it differs from the pre-edit profile', () async {
      final tokens = build();
      addTearDown(tokens.dispose);
      await tokens.refresh();
      tokens.updateSessionUser(fresh);

      bridge.user = {..._oldUser, 'display_name': 'Budi Baru', 'avatar_url': fresh.avatarUrl};
      await tokens.refresh();
      bridge.user = {..._oldUser, 'display_name': 'Budi Moderasi', 'avatar_url': null};
      final moderated = await tokens.refresh();

      expect(moderated.user.displayName, 'Budi Moderasi');
      expect(moderated.user.avatarUrl, isNull);
    });

    test('signing out forgets the edited profile', () async {
      final tokens = build();
      addTearDown(tokens.dispose);
      await tokens.refresh();
      tokens.updateSessionUser(fresh);

      tokens.clear();
      final next = await tokens.refresh();

      expect(next.user.displayName, 'Budi');
      expect(next.user.avatarUrl, isNull);
    });
  });

  group('ProfileRepositoryImpl', () {
    late MockApi api;
    late List<UserSummary> changed;
    late ProfileRepositoryImpl profiles;

    setUp(() {
      api = mockApi();
      changed = [];
      profiles = ProfileRepositoryImpl(api, onMyProfileChanged: changed.add);
      when(() => api.update(any(), any(), any())).thenAnswer((_) async {});
    });

    test('saving reloads the profile and reports the fresh user', () async {
      when(() => api.rpcRows('get_profile', any())).thenAnswer((_) async => [_profileRow()]);

      await profiles.updateMyProfile(displayName: 'Budi Baru', bio: 'Investor');

      verify(() => api.rpcRows('get_profile', {'p_user_id': 'u-1', 'p_username': null})).called(1);
      expect(changed.single.displayName, 'Budi Baru');
      expect(changed.single.avatarUrl, fresh.avatarUrl);
    });

    test('a failed reload does not fail the save', () async {
      when(() => api.rpcRows('get_profile', any())).thenThrow(const CommunityException(CommunityErrorKind.network));

      await profiles.updateMyProfile(displayName: 'Budi Baru');

      verify(() => api.update('profiles', {'display_name': 'Budi Baru'}, {'id': 'u-1'})).called(1);
      expect(changed, isEmpty);
    });

    test('a failed save does not reload or report anything', () async {
      when(() => api.update(any(), any(), any())).thenThrow(const CommunityException(CommunityErrorKind.network));

      await expectLater(profiles.updateMyProfile(displayName: 'Budi Baru'), throwsA(isA<CommunityException>()));

      verifyNever(() => api.rpcRows('get_profile', any()));
      expect(changed, isEmpty);
    });
  });

  group('RendezvousCommunity', () {
    late _Bridge bridge;
    late List<String> requests;
    late bool profileFails;
    late bool jwtExpired;

    RendezvousCommunity create() {
      bridge = _Bridge(DateTime.now().toUtc());
      requests = [];
      profileFails = false;
      jwtExpired = false;
      final community = RendezvousCommunity.create(
        supabaseUrl: 'http://api.test',
        anonKey: 'anon',
        tokenProvider: () async => 'olt-session',
        trackDelivery: false,
        httpClient: MockClient((request) async {
          requests.add('${request.method} ${request.url.path}');
          return switch (request.url.path) {
            '/bridge/v1/exchange' => bridge.respond(request),
            '/rest/v1/profiles' => http.Response('', 204, request: request),
            '/rest/v1/rpc/get_profile' when jwtExpired => () {
              jwtExpired = false;
              return http.Response(jsonEncode({'code': 'PGRST303', 'message': 'JWT expired'}), 401, request: request);
            }(),
            '/rest/v1/rpc/get_profile' =>
              profileFails
                  ? http.Response('{"message":"boom"}', 500, request: request)
                  : http.Response(jsonEncode([_profileRow()]), 200, request: request),
            _ => http.Response('[]', 200, request: request),
          };
        }),
      );
      addTearDown(community.dispose);
      return community;
    }

    test('after saving the profile currentUser and userChanges carry the new name and photo', () async {
      final community = create();
      await community.ensureSignedIn();
      final users = <UserSummary?>[];
      final sub = community.userChanges.listen(users.add);
      addTearDown(sub.cancel);

      await community.profiles.updateMyProfile(displayName: 'Budi Baru');
      await pumpEventQueue();

      expect(community.currentUser!.displayName, 'Budi Baru');
      expect(community.currentUser!.avatarUrl, fresh.avatarUrl);
      expect(users.last!.displayName, 'Budi Baru');
      expect(requests.where((r) => r.endsWith('/exchange')), hasLength(1));
    });

    test('a failed reload keeps the save successful and the old session user', () async {
      final community = create();
      await community.ensureSignedIn();
      profileFails = true;

      await community.profiles.updateMyProfile(displayName: 'Budi Baru');

      expect(requests, contains('PATCH /rest/v1/profiles'));
      expect(community.currentUser!.displayName, 'Budi');
    });

    test('a token refresh after editing does not bring back the old name and photo', () async {
      final community = create();
      await community.ensureSignedIn();
      await community.profiles.updateMyProfile(displayName: 'Budi Baru');

      jwtExpired = true;
      await community.profiles.getProfile(userId: 'u-1');

      expect(bridge.calls, 2);
      expect(community.currentUser!.displayName, 'Budi Baru');
      expect(community.currentUser!.avatarUrl, fresh.avatarUrl);
    });
  });

  group('open widgets', () {
    testWidgets('the compose prompt shows the edited user without being rebuilt', (tester) async {
      final deps = _UserFeed(const UserSummary(id: 'u-1', username: 'budi', displayName: 'Budi'));
      final seen = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: CommunityLocalizations.localizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Scaffold(
            body: CommunityScope(
              dependencies: deps,
              child: CommunityBuildersScope(
                builders: CommunityBuilders(
                  feed: CommunityFeedBuilders(
                    composePrompt: (context, d, fallback) {
                      seen.add(d.user?.displayName);
                      return Text('penulis ${d.user?.displayName}');
                    },
                  ),
                ),
                child: const CommunityComposePromptCard(),
              ),
            ),
          ),
        ),
      );
      expect(find.text('penulis Budi'), findsOneWidget);

      deps.change(fresh);
      await tester.pump();

      expect(find.text('penulis Budi Baru'), findsOneWidget);
    });
  });
}
