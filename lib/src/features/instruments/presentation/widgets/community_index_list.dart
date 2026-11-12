import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';
import 'package:rendezvous_community/src/features/instruments/domain/services/market_instrument_directory.dart';
import 'package:rendezvous_community/src/features/instruments/presentation/community_instruments.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/presentation/widgets/community_stock_stats.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityIndexList extends StatefulWidget {
  const CommunityIndexList({super.key, this.onOpen, this.showStats = true, this.builders, this.scrollController});

  final void Function(BuildContext context, MarketInstrument instrument)? onOpen;
  final bool showStats;
  final CommunityFeedBuilders? builders;
  final ScrollController? scrollController;

  @override
  State<CommunityIndexList> createState() => _CommunityIndexListState();
}

class _CommunityIndexListState extends State<CommunityIndexList> {
  MarketInstrumentDirectory? _instruments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final instruments = CommunityInstruments.maybeOf(context);
    if (identical(instruments, _instruments)) return;
    _instruments?.removeListener(_changed);
    _instruments = instruments?..addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _instruments?.removeListener(_changed);
    super.dispose();
  }

  void _open(BuildContext context, MarketInstrument instrument) {
    final onOpen = widget.onOpen;
    if (onOpen != null) return onOpen(context, instrument);
    CommunityNavigator.openIndex(context, instrument.code, source: 'stock');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final instruments = _instruments;
    if (instruments == null || (!instruments.loaded && instruments.supported)) {
      return ColoredBox(color: style.surface, child: const CommunityLoadingView());
    }
    final items = instruments.instruments;
    if (items.isEmpty) {
      return ColoredBox(
        color: style.surface,
        child: CommunityEmptyView(message: l10n.indexListEmpty, icon: Icons.insights),
      );
    }
    Widget list(Map<String, StockStats> stats) => ListView.separated(
      addAutomaticKeepAlives: false,
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(vertical: style.spacing.xs),
      itemCount: items.length,
      separatorBuilder: (_, _) => CommunityDivider(indent: style.spacing.lg),
      itemBuilder: (context, index) {
        final item = items[index];
        final stat = stats[item.code];
        final details = CommunityIndexTileDetails(
          instrument: item,
          code: item.code,
          name: item.name,
          kindLabel: l10n.indexLabel,
          postsToday: stat?.postsToday,
          bullishPct: stat?.bullishPct,
          statsLabel: stat == null ? null : l10n.postsToday(stat.postsToday),
          onOpen: () => _open(context, item),
        );
        return KeyedSubtree(
          key: ValueKey(item.code),
          child: buildFeedPart((b) => b.indexTile, context, details, _DefaultIndexTile(details: details)),
        );
      },
    );
    return withFeedBuilders(
      context,
      widget.builders,
      ColoredBox(
        color: style.surface,
        child: widget.showStats
            ? CommunityStockStatsBuilder(
                codes: [for (final item in items) item.code],
                builder: (context, stats) => list(stats),
              )
            : list(const {}),
      ),
    );
  }
}

class _DefaultIndexTile extends StatelessWidget {
  const _DefaultIndexTile({required this.details});

  final CommunityIndexTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final stats = details.statsLabel;
    final bullish = details.bullishPct;
    return InkWell(
      onTap: details.onOpen,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: style.accentMuted, shape: BoxShape.circle),
              child: Icon(Icons.insights, size: 18, color: style.accent),
            ),
            SizedBox(width: spacing.sm + spacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${details.code}', style: style.typography.label),
                  Text(
                    details.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.typography.meta.copyWith(color: style.textSecondary),
                  ),
                ],
              ),
            ),
            if (stats != null) ...[
              SizedBox(width: spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(stats, style: style.typography.meta),
                  if (bullish != null)
                    Text(
                      context.communityL10n.indexBullishPct(bullish),
                      style: style.typography.meta.copyWith(color: style.textSecondary),
                    ),
                ],
              ),
            ],
            SizedBox(width: spacing.xs),
            Icon(Icons.chevron_right, color: style.textSecondary),
          ],
        ),
      ),
    );
  }
}
