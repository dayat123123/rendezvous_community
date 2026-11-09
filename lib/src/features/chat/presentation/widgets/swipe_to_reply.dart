import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

enum CommunitySwipeDirection { right, left }

class CommunitySwipeToReplySettings {
  const CommunitySwipeToReplySettings({
    this.enabled = true,
    this.threshold = 56,
    this.mine = CommunitySwipeDirection.right,
    this.others = CommunitySwipeDirection.right,
    this.haptic = true,
  }) : assert(threshold > 0);

  final bool enabled;
  final double threshold;
  final CommunitySwipeDirection mine;
  final CommunitySwipeDirection others;
  final bool haptic;
}

class CommunitySwipeToReplyScope extends InheritedWidget {
  const CommunitySwipeToReplyScope({super.key, required this.settings, required super.child});

  final CommunitySwipeToReplySettings settings;

  static CommunitySwipeToReplySettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommunitySwipeToReplyScope>()?.settings ??
      const CommunitySwipeToReplySettings();

  @override
  bool updateShouldNotify(CommunitySwipeToReplyScope oldWidget) => settings != oldWidget.settings;
}

class SwipeToReply extends StatefulWidget {
  const SwipeToReply({super.key, required this.onReply, required this.child, this.mine = false});

  final VoidCallback? onReply;
  final Widget child;
  final bool mine;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  static const _touch = {PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.invertedStylus};

  late final AnimationController _offset;
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _offset = AnimationController(
      vsync: this,
      upperBound: double.infinity,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails details, CommunitySwipeToReplySettings settings, double sign) {
    final delta = (details.primaryDelta ?? 0) * sign;
    final trigger = settings.threshold;
    final current = _offset.value;
    _offset.value = (current + (current >= trigger && delta > 0 ? delta * 0.3 : delta)).clamp(0.0, trigger * 1.6);
    final armed = _offset.value >= trigger;
    if (armed && !_armed && settings.haptic) HapticFeedback.lightImpact();
    _armed = armed;
  }

  void _release([Object? _]) {
    if (_armed) widget.onReply?.call();
    _armed = false;
    _offset.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final settings = CommunitySwipeToReplyScope.of(context);
    if (widget.onReply == null || !settings.enabled) return widget.child;
    final style = CommunityStyle.of(context);
    final direction = widget.mine ? settings.mine : settings.others;
    final sign = direction == CommunitySwipeDirection.right ? 1.0 : -1.0;
    final trigger = settings.threshold;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      supportedDevices: _touch,
      onHorizontalDragUpdate: (details) => _drag(details, settings, sign),
      onHorizontalDragEnd: _release,
      onHorizontalDragCancel: _release,
      child: AnimatedBuilder(
        animation: _offset,
        child: widget.child,
        builder: (context, child) {
          final distance = _offset.value;
          final progress = (distance / trigger).clamp(0.0, 1.0);
          return Stack(
            children: [
              if (distance > 0)
                Positioned(
                  left: sign > 0 ? style.spacing.md : null,
                  right: sign < 0 ? style.spacing.md : null,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: progress,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * progress,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: style.surface, shape: BoxShape.circle),
                          child: Padding(
                            padding: EdgeInsets.all(style.spacing.xs + style.spacing.xxs),
                            child: Icon(Icons.reply, size: 18, color: style.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(offset: Offset(distance * sign, 0), child: child),
            ],
          );
        },
      ),
    );
  }
}
