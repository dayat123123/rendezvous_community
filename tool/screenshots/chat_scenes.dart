import 'package:flutter/material.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_info_view.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_banners.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_bubble.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/widgets/community_message_requests.dart';

import '../../test/support/fakes.dart';
import '../../test/support/feature_fakes.dart';
import 'screenshot_harness.dart';

const _rina = UserSummary(id: 'u-rina', username: 'rina.invest', displayName: 'Rina Wulandari', isVerified: true);
const _dimas = UserSummary(id: 'u-dimas', username: 'dimas_p', displayName: 'Dimas Pratama');

final _now = DateTime.now();

DateTime _ago(Duration d) => _now.subtract(d).toUtc();

List<ChatRoom> _rooms() => [
  ChatRoom(
    id: 'cs',
    type: RoomType.support,
    name: 'CS OLT',
    lastMessageAt: _ago(const Duration(minutes: 2)),
    lastMessagePreview: 'Order Anda sudah kami cek, mohon tunggu sebentar.',
    createdAt: _ago(const Duration(days: 30)),
    lastReadAt: _ago(const Duration(days: 1)),
    unreadCount: 1,
  ),
  ChatRoom(
    id: 'dm-rina',
    type: RoomType.direct,
    otherUser: _rina,
    lastMessageAt: _ago(const Duration(minutes: 8)),
    lastMessagePreview: r'Menurutmu $BBCA masih layak akumulasi?',
    lastMessageSenderId: _rina.id,
    createdAt: _ago(const Duration(days: 9)),
    lastReadAt: _ago(const Duration(days: 1)),
    unreadCount: 3,
  ),
  ChatRoom(
    id: 'dm-dimas',
    type: RoomType.direct,
    otherUser: _dimas,
    lastMessageAt: _ago(const Duration(hours: 2)),
    lastMessagePreview: 'Siap, nanti saya kabari hasil RUPS-nya.',
    lastMessageSenderId: me.id,
    lastMessageStatus: ReceiptStatus.read,
    createdAt: _ago(const Duration(days: 20)),
    lastReadAt: _ago(const Duration(hours: 2)),
  ),
  ChatRoom(
    id: 'g-bank',
    type: RoomType.group,
    name: 'Diskusi Perbankan',
    lastMessageAt: _ago(const Duration(hours: 5)),
    lastMessagePreview: 'NIM kuartal ini lebih stabil dari dugaan.',
    lastMessageSenderId: alice.id,
    createdAt: _ago(const Duration(days: 40)),
    lastReadAt: _ago(const Duration(hours: 5)),
    muted: true,
    unreadCount: 12,
  ),
  ChatRoom(
    id: 's-tlkm',
    type: RoomType.stock,
    stockCode: 'TLKM',
    name: 'Telkom Indonesia',
    lastMessageAt: _ago(const Duration(days: 1)),
    lastMessagePreview: 'Dividen tahun ini diumumkan minggu depan.',
    createdAt: _ago(const Duration(days: 60)),
    lastReadAt: _ago(const Duration(days: 1)),
  ),
];

class _RoomListSample extends StatelessWidget {
  const _RoomListSample();

  @override
  Widget build(BuildContext context) {
    final chat = FakeChatRepository(rooms: _rooms());
    return SizedBox(
      height: 560,
      child: CommunityScope(
        dependencies: FakeDependencies(chat: chat),
        child: const CommunityChatList(),
      ),
    );
  }
}

ChatMessage _message(
  String id,
  Duration ago, {
  required UserSummary sender,
  String? body,
  String? replyToId,
  String? replyToBody,
  String? replyToSenderUsername,
  List<MessageReaction> reactions = const [],
  List<String> stockCodes = const [],
  String? sharedPostId,
  SharedPost? sharedPost,
}) => ChatMessage(
  id: id,
  roomId: 'dm-rina',
  senderId: sender.id,
  sender: sender,
  body: body,
  replyToId: replyToId,
  replyToBody: replyToBody,
  replyToSenderUsername: replyToSenderUsername,
  reactions: reactions,
  stockCodes: stockCodes,
  sharedPostId: sharedPostId,
  sharedPost: sharedPost,
  createdAt: _ago(ago),
);

List<ChatMessage> _messages() => [
  _message('m-1', const Duration(days: 1, minutes: 30), sender: _rina, body: 'Pagi! Sudah lihat laporan Q3 bank?'),
  _message(
    'm-2',
    const Duration(minutes: 22),
    sender: me,
    body: 'Sudah. Laba BBCA tumbuh dua digit, NPL turun.',
    reactions: const [MessageReaction(emoji: '👍', count: 1)],
  ),
  _message('m-3', const Duration(minutes: 21), sender: me, stockCodes: const ['BBCA', 'BMRI']),
  _message(
    'm-4',
    const Duration(minutes: 12),
    sender: _rina,
    body: 'Menurutmu masih layak akumulasi di harga sekarang?',
    replyToId: 'm-2',
    replyToBody: 'Sudah. Laba BBCA tumbuh dua digit, NPL turun.',
    replyToSenderUsername: me.username,
    reactions: const [MessageReaction(emoji: '🔥', count: 2, mine: true)],
  ),
  _message(
    'm-5',
    const Duration(minutes: 11),
    sender: _rina,
    sharedPostId: 'p-1',
    sharedPost: const SharedPost(
      postId: 'p-1',
      author: alice,
      body: 'Valuasi perbankan sudah premium, saya pilih akumulasi bertahap sambil memantau suku bunga.',
    ),
  ),
  _message('m-6', const Duration(minutes: 3), sender: me, body: 'Bertahap saja, sambil pantau suku bunga 👌'),
];

String _stockName(String code) => switch (code) {
  'BBCA' => 'Bank Central Asia',
  _ => 'Bank Mandiri',
};

CommunityStockInfo? _stockInfo(String code) => CommunityStockInfo(
  name: _stockName(code),
  price: code == 'BBCA' ? '9.250' : '6.125',
  change: code == 'BBCA' ? '+1,4%' : '−0,8%',
  rising: code == 'BBCA',
);

class _ChatRoomSample extends StatelessWidget {
  const _ChatRoomSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final room = ChatRoom(
      id: 'dm-rina',
      type: RoomType.direct,
      otherUser: _rina,
      createdAt: _ago(const Duration(days: 9)),
      lastReadAt: _ago(Duration.zero),
    );
    final chat = FakeChatRepository(
      rooms: [room],
      members: [
        RoomMember(user: me, lastReadAt: _ago(Duration.zero), lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
        RoomMember(user: _rina, lastReadAt: _ago(Duration.zero), lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
      ],
      messages: _messages(),
    );
    return SizedBox(
      height: 860,
      child: Material(
        color: style.surface,
        child: CommunityScope(
          dependencies: FakeDependencies(
            chat: chat,
            callbacks: const CommunityCallbacks(stockInfo: _stockInfo),
          ),
          child: CommunityChatRoom(roomId: 'dm-rina', repository: chat),
        ),
      ),
    );
  }
}

class _InfoChat extends FakeChatRepository implements MessageInfoRepository {
  _InfoChat({super.rooms, super.members, super.messages, required this.info});

  final MessageInfo info;

  @override
  Future<MessageInfo> getMessageInfo(String messageId) async => info;
}

class _MessageInfoSample extends StatelessWidget {
  const _MessageInfoSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final room = ChatRoom(
      id: 'grp-info',
      type: RoomType.group,
      name: 'Diskusi Dividen',
      createdAt: _ago(const Duration(days: 9)),
      lastReadAt: _ago(Duration.zero),
    );
    final sent = _ago(const Duration(minutes: 42));
    final message = ChatMessage(
      id: 'info-1',
      roomId: 'grp-info',
      senderId: me.id,
      sender: me,
      body: 'Jadwal cum date TLKM sudah keluar, cek pengumuman di IDX ya.',
      createdAt: sent,
    );
    final chat = _InfoChat(
      rooms: [room],
      members: [
        RoomMember(user: me, lastReadAt: _ago(Duration.zero), lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
        RoomMember(user: _rina, lastReadAt: _ago(Duration.zero), lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
        RoomMember(user: alice, lastReadAt: sent, lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
      ],
      messages: [message],
      info: MessageInfo(
        messageId: 'info-1',
        sentAt: sent,
        recipients: [
          MessageRecipientInfo(
            user: _rina,
            delivered: true,
            read: true,
            deliveredAt: _ago(const Duration(minutes: 41)),
            readAt: _ago(const Duration(minutes: 37)),
          ),
          MessageRecipientInfo(
            user: alice,
            delivered: true,
            read: false,
            deliveredAt: _ago(const Duration(minutes: 40)),
          ),
          const MessageRecipientInfo(
            user: UserSummary(id: 'u-dimas', username: 'dimas', displayName: 'Dimas Pratama'),
            delivered: false,
            read: false,
          ),
        ],
      ),
    );
    return SizedBox(
      height: 640,
      child: Material(
        color: style.surface,
        child: CommunityScope(
          dependencies: FakeDependencies(chat: chat),
          child: CommunityChatRoom(
            roomId: 'grp-info',
            repository: chat,
            showHeader: false,
            composer: SizedBox(height: 470, child: MessageInfoView(message: message)),
          ),
        ),
      ),
    );
  }
}

ChatMessage _groupMessage(
  String id,
  Duration ago,
  UserSummary sender,
  String body, {
  List<MessageReaction> reactions = const [],
}) => ChatMessage(
  id: id,
  roomId: 's-tlkm',
  senderId: sender.id,
  sender: sender,
  body: body,
  reactions: reactions,
  createdAt: _ago(ago),
);

class _GroupRoomSample extends StatelessWidget {
  const _GroupRoomSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final room = ChatRoom(
      id: 's-tlkm',
      type: RoomType.stock,
      stockCode: 'TLKM',
      name: 'Telkom Indonesia',
      createdAt: _ago(const Duration(days: 60)),
      lastReadAt: _ago(Duration.zero),
    );
    final chat = FakeChatRepository(
      rooms: [room],
      members: [
        for (final user in [me, _rina, _dimas, alice])
          RoomMember(user: user, lastReadAt: _ago(Duration.zero), lastDeliveredAt: _ago(Duration.zero), joinedAt: _now),
      ],
      messages: [
        _groupMessage('g-1', const Duration(minutes: 40), _rina, 'Dividen TLKM tahun ini kira-kira berapa?'),
        _groupMessage('g-2', const Duration(minutes: 39), _rina, 'Ada yang sudah lihat jadwal cum date?'),
        _groupMessage(
          'g-3',
          const Duration(minutes: 30),
          _dimas,
          'Biasanya diumumkan setelah RUPS, sekitar Mei.',
          reactions: const [MessageReaction(emoji: '👍', count: 3)],
        ),
        _groupMessage('g-4', const Duration(minutes: 20), me, 'Yield tahun lalu sekitar 4,5%.'),
        _groupMessage('g-5', const Duration(minutes: 12), alice, 'Saya tunggu konfirmasi resmi dulu.'),
        _groupMessage('g-6', const Duration(minutes: 11), alice, 'Sambil pantau arus kas bebasnya.'),
      ],
    );
    return SizedBox(
      height: 760,
      child: Material(
        color: style.surface,
        child: CommunityScope(
          dependencies: FakeDependencies(chat: chat),
          child: CommunityChatRoom(roomId: 's-tlkm', repository: chat),
        ),
      ),
    );
  }
}

class _NoticesSample extends StatelessWidget {
  const _NoticesSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Material(
      color: style.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.pinned,
              icon: Icons.push_pin,
              title: 'Pesan disematkan · Rina Wulandari',
              message: 'Jadwal diskusi rilis laporan keuangan: Kamis 19.30 WIB di room ini.',
            ),
          ),
          const RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.slowMode,
              icon: Icons.timer_outlined,
              message: 'Mode lambat aktif: satu pesan setiap 30 detik.',
            ),
          ),
          RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.dmRequestReceived,
              icon: Icons.mark_email_unread_outlined,
              message: 'Dimas Pratama ingin mengirim pesan kepada Anda.',
              actionLabel: 'Terima',
              onAction: () {},
            ),
          ),
          const RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.dmRequestLimit,
              icon: Icons.mark_email_unread_outlined,
              message: 'Tunggu Dimas menerima permintaan pesan Anda sebelum mengirim lagi.',
              strong: true,
            ),
          ),
          const RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.dmRequestInfo,
              icon: Icons.info_outline,
              message: 'Pesan Anda masuk sebagai permintaan pesan sampai dibalas.',
            ),
          ),
          SizedBox(height: style.spacing.lg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: style.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReactionPicker(choices: const ['👍', '❤️', '😂', '😮', '🔥'], selected: '🔥', onSelected: (_) {}),
                SizedBox(height: style.spacing.sm),
                const ReactionChips(
                  reactions: [
                    MessageReaction(emoji: '👍', count: 4),
                    MessageReaction(emoji: '🔥', count: 2, mine: true),
                  ],
                ),
                SizedBox(height: style.spacing.md),
                const TypingBubble(label: 'Rina sedang mengetik…', user: _rina),
                const TypingBubble(label: 'mengetik…'),
                SizedBox(height: style.spacing.md),
                StockCardTile(
                  details: CommunityStockCardDetails(code: 'BBCA', isMine: false, info: _stockInfo('BBCA')),
                ),
                StockCardTile(
                  details: CommunityStockCardDetails(code: 'BMRI', isMine: false, info: _stockInfo('BMRI')),
                ),
                SizedBox(height: style.spacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

MessageRequest _request(String roomId, UserSummary sender, String preview, int count, Duration ago) => MessageRequest(
  roomId: roomId,
  sender: sender,
  messageCount: count,
  lastMessagePreview: preview,
  lastMessageAt: _ago(ago),
  createdAt: _ago(ago),
);

class _RequestsSample extends StatelessWidget {
  const _RequestsSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final requests = [
      _request('r-1', _dimas, 'Halo, boleh tanya soal analisis TLKM kemarin?', 2, const Duration(minutes: 14)),
      _request('r-2', alice, 'Saya tertarik gabung grup diskusi perbankan.', 1, const Duration(hours: 6)),
    ];
    final features = FakeFeatureDependencies(config: loadedConfig());
    features.messageRequests
      ..requests = requests
      ..count = requests.length;
    final chat = FakeChatRepository(
      messages: [
        ChatMessage(
          id: 'q-1',
          roomId: 'r-1',
          senderId: _dimas.id,
          sender: _dimas,
          body: 'Halo, boleh tanya soal analisis TLKM kemarin?',
          createdAt: _ago(const Duration(minutes: 15)),
        ),
        ChatMessage(
          id: 'q-2',
          roomId: 'r-1',
          senderId: _dimas.id,
          sender: _dimas,
          body: 'Saya baru mulai belajar valuasi dividen.',
          createdAt: _ago(const Duration(minutes: 14)),
        ),
      ],
    );
    return CommunityScope(
      dependencies: FakeDependencies(chat: chat),
      child: CommunityFeatureScope(
        dependencies: features,
        child: Material(
          color: style.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MessageRequestsEntry(),
              const SizedBox(height: 200, child: CommunityMessageRequests()),
              Container(height: style.spacing.sm, color: style.background),
              SizedBox(height: 420, child: MessageRequestRoom(request: requests.first)),
            ],
          ),
        ),
      ),
    );
  }
}

final chatScenes = <ScreenshotScene>[
  ScreenshotScene('chat_rooms', padding: EdgeInsets.zero, (context) => const _RoomListSample()),
  ScreenshotScene('chat_room', padding: EdgeInsets.zero, (context) => const _ChatRoomSample()),
  ScreenshotScene('chat_message_info', padding: EdgeInsets.zero, (context) => const _MessageInfoSample()),
  ScreenshotScene('chat_group', padding: EdgeInsets.zero, (context) => const _GroupRoomSample()),
  ScreenshotScene('chat_notices', padding: EdgeInsets.zero, (context) => const _NoticesSample()),
  ScreenshotScene('chat_requests', padding: EdgeInsets.zero, (context) => const _RequestsSample()),
];
