import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/features/config/presentation/cubit/community_banners_cubit.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/banner_link.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

typedef CommunityBannerBuilder =
    Widget Function(BuildContext context, CommunityBanner banner, VoidCallback? onOpen, VoidCallback? onDismiss);

class CommunityBannerHost extends StatelessWidget {
  const CommunityBannerHost({
    super.key,
    this.maxVisible = 3,
    this.padding = EdgeInsets.zero,
    this.builder,
    this.onBannerLink,
  });

  final int maxVisible;
  final EdgeInsetsGeometry padding;
  final CommunityBannerBuilder? builder;
  final CommunityBannerLinkCallback? onBannerLink;

  @override
  Widget build(BuildContext context) {
    final features = context.communityFeatures;
    if (features == null) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) => CommunityBannersCubit(features.configService, features.bannerDismissals, maxVisible: maxVisible),
      child: BlocBuilder<CommunityBannersCubit, List<CommunityBanner>>(
        builder: (context, banners) {
          if (banners.isEmpty) return const SizedBox.shrink();
          final cubit = context.read<CommunityBannersCubit>();
          return Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final banner in banners)
                  Builder(
                    builder: (context) {
                      final onOpen = banner.link == null
                          ? null
                          : () => openCommunityBannerLink(context, banner, onBannerLink: onBannerLink);
                      final onDismiss = banner.dismissible ? () => cubit.dismiss(banner) : null;
                      return builder?.call(context, banner, onOpen, onDismiss) ??
                          CommunityBannerCard(banner: banner, onOpen: onOpen, onDismiss: onDismiss);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CommunityBannerCard extends StatelessWidget {
  const CommunityBannerCard({super.key, required this.banner, this.onOpen, this.onDismiss});

  final CommunityBanner banner;
  final VoidCallback? onOpen;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityBannerDetails(
      banner: banner,
      icon: switch (banner.level) {
        CommunityBannerLevel.info => Icons.info_outline,
        CommunityBannerLevel.warning => Icons.warning_amber,
        CommunityBannerLevel.critical => Icons.error_outline,
      },
      openLabel: l10n.bannerOpen,
      dismissLabel: l10n.bannerDismiss,
      onOpen: onOpen,
      onDismiss: onDismiss,
    );
    return buildSystemPart((b) => b.banner, context, details, _DefaultBannerCard(details: details));
  }
}

class _DefaultBannerCard extends StatelessWidget {
  const _DefaultBannerCard({required this.details});

  final CommunityBannerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final scheme = Theme.of(context).colorScheme;
    final d = details;
    final tone = switch (d.level) {
      CommunityBannerLevel.info => style.accent,
      CommunityBannerLevel.warning => scheme.tertiary,
      CommunityBannerLevel.critical => scheme.error,
    };
    final onOpen = d.onOpen;
    final onDismiss = d.onDismiss;
    return Semantics(
      container: true,
      liveRegion: d.level == CommunityBannerLevel.critical,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(tone.withValues(alpha: 0.05), style.surface),
          border: Border(
            bottom: BorderSide(color: style.divider, width: style.borderWidth),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.xs, spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityToneIcon(icon: d.icon, tone: tone, size: 32),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, style: style.typography.author),
                    if (d.message.isNotEmpty) ...[
                      SizedBox(height: spacing.xxs),
                      Text(d.message, style: style.typography.meta.copyWith(color: style.textPrimary)),
                    ],
                    if (onOpen != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: tone,
                          textStyle: style.typography.label,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: onOpen,
                        child: Text(d.openLabel),
                      ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  tooltip: d.dismissLabel,
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, size: 18, color: style.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
