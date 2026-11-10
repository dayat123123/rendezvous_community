import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';

abstract interface class FeedCacheRepository {
  Future<List<Post>?> cachedFeed(FeedScope scope);
}

String? feedCacheKey(FeedScope scope) => switch (scope) {
  GlobalFeedScope() => 'global',
  FollowingFeedScope() => 'following',
  StockFeedScope(:final code) => 'stock:${code.toUpperCase()}',
  UserFeedScope() => null,
  StocksFeedScope(:final codes) => 'stocks:${([for (final c in codes) c.toUpperCase()]..sort()).join(',')}',
  OfficialFeedScope() => 'official',
  ForYouFeedScope() => 'for_you',
};
