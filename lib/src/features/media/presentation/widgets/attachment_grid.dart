import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/media/domain/repositories/media_repository.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/moderation_notice.dart';

class AttachmentGrid extends StatelessWidget {
  const AttachmentGrid({
    super.key,
    required this.attachments,
    this.maxHeight = 280,
    this.blurred = false,
    this.edgeToEdge = false,
    this.onOpen,
  });

  final List<Attachment> attachments;
  final double maxHeight;
  final bool blurred;
  final bool edgeToEdge;
  final ValueChanged<int>? onOpen;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    final media = CommunityScope.of(context).media;
    final style = CommunityStyle.of(context);
    final builder = CommunityFeedBuilders.of(context).attachmentImage;
    final count = attachments.length;
    final columns = count == 1 ? 1 : 2;
    Widget tile(int index) {
      final a = attachments[index];
      final part = buildCommunityPart(
        builder,
        context,
        CommunityAttachmentImageDetails(
          attachment: a,
          index: index,
          count: count,
          blurred: blurred,
          image: _AttachmentImage(attachment: a, media: media),
        ),
        _AttachmentTile(attachment: a, media: media, blurred: blurred),
      );
      final open = onOpen;
      if (open == null) return part;
      return Semantics(
        button: true,
        label: context.communityL10n.imageOpen,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => open(index), child: part),
        ),
      );
    }

    if (edgeToEdge) {
      final first = attachments.first;
      final w = first.width;
      final h = first.height;
      final ratio = w != null && h != null && w > 0 && h > 0 ? (w / h).clamp(0.8, 1.91).toDouble() : 4 / 3;
      return _EdgeGrid(count: count, maxHeight: maxHeight, gap: style.spacing.xxs, ratio: ratio, tile: tile);
    }
    final gap = style.spacing.xs;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ClipRRect(
        borderRadius: style.radii.cardRadius,
        child: GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: count == 1 ? 16 / 9 : 1,
          physics: const NeverScrollableScrollPhysics(),
          children: [for (var index = 0; index < count; index++) tile(index)],
        ),
      ),
    );
  }
}

class _EdgeGrid extends StatelessWidget {
  const _EdgeGrid({
    required this.count,
    required this.maxHeight,
    required this.gap,
    required this.ratio,
    required this.tile,
  });

  static const _maxTiles = 4;

  final int count;
  final double maxHeight;
  final double gap;
  final double ratio;
  final Widget Function(int index) tile;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (count == 1) {
        return SizedBox(width: width, height: (width / ratio).clamp(0, maxHeight), child: tile(0));
      }
      final shown = count < _maxTiles ? count : _maxTiles;
      final rows = (shown + 1) ~/ 2;
      final tileWidth = (width - gap) / 2;
      final rowHeight = tileWidth.clamp(0.0, (maxHeight - gap * (rows - 1)) / rows);
      final hidden = count - shown;
      Widget cell(int index) {
        final child = tile(index);
        if (hidden <= 0 || index != shown - 1) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            _MoreBadge(label: '+$hidden'),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < rows; row++) ...[
            if (row > 0) SizedBox(height: gap),
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  for (var col = 0; col < 2 && row * 2 + col < shown; col++) ...[
                    if (col > 0) SizedBox(width: gap),
                    Expanded(child: cell(row * 2 + col)),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

class _MoreBadge extends StatelessWidget {
  const _MoreBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return ColoredBox(
      color: Colors.black45,
      child: Center(
        child: Text(
          label,
          style: style.typography.title.copyWith(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment, required this.media, required this.blurred});

  final Attachment attachment;
  final MediaRepository media;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    final image = _AttachmentImage(attachment: attachment, media: media);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (blurred)
          ClipRect(
            child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18), child: image),
          )
        else
          image,
        if (blurred) const Center(child: Icon(Icons.visibility_off_outlined, color: Colors.white70, size: 32)),
        if (attachment.held)
          Positioned(left: spacing.xs + spacing.xxs, top: spacing.xs + spacing.xxs, child: const HeldAttachmentLabel()),
      ],
    );
  }
}

class _AttachmentImage extends StatelessWidget {
  const _AttachmentImage({required this.attachment, required this.media});

  final Attachment attachment;
  final MediaRepository media;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final bucket = attachment.bucket ?? attachmentBucket;
    return CommunityNetworkImage(
      cacheKey: imageCacheKeyForObject(bucket, attachment.path),
      source: () => media.attachmentImage(attachment),
      persist: bucket != supportDocumentBucket,
      placeholder: ColoredBox(color: style.skeleton),
      error: ColoredBox(
        color: style.skeleton,
        child: Center(child: Icon(Icons.broken_image_outlined, color: style.textTertiary)),
      ),
    );
  }
}
