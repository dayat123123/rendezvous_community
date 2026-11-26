import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum ShareTargetKind { user, group, stock }

enum ShareTargetReason { dmNotAllowed, cannotSend, groupAdminsOnly, roomDisabled, messageRequest, other }

class ShareLimits {
  const ShareLimits({required this.maxTargets, this.perHour});

  final int maxTargets;
  final int? perHour;
}

class ShareTargetRef {
  const ShareTargetRef.room(String this.roomId) : userId = null, stockCode = null;

  const ShareTargetRef.user(String this.userId) : roomId = null, stockCode = null;

  const ShareTargetRef.stock(String this.stockCode) : roomId = null, userId = null;

  final String? roomId;
  final String? userId;
  final String? stockCode;

  String get key => switch (this) {
    ShareTargetRef(roomId: final id?) => 'room:$id',
    ShareTargetRef(userId: final id?) => 'user:$id',
    ShareTargetRef(stockCode: final code?) => 'stock:${code.trim().toUpperCase()}',
    _ => 'invalid',
  };

  Map<String, Object?> toJson() => switch (this) {
    ShareTargetRef(roomId: final id?) => {'room_id': id},
    ShareTargetRef(userId: final id?) => {'user_id': id},
    ShareTargetRef(stockCode: final code?) => {'stock_code': code.trim().toUpperCase()},
    _ => const {},
  };

  @override
  bool operator ==(Object other) => other is ShareTargetRef && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class ShareTarget {
  const ShareTarget({
    required this.kind,
    this.roomId,
    this.user,
    this.groupName,
    this.stockCode,
    this.canSend = true,
    this.reason,
  });

  final ShareTargetKind kind;
  final String? roomId;
  final UserSummary? user;
  final String? groupName;
  final String? stockCode;
  final bool canSend;
  final ShareTargetReason? reason;

  ShareTargetRef get ref {
    final room = roomId;
    if (room != null) return ShareTargetRef.room(room);
    return switch (kind) {
      ShareTargetKind.user => ShareTargetRef.user(user?.id ?? ''),
      ShareTargetKind.stock => ShareTargetRef.stock(stockCode ?? ''),
      ShareTargetKind.group => const ShareTargetRef.room(''),
    };
  }

  String get title => switch (kind) {
    ShareTargetKind.user => user?.name ?? '',
    ShareTargetKind.group => groupName ?? '',
    ShareTargetKind.stock => '\$${stockCode ?? ''}',
  };
}

class ShareTargetRequest {
  const ShareTargetRequest(this.ref, {required this.clientId});

  final ShareTargetRef ref;
  final String clientId;
}

class ShareDelivery {
  const ShareDelivery({required this.request, required this.sent, this.roomId, this.messageId, this.error});

  final ShareTargetRequest request;
  final bool sent;
  final String? roomId;
  final String? messageId;
  final CommunityException? error;
}
