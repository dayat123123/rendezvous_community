import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_actions.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_skeletons.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/comment_tree.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_composer_field.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_disclaimer.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityPostDetail extends StatelessWidget {
  const CommunityPostDetail({super.key, required this.postId, this.rootCommentId});

  final String postId;
  final String? rootCommentId;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = context.communityFeatures;
    final maxLevels = CommunityTheme.of(context).maxThreadIndentLevels;
    return CommunitySocialGate(
      child: BlocProvider(
        create: (_) => CommentThreadCubit(
          feed: deps.feed,
          comments: deps.comments,
          postId: postId,
          rootCommentId: rootCommentId,
          maxLevels: maxLevels,
          consent: communityConsentGate(context),
          bookmarks: features?.bookmarks,
          edits: features?.edits,
        )..load(),
        child: _PostDetailView(postId: postId, maxLevels: maxLevels),
      ),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  const _PostDetailView({required this.postId, required this.maxLevels});

  final String postId;
  final int maxLevels;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return BlocConsumer<CommentThreadCubit, ThreadState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<CommentThreadCubit>();
        switch (state.status) {
          case LoadStatus.initial || LoadStatus.loading:
            return CommunitySkeleton(itemCount: 1, itemBuilder: (_) => const PostThreadSkeleton());
          case LoadStatus.failure:
            return CommunityErrorView(error: state.error!, onRetry: cubit.load);
          case LoadStatus.ready:
            final post = state.post;
            if (post == null) return CommunityEmptyView(message: l10n.postNotFound, icon: Icons.search_off);
        }
        final post = state.post!;
        final rows = buildThreadRows(state, maxLevels: maxLevels);
        final threadHeader = CommunityThreadHeaderDetails(
          post: post,
          commentCount: post.commentCount,
          label: '${l10n.comments} (${post.commentCount})',
        );
        PostCard card({bool actionsOnly = false}) => PostCard(
          post: post,
          expanded: true,
          showActions: false,
          actionsOnly: actionsOnly,
          source: 'post',
          onEdit: editPostAction(context, post, cubit.canEdit ? cubit.editPost : null),
          onToggleBookmark: bookmarkPostAction(context, cubit.canBookmark ? cubit.togglePostBookmark : null),
          onShare: sharePostAction(context, post),
          onAppeal: appealPostAction(context, post),
          onLike: cubit.togglePostLike,
          onDelete: () async {
            if (await cubit.deletePost() && context.mounted) {
              showCommunityMessage(context, l10n.postDeleted);
              await Navigator.of(context).maybePop();
            }
          },
        );
        final header = <Widget>[
          card(),
          const CommunityDisclaimer(),
          const CommunityDivider(),
          if (state.root != null) _ThreadContext(postId: postId),
          buildFeedPart(
            (b) => b.threadHeader,
            context,
            threadHeader,
            EditorialSectionHeader(title: threadHeader.label, icon: Icons.forum_outlined, divider: false),
          ),
          if (rows.isEmpty) CommunityEmptyView(message: l10n.noComments, icon: Icons.chat_bubble_outline),
        ];

        Widget row(int index) {
          final row = rows[index];
          final view = Padding(
            padding: EdgeInsetsDirectional.only(end: spacing.sm),
            child: ThreadRowView(row: row, postId: postId),
          );
          if (index == 0 || row is! CommentRow || row.level != 0) return view;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommunityDivider(indent: spacing.lg, endIndent: spacing.lg),
              view,
            ],
          );
        }

        return ColoredBox(
          color: style.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth + 40),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      padding: EdgeInsets.only(bottom: spacing.lg),
                      itemCount: header.length + rows.length,
                      itemBuilder: (context, index) =>
                          index < header.length ? header[index] : row(index - header.length),
                    ),
                  ),
                  card(actionsOnly: true),
                  const CommunityDivider(),
                  const _ReplyComposer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThreadContext extends StatelessWidget {
  const _ThreadContext({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final root = context.select((CommentThreadCubit c) => c.state.root)!;
    final details = CommunityThreadContextDetails(
      root: root,
      label: l10n.threadContext,
      actionLabel: l10n.postDetail,
      comment: CommentTile(comment: root, showCollapse: false),
      onOpenPost: () => CommunityNavigator.openPost(context, postId),
    );
    return buildFeedPart((b) => b.threadContext, context, details, _DefaultThreadContext(details: details));
  }
}

class _DefaultThreadContext extends StatelessWidget {
  const _DefaultThreadContext({required this.details});

  final CommunityThreadContextDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.pill,
          borderRadius: style.radii.cardRadius,
          border: Border.fromBorderSide(style.borderSide),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(spacing.md, spacing.xs, spacing.xs, spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.forum_outlined, size: 16, color: style.textSecondary),
                  SizedBox(width: spacing.xs + spacing.xxs),
                  Expanded(child: Text(details.label, style: style.typography.label)),
                  TextButton(
                    onPressed: details.onOpenPost,
                    style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                    child: Text(details.actionLabel),
                  ),
                ],
              ),
              details.comment,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatefulWidget {
  const _ReplyComposer();

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final cubit = context.read<CommentThreadCubit>();
    final reply = cubit.state.replyTo != null;
    if (await cubit.send(_controller.text)) {
      _controller.clear();
      if (mounted) {
        context.trackCommunityEvent(CommunityAnalyticsEvent.commentCreate, {
          'post_id': cubit.postId,
          'is_reply': reply,
          'source': 'post',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(spacing.xl), borderSide: style.borderSide);
    return BlocConsumer<CommentThreadCubit, ThreadState>(
      listenWhen: (a, b) => a.replyTo?.id != b.replyTo?.id && b.replyTo != null,
      listener: (_, _) => _focus.requestFocus(),
      buildWhen: (a, b) => a.replyTo != b.replyTo || a.sending != b.sending,
      builder: (context, state) {
        final replyTo = state.replyTo;
        final cubit = context.read<CommentThreadCubit>();
        final field = CommunityComposerField(
          controller: _controller,
          focusNode: _focus,
          hintText: l10n.writeComment,
          maxLength: 1000,
          maxLines: 5,
          enabled: !state.sending,
          onSubmit: _send,
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: style.pill,
            hintStyle: style.typography.body.copyWith(color: style.textSecondary, fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: style.accent, width: style.borderWidth),
            ),
          ),
        );
        final details = CommunityReplyComposerDetails(
          controller: _controller,
          focusNode: _focus,
          hintText: l10n.writeComment,
          sending: state.sending,
          sendLabel: l10n.reply,
          cancelLabel: l10n.cancel,
          field: field,
          replyTo: replyTo,
          replyingLabel: replyTo == null ? null : l10n.replyingTo(replyTo.author?.name ?? l10n.someone),
          onSend: state.sending ? null : _send,
          onCancelReply: replyTo == null ? null : () => cubit.setReplyTo(null),
        );
        return buildFeedPart((b) => b.replyComposer, context, details, _DefaultReplyComposer(details: details));
      },
    );
  }
}

class _DefaultReplyComposer extends StatelessWidget {
  const _DefaultReplyComposer({required this.details});

  final CommunityReplyComposerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final replying = details.replyingLabel;
    return Material(
      color: style.surface,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.sm, spacing.sm, spacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replying != null)
              Row(
                children: [
                  Icon(Icons.reply, size: 16, color: style.accent),
                  SizedBox(width: spacing.xs + spacing.xxs),
                  Expanded(child: Text(replying, style: style.typography.label)),
                  IconButton(
                    tooltip: details.cancelLabel,
                    color: style.textSecondary,
                    onPressed: details.onCancelReply,
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.sm),
                  child: CommunityAvatar(
                    user: CommunityScope.of(context).currentUser,
                    radius: style.avatarSizes.comment / 2,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(child: details.field),
                SizedBox(width: spacing.sm),
                IconButton.filled(
                  tooltip: details.sendLabel,
                  style: IconButton.styleFrom(
                    backgroundColor: style.accent,
                    foregroundColor: style.onAccent,
                    disabledBackgroundColor: style.pill,
                    disabledForegroundColor: style.textTertiary,
                  ),
                  onPressed: details.onSend,
                  icon: details.sending
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
