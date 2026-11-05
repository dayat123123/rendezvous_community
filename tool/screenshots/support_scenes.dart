import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_composer.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_header.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';

import '../../test/support/fakes.dart';
import 'screenshot_harness.dart';

const _nadia = UserSummary(id: 'a-1', username: 'cs_nadia', displayName: 'Nadia');

final _created = DateTime(2026, 11, 4, 9, 12);

SupportTicket _ticket(SupportStatus status, {String number = 'CS-20261104-0007', String topic = 'orders'}) =>
    SupportTicket(
      id: 't-$number',
      ticketNumber: number,
      roomId: 'r-cs',
      topic: topic,
      topicName: switch (topic) {
        'funds' => 'Deposit/Tarik Dana',
        'technical' => 'Aplikasi/Teknis',
        _ => 'Order & Transaksi',
      },
      status: status,
      agent: status == SupportStatus.claimed ? const SupportAgent(displayName: 'Nadia') : null,
      createdAt: _created,
      rating: status == SupportStatus.closed ? 5 : null,
      canRate: status == SupportStatus.resolved,
    );

const _topics = [
  SupportTopic(code: 'orders', name: 'Order & Transaksi'),
  SupportTopic(code: 'funds', name: 'Deposit/Tarik Dana'),
  SupportTopic(code: 'technical', name: 'Aplikasi/Teknis'),
  SupportTopic(code: 'fraud', name: 'Penipuan & keamanan akun', urgent: true),
];

class _Support extends Fake implements SupportRepository {
  @override
  Future<List<SupportTicket>> myTickets() async => [
    _ticket(SupportStatus.claimed),
    _ticket(SupportStatus.resolved, number: 'CS-20261028-0003', topic: 'funds'),
    _ticket(SupportStatus.closed, number: 'CS-20261012-0011', topic: 'technical'),
  ];

  @override
  Stream<void> watchTicket(String roomId) => const Stream.empty();

  @override
  Future<SensitiveCheck> checkSensitive(String text) async => const SensitiveCheck();
}

class _ReadyCubit extends SupportCubit {
  _ReadyCubit(SupportState state) : super(support: _Support()) {
    emit(state);
  }
}

SupportState _state(SupportTicket? ticket, {bool sensitive = false, bool serviceOpen = true}) => SupportState(
  status: LoadStatus.ready,
  home: SupportHome(
    roomId: 'r-cs',
    supportName: 'CS OLT',
    ticket: ticket,
    active: ticket?.isActive ?? false,
    serviceOpen: serviceOpen,
    nextOpenAt: serviceOpen ? null : DateTime(2026, 11, 5, 8),
  ),
  topics: _topics,
  sensitive: sensitive ? const SensitiveCheck(masked: true, kinds: ['otp']) : const SensitiveCheck(),
);

ChatMessage _message(
  String id,
  int minutes, {
  String? body,
  UserSummary? sender,
  SenderRole? role,
  MessageKind kind = MessageKind.text,
  Map<String, Object?> payload = const {},
}) => ChatMessage(
  id: id,
  roomId: 'r-cs',
  senderId: sender?.id,
  sender: sender,
  body: body,
  createdAt: _created.add(Duration(minutes: minutes)),
  kind: kind,
  senderRole: role,
  ticketId: 't-1',
  payload: payload,
);

List<ChatMessage> _activeMessages() => [
  _message(
    'm-1',
    0,
    body: 'Tiket CS-20261104-0007 dibuat. Kami akan segera membantu.',
    role: SenderRole.system,
    kind: MessageKind.system,
    payload: const {'code': 'ticket_opened'},
  ),
  _message('m-2', 1, body: 'Order BBCA saya dari pagi belum terpenuhi, kenapa ya?', sender: me),
  _message(
    'm-3',
    2,
    body: 'Nadia dari CS Resmi siap membantu Anda.',
    role: SenderRole.system,
    kind: MessageKind.system,
    payload: const {'code': 'ticket_claimed'},
  ),
  _message(
    'm-4',
    3,
    body: 'Halo Pak Budi, order limit di 9.150 belum tersentuh harga pasar. Apakah ingin diubah?',
    sender: _nadia,
    role: SenderRole.agent,
  ),
  _message(
    'm-5',
    4,
    body: 'Pilih salah satu agar kami bisa lanjutkan:',
    sender: _nadia,
    role: SenderRole.agent,
    kind: MessageKind.quickReply,
    payload: const {
      'options': ['Ubah harga', 'Biarkan saja', 'Batalkan order'],
    },
  ),
];

List<ChatMessage> _closedMessages() => [
  _message('m-1', 0, body: 'Terima kasih, sudah beres.', sender: me),
  _message(
    'm-2',
    1,
    body: 'Senang bisa membantu. Bagaimana pelayanan kami hari ini?',
    sender: _nadia,
    role: SenderRole.agent,
  ),
  _message(
    'm-3',
    2,
    body: 'Tiket CS-20261104-0007 selesai.',
    role: SenderRole.system,
    kind: MessageKind.csat,
    payload: const {'code': 'ticket_resolved'},
  ),
];

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({required this.state, required this.messages, required this.height, this.closed = false});

  final SupportState state;
  final List<ChatMessage> messages;
  final double height;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    final chat = FakeChatRepository(
      rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, name: 'CS OLT', createdAt: _created, lastReadAt: _created)],
      messages: messages,
    );
    final ticket = state.ticket;
    return SizedBox(
      height: height,
      child: CommunityScope(
        dependencies: FakeDependencies(chat: chat),
        child: BlocProvider<SupportCubit>(
          create: (_) => _ReadyCubit(state),
          child: Column(
            children: [
              const SupportHeader(onClose: _noop),
              Expanded(
                child: CommunitySupportMessageActions(
                  onQuickReply: (_) {},
                  canRate: (_) => true,
                  onRate: (_) {},
                  child: CommunityChatRoom(
                    roomId: 'r-cs',
                    repository: chat,
                    showHeader: false,
                    composer: closed && ticket != null
                        ? SupportClosedBar(ticketNumber: ticket.ticketNumber)
                        : const SupportComposer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}

class _Notifications extends Fake implements NotificationRepository {
  _Notifications(this.items);

  final List<AppNotification> items;

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async => Paged(items);

  @override
  Future<int> unreadCount() async => items.where((n) => !n.isRead).length;

  @override
  Future<void> markRead({List<String>? ids}) async {}

  @override
  Stream<void> watchNotifications() => const Stream.empty();
}

final _now = DateTime.now();

const _rina = UserSummary(id: 'u-rina', username: 'rina.invest', displayName: 'Rina Wulandari', isVerified: true);

List<AppNotification> _notifications() => [
  AppNotification(
    id: 'n-1',
    type: NotificationType.reply,
    actor: _rina,
    payload: const {'post_id': 'p-1', 'snippet': 'Setuju, NIM bank besar masih stabil walau suku bunga turun.'},
    createdAt: _now.subtract(const Duration(minutes: 4)),
    cursor: 'c-1',
  ),
  AppNotification(
    id: 'n-2',
    type: NotificationType.announcement,
    payload: const {
      'source': 'olt',
      'kind': 'olt.trade',
      'category': 'info',
      'title': {'id': 'Order BBCA terpenuhi', 'en': 'BBCA order filled'},
      'body': {'id': '10 lot @ 9.200 · Beli', 'en': '10 lots @ 9,200 · Buy'},
    },
    createdAt: _now.subtract(const Duration(minutes: 30)),
    cursor: 'c-2',
  ),
  AppNotification(
    id: 'n-3',
    type: NotificationType.like,
    actor: alice,
    actorCount: 12,
    payload: const {'post_id': 'p-2', 'snippet': r'Apakah $TLKM masih layak dikoleksi?'},
    readAt: _now,
    createdAt: _now.subtract(const Duration(hours: 3)),
    cursor: 'c-3',
  ),
  AppNotification(
    id: 'n-4',
    type: NotificationType.announcement,
    payload: const {
      'source': 'olt',
      'kind': 'olt.info',
      'category': 'important',
      'title': 'Pemeliharaan sistem Sabtu 01.00–03.00 WIB',
    },
    readAt: _now,
    createdAt: _now.subtract(const Duration(days: 1)),
    cursor: 'c-4',
  ),
  AppNotification(
    id: 'n-5',
    type: NotificationType.follow,
    actor: bob,
    readAt: _now,
    createdAt: _now.subtract(const Duration(days: 2)),
    cursor: 'c-5',
  ),
];

final supportScenes = <ScreenshotScene>[
  ScreenshotScene(
    'support_chat',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.claimed), sensitive: true),
      messages: _activeMessages(),
      height: 760,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_closed',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.closed), serviceOpen: false),
      messages: _closedMessages(),
      height: 520,
      closed: true,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_topics',
    (context) => SizedBox(
      height: 460,
      child: BlocProvider<SupportCubit>(create: (_) => _ReadyCubit(_state(null)), child: const SupportTopicPicker()),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene('support_rating', (context) => const SupportRatingDialog()),
  ScreenshotScene('support_tickets', (context) {
    final chat = FakeChatRepository();
    return SizedBox(
      height: 330,
      child: CommunityScope(
        dependencies: FakeDependencies(chat: chat),
        child: CommunitySupportScope(dependencies: _SupportDeps(chat), child: const CommunitySupportTickets()),
      ),
    );
  }, padding: EdgeInsets.zero),
  ScreenshotScene(
    'notifications_list',
    (context) => SizedBox(
      height: 560,
      child: CommunityScope(
        dependencies: FakeDependencies(notifications: _Notifications(_notifications())),
        child: const CommunityNotificationList(),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
];

class _SupportDeps implements CommunitySupportDependencies {
  _SupportDeps(this.supportChat);

  @override
  final SupportRepository support = _Support();
  @override
  final ChatRepository supportChat;
}
