import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

Future<bool> showReportDialog(BuildContext context, {required ReportTarget target, required String targetId}) async {
  final deps = CommunityScope.of(context);
  final carry = carryCommunityBuilders(context);
  final sent = await showDialog<bool>(
    context: context,
    builder: (context) => carry(
      CommunityScope(
        dependencies: deps,
        child: _ReportDialog(target: target, targetId: targetId),
      ),
    ),
  );
  if ((sent ?? false) && context.mounted) showCommunityMessage(context, context.communityL10n.reportSent);
  return sent ?? false;
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.target, required this.targetId});

  final ReportTarget target;
  final String targetId;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  static const _maxLength = 1000;

  ReportReason _reason = ReportReason.spam;
  final _details = TextEditingController();
  bool _sending = false;
  Object? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await CommunityScope.of(context).moderation.report(
        target: widget.target,
        targetId: widget.targetId,
        reason: _reason,
        details: _details.text.trim().isEmpty ? null : _details.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    String label(ReportReason r) => switch (r) {
      ReportReason.spam => l10n.reasonSpam,
      ReportReason.abuse => l10n.reasonAbuse,
      ReportReason.scam => l10n.reasonScam,
      ReportReason.pumpAndDump => l10n.reasonPumpAndDump,
      ReportReason.misinformation => l10n.reasonMisinformation,
      ReportReason.other => l10n.reasonOther,
    };
    final error = _error;
    final details = CommunityReportDetails(
      target: widget.target,
      targetId: widget.targetId,
      title: l10n.reportTitle,
      options: [for (final r in ReportReason.values) CommunitySettingsOption(value: r, label: label(r))],
      selected: _reason,
      controller: _details,
      hintText: l10n.reportDetailsHint,
      maxLength: _maxLength,
      submitting: _sending,
      submitLabel: l10n.report,
      cancelLabel: l10n.cancel,
      error: error,
      errorMessage: error == null ? null : l10n.errorMessage(error),
      onSelect: (r) => setState(() => _reason = r),
      onSubmit: _sending ? null : _submit,
      onCancel: _sending ? null : () => Navigator.pop(context, false),
    );
    return buildSettingsPart((b) => b.reportDialog, context, details, DefaultReportDialog(details: details));
  }
}

class DefaultReportDialog extends StatelessWidget {
  const DefaultReportDialog({super.key, required this.details});

  final CommunityReportDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final onSelect = d.onSelect;
    final errorMessage = d.errorMessage;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      shape: communityDialogShape(style),
      title: Text(d.title, style: style.typography.title),
      contentPadding: EdgeInsets.fromLTRB(spacing.sm, spacing.md, spacing.xl, 0),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<ReportReason>(
                groupValue: d.selected,
                onChanged: (r) {
                  if (r != null) onSelect?.call(r);
                },
                child: Column(
                  children: [
                    for (final option in d.options)
                      RadioListTile<ReportReason>(
                        value: option.value,
                        dense: true,
                        fillColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected) ? style.accent : style.textTertiary,
                        ),
                        title: Text(option.label, style: style.typography.body.copyWith(fontSize: 14)),
                      ),
                  ],
                ),
              ),
              SizedBox(height: spacing.sm),
              Padding(
                padding: EdgeInsets.only(left: spacing.lg),
                child: TextField(
                  controller: d.controller,
                  maxLength: d.maxLength,
                  maxLines: 3,
                  style: style.typography.body,
                  decoration: communityFieldDecoration(style, hintText: d.hintText),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(left: spacing.lg),
                  child: Text(
                    errorMessage,
                    style: style.typography.meta.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
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
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onSubmit, child: Text(d.submitLabel)),
      ],
    );
  }
}

Future<bool> blockUserWithConfirm(BuildContext context, UserSummary user) async {
  final l10n = context.communityL10n;
  if (!await confirmCommunityAction(context, l10n.blockConfirm(user.name), confirmLabel: l10n.block)) return false;
  if (!context.mounted) return false;
  try {
    await CommunityScope.of(context).profiles.block(user.id);
    if (context.mounted) showCommunityMessage(context, l10n.blocked(user.name));
    return true;
  } catch (e) {
    if (context.mounted) showCommunityError(context, e);
    return false;
  }
}
