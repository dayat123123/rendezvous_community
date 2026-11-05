import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class SupportRating {
  const SupportRating(this.rating, this.comment);

  final int rating;
  final String? comment;
}

Future<SupportRating?> askSupportRating(BuildContext context) {
  final builders = CommunitySupportBuilders.of(context, listen: false);
  return showDialog<SupportRating>(
    context: context,
    builder: (_) => CommunitySupportBuildersScope(builders: builders, child: const SupportRatingDialog()),
  );
}

class SupportRatingDialog extends StatefulWidget {
  const SupportRatingDialog({super.key});

  @override
  State<SupportRatingDialog> createState() => _SupportRatingDialogState();
}

class _SupportRatingDialogState extends State<SupportRatingDialog> {
  final _comment = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _comment.text.trim();
    Navigator.pop(context, SupportRating(_rating, comment.isEmpty ? null : comment));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunitySupportRatingDetails(
      rating: _rating,
      controller: _comment,
      title: l10n.supportRateTitle,
      commentLabel: l10n.supportRateComment,
      submitLabel: l10n.supportRateSubmit,
      cancelLabel: l10n.cancel,
      onRate: (value) => setState(() => _rating = value),
      onCancel: () => Navigator.pop(context),
      onSubmit: _rating == 0 ? null : _submit,
    );
    return buildSupportPart((b) => b.ratingDialog, context, details, _DefaultRatingDialog(details: details));
  }
}

class _DefaultRatingDialog extends StatelessWidget {
  const _DefaultRatingDialog({required this.details});

  final CommunitySupportRatingDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      icon: SizedBox.square(
        dimension: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(color: style.accentMuted, shape: BoxShape.circle),
          child: Icon(Icons.support_agent, size: 28, color: style.accent),
        ),
      ),
      title: Text(d.title, textAlign: TextAlign.center, style: style.typography.title),
      actionsAlignment: MainAxisAlignment.center,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SupportRatingStars(rating: d.rating, max: d.maxRating, onRate: d.onRate),
            SizedBox(height: spacing.lg),
            TextField(
              controller: d.controller,
              maxLines: 3,
              maxLength: 500,
              style: style.typography.body,
              decoration: InputDecoration(
                labelText: d.commentLabel,
                alignLabelWithHint: true,
                filled: true,
                fillColor: style.pill,
                border: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
                enabledBorder: OutlineInputBorder(
                  borderRadius: style.radii.controlRadius,
                  borderSide: style.borderSide,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          onPressed: d.onCancel,
          child: Text(d.cancelLabel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onSubmit, child: Text(d.submitLabel)),
      ],
    );
  }
}

class SupportRatingStars extends StatelessWidget {
  const SupportRatingStars({super.key, required this.rating, required this.onRate, this.max = 5});

  final int rating;
  final int max;
  final ValueChanged<int>? onRate;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final onRate = this.onRate;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= max; i++)
            IconButton(
              tooltip: '$i',
              iconSize: 40,
              padding: EdgeInsets.all(style.spacing.xs),
              onPressed: onRate == null ? null : () => onRate(i),
              icon: Icon(
                i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i <= rating ? style.accent : style.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

Future<String?> askFakeCsReport(BuildContext context) {
  final builders = CommunitySupportBuilders.of(context, listen: false);
  return showDialog<String>(
    context: context,
    builder: (_) => CommunitySupportBuildersScope(builders: builders, child: const _FakeCsDialog()),
  );
}

class _FakeCsDialog extends StatefulWidget {
  const _FakeCsDialog();

  @override
  State<_FakeCsDialog> createState() => _FakeCsDialogState();
}

class _FakeCsDialogState extends State<_FakeCsDialog> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final valid = _text.text.trim().length >= 5;
    final details = CommunityFakeCsDetails(
      controller: _text,
      title: l10n.supportReportFake,
      hintText: l10n.supportReportFakeHint,
      submitLabel: l10n.supportSend,
      cancelLabel: l10n.cancel,
      onCancel: () => Navigator.pop(context),
      onSubmit: valid ? () => Navigator.pop(context, _text.text.trim()) : null,
    );
    return buildSupportPart((b) => b.fakeCsWarning, context, details, _DefaultFakeCsDialog(details: details));
  }
}

class _DefaultFakeCsDialog extends StatelessWidget {
  const _DefaultFakeCsDialog({required this.details});

  final CommunityFakeCsDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: d.controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          style: style.typography.body,
          decoration: InputDecoration(
            hintText: d.hintText,
            filled: true,
            fillColor: style.pill,
            border: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
            enabledBorder: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          onPressed: d.onCancel,
          child: Text(d.cancelLabel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onSubmit, child: Text(d.submitLabel)),
      ],
    );
  }
}

Future<bool> confirmSupport(BuildContext context, {required String message, required String confirm}) =>
    confirmCommunityAction(context, message, confirmLabel: confirm);
