import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';

import '../../support/fakes.dart';
import '../../support/legal_fakes.dart';
import '../../support/mock_api.dart';

final _poll = Poll(
  endsAt: now.add(const Duration(days: 1)),
  closed: false,
  totalVotes: 0,
  resultsVisible: false,
  options: const [],
);

Post _post(String id, {bool media = false, bool poll = false, String body = 'Halo'}) => Post(
  id: id,
  author: alice,
  body: body,
  createdAt: now,
  cursor: 'c-$id',
  attachments: media ? const [Attachment(path: 'posts/u/a.png')] : const [],
  poll: poll ? _poll : null,
);

const _serverFilters = [
  FeedFilter(key: 'latest', labelEn: 'Latest', labelId: 'Terbaru'),
  FeedFilter(key: 'top', labelEn: 'Top', labelId: 'Teratas', sort: CommunityFeedSort.top, position: 1),
  FeedFilter(
    key: 'media',
    labelEn: 'Chart & Media',
    labelId: 'Grafik & Media',
    content: 'media',
    icon: 'image',
    position: 2,
  ),
  FeedFilter(key: 'polls', labelEn: 'Polls', labelId: 'Polling', content: 'poll', icon: 'poll', position: 3),
  FeedFilter(key: 'videos', labelEn: 'Videos', labelId: 'Video', content: 'video', position: 4),
];

class _FilterFeed extends FakeFeedRepository implements FeedQueryRepository, FeedFilterRepository {
  final queries = <String?>[];
  final changes = StreamController<PostChange>.broadcast();
  final polls = <String>{};
  var filterCalls = 0;

  @override
  Future<List<FeedFilter>> getFeedFilters({bool refresh = false}) async {
    filterCalls++;
    return _serverFilters;
  }

  @override
  Future<Paged<Post>> queryFeed(
    FeedScope scope, {
    CommunityFeedSort sort = CommunityFeedSort.latest,
    bool mediaOnly = false,
    String? filter,
    String? cursor,
    int limit = 20,
  }) async {
    queries.add(filter);
    return Paged([_post('p-$filter')]);
  }

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async {
    queries.add(null);
    return Paged([_post('p-plain')]);
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];

  @override
  Future<Post?> getPost(String postId) async => _post(postId, poll: polls.contains(postId));

  @override
  Stream<PostChange> watchPosts({String? postId}) => changes.stream;

  Future<void> close() => changes.close();
}

PostInserted _inserted(String id, {bool media = false, String body = 'Halo'}) =>
    PostInserted(id, authorId: 'u-other', body: body, createdAt: now, hasMedia: media);

Future<FeedCubit> _cubit(_FilterFeed feed, String filter, {FeedScope scope = const FeedScope.global()}) async {
  addTearDown(feed.close);
  final cubit = FeedCubit(feed: feed, scope: scope, filter: filter, currentUserId: () => 'u-me');
  await cubit.load();
  return cubit;
}

Future<void> _emit(_FilterFeed feed, PostChange change) async {
  feed.changes.add(change);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('FeedRepositoryImpl filters', () {
    test('get_feed_filters rows map to FeedFilter and are cached', () async {
      final api = mockApi();
      when(() => api.rpcRows('get_feed_filters', any())).thenAnswer(
        (_) async => [
          {
            'key': 'polls',
            'label_en': 'Polls',
            'label_id': 'Polling',
            'sort': 'latest',
            'content': 'poll',
            'icon': 'poll',
            'position': 3,
          },
          {
            'key': 'top',
            'label_en': 'Top',
            'label_id': 'Teratas',
            'sort': 'top',
            'content': null,
            'icon': null,
            'position': 1,
          },
        ],
      );
      final repository = FeedRepositoryImpl(api);

      final filters = await repository.getFeedFilters();
      await repository.getFeedFilters();

      expect(filters.first, _serverFilters[3].copyWith(position: 3));
      expect(filters.last.sort, CommunityFeedSort.top);
      expect(filters.first.label(const Locale('id')), 'Polling');
      expect(filters.first.label(const Locale('en')), 'Polls');
      verify(() => api.rpcRows('get_feed_filters', any())).called(1);
    });

    test('an older server gets the built-in tabs without polls', () async {
      final api = mockApi();
      when(
        () => api.rpcRows('get_feed_filters', any()),
      ).thenThrow(const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202'));

      final filters = await FeedRepositoryImpl(api).getFeedFilters();

      expect(filters.map((f) => f.key), ['latest', 'top', 'media']);
    });

    test('a filter sends p_filter and leaves out p_sort and p_media_only', () async {
      final api = mockApi();
      when(() => api.rpcRows('get_feed', any())).thenAnswer((_) async => [feedRow('p-1')]);

      await FeedRepositoryImpl(
        api,
      ).queryFeed(const FeedScope.stock('LQ45'), filter: 'polls', sort: CommunityFeedSort.top, mediaOnly: true);

      final params = verify(() => api.rpcRows('get_feed', captureAny())).captured.single as Map<String, Object?>;
      expect(params['p_filter'], 'polls');
      expect(params['p_stock_code'], 'LQ45');
      expect(params.containsKey('p_sort'), isFalse);
      expect(params.containsKey('p_media_only'), isFalse);
    });

    test('without p_filter on the server a known filter falls back to sort and media', () async {
      final api = mockApi();
      final calls = <Map<String, Object?>>[];
      when(() => api.rpcRows('get_feed', any())).thenAnswer((invocation) async {
        final params = invocation.positionalArguments[1] as Map<String, Object?>;
        calls.add(params);
        if (params.containsKey('p_filter')) {
          throw const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202');
        }
        return [feedRow('p-1')];
      });
      final repository = FeedRepositoryImpl(api);

      await repository.queryFeed(const FeedScope.global(), filter: 'top');
      await repository.queryFeed(const FeedScope.global(), filter: 'media');
      await repository.queryFeed(const FeedScope.global(), filter: 'polls', cursor: 'o:20');

      expect(calls[1]['p_sort'], 'top');
      expect(calls[3]['p_media_only'], isTrue);
      expect(calls[5].containsKey('p_sort'), isFalse);
      expect(calls[5].containsKey('p_media_only'), isFalse);
      expect(calls[5]['p_cursor'], isNull);
    });

    test('analytics keeps a valid filter key', () {
      expect(sanitizeAnalyticsProps({'filter': 'polls'}), {'filter': 'polls'});
      expect(sanitizeAnalyticsProps({'filter': 'Bad Key'}), isEmpty);
      expect(sanitizeAnalyticsProps({'stock_code': r'$sri-kehati'}), {'stock_code': 'SRI-KEHATI'});
    });
  });

  group('FeedCubit filters', () {
    test('loads through the filter and resolves its definition', () async {
      final feed = _FilterFeed();
      final cubit = await _cubit(feed, 'polls');
      addTearDown(cubit.close);

      expect(feed.queries, ['polls']);
      expect(cubit.filterDef?.content, 'poll');
      expect(cubit.isFiltered, isTrue);
    });

    test('media filter counts only realtime posts with media', () async {
      final feed = _FilterFeed();
      final cubit = await _cubit(feed, 'media');
      addTearDown(cubit.close);

      await _emit(feed, _inserted('n-1'));
      expect(cubit.state.newPosts, 0);
      await _emit(feed, _inserted('n-2', media: true));
      expect(cubit.state.newPosts, 1);
    });

    test('polls filter checks the post for a poll', () async {
      final feed = _FilterFeed()..polls.add('n-2');
      final cubit = await _cubit(feed, 'polls');
      addTearDown(cubit.close);

      await _emit(feed, _inserted('n-1'));
      expect(cubit.state.newPosts, 0);
      await _emit(feed, _inserted('n-2'));
      expect(cubit.state.newPosts, 1);
    });

    test('top filters ignore realtime inserts and unknown content only shows the banner', () async {
      final feed = _FilterFeed();
      final top = await _cubit(feed, 'top');
      final videos = await _cubit(feed, 'videos');
      addTearDown(top.close);
      addTearDown(videos.close);

      await _emit(feed, _inserted('n-1'));

      expect(top.state.newPosts, 0);
      expect(videos.state.newPosts, 1);
      expect(videos.state.posts.map((p) => p.id), ['p-videos']);
    });

    test('a stock scope filter still checks the cashtag', () async {
      final feed = _FilterFeed();
      final cubit = await _cubit(feed, 'latest', scope: const FeedScope.stock('BBCA'));
      addTearDown(cubit.close);

      await _emit(feed, _inserted('n-1', body: r'$TLKM'));
      await _emit(feed, _inserted('n-2', body: r'$BBCA-nya'));

      expect(cubit.state.newPosts, 1);
    });

    test('own posts are inserted only when they match the filter', () async {
      final feed = _FilterFeed();
      final polls = await _cubit(feed, 'polls');
      final videos = await _cubit(feed, 'videos');
      addTearDown(polls.close);
      addTearDown(videos.close);

      polls.insertOwnPost(_post('mine-1'));
      polls.insertOwnPost(_post('mine-2', poll: true));
      videos.insertOwnPost(_post('mine-3', media: true));

      expect(polls.state.posts.map((p) => p.id), ['mine-2', 'p-polls']);
      expect(videos.state.posts.map((p) => p.id), ['p-videos']);
    });
  });

  group('widgets', () {
    testWidgets('CommunityFeedList recreates its feed when the filter changes', (tester) async {
      final feed = _FilterFeed();
      final deps = FakeDependencies(feed: feed);
      await pumpCommunity(
        tester,
        const CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'x', filter: 'top'),
        dependencies: deps,
      );
      await pumpCommunity(
        tester,
        const CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'x', filter: 'polls'),
        dependencies: deps,
      );

      expect(feed.queries, ['top', 'polls']);
      expect(find.text('Halo'), findsOneWidget);
    });

    testWidgets('CommunityStreamFeed shows the server tabs and switches the filter', (tester) async {
      final feed = _FilterFeed();
      final changed = <String>[];
      await pumpCommunity(
        tester,
        CommunityStreamFeed(
          showComposePrompt: false,
          showFilterTabs: true,
          filter: 'latest',
          onFilterChanged: (f) => changed.add(f.key),
        ),
        dependencies: FakeDependencies(feed: feed),
      );

      expect(find.text('Grafik & Media'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);

      await tester.ensureVisible(find.text('Polling'));
      await tester.tap(find.text('Polling'));
      await tester.pumpAndSettle();

      expect(feed.queries, ['latest', 'polls']);
      expect(changed, ['polls']);
    });

    testWidgets('the filter tabs builder receives the filters and selection', (tester) async {
      final feed = _FilterFeed();
      CommunityFeedFilterTabsDetails? seen;
      await pumpCommunity(
        tester,
        CommunityFeedFilterTabs(
          selected: 'top',
          onSelected: (_) {},
          builders: CommunityFeedBuilders(
            feedFilterTabs: (context, details, fallback) {
              seen = details;
              return Text('tabs ${details.labels.join(',')}');
            },
          ),
        ),
        dependencies: FakeDependencies(feed: feed),
      );

      expect(find.text('tabs Terbaru,Teratas,Grafik & Media,Polling,Video'), findsOneWidget);
      expect(seen?.selected, 'top');
      expect(seen?.loading, isFalse);
    });
  });
}
