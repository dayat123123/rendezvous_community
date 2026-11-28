import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/quoted_post.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/social_text.dart';

class QuotedPostCard extends StatelessWidget {
  const QuotedPostCard({super.key, required this.quoted, this.onTap, this.source = 'feed', this.maxLines = 4});

  final QuotedPost quoted;
  final VoidCallback? onTap;
  final String source;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final l10n = context.communityL10n;
    final author = quoted.author;
    final image = quoted.image;
    final meta = style.typography.meta.copyWith(color: style.textSecondary);
    final created = quoted.createdAt;
    final Widget content = !quoted.available || author == null
        ? Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Text(l10n.quotedPostUnavailable, style: meta),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm + spacing.xxs, spacing.md, 0),
                child: Row(
                  children: [
                    CommunityAvatar(user: author, radius: 10, ringColor: quoted.authorIsOfficial ? style.accent : null),
                    SizedBox(width: spacing.xs + spacing.xxs),
                    Flexible(
                      child: CommunityUserName(
                        user: author,
                        official: quoted.authorIsOfficial,
                        style: style.typography.label,
                      ),
                    ),
                    if (created != null) ...[Text(' · ', style: meta), Text(l10n.relativeTime(created), style: meta)],
                  ],
                ),
              ),
              if (quoted.body.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(spacing.md, spacing.xs, spacing.md, 0),
                  child: SocialText(
                    quoted.body.trim(),
                    validStockCodes: quoted.stockCodes.toSet(),
                    style: style.typography.body,
                    maxLines: maxLines,
                    links: false,
                    source: source,
                  ),
                ),
              if (image != null)
                Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: AttachmentGrid(attachments: [image], edgeToEdge: true, maxHeight: 180),
                )
              else
                SizedBox(height: spacing.sm + spacing.xxs),
            ],
          );
    return Semantics(
      container: true,
      label: l10n.quotedPostLabel,
      child: Material(
        color: style.surface,
        shape: style.cardShape(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: quoted.available ? onTap : null, child: content),
      ),
    );
  }
}
