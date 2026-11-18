import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/banner_event_repository.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/promo_popup_history_repository.dart';
import 'package:rendezvous_community/src/features/config/domain/services/community_promo_popups.dart';

class CommunityStripViews extends ChangeNotifier {
  CommunityStripViews(this._events, this._history, {required this._currentUserId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _guest = '';

  final BannerEventRepository _events;
  final PromoPopupHistoryRepository _history;
  final String? Function() _currentUserId;
  final DateTime Function() _clock;
  final _admitted = <String>{};
  final _viewed = <String>{};
  String? _sessionUser;
  Map<String, DateTime>? _shown;
  Future<void>? _loading;
  bool _disposed = false;

  bool get ready {
    _sync();
    return _shown != null;
  }

  void _sync() {
    final user = _currentUserId() ?? _guest;
    if (user == _sessionUser) return;
    _sessionUser = user;
    _admitted.clear();
    _viewed.clear();
    _shown = null;
    _loading = null;
  }

  List<CommunityBanner> admit(Iterable<CommunityBanner> candidates, {required int max}) {
    _sync();
    final shown = _shown;
    if (shown == null) {
      _ensureLoaded();
      return const [];
    }
    final today = _clock();
    final admitted = <CommunityBanner>[];
    var changed = false;
    for (final banner in candidates) {
      if (admitted.length >= max) break;
      if (!_admitted.contains(banner.id)) {
        if (!promoPopupDue(banner, shown[banner.id], today)) continue;
        _admitted.add(banner.id);
        shown[banner.id] = today;
        changed = true;
      }
      admitted.add(banner);
    }
    if (changed) unawaited(_save(_sessionUser!, Map.of(shown)));
    return admitted;
  }

  void viewed(Iterable<CommunityBanner> banners) {
    _sync();
    for (final banner in banners) {
      if (_viewed.add(banner.id)) record(banner, CommunityBannerEvent.impression);
    }
  }

  void record(CommunityBanner banner, CommunityBannerEvent event) {
    if (_disposed || _currentUserId() == null) return;
    unawaited(_record(banner.id, event));
  }

  void onUserChanged(String? userId) {
    _sync();
    if (!_disposed) notifyListeners();
  }

  void _ensureLoaded() {
    if (_loading != null) return;
    final user = _sessionUser!;
    _loading = _load(user).then((loaded) {
      if (_disposed || _sessionUser != user || _shown != null) return;
      _shown = {...loaded};
      notifyListeners();
    });
  }

  Future<Map<String, DateTime>> _load(String user) async {
    try {
      return await _history.load(user);
    } catch (_) {
      return const {};
    }
  }

  Future<void> _save(String user, Map<String, DateTime> shown) async {
    try {
      await _history.save(user, shown);
    } catch (_) {}
  }

  Future<void> _record(String bannerId, CommunityBannerEvent event) async {
    try {
      await _events.record(bannerId, event);
    } catch (error) {
      final mapped = mapError(error);
      CommunityLoggers.config.event(
        Level.FINE,
        'Banner event not recorded',
        fields: {'event': event.name, 'kind': mapped.kind, 'code': mapped.code},
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
