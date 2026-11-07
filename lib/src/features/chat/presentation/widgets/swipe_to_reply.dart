import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class SwipeToReply extends StatefulWidget {
  const SwipeToReply({super.key, required this.onReply, required this.child});

  final VoidCallback? onReply;
  final Widget child;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  static const _trigger = 56.0;
  static const _limit = 88.0;
  static const _touch = {PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.invertedStylus};

  late final AnimationController _offset;
  bool _armed = false;

  @override
  void initState() {
    super.initState();
    _offset = AnimationController(vsync: this, upperBound: _limit, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final current = _offset.value;
    _offset.value = (current + (current >= _trigger && delta > 0 ? delta * 0.3 : delta)).clamp(0.0, _limit);
    final armed = _offset.value >= _trigger;
    if (armed && !_armed) HapticFeedback.lightImpact();
    _armed = armed;
  }

  void _release([Object? _]) {
    if (_armed) widget.onReply?.call();
    _armed = false;
    _offset.animateBack(0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onReply == null) return widget.child;
    final style = CommunityStyle.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      supportedDevices: _touch,
      onHorizontalDragUpdate: _drag,
      onHorizontalDragEnd: _release,
      onHorizontalDragCancel: _release,
      child: AnimatedBuilder(
        animation: _offset,
        child: widget.child,
        builder: (context, child) {
          final dx = _offset.value;
          final progress = (dx / _trigger).clamp(0.0, 1.0);
          return Stack(
            children: [
              if (dx > 0)
                Positioned(
                  left: style.spacing.md,
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
              Transform.translate(offset: Offset(dx, 0), child: child),
            ],
          );
        },
      ),
    );
  }
}
