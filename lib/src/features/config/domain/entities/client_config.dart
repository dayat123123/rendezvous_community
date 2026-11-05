import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_config.freezed.dart';

enum CommunityPlatform { android, ios, web, windows, macos, linux }

abstract final class CommunityFlags {
  static const search = 'search';
  static const trending = 'trending';
  static const bookmarks = 'bookmarks';
  static const postEdit = 'post_edit';
  static const messageReactions = 'message_reactions';
  static const sharePostToChat = 'share_post_to_chat';
  static const notificationPrefs = 'notification_prefs';
  static const analytics = 'analytics';

  static const all = [
    search,
    trending,
    bookmarks,
    postEdit,
    messageReactions,
    sharePostToChat,
    notificationPrefs,
    analytics,
  ];
}

@freezed
abstract class ClientConfig with _$ClientConfig {
  const factory ClientConfig({
    @Default(true) bool socialEnabled,
    @Default(<String, bool>{}) Map<String, bool> flags,
    @Default(<String, String?>{}) Map<String, String?> minVersions,
    @Default(false) bool updateRequired,
    @Default(Duration(minutes: 15)) Duration editWindow,
    @Default(<String>['👍', '❤️', '😂', '😮', '😢', '🔥']) List<String> messageReactions,
    @Default(2) int searchMinLength,
    @Default(<String>[]) List<String> notificationTypes,
    @Default(<String>['24h', '7d']) List<String> trendingWindows,
    @Default(60) int notificationAggregateMinutes,
    @Default(Duration.zero) Duration clockSkew,
    @Default(<CommunityBanner>[]) List<CommunityBanner> banners,
    DateTime? fetchedAt,
  }) = _ClientConfig;

  const ClientConfig._();

  bool get loaded => fetchedAt != null;

  bool flag(String key) => flags[key] ?? !loaded;

  bool feature(String key) => socialEnabled && flag(key);

  DateTime serverNow([DateTime? local]) => (local ?? DateTime.now()).toUtc().add(clockSkew);

  bool canEdit(DateTime createdAt, {DateTime? now}) =>
      feature(CommunityFlags.postEdit) && serverNow(now).difference(createdAt.toUtc()) < editWindow;
}

enum CommunityBannerLevel { info, warning, critical }

enum CommunityBannerDisplay { strip, popup }

enum CommunityBannerFrequency { once, daily, everyOpen }

enum CommunityBannerEvent { impression, click, dismiss }

@freezed
abstract class CommunityBanner with _$CommunityBanner {
  const factory CommunityBanner({
    required String id,
    required String title,
    @Default('') String body,
    String? linkUrl,
    @Default(CommunityBannerLevel.info) CommunityBannerLevel level,
    @Default(true) bool dismissible,
    @Default(0) int priority,
    DateTime? startsAt,
    DateTime? endsAt,
    @Default(CommunityBannerDisplay.strip) CommunityBannerDisplay display,
    String? imageUrl,
    String? ctaLabel,
    @Default(CommunityBannerFrequency.once) CommunityBannerFrequency frequency,
  }) = _CommunityBanner;

  const CommunityBanner._();

  bool get isPopup => display == CommunityBannerDisplay.popup;

  Uri? get link {
    final uri = Uri.tryParse(linkUrl ?? '');
    return uri == null || !uri.hasScheme ? null : uri;
  }
}
