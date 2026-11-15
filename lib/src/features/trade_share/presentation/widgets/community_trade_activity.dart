import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_activity_detail_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_activity_feed_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_state.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_navigation.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_texts.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_share_gate.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/trade_share_parts.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';

class CommunityTradeActivityFeedPage extends StatelessWidget {
  const CommunityTradeActivityFeedPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.tradeActivityFeed)),
    body: const SafeArea(top: false, child: CommunityTradeActivityFeed()),
  );
}

class CommunityTradeActivityFeed extends StatelessWidget {
  const CommunityTradeActivityFeed({super.key, this.onActivityTap});

  final void Function(BuildContext context, TradeActivity activity)? onActivityTap;

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null) return const TradeShareUnavailableView();
    return CommunityTradeShareStatusBuilder(
      builder: (context, status) {
        if (status != null && !status.enabled) return const TradeShareUnavailableView();
        return BlocProvider(
          create: (_) => TradeActivityFeedCubit(service.repository)..load(),
          child: _FeedView(onActivityTap: onActivityTap),
        );
      },
    );
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView({this.onActivityTap});

  final void Function(BuildContext context, TradeActivity activity)? onActivityTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradeActivityFeedCubit, TradeListState<TradeActivity>>(
      builder: (context, state) {
        final l10n = context.communityL10n;
        final cubit = context.read<TradeActivityFeedCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return TradeLoadingState(area: CommunityTradeArea.activityFeed);
          case LoadStatus.failure:
            return TradeErrorState(area: CommunityTradeArea.activityFeed, error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            break;
        }
        if (state.items.isEmpty) {
          return TradeEmptyState(
            area: CommunityTradeArea.activityFeed,
            message: l10n.tradeActivityEmpty,
            icon: CommunityStyle.of(context).icons.tradeShare,
          );
        }
        return NotificationListener<ScrollEndNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) cubit.loadMore();
            return false;
          },
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CommunityScrollArea(
              child: ListView.separated(
                addAutomaticKeepAlives: false,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const CommunityDivider(),
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final activity = state.items[index];
                  return TradeActivityTile(
                    activity: activity,
                    onTap: () {
                      final custom = onActivityTap;
                      if (custom != null) return custom(context, activity);
                      openCommunityTradeActivity(context, activity.id, activity: activity);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class TradeActivityTile extends StatelessWidget {
  const TradeActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
    this.placement = CommunityTradeActivityPlacement.feed,
    this.notification,
    this.fallback,
  });

  final TradeActivity activity;
  final VoidCallback onTap;
  final CommunityTradeActivityPlacement placement;
  final AppNotification? notification;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final text = l10n.tradeActivityText(activity);
    final completedAt = notification?.createdAt ?? activity.completedAt;
    final details = CommunityTradeActivityTileDetails(
      activity: activity,
      placement: placement,
      title: text.title,
      body: text.body,
      timeLabel: completedAt == null ? null : l10n.relativeTime(completedAt),
      notification: notification,
      onTap: onTap,
    );
    return buildTradeSharePart(
      (b) => b.activityTile,
      context,
      details,
      fallback ?? _DefaultActivityTile(details: details),
    );
  }
}

class _DefaultActivityTile extends StatelessWidget {
  const _DefaultActivityTile({required this.details});

  final CommunityTradeActivityTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final time = d.timeLabel;
    return InkWell(
      key: ValueKey('trade-activity-${d.activity.id}'),
      onTap: d.onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityAvatar(user: d.activity.trader, radius: 20),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title, style: style.typography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (d.body.isNotEmpty) ...[SizedBox(height: spacing.xxs), Text(d.body, style: style.typography.meta)],
                  if (time != null) ...[
                    SizedBox(height: spacing.xxs),
                    Text(time, style: style.typography.meta.copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityTradeActivityPage extends StatelessWidget {
  const CommunityTradeActivityPage({super.key, required this.activityId, this.activity});

  final String activityId;
  final TradeActivity? activity;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.tradeActivityTitle)),
    body: SafeArea(
      top: false,
      child: CommunityTradeActivityDetail(activityId: activityId, activity: activity),
    ),
  );
}

class CommunityTradeActivityDetail extends StatelessWidget {
  const CommunityTradeActivityDetail({super.key, required this.activityId, this.activity});

  final String activityId;
  final TradeActivity? activity;

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null) return const TradeShareUnavailableView();
    return BlocProvider(
      create: (_) => TradeActivityDetailCubit(service.repository, activityId: activityId, initial: activity)..load(),
      child: BlocBuilder<TradeActivityDetailCubit, TradeActivityDetailState>(
        builder: (context, state) {
          final cubit = context.read<TradeActivityDetailCubit>();
          final shown = state.activity;
          return switch (state.status) {
            LoadStatus.initial || LoadStatus.loading => TradeLoadingState(area: CommunityTradeArea.activityDetail),
            LoadStatus.failure => TradeErrorState(
              area: CommunityTradeArea.activityDetail,
              error: state.error!,
              onRetry: cubit.load,
            ),
            LoadStatus.ready when shown == null => const TradeShareUnavailableView(),
            LoadStatus.ready => _DetailView(activity: shown!),
          };
        },
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.activity});

  final TradeActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final text = l10n.tradeActivityText(activity);
    final trader = activity.trader;
    final lots = activity.lots;
    final price = activity.price;
    final completedAt = activity.completedAt;
    final volume = lots == null
        ? l10n.tradeActivityHidden
        : l10n.tradeVolume(
            lots,
            orderLots: activity.orderLots,
            partial: activity.partial,
            additional: activity.additional,
          );
    final details = CommunityTradeActivityViewDetails(
      activity: activity,
      title: text.title,
      body: text.body,
      facts: [
        CommunityTradeActivityFact(label: l10n.tradeActivitySide, value: l10n.tradeSideLabel(activity.side)),
        CommunityTradeActivityFact(label: l10n.tradeActivityStock, value: '\$${activity.stock}'),
        CommunityTradeActivityFact(label: l10n.tradeActivityVolume, value: volume),
        CommunityTradeActivityFact(
          label: l10n.tradeActivityPrice,
          value: price == null ? l10n.tradeActivityHidden : l10n.tradeNumber(price),
        ),
        if (completedAt != null)
          CommunityTradeActivityFact(label: l10n.tradeActivityTime, value: l10n.tradeDate(completedAt)),
      ],
      badges: [if (activity.partial) l10n.tradeActivityPartial, if (activity.additional) l10n.tradeActivityAdditional],
      disclaimer: activity.disclaimer(l10n.tradeLanguage) ?? l10n.tradeActivityDisclaimer,
      openStockLabel: l10n.tradeOpenStock(activity.stock),
      onOpenStock: () => CommunityNavigator.openStock(context, activity.stock, source: 'trade_activity'),
      onOpenTrader: trader == null ? null : () => CommunityNavigator.openUser(context, trader),
    );
    return buildTradeSharePart((b) => b.activityDetail, context, details, _DefaultDetailView(details: details));
  }
}

class _DefaultDetailView extends StatelessWidget {
  const _DefaultDetailView({required this.details});

  final CommunityTradeActivityViewDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final trader = d.activity.trader;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
        child: CommunityScrollArea(
          child: ListView(
            padding: EdgeInsets.all(spacing.lg),
            children: [
              if (trader != null)
                InkWell(
                  borderRadius: style.radii.cardRadius,
                  onTap: d.onOpenTrader,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.xs),
                    child: Row(
                      children: [
                        CommunityAvatar(user: trader, radius: 22),
                        SizedBox(width: spacing.md),
                        Expanded(child: CommunityUserName(user: trader)),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: spacing.md),
              Text(d.title, style: style.typography.title.copyWith(fontSize: 20)),
              if (d.body.isNotEmpty) ...[SizedBox(height: spacing.xs), Text(d.body, style: style.typography.body)],
              if (d.badges.isNotEmpty) ...[
                SizedBox(height: spacing.sm),
                Wrap(
                  spacing: spacing.sm,
                  children: [for (final badge in d.badges) TradeStatusPill(label: badge, tone: style.textSecondary)],
                ),
              ],
              SizedBox(height: spacing.lg),
              const CommunityDivider(),
              for (final fact in d.facts)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.sm),
                  child: Row(
                    children: [
                      Expanded(child: Text(fact.label, style: style.typography.meta)),
                      Text(fact.value, style: style.typography.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const CommunityDivider(),
              SizedBox(height: spacing.lg),
              OutlinedButton.icon(
                key: const ValueKey('trade-open-stock'),
                style: style.secondaryButtonStyle(),
                onPressed: d.onOpenStock,
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(d.openStockLabel),
              ),
              SizedBox(height: spacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.cardRadius),
                child: Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: style.textSecondary),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          d.disclaimer,
                          key: const ValueKey('trade-disclaimer'),
                          style: style.typography.meta,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
