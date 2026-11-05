import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunitySectionHeader extends StatelessWidget {
  const CommunitySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final details = CommunitySectionHeaderDetails(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      trailing: trailing,
    );
    return buildSharedPart(
      (b) => b.sectionHeader,
      context,
      details,
      _DefaultSectionHeader(details: details, padding: padding),
    );
  }
}

class _DefaultSectionHeader extends StatelessWidget {
  const _DefaultSectionHeader({required this.details, this.padding});

  final CommunitySectionHeaderDetails details;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final subtitle = details.subtitle;
    final actionLabel = details.actionLabel;
    final trailing = details.trailing;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.sm, spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details.title, style: style.typography.sectionTitle),
                  if (subtitle != null) ...[
                    SizedBox(height: spacing.xxs),
                    Text(subtitle, style: style.typography.meta),
                  ],
                ],
              ),
            ),
          ),
          ?trailing,
          if (actionLabel != null)
            TextButton(
              onPressed: details.onAction,
              style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}
