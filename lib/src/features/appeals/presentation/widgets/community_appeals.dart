import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/appeals/domain/entities/appeal.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/cubit/appeal_form_cubit.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/cubit/appeals_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_section_header.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<bool> showCommunityAppealDialog(
  BuildContext context, {
  required AppealTargetType targetType,
  required String targetId,
}) async {
  final features = CommunityFeatureScope.maybeOf(context);
  if (features == null) return false;
  final carry = carryCommunityBuilders(context);
  final created = await showDialog<bool>(
    context: context,
    builder: (_) => carry(
      BlocProvider(
        create: (_) => AppealFormCubit(features.appeals, targetType: targetType, targetId: targetId),
        child: _AppealDialog(targetType: targetType),
      ),
    ),
  );
  if (created == true && context.mounted) showCommunityMessage(context, context.communityL10n.appealSent);
  return created ?? false;
}

class _AppealDialog extends StatefulWidget {
  const _AppealDialog({required this.targetType});

  final AppealTargetType targetType;

  @override
  State<_AppealDialog> createState() => _AppealDialogState();
}

class _AppealDialogState extends State<_AppealDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final appeal = await context.read<AppealFormCubit>().submit(_controller.text);
    if (appeal != null && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocBuilder<AppealFormCubit, AppealFormState>(
      builder: (context, state) {
        final cubit = context.read<AppealFormCubit>();
        final error = state.error;
        final canSubmit = !state.submitting && cubit.isValid(_controller.text);
        final details = CommunityAppealDialogDetails(
          targetType: widget.targetType,
          title: l10n.appealTitle,
          hint: l10n.appealHint,
          controller: _controller,
          maxLength: maxAppealReasonLength,
          canSubmit: canSubmit,
          submitting: state.submitting,
          submitLabel: l10n.appealSubmit,
          cancelLabel: l10n.cancel,
          error: error,
          errorMessage: error == null ? null : l10n.errorMessage(error),
          onSubmit: canSubmit ? _submit : null,
          onCancel: state.submitting ? null : () => Navigator.pop(context, false),
        );
        return buildSettingsPart((b) => b.appealDialog, context, details, DefaultAppealDialog(details: details));
      },
    );
  }
}

class DefaultAppealDialog extends StatelessWidget {
  const DefaultAppealDialog({super.key, required this.details});

  final CommunityAppealDialogDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final errorMessage = d.errorMessage;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      shape: communityDialogShape(style),
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d.hint, style: style.typography.body.copyWith(color: style.textSecondary)),
            SizedBox(height: spacing.md),
            TextField(
              controller: d.controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              maxLength: d.maxLength,
              enabled: !d.submitting,
              style: style.typography.body,
              decoration: communityFieldDecoration(style),
            ),
            if (errorMessage != null)
              Text(errorMessage, style: style.typography.meta.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
          onPressed: d.onCancel,
          child: Text(d.cancelLabel),
        ),
        FilledButton(
          style: style.primaryButtonStyle(),
          onPressed: d.onSubmit,
          child: d.submitting
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
                )
              : Text(d.submitLabel),
        ),
      ],
    );
  }
}

Future<void> openCommunityAppeals(BuildContext context) {
  final features = CommunityFeatureScope.of(context);
  final title = context.communityL10n.myAppeals;
  final carry = carryCommunityBuilders(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => carry(
        CommunityFeatureScope(
          dependencies: features,
          child: Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const SafeArea(top: false, child: CommunityAppeals()),
          ),
        ),
      ),
    ),
  );
}

class CommunityAppeals extends StatelessWidget {
  const CommunityAppeals({super.key});

  @override
  Widget build(BuildContext context) {
    final features = CommunityFeatureScope.of(context);
    return BlocProvider(create: (_) => AppealsCubit(features.appeals)..load(), child: const _AppealsView());
  }
}

class _AppealsView extends StatelessWidget {
  const _AppealsView();

  Future<void> _appeal(BuildContext context, AppealTargetType type, String id) async {
    final created = await showCommunityAppealDialog(context, targetType: type, targetId: id);
    if (created && context.mounted) await context.read<AppealsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    return BlocBuilder<AppealsCubit, AppealsState>(
      builder: (context, state) {
        final cubit = context.read<AppealsCubit>();
        return switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => const CommunitySettingsLoading(
            area: CommunitySettingsArea.appeals,
            fallback: CommunitySkeleton(itemCount: 3),
          ),
          LoadStatus.failure => CommunitySettingsError(
            area: CommunitySettingsArea.appeals,
            error: state.error!,
            onRetry: cubit.load,
            fallback: CommunityErrorView(error: state.error!, onRetry: cubit.load),
          ),
          LoadStatus.ready => ColoredBox(
            color: style.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
                child: CommunityRefresh(
                  onRefresh: cubit.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      CommunitySectionHeader(title: l10n.activeSanctions),
                      CommunitySettingsGroup(
                        children: [
                          if (state.sanctions.isEmpty)
                            CommunitySettingsEmpty(
                              area: CommunitySettingsArea.sanctions,
                              message: l10n.noActiveSanctions,
                            )
                          else
                            for (final sanction in state.sanctions)
                              _AppealTile(
                                details: CommunityAppealTileDetails(
                                  kind: CommunityAppealTileKind.sanction,
                                  icon: Icons.gavel_outlined,
                                  color: scheme.error,
                                  title: _sanctionLabel(l10n, sanction.kind),
                                  subtitle: [
                                    if (sanction.reason != null && sanction.reason!.isNotEmpty) sanction.reason!,
                                    sanction.endsAt == null
                                        ? l10n.sanctionPermanent
                                        : l10n.sanctionUntil(dateFormat.format(sanction.endsAt!.toLocal())),
                                  ].join(' · '),
                                  appealLabel: l10n.appealAction,
                                  sanction: sanction,
                                  onAppeal: state.appealFor(AppealTargetType.sanction, sanction.id) == null
                                      ? () => _appeal(context, AppealTargetType.sanction, sanction.id)
                                      : null,
                                ),
                              ),
                        ],
                      ),
                      CommunitySectionHeader(title: l10n.moderatedContent),
                      CommunitySettingsGroup(
                        children: [
                          if (state.moderated.isEmpty)
                            CommunitySettingsEmpty(
                              area: CommunitySettingsArea.moderatedContent,
                              message: l10n.moderatedContentEmpty,
                            )
                          else
                            for (final item in state.moderated)
                              _AppealTile(
                                details: CommunityAppealTileDetails(
                                  kind: CommunityAppealTileKind.moderatedContent,
                                  icon: item.state == ModeratedState.removed
                                      ? Icons.delete_outline
                                      : Icons.visibility_off_outlined,
                                  color: scheme.error,
                                  title:
                                      '${_targetLabel(l10n, item.type)} · '
                                      '${item.state == ModeratedState.removed ? l10n.moderationRemoved : l10n.moderationHidden}',
                                  subtitle: [
                                    if (item.decidedAt != null) dateFormat.format(item.decidedAt!.toLocal()),
                                    if (item.excerpt != null && item.excerpt!.isNotEmpty) item.excerpt!,
                                    if (item.appeal != null)
                                      '${l10n.appealAction}: ${_statusLabel(l10n, item.appeal!.status)}',
                                  ].join('\n'),
                                  appealLabel: l10n.appealAction,
                                  moderated: item,
                                  appeal: item.appeal,
                                  status: item.appeal?.status,
                                  onAppeal: item.appeal == null ? () => _appeal(context, item.type, item.id) : null,
                                ),
                              ),
                        ],
                      ),
                      CommunitySectionHeader(title: l10n.myAppeals),
                      CommunitySettingsGroup(
                        children: [
                          if (state.appeals.isEmpty)
                            CommunitySettingsEmpty(area: CommunitySettingsArea.myAppeals, message: l10n.myAppealsEmpty)
                          else
                            for (final appeal in state.appeals)
                              _AppealTile(
                                details: CommunityAppealTileDetails(
                                  kind: CommunityAppealTileKind.appeal,
                                  icon: _statusIcon(appeal.status),
                                  color: _statusColor(scheme, appeal.status),
                                  title:
                                      '${_targetLabel(l10n, appeal.targetType)} · ${_statusLabel(l10n, appeal.status)}',
                                  subtitle: [
                                    dateFormat.format(appeal.createdAt.toLocal()),
                                    appeal.reason,
                                    if (appeal.decisionNote != null && appeal.decisionNote!.isNotEmpty)
                                      l10n.appealDecisionNote(appeal.decisionNote!),
                                  ].join('\n'),
                                  appealLabel: l10n.appealAction,
                                  appeal: appeal,
                                  status: appeal.status,
                                ),
                              ),
                        ],
                      ),
                      SizedBox(height: style.spacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        };
      },
    );
  }
}

class _AppealTile extends StatelessWidget {
  const _AppealTile({required this.details});

  final CommunityAppealTileDetails details;

  @override
  Widget build(BuildContext context) =>
      buildSettingsPart((b) => b.appealTile, context, details, _DefaultAppealTile(details: details));
}

class _DefaultAppealTile extends StatelessWidget {
  const _DefaultAppealTile({required this.details});

  final CommunityAppealTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final onAppeal = d.onAppeal;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.sm, spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityToneIcon(icon: d.icon, tone: d.color),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, style: style.typography.author),
                if (d.subtitle.isNotEmpty) ...[
                  SizedBox(height: spacing.xxs),
                  Text(d.subtitle, maxLines: 4, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                ],
              ],
            ),
          ),
          if (onAppeal != null)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
              onPressed: onAppeal,
              child: Text(d.appealLabel),
            )
          else
            SizedBox(width: spacing.sm),
        ],
      ),
    );
  }
}

String _sanctionLabel(CommunityLocalizations l10n, String kind) => switch (kind) {
  'mute' => l10n.sanctionMute,
  'ban' => l10n.sanctionBan,
  _ => l10n.sanctionWarning,
};

String _targetLabel(CommunityLocalizations l10n, AppealTargetType type) => switch (type) {
  AppealTargetType.sanction => l10n.appealTargetSanction,
  AppealTargetType.post => l10n.appealTargetPost,
  AppealTargetType.comment => l10n.appealTargetComment,
  AppealTargetType.message => l10n.appealTargetMessage,
};

String _statusLabel(CommunityLocalizations l10n, AppealStatus status) => switch (status) {
  AppealStatus.pending => l10n.appealStatusPending,
  AppealStatus.accepted => l10n.appealStatusAccepted,
  AppealStatus.rejected => l10n.appealStatusRejected,
};

IconData _statusIcon(AppealStatus status) => switch (status) {
  AppealStatus.pending => Icons.hourglass_top,
  AppealStatus.accepted => Icons.check_circle_outline,
  AppealStatus.rejected => Icons.cancel_outlined,
};

Color _statusColor(ColorScheme scheme, AppealStatus status) => switch (status) {
  AppealStatus.pending => scheme.tertiary,
  AppealStatus.accepted => scheme.primary,
  AppealStatus.rejected => scheme.error,
};
