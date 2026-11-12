import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_filter.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_sort.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_open_mode.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_feed_filter_tabs.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_feed_list.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/compose_prompt_card.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_tag.dart';

enum CommunityFeedTab { latest, following }

class CommunityStreamFeed extends StatefulWidget {
  const CommunityStreamFeed({
    super.key,
    this.initialTab = CommunityFeedTab.latest,
    this.showComposePrompt = true,
    this.builders,
    this.postOpenMode = CommunityPostOpenMode.navigate,
    this.sort = CommunityFeedSort.latest,
    this.mediaOnly = false,
    this.scrollController,
    this.filter,
    this.showFilterTabs = false,
    this.onFilterChanged,
  });

  final CommunityFeedTab initialTab;
  final bool showComposePrompt;
  final CommunityFeedBuilders? builders;
  final CommunityPostOpenMode postOpenMode;
  final CommunityFeedSort sort;
  final bool mediaOnly;
  final ScrollController? scrollController;
  final String? filter;
  final bool showFilterTabs;
  final ValueChanged<FeedFilter>? onFilterChanged;

  @override
  State<CommunityStreamFeed> createState() => _CommunityStreamFeedState();
}

class _CommunityStreamFeedState extends State<CommunityStreamFeed> {
  late CommunityFeedTab _tab = widget.initialTab;
  late String? _filter = widget.filter;

  @override
  void didUpdateWidget(CommunityStreamFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) _filter = widget.filter;
  }

  void _selectFilter(FeedFilter filter) {
    if (filter.key != _filter) setState(() => _filter = filter.key);
    widget.onFilterChanged?.call(filter);
  }

  void _select(CommunityFeedTab tab) {
    if (tab != _tab) setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final tabs = CommunityFeedTabsDetails(
      tabs: CommunityFeedTab.values,
      labels: [l10n.feedLatest, l10n.feedFollowing],
      selected: _tab,
      onSelect: _select,
    );
    return ColoredBox(
      color: style.background,
      child: Column(
        children: [
          withFeedBuilders(
            context,
            widget.builders,
            Builder(
              builder: (context) => buildFeedPart((b) => b.feedTabs, context, tabs, _DefaultFeedTabs(details: tabs)),
            ),
          ),
          if (widget.showFilterTabs)
            CommunityFeedFilterTabs(selected: _filter, onSelected: _selectFilter, builders: widget.builders),
          Expanded(
            child: CommunityFeedList(
              postOpenMode: widget.postOpenMode,
              sort: widget.sort,
              mediaOnly: widget.mediaOnly,
              key: ValueKey(_tab),
              scope: _tab == CommunityFeedTab.latest ? const FeedScope.global() : const FeedScope.following(),
              emptyMessage: _tab == CommunityFeedTab.latest ? l10n.feedEmpty : l10n.feedFollowingEmpty,
              header: widget.showComposePrompt ? const CommunityComposePromptCard() : null,
              builders: widget.builders,
              scrollController: widget.scrollController,
              filter: _filter,
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultFeedTabs extends StatelessWidget {
  const _DefaultFeedTabs({required this.details});

  final CommunityFeedTabsDetails details;

  static const _icons = {CommunityFeedTab.latest: Icons.public, CommunityFeedTab.following: Icons.people_outline};

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Material(
      color: style.surface,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(spacing.md, spacing.xxs, spacing.md, spacing.xxs),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Wrap(
            spacing: spacing.sm,
            children: [
              for (final (index, tab) in details.tabs.indexed)
                CommunityTag(
                  label: details.labels[index],
                  icon: _icons[tab],
                  selected: tab == details.selected,
                  onTap: () => details.onSelect(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
