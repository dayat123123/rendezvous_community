import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

typedef SupportIncidentArticleOpener = void Function(BuildContext context, SupportIncident incident);

abstract final class SupportIncidentDismissals {
  static final ValueNotifier<Set<String>> dismissed = ValueNotifier(const <String>{});

  static void dismiss(String id) => dismissed.value = {...dismissed.value, id};

  @visibleForTesting
  static void reset() => dismissed.value = const <String>{};
}

CommunitySupportTone supportIncidentTone(SupportIncidentLevel level) => switch (level) {
  SupportIncidentLevel.info => CommunitySupportTone.info,
  SupportIncidentLevel.warning => CommunitySupportTone.warning,
  SupportIncidentLevel.critical => CommunitySupportTone.danger,
};

IconData supportIncidentIcon(SupportIncidentLevel level) => switch (level) {
  SupportIncidentLevel.info => Icons.info_outline,
  SupportIncidentLevel.warning => Icons.warning_amber_rounded,
  SupportIncidentLevel.critical => Icons.error_outline,
};

class SupportIncidentBanners extends StatelessWidget {
  const SupportIncidentBanners({super.key, required this.incidents, this.onOpenArticle});

  final List<SupportIncident> incidents;
  final SupportIncidentArticleOpener? onOpenArticle;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
    valueListenable: SupportIncidentDismissals.dismissed,
    builder: (context, dismissed, _) {
      final now = DateTime.now();
      final visible = [
        for (final incident in incidents)
          if (incident.activeAt(now) && !dismissed.contains(incident.id)) incident,
      ];
      if (visible.isEmpty) return const SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final incident in visible)
            SupportIncidentBanner(key: ValueKey(incident.id), incident: incident, onOpenArticle: onOpenArticle),
        ],
      );
    },
  );
}

class SupportIncidentBanner extends StatelessWidget {
  const SupportIncidentBanner({super.key, required this.incident, this.onOpenArticle});

  final SupportIncident incident;
  final SupportIncidentArticleOpener? onOpenArticle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final open = onOpenArticle;
    final article = incident.faqArticleId != null && open != null;
    final details = CommunitySupportIncidentDetails(
      incident: incident,
      tone: supportIncidentTone(incident.level),
      icon: supportIncidentIcon(incident.level),
      levelLabel: switch (incident.level) {
        SupportIncidentLevel.info => l10n.supportIncidentInfo,
        SupportIncidentLevel.warning => l10n.supportIncidentWarning,
        SupportIncidentLevel.critical => l10n.supportIncidentCritical,
      },
      dismissLabel: l10n.supportIncidentDismiss,
      onDismiss: () => SupportIncidentDismissals.dismiss(incident.id),
      moreLabel: article ? l10n.supportIncidentMore : null,
      onMore: article ? () => open(context, incident) : null,
    );
    return buildSupportPart((b) => b.incidentBanner, context, details, _DefaultIncidentBanner(details: details));
  }
}

class _DefaultIncidentBanner extends StatelessWidget {
  const _DefaultIncidentBanner({required this.details});

  final CommunitySupportIncidentDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final color = supportToneColor(context, d.tone);
    final onMore = d.onMore;
    final moreLabel = d.moreLabel;
    return Semantics(
      container: true,
      label: d.levelLabel,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: supportSoftBackground(style, color),
          border: Border(
            bottom: BorderSide(color: color.withValues(alpha: 0.25), width: style.borderWidth),
          ),
        ),
        padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.sm, spacing.xs, spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs),
              child: Icon(d.icon, size: 18, color: color),
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(d.title, style: style.typography.label.copyWith(color: color)),
                  if (d.body.isNotEmpty) ...[
                    SizedBox(height: spacing.xxs),
                    Text(d.body, style: style.typography.meta.copyWith(color: style.textPrimary)),
                  ],
                  if (onMore != null && moreLabel != null)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: color,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, style.minTouchTarget),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: style.typography.label,
                      ),
                      onPressed: onMore,
                      child: Text(moreLabel),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: d.dismissLabel,
              onPressed: d.onDismiss,
              icon: Icon(Icons.close, size: 18, color: style.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
