import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/data/models/support_models.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_header.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../support/support_kit.dart';

RecordingChatRepository _chat() => RecordingChatRepository(
  rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: DateTime.now(), lastReadAt: DateTime.now())],
);

void main() {
  test('the ticket view parses quick replies and the queue estimate, and old servers give none', () {
    final ticket = SupportTicketModel.fromJson({
      'id': 't-1',
      'ticket_number': 'CS-1',
      'room_id': 'r-cs',
      'topic': 'orders',
      'status': 'open',
      'queue_ahead': 3,
      'eta_minutes': 12,
      'quick_replies': ['Sudah saya coba', '', 'Belum bisa', 7],
      'created_at': '2026-11-09T02:00:00Z',
    }).toEntity();
    expect(ticket.etaMinutes, 12);
    expect(ticket.quickReplies, ['Sudah saya coba', 'Belum bisa']);

    final old = SupportTicketModel.fromJson({
      'id': 't-1',
      'ticket_number': 'CS-1',
      'room_id': 'r-cs',
      'topic': 'orders',
      'status': 'claimed',
      'quick_replies': null,
      'created_at': '2026-11-09T02:00:00Z',
    }).toEntity();
    expect(old.etaMinutes, isNull);
    expect(old.quickReplies, isEmpty);
  });

  test('the waiting status shows the queue position and the estimate', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    expect(
      supportStatusText(l10n, supportTicket(status: SupportStatus.open, queueAhead: 2, etaMinutes: 8)),
      'Menunggu CS · 2 tiket di depan Anda · Perkiraan menunggu ± 8 menit',
    );
    expect(supportStatusText(l10n, supportTicket(status: SupportStatus.open)), 'Menunggu CS');
    expect(
      supportStatusText(
        lookupCommunityLocalizations(const Locale('en')),
        supportTicket(status: SupportStatus.open, etaMinutes: 5),
      ),
      'Waiting for an agent · Estimated wait ± 5 min',
    );
  });

  testWidgets('quick reply chips above the composer send through the normal send path', (tester) async {
    final support = MockSupport();
    stubSupport(
      support,
      home: SupportHome(
        roomId: 'r-cs',
        supportName: 'CS OLT',
        ticket: supportTicket(quickReplies: const ['Sudah saya coba', 'Belum bisa']),
        active: true,
      ),
    );
    final chat = _chat();
    await pumpSupportChat(tester, support, chat: chat);

    expect(find.text('Sudah saya coba'), findsOneWidget);
    await tester.tap(find.text('Belum bisa'));
    await tester.pumpAndSettle();

    expect(chat.sentBodies, ['Belum bisa']);
    expect(find.text('Belum bisa'), findsNWidgets(2));
  });

  testWidgets('a finished ticket shows no quick replies even while it can be reopened', (tester) async {
    final support = MockSupport();
    stubSupport(
      support,
      home: SupportHome(
        roomId: 'r-cs',
        supportName: 'CS OLT',
        ticket: supportTicket(
          status: SupportStatus.resolved,
          quickReplies: const ['Sudah saya coba'],
        ).copyWith(reopenUntil: DateTime.now().add(const Duration(days: 1))),
      ),
    );
    await pumpSupportChat(tester, support, chat: _chat());

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Sudah saya coba'), findsNothing);
  });

  testWidgets('the header shows the queue estimate for an open ticket', (tester) async {
    final support = MockSupport();
    stubSupport(
      support,
      home: SupportHome(
        roomId: 'r-cs',
        supportName: 'CS OLT',
        ticket: supportTicket(status: SupportStatus.open, queueAhead: 1, etaMinutes: 4),
        active: true,
      ),
    );
    await pumpSupportChat(tester, support, chat: _chat());

    expect(find.text('Menunggu CS · 1 tiket di depan Anda · Perkiraan menunggu ± 4 menit'), findsOneWidget);
  });
}
