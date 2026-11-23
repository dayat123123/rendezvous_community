import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_builders.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/community_help_markdown.dart';
import 'package:rendezvous_community/src/features/media/presentation/file_opener.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/video_player_page.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

typedef CommunityHelpAttachmentOpener = Future<bool> Function(BuildContext context, HelpAttachment attachment);

Future<bool> openHelpAttachment(BuildContext context, HelpAttachment attachment) async {
  switch (attachment.kind) {
    case HelpAttachmentKind.image:
      await Navigator.of(
        context,
        rootNavigator: true,
      ).push<void>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => HelpImagePage(attachment: attachment)));
      return true;
    case HelpAttachmentKind.video when communityVideoPlaysInApp():
      await showCommunityVideoPlayer(
        context,
        uri: attachment.url,
        title: attachment.name,
        onOpenExternal: () => _openFile(attachment),
      );
      return true;
    case HelpAttachmentKind.video || HelpAttachmentKind.document:
      return _openFile(attachment);
  }
}

Future<bool> _openFile(HelpAttachment attachment) =>
    const CommunityFileOpener().open(attachment.url, fileName: _fileName(attachment), key: attachment.path);

String _fileName(HelpAttachment attachment) {
  final extension = attachment.path.substring(attachment.path.lastIndexOf('.'));
  final name = safeDownloadName(attachment.name, fallback: 'lampiran');
  return name.toLowerCase().endsWith(extension) ? name : '$name$extension';
}

class HelpAttachments extends StatelessWidget {
  const HelpAttachments({super.key, required this.attachments, this.onOpen});

  final List<HelpAttachment> attachments;
  final CommunityHelpAttachmentOpener? onOpen;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final l10n = context.communityL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(container: true, header: true, child: Text(l10n.helpAttachments, style: style.typography.label)),
        SizedBox(height: style.spacing.sm),
        for (var index = 0; index < attachments.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : style.spacing.xs),
            child: _AttachmentTile(attachment: attachments[index], index: index, onOpen: onOpen),
          ),
      ],
    );
  }
}

class _AttachmentTile extends StatefulWidget {
  const _AttachmentTile({required this.attachment, required this.index, this.onOpen});

  final HelpAttachment attachment;
  final int index;
  final CommunityHelpAttachmentOpener? onOpen;

  @override
  State<_AttachmentTile> createState() => _AttachmentTileState();
}

class _AttachmentTileState extends State<_AttachmentTile> {
  bool _opening = false;

  Future<void> _open() async {
    final l10n = context.communityL10n;
    setState(() => _opening = true);
    try {
      final opened = await (widget.onOpen ?? openHelpAttachment)(context, widget.attachment);
      if (!opened && mounted) showCommunityMessage(context, l10n.helpAttachmentOpenFailed);
    } catch (_) {
      if (mounted) showCommunityMessage(context, l10n.helpAttachmentOpenFailed);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final a = widget.attachment;
    final details = CommunityHelpAttachmentDetails(
      attachment: a,
      index: widget.index,
      name: a.name,
      kindLabel: switch (a.kind) {
        HelpAttachmentKind.document => l10n.documentTypePdf,
        HelpAttachmentKind.image => l10n.helpAttachmentImage,
        HelpAttachmentKind.video => l10n.video,
      },
      sizeLabel: documentSize(a.size),
      semanticLabel: l10n.helpAttachmentOpen(a.name),
      preview: a.kind == HelpAttachmentKind.image ? _Thumbnail(attachment: a) : null,
      opening: _opening,
      onOpen: _opening ? null : _open,
    );
    return buildHelpPart((b) => b.attachment, context, details, _DefaultAttachmentTile(details: details));
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.attachment});

  final HelpAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Image.network(
      attachment.url.toString(),
      fit: BoxFit.cover,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: style.pill,
        child: Icon(Icons.image_outlined, color: style.textTertiary),
      ),
    );
  }
}

class _DefaultAttachmentTile extends StatelessWidget {
  const _DefaultAttachmentTile({required this.details});

  final CommunityHelpAttachmentDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final meta = details.sizeLabel.isEmpty ? details.kindLabel : '${details.kindLabel} · ${details.sizeLabel}';
    final preview = details.preview;
    return Semantics(
      container: true,
      button: true,
      label: details.semanticLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: details.onOpen,
        borderRadius: style.radii.controlRadius,
        child: Container(
          constraints: BoxConstraints(minHeight: style.minTouchTarget),
          padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.sm),
          decoration: BoxDecoration(
            borderRadius: style.radii.controlRadius,
            border: Border.all(color: style.divider, width: style.borderWidth),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: preview != null
                    ? ClipRRect(borderRadius: style.radii.controlRadius, child: preview)
                    : DecoratedBox(
                        decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.controlRadius),
                        child: Icon(switch (details.kind) {
                          HelpAttachmentKind.document => Icons.picture_as_pdf_outlined,
                          HelpAttachmentKind.video => Icons.play_circle_outline,
                          HelpAttachmentKind.image => Icons.image_outlined,
                        }, color: style.accent),
                      ),
              ),
              SizedBox(width: spacing.sm + spacing.xxs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: style.typography.author.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(meta, style: style.typography.meta),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              details.opening
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: style.accent),
                    )
                  : Icon(Icons.open_in_new, size: 18, color: style.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpImagePage extends StatelessWidget {
  const HelpImagePage({super.key, required this.attachment});

  final HelpAttachment attachment;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        attachment.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          tooltip: context.communityL10n.close,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: SafeArea(
      child: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: HelpMarkdownImage(uri: attachment.url, alt: attachment.name, maxHeight: double.infinity),
        ),
      ),
    ),
  );
}
