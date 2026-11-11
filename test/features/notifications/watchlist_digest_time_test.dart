import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/notifications/data/repositories/notification_preferences_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

Map<String, Object?> _prefs({Object? digest}) => {
  'types': [
    {'type': 'watchlist_digest', 'in_app': true, 'push': true},
  ],
  'quiet_hours': {'enabled': false},
  'aggregate_minutes': 60,
  'watchlist_digest': ?digest,
};

Future<FakeFeatureDependencies> _pump(
  WidgetTester tester, {
  String? time,
  Locale locale = const Locale('id'),
  CommunitySettingsBuilders settings = const CommunitySettingsBuilders(),
}) async {
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  features.notificationPreferences.preferences = NotificationPreferences(
    types: const [NotificationTypePreference(type: 'watchlist_digest', inApp: true)],
    watchlistDigestTime: time,
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(),
          child: CommunityFeatureScope(
            dependencies: features,
            child: CommunityBuildersScope(
              builders: CommunityBuilders(settings: settings),
              child: const SingleChildScrollView(child: CommunityNotificationSettings()),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return features;
}

void main() {
  group('parsing the digest time', () {
    Future<NotificationPreferences> parse(Object? digest) async {
      final api = mockApi();
      when(() => api.rpcValue('get_notification_prefs')).thenAnswer((_) async => _prefs(digest: digest));
      return NotificationPreferencesRepositoryImpl(api).get();
    }

    test('reads the time the server schedules the digest at', () async {
      final prefs = await parse({'time': '06:30', 'timezone': 'Asia/Jakarta'});
      expect(prefs.watchlistDigestTime, '06:30');
    });

    test('is null when the server does not send it', () async {
      expect((await parse(null)).watchlistDigestTime, isNull);
    });

    test('ignores a malformed time', () async {
      for (final time in ['6:30', '24:00', '06:30:00', 630]) {
        expect((await parse({'time': time})).watchlistDigestTime, isNull, reason: '$time');
      }
    });
  });

  group('settings description', () {
    testWidgets('shows the time from the server in Indonesian', (tester) async {
      await _pump(tester, time: '06:30');
      expect(find.text('Setiap hari pukul 06.30 WIB'), findsOneWidget);
      expect(find.textContaining('17.05'), findsNothing);
    });

    testWidgets('shows the time from the server in English', (tester) async {
      await _pump(tester, time: '20:15', locale: const Locale('en'));
      expect(find.text('Daily at 20:15 WIB'), findsOneWidget);
    });

    testWidgets('keeps the old 17.05 text for servers that do not send a time', (tester) async {
      await _pump(tester);
      expect(find.text('Setiap hari pukul 17.05 WIB'), findsOneWidget);
    });

    testWidgets('hands the server time to the notificationType builder', (tester) async {
      String? seen;
      await _pump(
        tester,
        time: '08:00',
        settings: CommunitySettingsBuilders(
          notificationType: (context, d, fallback) {
            if (d.type == 'watchlist_digest') seen = d.description;
            return fallback;
          },
        ),
      );
      expect(seen, 'Setiap hari pukul 08.00 WIB');
    });
  });
}
