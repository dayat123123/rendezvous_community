import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_tile.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

class _NoMedia extends Fake implements MediaRepository {}

ChatRoom _room(String id, RoomType type, {MemberRole role = MemberRole.member, int minutes = 0}) => ChatRoom(
  id: id,
  type: type,
  name: switch (type) {
    RoomType.group => 'Grup $id',
    RoomType.stock => 'BBCA',
    RoomType.support => 'CS',
    RoomType.direct => null,
  },
  stockCode: type == RoomType.stock ? 'BBCA' : null,
  otherUser: type == RoomType.direct ? alice : null,
  myRole: role,
  lastMessageAt: chatStart.subtract(Duration(minutes: minutes)),
  createdAt: chatStart.subtract(const Duration(days: 1)),
  lastReadAt: chatStart.subtract(const Duration(days: 1)),
);

Future<void> _pumpTile(WidgetTester tester, ChatRoom room, {CommunityChatBuilders? builders}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityChatBuildersScope(
          builders: builders ?? const CommunityChatBuilders(),
          child: RoomTile(
            room: room,
            me: me,
            online: false,
            typing: const [],
            selected: false,
            onTap: () {},
            onHide: () {},
            onLeave: () {},
            onDeleteGroup: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<List<String>> _sheetLabels(WidgetTester tester, ChatRoom room) async {
  await _pumpTile(tester, room);
  await tester.longPress(find.byType(RoomTile));
  await tester.pumpAndSettle();
  final labels = [
    for (final label in ['Hapus chat', 'Keluar', 'Hapus grup'])
      if (find.text(label).evaluate().isNotEmpty) label,
  ];
  return labels;
}

void main() {
  group('room actions follow the room type', () {
    test('permission getters', () {
      expect(_room('cs', RoomType.support).canHide, isFalse);
      expect(_room('cs', RoomType.support).canLeave, isFalse);
      expect(_room('dm', RoomType.direct).canLeave, isFalse);
      expect(_room('g', RoomType.group, role: MemberRole.owner).canDeleteGroup, isTrue);
      expect(_room('g', RoomType.group, role: MemberRole.admin).canDeleteGroup, isFalse);
      expect(_room('s', RoomType.stock).canDeleteGroup, isFalse);
    });

    testWidgets('support has no actions at all', (tester) async {
      await _pumpTile(tester, _room('cs', RoomType.support));
      await tester.longPress(find.byType(RoomTile));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('direct only offers Hapus chat', (tester) async {
      expect(await _sheetLabels(tester, _room('dm', RoomType.direct)), ['Hapus chat']);
    });

    testWidgets('stock offers Hapus chat and Keluar', (tester) async {
      expect(await _sheetLabels(tester, _room('s', RoomType.stock)), ['Hapus chat', 'Keluar']);
    });

    testWidgets('the group owner gets Hapus grup', (tester) async {
      expect(await _sheetLabels(tester, _room('g', RoomType.group, role: MemberRole.owner)), [
        'Hapus chat',
        'Keluar',
        'Hapus grup',
      ]);
    });

    testWidgets('a group admin does not get Hapus grup', (tester) async {
      expect(await _sheetLabels(tester, _room('g', RoomType.group, role: MemberRole.admin)), ['Hapus chat', 'Keluar']);
    });

    testWidgets('a group member does not get Hapus grup', (tester) async {
      expect(await _sheetLabels(tester, _room('g', RoomType.group)), ['Hapus chat', 'Keluar']);
    });

    testWidgets('right click opens the same actions', (tester) async {
      await _pumpTile(tester, _room('dm', RoomType.direct));
      await tester.tap(find.byType(RoomTile), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(find.text('Hapus chat'), findsOneWidget);
    });

    testWidgets('the roomActions builder replaces the menu', (tester) async {
      CommunityRoomActionsDetails? seen;
      await _pumpTile(
        tester,
        _room('g', RoomType.group, role: MemberRole.owner),
        builders: CommunityChatBuilders(
          roomActions: (context, details, fallback) {
            seen = details;
            return const Text('menu host');
          },
        ),
      );
      await tester.longPress(find.byType(RoomTile));
      await tester.pumpAndSettle();
      expect(find.text('menu host'), findsOneWidget);
      expect(seen!.actions.map((a) => a.kind), [
        CommunityRoomActionKind.hide,
        CommunityRoomActionKind.leave,
        CommunityRoomActionKind.deleteGroup,
      ]);
    });
  });

  group('ChatListCubit', () {
    late FakeChatRepository chat;
    late ChatListCubit cubit;

    setUp(() async {
      chat = FakeChatRepository(
        rooms: [
          _room('cs', RoomType.support),
          _room('dm', RoomType.direct, minutes: 1),
          _room('g', RoomType.group, role: MemberRole.owner, minutes: 2),
        ],
      );
      cubit = ChatListCubit(chat: chat, me: () async => me);
      await cubit.load();
    });

    tearDown(() async {
      await cubit.close();
      await chat.dispose();
    });

    List<String> ids() => [for (final r in cubit.state.rooms) r.id];

    test('hideRoom removes the room right away', () async {
      final room = cubit.state.rooms[1];
      final pending = cubit.hideRoom(room);
      expect(ids(), ['cs', 'g']);
      expect(await pending, isTrue);
      expect(chat.hiddenRooms, ['dm']);
    });

    test('hideRoom rolls back when the server refuses', () async {
      chat.roomActionError = const CommunityException(CommunityErrorKind.invalidInput, code: 'cannot_hide_support');
      expect(await cubit.hideRoom(cubit.state.rooms[1]), isFalse);
      expect(ids(), ['cs', 'dm', 'g']);
      expect(cubit.state.actionError, isA<CommunityException>());
    });

    test('support cannot be hidden from the list', () async {
      expect(await cubit.hideRoom(cubit.state.rooms.first), isFalse);
      expect(chat.hiddenRooms, isEmpty);
      expect(ids(), contains('cs'));
    });

    test('deleteGroup removes the group for the owner', () async {
      expect(await cubit.deleteGroup(cubit.state.rooms[2]), isTrue);
      expect(chat.deletedGroups, ['g']);
      expect(ids(), ['cs', 'dm']);
    });

    test('a removal from another device drops the room', () async {
      chat.removals.add(const RoomRemoval(roomId: 'g', reason: RoomRemovalReason.groupDeleted));
      await pumpEventQueue();
      expect(ids(), ['cs', 'dm']);
    });

    test('an edited last message updates the preview', () async {
      chat.signals.add(const RoomPreviewEdited('dm', messageId: 'm-1', preview: 'Sudah diedit'));
      await pumpEventQueue();
      expect(cubit.state.rooms[1].lastMessagePreview, 'Sudah diedit');
    });
  });

  group('ChatRoomCubit', () {
    final sentAt = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
    late FakeChatRepository chat;
    late ChatRoomCubit cubit;

    ChatMessage text(String id, {UserSummary sender = me, List<Attachment> attachments = const []}) => ChatMessage(
      id: id,
      roomId: 'dm',
      senderId: sender.id,
      sender: sender,
      body: 'Isi $id',
      attachments: attachments,
      createdAt: sentAt,
    );

    setUp(() async {
      chat = FakeChatRepository(
        rooms: [_room('dm', RoomType.direct)],
        members: directMembers(),
        messages: [
          text('mine'),
          text('theirs', sender: alice),
          text(
            'photo',
            attachments: const [Attachment(path: 'rooms/dm/x.png', mime: 'image/png')],
          ),
        ],
      );
      cubit = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'dm');
      await cubit.load();
    });

    tearDown(() async {
      await cubit.close();
      await chat.dispose();
    });

    ChatMessage byId(String id) => cubit.state.messages.firstWhere((m) => m.id == id);

    test('only own text messages are editable', () {
      expect(cubit.state.canEdit(byId('mine')), isTrue);
      expect(cubit.state.canEdit(byId('theirs')), isFalse);
      expect(cubit.state.canEdit(byId('photo')), isFalse);
      expect(cubit.state.canEdit(byId('mine').copyWith(isDeleted: true)), isFalse);
    });

    test('saveEdit shows the new text at once and keeps it after the server confirms', () async {
      cubit.startEditing(byId('mine'));
      expect(cubit.state.editing?.id, 'mine');
      final pending = cubit.saveEdit('Isi baru');
      expect(byId('mine').body, 'Isi baru');
      expect(await pending, isTrue);
      expect(cubit.state.editing, isNull);
      expect(byId('mine').editedAt, isNotNull);
      expect(chat.edits, [('mine', 'Isi baru')]);
    });

    test('saveEdit rolls back and stays in edit mode when refused', () async {
      chat.editError = const CommunityException(CommunityErrorKind.forbidden, code: 'edit_window_closed');
      cubit.startEditing(byId('mine'));
      expect(await cubit.saveEdit('Terlambat'), isFalse);
      expect(byId('mine').body, 'Isi mine');
      expect(cubit.state.editing?.id, 'mine');
      expect(cubit.state.actionError, isA<CommunityException>());
    });

    test('hideRoom closes the room', () async {
      expect(await cubit.hideRoom(), isTrue);
      expect(chat.hiddenRooms, ['dm']);
      expect(cubit.state.closed, RoomRemovalReason.hidden);
    });

    test('a removal for this room closes it with the actor name', () async {
      chat.removals.add(const RoomRemoval(roomId: 'dm', reason: RoomRemovalReason.groupDeleted, actorName: 'Owen'));
      await pumpEventQueue();
      expect(cubit.state.closed, RoomRemovalReason.groupDeleted);
      expect(cubit.state.closedBy, 'Owen');
    });
  });

  group('editing in the room', () {
    Future<FakeChatRepository> pumpRoom(WidgetTester tester, ChatRoom room, List<ChatMessage> messages) async {
      useScreen(tester, const Size(500, 900));
      final chat = FakeChatRepository(rooms: [room], members: directMembers(), messages: messages);
      addTearDown(chat.dispose);
      await pumpChat(tester, chat, CommunityChatRoom(roomId: room.id));
      return chat;
    }

    TestGesture? mouse;

    Future<void> openActions(WidgetTester tester, String body) async {
      var pointer = mouse;
      if (pointer == null) {
        pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
        mouse = pointer;
        addTearDown(() async {
          await pointer!.removePointer();
          mouse = null;
        });
        await pointer.addPointer(location: Offset.zero);
      }
      await pointer.moveTo(tester.getCenter(find.text(body)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Lainnya').hitTestable());
      await tester.pumpAndSettle();
    }

    final now = DateTime.now().toUtc();

    testWidgets('Edit appears only for own text inside the edit window', (tester) async {
      await pumpRoom(tester, directRoom(), [
        ChatMessage(id: 'a', roomId: 'dm', senderId: me.id, sender: me, body: 'Baru saja', createdAt: now),
        ChatMessage(
          id: 'b',
          roomId: 'dm',
          senderId: me.id,
          sender: me,
          body: 'Sudah lama',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessage(id: 'c', roomId: 'dm', senderId: alice.id, sender: alice, body: 'Dari Alice', createdAt: now),
      ]);

      await openActions(tester, 'Baru saja');
      expect(find.text('Edit'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await openActions(tester, 'Sudah lama');
      expect(find.text('Edit'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await openActions(tester, 'Dari Alice');
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('edit mode fills the composer, Esc cancels', (tester) async {
      await pumpRoom(tester, directRoom(), [
        ChatMessage(id: 'a', roomId: 'dm', senderId: me.id, sender: me, body: 'Teks lama', createdAt: now),
      ]);
      await openActions(tester, 'Teks lama');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Mengedit pesan'), findsOneWidget);
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, 'Teks lama');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Mengedit pesan'), findsNothing);
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isEmpty);
    });

    testWidgets('saving an edit shows the diedit label', (tester) async {
      final chat = await pumpRoom(tester, directRoom(), [
        ChatMessage(id: 'a', roomId: 'dm', senderId: me.id, sender: me, body: 'Teks lama', createdAt: now),
      ]);
      await openActions(tester, 'Teks lama');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'Teks baru');
      await tester.tap(find.byTooltip('Kirim'));
      await tester.pumpAndSettle();

      expect(chat.edits, [('a', 'Teks baru')]);
      expect(find.text('Teks baru'), findsOneWidget);
      expect(find.textContaining('(diedit)'), findsOneWidget);
      expect(find.text('Mengedit pesan'), findsNothing);
    });

    testWidgets('the support room never offers Edit, Hapus chat or Keluar', (tester) async {
      final support = ChatRoom(id: 'cs', type: RoomType.support, name: 'CS', createdAt: now, lastReadAt: now);
      await pumpRoom(tester, support, [
        ChatMessage(id: 'a', roomId: 'cs', senderId: me.id, sender: me, body: 'Tolong bantu', createdAt: now),
      ]);
      final cubit = BlocProvider.of<ChatRoomCubit>(tester.element(find.byType(MessageComposer)));
      expect(cubit.state.canEdit(cubit.state.messages.single), isFalse);
      await openActions(tester, 'Tolong bantu');
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Hapus chat'), findsNothing);
      expect(find.text('Keluar'), findsNothing);
    });
  });
}
