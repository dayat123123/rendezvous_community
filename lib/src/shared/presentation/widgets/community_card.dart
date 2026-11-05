import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final details = CommunityCardDetails(
      child: child,
      padding: padding ?? CommunityStyle.of(context).spacing.card,
      margin: margin,
      selected: selected,
      onTap: onTap,
      onLongPress: onLongPress,
    );
    return buildSharedPart((b) => b.card, context, details, _DefaultCard(details: details));
  }
}

class _DefaultCard extends StatelessWidget {
  const _DefaultCard({required this.details});

  final CommunityCardDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final tappable = details.onTap != null || details.onLongPress != null;
    final content = Padding(padding: details.padding, child: details.child);
    final card = Material(
      color: style.surface,
      shape: style.cardShape(selected: details.selected),
      clipBehavior: tappable ? Clip.antiAlias : Clip.none,
      child: tappable ? InkWell(onTap: details.onTap, onLongPress: details.onLongPress, child: content) : content,
    );
    final margin = details.margin;
    return margin == null ? card : Padding(padding: margin, child: card);
  }
}
