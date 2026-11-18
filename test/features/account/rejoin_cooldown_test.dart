import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/auth/auth_bridge_client.dart';
import 'package:rendezvous_community/src/core/auth/token_manager.dart';
import 'package:rendezvous_community/src/features/config/data/models/client_config_model.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/gen/community_localizations.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/legal_fakes.dart';

final _now = DateTime.utc(2026, 11, 18, 9);

http.Response _cooldown(Duration wait) => http.Response(
  jsonEncode({
    'error': 'account_rejoin_cooldown',
    'message': 'Akun komunitas Anda baru saja dihapus.',
    'retry_at': _now.add(wait).toIso8601String(),
  }),
  403,
);

class _Guest implements CommunityGuestSupportDependencies {
  @override
  GuestSupportRepository get guestSupport => throw UnimplementedError();

  @override
  CommunityGuestSessionStore get guestSessions => MemoryGuestSessionStore();
}

Future<void> _pumpError(WidgetTester tester, Object error, {bool guest = true, VoidCallback? onRetry}) async {
  Widget body = CommunityErrorView(error: error, onRetry: onRetry);
  if (guest) body = CommunityGuestSupportScope(dependencies: _Guest(), child: body);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(body: body),
    ),
  );
}

void main() {
  test('auth-bridge cooldown becomes a forbidden error with the remaining wait', () async {
    final client = AuthBridgeClient(
      baseUrl: 'http://localhost/bridge/v1',
      anonKey: 'anon',
      httpClient: MockClient((_) async => _cooldown(const Duration(hours: 72))),
      clock: () => _now,
    );
    await expectLater(
      client.exchange('host-token'),
      throwsA(
        isA<CommunityException>()
            .having((e) => e.kind, 'kind', CommunityErrorKind.forbidden)
            .having((e) => e.code, 'code', 'account_rejoin_cooldown')
            .having((e) => e.retryAfter, 'retryAfter', const Duration(hours: 72)),
      ),
    );
  });

  test('token manager remembers the cooldown per host login for a few minutes only', () async {
    var now = _now;
    var calls = 0;
    var token = 'host-a';
    final tokens = TokenManager(
      bridge: AuthBridgeClient(
        baseUrl: 'http://localhost/bridge/v1',
        anonKey: 'anon',
        httpClient: MockClient((_) async {
          calls++;
          return _cooldown(const Duration(hours: 2));
        }),
        clock: () => _now,
      ),
      tokenProvider: () async => token,
      clock: () => now,
    );
    addTearDown(tokens.dispose);

    await expectLater(tokens.refresh(), throwsA(isA<CommunityException>()));
    now = now.add(const Duration(minutes: 3));
    await expectLater(
      tokens.refresh(),
      throwsA(isA<CommunityException>().having((e) => e.retryAfter, 'retryAfter', const Duration(minutes: 117))),
    );
    expect(calls, 1);

    token = 'host-b';
    await expectLater(tokens.refresh(), throwsA(isA<CommunityException>()));
    expect(calls, 2);

    token = 'host-a';
    now = now.add(const Duration(minutes: 3));
    await expectLater(tokens.refresh(), throwsA(isA<CommunityException>()));
    expect(calls, 3);
  });

  test('a wait shortened in the Hub takes effect at the next recheck', () async {
    var now = _now;
    var cooldown = true;
    final tokens = TokenManager(
      bridge: AuthBridgeClient(
        baseUrl: 'http://localhost/bridge/v1',
        anonKey: 'anon',
        httpClient: MockClient((_) async {
          if (cooldown) return _cooldown(const Duration(hours: 72));
          return http.Response(
            jsonEncode({
              'access_token': 'jwt',
              'expires_at': now.add(const Duration(minutes: 15)).millisecondsSinceEpoch ~/ 1000,
              'user': {'id': 'u-1', 'username': 'budi'},
            }),
            200,
          );
        }),
        clock: () => _now,
      ),
      tokenProvider: () async => 'host-a',
      clock: () => now,
    );
    addTearDown(tokens.dispose);

    await expectLater(tokens.refresh(), throwsA(isA<CommunityException>()));
    cooldown = false;
    await expectLater(tokens.refresh(), throwsA(isA<CommunityException>()));
    now = now.add(const Duration(minutes: 5));
    expect((await tokens.refresh()).accessToken, 'jwt');
  });

  test('error text names the remaining wait in hours or days, and explains bans', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    CommunityException cooldown(Duration? wait) =>
        CommunityException(CommunityErrorKind.forbidden, code: 'account_rejoin_cooldown', retryAfter: wait);
    expect(
      l10n.errorMessage(cooldown(const Duration(hours: 72))),
      'Akun komunitas Anda baru saja dihapus. Anda bisa bergabung lagi dalam 3 hari.',
    );
    expect(l10n.errorMessage(cooldown(const Duration(hours: 4, minutes: 10))), contains('dalam 5 jam.'));
    expect(l10n.errorMessage(cooldown(const Duration(minutes: 5))), contains('dalam 1 jam.'));
    expect(l10n.errorMessage(cooldown(null)), l10n.errorRejoinCooldown);
    expect(
      l10n.errorMessage(const CommunityException(CommunityErrorKind.forbidden, code: 'user_banned')),
      'Akun Anda diblokir dari fitur komunitas.',
    );
  });

  testWidgets('a locked account offers Hubungi CS next to retry', (tester) async {
    var retried = false;
    await _pumpError(
      tester,
      const CommunityException(
        CommunityErrorKind.forbidden,
        code: 'account_rejoin_cooldown',
        retryAfter: Duration(hours: 10),
      ),
      onRetry: () => retried = true,
    );
    expect(find.textContaining('dalam 10 jam'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Hubungi CS'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Coba lagi'));
    expect(retried, isTrue);
  });

  testWidgets('without guest support the locked account shows only the message', (tester) async {
    await _pumpError(tester, const CommunityException(CommunityErrorKind.forbidden, code: 'user_banned'), guest: false);
    expect(find.text('Akun Anda diblokir dari fitur komunitas.'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('other errors keep the retry button', (tester) async {
    await _pumpError(tester, const CommunityException(CommunityErrorKind.network), onRetry: () {});
    expect(find.widgetWithText(OutlinedButton, 'Hubungi CS'), findsNothing);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  test('client config reads the rejoin cooldown', () {
    ClientConfig parse(Object? hours) => ClientConfigModel.fromJson({
      'config': {'account_rejoin_cooldown_hours': hours},
    }).toEntity(receivedAt: _now);
    expect(parse(72).rejoinCooldown, const Duration(hours: 72));
    expect(parse(1.5).rejoinCooldown, const Duration(minutes: 90));
    expect(parse(0).rejoinCooldown, Duration.zero);
    expect(parse(null).rejoinCooldown, isNull);
  });

  testWidgets('the delete dialog tells how long the user must wait to rejoin', (tester) async {
    final account = FakeAccount(FakeLegalRepository(const []));
    final features = FakeFeatureDependencies(config: const ClientConfig(rejoinCooldown: Duration(hours: 72)));
    List<CommunityDeleteConsequence>? seen;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: communityLocalizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityScope(
            dependencies: FakeDependencies(),
            child: CommunityAccountScope(
              dependencies: account,
              child: CommunityFeatureScope(
                dependencies: features,
                child: CommunityBuildersScope(
                  builders: CommunityBuilders(
                    settings: CommunitySettingsBuilders(
                      deleteAccountDialog: (context, d, fallback) {
                        seen = d.consequences;
                        return const AlertDialog(content: Text('delete'));
                      },
                    ),
                  ),
                  child: const CommunityAccountSettings(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Hapus akun komunitas'), 200);
    await tester.ensureVisible(find.text('Hapus akun komunitas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus akun komunitas'));
    await tester.pumpAndSettle();
    expect(find.text('delete'), findsOneWidget);
    expect(
      seen?.map((c) => c.text),
      contains('Setelah dihapus, Anda baru bisa membuka komunitas lagi setelah 3 hari.'),
    );
  });
}
