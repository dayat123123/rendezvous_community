import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/domain/repositories/trending_repository.dart';

typedef CommunityStockStatsWidgetBuilder = Widget Function(BuildContext context, Map<String, StockStats> stats);

class CommunityStockStatsBuilder extends StatefulWidget {
  const CommunityStockStatsBuilder({
    super.key,
    required this.codes,
    required this.builder,
    this.refreshInterval = const Duration(minutes: 5),
  });

  final List<String> codes;
  final CommunityStockStatsWidgetBuilder builder;
  final Duration refreshInterval;

  @override
  State<CommunityStockStatsBuilder> createState() => _CommunityStockStatsBuilderState();
}

class _CommunityStockStatsBuilderState extends State<CommunityStockStatsBuilder> {
  Map<String, StockStats> _stats = const {};
  Timer? _timer;
  int _request = 0;

  List<String> get _codes =>
      {for (final c in widget.codes) c.trim().toUpperCase()}.where((c) => c.isNotEmpty).toList()..sort();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer == null) _start();
  }

  @override
  void didUpdateWidget(CommunityStockStatsBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = {for (final c in oldWidget.codes) c.trim().toUpperCase()};
    if (!setEquals(before, _codes.toSet()) || oldWidget.refreshInterval != widget.refreshInterval) _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.refreshInterval, (_) => unawaited(_load()));
    unawaited(_load());
  }

  Future<void> _load() async {
    final trending = context.communityFeatures?.trending;
    final codes = _codes;
    if (trending is! TrendingInsightsRepository || codes.isEmpty) {
      if (_stats.isNotEmpty) setState(() => _stats = const {});
      return;
    }
    final request = ++_request;
    try {
      final stats = await (trending as TrendingInsightsRepository).stockStats(codes);
      if (mounted && request == _request) setState(() => _stats = stats);
    } catch (e) {
      final mapped = mapError(e);
      CommunityLoggers.feed.event(
        Level.WARNING,
        'Failed to load stock stats',
        fields: {'codes': codes.length, 'kind': mapped.kind, 'code': mapped.code},
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _stats);
}
