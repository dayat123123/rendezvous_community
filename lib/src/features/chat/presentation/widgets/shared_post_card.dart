import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_extras.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

SharedPost sharedPostFromPost(Post post) => SharedPost(
  postId: post.id,
  author: post.author,
  body: post.body.length > 280 ? '${post.body.substring(0, 279)}…' : post.body,
  attachments: post.attachments,
  sentiment: post.sentiment,
  stockCodes: post.stockCodes,
  likeCount: post.likeCount,
  commentCount: post.commentCount,
  createdAt: post.createdAt,
);

class SharedPostCard extends StatefulWidget {
  const SharedPostCard({super.key, required this.postId, this.sharedPost, this.color, this.onOpen});

  final String postId;
  final SharedPost? sharedPost;
  final Color? color;
  final VoidCallback? onOpen;

  @override
  State<SharedPostCard> createState() => _SharedPostCardState();
}

class _SharedPostCardState extends State<SharedPostCard> {
  Future<SharedPost>? _lookup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.sharedPost == null) _lookup ??= _load();
  }

  Future<SharedPost> _load() async {
    try {
      final post = await CommunityScope.of(context).feed.getPost(widget.postId);
      return post == null ? SharedPost(postId: widget.postId, available: false) : sharedPostFromPost(post);
    } catch (_) {
      return SharedPost(postId: widget.postId, available: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final known = widget.sharedPost;
    if (known != null) return _card(context, known);
    return FutureBuilder<SharedPost>(future: _lookup, builder: (context, snapshot) => _card(context, snapshot.data));
  }

  Widget _card(BuildContext context, SharedPost? shared) {
    final available = shared?.available ?? true;
    final details = CommunitySharedPostDetails(
      postId: widget.postId,
      loading: shared == null,
      available: available,
      post: shared,
      color: widget.color,
      onOpen: available ? widget.onOpen : null,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).sharedPost,
      context,
      details,
      _DefaultSharedPost(details: details),
    );
  }
}

class _DefaultSharedPost extends StatelessWidget {
  const _DefaultSharedPost({required this.details});

  final CommunitySharedPostDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final fg = details.color ?? style.textPrimary;
    final muted = fg.withValues(alpha: 0.72);
    final shared = details.post;
    final author = shared?.author;
    final body = shared?.body ?? '';
    return Container(
      margin: EdgeInsets.symmetric(vertical: spacing.xs),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.05),
        border: Border.all(color: fg.withValues(alpha: 0.16), width: style.borderWidth),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: details.onOpen,
        child: Padding(
          padding: EdgeInsets.all(spacing.sm + spacing.xxs),
          child: details.loading
              ? SizedBox(
                  height: 36,
                  child: Center(
                    child: LinearProgressIndicator(color: style.accent, backgroundColor: style.skeleton),
                  ),
                )
              : !details.available
              ? Row(
                  children: [
                    Icon(Icons.hide_source_outlined, size: 18, color: muted),
                    SizedBox(width: spacing.xs + spacing.xxs),
                    Flexible(
                      child: Text(
                        l10n.sharedPostUnavailable,
                        style: style.typography.meta.copyWith(color: fg, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.article_outlined, size: 14, color: muted),
                        SizedBox(width: spacing.xs),
                        Text(l10n.sharedPostLabel, style: style.typography.badge.copyWith(color: muted)),
                        if (author != null) ...[
                          SizedBox(width: spacing.sm),
                          CommunityAvatar(user: author, radius: 9),
                          SizedBox(width: spacing.xs),
                          Flexible(
                            child: Text(
                              author.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.typography.author.copyWith(color: fg, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (body.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.xs + spacing.xxs),
                        child: Text(
                          body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: style.typography.meta.copyWith(color: fg, height: 1.45),
                        ),
                      ),
                    if (shared != null && shared.attachments.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.sm),
                        child: AttachmentGrid(attachments: shared.attachments.take(1).toList(), maxHeight: 120),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
