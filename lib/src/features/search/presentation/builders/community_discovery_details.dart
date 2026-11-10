import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/search/domain/entities/search_results.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/presentation/widgets/community_trending.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum CommunityHashtagPlacement { searchResult, trending, suggestion }

enum CommunityTrendingStockKind { trending, rising }

class CommunitySearchFieldDetails {
  const CommunitySearchFieldDetails({
    required this.controller,
    required this.hintText,
    required this.clearLabel,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final String clearLabel;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
}

class CommunitySearchTabsDetails {
  const CommunitySearchTabsDetails({
    required this.types,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<SearchType> types;
  final List<String> labels;
  final SearchType selected;
  final ValueChanged<SearchType> onSelect;
}

class CommunityUserResultDetails {
  const CommunityUserResultDetails({required this.result, required this.subtitle, required this.onOpen});

  final UserSearchResult result;
  final String subtitle;
  final VoidCallback onOpen;

  UserSummary get user => result.user;
}

class CommunityStockResultDetails {
  const CommunityStockResultDetails({required this.result, required this.subtitle, required this.onOpen});

  final StockSearchResult result;
  final String subtitle;
  final VoidCallback onOpen;

  String get code => result.code;

  bool get watching => result.isWatching;
}

class CommunityHashtagDetails {
  const CommunityHashtagDetails({
    required this.hashtag,
    required this.placement,
    required this.onOpen,
    this.countLabel,
    this.rank,
  });

  final HashtagSummary hashtag;
  final CommunityHashtagPlacement placement;
  final VoidCallback onOpen;
  final String? countLabel;
  final int? rank;

  String get tag => hashtag.tag;
}

class CommunityHashtagHeaderDetails {
  const CommunityHashtagHeaderDetails({required this.tag, this.header});

  final String tag;
  final Widget? header;
}

class CommunityTrendingTabsDetails {
  const CommunityTrendingTabsDetails({
    required this.tabs,
    required this.labels,
    required this.selected,
    required this.window,
    required this.windows,
    required this.windowLabels,
    required this.onWindowChanged,
    this.onSelect,
  });

  final List<CommunityTrendingTab> tabs;
  final List<String> labels;
  final CommunityTrendingTab selected;
  final TrendWindow window;
  final List<TrendWindow> windows;
  final List<String> windowLabels;
  final ValueChanged<TrendWindow> onWindowChanged;
  final ValueChanged<CommunityTrendingTab>? onSelect;
}

class CommunityTrendingStockDetails {
  const CommunityTrendingStockDetails({
    required this.kind,
    required this.rank,
    required this.code,
    required this.postsLabel,
    required this.onOpen,
    this.growthLabel,
    this.bullishPct,
    this.bearishPct,
  });

  final CommunityTrendingStockKind kind;
  final int rank;
  final String code;
  final String postsLabel;
  final VoidCallback onOpen;
  final String? growthLabel;
  final int? bullishPct;
  final int? bearishPct;

  bool get hasSentiment => bullishPct != null || bearishPct != null;
}

class CommunitySentimentBarDetails {
  const CommunitySentimentBarDetails({
    required this.bullishPct,
    required this.bearishPct,
    required this.neutralPct,
    required this.height,
  });

  final int bullishPct;
  final int bearishPct;
  final int neutralPct;
  final double height;
}

class CommunityStockSentimentDetails {
  const CommunityStockSentimentDetails({
    required this.code,
    required this.title,
    required this.window,
    required this.windows,
    required this.windowLabels,
    required this.loading,
    required this.noDataLabel,
    required this.bullishLabel,
    required this.bearishLabel,
    required this.onWindowChanged,
    required this.onRetry,
    required this.retryLabel,
    this.breakdown,
    this.error,
    this.errorMessage,
    this.basedOnLabel,
  });

  final String code;
  final String title;
  final TrendWindow window;
  final List<TrendWindow> windows;
  final List<String> windowLabels;
  final bool loading;
  final String noDataLabel;
  final String bullishLabel;
  final String bearishLabel;
  final ValueChanged<TrendWindow> onWindowChanged;
  final VoidCallback onRetry;
  final String retryLabel;
  final SentimentBreakdown? breakdown;
  final Object? error;
  final String? errorMessage;
  final String? basedOnLabel;

  bool get hasData => breakdown?.hasLabels ?? false;
}

class CommunitySuggestedUserDetails {
  const CommunitySuggestedUserDetails({
    required this.suggestion,
    required this.subtitle,
    required this.following,
    required this.pending,
    required this.followLabel,
    required this.followingLabel,
    required this.onOpen,
    required this.onToggleFollow,
  });

  final SuggestedUser suggestion;
  final String subtitle;
  final bool following;
  final bool pending;
  final String followLabel;
  final String followingLabel;
  final VoidCallback onOpen;
  final VoidCallback onToggleFollow;

  UserSummary get user => suggestion.user;
}

class CommunityMarketSentimentDetails {
  const CommunityMarketSentimentDetails({
    required this.title,
    required this.window,
    required this.windows,
    required this.windowLabels,
    required this.loading,
    required this.noDataLabel,
    required this.bullishLabel,
    required this.neutralLabel,
    required this.bearishLabel,
    required this.onWindowChanged,
    required this.onRetry,
    required this.retryLabel,
    this.breakdown,
    this.mood,
    this.headline,
    this.basedOnLabel,
    this.error,
    this.errorMessage,
  });

  final String title;
  final TrendWindow window;
  final List<TrendWindow> windows;
  final List<String> windowLabels;
  final bool loading;
  final String noDataLabel;
  final String bullishLabel;
  final String neutralLabel;
  final String bearishLabel;
  final ValueChanged<TrendWindow> onWindowChanged;
  final VoidCallback onRetry;
  final String retryLabel;
  final SentimentBreakdown? breakdown;
  final Sentiment? mood;
  final String? headline;
  final String? basedOnLabel;
  final Object? error;
  final String? errorMessage;

  bool get hasData => breakdown?.hasLabels ?? false;
}
