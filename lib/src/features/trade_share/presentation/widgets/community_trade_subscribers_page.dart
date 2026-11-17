import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_state.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_subscribers_cubit.dart';
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

class CommunityTradeSubscribersPage extends StatelessWidget {
  const CommunityTradeSubscribersPage({super.key, this.initialRequests = false});

  final bool initialRequests;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.tradeSubscribersTitle)),
    body: SafeArea(top: false, child: CommunityTradeSubscribers(initialRequests: initialRequests)),
  );
}

class CommunityTradeSubscribers extends StatefulWidget {
  const CommunityTradeSubscribers({super.key, this.initialRequests = false});

  final bool initialRequests;

  @override
  State<CommunityTradeSubscribers> createState() => _CommunityTradeSubscribersState();
}

class _CommunityTradeSubscribersState extends State<CommunityTradeSubscribers> {
  late TradeSubscriberStatus _tab = widget.initialRequests
      ? TradeSubscriberStatus.pending
      : TradeSubscriberStatus.active;

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null) return const TradeShareUnavailableView();
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return CommunityTradeShareStatusBuilder(
      builder: (context, status) {
        if (status != null && !status.enabled) return const TradeShareUnavailableView();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.sm),
              child: Wrap(
                spacing: spacing.sm,
                children: [
                  for (final tab in TradeSubscriberStatus.values)
                    ChoiceChip(
                      key: ValueKey('trade-subscribers-${tab.name}'),
                      selected: _tab == tab,
                      label: Text(
                        tab == TradeSubscriberStatus.active
                            ? l10n.tradeSubscribersActive
                            : l10n.tradeSubscribersRequests,
                      ),
                      onSelected: (_) => setState(() => _tab = tab),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _SubscriberList(key: ValueKey(_tab), repository: service.repository, status: _tab),
            ),
          ],
        );
      },
    );
  }
}

class _SubscriberList extends StatelessWidget {
  const _SubscriberList({super.key, required this.repository, required this.status});

  final TradeShareRepository repository;
  final TradeSubscriberStatus status;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => TradeSubscribersCubit(repository, status: status)..load(),
    child: BlocConsumer<TradeSubscribersCubit, TradeListState<TradeSubscriberEntry>>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final l10n = context.communityL10n;
        final cubit = context.read<TradeSubscribersCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return TradeLoadingState(area: CommunityTradeArea.subscribers);
          case LoadStatus.failure:
            return TradeErrorState(area: CommunityTradeArea.subscribers, error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            break;
        }
        if (state.items.isEmpty) {
          return TradeEmptyState(
            area: CommunityTradeArea.subscribers,
            message: status == TradeSubscriberStatus.pending ? l10n.tradeRequestsEmpty : l10n.tradeSubscribersEmpty,
            icon: CommunityStyle.of(context).icons.tradeBell,
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
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const CommunityDivider(),
                itemBuilder: (context, index) {
                  final entry = state.items[index];
                  return _SubscriberTile(entry: entry, busy: state.busy.contains(entry.subscriber.id));
                },
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _SubscriberTile extends StatelessWidget {
  const _SubscriberTile({required this.entry, required this.busy});

  final TradeSubscriberEntry entry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<TradeSubscribersCubit>();
    final pending = entry.status == TradeSubscriptionStatus.pending;
    final expiresAt = entry.expiresAt;
    final since = entry.decidedAt ?? entry.requestedAt;
    final idle = !busy;
    final details = CommunityTradeSubscriberTileDetails(
      entry: entry,
      subtitle: pending
          ? (expiresAt == null ? null : l10n.tradeRequestExpires(l10n.tradeDate(expiresAt)))
          : (since == null ? null : l10n.tradeSubscribedSince(l10n.tradeDate(since))),
      busy: busy,
      approveLabel: l10n.tradeApprove,
      declineLabel: l10n.tradeDecline,
      removeLabel: l10n.tradeRemoveSubscriber,
      onOpen: () => CommunityNavigator.openUser(context, entry.subscriber),
      onApprove: pending && idle ? () => cubit.decide(entry, approve: true) : null,
      onDecline: pending && idle ? () => cubit.decide(entry, approve: false) : null,
      onRemove: !pending && idle
          ? () async {
              final ok = await confirmCommunityAction(
                context,
                l10n.tradeRemoveSubscriberConfirm(entry.subscriber.name),
                confirmLabel: l10n.tradeRemoveSubscriber,
              );
              if (ok) await cubit.remove(entry);
            }
          : null,
    );
    return buildTradeSharePart((b) => b.subscriberTile, context, details, _DefaultSubscriberTile(details: details));
  }
}

class _DefaultSubscriberTile extends StatelessWidget {
  const _DefaultSubscriberTile({required this.details});

  final CommunityTradeSubscriberTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final d = details;
    final id = d.subscriber.id;
    final subtitle = d.subtitle;
    return ListTile(
      key: ValueKey('trade-subscriber-$id'),
      leading: CommunityAvatar(user: d.subscriber, radius: 20),
      title: CommunityUserName(user: d.subscriber, showUsername: false),
      subtitle: subtitle == null ? null : Text(subtitle, style: style.typography.meta),
      onTap: d.onOpen,
      trailing: d.busy
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : d.pending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(key: ValueKey('trade-decline-$id'), onPressed: d.onDecline, child: Text(d.declineLabel)),
                FilledButton(
                  key: ValueKey('trade-approve-$id'),
                  style: style.primaryButtonStyle(),
                  onPressed: d.onApprove,
                  child: Text(d.approveLabel),
                ),
              ],
            )
          : TextButton(
              key: ValueKey('trade-remove-$id'),
              style: TextButton.styleFrom(foregroundColor: style.danger),
              onPressed: d.onRemove,
              child: Text(d.removeLabel),
            ),
    );
  }
}
