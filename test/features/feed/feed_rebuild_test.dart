import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';

import '../../support/fakes.dart';
import '../../support/legal_fakes.dart';

Post _post(String id, String body, int hoursAgo) => Post(
  id: id,
  author: alice,
  body: body,
  likeCount: 3,
  createdAt: now.subtract(Duration(hours: hoursAgo)),
  cursor: 'c-$id',
);

class _Feed extends FakeFeedRepository {
  List<Post> items = [_post('p-1', 'Post satu', 1), _post('p-2', 'Post dua', 2)];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(items);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

final _likes = <String, int>{};

Future<Map<String, int>> _pump(WidgetTester tester, _Feed feed) async {
  tester.view.physicalSize = const Size(600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final builds = <String, int>{};
  await pumpCommunity(
    tester,
    CommunityFeedList(
      scope: const FeedScope.user('u-a'),
      emptyMessage: 'Kosong',
      postOpenMode: CommunityPostOpenMode.inlineComments,
      builders: CommunityFeedBuilders(
        postCard: (context, d, fallback) {
          builds.update(d.post.id, (n) => n + 1, ifAbsent: () => 1);
          _likes[d.post.id] = d.post.likeCount;
          return fallback;
        },
      ),
    ),
    dependencies: FakeDependencies(feed: feed),
  );
  builds.clear();
  return builds;
}

FeedCubit _cubit(WidgetTester tester) => tester.element(find.text('Post satu')).read<FeedCubit>();

void main() {
  testWidgets('liking one post rebuilds only that card', (tester) async {
    final feed = _Feed();
    final builds = await _pump(tester, feed);

    await _cubit(tester).toggleLike(feed.items.first);
    await tester.pumpAndSettle();

    expect(builds['p-1'], greaterThanOrEqualTo(1));
    expect(builds['p-2'], isNull);
  });

  testWidgets('the liked card still shows its new count', (tester) async {
    final feed = _Feed();
    await _pump(tester, feed);

    await _cubit(tester).toggleLike(feed.items.first);
    await tester.pumpAndSettle();

    expect(_likes['p-1'], 4);
    expect(_likes['p-2'], 3);
  });

  testWidgets('opening one post\'s comments rebuilds only that card', (tester) async {
    final feed = _Feed();
    final builds = await _pump(tester, feed);

    _cubit(tester).toggleComments('p-1');
    await tester.pumpAndSettle();

    expect(find.byType(CommunityPostComments), findsOneWidget);
    expect(builds['p-1'], greaterThanOrEqualTo(1));
    expect(builds['p-2'], isNull);
  });

  testWidgets('a refreshed list with a new post still renders every card', (tester) async {
    final feed = _Feed();
    await _pump(tester, feed);

    feed.items = [_post('p-0', 'Post baru', 0), ...feed.items];
    await _cubit(tester).refresh();
    await tester.pumpAndSettle();

    expect(find.text('Post baru'), findsOneWidget);
    expect(find.text('Post satu'), findsOneWidget);
    expect(find.text('Post dua'), findsOneWidget);
  });
}
