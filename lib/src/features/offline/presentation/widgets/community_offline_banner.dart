import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_offline_scope.dart';
import 'package:rendezvous_community/src/core/network/community_connectivity.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityOfflineBanner extends StatelessWidget {
  const CommunityOfflineBanner({super.key, this.message, this.connectivity, this.builder});

  final String? message;
  final CommunityConnectivity? connectivity;
  final Widget Function(BuildContext context, String message)? builder;

  @override
  Widget build(BuildContext context) {
    final source = connectivity ?? CommunityOfflineScope.maybeOf(context)?.connectivity;
    if (source == null) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: source.online,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        final text = message ?? context.communityL10n.offlineBanner;
        return builder?.call(context, text) ?? CommunityOfflineNotice(message: text);
      },
    );
  }
}

class CommunityOfflineNotice extends StatelessWidget {
  const CommunityOfflineNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final details = CommunityOfflineDetails(message: message);
    return buildSystemPart((b) => b.offlineBanner, context, details, _DefaultOfflineNotice(details: details));
  }
}

class _DefaultOfflineNotice extends StatelessWidget {
  const _DefaultOfflineNotice({required this.details});

  final CommunityOfflineDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.pill,
          border: Border(
            bottom: BorderSide(color: style.divider, width: style.borderWidth),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: style.textSecondary),
              SizedBox(width: spacing.sm),
              Expanded(child: Text(details.message, style: style.typography.meta)),
            ],
          ),
        ),
      ),
    );
  }
}
