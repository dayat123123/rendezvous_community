import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/services/support_intake.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

String supportIntakeProblemText(CommunityLocalizations l10n, SupportIntakeProblem problem) => switch (problem) {
  SupportIntakeProblem.required => l10n.supportIntakeRequired,
  SupportIntakeProblem.tooLong => l10n.supportIntakeTooLong(supportIntakeMaxLength),
  SupportIntakeProblem.number => l10n.supportIntakeNumber,
  SupportIntakeProblem.date => l10n.supportIntakeDate,
  SupportIntakeProblem.choice => l10n.supportIntakeChoice,
};

class SupportIntakeForm extends StatefulWidget {
  const SupportIntakeForm({super.key, required this.topic, this.notice});

  final SupportTopic topic;
  final String? notice;

  @override
  State<SupportIntakeForm> createState() => _SupportIntakeFormState();
}

class _SupportIntakeFormState extends State<SupportIntakeForm> {
  final _answers = <String, String>{};
  final _controllers = <String, TextEditingController>{};
  bool _submitted = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String key) =>
      _controllers.putIfAbsent(key, () => TextEditingController(text: _answers[key] ?? ''));

  void _change(String key, String value) => setState(() => _answers[key] = value);

  Future<void> _pickDate(SupportIntakeField field) async {
    final current = _answers[field.key];
    final initial = current != null && isSupportIntakeDate(current) ? DateTime.parse(current) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && mounted) _change(field.key, supportIntakeDateValue(picked));
  }

  void _submit() {
    setState(() => _submitted = true);
    if (validateSupportIntake(widget.topic.intake, _answers).isNotEmpty) return;
    context.read<SupportCubit>().submitIntake(Map.of(_answers));
  }

  String? _dateLabel(SupportIntakeField field, DateFormat format) {
    final value = _answers[field.key];
    if (field.type != SupportIntakeType.date || value == null || !isSupportIntakeDate(value)) return null;
    return format.format(DateTime.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<SupportCubit>();
    final busy = context.select((SupportCubit c) => c.state.busy);
    final topic = widget.topic;
    final problems = _submitted
        ? validateSupportIntake(topic.intake, _answers)
        : const <String, SupportIntakeProblem>{};
    final errors = {for (final entry in problems.entries) entry.key: supportIntakeProblemText(l10n, entry.value)};
    final dates = DateFormat.yMMMMd(l10n.localeName);
    final views = [
      for (final field in topic.intake)
        SupportIntakeFieldView(
          key: ValueKey(field.key),
          details: CommunitySupportIntakeFieldDetails(
            field: field,
            label: field.label,
            value: _answers[field.key] ?? '',
            onChanged: (value) => _change(field.key, value),
            enabled: !busy,
            error: errors[field.key],
            optionalLabel: field.isRequired ? null : l10n.supportIntakeOptional,
            controller: field.type == SupportIntakeType.text || field.type == SupportIntakeType.number
                ? _controller(field.key)
                : null,
            onPickDate: field.type == SupportIntakeType.date && !busy ? () => _pickDate(field) : null,
            dateLabel: _dateLabel(field, dates),
            pickDateLabel: field.type == SupportIntakeType.date ? l10n.supportIntakePickDate : null,
          ),
        ),
    ];
    final details = CommunitySupportIntakeDetails(
      topic: topic,
      icon: supportTopicIconFor(topic),
      title: l10n.supportIntakeTitle,
      hint: l10n.supportIntakeHint,
      fields: topic.intake,
      answers: Map.unmodifiable(_answers),
      errors: errors,
      fieldViews: views,
      submitLabel: widget.notice == null ? l10n.supportIntakeSubmit : l10n.supportLeaveMessage,
      backLabel: l10n.helpPickAnotherTopic,
      busy: busy,
      onSubmit: _submit,
      onBack: cubit.cancelIntake,
      notice: widget.notice,
    );
    return buildSupportPart((b) => b.intakeForm, context, details, _DefaultIntakeForm(details: details));
  }
}

class _DefaultIntakeForm extends StatelessWidget {
  const _DefaultIntakeForm({required this.details});

  final CommunitySupportIntakeDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final icon = d.icon;
    final notice = d.notice;
    return ColoredBox(
      color: style.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xl, spacing.lg, spacing.xl),
        children: [
          Row(
            children: [
              if (icon != null) ...[
                SupportIconCircle(icon: icon, color: style.accent, size: 28),
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: Text(d.topic.name, style: style.typography.label.copyWith(color: style.textSecondary)),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Semantics(header: true, child: Text(d.title, style: style.typography.title)),
          SizedBox(height: spacing.xs),
          Text(d.hint, style: style.typography.body.copyWith(color: style.textSecondary)),
          if (notice != null) ...[
            SizedBox(height: spacing.md),
            SupportNoticeBox(message: notice, tone: CommunitySupportTone.warning, icon: Icons.schedule),
          ],
          SizedBox(height: spacing.lg),
          for (final view in d.fieldViews) ...[view, SizedBox(height: spacing.md)],
          SizedBox(height: spacing.sm),
          FilledButton.icon(
            style: style.primaryButtonStyle(),
            onPressed: d.busy ? null : d.onSubmit,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(d.submitLabel),
          ),
          SizedBox(height: spacing.xs),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
            onPressed: d.busy ? null : d.onBack,
            child: Text(d.backLabel),
          ),
        ],
      ),
    );
  }
}

class SupportIntakeFieldView extends StatelessWidget {
  const SupportIntakeFieldView({super.key, required this.details});

  final CommunitySupportIntakeFieldDetails details;

  @override
  Widget build(BuildContext context) =>
      buildSupportPart((b) => b.intakeField, context, details, _DefaultIntakeField(details: details));
}

class _DefaultIntakeField extends StatelessWidget {
  const _DefaultIntakeField({required this.details});

  final CommunitySupportIntakeFieldDetails details;

  InputDecoration _decoration(CommunityStyle style, String label, {Widget? suffixIcon}) => InputDecoration(
    labelText: label,
    errorText: details.error,
    counterText: '',
    filled: true,
    fillColor: style.surface,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
    enabledBorder: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
  );

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final optional = d.optionalLabel;
    final label = optional == null ? d.label : '${d.label} ($optional)';
    return switch (d.type) {
      SupportIntakeType.text || SupportIntakeType.number => TextField(
        controller: d.controller,
        enabled: d.enabled,
        onChanged: d.onChanged,
        maxLength: supportIntakeMaxLength,
        keyboardType: d.type == SupportIntakeType.number
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : null,
        textInputAction: TextInputAction.next,
        style: style.typography.body,
        decoration: _decoration(style, label),
      ),
      SupportIntakeType.date => Semantics(
        button: true,
        child: InkWell(
          onTap: d.onPickDate,
          borderRadius: style.radii.controlRadius,
          child: InputDecorator(
            decoration: _decoration(style, label, suffixIcon: Icon(Icons.event_outlined, color: style.accent)),
            child: Text(
              d.dateLabel ?? d.pickDateLabel ?? '',
              style: style.typography.body.copyWith(color: d.dateLabel == null ? style.textTertiary : null),
            ),
          ),
        ),
      ),
      SupportIntakeType.choice => _ChoiceField(details: d, label: label),
    };
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({required this.details, required this.label});

  final CommunitySupportIntakeFieldDetails details;
  final String label;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final error = d.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style.typography.label),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final option in d.options)
              ChoiceChip(
                label: Text(option.label),
                selected: d.value == option.value,
                selectedColor: style.accentMuted,
                backgroundColor: style.surface,
                side: BorderSide(
                  color: d.value == option.value ? style.accent : style.border,
                  width: style.borderWidth,
                ),
                labelStyle: style.typography.label.copyWith(
                  color: d.value == option.value ? style.accent : style.textPrimary,
                ),
                showCheckmark: false,
                onSelected: d.enabled ? (selected) => d.onChanged(selected ? option.value : '') : null,
              ),
          ],
        ),
        if (error != null) ...[
          SizedBox(height: spacing.xs),
          Text(error, style: style.typography.meta.copyWith(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}
