import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_state.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_subscriptions_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_navigation.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_texts.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_share_gate.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/trade_share_parts.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityTradeSubscriptionsPage extends StatelessWidget {
  const CommunityTradeSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.tradeSubscriptionsTitle)),
    body: const SafeArea(top: false, child: CommunityTradeSubscriptions()),
  );
}

class CommunityTradeSubscriptions extends StatelessWidget {
  const CommunityTradeSubscriptions({super.key, this.showActivityLink = true});

  final bool showActivityLink;

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null) return const TradeShareUnavailableView();
    return CommunityTradeShareStatusBuilder(
      builder: (context, status) {
        if (status != null && !status.enabled) return const TradeShareUnavailableView();
        return BlocProvider(
          create: (_) => TradeSubscriptionsCubit(service.repository)..load(),
          child: _SubscriptionsView(showActivityLink: showActivityLink),
        );
      },
    );
  }
}

class _SubscriptionsView extends StatelessWidget {
  const _SubscriptionsView({required this.showActivityLink});

  final bool showActivityLink;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeSubscriptionsCubit, TradeListState<TradeSubscriptionEntry>>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final l10n = context.communityL10n;
        final cubit = context.read<TradeSubscriptionsCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return TradeLoadingState(area: CommunityTradeArea.subscriptions);
          case LoadStatus.failure:
            return TradeErrorState(area: CommunityTradeArea.subscriptions, error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            break;
        }
        final link = showActivityLink
            ? ListTile(
                leading: Icon(CommunityStyle.of(context).icons.tradeShare),
                title: Text(l10n.tradeActivityFeed),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openCommunityTradeActivityFeed(context),
              )
            : null;
        if (state.items.isEmpty) {
          return Column(
            children: [
              ?link,
              Expanded(
                child: TradeEmptyState(
                  area: CommunityTradeArea.subscriptions,
                  message: l10n.tradeSubscriptionsEmpty,
                  icon: CommunityStyle.of(context).icons.tradeBell,
                ),
              ),
            ],
          );
        }
        final offset = link == null ? 0 : 1;
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
                itemCount: state.items.length + offset,
                separatorBuilder: (_, _) => const CommunityDivider(),
                itemBuilder: (context, index) {
                  if (link != null && index == 0) return link;
                  final entry = state.items[index - offset];
                  return _SubscriptionTile(entry: entry, busy: state.busy.contains(entry.trader.id));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.entry, required this.busy});

  final TradeSubscriptionEntry entry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<TradeSubscriptionsCubit>();
    final subscription = entry.subscription;
    final requestedAt = subscription.decidedAt ?? subscription.requestedAt;
    final status = subscription.isPending
        ? l10n.tradeBellPending
        : subscription.muted
        ? l10n.tradeBellMuted
        : l10n.tradeBellActive;
    final subtitle = [
      status,
      if (!entry.sharing) l10n.tradeNotSharingNow,
      if (requestedAt != null && subscription.isActive) l10n.tradeSubscribedSince(l10n.tradeDate(requestedAt)),
    ].join(' · ');
    final details = CommunityTradeSubscriptionTileDetails(
      entry: entry,
      statusLabel: status,
      subtitle: subtitle,
      busy: busy,
      muteLabel: subscription.muted ? l10n.tradeUnmute : l10n.tradeMute,
      cancelLabel: subscription.isPending ? l10n.tradeCancelRequest : l10n.tradeUnsubscribe,
      onOpen: () => CommunityNavigator.openUser(context, entry.trader),
      onToggleMute: subscription.isActive && !busy ? () => cubit.setMuted(entry, muted: !subscription.muted) : null,
      onCancel: () async {
        if (busy) return;
        if (subscription.isActive) {
          final ok = await confirmCommunityAction(
            context,
            l10n.tradeUnsubscribeConfirm(entry.trader.name),
            confirmLabel: l10n.tradeUnsubscribe,
          );
          if (!ok) return;
        }
        await cubit.cancel(entry);
      },
    );
    return buildTradeSharePart((b) => b.subscriptionTile, context, details, _DefaultSubscriptionTile(details: details));
  }
}

class _DefaultSubscriptionTile extends StatelessWidget {
  const _DefaultSubscriptionTile({required this.details});

  final CommunityTradeSubscriptionTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final d = details;
    final id = d.trader.id;
    final toggle = d.onToggleMute;
    return ListTile(
      key: ValueKey('trade-subscription-$id'),
      leading: CommunityAvatar(user: d.trader, radius: 20),
      title: CommunityUserName(user: d.trader, showUsername: false),
      subtitle: Text(d.subtitle, style: style.typography.meta),
      onTap: d.onOpen,
      trailing: d.busy
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (toggle != null)
                  IconButton(
                    key: ValueKey('trade-mute-$id'),
                    tooltip: d.muteLabel,
                    icon: Icon(d.muted ? style.icons.tradeBellMuted : style.icons.tradeBellActive),
                    onPressed: toggle,
                  ),
                IconButton(
                  key: ValueKey('trade-cancel-$id'),
                  tooltip: d.cancelLabel,
                  icon: Icon(style.icons.leave, color: style.danger),
                  onPressed: d.onCancel,
                ),
              ],
            ),
    );
  }
}
