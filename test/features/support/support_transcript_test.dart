import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/data/models/support_models.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_repository_impl.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';
import '../../support/support_kit.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

const _labels = SupportTranscriptLabels(
  title: 'Transkrip chat CS',
  ticket: 'Tiket',
  topic: 'Topik',
  created: 'Dibuat',
  resolved: 'Selesai',
  closed: 'Ditutup',
  customer: 'Anda',
  agent: 'CS',
  system: 'Sistem',
  deleted: '(pesan dihapus)',
  attachments: 'Lampiran',
  empty: '(belum ada pesan)',
);

Map<String, dynamic> _transcriptJson() => {
  'ticket': {
    'id': 't-1',
    'ticket_number': 'CS-20261109-0001',
    'room_id': 'r-cs',
    'topic': 'orders',
    'topic_name': 'Order & Transaksi',
    'status': 'closed',
    'created_at': '2026-11-09T02:00:00Z',
    'resolved_at': '2026-11-09T02:30:00Z',
    'closed_at': '2026-11-09T03:00:00Z',
  },
  'messages': [
    {
      'created_at': '2026-11-09T02:00:00Z',
      'sender': 'system',
      'sender_name': null,
      'body': 'Tiket dibuat.',
      'deleted': false,
      'attachments': [],
    },
    {
      'created_at': '2026-11-09T02:01:00Z',
      'sender': 'customer',
      'sender_name': null,
      'body': 'Order saya belum masuk.\nMohon dicek.',
      'deleted': false,
      'attachments': ['bukti transfer.jpg', 'mutasi.pdf'],
    },
    {
      'created_at': '2026-11-09T02:05:00Z',
      'sender': 'agent',
      'sender_name': 'Nadia',
      'body': null,
      'deleted': true,
      'attachments': [],
    },
    {
      'created_at': '2026-11-09T02:06:00Z',
      'sender': 'agent',
      'sender_name': null,
      'body': 'Sudah kami proses.',
      'deleted': false,
      'attachments': [],
    },
  ],
};

void main() {
  test('the transcript parses senders, deleted messages and attachment names', () {
    final transcript = parseSupportTranscript(_transcriptJson());

    expect(transcript.ticket.ticketNumber, 'CS-20261109-0001');
    expect(transcript.messages.map((m) => m.sender), [
      SupportTranscriptSender.system,
      SupportTranscriptSender.customer,
      SupportTranscriptSender.agent,
      SupportTranscriptSender.agent,
    ]);
    expect(transcript.messages[1].attachments, ['bukti transfer.jpg', 'mutasi.pdf']);
    expect(transcript.messages[2].deleted, isTrue);
  });

  test('the TXT transcript lists the ticket, local times, sender labels, and attachments', () {
    final text = formatSupportTranscript(
      parseSupportTranscript(_transcriptJson()),
      _labels,
      toLocal: (value) => value.add(const Duration(hours: 7)),
    );

    expect(
      text,
      'Transkrip chat CS\n'
      'Tiket: CS-20261109-0001\n'
      'Topik: Order & Transaksi\n'
      'Dibuat: 2026-11-09 09:00\n'
      'Selesai: 2026-11-09 09:30\n'
      'Ditutup: 2026-11-09 10:00\n'
      '\n'
      '[2026-11-09 09:00] Sistem: Tiket dibuat.\n'
      '[2026-11-09 09:01] Anda: Order saya belum masuk.\n'
      '    Mohon dicek.\n'
      '    Lampiran: bukti transfer.jpg, mutasi.pdf\n'
      '[2026-11-09 09:05] Nadia (CS): (pesan dihapus)\n'
      '[2026-11-09 09:06] CS: Sudah kami proses.\n',
    );
    expect(supportTranscriptFileName(parseSupportTranscript(_transcriptJson())), 'transkrip-CS-20261109-0001.txt');
  });

  test('an empty transcript says so', () {
    final transcript = SupportTranscript(ticket: supportTicket(status: SupportStatus.closed));
    expect(formatSupportTranscript(transcript, _labels, toLocal: (v) => v), contains('(belum ada pesan)'));
  });

  test('the English file uses English labels and prefix', () {
    final l10n = lookupCommunityLocalizations(const Locale('en'));
    final file = supportTranscriptFile(parseSupportTranscript(_transcriptJson()), l10n);
    expect(file.name, 'transcript-CS-20261109-0001.txt');
    expect(file.text, startsWith('Customer support chat transcript\nTicket: CS-20261109-0001\n'));
    expect(file.text, contains('] You: Order saya belum masuk.'));
  });

  test('the repository calls ticket_transcript', () async {
    final cs = mockApi();
    when(() => cs.rpcValue('ticket_transcript', {'p_ticket_id': 't-1'})).thenAnswer((_) async => _transcriptJson());
    final repo = SupportRepositoryImpl(cs: cs, notifications: _MockNotifications());

    expect((await repo.transcript('t-1')).messages, hasLength(4));
  });

  group('my tickets', () {
    late MockSupport support;
    final saved = <SupportTranscriptFile>[];

    setUp(() {
      saved.clear();
      support = MockSupport();
      stubSupport(support);
      when(() => support.myTickets()).thenAnswer(
        (_) async => [
          supportTicket(status: SupportStatus.closed),
          supportTicket(status: SupportStatus.claimed).copyWith(id: 't-2', ticketNumber: 'CS-20261109-0002'),
        ],
      );
      when(() => support.ticketMessages(any())).thenAnswer((_) async => const []);
      when(() => support.transcript('t-1')).thenAnswer((_) async => parseSupportTranscript(_transcriptJson()));
    });

    Future<void> pumpTickets(WidgetTester tester, {bool saves = true}) async {
      final chat = FakeChatRepository();
      await tester.pumpWidget(
        supportApp(
          CommunityScope(
            dependencies: FakeDependencies(chat: chat),
            child: CommunitySupportScope(
              dependencies: SupportDeps(support, chat),
              child: CommunitySupportTickets(
                transcriptSaver: (context, file) async {
                  saved.add(file);
                  return saves;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a finished ticket offers "Unduh transkrip" and saves a TXT file', (tester) async {
      await pumpTickets(tester);

      await tester.tap(find.textContaining('CS-20261109-0001'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Unduh transkrip'));
      await tester.pumpAndSettle();

      expect(saved.single.name, 'transkrip-CS-20261109-0001.txt');
      expect(saved.single.text, contains('Tiket: CS-20261109-0001'));
      expect(saved.single.text, contains('Lampiran: bukti transfer.jpg, mutasi.pdf'));
      expect(find.text('Transkrip disimpan.'), findsOneWidget);
    });

    testWidgets('a cancelled save shows no confirmation', (tester) async {
      await pumpTickets(tester, saves: false);

      await tester.tap(find.textContaining('CS-20261109-0001'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Unduh transkrip'));
      await tester.pumpAndSettle();

      expect(saved, hasLength(1));
      expect(find.text('Transkrip disimpan.'), findsNothing);
    });

    testWidgets('an active ticket has no download action', (tester) async {
      await pumpTickets(tester);

      await tester.tap(find.textContaining('CS-20261109-0002'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Unduh transkrip'), findsNothing);
    });

    testWidgets('a server refusal is shown as a friendly error', (tester) async {
      when(
        () => support.transcript('t-1'),
      ).thenThrow(const CommunityException(CommunityErrorKind.invalidInput, code: 'ticket_active'));
      await pumpTickets(tester);

      await tester.tap(find.textContaining('CS-20261109-0001'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Unduh transkrip'));
      await tester.pumpAndSettle();

      expect(find.text('Transkrip tersedia setelah tiket selesai.'), findsOneWidget);
      expect(saved, isEmpty);
    });
  });

  testWidgets('"Tiket saya" stays reachable from the support menu before any ticket exists', (tester) async {
    final support = MockSupport();
    stubSupport(support);
    when(() => support.myTickets()).thenAnswer((_) async => const []);
    await pumpSupportChat(tester, support);

    await tester.tap(find.byTooltip('Menu bantuan'));
    await tester.pumpAndSettle();
    expect(find.text('Tiket saya'), findsOneWidget);
    await tester.tap(find.text('Tiket saya'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada tiket.'), findsOneWidget);
  });
}
