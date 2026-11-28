import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/network/json_values.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_extras.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/share_target.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/stock_room_state.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_extras_repository.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/post_links/domain/post_link.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class ChatExtrasRepositoryImpl implements ChatExtrasRepository, MultiShareRepository, PostLinkRepository {
  ChatExtrasRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  @override
  Future<List<MessageReaction>> react(String messageId, String? emoji) async {
    final json = jsonMap(await _api.rpcValue('react_to_message', {'p_message_id': messageId, 'p_emoji': emoji}));
    return reactionsFromJson(json['reactions']);
  }

  @override
  Future<ChatMessage> sharePost(String roomId, String postId, {String? body, String? clientId}) async {
    final text = body == null ? null : lowercaseMentions(body.trim());
    final rows = await _api.rpcRows('share_post_to_chat', {
      'p_room_id': roomId,
      'p_post_id': postId,
      'p_body': text == null || text.isEmpty ? null : text,
      'p_client_id': clientId ?? _uuid.v4(),
    });
    if (rows.isEmpty) {
      throw const CommunityException(CommunityErrorKind.unknown, message: 'share_post_to_chat returned no rows');
    }
    return ChatMessageModel.fromJson(rows.first).toEntity();
  }

  @override
  Future<PostLink> postLink(String postId) async {
    final json = jsonMap(await _api.rpcValue('post_share_link', {'p_post_id': postId}));
    final code = json['code'];
    final url = Uri.tryParse(json['url'] as String? ?? '');
    if (code is! String || url == null || !url.hasScheme) {
      throw const CommunityException(CommunityErrorKind.unknown, message: 'post_share_link returned no link');
    }
    final app = json['app_url'];
    return PostLink(code: code, url: url, appUrl: app is String ? Uri.tryParse(app) : null);
  }

  @override
  Future<String?> resolvePostLink(String code) async {
    final id = await _api.rpcValue('resolve_post_share', {'p_code': code});
    return id is String && id.isNotEmpty ? id : null;
  }

  @override
  Future<ShareLimits> shareLimits() async {
    final json = jsonMap(await _api.rpcValue('get_share_limits'));
    return ShareLimits(
      maxTargets: (json['max_targets'] as num?)?.toInt() ?? 10,
      perHour: (json['per_hour'] as num?)?.toInt(),
    );
  }

  @override
  Future<List<ShareTarget>> searchShareTargets(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final rows = await _api.rpcRows('search_share_targets', {'p_query': q, 'p_limit': limit});
    return [for (final row in rows) ?_shareTarget(row)];
  }

  ShareTarget? _shareTarget(Map<String, dynamic> row) {
    final kind = switch (row['kind']) {
      'user' => ShareTargetKind.user,
      'group' => ShareTargetKind.group,
      'stock' => ShareTargetKind.stock,
      _ => null,
    };
    if (kind == null) return null;
    final userId = row['user_id'] as String?;
    return ShareTarget(
      kind: kind,
      roomId: row['room_id'] as String?,
      user: kind == ShareTargetKind.user && userId != null
          ? UserSummary(
              id: userId,
              username: row['username'] as String? ?? '',
              displayName: row['display_name'] as String?,
              avatarUrl: row['avatar_url'] as String?,
              isVerified: row['is_verified'] == true,
              isOfficial: row['is_official'] == true,
            )
          : null,
      groupName: row['group_name'] as String?,
      stockCode: row['stock_code'] as String?,
      canSend: row['can_send'] != false,
      reason: switch (row['reason']) {
        null => null,
        'dm_not_allowed' => ShareTargetReason.dmNotAllowed,
        'cannot_send' => ShareTargetReason.cannotSend,
        'group_admins_only' => ShareTargetReason.groupAdminsOnly,
        'room_disabled' => ShareTargetReason.roomDisabled,
        'message_request' => ShareTargetReason.messageRequest,
        _ => ShareTargetReason.other,
      },
    );
  }

  @override
  Future<List<ShareDelivery>> sharePostToTargets(
    String postId,
    List<ShareTargetRequest> targets, {
    String? body,
  }) async {
    final text = body == null ? null : lowercaseMentions(body.trim());
    final rows = await _api.rpcRows('share_post_to_targets', {
      'p_post_id': postId,
      'p_targets': [
        for (final target in targets) {...target.ref.toJson(), 'client_id': target.clientId},
      ],
      'p_body': text == null || text.isEmpty ? null : text,
    });
    return [
      for (final row in rows)
        if (row['target_index'] case final num index when index >= 0 && index < targets.length)
          ShareDelivery(
            request: targets[index.toInt()],
            sent: row['status'] == 'sent',
            roomId: row['room_id'] as String?,
            messageId: row['message_id'] as String?,
            error: row['status'] == 'sent' ? null : _shareError(row['error_code'] as String?),
          ),
    ];
  }

  CommunityException _shareError(String? code) => CommunityException(switch (code) {
    'rate_limited' => CommunityErrorKind.rateLimited,
    'blocked' ||
    'dm_not_allowed' ||
    'official_no_dm' ||
    'not_member' ||
    'group_admins_only' ||
    'share_not_allowed' ||
    'user_muted' => CommunityErrorKind.forbidden,
    'user_not_found' || 'post_not_found' => CommunityErrorKind.notFound,
    'content_blocked' => CommunityErrorKind.contentBlocked,
    null => CommunityErrorKind.unknown,
    _ => CommunityErrorKind.invalidInput,
  }, code: code);

  @override
  Future<ChatMessage> sendStockCards(
    String roomId,
    List<String> codes, {
    required String clientId,
    String? body,
  }) async {
    final rows = await _api.rpcRows('send_message', {
      'p_room_id': roomId,
      'p_body': lowercaseMentions(body?.trim() ?? ''),
      'p_client_id': clientId,
      'p_reply_to_id': null,
      'p_attachments': [
        for (final code in codes) {'type': 'stock', 'code': code},
      ],
    });
    if (rows.isEmpty) {
      throw const CommunityException(CommunityErrorKind.unknown, message: 'send_message returned no rows');
    }
    return ChatMessageModel.fromJson(rows.first).toEntity();
  }

  @override
  Future<StockRoomState> stockRoomState(String stockCode) async =>
      parseStockRoomState(jsonMap(await _api.rpcValue('get_stock_room_state', {'p_code': stockCode.toUpperCase()})));

  @override
  Future<RoomModerationResult> hideMessage(String messageId, ReportReason reason, {String? note}) async =>
      parseRoomModerationResult(
        jsonMap(
          await _api.rpcValue('room_mod_hide_message', {
            'p_message_id': messageId,
            'p_reason': reason.wireName,
            'p_note': _note(note),
          }),
        ),
      );

  @override
  Future<RoomModerationResult> muteMember(
    String roomId,
    String userId,
    Duration duration,
    ReportReason reason, {
    String? note,
    String? messageId,
  }) async => parseRoomModerationResult(
    jsonMap(
      await _api.rpcValue('room_mod_mute_user', {
        'p_room_id': roomId,
        'p_user_id': userId,
        'p_minutes': duration.inMinutes,
        'p_reason': reason.wireName,
        'p_note': _note(note),
        'p_message_id': messageId,
      }),
    ),
  );

  @override
  Future<RoomModerationResult> escalateMessage(String messageId, ReportReason reason, {String? note}) async =>
      parseRoomModerationResult(
        jsonMap(
          await _api.rpcValue('room_mod_escalate', {
            'p_message_id': messageId,
            'p_reason': reason.wireName,
            'p_note': _note(note),
          }),
        ),
      );

  static String? _note(String? note) {
    final text = note?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
