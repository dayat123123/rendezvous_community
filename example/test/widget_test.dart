import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community_example/fake_olt_auth.dart';
import 'package:rendezvous_community_example/main.dart';

void main() {
  testWidgets('shows configuration hints without an anon key', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.textContaining('OLT_SOCIAL_ANON_KEY'), findsOneWidget);
  });

  testWidgets('the login page offers guest support for customers who cannot sign in', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: CommunityGuestSupportScope(
          dependencies: CommunityGuestSupportClient.anonymous(supabaseUrl: 'http://localhost:1', anonKey: 'anon'),
          child: LoginPage(onSignedIn: (_) async {}),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Tidak bisa masuk? Hubungi CS'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Tidak bisa masuk? Hubungi CS'), findsOneWidget);
  });
}
