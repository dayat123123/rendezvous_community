import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_builders.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/domain/repositories/trending_repository.dart';
import 'package:rendezvous_community/src/features/trending/presentation/cubit/market_sentiment_cubit.dart';
import 'package:rendezvous_community/src/features/trending/presentation/widgets/community_trending.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Sentiment? marketMood(SentimentBreakdown breakdown) {
  if (!breakdown.hasLabels) return null;
  final bullish = breakdown.bullishPct ?? 0;
  final bearish = breakdown.bearishPct ?? 0;
  if (bullish >= bearish + 10) return Sentiment.bullish;
  if (bearish >= bullish + 10) return Sentiment.bearish;
  return Sentiment.neutral;
}

class CommunityMarketSentiment extends StatelessWidget {
  const CommunityMarketSentiment({
    super.key,
    this.initialWindow = TrendWindow.day,
    this.padding = const EdgeInsets.all(16),
    this.builders,
  });

  final TrendWindow initialWindow;
  final EdgeInsetsGeometry padding;
  final CommunityDiscoveryBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final trending = context.communityFeatures?.trending;
    if (trending is! TrendingInsightsRepository) return const SizedBox.shrink();
    final insights = trending as TrendingInsightsRepository;
    return withDiscoveryBuilders(
      context,
      builders,
      CommunitySocialGate(
        feature: CommunityFlags.trending,
        unavailableBuilder: (_, _, _) => const SizedBox.shrink(),
        child: BlocProvider(
          create: (_) => MarketSentimentCubit(insights, window: initialWindow)..load(),
          child: _MarketSentimentView(padding: padding),
        ),
      ),
    );
  }
}

class _MarketSentimentView extends StatelessWidget {
  const _MarketSentimentView({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocBuilder<MarketSentimentCubit, MarketSentimentState>(
      builder: (context, state) {
        final cubit = context.read<MarketSentimentCubit>();
        final current = state.current;
        final error = state.status == LoadStatus.failure ? state.error : null;
        final mood = current == null ? null : marketMood(current);
        final details = CommunityMarketSentimentDetails(
          title: l10n.marketMoodTitle,
          window: state.window,
          windows: TrendWindow.values,
          windowLabels: [l10n.trendingWindowDay, l10n.trendingWindowWeek],
          loading: current == null && error == null,
          noDataLabel: l10n.sentimentNoData,
          bullishLabel: '${l10n.sentimentBullish} ${current?.bullishPct ?? 0}%',
          neutralLabel: '${l10n.sentimentNeutral} ${current?.neutralPct ?? 0}%',
          bearishLabel: '${l10n.sentimentBearish} ${current?.bearishPct ?? 0}%',
          basedOnLabel: current == null ? null : l10n.sentimentBasedOn(current.posts),
          breakdown: current,
          mood: mood,
          headline: switch (mood) {
            Sentiment.bullish => l10n.marketMoodBullish,
            Sentiment.bearish => l10n.marketMoodBearish,
            Sentiment.neutral => l10n.marketMoodMixed,
            null => null,
          },
          error: error,
          errorMessage: error == null ? null : l10n.errorMessage(error),
          retryLabel: l10n.retry,
          onWindowChanged: cubit.setWindow,
          onRetry: cubit.load,
        );
        return buildDiscoveryPart(
          (b) => b.marketSentiment,
          context,
          details,
          _DefaultMarketSentiment(details: details, padding: padding),
        );
      },
    );
  }
}

class _DefaultMarketSentiment extends StatelessWidget {
  const _DefaultMarketSentiment({required this.details, required this.padding});

  final CommunityMarketSentimentDetails details;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final colors = CommunityTheme.of(context);
    final spacing = style.spacing;
    final breakdown = details.breakdown;
    final errorMessage = details.errorMessage;
    final Widget body;
    if (details.loading) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommunitySkeletonBox(width: 140, height: 24),
          SizedBox(height: spacing.sm),
          CommunitySkeletonBox(width: double.infinity, height: 8, radius: style.radii.pill),
        ],
      );
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
    } else if (breakdown == null || !details.hasData) {
      body = Text(details.noDataLabel, style: style.typography.meta);
    } else {
      final mood = details.mood;
      final tone = switch (mood) {
        Sentiment.bearish => colors.onBearish,
        Sentiment.bullish => colors.onBullish,
        _ => style.textPrimary,
      };
      final lead = mood == Sentiment.bearish ? breakdown.bearishPct ?? 0 : breakdown.bullishPct ?? 0;
      final basedOn = details.basedOnLabel;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                switch (mood) {
                  Sentiment.bearish => Icons.trending_down,
                  Sentiment.bullish => Icons.trending_up,
                  _ => Icons.trending_flat,
                },
                color: tone,
                size: 28,
              ),
              SizedBox(width: spacing.sm),
              Text('$lead%', style: style.typography.title.copyWith(fontSize: 28, height: 1.1, color: tone)),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (details.headline != null)
                      Text(details.headline!, style: style.typography.label.copyWith(color: tone)),
                    if (basedOn != null)
                      Text(basedOn, style: style.typography.badge.copyWith(color: style.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          SentimentBar(bullishPct: breakdown.bullishPct ?? 0, bearishPct: breakdown.bearishPct ?? 0, height: 8),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.md,
            runSpacing: spacing.xxs,
            children: [
              _Legend(color: colors.onBullish, label: details.bullishLabel),
              _Legend(color: colors.neutral, label: details.neutralLabel),
              _Legend(color: colors.onBearish, label: details.bearishLabel),
            ],
          ),
        ],
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(header: true, child: Text(details.title, style: style.typography.sectionTitle)),
              ),
              _WindowToggle(details: details),
            ],
          ),
          SizedBox(height: spacing.md),
          body,
        ],
      ),
    );
  }
}

class _WindowToggle extends StatelessWidget {
  const _WindowToggle({required this.details});

  final CommunityMarketSentimentDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.pillRadius),
      child: Padding(
        padding: EdgeInsets.all(spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, window) in details.windows.indexed)
              Semantics(
                selected: window == details.window,
                button: true,
                child: InkWell(
                  onTap: () => details.onWindowChanged(window),
                  borderRadius: style.radii.pillRadius,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.xs),
                    decoration: BoxDecoration(
                      color: window == details.window ? style.surface : null,
                      borderRadius: style.radii.pillRadius,
                    ),
                    child: Text(
                      details.windowLabels[index],
                      style: style.typography.badge.copyWith(
                        color: window == details.window ? style.textPrimary : style.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 8),
        ),
        SizedBox(width: style.spacing.xs),
        Text(label, style: style.typography.badge.copyWith(color: style.textSecondary)),
      ],
    );
  }
}
