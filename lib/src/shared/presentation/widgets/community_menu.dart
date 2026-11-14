import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

const double communityMenuIconGap = 10;

PopupMenuItem<T> communityMenuItem<T>(
  BuildContext context, {
  required T value,
  required String label,
  IconData? icon,
  bool danger = false,
  bool? checked,
  bool enabled = true,
  Color? color,
  Key? key,
}) {
  final style = CommunityStyle.of(context);
  final textColor = danger ? style.danger : color ?? style.textPrimary;
  final iconColor = danger ? style.danger : color ?? style.textSecondary;
  final leading = checked == null ? icon : (checked ? style.icons.check : null);
  final hasLeading = checked != null || icon != null;
  return PopupMenuItem<T>(
    key: key,
    value: value,
    enabled: enabled,
    height: style.menuItemHeight,
    child: Row(
      children: [
        if (hasLeading) ...[
          if (leading == null)
            SizedBox.square(dimension: style.menuIconSize)
          else
            Icon(leading, size: style.menuIconSize, color: iconColor),
          const SizedBox(width: communityMenuIconGap),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.typography.body.copyWith(fontSize: 12, color: textColor),
          ),
        ),
      ],
    ),
  );
}
