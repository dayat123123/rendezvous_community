import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/help_fakes.dart';
import '../../support/support_kit.dart';

void main() {
  late MockSupport support;
  final nextOpen = DateTime(2026, 11, 10, 8);

  setUp(() {
    support = MockSupport();
    stubSupport(
      support,
      home: SupportHome(supportName: 'CS OLT', serviceOpen: false, nextOpenAt: nextOpen),
    );
    stubOpenTicket(support, supportTicket(status: SupportStatus.open));
  });

  void verifyOpened(String topic, {int times = 1}) => verify(
    () => support.openTicket(
      topic: topic,
      language: any(named: 'language'),
      screen: any(named: 'screen'),
      complaint: any(named: 'complaint'),
      intake: any(named: 'intake'),
    ),
  ).called(times);

  testWidgets('outside service hours a topic shows the hours, its articles, and a leave-a-message button', (
    tester,
  ) async {
    final help = FakeHelpRepository(suggestions: const [depositArticle]);
    await pumpSupportChat(tester, support, help: help);

    await tester.tap(find.text('Deposit/Tarik Dana'));
    await tester.pumpAndSettle();

    expect(find.text('CS sedang di luar jam layanan'), findsOneWidget);
    expect(find.textContaining('Pesan Anda dibalas mulai'), findsWidgets);
    expect(find.text('Berapa lama dana deposit masuk?'), findsOneWidget);
    expect(help.topicLookups, ['funds']);
    verifyNever(
      () => support.openTicket(
        topic: any(named: 'topic'),
        language: any(named: 'language'),
        screen: any(named: 'screen'),
        complaint: any(named: 'complaint'),
        intake: any(named: 'intake'),
      ),
    );

    await tester.tap(find.text('Tinggalkan pesan'));
    await tester.pumpAndSettle();
    verifyOpened('funds');
  });

  testWidgets('outside service hours without help articles the step still offers to leave a message', (tester) async {
    await pumpSupportChat(tester, support);

    await tester.tap(find.text('Deposit/Tarik Dana'));
    await tester.pumpAndSettle();

    expect(find.text('Tinggalkan pesan sekarang. Tiket Anda tercatat dan dibalas saat layanan buka.'), findsOneWidget);
    await tester.tap(find.text('Tinggalkan pesan'));
    await tester.pumpAndSettle();
    verifyOpened('funds');
  });

  testWidgets('outside service hours an intake topic continues to the form, which also leaves a message', (
    tester,
  ) async {
    await pumpSupportChat(tester, support);

    await tester.tap(find.text('Order & Transaksi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tinggalkan pesan'));
    await tester.pumpAndSettle();

    expect(find.text('Sebelum mulai chat'), findsOneWidget);
    expect(find.text('Tinggalkan pesan'), findsOneWidget);
    expect(find.textContaining('Pesan Anda dibalas mulai'), findsWidgets);
  });

  testWidgets('during service hours the picker behaves as before', (tester) async {
    stubSupport(support);
    await pumpSupportChat(tester, support);

    await tester.tap(find.text('Deposit/Tarik Dana'));
    await tester.pumpAndSettle();

    expect(find.text('Tinggalkan pesan'), findsNothing);
    verifyOpened('funds');
  });
}
