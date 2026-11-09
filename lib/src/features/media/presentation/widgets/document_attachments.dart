import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/document_type.dart';
import 'package:rendezvous_community/src/features/media/presentation/file_opener.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

export 'package:rendezvous_community/src/features/media/presentation/file_opener.dart' show DocumentOpener;

String documentTypeLabel(CommunityLocalizations l10n, CommunityDocumentType type) => switch (type) {
  CommunityDocumentType.pdf => l10n.documentTypePdf,
  CommunityDocumentType.word => l10n.documentTypeWord,
  CommunityDocumentType.excel => l10n.documentTypeExcel,
  CommunityDocumentType.powerPoint => l10n.documentTypePowerPoint,
  CommunityDocumentType.csv => l10n.documentTypeCsv,
  CommunityDocumentType.text => l10n.documentTypeText,
  CommunityDocumentType.other => l10n.documentTypeOther,
};

IconData documentTypeIcon(CommunityDocumentType type) => switch (type) {
  CommunityDocumentType.pdf => Icons.picture_as_pdf_outlined,
  CommunityDocumentType.word => Icons.article_outlined,
  CommunityDocumentType.excel => Icons.table_chart_outlined,
  CommunityDocumentType.powerPoint => Icons.slideshow_outlined,
  CommunityDocumentType.csv => Icons.grid_on_outlined,
  CommunityDocumentType.text => Icons.notes_outlined,
  CommunityDocumentType.other => Icons.description_outlined,
};

String documentSize(int? bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.round()} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}

class DocumentAttachments extends StatelessWidget {
  const DocumentAttachments({super.key, required this.attachments, required this.color, this.onOpen});

  final List<Attachment> attachments;
  final Color color;
  final DocumentOpener? onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final a in attachments)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _DocumentTile(attachment: a, color: color, onOpen: onOpen),
        ),
    ],
  );
}

class _DocumentTile extends StatefulWidget {
  const _DocumentTile({required this.attachment, required this.color, this.onOpen});

  final Attachment attachment;
  final Color color;
  final DocumentOpener? onOpen;

  @override
  State<_DocumentTile> createState() => _DocumentTileState();
}

class _DocumentTileState extends State<_DocumentTile> {
  bool _opening = false;

  Future<void> _open() async {
    final l10n = context.communityL10n;
    final media = CommunityScope.of(context).media;
    setState(() => _opening = true);
    try {
      final a = widget.attachment;
      final uri = await media.documentUri(a);
      final onOpen = widget.onOpen;
      final opened = onOpen != null
          ? await onOpen(uri)
          : await const CommunityFileOpener().open(uri, fileName: _fileName(l10n), key: a.path);
      if (!opened && mounted) showCommunityMessage(context, l10n.documentOpenFailed);
    } catch (_) {
      if (mounted) showCommunityMessage(context, l10n.documentOpenFailed);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  String _fileName(CommunityLocalizations l10n) {
    final a = widget.attachment;
    final name = a.name ?? '';
    if (name.isNotEmpty) return name;
    final ext = a.path.contains('.') ? a.path.substring(a.path.lastIndexOf('.')) : '';
    return '${l10n.documentTypeOther}$ext';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final a = widget.attachment;
    final type = documentTypeOf(a);
    final name = (a.name ?? '').isNotEmpty
        ? a.name!
        : type == CommunityDocumentType.pdf
        ? l10n.documentFallbackName
        : _fileName(l10n);
    final size = documentSize(a.size);
    final typeLabel = documentTypeLabel(l10n, type);
    final details = CommunityDocumentDetails(
      attachment: a,
      name: name,
      sizeLabel: size.isEmpty ? typeLabel : '$typeLabel · $size',
      type: type,
      typeLabel: typeLabel,
      color: widget.color,
      opening: _opening,
      semanticLabel: l10n.openDocument(name),
      onOpen: _opening ? null : _open,
    );
    return buildFeedPart((b) => b.document, context, details, _DefaultDocumentTile(details: details));
  }
}

class _DefaultDocumentTile extends StatelessWidget {
  const _DefaultDocumentTile({required this.details});

  final CommunityDocumentDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final color = details.color;
    return Semantics(
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
            border: Border.all(color: color.withValues(alpha: 0.25), width: style.borderWidth),
          ),
          child: Row(
            children: [
              Icon(documentTypeIcon(details.type), color: color),
              SizedBox(width: spacing.sm + spacing.xxs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.typography.author.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                    Text(details.sizeLabel, style: style.typography.meta.copyWith(color: color.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              details.opening
                  ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  : Icon(Icons.open_in_new, size: 18, color: color.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
