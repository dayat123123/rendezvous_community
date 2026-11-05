import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_official_scope.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_official_badge.dart';

class CommunityUserName extends StatelessWidget {
  const CommunityUserName({super.key, required this.user, this.showUsername = true, this.style, this.official = false});

  final UserSummary user;
  final bool showUsername;
  final TextStyle? style;
  final bool official;

  static final _none = ValueNotifier<Set<String>>(const <String>{});

  @override
  Widget build(BuildContext context) {
    final official = CommunityOfficialScope.maybeOf(context)?..ensureLoaded();
    return ValueListenableBuilder<Set<String>>(
      valueListenable: official ?? _none,
      builder: (context, ids, _) {
        final details = CommunityUserNameDetails(
          user: user,
          official: this.official || ids.contains(user.id),
          showUsername: showUsername,
          style: style,
        );
        return buildSharedPart((b) => b.userName, context, details, _DefaultUserName(details: details));
      },
    );
  }
}

class _DefaultUserName extends StatelessWidget {
  const _DefaultUserName({required this.details});

  final CommunityUserNameDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final user = details.user;
    final username = details.usernameLabel;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(user.name, overflow: TextOverflow.ellipsis, style: details.style ?? style.typography.author),
        ),
        if (details.official) ...[
          SizedBox(width: style.spacing.xs),
          const CommunityOfficialBadge(),
        ] else if (user.isVerified) ...[
          SizedBox(width: style.spacing.xs),
          _VerifiedBadge(user: user),
        ],
        if (username != null) ...[
          SizedBox(width: style.spacing.xs + style.spacing.xxs),
          Flexible(
            child: Text(username, overflow: TextOverflow.ellipsis, style: style.typography.meta),
          ),
        ],
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.user});

  final UserSummary user;

  @override
  Widget build(BuildContext context) {
    final details = CommunityVerifiedBadgeDetails(user: user, color: Theme.of(context).colorScheme.primary);
    return buildCommunityPart(
      CommunityBadgeBuilders.of(context).verified,
      context,
      details,
      Icon(Icons.verified, size: details.size, color: details.color),
    );
  }
}
