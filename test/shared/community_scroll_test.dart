import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';

import '../support/fakes.dart';
import '../support/legal_fakes.dart';

class _LongFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged([
    for (var i = 0; i < 12; i++)
      Post(
        id: 'p-$i',
        author: alice,
        body: 'Post nomor $i',
        createdAt: now.subtract(Duration(minutes: i)),
        cursor: 'c-$i',
      ),
  ]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

const _feed = CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'Kosong');

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(600, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpCommunity(tester, child, dependencies: FakeDependencies(feed: _LongFeed()));
}

double _feedOffset(WidgetTester tester) => tester
    .state<ScrollableState>(find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first)
    .position
    .pixels;

void main() {
  group('pull to refresh', () {
    testWidgets('is on by default', (tester) async {
      await _pump(tester, _feed);

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('CommunityScrollScope turns it off for the feed', (tester) async {
      await _pump(
        tester,
        const CommunityScrollScope(settings: CommunityScrollSettings(pullToRefresh: false), child: _feed),
      );

      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.text('Post nomor 0'), findsOneWidget);
    });

    testWidgets('CommunityScrollScope turns it off for the chat list', (tester) async {
      await _pump(
        tester,
        const CommunityScrollScope(settings: CommunityScrollSettings(pullToRefresh: false), child: CommunityChatList()),
      );

      expect(find.byType(CommunityChatList), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });

  group('scroll behavior', () {
    testWidgets('a mouse drag does not scroll the feed by default', (tester) async {
      await _pump(tester, _feed);

      await tester.dragFrom(const Offset(300, 600), const Offset(0, -300), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(_feedOffset(tester), 0);
    });

    testWidgets('CommunityMouseDragScrollBehavior lets a mouse drag scroll the feed', (tester) async {
      await _pump(
        tester,
        const CommunityScrollScope(
          settings: CommunityScrollSettings(behavior: CommunityMouseDragScrollBehavior()),
          child: _feed,
        ),
      );

      await tester.dragFrom(const Offset(300, 600), const Offset(0, -300), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(_feedOffset(tester), greaterThan(0));
    });

    testWidgets('the mouse wheel scrolls the feed from the empty side margin', (tester) async {
      await _pump(tester, _feed, size: const Size(1600, 900));

      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(const Offset(40, 450)));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 400)));
      await tester.pumpAndSettle();

      expect(_feedOffset(tester), greaterThan(0));
    });

    testWidgets('the post detail page uses the scoped behavior', (tester) async {
      await _pump(
        tester,
        const CommunityScrollScope(
          settings: CommunityScrollSettings(behavior: CommunityMouseDragScrollBehavior()),
          child: CommunityPostDetail(postId: 'p-1'),
        ),
      );

      final configs = tester.widgetList<ScrollConfiguration>(find.byType(ScrollConfiguration));
      expect(configs.where((c) => c.behavior is CommunityMouseDragScrollBehavior), isNotEmpty);
    });

    testWidgets('pages the library pushes keep the scroll settings', (tester) async {
      const settings = CommunityScrollSettings(pullToRefresh: false, behavior: CommunityMouseDragScrollBehavior());
      late Widget Function(Widget) carry;
      await tester.pumpWidget(
        CommunityScrollScope(
          settings: settings,
          child: Builder(
            builder: (context) {
              carry = carryCommunityBuilders(context);
              return const SizedBox();
            },
          ),
        ),
      );

      CommunityScrollSettings? seen;
      await tester.pumpWidget(
        carry(
          Builder(
            builder: (context) {
              seen = CommunityScrollScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seen, settings);
    });
  });

  group('settings from RendezvousCommunity', () {
    const settings = CommunityScrollSettings(pullToRefresh: false);
    late RendezvousCommunity community;

    setUp(() {
      community = RendezvousCommunity.create(
        supabaseUrl: 'http://api.test',
        anonKey: 'anon',
        tokenProvider: () async => null,
        trackDelivery: false,
        offlineCache: false,
        scroll: settings,
        httpClient: MockClient((_) async => http.Response('{}', 404)),
      );
    });

    tearDown(() => community.dispose());

    test('create keeps the scroll settings', () {
      expect(community.scroll, settings);
      expect(CommunityScrollSettings.defaults.pullToRefresh, isTrue);
      expect(CommunityScrollSettings.defaults.behavior, isNull);
    });

    testWidgets('widgets below CommunityScope fall back to them', (tester) async {
      CommunityScrollSettings? seen;
      await tester.pumpWidget(
        CommunityScope(
          dependencies: community,
          child: Builder(
            builder: (context) {
              seen = CommunityScrollScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(seen, settings);
    });
  });
}
