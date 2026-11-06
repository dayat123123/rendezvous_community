import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_info_view.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

class _InfoChat extends FakeChatRepository implements MessageInfoRepository {
  _InfoChat({super.rooms, super.members, super.messages, required this.info});

  MessageInfo info;
  final requested = <String>[];

  @override
  Future<MessageInfo> getMessageInfo(String messageId) async {
    requested.add(messageId);
    return info;
  }
}

final _sentAt = DateTime.now().subtract(const Duration(minutes: 30));

ChatMessage _mine(String id, String body, {String roomId = 'dm'}) =>
    ChatMessage(id: id, roomId: roomId, senderId: me.id, sender: me, body: body, createdAt: _sentAt);

Future<TestGesture> _openMenu(WidgetTester tester, String text, {TestGesture? mouse}) async {
  var pointer = mouse;
  if (pointer == null) {
    pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(pointer.removePointer);
    await pointer.addPointer(location: Offset.zero);
  }
  await pointer.moveTo(tester.getCenter(find.text(text)));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Lainnya').hitTestable());
  await tester.pumpAndSettle();
  return pointer;
}

void main() {
  testWidgets('the ⋮ menu on my message offers reply, copy, message info, and delete', (tester) async {
    useScreen(tester, const Size(500, 900));
    final chat = _InfoChat(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [_mine('m-1', 'Order sudah saya kirim')],
      info: MessageInfo(messageId: 'm-1', sentAt: _sentAt),
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));

    await _openMenu(tester, 'Order sudah saya kirim');

    for (final label in ['Balas pesan', 'Salin', 'Info pesan', 'Hapus']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Laporkan'), findsNothing);
  });

  testWidgets('message info of a direct message shows when it was delivered and read', (tester) async {
    useScreen(tester, const Size(500, 900));
    final delivered = _sentAt.add(const Duration(minutes: 1));
    final read = _sentAt.add(const Duration(minutes: 5));
    final chat = _InfoChat(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [_mine('m-1', 'Order sudah saya kirim')],
      info: MessageInfo(
        messageId: 'm-1',
        sentAt: _sentAt,
        recipients: [
          MessageRecipientInfo(user: alice, delivered: true, read: true, deliveredAt: delivered, readAt: read),
        ],
      ),
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));
    final context = tester.element(find.byType(CommunityChatRoom));
    final l10n = CommunityLocalizations.of(context)!;
    String label(DateTime time) => l10n.messageInfoTime(l10n.dayLabel(time), l10n.clockTime(time));

    await _openMenu(tester, 'Order sudah saya kirim');
    await tester.tap(find.text('Info pesan'));
    await tester.pumpAndSettle();

    expect(chat.requested, ['m-1']);
    expect(find.text('Dibaca'), findsOneWidget);
    expect(find.text(label(read)), findsOneWidget);
    expect(find.text('Terkirim'), findsOneWidget);
    expect(find.text(label(delivered)), findsOneWidget);
  });

  testWidgets('message info of a group lists who read it, who received it, and how many are waiting', (tester) async {
    useScreen(tester, const Size(500, 900));
    final room = ChatRoom(id: 'grp', type: RoomType.group, name: 'Grup', createdAt: chatStart, lastReadAt: chatStart);
    final chat = _InfoChat(
      rooms: [room],
      members: [
        ...directMembers(),
        RoomMember(user: bob, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
      ],
      messages: [_mine('g-1', 'Rapat jam 3', roomId: 'grp')],
      info: MessageInfo(
        messageId: 'g-1',
        sentAt: _sentAt,
        recipients: [
          MessageRecipientInfo(user: alice, delivered: true, read: true, readAt: _sentAt, deliveredAt: _sentAt),
          MessageRecipientInfo(user: bob, delivered: true, read: false, deliveredAt: _sentAt),
          const MessageRecipientInfo(
            user: UserSummary(id: 'u-c', username: 'carol'),
            delivered: false,
            read: false,
          ),
        ],
      ),
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'grp'));

    await _openMenu(tester, 'Rapat jam 3');
    await tester.tap(find.text('Info pesan'));
    await tester.pumpAndSettle();

    expect(find.text('Dibaca oleh'), findsOneWidget);
    expect(find.text('Terkirim ke'), findsOneWidget);
    expect(find.text('Alice'), findsWidgets);
    expect(find.text('Bob'), findsWidgets);
    expect(find.text('1 anggota belum menerima'), findsOneWidget);
  });

  testWidgets('message info is not offered for other people\'s messages or without server support', (tester) async {
    useScreen(tester, const Size(500, 900));
    final theirs = ChatMessage(
      id: 'a-1',
      roomId: 'dm',
      senderId: alice.id,
      sender: alice,
      body: 'Pesan dari Alice',
      createdAt: _sentAt,
    );
    final chat = FakeChatRepository(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [theirs, _mine('m-1', 'Pesan saya')],
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));

    final mouse = await _openMenu(tester, 'Pesan dari Alice');
    expect(find.text('Info pesan'), findsNothing);
    expect(find.text('Laporkan'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await _openMenu(tester, 'Pesan saya', mouse: mouse);
    expect(find.text('Info pesan'), findsNothing);
  });

  testWidgets('copy puts the message text on the clipboard', (tester) async {
    useScreen(tester, const Size(500, 900));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final chat = FakeChatRepository(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [_mine('m-1', 'Kode order 4471')],
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));

    await _openMenu(tester, 'Kode order 4471');
    await tester.tap(find.text('Salin'));
    await tester.pumpAndSettle();

    expect(copied, 'Kode order 4471');
    expect(find.text('Pesan disalin'), findsOneWidget);
  });

  testWidgets('on a wide screen message info opens as a panel beside the bubble, without a page', (tester) async {
    useScreen(tester, const Size(1100, 800));
    final chat = _InfoChat(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [_mine('m-1', 'Order sudah saya kirim')],
      info: MessageInfo(
        messageId: 'm-1',
        sentAt: _sentAt,
        recipients: [MessageRecipientInfo(user: alice, delivered: true, read: false, deliveredAt: _sentAt)],
      ),
    );
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));
    final bubble = tester.getRect(find.text('Order sudah saya kirim'));

    await _openMenu(tester, 'Order sudah saya kirim');
    await tester.tap(find.text('Info pesan'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('DIBACA'), findsOneWidget);
    expect(find.text('TERKIRIM'), findsOneWidget);
    final panel = tester.getRect(find.byType(MessageInfoView));
    expect(panel.right, lessThanOrEqualTo(bubble.left));
    expect(
      find.descendant(of: find.byType(MessageInfoView), matching: find.text('Order sudah saya kirim')),
      findsNothing,
    );

    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();
    expect(find.byType(MessageInfoView), findsNothing);
  });
}
