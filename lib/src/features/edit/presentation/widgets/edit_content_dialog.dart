import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_composer_field.dart';

Future<String?> showEditContentDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required int maxLength,
}) {
  final builder = CommunityFeedBuilders.of(context, listen: false).editDialog;
  return showDialog<String>(
    context: context,
    builder: (_) => _EditContentDialog(title: title, initial: initial, maxLength: maxLength, builder: builder),
  );
}

class _EditContentDialog extends StatefulWidget {
  const _EditContentDialog({required this.title, required this.initial, required this.maxLength, this.builder});

  final String title;
  final String initial;
  final int maxLength;
  final CommunityPartBuilder<CommunityEditDialogDetails>? builder;

  @override
  State<_EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<_EditContentDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty || text == widget.initial.trim()) return Navigator.pop(context);
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final border = OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide);
    final details = CommunityEditDialogDetails(
      title: widget.title,
      controller: _controller,
      maxLength: widget.maxLength,
      saveLabel: l10n.save,
      cancelLabel: l10n.cancel,
      field: CommunityComposerField(
        controller: _controller,
        hintText: widget.title,
        maxLength: widget.maxLength,
        minLines: 3,
        maxLines: 10,
        autofocus: true,
        onSubmit: _save,
        decoration: InputDecoration(
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: style.accent, width: style.borderWidth),
          ),
          hintStyle: style.typography.body.copyWith(color: style.textSecondary),
        ),
      ),
      onSave: _save,
      onCancel: () => Navigator.pop(context),
    );
    return buildCommunityPart(widget.builder, context, details, _DefaultEditDialog(details: details));
  }
}

class _DefaultEditDialog extends StatelessWidget {
  const _DefaultEditDialog({required this.details});

  final CommunityEditDialogDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      title: Text(details.title, style: style.typography.title),
      content: SizedBox(width: 520, child: details.field),
      actions: [
        TextButton(
          onPressed: details.onCancel,
          style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
          child: Text(details.cancelLabel),
        ),
        FilledButton(onPressed: details.onSave, style: style.primaryButtonStyle(), child: Text(details.saveLabel)),
      ],
    );
  }
}
