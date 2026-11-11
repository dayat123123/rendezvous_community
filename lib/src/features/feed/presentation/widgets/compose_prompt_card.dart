import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_current_user.dart';
import 'package:rendezvous_community/src/features/compose/presentation/composer_action.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/community_compose_post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

class CommunityComposePromptCard extends StatelessWidget {
  const CommunityComposePromptCard({super.key, this.initialStock, this.showQuickActions = true, this.onPosted});

  final String? initialStock;
  final bool showQuickActions;
  final ValueChanged<Post>? onPosted;

  @override
  Widget build(BuildContext context) => CommunityCurrentUserBuilder(builder: _build);

  Widget _build(BuildContext context, UserSummary? user) {
    final l10n = context.communityL10n;
    Future<void> compose({Sentiment? sentiment, CommunityComposerAction? action}) async {
      final post = await showCommunityComposer(
        context,
        initialStock: initialStock,
        initialSentiment: sentiment,
        initialAction: action,
      );
      if (post == null || !context.mounted) return;
      onPosted?.call(post);
      try {
        context.read<FeedCubit>().insertOwnPost(post);
      } on ProviderNotFoundException {
        return;
      }
    }

    final details = CommunityComposePromptDetails(
      user: user,
      hintText: l10n.composePrompt,
      onCompose: compose,
      onComposeWith: compose,
      quickActions: showQuickActions
          ? [
              CommunityComposeQuickAction(
                label: l10n.sentimentBullish,
                icon: Icons.trending_up,
                sentiment: Sentiment.bullish,
              ),
              CommunityComposeQuickAction(
                label: l10n.sentimentBearish,
                icon: Icons.trending_down,
                sentiment: Sentiment.bearish,
              ),
              CommunityComposeQuickAction(
                label: l10n.composeQuickImage,
                icon: Icons.image_outlined,
                action: CommunityComposerAction.image,
              ),
              CommunityComposeQuickAction(
                label: l10n.composeQuickPoll,
                icon: Icons.poll_outlined,
                action: CommunityComposerAction.poll,
              ),
              if (initialStock == null)
                CommunityComposeQuickAction(
                  label: l10n.composeQuickCashtag,
                  icon: Icons.candlestick_chart_outlined,
                  action: CommunityComposerAction.cashtag,
                ),
            ]
          : const [],
    );
    return buildFeedPart((b) => b.composePrompt, context, details, _DefaultComposePrompt(details: details));
  }
}

class _DefaultComposePrompt extends StatelessWidget {
  const _DefaultComposePrompt({required this.details});

  final CommunityComposePromptDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final actions = details.quickActions;
    final composeWith = details.onComposeWith;
    return EditorialSection(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CommunityAvatar(user: details.user, radius: style.avatarSizes.post / 2),
              SizedBox(width: spacing.sm + spacing.xxs),
              Expanded(
                child: Material(
                  color: style.pill,
                  shape: StadiumBorder(side: style.borderSide),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: details.onCompose,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
                      child: Text(
                        details.hintText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.body.copyWith(color: style.textSecondary, fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty && composeWith != null) ...[
            SizedBox(height: spacing.sm),
            Padding(
              padding: EdgeInsetsDirectional.only(start: style.avatarSizes.post + spacing.xs),
              child: Wrap(
                spacing: spacing.xxs,
                runSpacing: spacing.xxs,
                children: [
                  for (final action in actions)
                    _QuickAction(
                      action: action,
                      onTap: () => composeWith(sentiment: action.sentiment, action: action.action),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.action, required this.onTap});

  final CommunityComposeQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final colors = CommunityTheme.of(context);
    final color = switch (action.sentiment) {
      Sentiment.bullish => colors.onBullish,
      Sentiment.bearish => colors.onBearish,
      _ => style.textSecondary,
    };
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(action.icon, size: 18, color: color),
      label: Text(action.label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: style.typography.label,
        padding: EdgeInsets.symmetric(horizontal: style.spacing.sm + style.spacing.xxs),
        minimumSize: Size(0, style.minTouchTarget),
        shape: const StadiumBorder(),
      ),
    );
  }
}
