import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/message_requests/domain/entities/message_request.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/cubit/dm_policy_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityDmPolicySettings extends StatelessWidget {
  const CommunityDmPolicySettings({super.key});

  @override
  Widget build(BuildContext context) {
    final features = CommunityFeatureScope.of(context);
    return BlocProvider(create: (_) => DmPolicyCubit(features.messageRequests)..load(), child: const _PolicyView());
  }
}

class _PolicyView extends StatelessWidget {
  const _PolicyView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocListener<DmPolicyCubit, DmPolicyState>(
      listenWhen: (a, b) => a.savedId != b.savedId,
      listener: (context, _) => showCommunityMessage(context, l10n.dmPolicySaved),
      child: BlocConsumer<DmPolicyCubit, DmPolicyState>(
        listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
        listener: (context, state) => showCommunityError(context, state.actionError!),
        builder: (context, state) => _build(context, state),
      ),
    );
  }

  Widget _build(BuildContext context, DmPolicyState state) {
    final l10n = context.communityL10n;
    final cubit = context.read<DmPolicyCubit>();
    switch (state.status) {
      case LoadStatus.initial || LoadStatus.loading:
        return const CommunitySettingsLoading(area: CommunitySettingsArea.dmPolicy);
      case LoadStatus.failure:
        return CommunitySettingsError(area: CommunitySettingsArea.dmPolicy, error: state.error!, onRetry: cubit.load);
      case LoadStatus.ready:
        break;
    }
    final details = CommunityDmPolicyDetails(
      policy: state.settings.policy,
      title: l10n.dmPolicyTitle,
      options: [
        CommunitySettingsOption(
          value: DmPolicy.everyone,
          label: l10n.dmPolicyEveryone,
          hint: l10n.dmPolicyEveryoneHint,
        ),
        CommunitySettingsOption(value: DmPolicy.following, label: l10n.dmPolicyFollowing),
        CommunitySettingsOption(value: DmPolicy.none, label: l10n.dmPolicyNone, hint: l10n.dmPolicyNoneHint),
      ],
      saving: state.saving,
      onChanged: state.saving ? null : cubit.setPolicy,
    );
    return buildSettingsPart((b) => b.dmPolicy, context, details, _DefaultDmPolicy(details: details));
  }
}

class _DefaultDmPolicy extends StatelessWidget {
  const _DefaultDmPolicy({required this.details});

  final CommunityDmPolicyDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final onChanged = d.onChanged;
    return RadioGroup<DmPolicy>(
      groupValue: d.policy,
      onChanged: (policy) {
        if (policy != null && onChanged != null) onChanged(policy);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xs),
            child: Text(d.title, style: style.typography.meta),
          ),
          for (final option in d.options)
            RadioListTile<DmPolicy>(
              value: option.value,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? style.accent : style.textTertiary,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: spacing.sm),
              title: Text(option.label, style: style.typography.body),
              subtitle: option.hint == null ? null : Text(option.hint!, style: style.typography.meta),
            ),
        ],
      ),
    );
  }
}
