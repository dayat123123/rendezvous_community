import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_repository_impl.dart';

import '../../support/mock_api.dart';
import '../../support/support_kit.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

void main() {
  group('intake validation matches the server', () {
    const text = SupportIntakeField(key: 'note', type: SupportIntakeType.text, label: 'Catatan');
    const number = SupportIntakeField(key: 'amount', type: SupportIntakeType.number, label: 'Nominal');
    const date = SupportIntakeField(key: 'day', type: SupportIntakeType.date, label: 'Tanggal');
    const choice = SupportIntakeField(
      key: 'channel',
      type: SupportIntakeType.choice,
      label: 'Kanal',
      options: [SupportIntakeOption(value: 'app', label: 'Aplikasi')],
    );

    test('required answers must not be blank, optional ones may be', () {
      expect(checkSupportIntakeAnswer(text.copyWith(isRequired: true), '  '), SupportIntakeProblem.required);
      expect(checkSupportIntakeAnswer(text, ''), isNull);
      expect(checkSupportIntakeAnswer(text, 'a' * 200), isNull);
      expect(checkSupportIntakeAnswer(text, 'a' * 201), SupportIntakeProblem.tooLong);
    });

    test('numbers accept up to 15 digits and 4 decimals with a dot or comma', () {
      for (final ok in ['1500', '-3', '12,5', '0.1234', '123456789012345']) {
        expect(checkSupportIntakeAnswer(number, ok), isNull, reason: ok);
      }
      for (final bad in ['1.000.000', '12,34567', 'abc', '1e5', '1234567890123456', '+5']) {
        expect(checkSupportIntakeAnswer(number, bad), SupportIntakeProblem.number, reason: bad);
      }
    });

    test('dates must be real ISO calendar dates', () {
      expect(checkSupportIntakeAnswer(date, '2026-11-09'), isNull);
      expect(checkSupportIntakeAnswer(date, '2024-02-29'), isNull);
      expect(checkSupportIntakeAnswer(date, '2026-02-30'), SupportIntakeProblem.date);
      expect(checkSupportIntakeAnswer(date, '09-11-2026'), SupportIntakeProblem.date);
      expect(supportIntakeDateValue(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('choices must be one of the option values', () {
      expect(checkSupportIntakeAnswer(choice, 'app'), isNull);
      expect(checkSupportIntakeAnswer(choice, 'Aplikasi'), SupportIntakeProblem.choice);
    });

    test('the payload keeps only trimmed answers for known fields', () {
      final payload = supportIntakePayload(intakeFields, {
        'order_no': ' ORD-1 ',
        'amount': '',
        'channel': 'app',
        'unknown': 'x',
      });
      expect(payload, {'order_no': 'ORD-1', 'channel': 'app'});
      expect(validateSupportIntake(intakeFields, const {}).keys, ['order_no', 'channel']);
    });
  });

  group('repository', () {
    late MockApi cs;
    late SupportRepositoryImpl repo;

    setUp(() {
      cs = mockApi();
      repo = SupportRepositoryImpl(cs: cs, notifications: _MockNotifications());
    });

    test('topics parse intake fields and fall back to none on older servers', () async {
      when(() => cs.rpcValue('topics', any())).thenAnswer(
        (_) async => [
          {
            'code': 'orders',
            'name': 'Order',
            'intake': [
              {'key': 'order_no', 'type': 'text', 'label': 'Nomor order', 'required': true, 'options': []},
              {
                'key': 'channel',
                'type': 'choice',
                'label': 'Kanal',
                'required': false,
                'options': [
                  {'value': 'app', 'label': 'Aplikasi'},
                  {'value': 'web', 'label': 'Web'},
                ],
              },
              {'key': 'weird', 'type': 'signature', 'label': 'Tanda tangan'},
            ],
          },
          {'code': 'funds', 'name': 'Dana'},
        ],
      );

      final topics = await repo.topics();

      expect(topics.first.intake.map((f) => f.key), ['order_no', 'channel']);
      expect(topics.first.intake.first.isRequired, isTrue);
      expect(topics.first.intake.last.optionLabel('web'), 'Web');
      expect(topics.last.hasIntake, isFalse);
    });

    test('open_ticket sends p_intake only when there are answers', () async {
      final calls = <Map<String, dynamic>>[];
      when(() => cs.rpcValue('open_ticket', any())).thenAnswer((invocation) async {
        calls.add(Map.of(invocation.positionalArguments[1] as Map<String, dynamic>));
        return {
          'id': 't-1',
          'ticket_number': 'CS-1',
          'room_id': 'r-cs',
          'topic': 'orders',
          'status': 'open',
          'created_at': '2026-11-09T02:00:00Z',
        };
      });

      await repo.openTicket(topic: 'funds');
      await repo.openTicket(topic: 'orders', intake: {'order_no': 'ORD-1'});

      expect(calls.first.containsKey('p_intake'), isFalse);
      expect(calls.last['p_intake'], {'order_no': 'ORD-1'});
    });
  });

  group('intake form', () {
    late MockSupport support;

    setUp(() {
      support = MockSupport();
      stubSupport(support);
      stubOpenTicket(support, supportTicket(status: SupportStatus.open));
    });

    testWidgets('a topic with intake questions shows the form and sends the answers', (tester) async {
      await pumpSupportChat(tester, support);

      await tester.tap(find.text('Order & Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Sebelum mulai chat'), findsOneWidget);
      expect(find.text('Nominal (opsional)'), findsOneWidget);

      await tester.tap(find.text('Mulai chat'));
      await tester.pumpAndSettle();
      expect(find.text('Wajib diisi.'), findsNWidgets(2));
      verifyNever(
        () => support.openTicket(
          topic: any(named: 'topic'),
          language: any(named: 'language'),
          screen: any(named: 'screen'),
          complaint: any(named: 'complaint'),
          intake: any(named: 'intake'),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Nomor order'), ' ORD-77 ');
      await tester.enterText(find.widgetWithText(TextField, 'Nominal (opsional)'), '12.5.0');
      await tester.tap(find.text('Web'));
      await tester.pumpAndSettle();
      expect(find.text('Isi dengan angka, misalnya 1500 atau 12,5.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Nominal (opsional)'), '1500');
      await tester.tap(find.text('Pilih tanggal'));
      await tester.pumpAndSettle();
      final ok = MaterialLocalizations.of(tester.element(find.byType(DatePickerDialog))).okButtonLabel;
      await tester.tap(find.text(ok));
      await tester.pumpAndSettle();

      when(() => support.home()).thenAnswer(
        (_) async => SupportHome(
          roomId: 'r-cs',
          supportName: 'CS OLT',
          ticket: supportTicket(status: SupportStatus.open),
          active: true,
        ),
      );
      await tester.tap(find.text('Mulai chat'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => support.openTicket(
                  topic: 'orders',
                  language: 'id',
                  screen: any(named: 'screen'),
                  complaint: any(named: 'complaint'),
                  intake: captureAny(named: 'intake'),
                ),
              ).captured.single
              as Map<String, String>;
      expect(captured['order_no'], 'ORD-77');
      expect(captured['amount'], '1500');
      expect(captured['channel'], 'web');
      expect(isSupportIntakeDate(captured['trade_date']!), isTrue);
      expect(find.text('Sebelum mulai chat'), findsNothing);
    });

    testWidgets('a topic without intake opens the ticket right away, with no intake sent', (tester) async {
      await pumpSupportChat(tester, support);

      await tester.tap(find.text('Deposit/Tarik Dana'));
      await tester.pumpAndSettle();

      expect(find.text('Sebelum mulai chat'), findsNothing);
      verify(
        () => support.openTicket(
          topic: 'funds',
          language: 'id',
          screen: any(named: 'screen'),
          complaint: any(named: 'complaint'),
        ),
      ).called(1);
    });

    testWidgets('a server intake error is shown and the form stays open', (tester) async {
      when(
        () => support.openTicket(
          topic: any(named: 'topic'),
          language: any(named: 'language'),
          screen: any(named: 'screen'),
          complaint: any(named: 'complaint'),
          intake: any(named: 'intake'),
        ),
      ).thenThrow(const CommunityException(CommunityErrorKind.invalidInput, code: 'invalid_intake_answers'));
      await pumpSupportChat(tester, support);

      await tester.tap(find.text('Order & Transaksi'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Nomor order'), 'ORD-1');
      await tester.tap(find.text('Aplikasi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mulai chat'));
      await tester.pumpAndSettle();

      expect(find.text('Ada jawaban yang belum sesuai. Periksa lagi isian Anda.'), findsOneWidget);
      expect(find.text('Sebelum mulai chat'), findsOneWidget);
    });

    testWidgets('going back from the form returns to the topic list', (tester) async {
      await pumpSupportChat(tester, support);

      await tester.tap(find.text('Order & Transaksi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih topik lain'));
      await tester.pumpAndSettle();

      expect(find.text('Sebelum mulai chat'), findsNothing);
      expect(find.text('Deposit/Tarik Dana'), findsOneWidget);
    });
  });
}
