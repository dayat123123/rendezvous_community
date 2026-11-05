import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_actions.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_builders.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/features/search/presentation/widgets/discovery_tile.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/presentation/cubit/trending_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

enum CommunityTrendingTab { stocks, rising, posts, hashtags }

class CommunityTrending extends StatelessWidget {
  const CommunityTrending({
    super.key,
    this.initialWindow = TrendWindow.day,
    this.initialTab = CommunityTrendingTab.stocks,
    this.tabs = CommunityTrendingTab.values,
    this.builders,
  });

  final TrendWindow initialWindow;
  final CommunityTrendingTab initialTab;
  final List<CommunityTrendingTab> tabs;
  final CommunityDiscoveryBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = CommunityFeatureScope.of(context);
    return withDiscoveryBuilders(
      context,
      builders,
      CommunitySocialGate(
        feature: CommunityFlags.trending,
        child: BlocProvider(
          create: (_) => TrendingCubit(features.trending, feed: deps.feed, window: initialWindow)..load(),
          child: _TrendingView(tabs: tabs, initialTab: tabs.contains(initialTab) ? initialTab : tabs.first),
        ),
      ),
    );
  }
}

class _TrendingView extends StatefulWidget {
  const _TrendingView({required this.tabs, required this.initialTab});

  final List<CommunityTrendingTab> tabs;
  final CommunityTrendingTab initialTab;

  @override
  State<_TrendingView> createState() => _TrendingViewState();
}

class _TrendingViewState extends State<_TrendingView> {
  late CommunityTrendingTab _tab = widget.initialTab;

  String _label(CommunityLocalizations l10n, CommunityTrendingTab tab) => switch (tab) {
    CommunityTrendingTab.stocks => l10n.trendingStocks,
    CommunityTrendingTab.rising => l10n.trendingRising,
    CommunityTrendingTab.posts => l10n.trendingPosts,
    CommunityTrendingTab.hashtags => l10n.searchTabHashtags,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return BlocConsumer<TrendingCubit, TrendingState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<TrendingCubit>();
        final tabs = CommunityTrendingTabsDetails(
          tabs: widget.tabs,
          labels: [for (final tab in widget.tabs) _label(l10n, tab)],
          selected: _tab,
          window: state.window,
          windows: TrendWindow.values,
          windowLabels: [l10n.trendingWindowDay, l10n.trendingWindowWeek],
          onWindowChanged: (window) => cubit.load(window: window),
          onSelect: widget.tabs.length > 1 ? (tab) => setState(() => _tab = tab) : null,
        );
        return ColoredBox(
          color: style.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildDiscoveryPart((b) => b.trendingTabs, context, tabs, _DefaultTrendingTabs(details: tabs)),
                  CommunityDivider(height: style.borderWidth),
                  Expanded(child: _body(context, state, cubit)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, TrendingState state, TrendingCubit cubit) {
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    final snapshot = state.snapshot;
    if (state.status == LoadStatus.failure) {
      return buildDiscoveryPart(
        (b) => b.error,
        context,
        CommunityListErrorDetails(error: state.error!, message: l10n.errorMessage(state.error!), onRetry: cubit.load),
        CommunityErrorView(error: state.error!, onRetry: cubit.load),
      );
    }
    if (snapshot == null || state.status != LoadStatus.ready) {
      return buildDiscoveryPart(
        (b) => b.loading,
        context,
        const CommunityListLoadingDetails(),
        const CommunitySkeleton(itemCount: 4),
      );
    }
    final empty = buildDiscoveryPart(
      (b) => b.empty,
      context,
      CommunityListEmptyDetails(message: l10n.trendingEmpty),
      CommunityEmptyView(message: l10n.trendingEmpty, icon: Icons.trending_up),
    );
    Widget divided(List<Widget> rows) => ListView.separated(
      addAutomaticKeepAlives: false,
      itemCount: rows.length,
      separatorBuilder: (_, _) => CommunityDivider(indent: spacing.lg, endIndent: spacing.lg),
      itemBuilder: (_, index) => rows[index],
    );
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: switch (_tab) {
        CommunityTrendingTab.stocks when snapshot.stocks.isEmpty => _scrollable(empty),
        CommunityTrendingTab.stocks => divided([
          for (final (index, stock) in snapshot.stocks.indexed) _TrendingStockTile(rank: index + 1, stock: stock),
        ]),
        CommunityTrendingTab.rising when snapshot.rising.isEmpty => _scrollable(empty),
        CommunityTrendingTab.rising => divided([
          for (final (index, stock) in snapshot.rising.indexed) _RisingStockTile(rank: index + 1, stock: stock),
        ]),
        CommunityTrendingTab.posts when snapshot.posts.isEmpty => _scrollable(empty),
        CommunityTrendingTab.posts => ColoredBox(
          color: CommunityStyle.of(context).background,
          child: ListView(
            padding: EdgeInsets.only(top: spacing.sm),
            children: [
              for (final post in snapshot.posts)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: PostCard(
                    post: post,
                    source: 'trending',
                    onLike: () => cubit.toggleLike(post),
                    onOpen: () => CommunityNavigator.openPost(context, post.id),
                    onShare: sharePostAction(context, post),
                  ),
                ),
            ],
          ),
        ),
        CommunityTrendingTab.hashtags when snapshot.hashtags.isEmpty => _scrollable(empty),
        CommunityTrendingTab.hashtags => divided([
          for (final (index, hashtag) in snapshot.hashtags.indexed)
            _TrendingHashtagTile(rank: index + 1, hashtag: hashtag),
        ]),
      },
    );
  }

  Widget _scrollable(Widget child) => ListView(children: [SizedBox(height: 240, child: child)]);
}

class _DefaultTrendingTabs extends StatelessWidget {
  const _DefaultTrendingTabs({required this.details});

  final CommunityTrendingTabsDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onSelect = details.onSelect;
    final selectedColor = WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? style.accentMuted : style.surface,
    );
    final foreground = WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? style.accent : style.textSecondary,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
      child: Row(
        spacing: spacing.sm,
        children: [
          SegmentedButton<TrendWindow>(
            showSelectedIcon: false,
            style: ButtonStyle(
              backgroundColor: selectedColor,
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
          if (onSelect != null)
            for (final (index, tab) in details.tabs.indexed)
              ChoiceChip(
                label: Text(details.labels[index]),
                selected: tab == details.selected,
                showCheckmark: false,
                backgroundColor: style.chip,
                selectedColor: style.accentMuted,
                labelStyle: style.typography.label.copyWith(
                  color: tab == details.selected ? style.accent : style.onChip,
                ),
                shape: const StadiumBorder(),
                side: tab == details.selected
                    ? BorderSide(color: style.accent.withValues(alpha: 0.35), width: style.borderWidth)
                    : style.borderSide,
                onSelected: (_) => onSelect(tab),
              ),
        ],
      ),
    );
  }
}

String formatGrowth(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

class _TrendingStockTile extends StatelessWidget {
  const _TrendingStockTile({required this.rank, required this.stock});

  final int rank;
  final TrendingStock stock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final growth = stock.growthPct;
    final details = CommunityTrendingStockDetails(
      kind: CommunityTrendingStockKind.trending,
      rank: rank,
      code: stock.code,
      postsLabel: l10n.trendingPostCount(stock.posts),
      growthLabel: growth != null && growth > 0 ? l10n.trendingGrowth(formatGrowth(growth)) : null,
      bullishPct: stock.bullishPct,
      bearishPct: stock.bearishPct,
      onOpen: () => CommunityNavigator.openStock(context, stock.code, source: 'trending'),
    );
    return buildDiscoveryPart((b) => b.trendingStock, context, details, _DefaultTrendingStock(details: details));
  }
}

class _RisingStockTile extends StatelessWidget {
  const _RisingStockTile({required this.rank, required this.stock});

  final int rank;
  final RisingStock stock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final growth = stock.growthPct;
    final details = CommunityTrendingStockDetails(
      kind: CommunityTrendingStockKind.rising,
      rank: rank,
      code: stock.code,
      postsLabel: l10n.trendingPostCount(stock.posts),
      growthLabel: growth == null ? null : l10n.trendingGrowth(formatGrowth(growth)),
      onOpen: () => CommunityNavigator.openStock(context, stock.code, source: 'trending'),
    );
    return buildDiscoveryPart((b) => b.trendingStock, context, details, _DefaultTrendingStock(details: details));
  }
}

class _DefaultTrendingStock extends StatelessWidget {
  const _DefaultTrendingStock({required this.details});

  final CommunityTrendingStockDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final colors = CommunityTheme.of(context);
    final growth = details.growthLabel;
    final rising = details.kind == CommunityTrendingStockKind.rising;
    return DiscoveryTile(
      leading: DiscoveryIcon(text: '${details.rank}'),
      title: '\$${details.code}',
      subtitle: details.postsLabel,
      footer: !rising && details.hasSentiment
          ? SentimentBar(bullishPct: details.bullishPct ?? 0, bearishPct: details.bearishPct ?? 0, height: 6)
          : null,
      trailing: growth == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rising) ...[
                  Icon(Icons.trending_up, size: 18, color: colors.onBullish),
                  SizedBox(width: style.spacing.xs),
                ],
                Text(growth, style: style.typography.label.copyWith(color: colors.onBullish)),
              ],
            ),
      onTap: details.onOpen,
    );
  }
}

class _TrendingHashtagTile extends StatelessWidget {
  const _TrendingHashtagTile({required this.rank, required this.hashtag});

  final int rank;
  final HashtagSummary hashtag;

  @override
  Widget build(BuildContext context) {
    final details = CommunityHashtagDetails(
      hashtag: hashtag,
      placement: CommunityHashtagPlacement.trending,
      rank: rank,
      countLabel: context.communityL10n.trendingPostCount(hashtag.postCount),
      onOpen: () => CommunityNavigator.openHashtag(context, hashtag.tag),
    );
    return buildDiscoveryPart(
      (b) => b.hashtag,
      context,
      details,
      DiscoveryTile(
        leading: DiscoveryIcon(text: '$rank'),
        title: '#${hashtag.tag}',
        subtitle: details.countLabel,
        onTap: details.onOpen,
      ),
    );
  }
}

class SentimentBar extends StatelessWidget {
  const SentimentBar({super.key, required this.bullishPct, required this.bearishPct, this.height = 10});

  final int bullishPct;
  final int bearishPct;
  final double height;

  @override
  Widget build(BuildContext context) {
    final neutral = (100 - bullishPct - bearishPct).clamp(0, 100);
    final details = CommunitySentimentBarDetails(
      bullishPct: bullishPct,
      bearishPct: bearishPct,
      neutralPct: neutral,
      height: height,
    );
    return buildDiscoveryPart((b) => b.sentimentBar, context, details, _DefaultSentimentBar(details: details));
  }
}

class _DefaultSentimentBar extends StatelessWidget {
  const _DefaultSentimentBar({required this.details});

  final CommunitySentimentBarDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = CommunityTheme.of(context);
    final style = CommunityStyle.of(context);
    final height = details.height;
    return ClipRRect(
      borderRadius: style.radii.pillRadius,
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: style.pill,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (details.bullishPct > 0)
                Expanded(
                  flex: details.bullishPct,
                  child: ColoredBox(color: theme.onBullish),
                ),
              if (details.neutralPct > 0)
                Expanded(
                  flex: details.neutralPct,
                  child: ColoredBox(color: theme.neutral),
                ),
              if (details.bearishPct > 0)
                Expanded(
                  flex: details.bearishPct,
                  child: ColoredBox(color: theme.onBearish),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
