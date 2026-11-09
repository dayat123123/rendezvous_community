import 'dart:async';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_composer.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_header.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';

import '../../test/support/fakes.dart';
import 'screenshot_harness.dart';

const _nadia = UserSummary(id: 'a-1', username: 'cs_nadia', displayName: 'Nadia');

final _created = DateTime(2026, 11, 4, 9, 12);

SupportTicket _ticket(
  SupportStatus status, {
  String number = 'CS-20261104-0007',
  String topic = 'orders',
  int? queueAhead,
  int? etaMinutes,
  List<String> quickReplies = const [],
}) => SupportTicket(
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
  queueAhead: queueAhead,
  etaMinutes: etaMinutes,
  quickReplies: quickReplies,
);

const _intake = [
  SupportIntakeField(key: 'order_no', type: SupportIntakeType.text, label: 'Nomor order', isRequired: true),
  SupportIntakeField(key: 'trade_date', type: SupportIntakeType.date, label: 'Tanggal transaksi', isRequired: true),
  SupportIntakeField(key: 'amount', type: SupportIntakeType.number, label: 'Nominal (Rp)'),
  SupportIntakeField(
    key: 'side',
    type: SupportIntakeType.choice,
    label: 'Jenis order',
    isRequired: true,
    options: [
      SupportIntakeOption(value: 'buy', label: 'Beli'),
      SupportIntakeOption(value: 'sell', label: 'Jual'),
    ],
  ),
];

const _incidents = [SceneIncidents.critical, SceneIncidents.info];

abstract final class SceneIncidents {
  static const critical = SupportIncident(
    id: 'i-1',
    title: 'Gangguan login aplikasi',
    body: 'Sebagian nasabah gagal masuk sejak 08.10 WIB. Tim kami sedang menangani.',
    level: SupportIncidentLevel.critical,
    faqArticleId: 'a-login',
  );

  static const info = SupportIncident(
    id: 'i-2',
    title: 'Pemeliharaan terjadwal',
    body: 'Sabtu 01.00–03.00 WIB, transfer dana diproses setelah pemeliharaan.',
  );
}

const _survey = SupportSurvey(
  question: 'Bagaimana layanan CS kami?',
  scale: 3,
  reasons: [
    SupportSurveyReason(code: 'slow', label: 'Terlalu lama'),
    SupportSurveyReason(code: 'unresolved', label: 'Masalah belum selesai'),
    SupportSurveyReason(code: 'unclear', label: 'Penjelasan kurang jelas'),
    SupportSurveyReason(code: 'attitude', label: 'Sikap kurang ramah'),
  ],
);

const _topics = [
  SupportTopic(code: 'orders', name: 'Order & Transaksi', intake: _intake),
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

SupportState _state(
  SupportTicket? ticket, {
  bool sensitive = false,
  bool serviceOpen = true,
  List<SupportIncident> incidents = const [],
  String? intakeTopic,
}) => SupportState(
  status: LoadStatus.ready,
  home: SupportHome(
    roomId: 'r-cs',
    supportName: 'CS OLT',
    ticket: ticket,
    active: ticket?.isActive ?? false,
    serviceOpen: serviceOpen,
    nextOpenAt: serviceOpen ? null : DateTime(2026, 11, 5, 8),
    incidents: incidents,
  ),
  topics: _topics,
  sensitive: sensitive ? const SensitiveCheck(masked: true, kinds: ['otp']) : const SensitiveCheck(),
  picking: intakeTopic != null,
  intakeTopic: intakeTopic,
);

class _TopicPanel extends StatelessWidget {
  const _TopicPanel({required this.state, required this.height});

  final SupportState state;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: BlocProvider<SupportCubit>(
      create: (_) => _ReadyCubit(state),
      child: const Column(
        children: [
          SupportHeader(onClose: _noop),
          Expanded(child: SupportTopicPicker()),
        ],
      ),
    ),
  );
}

ChatMessage _message(
  String id,
  int minutes, {
  String? body,
  UserSummary? sender,
  SenderRole? role,
  MessageKind kind = MessageKind.text,
  Map<String, Object?> payload = const {},
  String? replyToId,
  String? replyToBody,
  String? replyToSenderUsername,
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
  replyToId: replyToId,
  replyToBody: replyToBody,
  replyToSenderUsername: replyToSenderUsername,
);

List<ChatMessage> _replyMessages() => [
  ..._activeMessages().take(4),
  _message(
    'm-6',
    5,
    body: 'Biarkan saja dulu, nanti saya ubah sendiri.',
    sender: me,
    replyToId: 'm-4',
    replyToBody: 'Halo Pak Budi, order limit di 9.150 belum tersentuh harga pasar. Apakah ingin diubah?',
    replyToSenderUsername: 'cs_nadia',
  ),
];

class _ReplyingComposer extends StatefulWidget {
  const _ReplyingComposer();

  @override
  State<_ReplyingComposer> createState() => _ReplyingComposerState();
}

class _ReplyingComposerState extends State<_ReplyingComposer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ChatRoomCubit>();
      final target = cubit.state.messages.where((m) => m.id == 'm-4').firstOrNull;
      if (target != null) cubit.setReplyTo(target);
    });
  }

  @override
  Widget build(BuildContext context) => const SupportComposer();
}

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

Attachment _document(String name, String mime, int size) =>
    Attachment(path: 'rooms/r-cs/a-1/$name', bucket: 'cs-documents', mime: mime, name: name, size: size);

List<ChatMessage> _attachmentMessages() => [
  _message('m-1', 0, body: 'Aplikasi keluar sendiri saat buka portofolio. Ini rekaman layarnya.', sender: me),
  _message('m-2', 1, sender: me).copyWith(
    attachments: const [
      Attachment(
        path: 'rooms/r-cs/u-1/rekaman.mp4',
        bucket: 'cs-videos',
        mime: 'video/mp4',
        name: 'rekaman layar.mp4',
        size: 6200000,
        duration: 47,
        width: 1280,
        height: 720,
        thumbnail: 'rooms/r-cs/u-1/rekaman.jpg',
      ),
    ],
  ),
  _message(
    'm-3',
    3,
    body: 'Terima kasih. Mohon isi dan kirim kembali dokumen berikut.',
    sender: _nadia,
    role: SenderRole.agent,
  ).copyWith(
    attachments: [
      _document('Formulir Pengaduan.pdf', 'application/pdf', 182000),
      _document('Surat Kuasa.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 24000),
      _document(
        'Panduan Aplikasi.pptx',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        2400000,
      ),
    ],
  ),
  _message('m-4', 5, sender: me).copyWith(
    attachments: [
      _document('Mutasi Oktober.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 51200),
      _document('transaksi.csv', 'text/csv', 900),
      _document('catatan.txt', 'text/plain', 2048),
    ],
  ),
];

class _PendingMedia extends Fake implements MediaRepository {
  @override
  Future<Uri> documentUri(Attachment attachment) => Completer<Uri>().future;

  @override
  Future<Attachment> uploadSupportFile(
    String roomId,
    Uint8List bytes, {
    required String name,
    required CommunityAttachmentKind kind,
    required CommunityAttachmentFormat format,
  }) => Completer<Attachment>().future;

  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) => Completer<AuthorizedImage>().future;
}

XFile _pickedFile(String name, int size) => XFile.fromData(Uint8List(size), name: name, path: name, length: size);

class _CheckingComposer extends StatefulWidget {
  const _CheckingComposer();

  @override
  State<_CheckingComposer> createState() => _CheckingComposerState();
}

class _CheckingComposerState extends State<_CheckingComposer> {
  void _press(String tooltip) {
    void visit(Element element) {
      final widget = element.widget;
      if (widget is IconButton && widget.tooltip == tooltip) {
        widget.onPressed?.call();
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _press('Lampirkan foto, video, atau dokumen');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (mounted) _press('Kirim');
    });
  }

  @override
  Widget build(BuildContext context) => MessageComposer(
    allowDocuments: true,
    attachmentPolicy: CommunityAttachmentPolicy.fromJson(_policyJson),
    openFilesPicker: ({acceptedTypeGroups = const [], initialDirectory, confirmButtonText}) async => [
      _pickedFile('Rekening Koran.xlsx', 51200),
      _pickedFile('rekaman layar.mp4', 6200000),
    ],
  );
}

const _policyJson = <String, dynamic>{
  'documents': {
    'enabled': true,
    'max_bytes': 10485760,
    'formats': [
      {'code': 'pdf', 'mime': 'application/pdf', 'ext': 'pdf'},
      {'code': 'xlsx', 'mime': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'ext': 'xlsx'},
    ],
  },
  'images': {
    'enabled': true,
    'max_bytes': 5242880,
    'formats': [
      {'code': 'jpeg', 'mime': 'image/jpeg', 'ext': 'jpg'},
    ],
  },
  'videos': {
    'enabled': true,
    'max_bytes': 26214400,
    'max_seconds': 120,
    'formats': [
      {'code': 'mp4', 'mime': 'video/mp4', 'ext': 'mp4'},
    ],
  },
};

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
  const _SupportPanel({
    required this.state,
    required this.messages,
    required this.height,
    this.closed = false,
    this.replying = false,
    this.media,
    this.composer,
  });

  final SupportState state;
  final List<ChatMessage> messages;
  final double height;
  final bool closed;
  final bool replying;
  final MediaRepository? media;
  final Widget? composer;

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
        dependencies: FakeDependencies(chat: chat, mediaRepository: media),
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
                    composer: composer != null
                        ? composer!
                        : closed && ticket != null
                        ? SupportClosedBar(ticketNumber: ticket.ticketNumber)
                        : replying
                        ? const _ReplyingComposer()
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
    'support_reply',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.claimed)),
      messages: _replyMessages(),
      height: 760,
      replying: true,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_attachments',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.claimed)),
      messages: _attachmentMessages(),
      height: 900,
      media: _PendingMedia(),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_upload_checking',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.claimed)),
      messages: _activeMessages().take(4).toList(),
      height: 640,
      media: _PendingMedia(),
      composer: const _CheckingComposer(),
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
  ScreenshotScene(
    'support_survey_reasons',
    (context) => const SupportRatingDialog(survey: _survey, initialRating: 1, initialReasons: {'slow'}),
  ),
  ScreenshotScene(
    'support_incident',
    (context) => _TopicPanel(state: _state(null, incidents: _incidents), height: 720),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_intake',
    (context) => _TopicPanel(state: _state(null, intakeTopic: 'orders'), height: 760),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_queue_eta',
    (context) => _SupportPanel(
      state: _state(_ticket(SupportStatus.open, queueAhead: 3, etaMinutes: 12)),
      messages: _activeMessages().take(2).toList(),
      height: 420,
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'support_quick_replies',
    (context) => _SupportPanel(
      state: _state(
        _ticket(SupportStatus.claimed, quickReplies: const ['Sudah saya coba', 'Belum bisa', 'Terima kasih']),
      ),
      messages: _activeMessages().take(4).toList(),
      height: 640,
    ),
    padding: EdgeInsets.zero,
  ),
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
