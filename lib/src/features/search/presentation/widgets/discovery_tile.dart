import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class DiscoveryTile extends StatelessWidget {
  const DiscoveryTile({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.footer,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final footer = this.footer;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: style.minTouchTarget + spacing.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm + spacing.xxs),
          child: Row(
            children: [
              leading,
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.author),
                    if (subtitle != null) ...[
                      SizedBox(height: spacing.xxs),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                    ],
                    if (footer != null) ...[SizedBox(height: spacing.xs + spacing.xxs), footer],
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: spacing.sm), trailing],
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoveryIcon extends StatelessWidget {
  const DiscoveryIcon({super.key, this.icon, this.text});

  final IconData? icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final size = style.avatarSizes.post;
    final text = this.text;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: style.pill, shape: BoxShape.circle),
      child: text == null
          ? Icon(icon, size: 18, color: style.textSecondary)
          : Text(text, style: style.typography.label.copyWith(color: style.textPrimary)),
    );
  }
}
