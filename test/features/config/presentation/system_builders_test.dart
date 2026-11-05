import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/legal_fakes.dart';

Widget _part<T>(BuildContext context, T details, Widget fallback) => const SizedBox.shrink();

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  CommunitySystemBuilders system = const CommunitySystemBuilders(),
  FakeAccount? account,
}) async {
  Widget body = CommunityBuildersScope(
    builders: CommunityBuilders(system: system),
    child: child,
  );
  if (account != null) body = CommunityAccountScope(dependencies: account, child: body);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(body: body),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CommunitySystemBuilders.merge', () {
    const full = CommunitySystemBuilders(banner: _part, unavailable: _part, offlineBanner: _part, consentBanner: _part);

    test('keeps the base for null or empty sets and takes every slot from the other', () {
      expect(identical(full.merge(null), full), isTrue);
      expect(full.merge(const CommunitySystemBuilders()).banner, isNotNull);
      final merged = const CommunitySystemBuilders().merge(full);
      expect(
        [merged.banner, merged.unavailable, merged.offlineBanner, merged.consentBanner].every((b) => b != null),
        isTrue,
      );
    });
  });

  const banner = CommunityBanner(
    id: 'b-1',
    title: 'Pemeliharaan',
    body: 'Chat dibatasi pukul 22.00.',
    level: CommunityBannerLevel.warning,
  );

  testWidgets('banner receives the banner and its handlers', (tester) async {
    var dismissed = 0;
    await _pump(
      tester,
      CommunityBannerCard(banner: banner, onDismiss: () => dismissed++),
      system: CommunitySystemBuilders(
        banner: (context, d, fallback) => TextButton(
          onPressed: d.onDismiss,
          child: Text('banner:${d.title}:${d.level.name}:${d.onOpen == null}:${d.dismissLabel}'),
        ),
      ),
    );
    await tester.tap(find.text('banner:Pemeliharaan:warning:true:Tutup'));
    expect(dismissed, 1);
  });

  testWidgets('banner fallback shows title, body and the dismiss button', (tester) async {
    await _pump(tester, CommunityBannerCard(banner: banner, onOpen: () {}, onDismiss: () {}));
    expect(find.text('Pemeliharaan'), findsOneWidget);
    expect(find.text('Chat dibatasi pukul 22.00.'), findsOneWidget);
    expect(find.text('Selengkapnya'), findsOneWidget);
    expect(find.byTooltip('Tutup'), findsOneWidget);
  });

  testWidgets('unavailable receives the reason and texts', (tester) async {
    await _pump(
      tester,
      const Column(
        children: [
          Expanded(child: CommunityUnavailableView()),
          Expanded(child: CommunityUnavailableView(reason: CommunityUnavailableReason.featureDisabled)),
        ],
      ),
      system: CommunitySystemBuilders(
        unavailable: (context, d, fallback) => Text('off:${d.reason.name}:${d.title}:${d.message}'),
      ),
    );
    expect(
      find.text('off:socialDisabled:Komunitas sedang tidak tersedia:${_l10n(tester).socialUnavailableBody}'),
      findsOneWidget,
    );
    expect(find.text('off:featureDisabled:null:Fitur ini sedang tidak tersedia.'), findsOneWidget);
  });

  testWidgets('unavailable fallback shows the kill switch title', (tester) async {
    await _pump(tester, const CommunityUnavailableView());
    expect(find.text('Komunitas sedang tidak tersedia'), findsOneWidget);
  });

  testWidgets('offlineBanner replaces the offline notice; the widget builder still wins', (tester) async {
    final connectivity = CommunityConnectivity()..report(reachable: false);
    addTearDown(connectivity.dispose);
    await _pump(
      tester,
      Column(
        children: [
          const CommunityOfflineNotice(message: 'Offline'),
          CommunityOfflineBanner(connectivity: connectivity),
          CommunityOfflineBanner(connectivity: connectivity, builder: (context, message) => Text('own:$message')),
        ],
      ),
      system: CommunitySystemBuilders(offlineBanner: (context, d, fallback) => Text('offline:${d.message}')),
    );
    expect(find.text('offline:Offline'), findsOneWidget);
    expect(find.text('offline:Anda sedang offline. Menampilkan data tersimpan.'), findsOneWidget);
    expect(find.text('own:Anda sedang offline. Menampilkan data tersimpan.'), findsOneWidget);
  });

  testWidgets('consentBanner receives pending documents and dismisses', (tester) async {
    final account = FakeAccount(FakeLegalRepository([updatedTerms]));
    await _pump(
      tester,
      const CommunityConsentBanner(),
      account: account,
      system: CommunitySystemBuilders(
        consentBanner: (context, d, fallback) => TextButton(
          onPressed: d.onDismiss,
          child: Text('consent:${d.documents.length}:${d.updated}:${d.reviewLabel}'),
        ),
      ),
    );
    await tester.tap(find.text('consent:1:true:${_l10n(tester).consentReview}'));
    await tester.pumpAndSettle();
    expect(find.textContaining('consent:'), findsNothing);
  });
}

CommunityLocalizations _l10n(WidgetTester tester) => tester.element(find.byType(Scaffold)).communityL10n;
