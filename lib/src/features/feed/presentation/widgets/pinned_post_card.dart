import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/pinned_post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_actions.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class PinnedPostCard extends StatelessWidget {
  const PinnedPostCard({super.key, required this.pinned, required this.onLike, this.onOpen, this.onToggleBookmark});

  final PinnedPost pinned;
  final VoidCallback onLike;
  final VoidCallback? onOpen;
  final VoidCallback? onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final l10n = context.communityL10n;
    final announcement = pinned.announcement;
    final marker = CommunityPinnedMarkerDetails(
      pinned: pinned,
      label: announcement ? l10n.announcementLabel : l10n.pinnedLabel,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: style.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCommunityPart(
            CommunityFeedBuilders.of(context).pinnedMarker,
            context,
            marker,
            _DefaultPinnedMarker(details: marker, accent: announcement ? style.accent : style.textSecondary),
          ),
          PostCard(
            post: pinned.post,
            pinned: pinned,
            onLike: onLike,
            onOpen: onOpen,
            onToggleBookmark: bookmarkPostAction(context, onToggleBookmark),
            onShare: sharePostAction(context, pinned.post),
          ),
        ],
      ),
    );
  }
}

class _DefaultPinnedMarker extends StatelessWidget {
  const _DefaultPinnedMarker({required this.details, required this.accent});

  final CommunityPinnedMarkerDetails details;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final title = details.title;
    return Material(
      color: style.surface,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.md, spacing.lg, 0),
        child: Row(
          children: [
            Icon(details.announcement ? Icons.campaign_outlined : Icons.push_pin_outlined, size: 16, color: accent),
            SizedBox(width: spacing.xs + spacing.xxs),
            Text(details.label, style: style.typography.label.copyWith(color: accent)),
            if (title != null && title.isNotEmpty) ...[
              Text(' · ', style: style.typography.label),
              Flexible(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.author),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
