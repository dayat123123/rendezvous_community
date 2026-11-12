import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/legal_fakes.dart';

class _TrackingController extends ScrollController {
  var listeners = 0;
  var disposed = false;

  @override
  void addListener(VoidCallback listener) {
    listeners++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners--;
    super.removeListener(listener);
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class _PagedFeed extends FakeFeedRepository {
  final cursors = <String?>[];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async {
    cursors.add(cursor);
    final page = cursor == null ? 0 : int.parse(cursor);
    return Paged([
      for (var i = 0; i < 20; i++) samplePost(id: 'p-$page-$i', author: alice),
    ], nextCursor: page < 3 ? '${page + 1}' : null);
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

Finder _feedList(ScrollController? controller) =>
    find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.vertical && w.controller == controller);

ScrollController _attached(WidgetTester tester) => tester
    .widgetList<ListView>(find.byType(ListView))
    .firstWhere((w) => w.scrollDirection == Axis.vertical && w.controller != null)
    .controller!;

Future<void> _scrollToEnd(WidgetTester tester, ScrollController controller) async {
  controller.jumpTo(controller.position.maxScrollExtent);
  await tester.pumpAndSettle();
}

Widget _feed(ScrollController? controller) =>
    CommunityFeedList(scope: const FeedScope.global(), emptyMessage: 'kosong', scrollController: controller);

void main() {
  testWidgets('an external controller drives the feed list and survives the widget', (tester) async {
    final controller = _TrackingController();
    addTearDown(controller.dispose);
    final feed = _PagedFeed();
    await pumpCommunity(tester, _feed(controller), dependencies: FakeDependencies(feed: feed));

    expect(_feedList(controller), findsOneWidget);
    expect(controller.hasClients, isTrue);
    expect(controller.listeners, 1);

    await _scrollToEnd(tester, controller);
    expect(feed.cursors, [null, '1']);

    await tester.pumpWidget(const SizedBox());
    expect(controller.disposed, isFalse);
    expect(controller.listeners, 0);
    expect(controller.hasClients, isFalse);
  });

  testWidgets('without a controller the feed owns one and still loads more', (tester) async {
    final feed = _PagedFeed();
    await pumpCommunity(tester, _feed(null), dependencies: FakeDependencies(feed: feed));

    await _scrollToEnd(tester, _attached(tester));
    expect(feed.cursors, [null, '1']);

    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('swapping controllers moves the load-more listener', (tester) async {
    final first = _TrackingController();
    final second = _TrackingController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final feed = _PagedFeed();
    final deps = FakeDependencies(feed: feed);
    await pumpCommunity(tester, _feed(first), dependencies: deps);

    await pumpCommunity(tester, _feed(second), dependencies: deps);
    expect(first.listeners, 0);
    expect(first.hasClients, isFalse);
    expect(second.listeners, 1);
    expect(_feedList(second), findsOneWidget);
    await _scrollToEnd(tester, second);
    expect(feed.cursors, [null, '1']);

    await pumpCommunity(tester, _feed(null), dependencies: deps);
    expect(second.listeners, 0);
    expect(second.disposed, isFalse);
    final internal = _attached(tester);
    expect(internal, isNot(same(second)));
    await _scrollToEnd(tester, internal);
    expect(feed.cursors, [null, '1', '2']);

    await pumpCommunity(tester, _feed(first), dependencies: deps);
    expect(first.listeners, 1);
    expect(_feedList(first), findsOneWidget);
    await _scrollToEnd(tester, first);
    expect(feed.cursors, [null, '1', '2', '3']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CommunityStreamFeed forwards the controller across tabs', (tester) async {
    final controller = _TrackingController();
    addTearDown(controller.dispose);
    await pumpCommunity(
      tester,
      CommunityStreamFeed(scrollController: controller),
      dependencies: FakeDependencies(feed: _PagedFeed()),
    );
    expect(_feedList(controller), findsOneWidget);

    await tester.tap(find.text('Mengikuti'));
    await tester.pumpAndSettle();
    expect(_feedList(controller), findsOneWidget);
    expect(controller.listeners, 1);
  });

  testWidgets('CommunityBookmarks attaches the external controller', (tester) async {
    final controller = _TrackingController();
    addTearDown(controller.dispose);
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    features.bookmarks.saved = [for (var i = 0; i < 20; i++) samplePost(id: 'b-$i', author: alice, bookmarked: true)];
    await pumpFeatureApp(tester, CommunityBookmarks(scrollController: controller), features: features);
    await tester.pumpAndSettle();

    expect(_feedList(controller), findsOneWidget);
    expect(controller.hasClients, isTrue);
  });
}
