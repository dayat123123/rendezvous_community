import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

typedef PostCommentAudienceSaver = Future<bool> Function(Post post, CommentAudience audience);

String commentAudienceLabel(CommunityLocalizations l10n, CommentAudience audience) => switch (audience) {
  CommentAudience.everyone => l10n.commentAudienceEveryone,
  CommentAudience.following => l10n.commentAudienceFollowing,
  CommentAudience.followers => l10n.commentAudienceFollowers,
  CommentAudience.followingAndFollowers => l10n.commentAudienceFollowingAndFollowers,
  CommentAudience.off => l10n.commentAudienceOff,
};

List<CommunityCommentAudienceOption> commentAudienceOptions(
  CommunityLocalizations l10n,
  List<CommentAudience> audiences,
) => [
  for (final audience in audiences)
    CommunityCommentAudienceOption(
      audience: audience,
      label: commentAudienceLabel(l10n, audience),
      hint: audience == CommentAudience.off ? l10n.commentAudienceOffHint : null,
    ),
];

String commentRestrictionMessage(CommunityLocalizations l10n, Post post, {required bool isMine}) {
  if (post.commentsOff) return isMine ? l10n.commentsDisabledOwner : l10n.commentsDisabled;
  final name = post.author.handle;
  return switch (post.commentRestriction) {
    CommentAudience.following => l10n.commentsOnlyFollowing(name),
    CommentAudience.followers => l10n.commentsOnlyFollowers(name),
    CommentAudience.followingAndFollowers => l10n.commentsOnlyFollowingAndFollowers(name),
    _ => l10n.commentsUnavailable,
  };
}

Future<CommentAudience?> showCommentAudienceDialog(
  BuildContext context, {
  required CommentAudience selected,
  List<CommentAudience> options = CommentAudience.postOptions,
  String? title,
}) {
  final l10n = context.communityL10n;
  final carry = carryCommunityBuilders(context);
  final feedBuilders = CommunityFeedBuilders.of(context, listen: false);
  return showDialog<CommentAudience>(
    context: context,
    builder: (dialogContext) => carry(
      CommunityFeedBuildersScope(
        builders: feedBuilders,
        child: Builder(
          builder: (context) {
            final details = CommunityCommentAudienceSheetDetails(
              title: title ?? l10n.commentAudienceTitle,
              selected: selected,
              options: commentAudienceOptions(l10n, options),
              onSelect: (audience) => Navigator.pop(dialogContext, audience),
            );
            return buildFeedPart(
              (b) => b.commentAudienceSheet,
              context,
              details,
              CommunityCommentAudienceDialog(details: details),
            );
          },
        ),
      ),
    ),
  );
}

@Deprecated('Use showCommentAudienceDialog')
Future<CommentAudience?> showCommentAudienceSheet(
  BuildContext context, {
  required CommentAudience selected,
  List<CommentAudience> options = CommentAudience.postOptions,
  String? title,
}) => showCommentAudienceDialog(context, selected: selected, options: options, title: title);

class CommunityCommentAudienceDialog extends StatelessWidget {
  const CommunityCommentAudienceDialog({super.key, required this.details});

  final CommunityCommentAudienceSheetDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      title: Text(details.title, style: style.typography.title),
      contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: _AudienceRadios(details: details)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
          child: Text(context.communityL10n.cancel),
        ),
      ],
    );
  }
}

class CommunityCommentAudienceSheet extends StatelessWidget {
  const CommunityCommentAudienceSheet({super.key, required this.details});

  final CommunityCommentAudienceSheetDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.sm),
              child: Text(details.title, style: style.typography.title),
            ),
            _AudienceRadios(details: details),
          ],
        ),
      ),
    );
  }
}

class _AudienceRadios extends StatelessWidget {
  const _AudienceRadios({required this.details});

  final CommunityCommentAudienceSheetDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    return RadioGroup<CommentAudience>(
      groupValue: d.selected,
      onChanged: (audience) {
        if (audience != null) d.onSelect(audience);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in d.options)
            RadioListTile<CommentAudience>(
              key: ValueKey('comment-audience-${option.audience.wire}'),
              value: option.audience,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? style.accent : style.textTertiary,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: spacing.sm),
              title: Text(option.label, style: style.typography.body),
              subtitle: option.hint == null ? null : Text(option.hint!, style: style.typography.meta),
            ),
        ],
      ),
    );
  }
}

class CommentRestrictionNotice extends StatelessWidget {
  const CommentRestrictionNotice({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final isMine = CommunityScope.of(context).currentUser?.id == post.author.id;
    final details = CommunityCommentRestrictionDetails(
      post: post,
      isMine: isMine,
      message: commentRestrictionMessage(context.communityL10n, post, isMine: isMine),
    );
    return buildFeedPart((b) => b.commentRestriction, context, details, _DefaultCommentRestriction(details: details));
  }
}

class _DefaultCommentRestriction extends StatelessWidget {
  const _DefaultCommentRestriction({required this.details});

  final CommunityCommentRestrictionDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Material(
      color: style.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
        child: Row(
          children: [
            Icon(
              details.commentsOff ? Icons.comments_disabled_outlined : Icons.lock_outline,
              size: 18,
              color: style.textSecondary,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(details.message, style: style.typography.meta.copyWith(color: style.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityComposeCommentAudience extends StatelessWidget {
  const CommunityComposeCommentAudience({super.key, required this.details});

  final CommunityComposeCommentAudienceDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    return InkWell(
      key: const ValueKey('compose-comment-audience'),
      onTap: d.onTap,
      borderRadius: style.radii.controlRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: style.minTouchTarget),
        child: Row(
          children: [
            Icon(
              d.audience == CommentAudience.off ? Icons.comments_disabled_outlined : Icons.mode_comment_outlined,
              size: 18,
              color: style.textSecondary,
            ),
            SizedBox(width: spacing.sm),
            Expanded(child: Text(d.title, style: style.typography.label)),
            Flexible(
              child: Text(
                d.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: style.typography.label.copyWith(color: d.enabled ? style.accent : style.textTertiary),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: style.textSecondary),
          ],
        ),
      ),
    );
  }
}
