import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/features/profile/presentation/builders/community_profile_builders.dart';
import 'package:rendezvous_community/src/features/profile/presentation/builders/community_profile_details.dart';
import 'package:rendezvous_community/src/features/profile/presentation/cubit/follow_list_cubit.dart';
import 'package:rendezvous_community/src/features/profile/presentation/widgets/follow_toggle_button.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityFollowList extends StatelessWidget {
  const CommunityFollowList({
    super.key,
    required this.userId,
    this.initialKind = FollowListKind.followers,
    this.builders,
  });

  final String userId;
  final FollowListKind initialKind;
  final CommunityProfileBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final profiles = CommunityScope.of(context).profiles;
    if (profiles is! FollowListRepository) return const SizedBox.shrink();
    final lists = profiles as FollowListRepository;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return withProfileBuilders(
      context,
      builders,
      DefaultTabController(
        length: FollowListKind.values.length,
        initialIndex: initialKind.index,
        child: ColoredBox(
          color: style.surface,
          child: Column(
            children: [
              TabBar(
                labelColor: style.textPrimary,
                unselectedLabelColor: style.textSecondary,
                indicatorColor: style.accent,
                labelStyle: style.typography.label,
                tabs: [
                  Tab(text: l10n.profileStatFollowers),
                  Tab(text: l10n.followingLabel),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final kind in FollowListKind.values)
                      _FollowListTab(key: ValueKey(kind), lists: lists, profiles: profiles, userId: userId, kind: kind),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowListTab extends StatefulWidget {
  const _FollowListTab({
    super.key,
    required this.lists,
    required this.profiles,
    required this.userId,
    required this.kind,
  });

  final FollowListRepository lists;
  final ProfileRepository profiles;
  final String userId;
  final FollowListKind kind;

  @override
  State<_FollowListTab> createState() => _FollowListTabState();
}

class _FollowListTabState extends State<_FollowListTab> with AutomaticKeepAliveClientMixin {
  late final FollowListCubit _cubit = FollowListCubit(
    lists: widget.lists,
    profiles: widget.profiles,
    userId: widget.userId,
    kind: widget.kind,
  )..load();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _cubit,
      child: _FollowListView(kind: widget.kind),
    );
  }
}

class _FollowListView extends StatelessWidget {
  const _FollowListView({required this.kind});

  final FollowListKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    return BlocConsumer<FollowListCubit, FollowListState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<FollowListCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return CommunitySkeleton(itemCount: 6, itemBuilder: (_) => const _FollowListSkeleton());
          case LoadStatus.failure:
            return CommunityErrorView(error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            break;
        }
        if (state.entries.isEmpty) {
          return CommunityEmptyView(
            message: kind == FollowListKind.followers ? l10n.followersEmpty : l10n.followingEmpty,
            icon: Icons.people_outline,
          );
        }
        return NotificationListener<ScrollEndNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) cubit.loadMore();
            return false;
          },
          child: ListView.builder(
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            itemCount: state.entries.length + (state.loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.entries.length) {
                return Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: const Center(child: CircularProgressIndicator.adaptive()),
                );
              }
              final entry = state.entries[index];
              final details = CommunityFollowListEntryDetails(
                entry: entry,
                kind: kind,
                pending: state.pending.contains(entry.user.id),
                followLabel: l10n.follow,
                followingLabel: l10n.followingLabel,
                followBackLabel: l10n.followBack,
                followsYouLabel: l10n.followsYou,
                onOpen: () => CommunityNavigator.openUser(context, entry.user),
                onToggleFollow: entry.isMe ? null : () => cubit.toggleFollow(entry.user.id),
              );
              return KeyedSubtree(
                key: ValueKey(entry.user.id),
                child: buildCommunityPart(
                  CommunityProfileBuilders.of(context).followListEntry,
                  context,
                  details,
                  _DefaultFollowListEntry(details: details),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DefaultFollowListEntry extends StatelessWidget {
  const _DefaultFollowListEntry({required this.details});

  final CommunityFollowListEntryDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final user = d.user;
    final onToggle = d.onToggleFollow;
    return InkWell(
      onTap: d.onOpen,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: Row(
          children: [
            CommunityAvatar(user: user, radius: 20, ringColor: user.isOfficial ? style.accent : null),
            SizedBox(width: spacing.sm + spacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommunityUserName(user: user, showUsername: false, official: user.isOfficial),
                  SizedBox(height: spacing.xxs),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '@${user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.meta.copyWith(color: style.textSecondary),
                      ),
                      if (d.followsMe && !d.isMe)
                        DecoratedBox(
                          decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.badgeRadius),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
                            child: Text(
                              d.followsYouLabel,
                              style: style.typography.badge.copyWith(color: style.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onToggle != null) ...[
              SizedBox(width: spacing.sm),
              FollowToggleButton(
                label: d.buttonLabel,
                following: d.following,
                semanticName: user.name,
                onPressed: d.pending ? null : onToggle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowListSkeleton extends StatelessWidget {
  const _FollowListSkeleton();

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
                CommunitySkeletonBox(width: 90, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
