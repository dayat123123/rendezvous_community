import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

String communityCountText(BuildContext context, int count) {
  final tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
  final locale = Intl.verifiedLocale(tag, NumberFormat.localeExists, onFailure: (_) => 'en');
  return NumberFormat.compact(locale: locale).format(count);
}

class CommunityActionPill extends StatelessWidget {
  const CommunityActionPill({
    super.key,
    required this.icon,
    this.activeIcon,
    this.label,
    this.count,
    this.active = false,
    this.tooltip,
    this.onPressed,
    this.activeColor,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final int? count;
  final bool active;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final details = CommunityActionPillDetails(
      icon: icon,
      activeIcon: activeIcon,
      label: label,
      count: count,
      countLabel: count == null || count <= 0 ? null : communityCountText(context, count),
      active: active,
      tooltip: tooltip,
      onPressed: onPressed,
      activeColor: activeColor,
    );
    return buildSharedPart((b) => b.actionPill, context, details, _DefaultActionPill(details: details));
  }
}

class _DefaultActionPill extends StatelessWidget {
  const _DefaultActionPill({required this.details});

  final CommunityActionPillDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final active = details.active;
    final tint = details.activeColor ?? style.accent;
    final foreground = active ? tint : style.onPill;
    final text = details.text;
    final side = active ? BorderSide(color: tint.withValues(alpha: 0.35), width: style.borderWidth) : style.borderSide;
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: active ? (details.activeColor?.withValues(alpha: 0.10) ?? style.accentMuted) : style.pill,
      disabledForegroundColor: style.textTertiary,
      disabledBackgroundColor: style.pill,
      textStyle: style.typography.label,
      shape: StadiumBorder(side: side),
      minimumSize: Size(style.minTouchTarget - style.spacing.xs, 34),
      padding: EdgeInsets.symmetric(horizontal: text == null ? style.spacing.sm : style.spacing.md),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final icon = CommunityBump(active: active, child: Icon(details.effectiveIcon, size: 18));
    final Widget button = text == null
        ? TextButton(onPressed: details.onPressed, style: buttonStyle, child: icon)
        : TextButton.icon(onPressed: details.onPressed, style: buttonStyle, icon: icon, label: Text(text));
    final tooltip = details.tooltip;
    final semantic = Semantics(selected: active ? true : null, child: button);
    return tooltip == null ? semantic : Tooltip(message: tooltip, child: semantic);
  }
}

class CommunityBump extends StatefulWidget {
  const CommunityBump({super.key, required this.active, required this.child, this.scale = 1.15});

  final bool active;
  final Widget child;
  final double scale;

  @override
  State<CommunityBump> createState() => _CommunityBumpState();
}

class _CommunityBumpState extends State<CommunityBump> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;

  @override
  void didUpdateWidget(CommunityBump oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active || !widget.active || MediaQuery.maybeDisableAnimationsOf(context) == true) return;
    final controller = _controller ??= AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale ??= TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: widget.scale), weight: 1),
      TweenSequenceItem(tween: Tween(begin: widget.scale, end: 1), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scale;
    return scale == null ? widget.child : ScaleTransition(scale: scale, child: widget.child);
  }
}

class CommunityActionButton extends StatelessWidget {
  const CommunityActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.activeIcon,
    this.count,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final IconData? activeIcon;
  final int? count;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final count = this.count;
    final details = CommunityActionButtonDetails(
      icon: icon,
      tooltip: tooltip,
      activeIcon: activeIcon,
      count: count,
      countLabel: count == null || count <= 0 ? null : communityCountText(context, count),
      active: active,
      onPressed: onPressed,
    );
    return buildSharedPart((b) => b.actionButton, context, details, _DefaultActionButton(details: details));
  }
}

class _DefaultActionButton extends StatelessWidget {
  const _DefaultActionButton({required this.details});

  final CommunityActionButtonDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final color = details.active ? style.accent : style.textSecondary;
    final countLabel = details.countLabel;
    final icon = CommunityBump(active: details.active, child: Icon(details.effectiveIcon, size: 20));
    if (countLabel == null) {
      return IconButton(
        tooltip: details.tooltip,
        onPressed: details.onPressed,
        color: color,
        disabledColor: style.textTertiary,
        isSelected: details.active,
        icon: icon,
      );
    }
    return Tooltip(
      message: details.tooltip,
      child: Semantics(
        selected: details.active ? true : null,
        child: TextButton.icon(
          onPressed: details.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color,
            disabledForegroundColor: style.textTertiary,
            textStyle: style.typography.label,
            shape: const StadiumBorder(),
            minimumSize: Size(style.minTouchTarget, style.minTouchTarget),
            padding: EdgeInsets.symmetric(horizontal: style.spacing.sm + style.spacing.xxs),
          ),
          icon: icon,
          label: Text(countLabel),
        ),
      ),
    );
  }
}

class CommunityActionBar extends StatelessWidget {
  const CommunityActionBar({super.key, this.leading = const [], this.trailing = const []});

  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final details = CommunityActionBarDetails(leading: leading, trailing: trailing);
    return buildSharedPart((b) => b.actionBar, context, details, _DefaultActionBar(details: details));
  }
}

class _DefaultActionBar extends StatelessWidget {
  const _DefaultActionBar({required this.details});

  final CommunityActionBarDetails details;

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    return Row(
      children: [
        Expanded(
          child: Wrap(spacing: spacing.sm, crossAxisAlignment: WrapCrossAlignment.center, children: details.leading),
        ),
        if (details.trailing.isNotEmpty) Row(mainAxisSize: MainAxisSize.min, children: details.trailing),
      ],
    );
  }
}
