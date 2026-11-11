import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:rendezvous_community/src/features/group/domain/repositories/group_repository.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'group_info_cubit.freezed.dart';

@freezed
abstract class GroupInfoState with _$GroupInfoState {
  const factory GroupInfoState({
    @Default(LoadStatus.initial) LoadStatus status,
    ChatRoom? room,
    String? meId,
    @Default(<RoomMember>[]) List<RoomMember> members,
    @Default(false) bool busy,
    @Default(false) bool left,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _GroupInfoState;

  const GroupInfoState._();

  MemberRole get myRole => room?.myRole ?? MemberRole.member;

  bool get isAdmin => room?.isGroupAdmin ?? false;

  bool get canEditInfo => room?.canEditGroupInfo ?? false;

  bool isMe(RoomMember m) => m.user.id == meId;

  bool canPromote(RoomMember m) => isAdmin && !isMe(m) && m.role == MemberRole.member;

  bool canDemote(RoomMember m) => myRole == MemberRole.owner && m.role == MemberRole.admin;

  bool canRemove(RoomMember m) =>
      !isMe(m) &&
      switch (myRole) {
        MemberRole.owner => true,
        MemberRole.admin => m.role == MemberRole.member,
        MemberRole.member => false,
      };

  bool canTransfer(RoomMember m) => myRole == MemberRole.owner && !isMe(m);
}

class GroupInfoCubit extends Cubit<GroupInfoState> {
  GroupInfoCubit({required this._chat, required this._groups, required this.roomId, required this._me})
    : super(const GroupInfoState());

  final ChatRepository _chat;
  final GroupRepository _groups;
  final Future<UserSummary> Function() _me;
  final String roomId;

  Future<void> load() async {
    if (state.status != LoadStatus.ready) emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final me = await _me();
      final results = await Future.wait([_chat.getRoom(roomId), _chat.getMembers(roomId)]);
      if (isClosed) return;
      final room = results[0] as ChatRoom?;
      final members = [...results[1] as List<RoomMember>]..sort((a, b) => _order(a, b, me.id));
      emit(state.copyWith(status: LoadStatus.ready, room: room, meId: me.id, members: members, left: room == null));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  static int _order(RoomMember a, RoomMember b, String meId) {
    if ((a.user.id == meId) != (b.user.id == meId)) return a.user.id == meId ? -1 : 1;
    final role = a.role.index.compareTo(b.role.index);
    return role != 0 ? role : a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase());
  }

  Future<bool> addMembers(List<String> userIds) => _run(() => _groups.addMembers(roomId, userIds));

  Future<bool> removeMember(String userId) => _run(() => _groups.removeMember(roomId, userId));

  Future<bool> setAdmin(String userId, {required bool admin}) =>
      _run(() => _groups.setMemberRole(roomId, userId, admin ? MemberRole.admin : MemberRole.member));

  Future<bool> transferOwnership(String userId) => _run(() => _groups.transferOwnership(roomId, userId));

  Future<bool> updateInfo({required String name, required String description}) {
    final room = state.room;
    return _run(
      () => _groups.updateInfo(
        roomId,
        name: name == room?.name ? null : name,
        description: description == (room?.description ?? '') ? null : description,
      ),
    );
  }

  Future<bool> changePhoto(Uint8List bytes, String mimeType) =>
      _run(() => _groups.uploadPhoto(roomId, bytes, mimeType: mimeType));

  Future<bool> removePhoto() => _run(() => _groups.removePhoto(roomId));

  Future<bool> setOnlyAdminsSend(bool value) => _run(() => _groups.updateSettings(roomId, onlyAdminsSend: value));

  Future<bool> setOnlyAdminsEdit(bool value) => _run(() => _groups.updateSettings(roomId, onlyAdminsEdit: value));

  Future<bool> leave() async {
    emit(state.copyWith(busy: true));
    try {
      await _chat.leaveRoom(roomId);
      if (!isClosed) emit(state.copyWith(busy: false, left: true));
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> _run(Future<Object?> Function() action) async {
    emit(state.copyWith(busy: true));
    try {
      await action();
    } catch (e) {
      _fail(e);
      return false;
    }
    await load();
    if (!isClosed) emit(state.copyWith(busy: false));
    return true;
  }

  void _fail(Object error) {
    if (!isClosed) {
      emit(state.copyWith(busy: false, actionError: error, actionErrorId: state.actionErrorId + 1));
    }
  }
}
