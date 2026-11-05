import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/domain/entities/moderation_status.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class ModerationNotice extends StatelessWidget {
  const ModerationNotice({super.key, required this.status, this.onAppeal, this.compact = false, this.color});

  final ModerationStatus? status;
  final VoidCallback? onAppeal;
  final bool compact;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    if (status == null || status == ModerationStatus.visible) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final scheme = Theme.of(context).colorScheme;
    final held = status == ModerationStatus.held;
    final details = CommunityModerationNoticeDetails(
      status: status,
      label: held ? l10n.moderationHeld : l10n.moderationHidden,
      hint: held ? l10n.moderationHeldHint : l10n.moderationHiddenHint,
      icon: held ? Icons.hourglass_top : Icons.visibility_off_outlined,
      color: color ?? (held ? scheme.tertiary : scheme.error),
      compact: compact,
      onAppeal: held ? null : onAppeal,
    );
    return buildSharedPart(
      (b) => b.moderationNotice,
      context,
      details,
      compact ? _CompactNotice(details: details) : _FullNotice(details: details),
    );
  }
}

class _CompactNotice extends StatelessWidget {
  const _CompactNotice({required this.details});

  final CommunityModerationNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final accent = details.color;
    final text = style.typography.badge.copyWith(color: accent, fontWeight: FontWeight.w500);
    final onAppeal = details.onAppeal;
    return Semantics(
      label: details.label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(details.icon, size: 12, color: accent),
          const SizedBox(width: 3),
          Flexible(child: Text(details.label, style: text)),
          if (onAppeal != null) ...[
            SizedBox(width: style.spacing.xs + style.spacing.xxs),
            InkWell(
              onTap: onAppeal,
              child: Text(l10n.appealAction, style: text.copyWith(decoration: TextDecoration.underline)),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullNotice extends StatelessWidget {
  const _FullNotice({required this.details});

  final CommunityModerationNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final accent = details.color;
    final onAppeal = details.onAppeal;
    return Container(
      margin: EdgeInsets.symmetric(vertical: style.spacing.xs),
      padding: EdgeInsets.fromLTRB(style.spacing.md, style.spacing.sm, style.spacing.xs, style.spacing.sm),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.08), style.surface),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: style.borderWidth),
        borderRadius: style.radii.controlRadius,
      ),
      child: Row(
        children: [
          Icon(details.icon, size: 16, color: accent),
          SizedBox(width: style.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(details.label, style: style.typography.label.copyWith(color: accent)),
                SizedBox(height: style.spacing.xxs),
                Text(details.hint, style: style.typography.meta),
              ],
            ),
          ),
          if (onAppeal != null) TextButton(onPressed: onAppeal, child: Text(l10n.appealAction)),
        ],
      ),
    );
  }
}

class HeldAttachmentLabel extends StatelessWidget {
  const HeldAttachmentLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final details = CommunityHeldLabelDetails(
      label: context.communityL10n.moderationHeld,
      icon: Icons.hourglass_top,
      foreground: scheme.onTertiaryContainer,
      background: scheme.tertiaryContainer.withValues(alpha: 0.92),
    );
    return buildSharedPart((b) => b.heldLabel, context, details, _DefaultHeldLabel(details: details));
  }
}

class _DefaultHeldLabel extends StatelessWidget {
  const _DefaultHeldLabel({required this.details});

  final CommunityHeldLabelDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: style.spacing.xs + style.spacing.xxs, vertical: style.spacing.xxs),
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

class CommunityBotBadge extends StatelessWidget {
  const CommunityBotBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final details = CommunityLabelBadgeDetails(
      kind: CommunityBadgeKind.bot,
      label: context.communityL10n.botLabel,
      icon: Icons.smart_toy_outlined,
      foreground: scheme.onSecondaryContainer,
      background: scheme.secondaryContainer,
    );
    return buildLabelBadge(context, details, _DefaultBotBadge(details: details));
  }
}

class _DefaultBotBadge extends StatelessWidget {
  const _DefaultBotBadge({required this.details});

  final CommunityLabelBadgeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: details.background, borderRadius: style.radii.badgeRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(details.icon, size: 11, color: details.foreground),
          const SizedBox(width: 2),
          Text(
            details.label,
            style: style.typography.badge.copyWith(color: details.foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
