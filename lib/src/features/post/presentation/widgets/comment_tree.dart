import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/appeals/domain/entities/appeal.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/widgets/community_appeals.dart';
import 'package:rendezvous_community/src/features/edit/presentation/widgets/edit_content_dialog.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/link_preview/presentation/widgets/link_preview_card.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_actions.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/moderation_notice.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/social_text.dart';

class ThreadLinesPainter extends CustomPainter {
  const ThreadLinesPainter({
    required this.level,
    required this.indent,
    required this.color,
    this.inset = 8,
    this.strokeWidth = 2,
  });

  final int level;
  final double indent;
  final double inset;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    for (var i = 0; i < level; i++) {
      final x = inset + i * indent + indent / 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(ThreadLinesPainter old) =>
      old.level != level ||
      old.indent != indent ||
      old.color != color ||
      old.inset != inset ||
      old.strokeWidth != strokeWidth;
}

double _avatarSlot(CommunityStyle style) => style.minTouchTarget;

class _Indented extends StatelessWidget {
  const _Indented({required this.level, required this.child});

  final int level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CommunityTheme.of(context);
    final style = CommunityStyle.of(context);
    final inset = style.spacing.lg - (_avatarSlot(style) - style.avatarSizes.comment) / 2;
    final lineInset = inset + _avatarSlot(style) / 2 - t.threadIndent / 2;
    return CustomPaint(
      painter: ThreadLinesPainter(
        level: level,
        indent: t.threadIndent,
        color: t.threadLine,
        inset: lineInset,
        strokeWidth: style.borderWidth,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: inset + level * t.threadIndent),
        child: child,
      ),
    );
  }
}

class _StemPainter extends CustomPainter {
  const _StemPainter({required this.x, required this.top, required this.color, required this.width});

  final double x;
  final double top;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= top) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(Offset(x, top), Offset(x, size.height), paint);
  }

  @override
  bool shouldRepaint(_StemPainter old) => old.x != x || old.top != top || old.color != color || old.width != width;
}

class ThreadRowView extends StatelessWidget {
  const ThreadRowView({super.key, required this.row, required this.postId});

  final ThreadRow row;
  final String postId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<CommentThreadCubit>();
    return switch (row) {
      CommentRow(:final comment, :final collapsed) => _Indented(
        level: row.level,
        child: CommentTile(comment: comment, collapsed: collapsed, level: row.level),
      ),
      MoreRepliesRow(:final parentId, :final remaining, :final loading) => _Indented(
        level: row.level,
        child: _ThreadMore(
          details: CommunityThreadMoreDetails(
            kind: CommunityThreadMoreKind.moreReplies,
            label: l10n.viewMoreReplies(remaining),
            level: row.level,
            remaining: remaining,
            loading: loading,
            onTap: loading ? null : () => cubit.loadMoreReplies(parentId),
          ),
        ),
      ),
      ContinueThreadRow(:final comment) => _Indented(
        level: row.level,
        child: _ThreadMore(
          details: CommunityThreadMoreDetails(
            kind: CommunityThreadMoreKind.continueThread,
            label: '${l10n.continueThread} →',
            level: row.level,
            onTap: () => CommunityNavigator.openPost(context, postId, rootCommentId: comment.id),
          ),
        ),
      ),
      MoreTopLevelRow(:final loading) => _ThreadMore(
        details: CommunityThreadMoreDetails(
          kind: CommunityThreadMoreKind.moreComments,
          label: l10n.loadMoreComments,
          level: row.level,
          loading: loading,
          onTap: loading ? null : cubit.loadMoreTop,
        ),
      ),
    };
  }
}

class _ThreadMore extends StatelessWidget {
  const _ThreadMore({required this.details});

  final CommunityThreadMoreDetails details;

  @override
  Widget build(BuildContext context) =>
      buildFeedPart((b) => b.threadMore, context, details, _DefaultThreadMore(details: details));
}

class _DefaultThreadMore extends StatelessWidget {
  const _DefaultThreadMore({required this.details});

  final CommunityThreadMoreDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final spinner = SizedBox.square(
      dimension: 14,
      child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
    );
    if (details.kind == CommunityThreadMoreKind.moreComments) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: OutlinedButton(
          style: style.secondaryButtonStyle(),
          onPressed: details.onTap,
          child: details.loading ? spinner : Text(details.label),
        ),
      );
    }
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: style.accent,
      textStyle: style.typography.label.copyWith(fontWeight: FontWeight.w700),
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      shape: const StadiumBorder(),
    );
    final label = Text(details.label);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: spacing.xs),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: details.kind == CommunityThreadMoreKind.moreReplies
            ? TextButton.icon(
                onPressed: details.onTap,
                style: buttonStyle,
                icon: details.loading ? spinner : const Icon(Icons.subdirectory_arrow_right, size: 16),
                label: label,
              )
            : TextButton(onPressed: details.onTap, style: buttonStyle, child: label),
      ),
    );
  }
}

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.collapsed = false,
    this.showCollapse = true,
    this.level = 0,
  });

  final ThreadComment comment;
  final bool collapsed;
  final bool showCollapse;
  final int level;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _hovered = false;

  bool _canEdit(ThreadComment c, bool isMine, CommentThreadCubit cubit) =>
      isMine && !c.isDeleted && cubit.canEdit && context.communityConfig.canEdit(c.createdAt);

  Future<void> _edit(ThreadComment c, CommentThreadCubit cubit) async {
    final l10n = context.communityL10n;
    final body = await showEditContentDialog(
      context,
      title: l10n.editCommentTitle,
      initial: c.body ?? '',
      maxLength: 1000,
    );
    if (body == null || !mounted) return;
    if (await cubit.editComment(c, body) && mounted) showCommunityMessage(context, l10n.editSaved);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final l10n = context.communityL10n;
    final cubit = context.read<CommentThreadCubit>();
    final author = c.author;
    final isMine = author != null && author.id == CommunityScope.of(context).currentUser?.id;
    final details = CommunityCommentDetails(
      comment: c,
      isMine: isMine,
      collapsed: widget.collapsed,
      timeLabel: l10n.relativeTime(c.createdAt),
      level: widget.level,
      onLike: c.isDeleted ? null : () => cubit.toggleLike(c),
      onReply: c.isDeleted ? null : () => cubit.setReplyTo(c),
      onToggleCollapse: widget.showCollapse && c.replyCount > 0 ? () => cubit.toggleCollapse(c.id) : null,
      onOpenAuthor: author == null ? null : () => CommunityNavigator.openUser(context, author),
      onEdit: _canEdit(c, isMine, cubit) ? () => _edit(c, cubit) : null,
      onDelete: isMine && !c.isDeleted
          ? () async {
              if (await confirmCommunityAction(context, l10n.deleteCommentConfirm)) await cubit.deleteComment(c);
            }
          : null,
      onReport: isMine || c.isDeleted
          ? null
          : () => showReportDialog(context, target: ReportTarget.comment, targetId: c.id),
      onBlock: isMine || c.isDeleted || author == null
          ? null
          : () async {
              if (await blockUserWithConfirm(context, author)) await cubit.load();
            },
      onAppeal: isMine && !c.isDeleted && c.isHidden && context.communityFeatures != null
          ? () => showCommunityAppealDialog(context, targetType: AppealTargetType.comment, targetId: c.id)
          : null,
    );
    return buildCommunityPart(CommunityFeedBuilders.of(context).comment, context, details, _tile(context, details));
  }

  Widget _tile(BuildContext context, CommunityCommentDetails d) {
    final c = d.comment;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final theme = CommunityTheme.of(context);
    final spacing = style.spacing;
    final author = c.author;
    final slot = _avatarSlot(style);
    final avatarSize = d.level > 0 ? style.avatarSizes.reply : style.avatarSizes.comment;
    final meta = [d.timeLabel, if (d.edited) l10n.edited].join(' · ');
    final bodyStyle = style.typography.body.copyWith(fontSize: 14, height: 1.4);
    final openAuthor = d.onOpenAuthor;
    final name = author == null
        ? null
        : GestureDetector(
            onTap: openAuthor,
            excludeFromSemantics: true,
            child: CommunityUserName(
              user: author,
              showUsername: false,
              style: style.typography.author.copyWith(fontSize: 13),
            ),
          );
    final avatar = author == null
        ? SizedBox(width: slot)
        : SizedBox(
            width: slot,
            height: slot,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: openAuthor,
                customBorder: const CircleBorder(),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: spacing.xxs),
                    child: CommunityAvatar(user: author, radius: avatarSize / 2),
                  ),
                ),
              ),
            ),
          );
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: _hovered ? style.skeleton : style.pill,
        borderRadius: BorderRadius.circular(spacing.lg),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm + spacing.xxs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ?name,
            if (name != null) SizedBox(height: spacing.xxs),
            if (c.isDeleted)
              Text(l10n.commentDeleted, style: style.typography.meta.copyWith(fontStyle: FontStyle.italic))
            else
              SocialText(c.body ?? '', source: 'comment', style: bodyStyle),
          ],
        ),
      ),
    );
    final likeCount = c.likeCount;
    final metaLine = Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(width: spacing.md),
              Flexible(
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.typography.meta.copyWith(fontSize: 12),
                ),
              ),
              if (!c.isDeleted) ...[
                SizedBox(width: spacing.xs),
                _CommentAction(label: l10n.like, active: c.likedByMe, onPressed: d.onLike),
                _CommentAction(label: l10n.reply, onPressed: d.onReply),
                _commentMenu(d, l10n, style),
              ],
            ],
          ),
        ),
        if (!c.isDeleted && likeCount > 0) _CommentLikes(count: likeCount, active: c.likedByMe),
      ],
    );
    final metaRow = c.isDeleted
        ? Padding(
            padding: EdgeInsets.only(top: spacing.xs, bottom: spacing.sm),
            child: metaLine,
          )
        : Transform.translate(offset: Offset(0, -spacing.sm), child: metaLine);
    final toggle = d.onToggleCollapse;
    final bubbleRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerStart, child: bubble),
        ),
        if (toggle != null)
          IconButton(
            iconSize: 18,
            color: style.textSecondary,
            tooltip: d.collapsed ? l10n.expand : l10n.collapse,
            onPressed: toggle,
            icon: Icon(d.collapsed ? Icons.unfold_more : Icons.unfold_less),
          ),
      ],
    );
    final stem = c.replyCount > 0 && !d.collapsed && author != null && widget.showCollapse;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (d.isMine && !c.isDeleted)
                ModerationNotice(status: c.moderationStatus, compact: true, onAppeal: d.onAppeal),
              bubbleRow,
              if (!c.isDeleted && (c.body ?? '').isNotEmpty) LinkPreviewCard(text: c.body!),
              if (d.collapsed)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: spacing.md, top: spacing.xs),
                  child: Text(l10n.hiddenReplies(c.replyCount), style: style.typography.meta),
                ),
              metaRow,
            ],
          ),
        ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: EdgeInsets.only(top: spacing.xs),
        child: stem
            ? CustomPaint(
                painter: _StemPainter(
                  x: slot / 2,
                  top: spacing.xs + spacing.xxs + avatarSize,
                  color: theme.threadLine,
                  width: style.borderWidth,
                ),
                child: content,
              )
            : content,
      ),
    );
  }

  Widget _commentMenu(CommunityCommentDetails d, CommunityLocalizations l10n, CommunityStyle style) =>
      PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz, size: 18, color: style.textSecondary),
        tooltip: '',
        onSelected: (action) => switch (action) {
          'edit' => d.onEdit?.call(),
          'delete' => d.onDelete?.call(),
          'report' => d.onReport?.call(),
          'block' => d.onBlock?.call(),
          _ => null,
        },
        itemBuilder: (_) => [
          if (d.onEdit != null) PopupMenuItem(value: 'edit', child: Text(l10n.editAction)),
          if (d.onDelete != null) PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
          if (d.onReport != null) PopupMenuItem(value: 'report', child: Text(l10n.report)),
          if (d.onBlock != null) PopupMenuItem(value: 'block', child: Text(l10n.block)),
        ],
      );
}

class _CommentAction extends StatelessWidget {
  const _CommentAction({required this.label, this.active = false, this.onPressed});

  final String label;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final press = onPressed;
    return Semantics(
      selected: active ? true : null,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: active ? style.accent : style.textSecondary,
          disabledForegroundColor: style.textTertiary,
          textStyle: style.typography.label.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
          tapTargetSize: MaterialTapTargetSize.padded,
          minimumSize: Size(style.minTouchTarget, style.minTouchTarget - style.spacing.lg),
          padding: EdgeInsets.symmetric(horizontal: style.spacing.sm),
          shape: const StadiumBorder(),
        ),
        onPressed: press == null
            ? null
            : () {
                if (!active) HapticFeedback.selectionClick();
                press();
              },
        child: CommunityBump(active: active, child: Text(label)),
      ),
    );
  }
}

class _CommentLikes extends StatelessWidget {
  const _CommentLikes({required this.count, required this.active});

  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final color = active ? style.accent : style.textSecondary;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: style.spacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? style.accentMuted : style.surface,
          borderRadius: style.radii.pillRadius,
          border: Border.fromBorderSide(style.borderSide),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.spacing.sm, vertical: style.spacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded, size: 14, color: CommunityTheme.of(context).like),
              SizedBox(width: style.spacing.xxs),
              Text('$count', style: style.typography.label.copyWith(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
