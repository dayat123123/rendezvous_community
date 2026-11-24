import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'chat_room.freezed.dart';

enum RoomType { direct, group, stock, support }

enum MemberRole { owner, admin, member }

@freezed
abstract class ChatRoom with _$ChatRoom {
  const factory ChatRoom({
    required String id,
    required RoomType type,
    String? name,
    String? stockCode,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    String? lastMessageSenderId,
    ReceiptStatus? lastMessageStatus,
    required DateTime createdAt,
    @Default(MemberRole.member) MemberRole myRole,
    @Default(false) bool muted,
    required DateTime lastReadAt,
    @Default(0) int unreadCount,
    @Default(0) int memberCount,
    UserSummary? otherUser,
    String? description,
    String? avatarUrl,
    @Default(false) bool onlyAdminsSend,
    @Default(true) bool onlyAdminsEdit,
    DateTime? pinnedAt,
  }) = _ChatRoom;

  const ChatRoom._();

  bool get partnerDeleted => type == RoomType.direct && (otherUser?.isDeleted ?? true);

  DateTime get sortTime => lastMessageAt ?? createdAt;

  bool get tracksReceipts => type != RoomType.stock;

  bool get pinned => type == RoomType.support || pinnedAt != null;

  bool get canPin => type != RoomType.support;

  bool get isGroupAdmin => type == RoomType.group && myRole != MemberRole.member;

  bool get canSend => type != RoomType.group || !onlyAdminsSend || isGroupAdmin;

  bool get canEditGroupInfo => type == RoomType.group && (isGroupAdmin || !onlyAdminsEdit);

  bool get canHide => type != RoomType.support;

  bool get canLeave => type == RoomType.group || type == RoomType.stock;

  bool get canDeleteGroup => type == RoomType.group && myRole == MemberRole.owner;

  int compareListOrder(ChatRoom other) {
    final support = type == RoomType.support;
    if (support != (other.type == RoomType.support)) return support ? -1 : 1;
    final mine = pinnedAt;
    final theirs = other.pinnedAt;
    if ((mine == null) != (theirs == null)) return mine != null ? -1 : 1;
    if (mine != null && theirs != null && mine != theirs) return theirs.compareTo(mine);
    final time = other.sortTime.compareTo(sortTime);
    return time != 0 ? time : other.id.compareTo(id);
  }
}

@freezed
abstract class RoomMember with _$RoomMember {
  const factory RoomMember({
    required UserSummary user,
    @Default(MemberRole.member) MemberRole role,
    required DateTime lastReadAt,
    required DateTime lastDeliveredAt,
    required DateTime joinedAt,
  }) = _RoomMember;

  const RoomMember._();

  MemberReceipt get receipt => MemberReceipt(userId: user.id, lastDeliveredAt: lastDeliveredAt, lastReadAt: lastReadAt);
}
