import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/pinned_post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/sentiment_badge.dart';
import 'package:rendezvous_community/src/features/link_preview/presentation/widgets/link_preview_card.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/image_viewer.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';
import 'package:rendezvous_community/src/features/poll/presentation/widgets/community_poll_view.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_actions.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/moderation_notice.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/social_text.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onOpen,
    this.onDelete,
    this.onAuthorBlocked,
    this.expanded = false,
    this.onEdit,
    this.onToggleBookmark,
    this.onShare,
    this.onAppeal,
    this.source = 'feed',
    this.pinned,
    this.showActions = true,
    this.actionsOnly = false,
    this.commentsExpanded = false,
    this.onToggleComments,
    this.readMoreInPlace = false,
  });

  final Post post;
  final VoidCallback onLike;
  final bool commentsExpanded;
  final VoidCallback? onToggleComments;
  final bool readMoreInPlace;

  final VoidCallback? onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onAuthorBlocked;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onAppeal;

  final bool expanded;
  final String source;
  final PinnedPost? pinned;
  final bool showActions;
  final bool actionsOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final isMine = CommunityScope.of(context).currentUser?.id == post.author.id;
    final remove = onDelete;
    final details = CommunityPostDetails(
      post: post,
      isMine: isMine,
      timeLabel: l10n.relativeTime(post.createdAt),
      expanded: expanded,
      source: source,
      pinned: pinned,
      onLike: onLike,
      onOpen: onOpen,
      onComment: onToggleComments ?? onOpen,
      commentsExpanded: commentsExpanded,
      onToggleComments: onToggleComments,
      topComment: post.topComment,
      onOpenComments: onToggleComments ?? onOpen,
      onOpenImage: post.attachments.isEmpty
          ? null
          : (index) => showCommunityImageViewer(
              context,
              images: post.attachments,
              initialIndex: index,
              sender: post.author,
              sentAt: post.createdAt,
            ),
      onOpenAuthor: () => CommunityNavigator.openUser(context, post.author),
      onOpenStock: (code) => CommunityNavigator.openStock(context, code, source: source),
      onOpenHashtag: (tag) => CommunityNavigator.openHashtag(context, tag),
      onShare: onShare,
      onToggleBookmark: onToggleBookmark,
      onEdit: isMine ? onEdit : null,
      onDelete: isMine && remove != null
          ? () async {
              if (await confirmCommunityAction(context, l10n.deletePostConfirm)) remove();
            }
          : null,
      onReport: isMine ? null : () => showReportDialog(context, target: ReportTarget.post, targetId: post.id),
      onBlock: isMine
          ? null
          : () async {
              if (await blockUserWithConfirm(context, post.author)) onAuthorBlocked?.call();
            },
      onAppeal: onAppeal,
    );
    final builders = CommunityFeedBuilders.of(context);
    if (actionsOnly) {
      if (builders.postCard != null) return const SizedBox.shrink();
      return _StickyActions(
        child: buildCommunityPart(builders.actionBar, context, details, PostActionBar(details: details)),
      );
    }
    return buildCommunityPart(
      builders.postCard,
      context,
      details,
      _DefaultPostCard(
        details: details,
        builders: builders,
        showActions: showActions,
        readMoreInPlace: readMoreInPlace,
      ),
    );
  }
}

(String?, String) splitPostTitle(String body) {
  final text = body.trim();
  final newline = text.indexOf('\n');
  if (newline <= 0) return (null, text);
  final title = text.substring(0, newline).trim();
  final rest = text.substring(newline + 1).trim();
  if (title.isEmpty || rest.isEmpty || title.length > 100) return (null, text);
  return (title, rest);
}

class _DefaultPostCard extends StatelessWidget {
  const _DefaultPostCard({
    required this.details,
    required this.builders,
    required this.showActions,
    this.readMoreInPlace = false,
  });

  final CommunityPostDetails details;
  final CommunityFeedBuilders builders;
  final bool showActions;
  final bool readMoreInPlace;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final post = d.post;
    final expanded = d.expanded;
    final side = EdgeInsets.symmetric(horizontal: spacing.lg);
    final codes = post.stockCodes.toSet();
    final (title, body) = builders.postBody == null ? splitPostTitle(post.body) : (null, post.body);
    final titleStyle = style.typography.title.copyWith(fontSize: expanded ? 22 : 18, height: 1.3);
    final bodyStyle = expanded ? style.typography.body.copyWith(fontSize: 16, height: 1.5) : style.typography.body;
    final titleView = title == null
        ? null
        : Padding(
            padding: side.copyWith(top: spacing.sm),
            child: SocialText(title, validStockCodes: codes, style: titleStyle, source: d.source),
          );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (expanded) buildCommunityPart(builders.stockTags, context, d, PostTopics(details: d)),
        if (expanded) ?titleView,
        Padding(
          padding: side.copyWith(top: expanded && title != null ? spacing.sm : 0),
          child: InkWell(
            onTap: d.onOpenAuthor,
            borderRadius: style.radii.controlRadius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: style.minTouchTarget),
              child: Row(
                children: [
                  buildCommunityPart(
                    builders.postAvatar,
                    context,
                    d,
                    CommunityAvatar(
                      user: post.author,
                      radius: style.avatarSizes.post / 2,
                      ringColor: post.authorIsOfficial ? style.accent : null,
                    ),
                  ),
                  SizedBox(width: spacing.sm + spacing.xxs),
                  Expanded(child: buildCommunityPart(builders.postHeader, context, d, PostCardHeader(details: d))),
                ],
              ),
            ),
          ),
        ),
        if (d.isMine)
          Padding(
            padding: side,
            child: ModerationNotice(status: post.moderationStatus, onAppeal: d.onAppeal),
          ),
        if (!expanded) ?titleView,
        Padding(
          padding: side.copyWith(top: spacing.xs + spacing.xxs),
          child: buildCommunityPart(
            builders.postBody,
            context,
            d,
            readMoreInPlace && !expanded
                ? _InPlaceReadMore(text: body, validStockCodes: codes, style: bodyStyle, source: d.source)
                : expanded || d.onOpen == null
                ? SocialText(body, validStockCodes: codes, style: bodyStyle, source: d.source)
                : PostReadMore(
                    text: body,
                    validStockCodes: codes,
                    style: bodyStyle,
                    source: d.source,
                    onOpen: d.onOpen!,
                  ),
          ),
        ),
        if (!expanded) buildCommunityPart(builders.stockTags, context, d, const SizedBox.shrink()),
        Padding(
          padding: side,
          child: LinkPreviewCard(
            text: post.body,
            margin: EdgeInsets.only(top: spacing.md),
          ),
        ),
        if (post.poll != null)
          Padding(
            padding: side,
            child: CommunityPollView(postId: post.id, poll: post.poll!, canVote: d.canVote),
          ),
        if (post.attachments.isNotEmpty) ...[
          SizedBox(height: spacing.md),
          buildCommunityPart(
            builders.attachments,
            context,
            d,
            AttachmentGrid(attachments: post.attachments, edgeToEdge: true, maxHeight: 360, onOpen: d.onOpenImage),
          ),
        ],
        if (showActions) ...[
          SizedBox(height: spacing.xs),
          Padding(
            padding: EdgeInsetsDirectional.only(start: spacing.sm + spacing.xs, end: spacing.xs),
            child: buildCommunityPart(builders.actionBar, context, d, PostActionBar(details: d)),
          ),
          if (!expanded && !d.commentsExpanded && d.topComment?.body != null && d.onOpenComments != null)
            buildCommunityPart(builders.topComment, context, d, PostTopCommentPreview(details: d)),
        ] else
          SizedBox(height: spacing.md),
      ],
    );
    final padded = Padding(
      padding: EdgeInsets.only(top: expanded ? spacing.sm : spacing.md, bottom: spacing.xxs),
      child: content,
    );
    return Material(
      color: style.surface,
      child: expanded || d.onOpen == null ? padded : InkWell(onTap: d.onOpen, child: padded),
    );
  }
}

class PostTopCommentPreview extends StatelessWidget {
  const PostTopCommentPreview({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final comment = details.topComment;
    final author = comment?.author;
    final body = comment?.body;
    final open = details.onOpenComments;
    if (comment == null || author == null || body == null || open == null) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final meta = style.typography.meta.copyWith(color: style.textSecondary);
    final count = details.post.commentCount;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, 0, spacing.lg, spacing.md),
      child: Semantics(
        button: true,
        label: l10n.viewAllComments(count),
        child: InkWell(
          key: ValueKey('top-comment-${details.post.id}'),
          onTap: open,
          borderRadius: style.radii.controlRadius,
          child: Ink(
            padding: EdgeInsets.all(spacing.sm + spacing.xxs),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: style.radii.controlRadius,
              border: Border.fromBorderSide(style.borderSide),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommunityAvatar(user: author, radius: 13),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: author.name,
                                    style: style.typography.label.copyWith(color: style.textPrimary),
                                    children: [
                                      TextSpan(text: ' · ${l10n.relativeTime(comment.createdAt)}', style: meta),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (comment.likeCount > 0) ...[
                                Icon(Icons.favorite, size: 13, color: style.textTertiary),
                                SizedBox(width: spacing.xxs),
                                Text(communityCountText(context, comment.likeCount), style: meta),
                              ],
                            ],
                          ),
                          SizedBox(height: spacing.xxs),
                          SocialText(
                            body,
                            maxLines: 2,
                            links: false,
                            source: details.source,
                            style: style.typography.body.copyWith(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (count > 1) ...[
                  SizedBox(height: spacing.xs),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 26 + spacing.sm),
                    child: Text(
                      l10n.viewAllComments(count),
                      style: style.typography.label.copyWith(color: style.accent),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InPlaceReadMore extends StatefulWidget {
  const _InPlaceReadMore({required this.text, required this.style, this.validStockCodes, this.source});

  final String text;
  final TextStyle style;
  final Set<String>? validStockCodes;
  final String? source;

  @override
  State<_InPlaceReadMore> createState() => _InPlaceReadMoreState();
}

class _InPlaceReadMoreState extends State<_InPlaceReadMore> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => _open
      ? SocialText(widget.text, validStockCodes: widget.validStockCodes, style: widget.style, source: widget.source)
      : PostReadMore(
          text: widget.text,
          validStockCodes: widget.validStockCodes,
          style: widget.style,
          source: widget.source,
          onOpen: () => setState(() => _open = true),
        );
}

class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Material(
      color: style.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CommunityDivider(),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(spacing.sm + spacing.xs, spacing.xxs, spacing.xs, spacing.xxs),
            child: child,
          ),
        ],
      ),
    );
  }
}

class PostReadMore extends StatelessWidget {
  const PostReadMore({
    super.key,
    required this.text,
    required this.style,
    required this.onOpen,
    this.validStockCodes,
    this.source,
    this.maxLines = 4,
  });

  final String text;
  final TextStyle style;
  final VoidCallback onOpen;
  final Set<String>? validStockCodes;
  final String? source;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = CommunityStyle.of(context);
    final label = context.communityL10n.readMore;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflow = painter.didExceedMaxLines;
        painter.dispose();
        final social = SocialText(
          text,
          validStockCodes: validStockCodes,
          maxLines: maxLines,
          style: style,
          source: source,
        );
        if (!overflow) return social;
        return Stack(
          children: [
            social,
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onOpen,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tokens.surface.withValues(alpha: 0), tokens.surface],
                        stops: const [0, 0.2],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: tokens.spacing.xl),
                      child: Text(
                        '… $label',
                        style: style.copyWith(color: tokens.textSecondary, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PostCardHeader extends StatelessWidget {
  const PostCardHeader({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final l10n = context.communityL10n;
    final d = details;
    final post = d.post;
    final meta = [post.author.handle, d.timeLabel, if (d.edited) l10n.edited].join(' · ');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: CommunityUserName(user: post.author, official: post.authorIsOfficial, showUsername: false),
                  ),
                  if (post.isBot) ...[SizedBox(width: spacing.xs), const CommunityBotBadge()],
                ],
              ),
              SizedBox(height: spacing.xxs),
              Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
            ],
          ),
        ),
        if (post.sentiment != null) ...[SizedBox(width: spacing.xs), SentimentBadge(sentiment: post.sentiment!)],
        buildCommunityPart(CommunityFeedBuilders.of(context).postMenu, context, d, _PostMenu(details: d)),
      ],
    );
  }
}

class PostTopics extends StatelessWidget {
  const PostTopics({super.key, required this.details, this.maxVisible = 3});

  final CommunityPostDetails details;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final post = details.post;
    final hashtags =
        CommunityScope.of(context).callbacks.onHashtagTap != null || context.communityFeature(CommunityFlags.search)
        ? post.hashtags
        : const <String>[];
    final topics = [
      for (final code in post.stockCodes) ('\$$code', () => details.onOpenStock(code)),
      for (final tag in hashtags) ('#$tag', () => details.onOpenHashtag(tag)),
    ];
    if (topics.isEmpty) return const SizedBox.shrink();
    final spacing = CommunityStyle.of(context).spacing;
    final hidden = topics.length - maxVisible;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg - spacing.xs),
      child: Wrap(
        children: [
          for (final (label, onTap) in topics.take(maxVisible)) _TopicChip(label: label, onTap: onTap),
          if (hidden > 0) _TopicChip(label: '+$hidden'),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final chip = DecoratedBox(
      decoration: BoxDecoration(color: style.chip, borderRadius: style.radii.imageRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.xs + spacing.xxs),
        child: Text(label, style: style.typography.label.copyWith(color: style.onChip)),
      ),
    );
    final box = ConstrainedBox(
      constraints: BoxConstraints(minHeight: style.minTouchTarget, minWidth: style.minTouchTarget),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        child: Center(widthFactor: 1, child: chip),
      ),
    );
    final tap = onTap;
    if (tap == null) return box;
    return Semantics(
      button: true,
      child: InkWell(onTap: tap, borderRadius: style.radii.controlRadius, child: box),
    );
  }
}

class PostActionBar extends StatelessWidget {
  const PostActionBar({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final post = details.post;
    final bookmark = details.onToggleBookmark;
    final share = details.onShare;
    final like = details.onLike;
    return CommunityActionBar(
      leading: [
        CommunityActionPill(
          icon: Icons.favorite_border_rounded,
          activeIcon: Icons.favorite_rounded,
          activeColor: CommunityTheme.of(context).like,
          label: l10n.like,
          count: post.likeCount,
          active: post.likedByMe,
          tooltip: post.likedByMe ? l10n.unlike : l10n.like,
          onPressed: () {
            HapticFeedback.selectionClick();
            like();
          },
        ),
        CommunityActionButton(
          icon: Icons.mode_comment_outlined,
          activeIcon: Icons.mode_comment,
          active: details.commentsExpanded,
          tooltip: l10n.comment,
          count: post.commentCount,
          onPressed: details.onComment,
        ),
        if (share != null)
          CommunityActionButton(icon: Icons.send_outlined, tooltip: l10n.shareToChat, onPressed: share),
      ],
      trailing: [
        if (bookmark != null)
          CommunityActionButton(
            icon: Icons.bookmark_border,
            activeIcon: Icons.bookmark,
            active: post.isBookmarked,
            tooltip: post.isBookmarked ? l10n.bookmarkRemove : l10n.bookmarkAdd,
            onPressed: bookmark,
          ),
      ],
    );
  }
}

enum _PostAction { edit, bookmark, share, delete, report, block }

class _PostMenu extends StatelessWidget {
  const _PostMenu({required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final d = details;
    final bookmarked = d.post.isBookmarked;
    return PopupMenuButton<_PostAction>(
      icon: Icon(Icons.more_horiz, size: 20, color: style.textSecondary),
      onSelected: (action) => switch (action) {
        _PostAction.edit => d.onEdit?.call(),
        _PostAction.bookmark => d.onToggleBookmark?.call(),
        _PostAction.share => d.onShare?.call(),
        _PostAction.delete => d.onDelete?.call(),
        _PostAction.report => d.onReport?.call(),
        _PostAction.block => d.onBlock?.call(),
      },
      itemBuilder: (_) => [
        if (d.onEdit != null)
          PopupMenuItem(
            value: _PostAction.edit,
            child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.editAction)),
          ),
        if (d.onToggleBookmark != null)
          PopupMenuItem(
            value: _PostAction.bookmark,
            child: ListTile(
              leading: Icon(bookmarked ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined),
              title: Text(bookmarked ? l10n.bookmarkRemove : l10n.bookmarkAdd),
            ),
          ),
        if (d.onShare != null)
          PopupMenuItem(
            value: _PostAction.share,
            child: ListTile(leading: const Icon(Icons.send_outlined), title: Text(l10n.shareToChat)),
          ),
        if (d.onDelete != null)
          PopupMenuItem(
            value: _PostAction.delete,
            child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l10n.delete)),
          ),
        if (!d.isMine) ...[
          PopupMenuItem(
            value: _PostAction.report,
            child: ListTile(leading: const Icon(Icons.flag_outlined), title: Text(l10n.report)),
          ),
          PopupMenuItem(
            value: _PostAction.block,
            child: ListTile(leading: const Icon(Icons.block), title: Text(l10n.block)),
          ),
        ],
      ],
    );
  }
}
