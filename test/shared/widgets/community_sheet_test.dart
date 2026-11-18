import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_sheet.dart';

import '../../support/fakes.dart';

void main() {
  testWidgets('a sheet opened inside a nested navigator covers the whole app', (tester) async {
    final deps = FakeDependencies();
    CommunityDependencies? seen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(key: ValueKey('host-header'), height: 60),
              Expanded(
                child: CommunityScope(
                  dependencies: deps,
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (context) => Center(
                        child: TextButton(
                          onPressed: () => showCommunitySheet<void>(
                            context,
                            builder: (sheetContext) {
                              seen = CommunityScope.maybeOf(sheetContext);
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
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sheet-body')), findsOneWidget);
    final barrier = tester.getRect(find.byType(ModalBarrier).last);
    expect(barrier.top, 0);
    expect(tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle, isTrue);
    expect(seen, same(deps));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sheet-body')), findsNothing);
  });
}
