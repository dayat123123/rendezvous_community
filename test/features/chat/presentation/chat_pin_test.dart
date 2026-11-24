import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';

import '../../../support/fakes.dart';

final _t0 = DateTime.utc(2026, 11, 24, 9);

ChatRoom _room(String id, {int minutes = 0, RoomType type = RoomType.direct, DateTime? pinnedAt}) => ChatRoom(
  id: id,
  type: type,
  name: id,
  lastMessageAt: _t0.add(Duration(minutes: minutes)),
  createdAt: _t0,
  lastReadAt: _t0,
  pinnedAt: pinnedAt,
);

class _PinChat extends FakeChatRepository implements RoomPinRepository {
  _PinChat({super.rooms});

  final pinCalls = <(String, bool)>[];
  final pinChanges = StreamController<RoomPinChange>.broadcast();
  Object? pinError;
  Completer<void>? gate;

  @override
  Future<DateTime?> setRoomPinned(String roomId, {required bool pinned}) async {
    pinCalls.add((roomId, pinned));
    await gate?.future;
    final error = pinError;
    if (error != null) throw error;
    return pinned ? _t0.add(const Duration(days: 1)) : null;
  }

  @override
  Stream<RoomPinChange> watchRoomPins() => pinChanges.stream;

  @override
  Future<void> dispose() async {
    await pinChanges.close();
    await super.dispose();
  }
}

List<String> _ids(ChatListCubit cubit) => [for (final r in cubit.state.rooms) r.id];

void main() {
  test('support first, then pins newest first, then the rest by last message', () {
    final rooms = [
      _room('old', minutes: 1),
      _room('pin-a', minutes: -50, pinnedAt: _t0),
      _room('fresh', minutes: 30),
      _room('cs', type: RoomType.support, minutes: -90),
      _room('pin-b', minutes: -60, pinnedAt: _t0.add(const Duration(minutes: 5))),
    ]..sort((a, b) => a.compareListOrder(b));
    expect([for (final r in rooms) r.id], ['cs', 'pin-b', 'pin-a', 'fresh', 'old']);
    expect(rooms[1].pinned, isTrue);
    expect(rooms[3].pinned, isFalse);
    expect(rooms[0].canPin, isFalse);
    expect(rooms[3].canPin, isTrue);
  });

  test('pinned_at is read from the room summary', () {
    final room = RoomSummaryModel.fromJson({
      'id': 'r-1',
      'type': 'direct',
      'created_at': '2026-11-24T09:00:00Z',
      'last_read_at': '2026-11-24T09:00:00Z',
      'pinned_at': '2026-11-24T10:00:00Z',
    }).toEntity();
    expect(room.pinnedAt, DateTime.utc(2026, 11, 24, 10));
    expect(parseRoomPinChange({'room_id': 'r-1', 'pinned_at': null})?.pinnedAt, isNull);
    expect(parseRoomPinChange({'room_id': 'r-1', 'pinned_at': '2026-11-24T10:00:00Z'})?.roomId, 'r-1');
    expect(parseRoomPinChange({'pinned_at': null}), isNull);
  });

  group('chat list', () {
    late _PinChat chat;
    late ChatListCubit cubit;

    setUp(() async {
      chat = _PinChat(
        rooms: [
          _room('cs', type: RoomType.support, minutes: -90),
          _room('a', minutes: 10),
          _room('b', minutes: 5),
          _room('c', minutes: 1),
        ],
      );
      cubit = ChatListCubit(chat: chat, me: () async => me);
      await cubit.load();
    });

    tearDown(() async {
      await cubit.close();
      await chat.dispose();
    });

    test('pinning a chat moves it under support right away', () async {
      chat.gate = Completer<void>();
      final done = cubit.setPinned(cubit.state.rooms.last, pinned: true);
      await pumpEventQueue();
      expect(_ids(cubit), ['cs', 'c', 'a', 'b']);
      chat.gate!.complete();
      expect(await done, isTrue);
      expect(chat.pinCalls, [('c', true)]);
      expect(cubit.state.rooms[1].pinnedAt, _t0.add(const Duration(days: 1)));
    });

    test('a refused pin puts the chat back and reports the error', () async {
      chat.pinError = const CommunityException(CommunityErrorKind.invalidInput, code: 'pin_limit');
      expect(await cubit.setPinned(cubit.state.rooms.last, pinned: true), isFalse);
      expect(_ids(cubit), ['cs', 'a', 'b', 'c']);
      expect(cubit.state.rooms.last.pinnedAt, isNull);
      expect(cubit.state.actionError, chat.pinError);
    });

    test('unpinning returns the chat to its place by time', () async {
      await cubit.setPinned(cubit.state.rooms.last, pinned: true);
      await cubit.setPinned(cubit.state.rooms[1], pinned: false);
      expect(_ids(cubit), ['cs', 'a', 'b', 'c']);
      expect(chat.pinCalls, [('c', true), ('c', false)]);
    });

    test('support chats cannot be pinned or unpinned', () async {
      expect(await cubit.setPinned(cubit.state.rooms.first, pinned: false), isFalse);
      expect(chat.pinCalls, isEmpty);
    });

    test('a pin made on another device reorders the list', () async {
      chat.pinChanges.add(RoomPinChange(roomId: 'b', pinnedAt: _t0));
      await pumpEventQueue();
      expect(_ids(cubit), ['cs', 'b', 'a', 'c']);
      chat.pinChanges.add(const RoomPinChange(roomId: 'b'));
      await pumpEventQueue();
      expect(_ids(cubit), ['cs', 'a', 'b', 'c']);
    });
  });
}
