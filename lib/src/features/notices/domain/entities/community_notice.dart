import 'package:flutter/foundation.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';

@immutable
class CommunityNotice {
  const CommunityNotice({
    required this.id,
    required this.title,
    this.body = '',
    this.level = CommunityBannerLevel.info,
    this.linkUrl,
    this.ctaLabel,
    this.imageUrl,
    this.sentAt,
    this.bannerId,
    this.notificationId,
  });

  factory CommunityNotice.fromJson(Map<String, Object?> json, {String? id, String? notificationId, DateTime? sentAt}) =>
      CommunityNotice(
        id: _text(json['notice_id']) ?? _text(json['id']) ?? id ?? '',
        title: _text(json['title']) ?? '',
        body: _text(json['body']) ?? '',
        level: switch (json['level']) {
          'warning' => CommunityBannerLevel.warning,
          'critical' => CommunityBannerLevel.critical,
          _ => CommunityBannerLevel.info,
        },
        linkUrl: _text(json['link_url']),
        ctaLabel: _text(json['cta_label']),
        imageUrl: _httpUrl(json['image_url']),
        sentAt: _time(json['sent_at']) ?? sentAt,
        bannerId: _text(json['banner_id']),
        notificationId: _text(json['notification_id']) ?? notificationId,
      );

  final String id;
  final String title;
  final String body;
  final CommunityBannerLevel level;
  final String? linkUrl;
  final String? ctaLabel;
  final String? imageUrl;
  final DateTime? sentAt;
  final String? bannerId;
  final String? notificationId;

  Uri? get link {
    final uri = Uri.tryParse(linkUrl ?? '');
    return uri == null || !uri.hasScheme ? null : uri;
  }

  CommunityBanner toBanner() => CommunityBanner(
    id: bannerId ?? id,
    title: title,
    body: body,
    linkUrl: linkUrl,
    level: level,
    ctaLabel: ctaLabel,
    imageUrl: imageUrl,
  );

  @override
  bool operator ==(Object other) =>
      other is CommunityNotice &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.level == level &&
      other.linkUrl == linkUrl &&
      other.ctaLabel == ctaLabel &&
      other.imageUrl == imageUrl &&
      other.sentAt == sentAt &&
      other.bannerId == bannerId &&
      other.notificationId == notificationId;

  @override
  int get hashCode =>
      Object.hash(id, title, body, level, linkUrl, ctaLabel, imageUrl, sentAt, bannerId, notificationId);

  static String? _text(Object? value) => value is String && value.trim().isNotEmpty ? value : null;

  static String? _httpUrl(Object? value) {
    final text = _text(value);
    final uri = text == null ? null : Uri.tryParse(text);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') ? text : null;
  }

  static DateTime? _time(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
