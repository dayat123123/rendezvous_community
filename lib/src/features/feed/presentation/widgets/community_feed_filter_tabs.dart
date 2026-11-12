import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_filter.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_tag.dart';

abstract final class CommunityFeedFilters {
  static Future<List<FeedFilter>> load(BuildContext context, {bool refresh = false}) async {
    final feed = CommunityScope.of(context).feed;
    if (feed is! FeedFilterRepository) {
      return [
        for (final f in builtInFeedFilters)
          if (f.content != FeedFilterContent.poll) f,
      ];
    }
    return (feed as FeedFilterRepository).getFeedFilters(refresh: refresh);
  }

  static IconData icon(String? name) => switch (name) {
    'schedule' => Icons.schedule,
    'trending_up' => Icons.trending_up,
    'image' => Icons.image_outlined,
    'poll' => Icons.poll_outlined,
    'chart' || 'show_chart' => Icons.show_chart,
    'star' => Icons.star_outline,
    'video' => Icons.videocam_outlined,
    'campaign' => Icons.campaign_outlined,
    _ => Icons.label_outline,
  };
}

class CommunityFeedFilterTabs extends StatefulWidget {
  const CommunityFeedFilterTabs({super.key, required this.selected, required this.onSelected, this.builders});

  final String? selected;
  final ValueChanged<FeedFilter> onSelected;
  final CommunityFeedBuilders? builders;

  @override
  State<CommunityFeedFilterTabs> createState() => _CommunityFeedFilterTabsState();
}

class _CommunityFeedFilterTabsState extends State<CommunityFeedFilterTabs> {
  List<FeedFilter>? _filters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filters == null) _load();
  }

  Future<void> _load() async {
    List<FeedFilter> filters;
    try {
      filters = await CommunityFeedFilters.load(context);
    } catch (_) {
      filters = const [];
    }
    if (mounted) setState(() => _filters = filters);
  }

  @override
  Widget build(BuildContext context) {
    final filters = _filters ?? const <FeedFilter>[];
    final locale = Localizations.localeOf(context);
    final details = CommunityFeedFilterTabsDetails(
      filters: filters,
      labels: [for (final f in filters) f.label(locale)],
      selected: widget.selected,
      onSelect: widget.onSelected,
      loading: _filters == null,
    );
    return withFeedBuilders(
      context,
      widget.builders,
      Builder(
        builder: (context) =>
            buildFeedPart((b) => b.feedFilterTabs, context, details, _DefaultFeedFilterTabs(details: details)),
      ),
    );
  }
}

class _DefaultFeedFilterTabs extends StatelessWidget {
  const _DefaultFeedFilterTabs({required this.details});

  final CommunityFeedFilterTabsDetails details;

  @override
  Widget build(BuildContext context) {
    if (details.filters.isEmpty) return const SizedBox.shrink();
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Material(
      color: style.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.fromSTEB(spacing.md, spacing.xxs, spacing.md, spacing.xs),
        child: Row(
          children: [
            for (final (index, filter) in details.filters.indexed) ...[
              if (index > 0) SizedBox(width: spacing.sm),
              CommunityTag(
                label: details.labels[index],
                icon: CommunityFeedFilters.icon(filter.icon),
                selected: filter.key == details.selected,
                onTap: () => details.onSelect(filter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
