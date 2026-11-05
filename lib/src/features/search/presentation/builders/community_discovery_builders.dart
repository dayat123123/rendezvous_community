import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/search/presentation/builders/community_discovery_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunityDiscoveryBuilders {
  const CommunityDiscoveryBuilders({
    this.searchField,
    this.searchTabs,
    this.loading,
    this.empty,
    this.error,
    this.userResult,
    this.stockResult,
    this.hashtag,
    this.hashtagHeader,
    this.trendingTabs,
    this.trendingStock,
    this.sentimentBar,
    this.stockSentiment,
  });

  final CommunityPartBuilder<CommunitySearchFieldDetails>? searchField;
  final CommunityPartBuilder<CommunitySearchTabsDetails>? searchTabs;
  final CommunityPartBuilder<CommunityListLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityListEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityListErrorDetails>? error;
  final CommunityPartBuilder<CommunityUserResultDetails>? userResult;
  final CommunityPartBuilder<CommunityStockResultDetails>? stockResult;
  final CommunityPartBuilder<CommunityHashtagDetails>? hashtag;
  final CommunityPartBuilder<CommunityHashtagHeaderDetails>? hashtagHeader;
  final CommunityPartBuilder<CommunityTrendingTabsDetails>? trendingTabs;
  final CommunityPartBuilder<CommunityTrendingStockDetails>? trendingStock;
  final CommunityPartBuilder<CommunitySentimentBarDetails>? sentimentBar;
  final CommunityPartBuilder<CommunityStockSentimentDetails>? stockSentiment;

  static CommunityDiscoveryBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunityDiscoveryBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunityDiscoveryBuildersScope>();
    return scope?.builders ?? const CommunityDiscoveryBuilders();
  }

  CommunityDiscoveryBuilders merge(CommunityDiscoveryBuilders? other) {
    if (other == null) return this;
    return CommunityDiscoveryBuilders(
      searchField: other.searchField ?? searchField,
      searchTabs: other.searchTabs ?? searchTabs,
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      userResult: other.userResult ?? userResult,
      stockResult: other.stockResult ?? stockResult,
      hashtag: other.hashtag ?? hashtag,
      hashtagHeader: other.hashtagHeader ?? hashtagHeader,
      trendingTabs: other.trendingTabs ?? trendingTabs,
      trendingStock: other.trendingStock ?? trendingStock,
      sentimentBar: other.sentimentBar ?? sentimentBar,
      stockSentiment: other.stockSentiment ?? stockSentiment,
    );
  }
}

class CommunityDiscoveryBuildersScope extends InheritedWidget {
  const CommunityDiscoveryBuildersScope({super.key, required this.builders, required super.child});

  final CommunityDiscoveryBuilders builders;

  @override
  bool updateShouldNotify(CommunityDiscoveryBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget withDiscoveryBuilders(BuildContext context, CommunityDiscoveryBuilders? builders, Widget child) =>
    builders == null
    ? child
    : CommunityDiscoveryBuildersScope(builders: CommunityDiscoveryBuilders.of(context).merge(builders), child: child);

Widget buildDiscoveryPart<T>(
  CommunityPartBuilder<T>? Function(CommunityDiscoveryBuilders builders) select,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(select(CommunityDiscoveryBuilders.of(context)), context, details, fallback);
