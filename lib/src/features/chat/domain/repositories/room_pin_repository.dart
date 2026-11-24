import 'package:rendezvous_community/src/features/chat/domain/entities/chat_events.dart';

abstract interface class RoomPinRepository {
  Future<DateTime?> setRoomPinned(String roomId, {required bool pinned});

  Stream<RoomPinChange> watchRoomPins();
}
