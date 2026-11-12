import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';
import 'package:rendezvous_community/src/features/instruments/domain/repositories/market_instrument_repository.dart';
import 'package:rendezvous_community/src/features/instruments/domain/services/stock_codes.dart';

class MarketInstrumentDirectory extends ChangeNotifier {
  MarketInstrumentDirectory([this._repository, this.maxAge = const Duration(minutes: 10), DateTime Function()? clock])
    : _clock = clock ?? DateTime.now;

  static final _byRepository = Expando<MarketInstrumentDirectory>();

  static MarketInstrumentDirectory forSource(Object source) =>
      _byRepository[source] ??= MarketInstrumentDirectory(source is MarketInstrumentRepository ? source : null);

  final MarketInstrumentRepository? _repository;
  final Duration maxAge;
  final DateTime Function() _clock;

  List<MarketInstrument> _items = const [];
  Map<String, MarketInstrument> _byCode = const {};
  Map<String, String> _aliases = const {};
  DateTime? _loadedAt;
  DateTime? _failedAt;
  Future<void>? _loading;

  List<MarketInstrument> get instruments => _items;

  bool get supported => _repository != null;

  bool get loaded => _loadedAt != null;

  bool get _stale {
    final now = _clock();
    final failed = _failedAt;
    if (failed != null && now.difference(failed) < const Duration(minutes: 1)) return false;
    final at = _loadedAt;
    return at == null || now.difference(at) > maxAge;
  }

  void ensureLoaded() {
    if (_repository == null || _loading != null || !_stale) return;
    unawaited(load());
  }

  Future<void> load({bool force = false}) {
    final repository = _repository;
    if (repository == null) return Future.value();
    if (!force && !_stale) return Future.value();
    return _loading ??= _fetch(repository).whenComplete(() => _loading = null);
  }

  Future<void> _fetch(MarketInstrumentRepository repository) async {
    try {
      replace(await repository.getMarketInstruments());
    } catch (e) {
      final mapped = mapError(e);
      _failedAt = _clock();
      CommunityLoggers.feed.event(
        Level.WARNING,
        'Failed to load market instruments',
        fields: {'kind': mapped.kind, 'code': mapped.code},
      );
    }
  }

  void replace(List<MarketInstrument> items) {
    final sorted = [...items]
      ..sort((a, b) => a.position != b.position ? a.position.compareTo(b.position) : a.code.compareTo(b.code));
    _items = List.unmodifiable(sorted);
    _byCode = {for (final item in sorted) item.code.toUpperCase(): item};
    _aliases = {
      for (final item in sorted)
        for (final alias in item.aliases) alias.toUpperCase(): item.code.toUpperCase(),
    };
    _loadedAt = _clock();
    _failedAt = null;
    notifyListeners();
  }

  String? canonical(String code) {
    final token = normalizeStockCode(code);
    final alias = _aliases[token];
    if (alias != null) return alias;
    if (_byCode.containsKey(token) || isPlainStockCode(token)) return token;
    return null;
  }

  String canonicalOr(String code) => canonical(code) ?? normalizeStockCode(code);

  MarketInstrument? find(String code) {
    final token = canonical(code);
    return token == null ? null : _byCode[token];
  }

  bool isIndex(String code) => find(code)?.kind == MarketInstrumentKind.stockIndex;

  String? resolveCashtag(String token) => canonical(token);

  List<MarketInstrument> search(String query, {int limit = 6}) {
    final q = normalizeStockCode(query);
    if (q.isEmpty) return const [];
    final lower = query.trim().toLowerCase();
    final scored = <(int, MarketInstrument)>[];
    for (final item in _items) {
      final rank = item.code == q
          ? 0
          : item.code.startsWith(q)
          ? 1
          : item.aliases.any((a) => a.startsWith(q))
          ? 2
          : lower.length >= 2 && item.name.toLowerCase().contains(lower)
          ? 3
          : null;
      if (rank != null) scored.add((rank, item));
    }
    scored.sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.position.compareTo(b.$2.position));
    return [for (final (_, item) in scored.take(limit)) item];
  }
}
