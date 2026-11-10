import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
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
import 'package:rendezvous_community/src/features/post/presentation/widgets/reply_composer.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
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
                  const CommentReplyComposer(),
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
