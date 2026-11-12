import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';
import '../../../support/mock_api.dart';

class _NoMedia extends Fake implements MediaRepository {}

class _LostChat extends FakeChatRepository {
  _LostChat({super.rooms});

  bool lost = false;

  @override
  Future<Paged<ChatMessage>> getMessages(String roomId, {String? cursor, int limit = 30}) {
    if (lost) throw const CommunityException(CommunityErrorKind.forbidden, code: 'not_member');
    return super.getMessages(roomId, cursor: cursor, limit: limit);
  }
}

ChatRoom _group(String id, {MemberRole role = MemberRole.member, int minutes = 0}) => ChatRoom(
  id: id,
  type: RoomType.group,
  name: 'Grup $id',
  myRole: role,
  lastMessageAt: chatStart.subtract(Duration(minutes: minutes)),
  createdAt: chatStart.subtract(const Duration(days: 1)),
  lastReadAt: chatStart.subtract(const Duration(days: 1)),
);

void main() {
  group('repository', () {
    test('leave, hide and deleteGroup announce a local removal right away', () async {
      final api = mockApi();
      when(() => api.rpcValue(any(), any())).thenAnswer((_) async => null);
      final chat = ChatRepositoryImpl(api);
      addTearDown(chat.dispose);
      final seen = <(String, RoomRemovalReason)>[];
      final sub = chat.watchRoomRemovals().listen((r) => seen.add((r.roomId, r.reason)));
      addTearDown(sub.cancel);

      await chat.leaveRoom('g-1');
      await chat.hideRoom('dm-1');
      await chat.deleteGroup('g-2');
      await pumpEventQueue();

      expect(seen, [
        ('g-1', RoomRemovalReason.left),
        ('dm-1', RoomRemovalReason.hidden),
        ('g-2', RoomRemovalReason.groupDeleted),
      ]);
    });

    test('a failed leave announces nothing', () async {
      final api = mockApi();
      when(() => api.rpcValue('leave_room', any())).thenThrow(Exception('offline'));
      final chat = ChatRepositoryImpl(api);
      addTearDown(chat.dispose);
      final seen = <RoomRemoval>[];
      final sub = chat.watchRoomRemovals().listen(seen.add);
      addTearDown(sub.cancel);

      await expectLater(chat.leaveRoom('g-1'), throwsException);
      await pumpEventQueue();
      expect(seen, isEmpty);
    });
  });

  group('list', () {
    late FakeChatRepository chat;
    late ChatListCubit list;

    setUp(() async {
      chat = FakeChatRepository(
        rooms: [
          _group('g-1', role: MemberRole.owner),
          _group('g-2', minutes: 1),
          _group('g-3', minutes: 2),
        ],
      );
      list = ChatListCubit(chat: chat, me: () async => me);
      await list.load();
    });

    tearDown(() async {
      await list.close();
      await chat.dispose();
    });

    List<String> ids() => [for (final r in list.state.rooms) r.id];

    test('a room left from the open room leaves the list at once', () async {
      final room = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'g-2');
      addTearDown(room.close);
      await room.load();

      expect(await room.leave(), isTrue);
      await pumpEventQueue();

      expect(ids(), ['g-1', 'g-3']);
      expect(room.state.closed, RoomRemovalReason.left);
    });

    test('hide and delete from the open room also leave the list', () async {
      final hidden = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'g-3');
      addTearDown(hidden.close);
      await hidden.load();
      final owner = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'g-1');
      addTearDown(owner.close);
      await owner.load();

      await hidden.hideRoom();
      await owner.deleteGroup();
      await pumpEventQueue();

      expect(ids(), ['g-2']);
    });

    test('a removal for another room does not close the open room', () async {
      final room = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'g-2');
      addTearDown(room.close);
      await room.load();

      await list.leaveRoom(list.state.rooms.last);
      await pumpEventQueue();

      expect(room.state.closed, isNull);
      expect(ids(), ['g-1', 'g-2']);
    });
  });

  group('lost access', () {
    test('load with not_member closes the room as left', () async {
      final chat = _LostChat(rooms: [_group('g-1')])..lost = true;
      addTearDown(chat.dispose);
      final room = ChatRoomCubit(chat: chat, media: _NoMedia(), me: () async => me, roomId: 'g-1');
      addTearDown(room.close);

      await room.load();

      expect(room.state.closed, RoomRemovalReason.left);
      expect(room.state.status, isNot(LoadStatus.failure));
    });

    test('the support room keeps showing the error instead of closing', () async {
      final chat = _LostChat(rooms: [_group('g-1')])..lost = true;
      addTearDown(chat.dispose);
      final room = ChatRoomCubit(
        chat: chat,
        media: _NoMedia(),
        me: () async => me,
        roomId: 'g-1',
        closeOnAccessLoss: false,
      );
      addTearDown(room.close);

      await room.load();

      expect(room.state.closed, isNull);
      expect(room.state.status, LoadStatus.failure);
    });

    testWidgets('the room page calls onClosed and shows the left notice', (tester) async {
      final chat = _LostChat(rooms: [_group('g-1')])..lost = true;
      addTearDown(chat.dispose);
      var closed = 0;
      await pumpChat(tester, chat, CommunityChatRoom(roomId: 'g-1', onClosed: () => closed++));

      expect(closed, 1);
      expect(find.text('Anda sudah keluar dari chat ini.'), findsWidgets);
    });

    testWidgets('a support chat with its own repository is not closed', (tester) async {
      final chat = _LostChat(rooms: [_group('g-1')])..lost = true;
      addTearDown(chat.dispose);
      var closed = 0;
      await pumpChat(tester, chat, CommunityChatRoom(roomId: 'g-1', repository: chat, onClosed: () => closed++));

      expect(closed, 0);
      expect(find.text('Anda sudah keluar dari chat ini.'), findsNothing);
    });

    testWidgets('the error view offers a way back when no app bar does', (tester) async {
      final chat = FakeChatRepository(rooms: [_group('g-1')])..messagesError = Exception('boom');
      addTearDown(chat.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: CommunityLocalizations.localizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: CommunityScope(
                      dependencies: FakeDependencies(chat: chat),
                      child: const CommunityChatRoom(roomId: 'g-1'),
                    ),
                  ),
                ),
              ),
              child: const Text('buka'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('buka'), findsOneWidget);
    });
  });

  group('onRoomTap', () {
    testWidgets('an async host callback is awaited, then the list refreshes', (tester) async {
      final chat = FakeChatRepository(rooms: [_group('g-1'), _group('g-2', minutes: 1)]);
      addTearDown(chat.dispose);
      final done = Completer<void>();
      final opened = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: CommunityLocalizations.localizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Scaffold(
            body: CommunityScope(
              dependencies: FakeDependencies(
                chat: chat,
                callbacks: CommunityCallbacks(
                  onRoomTap: (context, roomId) async {
                    opened.add(roomId);
                    await done.future;
                  },
                ),
              ),
              child: const CommunityChatList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = chat.roomCursors.length;

      await tester.tap(find.text('Grup g-1'));
      await tester.pumpAndSettle();
      expect(opened, ['g-1']);
      expect(chat.roomCursors.length, before);

      chat.rooms = [_group('g-2', minutes: 1)];
      done.complete();
      await tester.pumpAndSettle();

      expect(chat.roomCursors.length, before + 1);
      expect(find.text('Grup g-1'), findsNothing);
    });
  });
}
