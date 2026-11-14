import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/comment_sort.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/comment_tree.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/reply_composer.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_menu.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

const _sortOptions = [CommunityCommentSort.top, CommunityCommentSort.latest];

class CommunityPostComments extends StatelessWidget {
  const CommunityPostComments({
    super.key,
    required this.postId,
    this.initialTopLevel = 3,
    this.sort = CommunityCommentSort.top,
    this.showComposer = true,
    this.autofocusComposer = false,
    this.inline = true,
    this.commentCount,
    this.onOpenThread,
    this.onCommentCountChanged,
    this.builders,
  });

  final String postId;
  final int initialTopLevel;
  final CommunityCommentSort sort;
  final bool showComposer;
  final bool autofocusComposer;
  final bool inline;
  final int? commentCount;
  final ValueChanged<String>? onOpenThread;
  final ValueChanged<int>? onCommentCountChanged;
  final CommunityFeedBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = context.communityFeatures;
    final maxLevels = CommunityTheme.of(context).maxThreadIndentLevels;
    return withFeedBuilders(
      context,
      builders,
      BlocProvider(
        key: ValueKey(postId),
        create: (_) => CommentThreadCubit(
          feed: deps.feed,
          comments: deps.comments,
          postId: postId,
          maxLevels: maxLevels,
          pageSize: 10,
          firstPageSize: math.max(1, initialTopLevel),
          fetchPost: false,
          sort: sort,
          consent: communityConsentGate(context),
          bookmarks: features?.bookmarks,
          edits: features?.edits,
          onCommentCountChanged: onCommentCountChanged,
        )..load(),
        child: _PostCommentsView(
          postId: postId,
          maxLevels: maxLevels,
          showComposer: showComposer,
          autofocusComposer: autofocusComposer,
          inline: inline,
          commentCount: commentCount,
          onOpenThread: onOpenThread,
        ),
      ),
    );
  }
}

class _PostCommentsView extends StatelessWidget {
  const _PostCommentsView({
    required this.postId,
    required this.maxLevels,
    required this.showComposer,
    required this.autofocusComposer,
    required this.inline,
    this.commentCount,
    this.onOpenThread,
  });

  final String postId;
  final int maxLevels;
  final bool showComposer;
  final bool autofocusComposer;
  final bool inline;
  final int? commentCount;
  final ValueChanged<String>? onOpenThread;

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
        final rows = state.status == LoadStatus.ready
            ? buildThreadRows(state, maxLevels: maxLevels)
            : const <ThreadRow>[];
        final total = commentCount;
        final shown = state.comments.values.where((c) => !c.isDeleted).length;
        final remaining = total == null ? 0 : total - shown;
        final children = <Widget>[
          if (showComposer)
            CommentReplyComposer(autofocus: autofocusComposer, hintText: l10n.addComment, source: 'feed_inline'),
          if ((rows.isNotEmpty || (total ?? 0) > 0) && state.sortSupported && state.sort != CommunityCommentSort.oldest)
            _CommentSortHeader(state: state, onSelect: cubit.setSort),
          ...switch (state.status) {
            LoadStatus.initial || LoadStatus.loading => [
              Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.md),
                child: const CommunityLoadingView(),
              ),
            ],
            LoadStatus.failure => [_InlineError(error: state.error!, onRetry: cubit.load)],
            LoadStatus.ready when rows.isEmpty => [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
                child: Text(
                  l10n.commentsFirst,
                  textAlign: TextAlign.center,
                  style: style.typography.meta.copyWith(color: style.textSecondary),
                ),
              ),
            ],
            LoadStatus.ready => [
              for (final row in rows)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: spacing.sm),
                  child: ThreadRowView(
                    row: row,
                    postId: postId,
                    moreCommentsLabel: remaining > 0 ? l10n.viewMoreComments(remaining) : null,
                    onOpenThread: onOpenThread,
                  ),
                ),
            ],
          },
        ];
        if (!inline) {
          return ListView(
            addAutomaticKeepAlives: false,
            padding: EdgeInsets.only(bottom: spacing.lg),
            children: children,
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}

class _CommentSortHeader extends StatelessWidget {
  const _CommentSortHeader({required this.state, required this.onSelect});

  final ThreadState state;
  final ValueChanged<CommunityCommentSort> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final busy = state.status != LoadStatus.ready;
    final details = CommunityCommentSortDetails(
      title: l10n.comments,
      tooltip: l10n.commentSortTooltip,
      selected: state.sort,
      options: _sortOptions,
      labels: [l10n.commentSortTop, l10n.commentSortLatest],
      onSelect: busy ? null : onSelect,
    );
    return buildFeedPart((b) => b.commentSort, context, details, _DefaultCommentSort(details: details));
  }
}

class _DefaultCommentSort extends StatelessWidget {
  const _DefaultCommentSort({required this.details});

  final CommunityCommentSortDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final select = d.onSelect;
    final labelStyle = style.typography.label.copyWith(color: style.textSecondary);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.xs, spacing.sm, 0),
      child: Row(
        children: [
          Text('${d.title} ·', style: labelStyle),
          PopupMenuButton<CommunityCommentSort>(
            tooltip: d.tooltip,
            enabled: select != null,
            initialValue: d.selected,
            onSelected: select,
            itemBuilder: (menuContext) => [
              for (final (index, option) in d.options.indexed)
                communityMenuItem(menuContext, value: option, checked: option == d.selected, label: d.labels[index]),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.selectedLabel,
                    style: labelStyle.copyWith(color: style.textPrimary, fontWeight: FontWeight.w700),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: style.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: style.textSecondary),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(l10n.errorMessage(error), style: style.typography.meta.copyWith(color: style.textSecondary)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: style.accent),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
