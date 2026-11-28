import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'app_notification.freezed.dart';

enum NotificationType {
  reply,
  mention,
  like,
  follow,
  message,
  announcement,
  appeal,
  followedPost,
  watchlistDigest,
  moderation,
  tradeActivity,
  tradeShare,
  quote,
}

const notificationTypeKeys = {
  NotificationType.followedPost: 'followed_post',
  NotificationType.watchlistDigest: 'watchlist_digest',
  NotificationType.tradeActivity: 'trade_activity',
  NotificationType.tradeShare: 'trade_share',
};

String? notificationCommentRoot(String type, Map<String, Object?> payload, {int eventCount = 1}) {
  String? text(String key) {
    final value = payload[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  final answered = text('parent_id') ?? text('comment_id');
  return switch (type) {
    'like' => text('target_type') == 'comment' ? text('target_id') : null,
    'reply' => eventCount > 1 && text('scope') != 'comment' ? null : answered,
    'mention' => answered,
    _ => null,
  };
}

NotificationType? notificationTypeFromKey(String key) =>
    NotificationType.values.where((t) => (notificationTypeKeys[t] ?? t.name) == key).firstOrNull;

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    UserSummary? actor,
    @Default(<String, Object?>{}) Map<String, Object?> payload,
    @Default(1) int eventCount,
    DateTime? readAt,
    required DateTime createdAt,
    required String cursor,
    @Default(1) int actorCount,
    @Default(<UserSummary>[]) List<UserSummary> actors,
  }) = _AppNotification;

  const AppNotification._();

  bool get isRead => readAt != null;
  String? get postId => payload['post_id'] as String?;
  String? get commentId => payload['comment_id'] as String?;
  String? get roomId => payload['room_id'] as String?;
  String? get snippet => payload['snippet'] as String?;
  String? get targetType => payload['target_type'] as String?;
  String? get reactionEmoji => normalizePostReaction(payload['emoji'] is String ? payload['emoji'] as String : null);
  String? get title => payload['title'] is String ? payload['title'] as String : null;
  String? get body => payload['body'] is String ? payload['body'] as String : null;
  String? get url => payload['url'] as String?;
  String? get appealId => payload['appeal_id'] as String?;
  String? get appealStatus => payload['status'] as String?;
  String? get note => payload['note'] as String?;
  int get otherActors => actorCount > 1 ? actorCount - 1 : 0;
  bool get isOlt => payload['source'] == 'olt';
  String? get noticeId => payload['notice_id'] is String ? payload['notice_id'] as String : null;
  bool get isNotice => noticeId != null;
  String? get oltKind => payload['kind'] is String ? payload['kind'] as String : null;
  String? get oltCategory => payload['category'] is String ? payload['category'] as String : null;
  String? get stockCode => payload['stock_code'] is String ? payload['stock_code'] as String : null;
  List<String> get stocks => _strings(payload['stocks']);
  int get postCount => (payload['post_count'] as num?)?.toInt() ?? 0;
  int get stockCount => (payload['stock_count'] as num?)?.toInt() ?? stocks.length;
  String? get moderationState => payload['state'] is String ? payload['state'] as String : null;
  bool get appealable => payload['appealable'] == true || payload['appealable'] == 'true';
  String? get excerpt => payload['excerpt'] is String ? payload['excerpt'] as String : null;
  bool get isRoomMention => type == NotificationType.mention && roomId != null && postId == null;
  bool get isRoomMute => type == NotificationType.moderation && targetType == 'room';
  DateTime? get muteUntil => payload['until'] is String ? DateTime.tryParse(payload['until'] as String)?.toUtc() : null;
  bool get isTrade => type == NotificationType.tradeActivity || type == NotificationType.tradeShare;
  String? get tradeActivityId => payload['activity_id'] is String ? payload['activity_id'] as String : null;
  String? get tradeAction => payload['action'] is String ? payload['action'] as String : null;
  String? get tradeReason => payload['reason'] is String ? payload['reason'] as String : null;
  String? get tradeTraderId => payload['trader_id'] is String ? payload['trader_id'] as String : null;
  String? get quotePostId => payload['quote_post_id'] is String ? payload['quote_post_id'] as String : null;
  String? get replyScope => payload['scope'] is String ? payload['scope'] as String : null;
  String? get commentRoot =>
      notificationCommentRoot(notificationTypeKeys[type] ?? type.name, payload, eventCount: eventCount);
  List<UserSummary> get knownActors => actors.isNotEmpty ? actors : [?actor];
  int get totalActors => actorCount > knownActors.length ? actorCount : knownActors.length;
  Attachment? get postAttachment => _attachment(payload['post_attachment']);
  String? get imageUrl => _webUrl(payload['image_url']);
  bool get hasImage => postAttachment != null || imageUrl != null;
  String? localizedTitle(String languageCode) => _localizedText(payload['title'], languageCode);
  String? localizedBody(String languageCode) => _localizedText(payload['body'], languageCode);
}

String? _webUrl(Object? value) {
  if (value is! String) return null;
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasAuthority || (uri.scheme != 'https' && uri.scheme != 'http')) return null;
  return value;
}

Attachment? _attachment(Object? value) {
  if (value is! Map || value['path'] is! String) return null;
  return Attachment(
    path: value['path'] as String,
    bucket: value['bucket'] is String ? value['bucket'] as String : null,
    mime: value['mime'] is String ? value['mime'] as String : null,
    width: (value['width'] as num?)?.toInt(),
    height: (value['height'] as num?)?.toInt(),
    thumbnail: value['thumbnail'] is String ? value['thumbnail'] as String : null,
  );
}

List<String> _strings(Object? value) {
  final list = value is String ? _decodeList(value) : value;
  return [
    if (list is List)
      for (final item in list)
        if (item is String && item.isNotEmpty) item,
  ];
}

Object? _decodeList(String value) {
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}

String? _localizedText(Object? value, String languageCode) {
  if (value is String) return value.isEmpty ? null : value;
  if (value is! Map) return null;
  for (final key in [languageCode, 'id', 'en']) {
    final text = value[key];
    if (text is String && text.isNotEmpty) return text;
  }
  return null;
}
