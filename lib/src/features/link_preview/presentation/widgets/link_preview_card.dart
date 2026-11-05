import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/link_preview/domain/entities/link_preview.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/link_opener.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({super.key, required this.text, this.margin = const EdgeInsets.only(top: 8)});

  final String text;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final features = context.communityFeatures;
    final url = extractLinks(text, max: 1).firstOrNull;
    if (features == null || url == null) return const SizedBox.shrink();
    return ValueListenableBuilder<LinkPreview?>(
      valueListenable: features.linkPreviews.watch(url),
      builder: (context, preview, _) {
        if (preview == null || !preview.hasCard) return const SizedBox.shrink();
        final target = safeLinkUri(preview.finalUrl ?? '') ?? safeLinkUri(preview.url);
        final details = CommunityLinkPreviewDetails(
          preview: preview,
          onOpen: target == null ? null : () => openCommunityLink(context, target),
        );
        return buildCommunityPart(
          CommunityFeedBuilders.of(context).linkPreview,
          context,
          details,
          _PreviewCard(details: details, margin: margin),
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.details, required this.margin});

  final CommunityLinkPreviewDetails details;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final preview = details.preview;
    final title = preview.title?.trim();
    final description = preview.description?.trim();
    final site = preview.siteName?.trim();
    final image = preview.imageUrl;
    final thumb = style.avatarSizes.large + spacing.sm;
    return Padding(
      padding: margin,
      child: Material(
        color: style.surface,
        shape: style.cardShape(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: details.onOpen,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null) ...[
                    ClipRRect(
                      borderRadius: style.radii.imageRadius,
                      child: SizedBox.square(
                        dimension: thumb,
                        child: CommunityNetworkImage.url(image, error: ColoredBox(color: style.skeleton)),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                  ],
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: image == null ? spacing.xs : 0,
                        top: spacing.xxs,
                        end: spacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (site != null && site.isNotEmpty)
                            Text(
                              site,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.typography.badge.copyWith(color: style.textSecondary),
                            ),
                          if (title != null && title.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: spacing.xxs),
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: style.typography.author,
                              ),
                            ),
                          if (description != null && description.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: spacing.xxs),
                              child: Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: style.typography.meta,
                              ),
                            ),
                          SizedBox(height: spacing.xs),
                          Row(
                            children: [
                              Icon(Icons.link, size: 14, color: style.textSecondary),
                              SizedBox(width: spacing.xs),
                              Flexible(
                                child: Text(
                                  preview.domain,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.typography.badge.copyWith(color: style.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
