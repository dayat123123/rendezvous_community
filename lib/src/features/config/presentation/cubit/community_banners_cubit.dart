import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/domain/services/banner_dismissals.dart';
import 'package:rendezvous_community/src/features/config/domain/services/client_config_service.dart';
import 'package:rendezvous_community/src/features/config/domain/services/community_strip_views.dart';

List<CommunityBanner> visibleBanners(
  List<CommunityBanner> banners, {
  required Set<String> dismissed,
  required DateTime now,
  int? max = 3,
  Set<CommunityBannerLevel>? levels,
}) {
  final active = [
    for (final banner in banners)
      if (!banner.isPopup &&
          (levels == null || levels.contains(banner.level)) &&
          !(banner.dismissible && dismissed.contains(banner.id)) &&
          (banner.endsAt == null || banner.endsAt!.isAfter(now)) &&
          (banner.startsAt == null || !banner.startsAt!.isAfter(now)))
        banner,
  ];
  active.sort((a, b) {
    final priority = b.priority.compareTo(a.priority);
    if (priority != 0) return priority;
    return (b.startsAt ?? DateTime(0)).compareTo(a.startsAt ?? DateTime(0));
  });
  return max == null ? active : active.take(max).toList();
}

class CommunityBannersCubit extends Cubit<List<CommunityBanner>> {
  CommunityBannersCubit(this._config, this._dismissals, {this.maxVisible = 3, this.levels, this._views})
    : _dismissalsReady = _dismissals == null,
      super(const []) {
    _configSub = _config.changes.listen((_) => _update());
    _dismissSub = _dismissals?.changes.listen((_) => _update());
    _views?.addListener(_update);
    _update();
    unawaited(
      _dismissals?.load().then((_) {
        _dismissalsReady = true;
        _update();
      }),
    );
  }

  final ClientConfigService _config;
  final BannerDismissals? _dismissals;
  final CommunityStripViews? _views;
  final int maxVisible;
  final Set<CommunityBannerLevel>? levels;
  final _local = <String>{};
  bool _dismissalsReady;
  late final StreamSubscription<ClientConfig> _configSub;
  StreamSubscription<Set<String>>? _dismissSub;

  Future<void> dismiss(CommunityBanner banner) async {
    if (!banner.dismissible) return;
    _views?.record(banner, CommunityBannerEvent.dismiss);
    _local.add(banner.id);
    _update();
    await _dismissals?.dismiss(banner.id);
  }

  void opened(CommunityBanner banner) => _views?.record(banner, CommunityBannerEvent.click);

  void _update() {
    if (isClosed) return;
    final views = _views;
    if (views != null && !_dismissalsReady) return;
    final config = _config.current;
    final candidates = visibleBanners(
      config.banners,
      dismissed: {..._local, ...?_dismissals?.ids},
      now: config.serverNow(),
      max: views == null ? maxVisible : null,
      levels: levels,
    );
    final shown = views == null ? candidates : views.admit(candidates, max: maxVisible);
    emit(shown);
    views?.viewed(shown);
  }

  @override
  Future<void> close() async {
    _views?.removeListener(_update);
    await _configSub.cancel();
    await _dismissSub?.cancel();
    return super.close();
  }
}
