import 'package:rendezvous_community/src/features/chat/domain/entities/room_preview.dart';

abstract interface class RoomPreviewRepository {
  Future<RoomPreviewPage> getRoomPreviews(List<String> roomIds);
}
