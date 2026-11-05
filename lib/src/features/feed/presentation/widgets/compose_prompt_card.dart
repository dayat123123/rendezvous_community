import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/community_compose_post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

class ComposePromptCard extends StatelessWidget {
  const ComposePromptCard({super.key, this.initialStock});

  final String? initialStock;

  @override
  Widget build(BuildContext context) {
    final details = CommunityComposePromptDetails(
      user: CommunityScope.of(context).currentUser,
      hintText: context.communityL10n.composePrompt,
      onCompose: () async {
        final post = await showCommunityComposer(context, initialStock: initialStock);
        if (post != null && context.mounted) context.read<FeedCubit>().insertOwnPost(post);
      },
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
    return EditorialSection(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      onTap: details.onCompose,
      child: Row(
        children: [
          CommunityAvatar(user: details.user, radius: style.avatarSizes.post / 2),
          SizedBox(width: spacing.sm + spacing.xxs),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: style.pill,
                borderRadius: style.radii.pillRadius,
                border: Border.fromBorderSide(style.borderSide),
              ),
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
          SizedBox(width: spacing.xs),
          SizedBox.square(
            dimension: style.minTouchTarget,
            child: Icon(Icons.photo_library_outlined, color: style.accent),
          ),
        ],
      ),
    );
  }
}
