import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_feed_list.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_skeletons.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/presentation/builders/community_profile_builders.dart';
import 'package:rendezvous_community/src/features/profile/presentation/builders/community_profile_details.dart';
import 'package:rendezvous_community/src/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_actions.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/social_text.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityUserProfile extends StatelessWidget {
  const CommunityUserProfile({super.key, this.userId, this.username, this.builders})
    : assert(userId != null || username != null, 'Either userId or username is required');

  final String? userId;
  final String? username;
  final CommunityProfileBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    return withProfileBuilders(
      context,
      builders,
      BlocProvider(
        create: (_) =>
            ProfileCubit(profiles: deps.profiles, chat: deps.chat, userId: userId, username: username)..load(),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
          listener: (context, state) => showCommunityError(context, state.actionError!),
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.profile?.user.id != b.profile?.user.id ||
              a.profile?.isBlocked != b.profile?.isBlocked,
          builder: (context, state) {
            final l10n = context.communityL10n;
            switch (state.status) {
              case LoadStatus.initial || LoadStatus.loading:
                return CommunitySkeleton(itemCount: 3, itemBuilder: (_) => const PostCardSkeleton());
              case LoadStatus.failure:
                return CommunityErrorView(error: state.error!, onRetry: context.read<ProfileCubit>().load);
              case LoadStatus.ready:
                final profile = state.profile;
                if (profile == null) {
                  return CommunityEmptyView(message: l10n.profileNotFound, icon: Icons.person_off_outlined);
                }
                if (profile.isBlocked) return const _ProfileHeader();
                return CommunityFeedList(
                  scope: FeedScope.user(profile.user.id),
                  emptyMessage: l10n.userFeedEmpty,
                  header: const _ProfileHeader(),
                );
            }
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final profile = state.profile!;
        final user = profile.user;
        final parts = CommunityProfileBuilders.of(context);
        final details = CommunityProfileDetails(
          profile: profile,
          busy: state.busy,
          followersLabel: l10n.followers(profile.followerCount),
          followingLabel: l10n.followingCount(profile.followingCount),
          postsLabel: l10n.postsCount(profile.postCount),
          onToggleFollow: profile.isMe || profile.isBlocked ? null : cubit.toggleFollow,
          onMessage: profile.isMe || profile.isBlocked
              ? null
              : () async {
                  final roomId = await cubit.openDirectRoom();
                  if (roomId != null && context.mounted) CommunityNavigator.openRoom(context, roomId);
                },
          onEdit: profile.isMe && !state.busy ? () => _editProfile(context, profile) : null,
          onReport: profile.isMe ? null : () => showReportDialog(context, target: ReportTarget.user, targetId: user.id),
          onBlock: profile.isMe || profile.isBlocked
              ? null
              : () async {
                  if (await blockUserWithConfirm(context, user)) await cubit.load();
                },
          onUnblock: profile.isMe || !profile.isBlocked ? null : cubit.unblock,
        );
        return buildCommunityPart(parts.header, context, details, _defaultHeader(context, details, parts));
      },
    );
  }

  Widget _defaultHeader(BuildContext context, CommunityProfileDetails details, CommunityProfileBuilders parts) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final profile = details.profile;
    final user = profile.user;
    final bio = profile.bio;
    final follow = profile.isFollowing
        ? OutlinedButton(
            style: style.secondaryButtonStyle(),
            onPressed: details.onToggleFollow,
            child: Text(l10n.followingLabel),
          )
        : FilledButton(style: style.primaryButtonStyle(), onPressed: details.onToggleFollow, child: Text(l10n.follow));
    final message = OutlinedButton.icon(
      style: style.secondaryButtonStyle(),
      onPressed: details.onMessage,
      icon: const Icon(Icons.chat_bubble_outline, size: 18),
      label: Text(l10n.sendMessage),
    );
    return EditorialSection(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommunityAvatar(user: user, radius: style.avatarSizes.profile / 2),
              SizedBox(width: spacing.lg),
              Expanded(child: buildCommunityPart(parts.stats, context, details, _ProfileStats(details: details))),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommunityUserName(
                      user: user,
                      showUsername: false,
                      style: style.typography.title.copyWith(fontSize: 17),
                    ),
                    SizedBox(height: spacing.xxs),
                    Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('@${user.username}', style: style.typography.meta),
                        if (profile.followsMe)
                          DecoratedBox(
                            decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.badgeRadius),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.xs + spacing.xxs,
                                vertical: spacing.xxs,
                              ),
                              child: Text(
                                l10n.followsYou,
                                style: style.typography.badge.copyWith(color: style.textSecondary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!profile.isMe) buildCommunityPart(parts.menu, context, details, _ProfileMenu(details: details)),
            ],
          ),
          if (bio != null && bio.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            SocialText(bio, style: style.typography.body.copyWith(height: 1.45)),
          ],
          SizedBox(height: spacing.lg),
          if (profile.isMe)
            OutlinedButton.icon(
              style: style.secondaryButtonStyle(),
              onPressed: details.onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.editProfile),
            )
          else if (!profile.isBlocked)
            Row(
              children: [
                Expanded(child: buildCommunityPart(parts.followButton, context, details, follow)),
                SizedBox(width: spacing.sm),
                Expanded(child: buildCommunityPart(parts.messageButton, context, details, message)),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, UserProfile profile) async {
    final cubit = context.read<ProfileCubit>();
    final l10n = context.communityL10n;
    final name = TextEditingController(text: profile.user.displayName ?? '');
    final bio = TextEditingController(text: profile.bio ?? '');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editProfile),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () async {
                  const group = XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png', 'webp']);
                  final file = await openFile(acceptedTypeGroups: const [group]);
                  if (file == null) return;
                  await cubit.changeAvatar(await file.readAsBytes(), mimeFromName(file.name, file.mimeType));
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.changeAvatar),
              ),
              TextField(
                controller: name,
                maxLength: 60,
                decoration: InputDecoration(labelText: l10n.displayName),
              ),
              TextField(
                controller: bio,
                maxLength: 300,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.bio),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final ok = await cubit.saveProfile(displayName: name.text.trim(), bio: bio.text.trim());
              if (ok && dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    name.dispose();
    bio.dispose();
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.details});

  final CommunityProfileDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final blocked = details.profile.isBlocked;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: CommunityStyle.of(context).textSecondary),
      onSelected: (action) => switch (action) {
        'report' => details.onReport?.call(),
        'block' => details.onBlock?.call(),
        'unblock' => details.onUnblock?.call(),
        _ => null,
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'report', child: Text(l10n.report)),
        PopupMenuItem(value: blocked ? 'unblock' : 'block', child: Text(blocked ? l10n.unblock : l10n.block)),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.details});

  final CommunityProfileDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final profile = details.profile;
    return Row(
      children: [
        _ProfileStat(count: profile.postCount, label: l10n.profileStatPosts, semanticLabel: details.postsLabel),
        _ProfileStat(
          count: profile.followerCount,
          label: l10n.profileStatFollowers,
          semanticLabel: details.followersLabel,
        ),
        _ProfileStat(count: profile.followingCount, label: l10n.followingLabel, semanticLabel: details.followingLabel),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.count, required this.label, required this.semanticLabel});

  final int count;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Expanded(
      child: Semantics(
        container: true,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                communityCountText(context, count),
                maxLines: 1,
                style: style.typography.title.copyWith(fontSize: 18, height: 1.2),
              ),
              SizedBox(height: style.spacing.xxs),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
            ],
          ),
        ),
      ),
    );
  }
}
