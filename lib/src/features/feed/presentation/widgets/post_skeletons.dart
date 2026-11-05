import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key, this.media = false, this.gap = true});

  final bool media;
  final bool gap;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final side = EdgeInsets.symmetric(horizontal: spacing.lg);
    return EditorialSection(
      gap: gap,
      padding: EdgeInsets.only(top: spacing.md, bottom: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: side,
            child: Row(
              children: [
                CommunitySkeletonBox(height: style.avatarSizes.post, circle: true),
                SizedBox(width: spacing.sm + spacing.xxs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommunitySkeletonBox(width: 128, height: 13),
                    SizedBox(height: spacing.xs + spacing.xxs),
                    const CommunitySkeletonBox(width: 84, height: 10),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
          Padding(
            padding: side,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FractionallySizedBox(
                  widthFactor: 0.8,
                  alignment: AlignmentDirectional.centerStart,
                  child: CommunitySkeletonBox(height: 16),
                ),
                SizedBox(height: spacing.md),
                const CommunitySkeletonBox(width: double.infinity),
                SizedBox(height: spacing.sm),
                const CommunitySkeletonBox(width: double.infinity),
                SizedBox(height: spacing.sm),
                const FractionallySizedBox(
                  widthFactor: 0.55,
                  alignment: AlignmentDirectional.centerStart,
                  child: CommunitySkeletonBox(),
                ),
              ],
            ),
          ),
          if (media) ...[SizedBox(height: spacing.md), const AspectRatio(aspectRatio: 16 / 9, child: _Block())],
          SizedBox(height: spacing.md),
          Padding(
            padding: side,
            child: Row(
              children: [
                CommunitySkeletonBox(width: 92, height: 32, radius: style.radii.pill),
                SizedBox(width: spacing.lg),
                const CommunitySkeletonBox(width: 40, height: 16),
                SizedBox(width: spacing.lg),
                const CommunitySkeletonBox(width: 24, height: 16),
                const Spacer(),
                const CommunitySkeletonBox(width: 20, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentSkeleton extends StatelessWidget {
  const CommentSkeleton({super.key, this.reply = false, this.lines = 2});

  final bool reply;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final size = reply ? style.avatarSizes.reply : style.avatarSizes.comment;
    final indent = reply ? spacing.lg + style.avatarSizes.comment + spacing.sm : spacing.lg;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(indent, spacing.sm, spacing.xxl * 2, spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunitySkeletonBox(height: size, circle: true),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommunitySkeletonBox(width: double.infinity, height: 28.0 + lines * 16, radius: 16),
                SizedBox(height: spacing.sm),
                const CommunitySkeletonBox(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostThreadSkeleton extends StatelessWidget {
  const PostThreadSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PostCardSkeleton(gap: false),
        SizedBox(height: spacing.md),
        const CommentSkeleton(),
        const CommentSkeleton(reply: true, lines: 1),
        const CommentSkeleton(lines: 1),
        const CommentSkeleton(),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block();

  @override
  Widget build(BuildContext context) => ColoredBox(color: CommunityStyle.of(context).skeleton);
}
