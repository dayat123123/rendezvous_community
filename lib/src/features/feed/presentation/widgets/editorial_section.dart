import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';

class EditorialSection extends StatelessWidget {
  const EditorialSection({super.key, required this.child, this.padding, this.onTap, this.gap = true});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool gap;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final content = Padding(padding: padding ?? style.spacing.card, child: child);
    final tap = onTap;
    final section = Material(
      color: style.surface,
      child: tap == null ? content : InkWell(onTap: tap, child: content),
    );
    return gap
        ? Padding(
            padding: EdgeInsets.only(bottom: style.sectionGap),
            child: section,
          )
        : section;
  }
}

class EditorialSectionHeader extends StatelessWidget {
  const EditorialSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.divider = true,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final details = CommunitySectionHeaderDetails(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    return buildSharedPart(
      (b) => b.sectionHeader,
      context,
      details,
      _DefaultEditorialHeader(details: details, icon: icon, divider: divider),
    );
  }
}

class _DefaultEditorialHeader extends StatelessWidget {
  const _DefaultEditorialHeader({required this.details, required this.icon, required this.divider});

  final CommunitySectionHeaderDetails details;
  final IconData? icon;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final icon = this.icon;
    final action = details.onAction;
    final label = details.actionLabel;
    final subtitle = details.subtitle;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.minTouchTarget),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 20, color: style.accent), SizedBox(width: spacing.sm + spacing.xxs)],
            Expanded(
              child: Semantics(
                header: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(details.title, style: style.typography.sectionTitle.copyWith(fontSize: 16)),
                    if (subtitle != null) Text(subtitle, style: style.typography.meta),
                  ],
                ),
              ),
            ),
            if (label != null) ...[
              SizedBox(width: spacing.sm),
              Text(label, style: style.typography.label.copyWith(color: style.accent)),
            ],
            if (action != null)
              Icon(Icons.chevron_right, size: 20, color: label != null ? style.accent : style.textSecondary),
          ],
        ),
      ),
    );
    return Material(
      color: style.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          action == null ? row : InkWell(onTap: action, child: row),
          if (divider) const CommunityDivider(),
        ],
      ),
    );
  }
}
