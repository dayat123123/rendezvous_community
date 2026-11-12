import 'package:flutter/material.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'stock_directory.dart';

enum StreamSource { forYou, latest, following, official, watchlist, indices }

class StreamPage extends StatefulWidget {
  const StreamPage({super.key, required this.watchlist});

  final List<String> watchlist;

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  StreamSource _source = StreamSource.forYou;
  String _filter = 'latest';
  FeedFilter? _filterDef;
  String? _stock;
  String? _index;

  FeedScope get _scope => switch (_source) {
    StreamSource.forYou => const FeedScope.forYou(),
    StreamSource.latest => const FeedScope.global(),
    StreamSource.following => const FeedScope.following(),
    StreamSource.official => const FeedScope.official(),
    StreamSource.watchlist => _stock == null ? FeedScope.stocks(widget.watchlist) : FeedScope.stock(_stock!),
    StreamSource.indices => FeedScope.stock(_index ?? 'IHSG'),
  };

  void _selectSource(StreamSource source) => setState(() {
    _source = source;
    _stock = null;
    _index = null;
  });

  void _selectIndex(String? code) => setState(() {
    _source = StreamSource.indices;
    _stock = null;
    _index = code;
  });

  void _selectFilter(FeedFilter filter) => setState(() {
    _filter = filter.key;
    _filterDef = filter;
  });

  void _selectStock(String? code) => setState(() {
    _source = StreamSource.watchlist;
    _stock = code;
  });

  String _emptyMessage(CommunityLocalizations l10n) {
    if (_filterDef?.content == FeedFilterContent.media) return l10n.feedMediaEmpty;
    return switch (_source) {
      StreamSource.forYou => l10n.feedForYouEmpty,
      StreamSource.latest => l10n.feedEmpty,
      StreamSource.following => l10n.feedFollowingEmpty,
      StreamSource.official => l10n.feedOfficialEmpty,
      StreamSource.watchlist => l10n.feedWatchlistEmpty,
      StreamSource.indices => l10n.indexFeedEmpty(_index ?? 'IHSG'),
    };
  }

  Widget _feed(BuildContext context, {Widget? extraHeader}) {
    final l10n = context.communityL10n;
    final filters = _FilterBar(selected: _filter, onSelect: _selectFilter);
    if (_source == StreamSource.indices) {
      final index = _index;
      if (index == null) return CommunityIndexList(onOpen: (_, instrument) => _selectIndex(instrument.code));
      return Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _selectIndex(null),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.indexLabel),
            ),
          ),
          Expanded(
            child: CommunityIndexFeed(
              key: ValueKey((index, _filter)),
              indexCode: index,
              filter: _filter,
              postOpenMode: CommunityPostOpenMode.inlineComments,
            ),
          ),
          filters,
        ],
      );
    }
    return CommunityFeedList(
      key: ValueKey((_scope, _filter)),
      scope: _scope,
      filter: _filter,
      postOpenMode: CommunityPostOpenMode.inlineComments,
      emptyMessage: _emptyMessage(l10n),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommunityComposePromptCard(initialStock: _stock),
          ?extraHeader,
          filters,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final style = CommunityStyle.of(context);
    if (width < 900) {
      return ColoredBox(
        color: style.background,
        child: Column(
          children: [
            _SourceChips(
              source: _source,
              stock: _stock,
              watchlist: widget.watchlist,
              onSource: _selectSource,
              onStock: _selectStock,
              onIndices: () => _selectIndex(null),
            ),
            Expanded(
              child: _feed(
                context,
                extraHeader: const _Panel(
                  margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CommunityMarketSentiment(),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final showRight = width >= 1240;
    return ColoredBox(
      color: style.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 248,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              children: [
                _SourceNav(
                  source: _source,
                  stock: _stock,
                  onSelect: _selectSource,
                  onIndices: () => _selectIndex(null),
                ),
                const SizedBox(height: 12),
                _WatchlistPanel(
                  watchlist: widget.watchlist,
                  selected: _source == StreamSource.watchlist ? (_stock ?? '*') : null,
                  onSelect: _selectStock,
                ),
              ],
            ),
          ),
          Expanded(child: _feed(context)),
          if (showRight)
            SizedBox(
              width: 320,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                children: [
                  const _Panel(child: CommunityMarketSentiment()),
                  const SizedBox(height: 12),
                  const _Panel(child: CommunitySuggestedUsers()),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Konten adalah opini pengguna, bukan rekomendasi investasi.',
                      style: style.typography.meta.copyWith(color: style.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.margin = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Padding(
      padding: margin,
      child: Material(
        color: style.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: style.border),
        ),
        child: child,
      ),
    );
  }
}

class _SourceNav extends StatelessWidget {
  const _SourceNav({required this.source, required this.stock, required this.onSelect, required this.onIndices});

  final StreamSource source;
  final String? stock;
  final ValueChanged<StreamSource> onSelect;
  final VoidCallback onIndices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final entries = [
      (StreamSource.forYou, Icons.auto_awesome_outlined, l10n.feedForYou),
      (StreamSource.latest, Icons.public, l10n.feedLatest),
      (StreamSource.following, Icons.people_outline, l10n.feedFollowing),
      (StreamSource.official, Icons.verified_outlined, l10n.feedOfficial),
    ];
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (value, icon, label) in entries)
              _NavTile(icon: icon, label: label, selected: source == value, onTap: () => onSelect(value)),
            _NavTile(
              icon: Icons.insights,
              label: l10n.indexLabel,
              selected: source == StreamSource.indices,
              onTap: onIndices,
            ),
            const Divider(height: 16),
            _NavTile(
              icon: Icons.bookmark_border,
              label: l10n.bookmarksTitle,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(l10n.bookmarksTitle)),
                    body: const CommunityBookmarks(),
                  ),
                ),
              ),
            ),
            _NavTile(
              icon: Icons.drafts_outlined,
              label: l10n.draftsTitle,
              onTap: () => openCommunityPostDrafts(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.onTap, this.selected = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final color = selected ? style.accent : style.textPrimary;
    return Material(
      color: selected ? style.accentMuted : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: style.typography.label.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WatchlistPanel extends StatelessWidget {
  const _WatchlistPanel({required this.watchlist, required this.selected, required this.onSelect});

  final List<String> watchlist;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final theme = CommunityTheme.of(context);
    return _Panel(
      child: CommunityStockStatsBuilder(
        codes: watchlist,
        builder: (context, stats) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => onSelect(null),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('Diskusi watchlist', style: style.typography.sectionTitle)),
                    if (selected == '*') Icon(Icons.check_circle, size: 18, color: style.accent),
                  ],
                ),
              ),
            ),
            for (final code in watchlist)
              Builder(
                builder: (context) {
                  final s = stats[code];
                  final bullish = s?.bullishPct;
                  return InkWell(
                    onTap: () => onSelect(code),
                    child: Container(
                      color: selected == code ? style.accentMuted : null,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('\$$code', style: style.typography.label.copyWith(fontWeight: FontWeight.w700)),
                                Text(
                                  stockNames[code] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: style.typography.badge.copyWith(color: style.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.postsToday(s?.postsToday ?? 0),
                                style: style.typography.badge.copyWith(color: style.textSecondary),
                              ),
                              if (bullish != null)
                                Text(
                                  l10n.bullishShare(bullish),
                                  style: style.typography.badge.copyWith(
                                    color: bullish >= 50 ? theme.onBullish : theme.onBearish,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _SourceChips extends StatelessWidget {
  const _SourceChips({
    required this.source,
    required this.stock,
    required this.watchlist,
    required this.onSource,
    required this.onStock,
    required this.onIndices,
  });

  final StreamSource source;
  final String? stock;
  final List<String> watchlist;
  final ValueChanged<StreamSource> onSource;
  final ValueChanged<String?> onStock;
  final VoidCallback onIndices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final entries = [
      (StreamSource.forYou, l10n.feedForYou),
      (StreamSource.latest, l10n.feedLatest),
      (StreamSource.following, l10n.feedFollowing),
      (StreamSource.official, l10n.feedOfficial),
    ];
    return Material(
      color: style.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            for (final (value, label) in entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(label: Text(label), selected: source == value, onSelected: (_) => onSource(value)),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(l10n.indexLabel),
                selected: source == StreamSource.indices,
                onSelected: (_) => onIndices(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('Watchlist'),
                selected: source == StreamSource.watchlist && stock == null,
                onSelected: (_) => onStock(null),
              ),
            ),
            for (final code in watchlist)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('\$$code'),
                  selected: source == StreamSource.watchlist && stock == code,
                  onSelected: (_) => onStock(code),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatefulWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<FeedFilter> onSelect;

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  List<FeedFilter> _filters = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filters.isEmpty) _load();
  }

  Future<void> _load() async {
    try {
      final filters = await CommunityFeedFilters.load(context);
      if (mounted) setState(() => _filters = filters);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final filter in _filters)
            Material(
              color: filter.key == widget.selected ? style.textPrimary : style.surface,
              shape: StadiumBorder(
                side: BorderSide(color: filter.key == widget.selected ? style.textPrimary : style.border),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => widget.onSelect(filter),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CommunityFeedFilters.icon(filter.icon),
                        size: 16,
                        color: filter.key == widget.selected ? style.surface : style.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter.label(locale),
                        style: style.typography.label.copyWith(
                          color: filter.key == widget.selected ? style.surface : style.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
