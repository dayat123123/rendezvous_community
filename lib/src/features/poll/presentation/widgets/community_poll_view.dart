import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/features/poll/presentation/cubit/poll_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityPollView extends StatefulWidget {
  const CommunityPollView({super.key, required this.postId, required this.poll, this.canVote = true});

  final String postId;
  final Poll poll;
  final bool canVote;

  @override
  State<CommunityPollView> createState() => _CommunityPollViewState();
}

class _CommunityPollViewState extends State<CommunityPollView> {
  late final PollCubit _cubit = PollCubit(
    polls: CommunityScope.of(context).polls,
    postId: widget.postId,
    poll: widget.poll,
  );

  @override
  void didUpdateWidget(CommunityPollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.poll != oldWidget.poll) _cubit.sync(widget.poll);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PollCubit, PollState>(
        listenWhen: (a, b) => a.errorId != b.errorId,
        listener: (context, state) => showCommunityError(context, state.error!),
        builder: (context, state) {
          final l10n = context.communityL10n;
          final poll = state.poll;
          final now = DateTime.now();
          final closed = poll.isClosedAt(now);
          final details = CommunityPollDetails(
            postId: widget.postId,
            poll: poll,
            canVote: widget.canVote,
            closed: closed,
            showResults: poll.resultsVisible || closed || poll.hasVoted || !widget.canVote,
            summary: [
              l10n.pollVotes(poll.totalVotes),
              if (closed) l10n.pollEnded else l10n.pollEndsIn(l10n.remainingTime(poll.endsAt.difference(now))),
            ].join(' · '),
            pendingOptionId: state.pendingOptionId,
            onVote: widget.canVote && !closed && !poll.hasVoted && state.pendingOptionId == null ? _cubit.vote : null,
          );
          return buildCommunityPart(
            CommunityFeedBuilders.of(context).poll,
            context,
            details,
            _PollBody(details: details),
          );
        },
      ),
    );
  }
}

class _PollBody extends StatelessWidget {
  const _PollBody({required this.details});

  final CommunityPollDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final poll = details.poll;
    final showResults = details.showResults;
    final leading = poll.leadingOptionId;
    final pending = details.pendingOptionId;

    return Padding(
      padding: EdgeInsets.only(top: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, option) in poll.options.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.sm),
              child: _PollOption(
                details: CommunityPollOptionDetails(
                  option: option,
                  index: index,
                  share: poll.share(option),
                  percentLabel: poll.resultsVisible ? '${(poll.share(option) * 100).round()}%' : null,
                  showResults: showResults,
                  resultsVisible: poll.resultsVisible,
                  mine: option.id == poll.myOptionId,
                  leading: option.id == leading,
                  pending: pending == option.id,
                  onVote: showResults || pending != null ? null : () => context.read<PollCubit>().vote(option),
                ),
              ),
            ),
          Text(details.summary, style: style.typography.meta),
        ],
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({required this.details});

  final CommunityPollOptionDetails details;

  @override
  Widget build(BuildContext context) => buildFeedPart(
    (b) => b.pollOption,
    context,
    details,
    details.showResults ? _ResultBar(details: details) : _VoteButton(details: details),
  );
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.details});

  final CommunityPollOptionDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return OutlinedButton(
      onPressed: details.onVote,
      style: style.secondaryButtonStyle().copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(40))),
      child: details.pending
          ? SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary))
          : Text(details.option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.details});

  final CommunityPollOptionDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final option = details.option;
    final mine = details.mine;
    final leading = details.leading;
    final percent = details.percentLabel;
    final text = style.typography.body.copyWith(fontSize: 14, fontWeight: leading ? FontWeight.w700 : FontWeight.w500);
    return Semantics(
      label: '${option.label}${mine ? ', ${l10n.pollYourVote}' : ''}',
      value: percent,
      child: ClipRRect(
        borderRadius: style.radii.pillRadius,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: style.pill)),
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: details.resultsVisible ? details.share.clamp(0, 1) : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: leading ? Color.alphaBlend(style.accent.withValues(alpha: 0.22), style.pill) : style.border,
                    borderRadius: style.radii.pillRadius,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm + spacing.xxs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: text),
                  ),
                  if (mine) ...[
                    Icon(Icons.check_circle, size: 16, color: style.accent),
                    SizedBox(width: spacing.xs + spacing.xxs),
                  ],
                  if (percent != null) Text(percent, style: text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
