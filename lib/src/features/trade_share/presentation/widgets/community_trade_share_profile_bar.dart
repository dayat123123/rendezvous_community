import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_share_profile_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_texts.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/trade_share_parts.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityTradeShareProfileBar extends StatelessWidget {
  const CommunityTradeShareProfileBar({super.key, required this.user, this.following, this.padding});

  final UserSummary user;
  final bool? following;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null || user.id.isEmpty) return const SizedBox.shrink();
    return BlocProvider(
      key: ValueKey('trade-share-${user.id}-$following'),
      create: (_) => TradeShareProfileCubit(service, traderId: user.id)..load(),
      child: _ProfileBarView(user: user, padding: padding),
    );
  }
}

enum _BellAction { mute, unmute, cancel }

class _ProfileBarView extends StatelessWidget {
  const _ProfileBarView({required this.user, this.padding});

  final UserSummary user;
  final EdgeInsetsGeometry? padding;

  Future<void> _subscribe(BuildContext context) async {
    final l10n = context.communityL10n;
    final cubit = context.read<TradeShareProfileCubit>();
    final profile = cubit.state.profile;
    final risk = profile?.riskDocument;
    if (profile == null || risk == null) return;
    if (profile.needsRiskConsent) {
      final accepted = await showTradeShareDocument(
        context,
        risk,
        acceptLabel: l10n.tradeRiskAccept,
        confirmLabel: l10n.tradeRiskSubscribe,
      );
      if (!accepted) return;
    }
    final result = await cubit.subscribe();
    final subscription = result?.subscription;
    if (subscription == null || !context.mounted) return;
    showCommunityMessage(context, subscription.isPending ? l10n.tradeRequestSent : l10n.tradeSubscribed(user.name));
  }

  Future<void> _manage(BuildContext context, TradeBellState bell) async {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<TradeShareProfileCubit>();
    final action = await showModalBottomSheet<_BellAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bell == TradeBellState.active)
              ListTile(
                leading: Icon(style.icons.tradeBellMuted),
                title: Text(l10n.tradeMute),
                onTap: () => Navigator.pop(sheetContext, _BellAction.mute),
              ),
            if (bell == TradeBellState.muted)
              ListTile(
                leading: Icon(style.icons.tradeBellActive),
                title: Text(l10n.tradeUnmute),
                onTap: () => Navigator.pop(sheetContext, _BellAction.unmute),
              ),
            ListTile(
              leading: Icon(style.icons.leave, color: style.danger),
              title: Text(
                bell == TradeBellState.pending ? l10n.tradeCancelRequest : l10n.tradeUnsubscribe,
                style: TextStyle(color: style.danger),
              ),
              onTap: () => Navigator.pop(sheetContext, _BellAction.cancel),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _BellAction.mute:
        await cubit.setMuted(true);
      case _BellAction.unmute:
        await cubit.setMuted(false);
      case _BellAction.cancel:
        await _cancel(context, bell);
    }
  }

  Future<void> _cancel(BuildContext context, TradeBellState bell) async {
    final l10n = context.communityL10n;
    final cubit = context.read<TradeShareProfileCubit>();
    if (bell != TradeBellState.pending) {
      final ok = await confirmCommunityAction(
        context,
        l10n.tradeUnsubscribeConfirm(user.name),
        confirmLabel: l10n.tradeUnsubscribe,
      );
      if (!ok) return;
    }
    await cubit.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeShareProfileCubit, TradeShareProfileState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final profile = state.profile;
        final bell = state.bell;
        if (profile == null || bell == TradeBellState.hidden) return const SizedBox.shrink();
        final l10n = context.communityL10n;
        final style = CommunityStyle.of(context);
        final icons = style.icons;
        final (IconData icon, String label) = switch (bell) {
          TradeBellState.subscribe => (icons.tradeBell, l10n.tradeBellSubscribe),
          TradeBellState.pending => (icons.tradePending, l10n.tradeBellPending),
          TradeBellState.active => (icons.tradeBellActive, l10n.tradeBellActive),
          TradeBellState.muted => (icons.tradeBellMuted, l10n.tradeBellMuted),
          TradeBellState.unavailable || TradeBellState.hidden => (icons.tradeBell, l10n.tradeBellUnavailable),
        };
        final VoidCallback? onPressed = state.busy
            ? null
            : switch (bell) {
                TradeBellState.subscribe => () => _subscribe(context),
                TradeBellState.pending || TradeBellState.active || TradeBellState.muted => () => _manage(context, bell),
                TradeBellState.unavailable || TradeBellState.hidden => null,
              };
        final hint = switch (bell) {
          TradeBellState.unavailable => l10n.tradeBlockedReason(profile.blockedReason),
          TradeBellState.active || TradeBellState.muted when !profile.sharing => l10n.tradeNotSharingNow,
          _ => null,
        };
        final cubit = context.read<TradeShareProfileCubit>();
        final idle = !state.busy;
        final details = CommunityTradeProfileBarDetails(
          user: user,
          profile: profile,
          bell: bell,
          badgeLabel: l10n.tradeShareBadge,
          badgeIcon: icons.tradeShare,
          bellLabel: label,
          bellIcon: icon,
          hint: hint,
          busy: state.busy,
          onBell: onPressed,
          onSubscribe: idle && bell == TradeBellState.subscribe ? () => _subscribe(context) : null,
          onMute: idle && bell == TradeBellState.active ? () => cubit.setMuted(true) : null,
          onUnmute: idle && bell == TradeBellState.muted ? () => cubit.setMuted(false) : null,
          onCancel:
              idle && (bell == TradeBellState.pending || bell == TradeBellState.active || bell == TradeBellState.muted)
              ? () => _cancel(context, bell)
              : null,
        );
        return buildTradeSharePart(
          (b) => b.profileBar,
          context,
          details,
          _DefaultProfileBar(details: details, padding: padding),
        );
      },
    );
  }
}

class _DefaultProfileBar extends StatelessWidget {
  const _DefaultProfileBar({required this.details, this.padding});

  final CommunityTradeProfileBarDetails details;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final hint = d.hint;
    final button = d.bell == TradeBellState.active
        ? FilledButton.icon(
            key: const ValueKey('trade-bell'),
            style: style.primaryButtonStyle(),
            onPressed: d.onBell,
            icon: Icon(d.bellIcon, size: 18),
            label: Text(d.bellLabel),
          )
        : OutlinedButton.icon(
            key: const ValueKey('trade-bell'),
            style: style.secondaryButtonStyle(),
            onPressed: d.onBell,
            icon: Icon(d.bellIcon, size: 18),
            label: Text(d.bellLabel),
          );
    return Padding(
      padding: padding ?? EdgeInsets.only(top: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (d.sharing) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TradeStatusPill(label: d.badgeLabel, tone: style.accent, icon: d.badgeIcon),
            ),
            SizedBox(height: spacing.sm),
          ],
          button,
          if (hint != null) ...[SizedBox(height: spacing.xs), Text(hint, style: style.typography.meta)],
        ],
      ),
    );
  }
}
