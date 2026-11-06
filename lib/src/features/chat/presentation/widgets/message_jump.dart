import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class MessageJumpScope extends InheritedWidget {
  const MessageJumpScope({super.key, required this.reveal, required this.highlighted, required super.child});

  final Future<void> Function(String messageId) reveal;
  final ValueListenable<String?> highlighted;

  static MessageJumpScope? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<MessageJumpScope>();

  @override
  bool updateShouldNotify(MessageJumpScope oldWidget) =>
      reveal != oldWidget.reveal || highlighted != oldWidget.highlighted;
}

class MessageAnchors {
  final _items = <String, _MessageAnchorState>{};

  BuildContext? contextOf(String id) {
    final item = _items[id];
    return item != null && item.mounted ? item.context : null;
  }

  (int, int)? get builtRange {
    int? low;
    int? high;
    for (final item in _items.values) {
      if (!item.mounted) continue;
      final index = item.widget.index;
      if (low == null || index < low) low = index;
      if (high == null || index > high) high = index;
    }
    return low == null ? null : (low, high!);
  }
}

class MessageAnchor extends StatefulWidget {
  const MessageAnchor({
    super.key,
    required this.id,
    required this.index,
    required this.anchors,
    required this.highlighted,
    required this.child,
  });

  final String id;
  final int index;
  final MessageAnchors anchors;
  final ValueListenable<String?> highlighted;
  final Widget child;

  @override
  State<MessageAnchor> createState() => _MessageAnchorState();
}

class _MessageAnchorState extends State<MessageAnchor> {
  @override
  void initState() {
    super.initState();
    widget.anchors._items[widget.id] = this;
  }

  @override
  void didUpdateWidget(MessageAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.anchors != widget.anchors) {
      if (identical(oldWidget.anchors._items[oldWidget.id], this)) oldWidget.anchors._items.remove(oldWidget.id);
      widget.anchors._items[widget.id] = this;
    }
  }

  @override
  void dispose() {
    if (identical(widget.anchors._items[widget.id], this)) widget.anchors._items.remove(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = CommunityStyle.of(context).accent.withValues(alpha: 0.16);
    return ValueListenableBuilder<String?>(
      valueListenable: widget.highlighted,
      child: widget.child,
      builder: (context, id, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        color: id == widget.id ? color : color.withValues(alpha: 0),
        child: child,
      ),
    );
  }
}
