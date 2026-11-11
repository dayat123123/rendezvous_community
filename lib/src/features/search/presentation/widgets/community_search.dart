import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/editorial_section.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_actions.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/search/domain/entities/search_results.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_builders.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/features/search/presentation/cubit/search_cubit.dart';
import 'package:rendezvous_community/src/features/search/presentation/cubit/trending_hashtags_cubit.dart';
import 'package:rendezvous_community/src/features/search/presentation/widgets/discovery_tile.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_tag.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<void> openCommunitySearch(BuildContext context, {String? initialQuery}) {
  final deps = CommunityScope.of(context);
  final features = CommunityFeatureScope.of(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => CommunityFeatureScope(
        dependencies: features,
        child: CommunityScope(
          dependencies: deps,
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(top: false, child: CommunitySearch(initialQuery: initialQuery, autofocus: true)),
          ),
        ),
      ),
    ),
  );
}

class CommunitySearch extends StatelessWidget {
  const CommunitySearch({super.key, this.initialQuery, this.autofocus = false, this.builders});

  final String? initialQuery;
  final bool autofocus;
  final CommunityDiscoveryBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = CommunityFeatureScope.of(context);
    return withDiscoveryBuilders(
      context,
      builders,
      CommunitySocialGate(
        feature: CommunityFlags.search,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) {
                final cubit = SearchCubit(
                  search: features.search,
                  feed: deps.feed,
                  analytics: features.analytics,
                  minLength: features.configService.current.searchMinLength,
                );
                final query = initialQuery;
                if (query != null && query.isNotEmpty) {
                  cubit
                    ..setQuery(query)
                    ..submit();
                }
                return cubit;
              },
            ),
            BlocProvider(create: (_) => TrendingHashtagsCubit(features.search)..load()),
          ],
          child: _SearchView(initialQuery: initialQuery, autofocus: autofocus),
        ),
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView({this.initialQuery, required this.autofocus});

  final String? initialQuery;
  final bool autofocus;

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> with SingleTickerProviderStateMixin {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late final _tabs = TabController(length: SearchType.values.length, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) context.read<SearchCubit>().setType(SearchType.values[_tabs.index]);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabs.dispose();
    super.dispose();
  }

  void _search(String query) {
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    context.read<SearchCubit>()
      ..setQuery(query)
      ..submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<SearchCubit>();
    final field = CommunitySearchFieldDetails(
      controller: _controller,
      hintText: l10n.searchHint,
      clearLabel: l10n.cancel,
      autofocus: widget.autofocus,
      onChanged: cubit.setQuery,
      onSubmitted: cubit.submit,
      onClear: () => _search(''),
    );
    final labels = [
      l10n.searchTabAll,
      l10n.searchTabPosts,
      l10n.searchTabUsers,
      l10n.searchTabStocks,
      l10n.searchTabHashtags,
    ];
    return ColoredBox(
      color: style.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
          child: Column(
            children: [
              buildDiscoveryPart((b) => b.searchField, context, field, _DefaultSearchField(details: field)),
              ListenableBuilder(
                listenable: _tabs,
                builder: (context, _) {
                  final tabs = CommunitySearchTabsDetails(
                    types: SearchType.values,
                    labels: labels,
                    selected: SearchType.values[_tabs.index],
                    onSelect: (type) => _tabs.animateTo(SearchType.values.indexOf(type)),
                  );
                  return buildDiscoveryPart(
                    (b) => b.searchTabs,
                    context,
                    tabs,
                    _DefaultSearchTabs(controller: _tabs, labels: labels),
                  );
                },
              ),
              Expanded(
                child: ColoredBox(
                  color: style.background,
                  child: BlocConsumer<SearchCubit, SearchState>(
                    listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
                    listener: (context, state) => showCommunityError(context, state.actionError!),
                    builder: (context, state) => _SearchBody(
                      state: state,
                      onSeeAll: (type) => _tabs.animateTo(SearchType.values.indexOf(type)),
                      onHashtag: (tag) => _search('#$tag'),
                    ),
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

class _DefaultSearchField extends StatelessWidget {
  const _DefaultSearchField({required this.details});

  final CommunitySearchFieldDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final border = OutlineInputBorder(borderRadius: style.radii.pillRadius, borderSide: style.borderSide);
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, 0),
      child: TextField(
        controller: details.controller,
        autofocus: details.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: details.onChanged,
        onSubmitted: (_) => details.onSubmitted(),
        style: style.typography.body,
        decoration: InputDecoration(
          hintText: details.hintText,
          hintStyle: style.typography.body.copyWith(color: style.textSecondary),
          prefixIcon: Icon(Icons.search, color: style.textSecondary),
          filled: true,
          fillColor: style.pill,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: style.accent, width: style.borderWidth),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: details.controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: details.clearLabel,
                    color: style.textSecondary,
                    onPressed: details.onClear,
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DefaultSearchTabs extends StatelessWidget {
  const _DefaultSearchTabs({required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Container(
      width: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: style.divider, width: style.borderWidth),
        ),
      ),
      child: CommunityScrollArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xxs),
          child: Row(
            children: [
              for (final (index, label) in labels.indexed)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.xxs),
                  child: CommunityTag(
                    label: label,
                    selected: controller.index == index,
                    onTap: () => controller.index = index,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.state, required this.onSeeAll, required this.onHashtag});

  final SearchState state;
  final ValueChanged<SearchType> onSeeAll;
  final ValueChanged<String> onHashtag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<SearchCubit>();
    if (state.query.trim().isEmpty) return _TrendingHashtagsView(onHashtag: onHashtag);
    if (state.tooShort) {
      final message = l10n.searchMinLength(cubit.minLength);
      return buildDiscoveryPart(
        (b) => b.empty,
        context,
        CommunityListEmptyDetails(message: message),
        CommunityEmptyView(message: message, icon: Icons.search),
      );
    }
    switch (state.status) {
      case LoadStatus.initial || LoadStatus.loading:
        return buildDiscoveryPart(
          (b) => b.loading,
          context,
          const CommunityListLoadingDetails(),
          const CommunitySkeleton(itemCount: 4),
        );
      case LoadStatus.failure:
        return buildDiscoveryPart(
          (b) => b.error,
          context,
          CommunityListErrorDetails(
            error: state.error!,
            message: l10n.errorMessage(state.error!),
            onRetry: cubit.retry,
          ),
          CommunityErrorView(error: state.error!, onRetry: cubit.retry),
        );
      case LoadStatus.ready:
        break;
    }
    final results = state.results;
    if (results == null || results.isEmpty) {
      final message = l10n.searchNoResults(state.query.trim());
      return buildDiscoveryPart(
        (b) => b.empty,
        context,
        CommunityListEmptyDetails(message: message),
        CommunityEmptyView(message: message, icon: Icons.search_off),
      );
    }
    final children = <Widget>[
      if (state.type == SearchType.all) ...[
        if (results.posts.isNotEmpty)
          _Section(
            title: l10n.searchTabPosts,
            icon: Icons.article_outlined,
            onSeeAll: () => onSeeAll(SearchType.posts),
          ),
        for (final post in results.posts) _postTile(context, cubit, post),
        if (results.users.isNotEmpty)
          _Section(title: l10n.searchTabUsers, icon: Icons.people_outline, onSeeAll: () => onSeeAll(SearchType.users)),
        for (final user in results.users) _surface(_UserTile(result: user)),
        if (results.stocks.isNotEmpty)
          _Section(
            title: l10n.searchTabStocks,
            icon: Icons.candlestick_chart_outlined,
            onSeeAll: () => onSeeAll(SearchType.stocks),
          ),
        for (final stock in results.stocks) _surface(_StockTile(result: stock)),
        if (results.hashtags.isNotEmpty)
          _Section(title: l10n.searchTabHashtags, icon: Icons.tag, onSeeAll: () => onSeeAll(SearchType.hashtags)),
        for (final hashtag in results.hashtags) _surface(_HashtagTile(hashtag: hashtag)),
      ] else ...[
        SizedBox(height: CommunityStyle.of(context).spacing.sm),
        for (final post in results.posts) _postTile(context, cubit, post),
        for (final user in results.users) _surface(_UserTile(result: user)),
        for (final stock in results.stocks) _surface(_StockTile(result: stock)),
        for (final hashtag in results.hashtags) _surface(_HashtagTile(hashtag: hashtag)),
      ],
      if (state.loadingMore)
        buildDiscoveryPart(
          (b) => b.loading,
          context,
          const CommunityListLoadingDetails(more: true),
          const CommunityLoadingView(),
        ),
      SizedBox(height: CommunityStyle.of(context).spacing.xl),
    ];
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 400 && state.hasMore) cubit.loadMore();
        return false;
      },
      child: CommunityScrollArea(child: ListView(children: children)),
    );
  }

  Widget _surface(Widget child) => Builder(
    builder: (context) => Material(color: CommunityStyle.of(context).surface, child: child),
  );

  Widget _postTile(BuildContext context, SearchCubit cubit, Post post) {
    final spacing = CommunityStyle.of(context).spacing;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: PostCard(
        post: post,
        source: 'search',
        onLike: () => cubit.toggleLike(post),
        onOpen: () => CommunityNavigator.openPost(context, post.id),
        onShare: sharePostAction(context, post),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.onSeeAll});

  final String title;
  final IconData icon;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: CommunityStyle.of(context).sectionGap),
    child: EditorialSectionHeader(
      title: title,
      icon: icon,
      actionLabel: context.communityL10n.searchSeeAll,
      onAction: onSeeAll,
    ),
  );
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.result});

  final UserSearchResult result;

  @override
  Widget build(BuildContext context) {
    final details = CommunityUserResultDetails(
      result: result,
      subtitle: '${result.user.handle} · ${context.communityL10n.followers(result.followerCount)}',
      onOpen: () => CommunityNavigator.openUser(context, result.user),
    );
    final style = CommunityStyle.of(context);
    return buildDiscoveryPart(
      (b) => b.userResult,
      context,
      details,
      InkWell(
        onTap: details.onOpen,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: style.spacing.lg, vertical: style.spacing.sm + style.spacing.xxs),
          child: Row(
            children: [
              CommunityAvatar(
                user: result.user,
                radius: style.avatarSizes.post / 2,
                ringColor: result.isOfficial ? style.accent : null,
              ),
              SizedBox(width: style.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommunityUserName(user: result.user, official: result.isOfficial, showUsername: false),
                    SizedBox(height: style.spacing.xxs),
                    Text(details.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.result});

  final StockSearchResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final details = CommunityStockResultDetails(
      result: result,
      subtitle: '${l10n.postsLast7Days(result.posts7d)} · ${l10n.watchers(result.watcherCount)}',
      onOpen: () => CommunityNavigator.openStock(context, result.code, source: 'search'),
    );
    return buildDiscoveryPart(
      (b) => b.stockResult,
      context,
      details,
      DiscoveryTile(
        leading: const DiscoveryIcon(icon: Icons.candlestick_chart_outlined),
        title: '\$${result.code}',
        subtitle: details.subtitle,
        trailing: result.isWatching ? Icon(Icons.visibility, size: 20, color: style.accent) : null,
        onTap: details.onOpen,
      ),
    );
  }
}

class _HashtagTile extends StatelessWidget {
  const _HashtagTile({required this.hashtag});

  final HashtagSummary hashtag;

  @override
  Widget build(BuildContext context) {
    final details = CommunityHashtagDetails(
      hashtag: hashtag,
      placement: CommunityHashtagPlacement.searchResult,
      countLabel: context.communityL10n.postsLast7Days(hashtag.postCount),
      onOpen: () => CommunityNavigator.openHashtag(context, hashtag.tag),
    );
    return buildDiscoveryPart(
      (b) => b.hashtag,
      context,
      details,
      DiscoveryTile(
        leading: const DiscoveryIcon(icon: Icons.tag),
        title: '#${hashtag.tag}',
        subtitle: details.countLabel,
        onTap: details.onOpen,
      ),
    );
  }
}

class _TrendingHashtagsView extends StatelessWidget {
  const _TrendingHashtagsView({required this.onHashtag});

  final ValueChanged<String> onHashtag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    return BlocBuilder<TrendingHashtagsCubit, TrendingHashtagsState>(
      builder: (context, state) {
        if (state.status != LoadStatus.ready || state.hashtags.isEmpty) return const SizedBox.shrink();
        return CommunityScrollArea(
          child: ListView(
            padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.lg),
            children: [
              EditorialSectionHeader(title: l10n.trendingHashtags, icon: Icons.trending_up),
              EditorialSection(
                gap: false,
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.md),
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    for (final (index, hashtag) in state.hashtags.indexed)
                      Builder(
                        builder: (context) {
                          final details = CommunityHashtagDetails(
                            hashtag: hashtag,
                            placement: CommunityHashtagPlacement.suggestion,
                            rank: index + 1,
                            onOpen: () => onHashtag(hashtag.tag),
                          );
                          return buildDiscoveryPart(
                            (b) => b.hashtag,
                            context,
                            details,
                            CommunityTag(label: hashtag.tag, icon: Icons.tag, onTap: details.onOpen),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
