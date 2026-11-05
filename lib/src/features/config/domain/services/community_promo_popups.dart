import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/banner_event_repository.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/promo_popup_history_repository.dart';

bool promoPopupDue(CommunityBanner banner, DateTime? lastShown, DateTime today) {
  if (lastShown == null) return true;
  return switch (banner.frequency) {
    CommunityBannerFrequency.once => false,
    CommunityBannerFrequency.daily => !_sameLocalDay(lastShown, today),
    CommunityBannerFrequency.everyOpen => true,
  };
}

bool _sameLocalDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

bool _ranksBefore(CommunityBanner a, CommunityBanner b) {
  final priority = a.priority.compareTo(b.priority);
  if (priority != 0) return priority > 0;
  return (a.startsAt ?? DateTime(0)).isAfter(b.startsAt ?? DateTime(0));
}

CommunityBanner? selectPromoPopup(
  Iterable<CommunityBanner> banners, {
  required Map<String, DateTime> shown,
  required DateTime now,
  required DateTime today,
}) {
  CommunityBanner? best;
  for (final banner in banners) {
    if (!banner.isPopup) continue;
    final endsAt = banner.endsAt;
    final startsAt = banner.startsAt;
    if (endsAt != null && !endsAt.isAfter(now)) continue;
    if (startsAt != null && startsAt.isAfter(now)) continue;
    if (!promoPopupDue(banner, shown[banner.id], today)) continue;
    if (best == null || _ranksBefore(banner, best)) best = banner;
  }
  return best;
}

class CommunityPromoPopups extends ChangeNotifier {
  CommunityPromoPopups(this._events, this._history, {required this._currentUserId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final BannerEventRepository _events;
  final PromoPopupHistoryRepository _history;
  final String? Function() _currentUserId;
  final DateTime Function() _clock;
  final _shownByUser = <String, Map<String, DateTime>>{};
  final _loading = <String, Future<Map<String, DateTime>>>{};
  String? _sessionUser;
  bool _shown = false;
  bool _disposed = false;

  String? get userId => _currentUserId();

  bool get shownThisSession {
    _sync();
    return _shown;
  }

  void _sync() {
    final user = userId;
    if (user == _sessionUser) return;
    _sessionUser = user;
    _shown = false;
  }

  Future<CommunityBanner?> candidate(ClientConfig config) async {
    _sync();
    final user = _sessionUser;
    if (user == null || _shown || !config.loaded || config.updateRequired) return null;
    if (!config.banners.any((banner) => banner.isPopup)) return null;
    final shown = await _historyFor(user);
    _sync();
    if (_sessionUser != user || _shown) return null;
    return selectPromoPopup(config.banners, shown: shown, now: config.serverNow(), today: _clock());
  }

  bool claim(CommunityBanner banner) {
    _sync();
    final user = _sessionUser;
    if (user == null || _shown || _disposed) return false;
    _shown = true;
    final shown = _shownByUser[user] ??= {};
    shown[banner.id] = _clock();
    unawaited(_save(user, Map.of(shown)));
    record(banner, CommunityBannerEvent.impression);
    return true;
  }

  void record(CommunityBanner banner, CommunityBannerEvent event) {
    if (_disposed) return;
    unawaited(_record(banner.id, event));
  }

  void onUserChanged(String? userId) {
    _sync();
    if (!_disposed) notifyListeners();
  }

  Future<Map<String, DateTime>> _historyFor(String user) async {
    final cached = _shownByUser[user];
    if (cached != null) return cached;
    final loaded = await (_loading[user] ??= _load(user));
    return _shownByUser[user] ??= {...loaded};
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
