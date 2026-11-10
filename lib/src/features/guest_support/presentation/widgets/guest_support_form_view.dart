import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/builders/community_guest_support_details.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/guest_support_texts.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class GuestSecurityNote extends StatelessWidget {
  const GuestSecurityNote({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityGuestSecurityNoteDetails(
      title: l10n.guestSupportSecurityTitle,
      message: l10n.guestSupportSecurityNote,
      compact: compact,
    );
    return buildSupportPart((b) => b.guestSecurityNote, context, details, _DefaultSecurityNote(details: details));
  }
}

class _DefaultSecurityNote extends StatelessWidget {
  const _DefaultSecurityNote({required this.details});

  final CommunityGuestSecurityNoteDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final color = supportToneColor(context, CommunitySupportTone.info);
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(details.compact ? spacing.sm : spacing.md),
        decoration: BoxDecoration(
          color: supportSoftBackground(style, color),
          borderRadius: style.radii.controlRadius,
          border: Border.all(color: color.withValues(alpha: 0.35), width: style.borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_outlined, size: details.compact ? 18 : 22, color: color),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!details.compact) ...[
                    Text(details.title, style: style.typography.label.copyWith(color: color)),
                    SizedBox(height: spacing.xxs),
                  ],
                  Text(details.message, style: style.typography.meta.copyWith(color: style.textPrimary, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestUpperCaseFormatter extends TextInputFormatter {
  const GuestUpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    if (upper == newValue.text) return newValue;
    if (upper.length == newValue.text.length) return newValue.copyWith(text: upper);
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}

class GuestSupportFormView extends StatefulWidget {
  const GuestSupportFormView({super.key});

  @override
  State<GuestSupportFormView> createState() => _GuestSupportFormViewState();
}

class _GuestSupportFormViewState extends State<GuestSupportFormView> {
  final _name = TextEditingController();
  final _loginId = TextEditingController();
  final _description = TextEditingController();
  String? _problem;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [_name, _loginId, _description]) {
      controller.addListener(_changed);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _loginId.dispose();
    _description.dispose();
    super.dispose();
  }

  void _changed() {
    if (_submitted && mounted) setState(() {});
  }

  Map<GuestSupportField, GuestSupportFieldIssue> _issues(GuestSupportState state) => validateGuestSupportForm(
    name: _name.text,
    loginId: _loginId.text,
    problem: _problem,
    description: _description.text,
    problems: state.problems.map((p) => p.code),
  );

  void _submit() {
    final cubit = context.read<GuestSupportCubit>();
    setState(() => _submitted = true);
    if (_issues(cubit.state).isNotEmpty) return;
    cubit.start(name: _name.text, loginId: _loginId.text, problem: _problem, description: _description.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final state = context.watch<GuestSupportCubit>().state;
    final issues = _submitted ? _issues(state) : const <GuestSupportField, GuestSupportFieldIssue>{};
    final details = CommunityGuestFormDetails(
      title: l10n.guestSupportFormTitle,
      hint: l10n.guestSupportFormHint,
      securityNote: const GuestSecurityNote(),
      nameController: _name,
      loginIdController: _loginId,
      descriptionController: _description,
      nameLabel: l10n.guestSupportName,
      loginIdLabel: l10n.guestSupportLoginId,
      loginIdHint: l10n.guestSupportLoginIdHint,
      optionalLabel: l10n.supportIntakeOptional,
      problemLabel: l10n.guestSupportProblem,
      descriptionLabel: l10n.guestSupportDescription,
      descriptionHint: l10n.guestSupportDescriptionHint,
      problems: state.problems,
      selectedProblem: _problem,
      onSelectProblem: (code) => setState(() => _problem = code),
      errors: {for (final entry in issues.entries) entry.key: guestFieldIssueText(l10n, entry.key, entry.value)},
      submitLabel: l10n.guestSupportSubmit,
      onSubmit: _submit,
      busy: state.starting,
    );
    return buildSupportPart((b) => b.guestForm, context, details, _DefaultGuestForm(details: details));
  }
}

class _DefaultGuestForm extends StatelessWidget {
  const _DefaultGuestForm({required this.details});

  final CommunityGuestFormDetails details;

  InputDecoration _decoration(CommunityStyle style, String label, {String? error, String? hint, String? helper}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        errorText: error,
        errorMaxLines: 3,
        filled: true,
        fillColor: style.surface,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
        enabledBorder: OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide),
      );

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final problemError = d.errorFor(GuestSupportField.problem);
    return ColoredBox(
      color: style.background,
      child: CommunityScrollArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xl, spacing.lg, spacing.xl),
          children: [
            Semantics(header: true, child: Text(d.title, style: style.typography.title)),
            SizedBox(height: spacing.xs),
            Text(d.hint, style: style.typography.body.copyWith(color: style.textSecondary)),
            SizedBox(height: spacing.lg),
            d.securityNote,
            SizedBox(height: spacing.lg),
            TextField(
              key: const ValueKey('guest-name'),
              controller: d.nameController,
              enabled: !d.busy,
              maxLength: d.nameMaxLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              style: style.typography.body,
              decoration: _decoration(style, d.nameLabel, error: d.errorFor(GuestSupportField.name)),
            ),
            SizedBox(height: spacing.sm),
            TextField(
              key: const ValueKey('guest-login-id'),
              controller: d.loginIdController,
              enabled: !d.busy,
              maxLength: d.loginIdMaxLength,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: const [GuestUpperCaseFormatter()],
              style: style.typography.body,
              decoration: _decoration(
                style,
                '${d.loginIdLabel} (${d.optionalLabel})',
                hint: d.loginIdHint,
                error: d.errorFor(GuestSupportField.loginId),
              ),
            ),
            SizedBox(height: spacing.sm),
            Text(d.problemLabel, style: style.typography.label),
            SizedBox(height: spacing.xs),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                for (final problem in d.problems)
                  ChoiceChip(
                    key: ValueKey('guest-problem-${problem.code}'),
                    label: Text(problem.label),
                    selected: d.selectedProblem == problem.code,
                    selectedColor: style.accentMuted,
                    backgroundColor: style.surface,
                    side: BorderSide(
                      color: d.selectedProblem == problem.code ? style.accent : style.border,
                      width: style.borderWidth,
                    ),
                    labelStyle: style.typography.label.copyWith(
                      color: d.selectedProblem == problem.code ? style.accent : style.textPrimary,
                    ),
                    showCheckmark: false,
                    onSelected: d.busy ? null : (_) => d.onSelectProblem(problem.code),
                  ),
              ],
            ),
            if (problemError != null) ...[
              SizedBox(height: spacing.xs),
              Text(problemError, style: style.typography.meta.copyWith(color: Theme.of(context).colorScheme.error)),
            ],
            SizedBox(height: spacing.md),
            TextField(
              key: const ValueKey('guest-description'),
              controller: d.descriptionController,
              enabled: !d.busy,
              minLines: 4,
              maxLines: 8,
              maxLength: d.descriptionMaxLength,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: style.typography.body,
              decoration: _decoration(
                style,
                d.descriptionLabel,
                hint: d.descriptionHint,
                error: d.errorFor(GuestSupportField.description),
              ),
            ),
            SizedBox(height: spacing.md),
            FilledButton.icon(
              key: const ValueKey('guest-submit'),
              style: style.primaryButtonStyle(),
              onPressed: d.busy ? null : d.onSubmit,
              icon: d.busy
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: style.onAccent),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(d.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}
