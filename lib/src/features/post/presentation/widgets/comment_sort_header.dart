import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/comment_sort.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_menu.dart';

const commentSortOptions = [CommunityCommentSort.top, CommunityCommentSort.latest];

class CommentSortHeader extends StatelessWidget {
  const CommentSortHeader({super.key, required this.state, required this.onSelect});

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
      options: commentSortOptions,
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
