import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

typedef ChatFilesReceiver = void Function(List<XFile> files);

class ChatFileDropSlot {
  ChatFilesReceiver? _receiver;

  bool get ready => _receiver != null;

  void attach(ChatFilesReceiver receiver) => _receiver = receiver;

  void detach(ChatFilesReceiver receiver) {
    if (_receiver == receiver) _receiver = null;
  }

  void deliver(List<XFile> files) => _receiver?.call(files);
}

class ChatFileDropZone extends StatefulWidget {
  const ChatFileDropZone({super.key, required this.child});

  final Widget child;

  static ChatFileDropSlot? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_DropScope>()?.slot;

  @override
  State<ChatFileDropZone> createState() => _ChatFileDropZoneState();
}

class _ChatFileDropZoneState extends State<ChatFileDropZone> {
  final _slot = ChatFileDropSlot();
  bool _hovering = false;

  void _hover(bool value) {
    if (_hovering != value) setState(() => _hovering = value);
  }

  void _done(DropDoneDetails details) {
    _hover(false);
    final files = [
      for (final item in details.files)
        if (item is! DropItemDirectory) item,
    ];
    if (files.isNotEmpty) _slot.deliver(files);
  }

  @override
  Widget build(BuildContext context) => DropTarget(
    onDragEntered: (_) => _hover(true),
    onDragExited: (_) => _hover(false),
    onDragDone: _done,
    child: _DropScope(
      slot: _slot,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (_hovering && _slot.ready) const Positioned.fill(child: IgnorePointer(child: _DropOverlay())),
        ],
      ),
    ),
  );
}

class _DropScope extends InheritedWidget {
  const _DropScope({required this.slot, required super.child});

  final ChatFileDropSlot slot;

  @override
  bool updateShouldNotify(_DropScope old) => !identical(slot, old.slot);
}

class _DropOverlay extends StatelessWidget {
  const _DropOverlay();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return ColoredBox(
      color: style.background.withValues(alpha: 0.85),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: style.accent, width: 2),
            borderRadius: BorderRadius.circular(spacing.sm),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_upload_outlined, size: 40, color: style.accent),
                SizedBox(height: spacing.sm),
                Text(
                  context.communityL10n.dropFilesHere,
                  style: style.typography.label.copyWith(color: style.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
