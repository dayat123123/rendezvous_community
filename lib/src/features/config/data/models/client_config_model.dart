import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';

part 'client_config_model.freezed.dart';
part 'client_config_model.g.dart';

Map<String, bool> _flagsFromJson(Object? value) => {
  if (value is Map)
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value == true,
};

Map<String, String?> _versionsFromJson(Object? value) => {
  if (value is Map)
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value is String ? entry.value as String : null,
};

List<String> _strings(Object? value) => [
  if (value is List)
    for (final item in value)
      if (item is String) item,
];

List<CommunityBanner> bannersFromJson(Object? value) => [
  if (value is List)
    for (final item in value)
      if (item is Map && item['id'] is String && item['title'] is String)
        CommunityBanner(
          id: item['id'] as String,
          title: item['title'] as String,
          body: item['body'] is String ? item['body'] as String : '',
          linkUrl: item['link_url'] is String && (item['link_url'] as String).isNotEmpty
              ? item['link_url'] as String
              : null,
          level: CommunityBannerLevel.values.asNameMap()[item['level']] ?? CommunityBannerLevel.info,
          dismissible: item['dismissible'] != false,
          priority: (item['priority'] as num?)?.toInt() ?? 0,
          startsAt: DateTime.tryParse(item['starts_at'] as String? ?? ''),
          endsAt: DateTime.tryParse(item['ends_at'] as String? ?? ''),
          display: CommunityBannerDisplay.values.asNameMap()[item['display']] ?? CommunityBannerDisplay.strip,
          imageUrl: _imageUrl(item['image_url']),
          imageAspectRatio: _imageRatios[item['image_ratio']],
          ctaLabel: item['cta_label'] is String && (item['cta_label'] as String).trim().isNotEmpty
              ? (item['cta_label'] as String).trim()
              : null,
          frequency: _frequencies[item['frequency']] ?? CommunityBannerFrequency.once,
          seenAt: _time(item['seen_at']),
          dismissedAt: _time(item['dismissed_at']),
        ),
];

const _imageRatios = {'portrait': 4 / 5, 'square': 1.0};

const _frequencies = {
  'once': CommunityBannerFrequency.once,
  'daily': CommunityBannerFrequency.daily,
  'every_open': CommunityBannerFrequency.everyOpen,
};

DateTime? _time(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;

String? _imageUrl(Object? value) {
  if (value is! String) return null;
  final url = value.trim();
  final uri = Uri.tryParse(url);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isEmpty) return null;
  return url;
}

@freezed
abstract class ClientConfigModel with _$ClientConfigModel {
  const factory ClientConfigModel({
    @Default(true) bool socialEnabled,
    @JsonKey(fromJson: _flagsFromJson) @Default(<String, bool>{}) Map<String, bool> flags,
    @JsonKey(fromJson: _versionsFromJson) @Default(<String, String?>{}) Map<String, String?> minVersion,
    @Default(false) bool updateRequired,
    @Default(<String, dynamic>{}) Map<String, dynamic> config,
    @JsonKey(fromJson: bannersFromJson, includeToJson: false)
    @Default(<CommunityBanner>[])
    List<CommunityBanner> banners,
  }) = _ClientConfigModel;

  const ClientConfigModel._();

  factory ClientConfigModel.fromJson(Map<String, dynamic> json) => _$ClientConfigModelFromJson(json);

  ClientConfig toEntity({DateTime? receivedAt}) {
    final received = (receivedAt ?? DateTime.now()).toUtc();
    final serverTime = DateTime.tryParse(config['server_time'] as String? ?? '');
    final reactions = _strings(config['message_reactions']);
    final windows = _strings(config['trending_windows']);
    return ClientConfig(
      socialEnabled: socialEnabled,
      flags: flags,
      minVersions: minVersion,
      updateRequired: updateRequired,
      editWindow: Duration(minutes: (config['edit_minutes'] as num?)?.toInt() ?? 15),
      messageReactions: reactions.isEmpty ? const ClientConfig().messageReactions : reactions,
      searchMinLength: (config['search_min_length'] as num?)?.toInt() ?? 2,
      notificationTypes: _strings(config['notification_types']),
      trendingWindows: windows.isEmpty ? const ClientConfig().trendingWindows : windows,
      notificationAggregateMinutes: (config['notification_aggregate_minutes'] as num?)?.toInt() ?? 60,
      rejoinCooldown: switch (config['account_rejoin_cooldown_hours']) {
        final num hours when hours >= 0 => Duration(minutes: (hours * 60).round()),
        _ => null,
      },
      clockSkew: serverTime == null ? Duration.zero : serverTime.toUtc().difference(received),
      fetchedAt: received,
      banners: banners,
      viewerKnown: config.containsKey('viewer_id'),
      viewerId: config['viewer_id'] is String ? config['viewer_id'] as String : null,
    );
  }
}
