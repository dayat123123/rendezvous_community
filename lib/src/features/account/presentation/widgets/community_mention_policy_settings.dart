import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/mention_policy_cubit.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/mention_policy.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

bool communityMentionPolicyAvailable(BuildContext context) =>
    CommunityScope.maybeOf(context)?.profiles is MentionPolicyRepository;

class CommunityMentionPolicySettings extends StatelessWidget {
  const CommunityMentionPolicySettings({super.key});

  @override
  Widget build(BuildContext context) {
    if (CommunityScope.maybeOf(context)?.profiles case final MentionPolicyRepository repository) {
      return BlocProvider(create: (_) => MentionPolicyCubit(repository)..load(), child: const _MentionPolicyView());
    }
    return const SizedBox.shrink();
  }
}

class _MentionPolicyView extends StatelessWidget {
  const _MentionPolicyView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocListener<MentionPolicyCubit, MentionPolicyState>(
      listenWhen: (a, b) => a.savedId != b.savedId,
      listener: (context, _) => showCommunityMessage(context, l10n.mentionPolicySaved),
      child: BlocConsumer<MentionPolicyCubit, MentionPolicyState>(
        listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
        listener: (context, state) => showCommunityError(context, state.actionError!),
        builder: _build,
      ),
    );
  }

  Widget _build(BuildContext context, MentionPolicyState state) {
    final l10n = context.communityL10n;
    final cubit = context.read<MentionPolicyCubit>();
    switch (state.status) {
      case LoadStatus.initial || LoadStatus.loading:
        return const CommunitySettingsLoading(area: CommunitySettingsArea.mentionPolicy);
      case LoadStatus.failure:
        if (mapError(state.error!).code == 'PGRST202') return const SizedBox.shrink();
        return CommunitySettingsError(
          area: CommunitySettingsArea.mentionPolicy,
          error: state.error!,
          onRetry: cubit.load,
        );
      case LoadStatus.ready:
        break;
    }
    final details = CommunityMentionPolicyDetails(
      policy: state.policy,
      title: l10n.mentionPolicyTitle,
      hint: l10n.mentionPolicyHint,
      options: [
        CommunitySettingsOption(value: MentionPolicy.everyone, label: l10n.mentionPolicyEveryone),
        CommunitySettingsOption(value: MentionPolicy.following, label: l10n.mentionPolicyFollowing),
        CommunitySettingsOption(value: MentionPolicy.none, label: l10n.mentionPolicyNone),
      ],
      saving: state.saving,
      onChanged: state.saving ? null : cubit.setPolicy,
    );
    return buildSettingsPart((b) => b.mentionPolicy, context, details, _DefaultMentionPolicy(details: details));
  }
}

class _DefaultMentionPolicy extends StatelessWidget {
  const _DefaultMentionPolicy({required this.details});

  final CommunityMentionPolicyDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final onChanged = d.onChanged;
    return RadioGroup<MentionPolicy>(
      groupValue: d.policy,
      onChanged: (policy) {
        if (policy != null && onChanged != null) onChanged(policy);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xxs),
            child: Text(d.title, style: style.typography.meta),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xs),
            child: Text(d.hint, style: style.typography.meta.copyWith(color: style.textTertiary)),
          ),
          for (final option in d.options)
            RadioListTile<MentionPolicy>(
              key: ValueKey('account-mention-policy-${option.value.name}'),
              value: option.value,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? style.accent : style.textTertiary,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: spacing.sm),
              title: Text(option.label, style: style.typography.body),
            ),
        ],
      ),
    );
  }
}
