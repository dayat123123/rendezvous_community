import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/account_settings_cubit.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
      listenWhen: (a, b) => !a.deleted && b.deleted,
      listener: (context, _) => Navigator.pop(context, true),
      builder: (context, state) {
        final cubit = context.read<AccountSettingsCubit>();
        final error = state.failedAction == AccountAction.delete && !state.deleting ? state.actionError : null;
        return PopScope(
          canPop: !state.deleting,
          child: ValueListenableBuilder(
            valueListenable: _confirmation,
            builder: (context, value, _) {
              final confirmed = value.text.trim() == l10n.accountDeleteWord;
              final details = CommunityDeleteAccountDetails(
                title: l10n.accountDeleteTitle,
                intro: l10n.accountDeleteIntro,
                consequences: [
                  CommunityDeleteConsequence(icon: Icons.visibility_off_outlined, text: l10n.accountDeleteContent),
                  CommunityDeleteConsequence(icon: Icons.inventory_2_outlined, text: l10n.accountDeleteArchive),
                  CommunityDeleteConsequence(icon: Icons.people_outline, text: l10n.accountDeleteRelations),
                  CommunityDeleteConsequence(icon: Icons.support_agent_outlined, text: l10n.accountDeleteSupport),
                  CommunityDeleteConsequence(icon: Icons.account_balance_outlined, text: l10n.accountDeleteTrading),
                  CommunityDeleteConsequence(icon: Icons.person_add_alt_outlined, text: l10n.accountDeleteFresh),
                ],
                controller: _confirmation,
                confirmWord: l10n.accountDeleteWord,
                fieldLabel: l10n.accountDeleteTypeToConfirm(l10n.accountDeleteWord),
                confirmLabel: l10n.accountDeleteConfirm,
                cancelLabel: l10n.cancel,
                progressLabel: l10n.accountDeleteProgress,
                canConfirm: confirmed && !state.deleting,
                deleting: state.deleting,
                error: error,
                errorMessage: error == null ? null : l10n.errorMessage(error),
                onConfirm: confirmed && !state.deleting ? cubit.deleteAccount : null,
                onCancel: state.deleting ? null : () => Navigator.pop(context, false),
              );
              return buildSettingsPart(
                (b) => b.deleteAccountDialog,
                context,
                details,
                DefaultDeleteAccountDialog(details: details),
              );
            },
          ),
        );
      },
    );
  }
}

class DefaultDeleteAccountDialog extends StatelessWidget {
  const DefaultDeleteAccountDialog({super.key, required this.details});

  final CommunityDeleteAccountDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final scheme = Theme.of(context).colorScheme;
    final d = details;
    final errorMessage = d.errorMessage;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      shape: communityDialogShape(style),
      icon: CommunityToneIcon(icon: Icons.delete_forever_outlined, tone: scheme.error, size: 48),
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.intro, style: style.typography.body),
              SizedBox(height: spacing.sm),
              for (final consequence in d.consequences)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(consequence.icon, size: 18, color: style.textSecondary),
                      SizedBox(width: spacing.sm + spacing.xxs),
                      Expanded(child: Text(consequence.text, style: style.typography.body.copyWith(fontSize: 14))),
                    ],
                  ),
                ),
              SizedBox(height: spacing.lg),
              TextField(
                key: const ValueKey('community-delete-confirmation'),
                controller: d.controller,
                enabled: !d.deleting,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                style: style.typography.body,
                decoration: communityFieldDecoration(style, labelText: d.fieldLabel),
              ),
              if (d.deleting) ...[
                SizedBox(height: spacing.md),
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: style.accent),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(child: Text(d.progressLabel, style: style.typography.meta)),
                  ],
                ),
              ],
              if (errorMessage != null) ...[
                SizedBox(height: spacing.md),
                Text(errorMessage, style: style.typography.meta.copyWith(color: scheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
          onPressed: d.onCancel,
          child: Text(d.cancelLabel),
        ),
        FilledButton(
          style: style.primaryButtonStyle().copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled) ? style.pill : scheme.error,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled) ? style.textTertiary : scheme.onError,
            ),
          ),
          onPressed: d.onConfirm,
          child: Text(d.confirmLabel),
        ),
      ],
    );
  }
}
