import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';

class CommunityAuthorRow extends StatelessWidget {
  const CommunityAuthorRow({
    super.key,
    required this.user,
    this.meta,
    this.avatarSize,
    this.official = false,
    this.online = false,
    this.showUsername = false,
    this.trailing,
    this.onOpenAuthor,
  });

  final UserSummary user;
  final String? meta;
  final double? avatarSize;
  final bool official;
  final bool online;
  final bool showUsername;
  final Widget? trailing;
  final VoidCallback? onOpenAuthor;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final size = avatarSize ?? style.avatarSizes.medium;
    final details = CommunityAuthorRowDetails(
      user: user,
      avatar: CommunityAvatar(user: user, radius: size / 2, online: online),
      name: CommunityUserName(user: user, showUsername: showUsername, official: official),
      meta: meta,
      official: official,
      trailing: trailing,
      onOpenAuthor: onOpenAuthor,
    );
    return buildSharedPart((b) => b.authorRow, context, details, _DefaultAuthorRow(details: details));
  }
}

class _DefaultAuthorRow extends StatelessWidget {
  const _DefaultAuthorRow({required this.details});

  final CommunityAuthorRowDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final meta = details.meta;
    final trailing = details.trailing;
    final onOpen = details.onOpenAuthor;
    Widget identity = ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.minTouchTarget),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          details.avatar,
          SizedBox(width: style.spacing.sm + style.spacing.xxs),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details.name,
                if (meta != null) ...[
                  SizedBox(height: style.spacing.xxs),
                  Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                ],
              ],
            ),
          ),
          SizedBox(width: style.spacing.xs),
        ],
      ),
    );
    if (onOpen != null) {
      identity = Semantics(
        button: true,
        child: InkWell(onTap: onOpen, borderRadius: style.radii.controlRadius, child: identity),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerStart, child: identity),
        ),
        if (trailing != null) ...[SizedBox(width: style.spacing.xs), trailing],
      ],
    );
  }
}
