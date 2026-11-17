import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/comment_audience_cubit.dart'
    show CommentAudienceCubit, CommentAudienceState, CommentSettingSaved;
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/comment_controls.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

bool communityCommentControlsAvailable(BuildContext context) =>
    CommunityScope.maybeOf(context)?.feed is CommentControlRepository;

class CommunityCommentAudienceSettings extends StatelessWidget {
  const CommunityCommentAudienceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = CommunityScope.maybeOf(context)?.feed;
    if (feed is! CommentControlRepository) return const SizedBox.shrink();
    return BlocProvider(create: (_) => CommentAudienceCubit(feed)..load(), child: const _AudienceView());
  }
}

class _AudienceView extends StatelessWidget {
  const _AudienceView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocListener<CommentAudienceCubit, CommentAudienceState>(
      listenWhen: (a, b) => a.savedId != b.savedId,
      listener: (context, state) => showCommunityMessage(context, switch (state.saved) {
        CommentSettingSaved.allOff => l10n.commentsAllOffSaved,
        CommentSettingSaved.allOn => l10n.commentsAllOnSaved,
        _ => l10n.commentAudienceSaved,
      }),
      child: BlocConsumer<CommentAudienceCubit, CommentAudienceState>(
        listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
        listener: (context, state) => showCommunityError(context, state.actionError!),
        builder: _build,
      ),
    );
  }

  Widget _build(BuildContext context, CommentAudienceState state) {
    final l10n = context.communityL10n;
    final cubit = context.read<CommentAudienceCubit>();
    switch (state.status) {
      case LoadStatus.initial || LoadStatus.loading:
        return const CommunitySettingsLoading(area: CommunitySettingsArea.commentAudience);
      case LoadStatus.failure:
        if (mapError(state.error!).code == 'PGRST202') return const SizedBox.shrink();
        return CommunitySettingsError(
          area: CommunitySettingsArea.commentAudience,
          error: state.error!,
          onRetry: cubit.load,
        );
      case LoadStatus.ready:
        break;
    }
    final details = CommunityCommentAudienceSettingDetails(
      audience: state.audience,
      title: l10n.commentAudienceAccountTitle,
      hint: l10n.commentAudienceAccountHint,
      options: [
        for (final option in commentAudienceOptions(l10n, CommentAudience.accountOptions))
          CommunitySettingsOption(value: option.audience, label: option.label, hint: option.hint),
      ],
      saving: state.saving,
      onChanged: state.saving || state.allOff ? null : cubit.setAudience,
      allOff: state.allOff,
      allOffSupported: state.allOffSupported,
      allOffTitle: l10n.commentsAllOffTitle,
      allOffHint: l10n.commentsAllOffHint,
      allOffNote: state.allOff ? l10n.commentsAllOffNote : null,
      onAllOffChanged: state.saving || !state.allOffSupported ? null : cubit.setAllOff,
    );
    return buildSettingsPart((b) => b.commentAudience, context, details, _DefaultCommentAudience(details: details));
  }
}

class _DefaultCommentAudience extends StatelessWidget {
  const _DefaultCommentAudience({required this.details});

  final CommunityCommentAudienceSettingDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final onChanged = d.onChanged;
    final onAllOff = d.onAllOffChanged;
    final note = d.allOffNote;
    return RadioGroup<CommentAudience>(
      groupValue: d.audience,
      onChanged: (audience) {
        if (audience != null && onChanged != null) onChanged(audience);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (d.allOffSupported)
            SwitchListTile(
              key: const ValueKey('account-comments-all-off'),
              value: d.allOff,
              onChanged: onAllOff,
              activeThumbColor: style.accent,
              contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg),
              title: Text(d.allOffTitle, style: style.typography.body),
              subtitle: Text(d.allOffHint, style: style.typography.meta),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xxs),
            child: Text(d.title, style: style.typography.meta),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xs),
            child: Text(note ?? d.hint, style: style.typography.meta.copyWith(color: style.textTertiary)),
          ),
          for (final option in d.options)
            RadioListTile<CommentAudience>(
              key: ValueKey('account-comment-audience-${option.value.wire}'),
              value: option.value,
              enabled: !d.allOff,
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
