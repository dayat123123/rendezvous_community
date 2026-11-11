import 'dart:typed_data';

import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';

abstract interface class GroupRepository {
  Future<int> addMembers(String roomId, List<String> userIds);

  Future<void> removeMember(String roomId, String userId);

  Future<void> setMemberRole(String roomId, String userId, MemberRole role);

  Future<void> transferOwnership(String roomId, String userId);

  Future<void> updateInfo(String roomId, {String? name, String? description});

  Future<String> uploadPhoto(String roomId, Uint8List bytes, {required String mimeType});

  Future<void> removePhoto(String roomId);

  Future<void> updateSettings(String roomId, {bool? onlyAdminsSend, bool? onlyAdminsEdit});
}
