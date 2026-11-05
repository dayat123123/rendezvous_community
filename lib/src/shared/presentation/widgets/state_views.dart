import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityEmptyView extends StatelessWidget {
  const CommunityEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.forum_outlined,
    this.action,
    this.title,
  });

  final String message;
  final IconData icon;
  final Widget? action;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final details = CommunityEmptyViewDetails(message: message, icon: icon, action: action, title: title);
    return buildSharedPart(
      (b) => b.emptyView,
      context,
      details,
      _StateView(icon: icon, message: message, title: title, action: action),
    );
  }
}

class CommunityErrorView extends StatelessWidget {
  const CommunityErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityErrorViewDetails(error: error, message: l10n.errorMessage(error), onRetry: onRetry);
    final retry = onRetry;
    return buildSharedPart(
      (b) => b.errorView,
      context,
      details,
      _StateView(
        icon: Icons.cloud_off_outlined,
        message: details.message,
        error: true,
        action: retry == null
            ? null
            : OutlinedButton.icon(
                style: CommunityStyle.of(context).secondaryButtonStyle(),
                onPressed: retry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
              ),
      ),
    );
  }
}

class CommunityLoadingView extends StatelessWidget {
  const CommunityLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final details = CommunityLoadingViewDetails(message: message);
    return buildSharedPart((b) => b.loadingView, context, details, _DefaultLoadingView(details: details));
  }
}

class _DefaultLoadingView extends StatelessWidget {
  const _DefaultLoadingView({required this.details});

  final CommunityLoadingViewDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final message = details.message;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(style.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: style.accent)),
            if (message != null) ...[
              SizedBox(height: style.spacing.md),
              Text(message, textAlign: TextAlign.center, style: style.typography.meta),
            ],
          ],
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.message, this.title, this.action, this.error = false});

  final IconData icon;
  final String message;
  final String? title;
  final Widget? action;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final scheme = Theme.of(context).colorScheme;
    final action = this.action;
    final title = this.title;
    final headline = style.typography.title.copyWith(fontSize: 17);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(style.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: error
                    ? Color.alphaBlend(scheme.error.withValues(alpha: 0.10), style.surface)
                    : style.accentMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: error ? scheme.error : style.accent),
            ),
            SizedBox(height: style.spacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                children: [
                  if (title != null) ...[
                    Text(title, textAlign: TextAlign.center, style: headline),
                    SizedBox(height: style.spacing.xs),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: title == null
                        ? style.typography.author.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)
                        : style.typography.body.copyWith(color: style.textSecondary),
                  ),
                ],
              ),
            ),
            if (action != null) ...[SizedBox(height: style.spacing.lg), action],
          ],
        ),
      ),
    );
  }
}

class CommunitySkeleton extends StatelessWidget {
  const CommunitySkeleton({super.key, this.itemCount = 5, this.itemBuilder});

  final int itemCount;
  final WidgetBuilder? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final builder = CommunitySharedBuilders.of(context).skeleton;
    final itemBuilder = this.itemBuilder;
    return ExcludeSemantics(
      child: ListView.builder(
        addAutomaticKeepAlives: false,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final fallback = itemBuilder?.call(context) ?? _PostSkeleton(divider: index < itemCount - 1);
          if (builder == null) return fallback;
          final details = CommunitySkeletonDetails(index: index, itemCount: itemCount, custom: itemBuilder != null);
          return builder(context, details, fallback);
        },
      ),
    );
  }
}

class CommunitySkeletonBox extends StatelessWidget {
  const CommunitySkeletonBox({super.key, this.width, this.height = 12, this.radius, this.circle = false});

  final double? width;
  final double height;
  final double? radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return SizedBox(
      width: circle ? height : width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.skeleton,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius ?? style.radii.badge),
        ),
      ),
    );
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton({required this.divider});

  final bool divider;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(color: style.divider, width: style.borderWidth),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CommunitySkeletonBox(height: style.avatarSizes.medium, circle: true),
                SizedBox(width: spacing.sm + spacing.xxs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommunitySkeletonBox(width: 120),
                    SizedBox(height: spacing.xs + spacing.xxs),
                    const CommunitySkeletonBox(width: 72, height: 10),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            const CommunitySkeletonBox(width: double.infinity, height: 14),
            SizedBox(height: spacing.sm),
            const CommunitySkeletonBox(width: double.infinity),
            SizedBox(height: spacing.xs + spacing.xxs),
            const FractionallySizedBox(
              widthFactor: 0.6,
              alignment: AlignmentDirectional.centerStart,
              child: CommunitySkeletonBox(),
            ),
          ],
        ),
      ),
    );
  }
}
