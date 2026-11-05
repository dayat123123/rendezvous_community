import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityTag extends StatelessWidget {
  const CommunityTag({super.key, required this.label, this.icon, this.selected = false, this.onTap});

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final details = CommunityTagDetails(label: label, icon: icon, selected: selected, onTap: onTap);
    return buildSharedPart((b) => b.tag, context, details, _DefaultTag(details: details));
  }
}

class _DefaultTag extends StatelessWidget {
  const _DefaultTag({required this.details});

  final CommunityTagDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final selected = details.selected;
    final foreground = selected ? style.accent : style.onChip;
    final icon = details.icon;
    final onTap = details.onTap;
    return RawChip(
      label: Text(details.label),
      avatar: icon == null ? null : Icon(icon, size: 16, color: foreground),
      onPressed: onTap,
      tapEnabled: onTap != null,
      selected: selected,
      showCheckmark: false,
      backgroundColor: style.chip,
      selectedColor: style.accentMuted,
      disabledColor: style.chip,
      isEnabled: true,
      labelStyle: style.typography.label.copyWith(color: foreground),
      labelPadding: EdgeInsets.symmetric(horizontal: style.spacing.xxs),
      padding: EdgeInsets.symmetric(horizontal: icon == null ? style.spacing.sm : style.spacing.xs + style.spacing.xxs),
      shape: const StadiumBorder(),
      side: selected
          ? BorderSide(color: style.accent.withValues(alpha: 0.35), width: style.borderWidth)
          : style.borderSide,
      visualDensity: onTap == null ? VisualDensity.compact : const VisualDensity(horizontal: -2),
      materialTapTargetSize: onTap == null ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
    );
  }
}
