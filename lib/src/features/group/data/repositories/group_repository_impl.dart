import 'dart:typed_data';

import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/group/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  @override
  Future<int> addMembers(String roomId, List<String> userIds) async {
    final added = await _api.rpcValue('add_room_members', {'p_room_id': roomId, 'p_user_ids': userIds});
    return (added as num?)?.toInt() ?? 0;
  }

  @override
  Future<void> removeMember(String roomId, String userId) =>
      _api.rpcValue('remove_room_member', {'p_room_id': roomId, 'p_user_id': userId});

  @override
  Future<void> setMemberRole(String roomId, String userId, MemberRole role) => _api.rpcValue('set_room_member_role', {
    'p_room_id': roomId,
    'p_user_id': userId,
    'p_role': role == MemberRole.admin ? 'admin' : 'member',
  });

  @override
  Future<void> transferOwnership(String roomId, String userId) =>
      _api.rpcValue('transfer_room_ownership', {'p_room_id': roomId, 'p_user_id': userId});

  @override
  Future<void> updateInfo(String roomId, {String? name, String? description}) =>
      _api.rpcValue('update_group_info', {'p_room_id': roomId, 'p_name': ?name, 'p_description': ?description});

  @override
  Future<String> uploadPhoto(String roomId, Uint8List bytes, {required String mimeType}) async {
    if (mimeType == gifMimeType) {
      throw const CommunityException(CommunityErrorKind.invalidInput, code: 'unsupported_type');
    }
    final me = await _api.requireUserId();
    final path = '$me/group-$roomId-${DateTime.now().millisecondsSinceEpoch}.${imageExtension(mimeType)}';
    final object = await _api.upload(avatarBucket, path, bytes, contentType: mimeType, upsert: true);
    final url = _api.publicUrl(avatarBucket, object.path);
    await _api.rpcValue('update_group_info', {'p_room_id': roomId, 'p_avatar_url': url});
    return url;
  }

  @override
  Future<void> removePhoto(String roomId) =>
      _api.rpcValue('update_group_info', {'p_room_id': roomId, 'p_avatar_url': ''});

  @override
  Future<void> updateSettings(String roomId, {bool? onlyAdminsSend, bool? onlyAdminsEdit}) => _api.rpcValue(
    'update_group_settings',
    {'p_room_id': roomId, 'p_only_admins_send': ?onlyAdminsSend, 'p_only_admins_edit': ?onlyAdminsEdit},
  );
}
