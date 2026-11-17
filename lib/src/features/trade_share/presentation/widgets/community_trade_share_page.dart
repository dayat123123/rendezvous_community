import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_share_settings_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_navigation.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_texts.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/trade_share_parts.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_section_header.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityTradeSharePage extends StatelessWidget {
  const CommunityTradeSharePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.communityL10n.tradeShareTitle)),
    body: const SafeArea(top: false, child: CommunityTradeShareSettings()),
  );
}

class CommunityTradeShareSettings extends StatelessWidget {
  const CommunityTradeShareSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CommunityTradeShareScope.serviceOf(context);
    if (service == null) return const TradeShareUnavailableView();
    return BlocProvider(create: (_) => TradeShareSettingsCubit(service)..load(), child: const _SettingsView());
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TradeShareSettingsCubit, TradeShareSettingsState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<TradeShareSettingsCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return TradeLoadingState(area: CommunityTradeArea.settings);
          case LoadStatus.failure:
            return TradeErrorState(area: CommunityTradeArea.settings, error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            break;
        }
        final data = state.data!;
        if (!data.enabled) return const TradeShareUnavailableView();
        final style = CommunityStyle.of(context);
        final spacing = style.spacing;
        return ListTileTheme(
          data: communitySettingsTileTheme(style),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
              child: CommunityScrollArea(
                child: ListView(
                  padding: EdgeInsets.only(bottom: spacing.xl),
                  children: [
                    _StatusCard(data: data, busy: state.busy),
                    if (data.canApply) _Checks(eligibility: data.eligibility),
                    if (data.canApply || data.canEdit) ...[
                      _Accounts(data: data, draft: state.draft),
                      _Visibility(data: data, draft: state.draft),
                      _Delivery(data: data, draft: state.draft),
                      _Preview(data: data, draft: state.draft),
                    ],
                    if (data.canApply) _Terms(data: data, draft: state.draft),
                    if (data.canApply || data.canEdit) _PrimaryAction(state: state),
                    _Links(data: data),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.data, required this.busy});

  final TradeShareStatus data;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<TradeShareSettingsCubit>();
    final reason = data.decisionReason;
    final cooldown = data.cooldownUntil ?? data.eligibility.cooldownUntil;
    final suspendedUntil = data.suspendedUntil;
    final details = CommunityTradeShareStatusDetails(
      status: data,
      title: l10n.tradeShareTitle,
      label: l10n.tradeStatusLabel(data.status),
      hint: l10n.tradeStatusHint(data),
      icon: style.icons.tradeShare,
      tone: switch (data.status) {
        TradeSharerStatus.active => style.accent,
        TradeSharerStatus.suspended || TradeSharerStatus.rejected || TradeSharerStatus.revoked => style.danger,
        _ => style.textSecondary,
      },
      reason: reason == null ? null : l10n.tradeShareReason(reason),
      suspendedUntil: data.status == TradeSharerStatus.suspended && suspendedUntil != null
          ? l10n.tradeShareSuspendedUntil(l10n.tradeDate(suspendedUntil))
          : null,
      cooldown: data.canApply && cooldown != null && data.inCooldown
          ? l10n.tradeShareCooldown(l10n.tradeDate(cooldown))
          : null,
      intro: data.status == TradeSharerStatus.none ? l10n.tradeShareIntro : null,
      busy: busy,
      pauseLabel: l10n.tradeSharePause,
      resumeLabel: l10n.tradeShareResume,
      withdrawLabel: l10n.tradeShareWithdraw,
      onPause: data.canPause && !busy ? cubit.pause : null,
      onResume: data.canResume && !busy ? cubit.resume : null,
      onWithdraw: data.canWithdraw && !busy
          ? () async {
              final ok = await confirmCommunityAction(
                context,
                l10n.tradeShareWithdrawConfirm,
                confirmLabel: l10n.tradeShareWithdraw,
              );
              if (ok) await cubit.withdraw();
            }
          : null,
    );
    return buildTradeSharePart((b) => b.statusCard, context, details, _DefaultStatusCard(details: details));
  }
}

class _DefaultStatusCard extends StatelessWidget {
  const _DefaultStatusCard({required this.details});

  final CommunityTradeShareStatusDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final data = d.status;
    final notes = [?d.reason, ?d.suspendedUntil, ?d.cooldown, ?d.intro];
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommunityToneIcon(icon: d.icon, tone: d.tone, size: 40),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, style: style.typography.sectionTitle),
                    SizedBox(height: spacing.xxs),
                    TradeStatusPill(label: d.label, tone: d.tone),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(d.hint, style: style.typography.body.copyWith(fontSize: 14)),
          for (final note in notes) ...[SizedBox(height: spacing.xs), Text(note, style: style.typography.meta)],
          if (data.canPause || data.canResume || data.canWithdraw) ...[
            SizedBox(height: spacing.md),
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: [
                if (data.canPause)
                  OutlinedButton(style: style.secondaryButtonStyle(), onPressed: d.onPause, child: Text(d.pauseLabel)),
                if (data.canResume)
                  FilledButton(style: style.primaryButtonStyle(), onPressed: d.onResume, child: Text(d.resumeLabel)),
                if (data.canWithdraw)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: style.danger),
                    onPressed: d.onWithdraw,
                    child: Text(d.withdrawLabel),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Checks extends StatelessWidget {
  const _Checks({required this.eligibility});

  final TradeShareEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunitySectionHeader(title: l10n.tradeShareChecks),
        CommunitySettingsGroup(
          children: [
            for (final check in eligibility.checks)
              _CheckRow(
                details: CommunityTradeShareCheckDetails(
                  check: check,
                  label: l10n.tradeCheckLabel(check.code),
                  hint: check.ok ? null : l10n.tradeCheckHint(check.code, cooldownUntil: eligibility.cooldownUntil),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.details});

  final CommunityTradeShareCheckDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final hint = details.hint;
    return buildTradeSharePart(
      (b) => b.checkRow,
      context,
      details,
      ListTile(
        dense: true,
        leading: Icon(
          details.ok ? Icons.check_circle_outlined : Icons.cancel_outlined,
          color: details.ok ? style.accent : style.danger,
        ),
        title: Text(details.label),
        subtitle: hint == null ? null : Text(hint),
      ),
    );
  }
}

class _Accounts extends StatelessWidget {
  const _Accounts({required this.data, required this.draft});

  final TradeShareStatus data;
  final TradeShareDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<TradeShareSettingsCubit>();
    final known = {for (final account in data.eligibility.accounts) account.custId};
    final accounts = [
      ...data.eligibility.accounts,
      if (data.canEdit)
        for (final account in data.accounts)
          if (!known.contains(account.custId)) account,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunitySectionHeader(title: l10n.tradeShareAccounts, subtitle: l10n.tradeShareAccountsHint),
        CommunitySettingsGroup(
          children: [
            for (final account in accounts)
              CheckboxListTile(
                key: ValueKey('trade-account-${account.custId}'),
                activeColor: style.accent,
                value: draft.accounts.contains(account.custId),
                onChanged: account.isActive || draft.accounts.contains(account.custId)
                    ? (value) => cubit.toggleAccount(account.custId, selected: value ?? false)
                    : null,
                title: Text(account.custId),
                subtitle: Text(l10n.tradeAccountState(account.state)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Visibility extends StatelessWidget {
  const _Visibility({required this.data, required this.draft});

  final TradeShareStatus data;
  final TradeShareDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<TradeShareSettingsCubit>();
    final limits = data.limits;
    return Padding(
      padding: EdgeInsets.only(top: style.spacing.md),
      child: CommunitySettingsGroup(
        children: [
          SwitchListTile(
            key: const ValueKey('trade-show-price'),
            activeTrackColor: style.accent,
            title: Text(l10n.tradeShareShowPrice),
            subtitle: limits.forceHidePrice ? Text(l10n.tradeShareForcedHidden) : null,
            value: !limits.forceHidePrice && draft.showPrice,
            onChanged: limits.forceHidePrice ? null : cubit.setShowPrice,
          ),
          SwitchListTile(
            key: const ValueKey('trade-show-lot'),
            activeTrackColor: style.accent,
            title: Text(l10n.tradeShareShowLot),
            subtitle: Text(limits.forceHideLot ? l10n.tradeShareForcedHidden : l10n.tradeShareShowLotHint),
            value: !limits.forceHideLot && draft.showLot,
            onChanged: limits.forceHideLot ? null : cubit.setShowLot,
          ),
        ],
      ),
    );
  }
}

List<int> tradeDelayOptions(TradeShareLimits limits, int current) {
  final options = <int>{limits.minDelayMinutes, limits.maxDelayMinutes, current};
  for (final minutes in const [15, 30, 45, 60, 90, 120, 180, 240]) {
    if (minutes >= limits.minDelayMinutes && minutes <= limits.maxDelayMinutes) options.add(minutes);
  }
  return options.toList()..sort();
}

class _Delivery extends StatelessWidget {
  const _Delivery({required this.data, required this.draft});

  final TradeShareStatus data;
  final TradeShareDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final cubit = context.read<TradeShareSettingsCubit>();
    final limits = data.limits;
    return Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: CommunitySettingsGroup(
        children: [
          ListTile(
            title: Text(l10n.tradeShareDelay),
            subtitle: Text(l10n.tradeShareDelayHint(limits.minDelayMinutes)),
            trailing: DropdownButton<int>(
              key: const ValueKey('trade-delay'),
              value: draft.delayMinutes,
              underline: const SizedBox.shrink(),
              items: [
                for (final minutes in tradeDelayOptions(limits, draft.delayMinutes))
                  DropdownMenuItem(value: minutes, child: Text(l10n.tradeShareMinutes(minutes))),
              ],
              onChanged: (minutes) {
                if (minutes != null) cubit.setDelay(minutes);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tradeShareSubscribeMode, style: style.typography.body.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: spacing.sm),
                SegmentedButton<TradeSubscribeMode>(
                  key: const ValueKey('trade-subscribe-mode'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: TradeSubscribeMode.auto, label: Text(l10n.tradeShareModeAuto)),
                    ButtonSegment(value: TradeSubscribeMode.approval, label: Text(l10n.tradeShareModeApproval)),
                  ],
                  selected: {draft.subscribeMode},
                  onSelectionChanged: (selected) => cubit.setSubscribeMode(selected.first),
                ),
                if (draft.subscribeMode == TradeSubscribeMode.approval) ...[
                  SizedBox(height: spacing.xs),
                  Text(l10n.tradeShareModeApprovalHint, style: style.typography.meta),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.data, required this.draft});

  final TradeShareStatus data;
  final TradeShareDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final user = CommunityScope.maybeOf(context)?.currentUser;
    final showLot = draft.showLot && !data.limits.forceHideLot;
    final showPrice = draft.showPrice && !data.limits.forceHidePrice;
    final details = CommunityTradeSharePreviewDetails(
      user: user,
      title: l10n.tradeHeadline(user?.name ?? l10n.you, TradeSide.buy, 'BBCA'),
      body: l10n.tradePreviewBody(showLot: showLot, showPrice: showPrice),
      showLot: showLot,
      showPrice: showPrice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunitySectionHeader(title: l10n.tradeSharePreview),
        buildTradeSharePart(
          (b) => b.preview,
          context,
          details,
          TradeNotificationPreview(user: details.user, title: details.title, body: details.body),
        ),
      ],
    );
  }
}

class _Terms extends StatelessWidget {
  const _Terms({required this.data, required this.draft});

  final TradeShareStatus data;
  final TradeShareDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<TradeShareSettingsCubit>();
    final terms = data.eligibility.termsDocument;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunitySectionHeader(
          title: terms?.title.isNotEmpty ?? false ? terms!.title : l10n.tradeShareTerms,
          actionLabel: terms == null ? null : l10n.tradeShareReadTerms,
          onAction: terms == null ? null : () => showTradeShareDocument(context, terms),
        ),
        CheckboxListTile(
          key: const ValueKey('trade-accept-terms'),
          activeColor: style.accent,
          controlAffinity: ListTileControlAffinity.leading,
          value: draft.termsAccepted,
          onChanged: terms == null ? null : (value) => cubit.setTermsAccepted(value ?? false),
          title: Text(l10n.tradeShareAcceptTerms, style: style.typography.body.copyWith(fontSize: 14)),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.state});

  final TradeShareSettingsState state;

  Future<void> _save(BuildContext context) async {
    final l10n = context.communityL10n;
    final cubit = context.read<TradeShareSettingsCubit>();
    var result = await cubit.save();
    if (result == TradeShareSaveResult.confirmationRequired && context.mounted) {
      final ok = await confirmCommunityAction(
        context,
        '${l10n.tradeShareScopeTitle}\n\n${l10n.tradeShareScopeConfirm}',
        confirmLabel: l10n.tradeShareConfirm,
      );
      if (!ok) return;
      result = await cubit.save(confirm: true);
    }
    if (result == TradeShareSaveResult.saved && context.mounted) showCommunityMessage(context, l10n.tradeShareSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final cubit = context.read<TradeShareSettingsCubit>();
    final apply = state.data?.canApply ?? false;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
      child: FilledButton(
        key: const ValueKey('trade-primary-action'),
        style: style.primaryButtonStyle(),
        onPressed: apply
            ? state.canSubmit
                  ? () async {
                      if (await cubit.submit() && context.mounted) {
                        showCommunityMessage(context, l10n.tradeShareSubmitted);
                      }
                    }
                  : null
            : state.canSave
            ? () => _save(context)
            : null,
        child: Text(apply ? l10n.tradeShareSubmit : l10n.tradeShareSave),
      ),
    );
  }
}

class _Links extends StatelessWidget {
  const _Links({required this.data});

  final TradeShareStatus data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return Padding(
      padding: EdgeInsets.only(top: style.spacing.md),
      child: CommunitySettingsGroup(
        children: [
          if (data.isTrader)
            ListTile(
              leading: Icon(style.icons.tradeShare),
              title: Text(l10n.tradeShareMySubscribers),
              subtitle: Text(l10n.tradeShareSubscriberCounts(data.activeSubscribers, data.pendingSubscribers)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openCommunityTradeSubscribers(context, requests: data.pendingSubscribers > 0),
            ),
          ListTile(
            leading: Icon(style.icons.tradeBellActive),
            title: Text(l10n.tradeSubscriptionsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openCommunityTradeSubscriptions(context),
          ),
        ],
      ),
    );
  }
}
