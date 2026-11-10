import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rendezvous_community/src/features/trending/data/repositories/trending_repository_impl.dart';

import '../../../support/mock_api.dart';

Map<String, Object?> _captured(MockApi api) =>
    verify(() => api.rpcRows('get_feed', captureAny())).captured.last as Map<String, Object?>;

void main() {
  late MockApi api;

  setUp(() => api = mockApi());

  group('feed scopes, sort and media filter', () {
    test('a watchlist feed sends every code with the sort and media flag', () async {
      when(() => api.rpcRows('get_feed', any())).thenAnswer((_) async => [feedRow('p-1', cursor: 'o:1')]);

      final page = await FeedRepositoryImpl(
        api,
      ).queryFeed(const FeedScope.stocks(['bbca', 'TLKM']), sort: CommunityFeedSort.top, mediaOnly: true, limit: 1);

      expect(_captured(api), {
        'p_scope': 'stocks',
        'p_stock_code': null,
        'p_cursor': null,
        'p_limit': 1,
        'p_author_id': null,
        'p_sort': 'top',
        'p_media_only': true,
        'p_stock_codes': ['BBCA', 'TLKM'],
      });
      expect(page.nextCursor, 'o:1');
    });

    test('official and for-you scopes map to their server names', () async {
      when(() => api.rpcRows('get_feed', any())).thenAnswer((_) async => []);
      final repository = FeedRepositoryImpl(api);

      await repository.getFeed(const FeedScope.official());
      expect(_captured(api)['p_scope'], 'official');
      await repository.getFeed(const FeedScope.forYou());
      final params = _captured(api);
      expect(params['p_scope'], 'for_you');
      expect(params.containsKey('p_sort'), isFalse);
    });

    test('an older server falls back to the global feed and filters media locally', () async {
      var calls = 0;
      when(() => api.rpcRows('get_feed', any())).thenAnswer((_) async {
        if (calls++ == 0) throw const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202');
        return [
          feedRow('p-media'),
          {...feedRow('p-text'), 'attachments': <Object?>[]},
        ];
      });

      final page = await FeedRepositoryImpl(api).queryFeed(const FeedScope.forYou(), mediaOnly: true);

      expect(_captured(api), {
        'p_scope': 'global',
        'p_stock_code': null,
        'p_cursor': null,
        'p_limit': 20,
        'p_author_id': null,
      });
      expect(page.items.map((p) => p.id), ['p-media']);
    });

    test('a watchlist feed on an older server reports the error', () async {
      when(
        () => api.rpcRows('get_feed', any()),
      ).thenThrow(const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202'));

      expect(
        FeedRepositoryImpl(api).queryFeed(const FeedScope.stocks(['BBCA'])),
        throwsA(isA<CommunityException>().having((e) => e.code, 'code', 'PGRST202')),
      );
    });

    test('the top comment of a post is parsed from the feed row', () async {
      when(() => api.rpcRows('get_feed', any())).thenAnswer(
        (_) async => [
          {...feedRow('p-1'), 'top_comment': commentRow('c-9')},
          feedRow('p-2'),
        ],
      );

      final page = await FeedRepositoryImpl(api).getFeed(const FeedScope.global());

      expect(page.items.first.topComment?.id, 'c-9');
      expect(page.items.first.topComment?.author?.username, 'sari_invest');
      expect(page.items.last.topComment, isNull);
    });
  });

  group('trending insights', () {
    test('market sentiment maps the breakdown and the post count', () async {
      when(() => api.rpcValue('get_market_sentiment', any())).thenAnswer(
        (_) async => {
          'window': '7d',
          'posts': 120,
          'bullish': 60,
          'bearish': 30,
          'neutral': 10,
          'unlabeled': 20,
          'bullish_pct': 62,
          'bearish_pct': 30,
          'neutral_pct': 8,
        },
      );

      final mood = await TrendingRepositoryImpl(api).marketSentiment(window: TrendWindow.week);

      verify(() => api.rpcValue('get_market_sentiment', {'p_window': '7d'})).called(1);
      expect(mood.posts, 120);
      expect(mood.bullishPct, 62);
      expect(mood.hasLabels, isTrue);
    });

    test('stock stats are keyed by upper-case code', () async {
      when(() => api.rpcRows('get_stock_stats', any())).thenAnswer(
        (_) async => [
          {'code': 'BBCA', 'posts_today': 14, 'bullish_pct': 70},
          {'code': 'TLKM', 'posts_today': 0, 'bullish_pct': null},
        ],
      );

      final stats = await TrendingRepositoryImpl(api).stockStats(['bbca', ' TLKM ', 'bbca']);

      verify(
        () => api.rpcRows('get_stock_stats', {
          'p_codes': ['BBCA', 'TLKM'],
        }),
      ).called(1);
      expect(stats['BBCA'], const StockStats(code: 'BBCA', postsToday: 14, bullishPct: 70));
      expect(stats['TLKM']?.bullishPct, isNull);
    });

    test('stock stats skip the request when there are no codes', () async {
      expect(await TrendingRepositoryImpl(api).stockStats(const [' ']), isEmpty);
      verifyNever(() => api.rpcRows('get_stock_stats', any()));
    });
  });

  test('suggested users carry the mutual follows, followers and official mark', () async {
    when(() => api.rpcRows('get_suggested_users', any())).thenAnswer(
      (_) async => [
        {
          'id': 'u-9',
          'username': 'rina',
          'display_name': 'Rina',
          'avatar_url': null,
          'is_verified': false,
          'is_official': true,
          'follower_count': 1200,
          'mutual_count': 2,
        },
      ],
    );

    final users = await ProfileRepositoryImpl(api).suggestedUsers(limit: 3);

    verify(() => api.rpcRows('get_suggested_users', {'p_limit': 3})).called(1);
    expect(users.single.user.name, 'Rina');
    expect(users.single.mutualCount, 2);
    expect(users.single.followerCount, 1200);
    expect(users.single.isOfficial, isTrue);
  });
}
