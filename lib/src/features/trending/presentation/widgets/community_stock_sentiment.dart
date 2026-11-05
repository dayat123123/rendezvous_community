import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_builders.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/presentation/cubit/stock_sentiment_cubit.dart';
import 'package:rendezvous_community/src/features/trending/presentation/widgets/community_trending.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityStockSentiment extends StatelessWidget {
  const CommunityStockSentiment({
    super.key,
    required this.stockCode,
    this.initialWindow = TrendWindow.day,
    this.padding = const EdgeInsets.all(16),
  });

  final String stockCode;
  final TrendWindow initialWindow;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final features = CommunityFeatureScope.of(context);
    return CommunitySocialGate(
      feature: CommunityFlags.trending,
      unavailableBuilder: (_, _, _) => const SizedBox.shrink(),
      child: BlocProvider(
        key: ValueKey(stockCode.toUpperCase()),
        create: (_) =>
            StockSentimentCubit(features.trending, stockCode: stockCode.toUpperCase(), window: initialWindow)..load(),
        child: _SentimentView(padding: padding),
      ),
    );
  }
}

class _SentimentView extends StatelessWidget {
  const _SentimentView({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocBuilder<StockSentimentCubit, StockSentimentState>(
      builder: (context, state) {
        final cubit = context.read<StockSentimentCubit>();
        final current = state.current;
        final error = state.status == LoadStatus.failure ? state.error : null;
        final details = CommunityStockSentimentDetails(
          code: cubit.stockCode,
          title: l10n.sentimentTitle,
          window: state.window,
          windows: TrendWindow.values,
          windowLabels: [l10n.trendingWindowDay, l10n.trendingWindowWeek],
          loading: state.status == LoadStatus.initial || state.status == LoadStatus.loading,
          noDataLabel: l10n.sentimentNoData,
          bullishLabel: '${l10n.sentimentBullish} ${current?.bullishPct ?? 0}%',
          bearishLabel: '${l10n.sentimentBearish} ${current?.bearishPct ?? 0}%',
          basedOnLabel: current == null ? null : l10n.sentimentBasedOn(current.posts),
          breakdown: state.status == LoadStatus.ready ? current : null,
          error: error,
          errorMessage: error == null ? null : l10n.errorMessage(error),
          retryLabel: l10n.retry,
          onWindowChanged: cubit.setWindow,
          onRetry: cubit.load,
        );
        return buildDiscoveryPart(
          (b) => b.stockSentiment,
          context,
          details,
          _DefaultStockSentiment(details: details, padding: padding),
        );
      },
    );
  }
}

class _DefaultStockSentiment extends StatelessWidget {
  const _DefaultStockSentiment({required this.details, required this.padding});

  final CommunityStockSentimentDetails details;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final colors = CommunityTheme.of(context);
    final breakdown = details.breakdown;
    final errorMessage = details.errorMessage;
    final selected = WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? style.accentMuted : style.surface,
    );
    final foreground = WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? style.accent : style.textSecondary,
    );
    final Widget body;
    if (details.loading) {
      body = CommunitySkeletonBox(width: double.infinity, height: 10, radius: style.radii.pill);
    } else if (errorMessage != null) {
      body = Row(
        children: [
          Expanded(child: Text(errorMessage, style: style.typography.meta)),
          TextButton(
            onPressed: details.onRetry,
            style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
            child: Text(details.retryLabel),
          ),
        ],
      );
    } else if (breakdown == null || !breakdown.hasLabels) {
      body = Text(details.noDataLabel, style: style.typography.meta);
    } else {
      final basedOn = details.basedOnLabel;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SentimentBar(bullishPct: breakdown.bullishPct ?? 0, bearishPct: breakdown.bearishPct ?? 0),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Text(details.bullishLabel, style: style.typography.label.copyWith(color: colors.onBullish)),
              const Spacer(),
              if (basedOn != null) Text(basedOn, style: style.typography.badge.copyWith(color: style.textSecondary)),
              const Spacer(),
              Text(details.bearishLabel, style: style.typography.label.copyWith(color: colors.onBearish)),
            ],
          ),
        ],
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(details.title, style: style.typography.sectionTitle)),
              ),
              SegmentedButton<TrendWindow>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: selected,
                  foregroundColor: foreground,
                  textStyle: WidgetStatePropertyAll(style.typography.label),
                  side: WidgetStatePropertyAll(style.borderSide),
                ),
                segments: [
                  for (final (index, window) in details.windows.indexed)
                    ButtonSegment(value: window, label: Text(details.windowLabels[index])),
                ],
                selected: {details.window},
                onSelectionChanged: (s) => details.onWindowChanged(s.first),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          body,
        ],
      ),
    );
  }
}
