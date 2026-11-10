import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class _Media extends Fake implements MediaRepository {
  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) async =>
      AuthorizedImage('https://img.test/${attachment.path}', const {});
}

const _photos = [
  Attachment(path: 'posts/u-alice/a.png', mime: 'image/png'),
  Attachment(path: 'posts/u-alice/b.png', mime: 'image/png'),
];

class _PhotoFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged([
    Post(
      id: 'p-1',
      author: alice,
      body: 'Grafik BBCA',
      attachments: _photos,
      createdAt: now.subtract(const Duration(hours: 1)),
      cursor: 'c',
    ),
  ]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityImageScope(
          loader: CommunityImageLoader(client: MockClient((_) async => http.Response.bytes(_png, 200))),
          child: CommunityScope(
            dependencies: FakeDependencies(feed: _PhotoFeed(), mediaRepository: _Media()),
            child: child,
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

const _feed = CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'Kosong');

void main() {
  testWidgets('tapping a post photo opens the viewer at that photo without reply or reactions', (tester) async {
    await _pump(tester, _feed);

    await tester.tap(find.bySemanticsLabel('Lihat gambar').at(1));
    await _settle(tester);

    expect(find.text('2 dari 2'), findsOneWidget);
    expect(find.byTooltip('Unduh'), findsOneWidget);
    expect(find.text(alice.displayName ?? alice.username), findsWidgets);
    expect(find.byTooltip('Balas'), findsNothing);
    expect(find.text('👍'), findsNothing);
  });

  testWidgets('host builders get onOpenImage on the post details', (tester) async {
    CommunityPostDetails? seen;
    await _pump(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            attachments: (context, details, fallback) {
              seen = details;
              return TextButton(onPressed: () => details.onOpenImage!(0), child: const Text('foto'));
            },
          ),
        ),
        child: _feed,
      ),
    );

    expect(seen?.onOpenImage, isNotNull);
    await tester.tap(find.text('foto'));
    await _settle(tester);
    expect(find.text('1 dari 2'), findsOneWidget);
  });
}
