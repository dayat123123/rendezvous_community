import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

Color supportSoftBackground(CommunityStyle style, Color color) =>
    Color.alphaBlend(color.withValues(alpha: 0.12), style.surface);

Color supportToneColor(BuildContext context, CommunitySupportTone tone) {
  final scheme = Theme.of(context).colorScheme;
  return switch (tone) {
    CommunitySupportTone.neutral => CommunityStyle.of(context).textSecondary,
    CommunitySupportTone.info => scheme.primary,
    CommunitySupportTone.warning => scheme.tertiary,
    CommunitySupportTone.danger => scheme.error,
  };
}

Color supportStatusColor(BuildContext context, SupportStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    SupportStatus.open => scheme.tertiary,
    SupportStatus.claimed => scheme.primary,
    SupportStatus.waitingCustomer => scheme.secondary,
    SupportStatus.resolved || SupportStatus.closed => CommunityStyle.of(context).textSecondary,
  };
}

class SupportSoftPill extends StatelessWidget {
  const SupportSoftPill({super.key, required this.label, required this.color, this.icon, this.maxLines = 1});

  final String label;
  final Color color;
  final IconData? icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final icon = this.icon;
    return DecoratedBox(
      decoration: BoxDecoration(color: supportSoftBackground(style, color), borderRadius: style.radii.pillRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: style.spacing.sm, vertical: style.spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: color), SizedBox(width: style.spacing.xs)],
            Flexible(
              child: Text(
                label,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: style.typography.badge.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportIconCircle extends StatelessWidget {
  const SupportIconCircle({super.key, required this.icon, required this.color, this.size = 40, this.filled = false});

  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: filled ? color : supportSoftBackground(style, color), shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.5, color: filled ? style.onAccent : color),
      ),
    );
  }
}

class SupportNoticeBox extends StatelessWidget {
  const SupportNoticeBox({super.key, required this.message, required this.tone, this.icon});

  final String message;
  final CommunitySupportTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final color = supportToneColor(context, tone);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm + spacing.xxs),
      decoration: BoxDecoration(
        color: supportSoftBackground(style, color),
        borderRadius: style.radii.controlRadius,
        border: Border.all(color: color.withValues(alpha: 0.3), width: style.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? Icons.info_outline, size: 18, color: color),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(message, style: style.typography.meta.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
