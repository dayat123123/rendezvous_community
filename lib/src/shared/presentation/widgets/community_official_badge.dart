import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityOfficialBadge extends StatelessWidget {
  const CommunityOfficialBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final details = CommunityLabelBadgeDetails(
      kind: CommunityBadgeKind.official,
      label: context.communityL10n.officialAccountBadge,
      icon: Icons.verified,
      foreground: scheme.onPrimary,
      background: scheme.primary,
    );
    return buildLabelBadge(context, details, _DefaultOfficialBadge(details: details));
  }
}

class _DefaultOfficialBadge extends StatelessWidget {
  const _DefaultOfficialBadge({required this.details});

  final CommunityLabelBadgeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: style.spacing.xs + style.spacing.xxs, vertical: 1),
      decoration: BoxDecoration(color: details.background, borderRadius: style.radii.badgeRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(details.icon, size: 12, color: details.foreground),
          const SizedBox(width: 3),
          Text(details.label, style: style.typography.badge.copyWith(color: details.foreground)),
        ],
      ),
    );
  }
}
