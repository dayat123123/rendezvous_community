import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class SupportRating {
  const SupportRating(this.rating, this.comment, {this.reasons = const []});

  final int rating;
  final String? comment;
  final List<String> reasons;
}

Future<SupportRating?> askSupportRating(BuildContext context, {SupportSurvey? survey}) {
  final builders = CommunitySupportBuilders.of(context, listen: false);
  return showDialog<SupportRating>(
    context: context,
    builder: (_) => CommunitySupportBuildersScope(
      builders: builders,
      child: SupportRatingDialog(survey: survey),
    ),
  );
}

class SupportRatingDialog extends StatefulWidget {
  const SupportRatingDialog({super.key, this.survey, this.initialRating = 0, this.initialReasons = const {}});

  final SupportSurvey? survey;
  final int initialRating;
  final Set<String> initialReasons;

  @override
  State<SupportRatingDialog> createState() => _SupportRatingDialogState();
}

class _SupportRatingDialogState extends State<SupportRatingDialog> {
  final _comment = TextEditingController();
  late int _rating = widget.initialRating;
  late final Set<String> _reasons = {...widget.initialReasons};

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _asksReasons => widget.survey?.asksReasons(_rating) ?? false;

  void _rate(int value) => setState(() {
    _rating = value;
    if (!_asksReasons) _reasons.clear();
  });

  void _toggle(String code) => setState(() {
    if (!_reasons.remove(code)) _reasons.add(code);
  });

  void _submit() {
    final comment = _comment.text.trim();
    final survey = widget.survey;
    final reasons = _asksReasons && survey != null
        ? [
            for (final reason in survey.reasons)
              if (_reasons.contains(reason.code)) reason.code,
          ]
        : const <String>[];
    Navigator.pop(context, SupportRating(_rating, comment.isEmpty ? null : comment, reasons: reasons));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final survey = widget.survey;
    final selected = Set<String>.unmodifiable(_reasons);
    final reasons = survey != null && _asksReasons
        ? SupportSurveyReasonsView(
            details: CommunitySupportSurveyReasonsDetails(
              reasons: survey.reasons,
              selected: selected,
              title: l10n.supportSurveyReasons,
              hint: l10n.supportSurveyReasonsHint,
              onToggle: _toggle,
            ),
          )
        : null;
    final details = CommunitySupportRatingDetails(
      rating: _rating,
      controller: _comment,
      title: survey?.question ?? l10n.supportRateTitle,
      commentLabel: l10n.supportRateComment,
      submitLabel: l10n.supportRateSubmit,
      cancelLabel: l10n.cancel,
      onRate: _rate,
      onCancel: () => Navigator.pop(context),
      onSubmit: _rating == 0 ? null : _submit,
      survey: survey,
      values: survey?.values ?? const [1, 2, 3, 4, 5],
      ratingLabels: survey?.scale == 3
          ? {1: l10n.supportRateBad, 3: l10n.supportRateOkay, 5: l10n.supportRateGood}
          : const {},
      selectedReasons: selected,
      onToggleReason: reasons == null ? null : _toggle,
      reasons: reasons,
    );
    return buildSupportPart((b) => b.ratingDialog, context, details, _DefaultRatingDialog(details: details));
  }
}

class SupportSurveyReasonsView extends StatelessWidget {
  const SupportSurveyReasonsView({super.key, required this.details});

  final CommunitySupportSurveyReasonsDetails details;

  @override
  Widget build(BuildContext context) =>
      buildSupportPart((b) => b.surveyReasons, context, details, _DefaultSurveyReasons(details: details));
}

class _DefaultSurveyReasons extends StatelessWidget {
  const _DefaultSurveyReasons({required this.details});

  final CommunitySupportSurveyReasonsDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(d.title, style: style.typography.label),
        SizedBox(height: spacing.xxs),
        Text(d.hint, style: style.typography.meta),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final reason in d.reasons)
              FilterChip(
                label: Text(reason.label),
                selected: d.selected.contains(reason.code),
                selectedColor: style.accentMuted,
                backgroundColor: style.surface,
                checkmarkColor: style.accent,
                side: BorderSide(
                  color: d.selected.contains(reason.code) ? style.accent : style.border,
                  width: style.borderWidth,
                ),
                labelStyle: style.typography.label.copyWith(
                  color: d.selected.contains(reason.code) ? style.accent : style.textPrimary,
                ),
                onSelected: (_) => d.onToggle(reason.code),
              ),
          ],
        ),
      ],
    );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (d.faces)
                SupportRatingFaces(rating: d.rating, values: d.values, labels: d.ratingLabels, onRate: d.onRate)
              else
                SupportRatingStars(rating: d.rating, max: d.maxRating, onRate: d.onRate),
              if (d.reasons case final reasons?) ...[SizedBox(height: spacing.md), reasons],
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

class SupportRatingFaces extends StatelessWidget {
  const SupportRatingFaces({
    super.key,
    required this.rating,
    required this.onRate,
    this.values = const [1, 3, 5],
    this.labels = const {},
  });

  final int rating;
  final List<int> values;
  final Map<int, String> labels;
  final ValueChanged<int>? onRate;

  static IconData iconFor(int value) => switch (value) {
    <= 2 => Icons.sentiment_very_dissatisfied_rounded,
    3 => Icons.sentiment_neutral_rounded,
    _ => Icons.sentiment_very_satisfied_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final onRate = this.onRate;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in values)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: style.spacing.xs),
              child: Semantics(
                selected: value == rating,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: labels[value] ?? '$value',
                      iconSize: 44,
                      padding: EdgeInsets.all(style.spacing.xs),
                      onPressed: onRate == null ? null : () => onRate(value),
                      icon: Icon(iconFor(value), color: value == rating ? style.accent : style.textTertiary),
                    ),
                    if (labels[value] case final label?)
                      ExcludeSemantics(
                        child: Text(
                          label,
                          style: style.typography.meta.copyWith(
                            color: value == rating ? style.accent : style.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
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
