import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_composer_field.dart';

class CommentReplyComposer extends StatefulWidget {
  const CommentReplyComposer({super.key, this.autofocus = false, this.hintText, this.source = 'post'});

  final bool autofocus;
  final String? hintText;
  final String source;

  @override
  State<CommentReplyComposer> createState() => _CommentReplyComposerState();
}

class _CommentReplyComposerState extends State<CommentReplyComposer> {
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
          'source': widget.source,
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
        final hint = widget.hintText ?? l10n.writeComment;
        final field = CommunityComposerField(
          controller: _controller,
          focusNode: _focus,
          hintText: hint,
          maxLength: 1000,
          maxLines: 5,
          autofocus: widget.autofocus,
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
          hintText: hint,
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
