import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class FollowToggleButton extends StatelessWidget {
  const FollowToggleButton({
    super.key,
    required this.label,
    required this.following,
    required this.semanticName,
    this.onPressed,
  });

  final String label;
  final bool following;
  final String semanticName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    const density = VisualDensity.compact;
    final padding = EdgeInsets.symmetric(horizontal: style.spacing.md);
    return Semantics(
      label: '$label $semanticName',
      container: true,
      button: true,
      excludeSemantics: true,
      child: following
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                visualDensity: density,
                padding: padding,
                foregroundColor: style.textPrimary,
                side: style.borderSide,
                shape: const StadiumBorder(),
                textStyle: style.typography.label,
              ),
              child: Text(label),
            )
          : FilledButton(
              onPressed: onPressed,
              style: style.primaryButtonStyle().copyWith(
                visualDensity: density,
                padding: WidgetStatePropertyAll(padding),
                textStyle: WidgetStatePropertyAll(style.typography.label),
              ),
              child: Text(label),
            ),
    );
  }
}
