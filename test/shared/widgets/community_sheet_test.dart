import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_sheet.dart';

import '../../support/fakes.dart';

Future<void> _open(
  WidgetTester tester, {
  required Size window,
  required TargetPlatform platform,
  double panelWidth = 420,
  ValueChanged<CommunityDependencies?>? onScope,
}) async {
  tester.view.physicalSize = window;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final deps = FakeDependencies();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: Column(
          children: [
            const SizedBox(key: ValueKey('host-header'), height: 60),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: panelWidth,
                  child: CommunityScope(
                    dependencies: deps,
                    child: Navigator(
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (context) => Center(
                          child: TextButton(
                            onPressed: () => showCommunitySheet<void>(
                              context,
                              builder: (sheetContext) {
                                onScope?.call(CommunityScope.maybeOf(sheetContext));
                                return const SizedBox(key: ValueKey('sheet-body'), height: 120);
                              },
                            ),
                            child: const Text('open'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a phone-sized window opens a bottom sheet over the whole app', (tester) async {
    CommunityDependencies? seen;
    await _open(
      tester,
      window: const Size(390, 844),
      platform: TargetPlatform.android,
      panelWidth: 390,
      onScope: (deps) => seen = deps,
    );

    expect(find.byKey(const ValueKey('sheet-body')), findsOneWidget);
    expect(tester.getRect(find.byType(ModalBarrier).last).top, 0);
    expect(tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle, isTrue);
    expect(find.byType(Dialog), findsNothing);
    expect(seen, isNotNull);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet-body')), findsNothing);
  });

  testWidgets('a phone in landscape still gets a bottom sheet', (tester) async {
    await _open(tester, window: const Size(844, 390), platform: TargetPlatform.iOS, panelWidth: 844);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a wide desktop window opens a dialog even from a narrow side panel', (tester) async {
    CommunityDependencies? seen;
    await _open(
      tester,
      window: const Size(1500, 900),
      platform: TargetPlatform.windows,
      onScope: (deps) => seen = deps,
    );

    expect(find.byKey(const ValueKey('sheet-body')), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.getRect(find.byType(ModalBarrier).last).top, 0);
    final card = find.descendant(of: find.byType(Dialog), matching: find.byType(Material)).first;
    expect(tester.getSize(card).width, lessThanOrEqualTo(CommunitySheetLayout.dialogMaxWidth + 1));
    expect(seen, isNotNull);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet-body')), findsNothing);
  });

  testWidgets('a short desktop window still opens a dialog', (tester) async {
    await _open(tester, window: const Size(1500, 500), platform: TargetPlatform.windows);

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('a tablet-sized web window opens a dialog', (tester) async {
    await _open(tester, window: const Size(1024, 768), platform: TargetPlatform.android);

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('a desktop window shrunk to phone width uses the bottom sheet', (tester) async {
    await _open(tester, window: const Size(640, 900), platform: TargetPlatform.windows, panelWidth: 640);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });
}
