import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_extras.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/share_target.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/stock_room_state.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';

abstract interface class MultiShareRepository {
  Future<ShareLimits> shareLimits();

  Future<List<ShareTarget>> searchShareTargets(String query, {int limit = 20});

  Future<List<ShareDelivery>> sharePostToTargets(String postId, List<ShareTargetRequest> targets, {String? body});
}

abstract interface class ChatExtrasRepository {
  Future<List<MessageReaction>> react(String messageId, String? emoji);

  Future<ChatMessage> sharePost(String roomId, String postId, {String? body, String? clientId});

  Future<StockRoomState> stockRoomState(String stockCode);

  Future<ChatMessage> sendStockCards(String roomId, List<String> codes, {required String clientId, String? body});

  Future<RoomModerationResult> hideMessage(String messageId, ReportReason reason, {String? note});

  Future<RoomModerationResult> muteMember(
    String roomId,
    String userId,
    Duration duration,
    ReportReason reason, {
    String? note,
    String? messageId,
  });

  Future<RoomModerationResult> escalateMessage(String messageId, ReportReason reason, {String? note});
}
