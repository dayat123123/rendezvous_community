import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';

import '../../../support/fakes.dart';
import '../../../support/feature_fakes.dart';
import '../../../support/legal_fakes.dart';

Widget _part<T>(BuildContext context, T details, Widget fallback) => const SizedBox.shrink();

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  CommunitySettingsBuilders settings = const CommunitySettingsBuilders(),
  FakeAccount? account,
  CommunityFeatureDependencies? features,
}) async {
  Widget body = CommunityBuildersScope(
    builders: CommunityBuilders(settings: settings),
    child: child,
  );
  if (features != null) body = CommunityFeatureScope(dependencies: features, child: body);
  if (account != null) body = CommunityAccountScope(dependencies: account, child: body);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(dependencies: FakeDependencies(), child: body),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CommunitySettingsBuilders.merge', () {
    const full = CommunitySettingsBuilders(
      dmPolicy: _part,
      notificationType: _part,
      reportDialog: _part,
      appealDialog: _part,
      appealTile: _part,
      loading: _part,
      empty: _part,
      error: _part,
      consent: _part,
      legalDocumentTile: _part,
      legalReader: _part,
      accountTile: _part,
      deleteAccountDialog: _part,
    );

    test('keeps the base when the other set is null or empty', () {
      expect(identical(full.merge(null), full), isTrue);
      final merged = full.merge(const CommunitySettingsBuilders());
      expect(merged.dmPolicy, isNotNull);
      expect(merged.deleteAccountDialog, isNotNull);
    });

    test('takes every slot from the other set', () {
      final merged = const CommunitySettingsBuilders().merge(full);
      expect(
        [
          merged.dmPolicy,
          merged.notificationType,
          merged.reportDialog,
          merged.appealDialog,
          merged.appealTile,
          merged.loading,
          merged.empty,
          merged.error,
          merged.consent,
          merged.legalDocumentTile,
          merged.legalReader,
          merged.accountTile,
          merged.deleteAccountDialog,
        ].every((b) => b != null),
        isTrue,
      );
    });
  });

  testWidgets('dmPolicy receives the policy and options and can change it', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    CommunityDmPolicyDetails? seen;
    await _pump(
      tester,
      const CommunityDmPolicySettings(),
      features: features,
      settings: CommunitySettingsBuilders(
        dmPolicy: (context, d, fallback) {
          seen = d;
          return Text('policy:${d.policy.name}:${d.options.map((o) => o.value.name).join(',')}');
        },
      ),
    );
    expect(find.text('policy:everyone:everyone,following,none'), findsOneWidget);
    expect(seen!.title, 'Siapa yang bisa mengirim pesan langsung');
    expect(seen!.onChanged, isNotNull);
    expect(find.byType(RadioListTile<DmPolicy>), findsNothing);
  });

  testWidgets('dmPolicy fallback keeps the three radio rows', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    await _pump(tester, const CommunityDmPolicySettings(), features: features);
    expect(find.byType(RadioListTile<DmPolicy>), findsNWidgets(3));
  });

  testWidgets('notificationType replaces every type row', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    await _pump(
      tester,
      const SingleChildScrollView(child: CommunityNotificationSettings()),
      features: features,
      settings: CommunitySettingsBuilders(
        notificationType: (context, d, fallback) =>
            Text('type:${d.type}:${d.supportsInApp}:${d.onInAppChanged != null}:${d.isOlt}'),
      ),
    );
    expect(find.text('type:like:true:true:false'), findsOneWidget);
    expect(find.text('type:olt.trade:false:false:true'), findsOneWidget);
    expect(find.text('Jam tenang'), findsOneWidget);
  });

  testWidgets('reportDialog is carried into the dialog route', (tester) async {
    late BuildContext host;
    await _pump(
      tester,
      Builder(
        builder: (context) {
          host = context;
          return const SizedBox();
        },
      ),
      settings: CommunitySettingsBuilders(
        reportDialog: (context, d, fallback) => AlertDialog(
          content: Text('report:${d.target.name}:${d.selected.name}:${d.options.length}'),
          actions: [TextButton(onPressed: d.onCancel, child: Text(d.cancelLabel))],
        ),
      ),
    );
    final sent = showReportDialog(host, target: ReportTarget.post, targetId: 'p-1');
    await tester.pumpAndSettle();
    expect(find.text('report:post:spam:6'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(await sent, isFalse);
  });

  testWidgets('appealDialog receives the form state', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    late BuildContext host;
    await _pump(
      tester,
      Builder(
        builder: (context) {
          host = context;
          return const SizedBox();
        },
      ),
      features: features,
      settings: CommunitySettingsBuilders(
        appealDialog: (context, d, fallback) => AlertDialog(
          content: Text('appeal:${d.targetType.name}:${d.canSubmit}:${d.maxLength}'),
          actions: [TextButton(onPressed: d.onCancel, child: Text(d.cancelLabel))],
        ),
      ),
    );
    final created = showCommunityAppealDialog(host, targetType: AppealTargetType.post, targetId: 'p-1');
    await tester.pumpAndSettle();
    expect(find.text('appeal:post:false:1000'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(await created, isFalse);
  });

  testWidgets('appealTile and empty cover the appeals page', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    features.appeals.sanctions = [Sanction(id: 's-1', kind: 'mute', endsAt: DateTime.utc(2026, 12, 1))];
    await _pump(
      tester,
      const CommunityAppeals(),
      features: features,
      settings: CommunitySettingsBuilders(
        appealTile: (context, d, fallback) => Text('tile:${d.kind.name}:${d.title}:${d.onAppeal != null}'),
        empty: (context, d, fallback) => Text('empty:${d.area.name}'),
      ),
    );
    expect(find.text('tile:sanction:Dibatasi mengirim konten:true'), findsOneWidget);
    expect(find.text('empty:moderatedContent'), findsOneWidget);
    expect(find.text('empty:myAppeals'), findsOneWidget);
  });

  testWidgets('appeals fallback shows the sanction row with its appeal action', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    features.appeals.sanctions = [Sanction(id: 's-1', kind: 'mute', endsAt: DateTime.utc(2026, 12, 1))];
    await _pump(tester, const CommunityAppeals(), features: features);
    expect(find.text('Dibatasi mengirim konten'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Ajukan banding'), findsOneWidget);
  });

  testWidgets('consent and legalDocumentTile replace the consent body and its rows', (tester) async {
    final account = FakeAccount(FakeLegalRepository([updatedTerms, updatedGuidelines]));
    await _pump(
      tester,
      CommunityConsentView(onDone: (_) {}),
      account: account,
      settings: CommunitySettingsBuilders(
        consent: (context, d, fallback) => Column(
          children: [
            Text('consent:${d.documents.length}:${d.canAccept}:${d.title}'),
            Expanded(child: fallback),
          ],
        ),
        legalDocumentTile: (context, d, fallback) => Text('doc:${d.title}:${d.placement.name}:${d.actionLabel}'),
      ),
    );
    expect(find.text('consent:2:false:Persetujuan diperlukan'), findsOneWidget);
    expect(find.text('doc:Syarat & Ketentuan:consent:Baca'), findsOneWidget);
    expect(find.text('doc:Pedoman Komunitas:consent:Baca'), findsOneWidget);
  });

  testWidgets('legalReader replaces the document reader', (tester) async {
    await _pump(
      tester,
      CommunityLegalDocumentReader(document: updatedTerms),
      settings: CommunitySettingsBuilders(
        legalReader: (context, d, fallback) => Text('reader:${d.title}:${d.meta}:${d.changes != null}'),
      ),
    );
    expect(find.text('reader:Syarat & Ketentuan:Versi 3 · berlaku 1 November 2026:true'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
  });

  testWidgets('accountTile, legal tiles and error slots cover the account page', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    final legal = FakeLegalRepository([privacyPolicy]);
    final account = FakeAccount(legal);
    await _pump(
      tester,
      const CommunityAccountSettings(),
      account: account,
      features: features,
      settings: CommunitySettingsBuilders(
        accountTile: (context, d, fallback) => Text('tile:${d.kind.name}:${d.destructive}:${d.enabled}'),
        legalDocumentTile: (context, d, fallback) => Text('doc:${d.title}:${d.placement.name}'),
        notificationType: (context, d, fallback) => const SizedBox.shrink(),
      ),
    );
    await tester.scrollUntilVisible(find.text('tile:deleteAccount:true:true'), 200);
    expect(find.text('tile:exportData:false:true'), findsOneWidget);
    expect(find.text('tile:deleteAccount:true:true'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('tile:appeals:false:true'), -200);
    await tester.scrollUntilVisible(find.text('doc:Kebijakan Privasi:accountSettings'), -200);
  });

  testWidgets('error receives the area and retries', (tester) async {
    final legal = FakeLegalRepository([privacyPolicy])..loadError = Exception('x');
    await _pump(
      tester,
      const CommunityAccountSettings(),
      account: FakeAccount(legal),
      settings: CommunitySettingsBuilders(
        error: (context, d, fallback) => TextButton(onPressed: d.onRetry, child: Text('error:${d.area.name}')),
      ),
    );
    expect(find.text('error:legalDocuments'), findsOneWidget);
    legal.loadError = null;
    await tester.tap(find.text('error:legalDocuments'));
    await tester.pumpAndSettle();
    expect(find.text('Kebijakan Privasi'), findsOneWidget);
  });

  testWidgets('deleteAccountDialog follows the typed confirmation', (tester) async {
    final account = FakeAccount(FakeLegalRepository(const []));
    await _pump(
      tester,
      const CommunityAccountSettings(),
      account: account,
      settings: CommunitySettingsBuilders(
        deleteAccountDialog: (context, d, fallback) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('delete:${d.confirmWord}:${d.canConfirm}:${d.consequences.length}'),
              TextField(controller: d.controller),
            ],
          ),
          actions: [TextButton(onPressed: d.onCancel, child: Text(d.cancelLabel))],
        ),
      ),
    );
    await tester.tap(find.text('Hapus akun komunitas'));
    await tester.pumpAndSettle();
    expect(find.text('delete:HAPUS:false:6'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'HAPUS');
    await tester.pump();
    expect(find.text('delete:HAPUS:true:6'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(account.deletes, 0);
  });
}
