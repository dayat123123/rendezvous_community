import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';

class CommunityTradeShare {
  CommunityTradeShare(this.repository, {DateTime Function()? clock, this.maxAge = const Duration(minutes: 5)})
    : _clock = clock ?? DateTime.now;

  final TradeShareRepository repository;
  final Duration maxAge;
  final DateTime Function() _clock;
  final ValueNotifier<TradeShareStatus?> _status = ValueNotifier(null);
  DateTime? _fetchedAt;
  Future<TradeShareStatus>? _pending;
  int _generation = 0;
  bool _disposed = false;
  bool _requested = false;
  String? _owner;

  ValueListenable<TradeShareStatus?> get listenable => _status;

  TradeShareStatus? get current => _status.value;

  bool get enabled => _status.value?.enabled ?? false;

  bool get isFresh {
    final fetchedAt = _fetchedAt;
    return fetchedAt != null && _status.value != null && _clock().difference(fetchedAt) < maxAge;
  }

  Future<TradeShareStatus> status({bool refresh = false}) {
    _requested = true;
    final cached = _status.value;
    if (!refresh && cached != null && isFresh) return Future.value(cached);
    return _pending ??= _load();
  }

  Future<TradeShareStatus?> ensureFresh() async {
    try {
      return await status();
    } catch (e) {
      CommunityLoggers.tradeShare.event(Level.FINE, 'Trade share status unavailable', error: e);
      return _status.value;
    }
  }

  Future<TradeShareStatus> _load() {
    final generation = _generation;
    late final Future<TradeShareStatus> future;
    future = repository
        .status()
        .then((status) {
          if (generation == _generation) accept(status);
          return status;
        })
        .whenComplete(() {
          if (identical(_pending, future)) _pending = null;
        });
    return future;
  }

  void accept(TradeShareStatus status) {
    if (_disposed) return;
    _fetchedAt = _clock();
    final previous = _status.value;
    _status.value = status;
    if (previous?.enabled != status.enabled) {
      CommunityLoggers.tradeShare.event(
        Level.INFO,
        'Trade share availability changed',
        fields: {'enabled': status.enabled},
      );
    }
  }

  void observeEnabled(bool enabled) {
    final current = _status.value;
    if (current == null || current.enabled == enabled) return;
    if (enabled) {
      _fetchedAt = null;
      unawaited(ensureFresh());
    } else {
      accept(current.withEnabled(false));
    }
  }

  Future<void> onResumed() async {
    if (!_requested) return;
    _fetchedAt = null;
    await ensureFresh();
  }

  void onUserChanged(String? userId) {
    final previous = _owner;
    _owner = userId;
    if (previous != null && previous != userId) reset();
  }

  void reset() {
    _requested = false;
    _generation++;
    _pending = null;
    _fetchedAt = null;
    if (!_disposed) _status.value = null;
  }

  void dispose() {
    _disposed = true;
    _generation++;
    _status.dispose();
  }
}
