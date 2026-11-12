import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/core/media/clipboard_image.dart';
import 'package:rendezvous_community/src/core/media/pasted_image.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/outgoing_file.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/attachment_picker.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/stock_cards.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/document_type.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_composer_field.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

typedef CommunityFilesPicker =
    Future<List<XFile>> Function({
      List<XTypeGroup> acceptedTypeGroups,
      String? initialDirectory,
      String? confirmButtonText,
    });

const _controlSize = 48.0;
const _maxFiles = 4;
const _thumbSize = 56.0;

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    this.onChanged,
    this.leading = const [],
    this.allowDocuments = false,
    this.clipboardImage = readClipboardImage,
    this.attachmentPolicy,
    this.openFilesPicker = openFiles,
  });

  final ValueChanged<String>? onChanged;
  final List<Widget> leading;
  final bool allowDocuments;
  final ClipboardImageReader clipboardImage;
  final CommunityAttachmentPolicy? attachmentPolicy;
  final CommunityFilesPicker openFilesPicker;

  CommunityAttachmentPolicy get policy =>
      allowDocuments ? attachmentPolicy ?? CommunityAttachmentPolicy.legacy : CommunityAttachmentPolicy.imagesOnly;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  static const _maxLength = 4000;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _files = <ChatOutgoingFile>[];
  Timer? _ticker;

  void _syncTicker(Duration cooldown) {
    if (cooldown > Duration.zero) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final left = context.read<ChatRoomCubit>().state.cooldownLeft();
        setState(() {});
        if (left == Duration.zero) {
          _ticker?.cancel();
          _ticker = null;
        }
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<ChatRoomCubit>().onTextChanged(_controller.text);
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final cubit = context.read<ChatRoomCubit>();
    final text = _controller.text;
    if (cubit.state.editing != null) {
      if (text.trim().isEmpty) return;
      _focus.requestFocus();
      await cubit.saveEdit(text);
      return;
    }
    final files = List.of(_files);
    if (text.trim().isEmpty && files.isEmpty) return;
    if (cubit.state.cooldownLeft() > Duration.zero || cubit.state.uploading) return;
    _focus.requestFocus();
    if (files.isEmpty) {
      _controller.clear();
      await cubit.send(text);
      return;
    }
    if (!await cubit.sendWithFiles(text, files) || !mounted) return;
    setState(() => _files.removeWhere(files.contains));
    if (_controller.text == text) _controller.clear();
  }

  void _addFiles(List<ChatOutgoingFile> files) {
    if (files.isEmpty || !mounted) return;
    final room = _maxFiles - _files.length;
    if (files.length > room) showCommunityMessage(context, context.communityL10n.attachmentsTooMany);
    if (room <= 0) return;
    setState(() => _files.addAll(files.take(room)));
    _focus.requestFocus();
  }

  void _removeFile(int index) {
    if (index < 0 || index >= _files.length) return;
    setState(() => _files.removeAt(index));
  }

  Future<void> _pickImage() async {
    if (context.read<ChatRoomCubit>().state.uploading) return;
    final l10n = context.communityL10n;
    final policy = widget.policy;
    final groups = attachmentTypeGroups(policy, l10n);
    if (groups.isEmpty) return;
    final picked = await widget.openFilesPicker(acceptedTypeGroups: groups);
    if (picked.isEmpty || !mounted) return;
    final result = await prepareAttachments(picked.take(_maxFiles + 1).toList(), policy, l10n);
    if (!mounted) return;
    for (final error in result.errors) {
      showCommunityMessage(context, error);
    }
    _addFiles(result.files);
  }

  Future<bool> _pasteImage() async {
    final raw = await widget.clipboardImage();
    if (raw == null || !mounted) return false;
    unawaited(_stageImage(raw));
    return true;
  }

  Future<void> _stageImage(Uint8List raw) async {
    final image = await preparePastedImage(raw);
    if (!mounted) return;
    if (image == null) {
      showCommunityMessage(context, context.communityL10n.pasteImageFailed);
      return;
    }
    _addFiles([ChatOutgoingFile(bytes: image.bytes, mimeType: image.mimeType)]);
  }

  Future<void> _pickStockCards() async {
    final cubit = context.read<ChatRoomCubit>();
    final codes = await showStockCardPicker(context);
    if (codes != null && codes.isNotEmpty) await cubit.sendStockCards(codes);
  }

  String _attachLabel(CommunityLocalizations l10n) {
    final policy = widget.policy;
    if (!widget.allowDocuments) return l10n.composeAddImage;
    if (policy.videos.usable || !policy.onlyPdfDocuments) return l10n.composeAttachFiles;
    return l10n.composeAddImageOrPdf;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final builder = CommunityChatBuilders.of(context).composer;
    return BlocConsumer<ChatRoomCubit, ChatRoomState>(
      listenWhen: (a, b) => (a.replyTo?.id != b.replyTo?.id && b.replyTo != null) || a.editing?.id != b.editing?.id,
      listener: (_, state) {
        final editing = state.editing;
        if (editing != null) {
          final body = editing.body ?? '';
          _controller.value = TextEditingValue(
            text: body,
            selection: TextSelection.collapsed(offset: body.length),
          );
        } else if (state.replyTo == null) {
          _controller.clear();
        }
        _focus.requestFocus();
      },
      buildWhen: (a, b) =>
          a.editing != b.editing ||
          a.replyTo != b.replyTo ||
          a.uploading != b.uploading ||
          a.cooldownUntil != b.cooldownUntil ||
          a.mutedUntil() != b.mutedUntil(),
      builder: (context, state) {
        final replyTo = state.replyTo;
        final replyName = replyTo == null
            ? null
            : state.isMine(replyTo)
            ? l10n.you
            : replyTo.sender?.name ?? l10n.someone;
        final cooldown = state.cooldownLeft();
        _syncTicker(cooldown);
        final editing = state.editing;
        final cubit = context.read<ChatRoomCubit>();
        final details = CommunityComposerDetails(
          controller: _controller,
          focusNode: _focus,
          hintText: l10n.messageHint,
          maxLength: _maxLength,
          uploading: state.uploading,
          onSend: _send,
          replyTo: replyTo,
          replyToName: replyName,
          replyPreview: replyTo == null ? null : '$replyName: ${replyTo.body ?? l10n.attachment}',
          onCancelReply: replyTo == null ? null : () => context.read<ChatRoomCubit>().setReplyTo(null),
          onPickImage: editing == null ? _pickImage : null,
          allowsDocuments: widget.allowDocuments,
          attachmentPolicy: widget.policy,
          attachLabel: _attachLabel(l10n),
          uploadingLabel: state.uploading ? l10n.attachmentChecking : null,
          extraActions: widget.leading,
          cooldown: cooldown,
          onSendStockCard: editing == null && cubit.canSendStockCards ? _pickStockCards : null,
          mutedUntil: state.mutedUntil(),
          onPaste: _pasteImage,
          onContentInserted: (bytes) => unawaited(_stageImage(bytes)),
          files: List.unmodifiable(_files),
          onRemoveFile: _removeFile,
          editing: editing,
          editingLabel: editing == null ? null : l10n.editingMessage,
          onCancelEdit: editing == null ? null : cubit.cancelEditing,
        );
        final composer = buildChatPart(builder, context, details, DefaultMessageComposer(details: details));
        if (editing == null) return composer;
        return CallbackShortcuts(
          bindings: {const SingleActivator(LogicalKeyboardKey.escape): cubit.cancelEditing},
          child: composer,
        );
      },
    );
  }
}

class DefaultMessageComposer extends StatelessWidget {
  const DefaultMessageComposer({super.key, required this.details});

  final CommunityComposerDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final replyTo = d.replyTo;
    final text = style.typography.body.copyWith(color: style.textPrimary);
    final lineHeight = (text.fontSize ?? 15) * (text.height ?? 1.5);
    final vertical = ((_controlSize - lineHeight) / 2).clamp(spacing.sm, spacing.lg);

    return Material(
      color: style.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...d.extraActions,
              if (d.onSendStockCard != null)
                SizedBox.square(
                  dimension: _controlSize,
                  child: IconButton(
                    tooltip: l10n.stockCardSend,
                    color: style.textSecondary,
                    onPressed: d.enabled ? d.onSendStockCard : null,
                    icon: const Icon(Icons.candlestick_chart_outlined),
                  ),
                ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: style.pill, borderRadius: BorderRadius.circular(_controlSize / 2)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (d.editing case final editing?)
                        Padding(
                          padding: EdgeInsets.fromLTRB(spacing.xs + 2, spacing.xs + 2, spacing.xs + 2, 0),
                          child: _EditingBanner(
                            label: d.editingLabel ?? l10n.editingMessage,
                            original: editing.body ?? '',
                            onCancel: d.onCancelEdit,
                          ),
                        ),
                      if (replyTo != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(spacing.xs + 2, spacing.xs + 2, spacing.xs + 2, 0),
                          child: _ReplyPreview(
                            message: replyTo,
                            name: d.replyToName ?? l10n.someone,
                            onCancel: d.onCancelReply,
                          ),
                        ),
                      if (d.uploadingLabel != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, 0),
                          child: _CheckingLabel(label: d.uploadingLabel!),
                        ),
                      if (d.files.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm + spacing.xxs, spacing.md, 0),
                          child: _PendingFiles(files: d.files, onRemove: d.onRemoveFile),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (d.onPickImage == null)
                            SizedBox(width: spacing.md)
                          else
                            SizedBox.square(
                              dimension: _controlSize,
                              child: IconButton(
                                tooltip:
                                    d.attachLabel ??
                                    (d.allowsDocuments ? l10n.composeAddImageOrPdf : l10n.composeAddImage),
                                color: style.textSecondary,
                                onPressed: d.uploading || !d.enabled ? null : d.onPickImage,
                                icon: d.uploading
                                    ? SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: style.accent),
                                      )
                                    : Icon(d.allowsDocuments ? Icons.attach_file : Icons.add_photo_alternate_outlined),
                              ),
                            ),
                          Expanded(
                            child: CommunityComposerField(
                              fieldKey: d.fieldKey,
                              controller: d.controller,
                              focusNode: d.focusNode,
                              enabled: d.enabled,
                              enableAutocomplete: d.enableAutocomplete,
                              hintText: d.hintText,
                              maxLength: d.maxLength,
                              maxLines: 5,
                              onSubmit: d.enabled ? d.onSend : null,
                              onPaste: d.onPaste,
                              onContentInserted: d.onContentInserted,
                              style: text,
                              decoration: InputDecoration(
                                filled: false,
                                hintStyle: text.copyWith(color: style.textSecondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: vertical),
                                counterText: '',
                                isDense: true,
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.md),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing.xs + spacing.xxs),
              _SendButton(details: d),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.details});

  final CommunityComposerDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final round = IconButton.styleFrom(fixedSize: const Size.square(_controlSize));
    if (d.muted) {
      return Tooltip(
        message: l10n.roomMutedComposer,
        child: IconButton.filled(style: round, onPressed: null, icon: const Icon(Icons.volume_off_outlined)),
      );
    }
    if (d.coolingDown) {
      return Tooltip(
        message: l10n.errorSlowMode(d.cooldownSeconds),
        child: SizedBox(
          height: _controlSize,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            onPressed: null,
            child: Text(l10n.slowModeWait(d.cooldownSeconds)),
          ),
        ),
      );
    }
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: d.controller,
      builder: (context, value, _) {
        final empty = value.text.trim().isEmpty && d.files.isEmpty;
        return IconButton.filled(
          key: d.sendKey,
          tooltip: l10n.composeSubmit,
          style: IconButton.styleFrom(
            backgroundColor: empty ? style.pill : style.accent,
            foregroundColor: empty ? style.textTertiary : style.onAccent,
            fixedSize: const Size.square(_controlSize),
          ),
          onPressed: d.enabled ? d.onSend : null,
          icon: const Icon(Icons.send, size: 22),
        );
      },
    );
  }
}

class _PendingFiles extends StatelessWidget {
  const _PendingFiles({required this.files, this.onRemove});

  final List<ChatOutgoingFile> files;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        for (final (index, file) in files.indexed)
          _PendingFile(file: file, onRemove: onRemove == null ? null : () => onRemove!(index)),
      ],
    );
  }
}

IconData _pendingIcon(ChatOutgoingFile file) {
  if (file.video) return Icons.videocam_outlined;
  return documentTypeIcon(documentTypeOf(Attachment(path: file.name ?? '', mime: file.mimeType, name: file.name)));
}

class _CheckingLabel extends StatelessWidget {
  const _CheckingLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: style.accent)),
          SizedBox(width: style.spacing.sm),
          Flexible(
            child: Text(label, style: style.typography.meta.copyWith(color: style.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _PendingFile extends StatelessWidget {
  const _PendingFile({required this.file, this.onRemove});

  final ChatOutgoingFile file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final radius = BorderRadius.circular(spacing.sm);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final Widget body = file.kind != CommunityAttachmentKind.image
        ? Container(
            height: _thumbSize,
            width: 176,
            padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs),
            decoration: BoxDecoration(
              color: style.surface,
              borderRadius: radius,
              border: Border.all(color: style.border, width: style.borderWidth),
            ),
            child: Row(
              children: [
                Icon(_pendingIcon(file), size: 20, color: style.textSecondary),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name ?? (file.video ? l10n.video : l10n.documentTypeOther),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.label.copyWith(color: style.textPrimary),
                      ),
                      Text(documentSize(file.size), style: style.typography.meta.copyWith(color: style.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          )
        : ClipRRect(
            borderRadius: radius,
            child: Image.memory(
              file.bytes,
              width: _thumbSize,
              height: _thumbSize,
              fit: BoxFit.cover,
              cacheWidth: (_thumbSize * dpr).round(),
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => SizedBox.square(
                dimension: _thumbSize,
                child: Icon(Icons.broken_image_outlined, color: style.textSecondary),
              ),
            ),
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        body,
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: style.surface,
            shape: CircleBorder(
              side: BorderSide(color: style.border, width: style.borderWidth),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Tooltip(
                message: l10n.removeAttachment,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14, color: style.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditingBanner extends StatelessWidget {
  const _EditingBanner({required this.label, required this.original, this.onCancel});

  final String label;
  final String original;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final background = Color.alphaBlend(style.textPrimary.withValues(alpha: 0.06), style.pill);
    return ClipRRect(
      borderRadius: style.radii.controlRadius,
      child: ColoredBox(
        color: background,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: style.accent, child: const SizedBox(width: 4)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.sm + spacing.xxs, spacing.sm, spacing.xs, spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 15, color: style.accent),
                          SizedBox(width: spacing.xs),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.typography.label.copyWith(color: style.accent, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        original,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.meta.copyWith(color: style.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                  tooltip: l10n.cancelEdit,
                  visualDensity: VisualDensity.compact,
                  color: style.textSecondary,
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.message, required this.name, this.onCancel});

  final ChatMessage message;
  final String name;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final background = Color.alphaBlend(style.textPrimary.withValues(alpha: 0.06), style.pill);
    final color = chatSenderColor(message.senderId ?? '', background, fallback: t.link);
    final image = message.attachments.any((a) => a.isImage);
    final video = message.attachments.any((a) => a.isVideo);
    final document = message.attachments.where((a) => a.isDocument).firstOrNull;
    final text = message.body?.trim() ?? '';
    final summary = text.isNotEmpty
        ? text
        : image
        ? l10n.photo
        : video
        ? l10n.video
        : document?.name ?? l10n.attachment;
    return ClipRRect(
      borderRadius: style.radii.controlRadius,
      child: ColoredBox(
        color: background,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(color: color, child: const SizedBox(width: 4)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.sm + spacing.xxs, spacing.sm, spacing.xs, spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.label.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: spacing.xxs),
                      Row(
                        children: [
                          if (image || video || document != null) ...[
                            Icon(
                              image
                                  ? Icons.photo_camera_outlined
                                  : video
                                  ? Icons.videocam_outlined
                                  : Icons.description_outlined,
                              size: 15,
                              color: style.textSecondary,
                            ),
                            SizedBox(width: spacing.xs),
                          ],
                          Flexible(
                            child: Text(
                              summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.typography.meta.copyWith(color: style.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                  tooltip: l10n.cancel,
                  visualDensity: VisualDensity.compact,
                  color: style.textSecondary,
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
