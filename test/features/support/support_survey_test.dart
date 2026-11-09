import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_repository_impl.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';

import '../../support/mock_api.dart';
import '../../support/support_kit.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

const _faces = SupportSurvey(
  question: 'Bagaimana layanan CS kami?',
  scale: 3,
  lowMax: 2,
  reasons: [
    SupportSurveyReason(code: 'slow', label: 'Terlalu lama'),
    SupportSurveyReason(code: 'unclear', label: 'Penjelasan kurang jelas'),
  ],
);

const _stars = SupportSurvey(
  question: 'Seberapa puas Anda?',
  lowMax: 3,
  reasons: [SupportSurveyReason(code: 'slow', label: 'Terlalu lama')],
);

class _Opener extends StatelessWidget {
  const _Opener({required this.onResult, this.survey});

  final SupportSurvey? survey;
  final ValueChanged<SupportRating?> onResult;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async => onResult(await askSupportRating(context, survey: survey)),
    child: const Text('open'),
  );
}

Future<List<SupportRating?>> _pumpDialog(WidgetTester tester, {SupportSurvey? survey}) async {
  final results = <SupportRating?>[];
  await tester.pumpWidget(supportApp(_Opener(survey: survey, onResult: results.add)));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  test('survey values follow the scale and low ratings ask for reasons', () {
    expect(_faces.values, [1, 3, 5]);
    expect(_stars.values, [1, 2, 3, 4, 5]);
    expect(_faces.asksReasons(1), isTrue);
    expect(_faces.asksReasons(3), isFalse);
    expect(_stars.asksReasons(3), isTrue);
    expect(_stars.copyWith(reasons: const []).asksReasons(1), isFalse);
  });

  test('rate_ticket sends p_reasons only when reasons were picked', () async {
    final cs = mockApi();
    final repo = SupportRepositoryImpl(cs: cs, notifications: _MockNotifications());
    final calls = <Map<String, dynamic>>[];
    when(() => cs.rpcValue('rate_ticket', any())).thenAnswer((invocation) async {
      calls.add(Map.of(invocation.positionalArguments[1] as Map<String, dynamic>));
      return {
        'id': 't-1',
        'ticket_number': 'CS-1',
        'room_id': 'r-cs',
        'topic': 'orders',
        'status': 'closed',
        'created_at': '2026-11-09T02:00:00Z',
      };
    });

    await repo.rateTicket('t-1', 5, comment: 'Mantap');
    await repo.rateTicket('t-1', 1, reasons: ['slow', 'slow', 'unclear']);

    expect(calls.first.containsKey('p_reasons'), isFalse);
    expect(calls.last['p_reasons'], ['slow', 'unclear']);
  });

  testWidgets('a three-point survey shows faces that send 1, 3, 5 and reason chips for low ratings', (tester) async {
    final results = await _pumpDialog(tester, survey: _faces);

    expect(find.text('Bagaimana layanan CS kami?'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    expect(find.text('Kurang puas'), findsOneWidget);
    expect(find.text('Apa yang kurang?'), findsNothing);

    await tester.tap(find.byTooltip('Kurang puas'));
    await tester.pumpAndSettle();
    expect(find.text('Apa yang kurang?'), findsOneWidget);
    await tester.tap(find.text('Penjelasan kurang jelas'));
    await tester.tap(find.text('Terlalu lama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();

    expect(results.single?.rating, 1);
    expect(results.single?.reasons, ['slow', 'unclear']);
  });

  testWidgets('raising the rating above the low limit drops the picked reasons', (tester) async {
    final results = await _pumpDialog(tester, survey: _faces);

    await tester.tap(find.byTooltip('Kurang puas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terlalu lama'));
    await tester.tap(find.byTooltip('Puas'));
    await tester.pumpAndSettle();
    expect(find.text('Apa yang kurang?'), findsNothing);
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();

    expect(results.single?.rating, 5);
    expect(results.single?.reasons, isEmpty);
  });

  testWidgets('a five-point survey uses stars with the server question', (tester) async {
    final results = await _pumpDialog(tester, survey: _stars);

    expect(find.text('Seberapa puas Anda?'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    await tester.tap(find.byTooltip('3'));
    await tester.pumpAndSettle();
    expect(find.text('Terlalu lama'), findsOneWidget);
    await tester.tap(find.byTooltip('4'));
    await tester.pumpAndSettle();
    expect(find.text('Terlalu lama'), findsNothing);
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();

    expect(results.single?.rating, 4);
  });

  testWidgets('without a survey the dialog is the familiar five-star one', (tester) async {
    final results = await _pumpDialog(tester);

    expect(find.text('Nilai layanan CS'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    await tester.tap(find.byTooltip('1'));
    await tester.pumpAndSettle();
    expect(find.text('Apa yang kurang?'), findsNothing);
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();

    expect(results.single?.rating, 1);
    expect(results.single?.reasons, isEmpty);
  });

  testWidgets('the support chat rates with the survey of the app language and sends the reasons', (tester) async {
    final support = MockSupport();
    final resolved = supportTicket(status: SupportStatus.resolved, canRate: true);
    stubSupport(
      support,
      home: SupportHome(
        roomId: 'r-cs',
        supportName: 'CS OLT',
        ticket: resolved,
        surveys: const {'id': _faces, 'en': _stars},
      ),
    );
    when(
      () => support.rateTicket(
        any(),
        any(),
        comment: any(named: 'comment'),
        reasons: any(named: 'reasons'),
      ),
    ).thenAnswer((_) async => resolved);
    final chat = RecordingChatRepository(
      rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: DateTime.now(), lastReadAt: DateTime.now())],
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'r-cs',
          body: 'Tiket selesai.',
          createdAt: DateTime.now(),
          kind: MessageKind.csat,
          senderRole: SenderRole.system,
          ticketId: 't-1',
          payload: const {'code': 'ticket_resolved'},
        ),
      ],
    );
    await pumpSupportChat(tester, support, chat: chat);

    await tester.tap(find.text('Beri nilai layanan ini'));
    await tester.pumpAndSettle();
    expect(find.text('Bagaimana layanan CS kami?'), findsOneWidget);
    await tester.tap(find.byTooltip('Kurang puas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terlalu lama'));
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();

    verify(() => support.rateTicket('t-1', 1, comment: null, reasons: ['slow'])).called(1);
  });
}
