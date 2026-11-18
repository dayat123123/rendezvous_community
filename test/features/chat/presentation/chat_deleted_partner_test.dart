import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

const _gone = UserSummary(id: 'u-gone', username: 'deleted_0123456789ab');

ChatRoom _deletedRoom() =>
    ChatRoom(id: 'dm', type: RoomType.direct, createdAt: chatStart, lastReadAt: chatStart, otherUser: _gone);

List<RoomMember> _members() => [
  RoomMember(user: me, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
  RoomMember(user: _gone, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
];

void main() {
  test('a scrubbed or blank username marks a deleted account', () {
    expect(_gone.isDeleted, isTrue);
    expect(const UserSummary(id: 'x', username: '').isDeleted, isTrue);
    expect(const UserSummary(id: 'x', username: 'deleted_fan').isDeleted, isFalse);
    expect(alice.isDeleted, isFalse);
  });

  test('only direct rooms with a deleted or missing partner are flagged', () {
    expect(_deletedRoom().partnerDeleted, isTrue);
    expect(
      ChatRoom(id: 'dm', type: RoomType.direct, createdAt: chatStart, lastReadAt: chatStart).partnerDeleted,
      isTrue,
    );
    expect(directRoom().partnerDeleted, isFalse);
    expect(
      ChatRoom(id: 'g', type: RoomType.group, name: 'G', createdAt: chatStart, lastReadAt: chatStart).partnerDeleted,
      isFalse,
    );
  });

  testWidgets('a chat with a deleted account names it, explains it, and stays readable', (tester) async {
    final headers = <CommunityRoomHeaderDetails>[];
    final notices = <CommunityRoomNoticeDetails>[];
    final avatars = <CommunityRoomAvatarDetails>[];
    final chat = FakeChatRepository(rooms: [_deletedRoom()], members: _members(), messages: chatHistory(2));
    await pumpChat(
      tester,
      chat,
      CommunityChatRoom(
        roomId: 'dm',
        repository: chat,
        builders: CommunityChatBuilders(
          roomHeader: (context, d, fallback) {
            headers.add(d);
            return fallback;
          },
          roomNotice: (context, d, fallback) {
            notices.add(d);
            return fallback;
          },
          roomAvatar: (context, d, fallback) {
            avatars.add(d);
            return fallback;
          },
        ),
      ),
    );

    expect(find.text('Akun terhapus'), findsOneWidget);
    expect(find.text('Akun ini sudah dihapus'), findsOneWidget);
    expect(find.text('@deleted_0123456789ab'), findsNothing);
    expect(headers.last.title, 'Akun terhapus');
    expect(headers.last.onTap, isNull);
    expect(headers.last.room.partnerDeleted, isTrue);
    expect(notices.map((n) => n.kind), contains(CommunityRoomNoticeKind.accountDeleted));
    expect(find.text('Pengguna ini sudah menghapus akunnya. Riwayat chat tetap bisa dibaca.'), findsOneWidget);
    expect(avatars.any((a) => a.room.partnerDeleted), isTrue);
    expect(find.byIcon(Icons.person_off_outlined), findsWidgets);
    expect(find.text('Pesan 1'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('a live direct chat keeps its normal header', (tester) async {
    final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: chatHistory(1));
    await pumpChat(tester, chat, CommunityChatRoom(roomId: 'dm', repository: chat));

    expect(find.text('Alice'), findsWidgets);
    expect(find.text('Akun terhapus'), findsNothing);
    await chat.dispose();
  });
}
