import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/legal_fakes.dart';

TextField _field(WidgetTester tester) =>
    tester.widget<TextField>(find.descendant(of: find.byType(CommunityComposePost), matching: find.byType(TextField)));

Future<void> _pumpComposer(
  WidgetTester tester, {
  String? hintText,
  CommunityFeedBuilders? builders,
  CommunityCallbacks callbacks = const CommunityCallbacks(),
}) => pumpCommunity(
  tester,
  Material(
    child: builders == null
        ? CommunityComposePost(hintText: hintText)
        : CommunityFeedBuildersScope(
            builders: builders,
            child: CommunityComposePost(hintText: hintText),
          ),
  ),
  dependencies: FakeDependencies(callbacks: callbacks),
);

void main() {
  testWidgets('the composer text and hint follow typography.body', (tester) async {
    await _pumpComposer(tester);
    final body = CommunityStyle.of(tester.element(find.byType(CommunityComposePost))).typography.body;

    final field = _field(tester);
    expect(field.style!.fontSize, body.fontSize);
    expect(field.decoration!.hintStyle!.fontSize, body.fontSize);
    expect(field.decoration!.hintText, startsWith('Tulis analisis Anda.'));
  });

  testWidgets('hintText replaces the default hint', (tester) async {
    await _pumpComposer(tester, hintText: r'Bagikan analisis $BBCA');

    expect(_field(tester).decoration!.hintText, r'Bagikan analisis $BBCA');
  });

  testWidgets('showCommunityComposer passes hintText to the composer', (tester) async {
    await pumpCommunity(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showCommunityComposer(context, hintText: 'Tulis ide trading'),
          child: const Text('tulis'),
        ),
      ),
    );
    await tester.tap(find.text('tulis'));
    await tester.pumpAndSettle();

    expect(_field(tester).decoration!.hintText, 'Tulis ide trading');
  });

  testWidgets(r'composeField can restyle the field and keeps $CODE suggestions', (tester) async {
    CommunityComposeFieldDetails? seen;
    await _pumpComposer(
      tester,
      callbacks: CommunityCallbacks(stockSearch: (query) async => const [StockSuggestion(code: 'BBCA')]),
      builders: CommunityFeedBuilders(
        composeField: (context, d, fallback) {
          seen = d;
          return DecoratedBox(
            key: const ValueKey('custom-field'),
            decoration: const BoxDecoration(),
            child: d.buildField(textStyle: const TextStyle(fontSize: 14), hintStyle: const TextStyle(fontSize: 13)),
          );
        },
      ),
    );

    expect(find.byKey(const ValueKey('custom-field')), findsOneWidget);
    expect(_field(tester).style!.fontSize, 14);
    expect(_field(tester).decoration!.hintStyle!.fontSize, 13);
    expect(seen!.maxLength, 2000);
    expect(seen!.minLines, 4);

    await tester.enterText(find.byType(TextField).first, r'Akumulasi $bb');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text(r'$BBCA'), findsOneWidget);
  });
}
