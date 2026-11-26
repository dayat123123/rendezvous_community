import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_research.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';

class CommunityPostResearch extends StatelessWidget {
  const CommunityPostResearch({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  Widget build(BuildContext context) {
    final research = details.post.research;
    if (research == null) return const SizedBox.shrink();
    final part = CommunityResearchDetails(post: details.post, research: research, initiallyExpanded: details.expanded);
    return buildCommunityPart(
      CommunityFeedBuilders.of(context).researchCard,
      context,
      part,
      CommunityResearchCard(
        key: ValueKey('research-${research.id}'),
        research: research,
        initiallyExpanded: details.expanded,
      ),
    );
  }
}

class CommunityResearchCard extends StatefulWidget {
  const CommunityResearchCard({super.key, required this.research, this.initiallyExpanded = false});

  final PostResearch research;
  final bool initiallyExpanded;

  @override
  State<CommunityResearchCard> createState() => _CommunityResearchCardState();
}

class _CommunityResearchCardState extends State<CommunityResearchCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final l10n = context.communityL10n;
    final research = widget.research;
    final doc = research.document;
    final code = research.stockCode;
    final headline = doc.headline;
    final subtitle = doc.subtitle;
    final badge = doc.badge;
    final disclaimer = doc.disclaimer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.surface,
        borderRadius: BorderRadius.circular(style.radii.card),
        border: Border.fromBorderSide(style.borderSide),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (code != null) ...[_StockTile(code: code), SizedBox(width: spacing.sm)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title, style: style.typography.label.copyWith(color: style.textPrimary)),
                      if (subtitle != null)
                        Text(subtitle, style: style.typography.meta.copyWith(color: style.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            Row(
              children: [
                if (badge != null)
                  DecoratedBox(
                    decoration: BoxDecoration(color: style.accentMuted, borderRadius: style.radii.pillRadius),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xxs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: style.accent),
                          SizedBox(width: spacing.xxs),
                          Text(badge, style: style.typography.badge.copyWith(color: style.accent)),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  key: const ValueKey('research-toggle'),
                  tooltip: _expanded ? l10n.collapse : l10n.expand,
                  visualDensity: VisualDensity.compact,
                  color: style.textSecondary,
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ),
              ],
            ),
            if (headline != null) ...[
              SizedBox(height: spacing.xs),
              Text(headline, style: style.typography.title.copyWith(color: style.textPrimary)),
            ],
            if (_expanded) ...[
              for (final block in doc.blocks) ...[SizedBox(height: spacing.md), _ResearchBlockView(block: block)],
              if (disclaimer != null) ...[
                SizedBox(height: spacing.md),
                Text(disclaimer, style: style.typography.meta.copyWith(color: style.textTertiary)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.symmetric(horizontal: style.spacing.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: style.chip, borderRadius: style.radii.controlRadius),
      child: Text(
        code,
        style: style.typography.badge.copyWith(color: style.onChip, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ResearchBlockView extends StatelessWidget {
  const _ResearchBlockView({required this.block});

  final ResearchBlock block;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final body = style.typography.body.copyWith(color: style.textPrimary);
    return switch (block) {
      ResearchParagraph(:final text) => Text(text, style: body),
      ResearchMetrics(:final metrics) => Wrap(
        spacing: style.spacing.sm,
        runSpacing: style.spacing.sm,
        children: [for (final metric in metrics) _MetricChip(metric: metric)],
      ),
      ResearchList(:final numbered, :final items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : style.spacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (numbered) _NumberBox(number: i + 1) else _Bullet(color: style.textSecondary),
                  SizedBox(width: style.spacing.sm),
                  Expanded(child: Text(items[i], style: body)),
                ],
              ),
            ),
        ],
      ),
      ResearchCallout(:final title, :final text) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.radii.card),
          border: Border.all(color: style.accent, width: style.borderWidth),
        ),
        child: Padding(
          padding: EdgeInsets.all(style.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: style.typography.label.copyWith(color: style.accent)),
                SizedBox(height: style.spacing.xs),
              ],
              Text(text, style: body),
            ],
          ),
        ),
      ),
    };
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.metric});

  final ResearchMetric metric;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final theme = CommunityTheme.of(context);
    final (background, foreground) = switch (metric.trend) {
      ResearchTrend.up => (theme.bullish, theme.onBullish),
      ResearchTrend.down => (theme.bearish, theme.onBearish),
      ResearchTrend.flat || null => (theme.neutral, theme.onNeutral),
    };
    final change = metric.change;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: style.radii.controlRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.spacing.sm, vertical: style.spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(metric.label, style: style.typography.meta.copyWith(color: foreground)),
              Text(
                metric.value,
                style: style.typography.label.copyWith(color: foreground, fontWeight: FontWeight.w700),
              ),
              if (change != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (metric.trend case final trend?)
                      Icon(
                        switch (trend) {
                          ResearchTrend.up => Icons.arrow_drop_up,
                          ResearchTrend.down => Icons.arrow_drop_down,
                          ResearchTrend.flat => Icons.remove,
                        },
                        size: 16,
                        color: foreground,
                      ),
                    Flexible(
                      child: Text(change, style: style.typography.meta.copyWith(color: foreground)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: style.accentMuted, borderRadius: style.radii.controlRadius),
      child: Text('$number', style: style.typography.badge.copyWith(color: style.accent)),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, left: 7, right: 7),
    child: SizedBox.square(
      dimension: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    ),
  );
}
