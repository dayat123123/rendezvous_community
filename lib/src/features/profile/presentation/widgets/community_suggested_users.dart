import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/features/profile/presentation/cubit/suggested_users_cubit.dart';
import 'package:rendezvous_community/src/features/profile/presentation/widgets/follow_toggle_button.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_builders.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunitySuggestedUsers extends StatelessWidget {
  const CommunitySuggestedUsers({
    super.key,
    this.limit = 5,
    this.showTitle = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.builders,
  });

  final int limit;
  final bool showTitle;
  final EdgeInsetsGeometry padding;
  final CommunityDiscoveryBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final profiles = CommunityScope.of(context).profiles;
    if (profiles is! SuggestedUsersRepository) return const SizedBox.shrink();
    final suggestions = profiles as SuggestedUsersRepository;
    return withDiscoveryBuilders(
      context,
      builders,
      CommunitySocialGate(
        unavailableBuilder: (_, _, _) => const SizedBox.shrink(),
        child: BlocProvider(
          create: (_) => SuggestedUsersCubit(suggestions: suggestions, profiles: profiles, limit: limit)..load(),
          child: _SuggestedUsersView(showTitle: showTitle, padding: padding),
        ),
      ),
    );
  }
}

class _SuggestedUsersView extends StatelessWidget {
  const _SuggestedUsersView({required this.showTitle, required this.padding});

  final bool showTitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return BlocConsumer<SuggestedUsersCubit, SuggestedUsersState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<SuggestedUsersCubit>();
        final List<Widget> rows = switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => [for (var i = 0; i < 3; i++) const _SuggestedUserSkeleton()],
          LoadStatus.failure => [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.errorMessage(state.error!), style: style.typography.meta)),
                  TextButton(onPressed: cubit.load, child: Text(l10n.retry)),
                ],
              ),
            ),
          ],
          LoadStatus.ready when state.users.isEmpty => [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.xs),
              child: Text(l10n.whoToFollowEmpty, style: style.typography.meta),
            ),
          ],
          LoadStatus.ready => [
            for (final suggestion in state.users)
              Builder(
                key: ValueKey(suggestion.user.id),
                builder: (context) {
                  final details = CommunitySuggestedUserDetails(
                    suggestion: suggestion,
                    subtitle: _subtitle(context, suggestion),
                    following: state.following.contains(suggestion.user.id),
                    pending: state.pending.contains(suggestion.user.id),
                    followLabel: l10n.follow,
                    followingLabel: l10n.followingLabel,
                    onOpen: () => CommunityNavigator.openUser(context, suggestion.user),
                    onToggleFollow: () => cubit.toggleFollow(suggestion.user.id),
                  );
                  return buildDiscoveryPart(
                    (b) => b.suggestedUser,
                    context,
                    details,
                    _DefaultSuggestedUser(details: details),
                  );
                },
              ),
          ],
        };
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showTitle)
                Padding(
                  padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.xs),
                  child: Semantics(header: true, child: Text(l10n.whoToFollow, style: style.typography.sectionTitle)),
                ),
              ...rows,
            ],
          ),
        );
      },
    );
  }

  static String _subtitle(BuildContext context, SuggestedUser suggestion) {
    final l10n = context.communityL10n;
    if (suggestion.mutualCount > 0) return l10n.followedByMutual(suggestion.mutualCount);
    if (suggestion.isOfficial) return l10n.officialAccount;
    return l10n.followers(suggestion.followerCount);
  }
}

class _DefaultSuggestedUser extends StatelessWidget {
  const _DefaultSuggestedUser({required this.details});

  final CommunitySuggestedUserDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final suggestion = details.suggestion;
    return InkWell(
      onTap: details.onOpen,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: Row(
          children: [
            CommunityAvatar(user: details.user, radius: 20, ringColor: suggestion.isOfficial ? style.accent : null),
            SizedBox(width: spacing.sm + spacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommunityUserName(user: details.user, showUsername: false, official: suggestion.isOfficial),
                  SizedBox(height: spacing.xxs),
                  Text(
                    details.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.typography.meta.copyWith(color: style.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            buildDiscoveryPart(
              (b) => b.suggestedFollowButton,
              context,
              details,
              SuggestedFollowButton(details: details),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestedFollowButton extends StatelessWidget {
  const SuggestedFollowButton({super.key, required this.details});

  final CommunitySuggestedUserDetails details;

  @override
  Widget build(BuildContext context) => FollowToggleButton(
    label: details.following ? details.followingLabel : details.followLabel,
    following: details.following,
    semanticName: details.user.name,
    onPressed: details.pending ? null : details.onToggleFollow,
  );
}

class _SuggestedUserSkeleton extends StatelessWidget {
  const _SuggestedUserSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      child: Row(
        children: [
          const CommunitySkeletonBox(width: 40, height: 40, circle: true),
          SizedBox(width: spacing.sm + spacing.xxs),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommunitySkeletonBox(width: 120),
                SizedBox(height: 6),
                CommunitySkeletonBox(width: 160, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
