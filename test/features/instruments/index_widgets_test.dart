import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/legal_fakes.dart';

const _instruments = [
  MarketInstrument(code: 'IHSG', name: 'Indeks Harga Saham Gabungan', aliases: ['COMPOSITE', 'JCI']),
  MarketInstrument(
    code: 'SRI-KEHATI',
    name: 'Indeks SRI-KEHATI',
    aliases: ['SRIKEHATI'],
    description: 'Emiten dengan kinerja keberlanjutan baik',
    position: 1,
  ),
  MarketInstrument(code: 'LQ45', name: 'Indeks LQ45', position: 2, roomEnabled: false),
];

class _Stocks implements StockRepository {
  final watched = <String>[];
  final requested = <String>[];

  @override
  Future<Stock?> getStock(String code) async {
    requested.add(code);
    return Stock(code: code == 'COMPOSITE' ? 'IHSG' : code, watcherCount: 12);
  }

  @override
  Future<void> watch(String code) async => watched.add(code);

  @override
  Future<void> unwatch(String code) async => watched.remove(code);
}

class _Feed extends FakeFeedRepository {
  final scopes = <FeedScope>[];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async {
    scopes.add(scope);
    return Paged([
      Post(id: 'p-1', author: alice, body: r'$SRI-KEHATI-nya naik, $composite ikut', createdAt: now, cursor: 'c'),
    ]);
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

({_Stocks stocks, _Feed feed, FakeDependencies deps}) _setup({
  CommunityCallbacks callbacks = const CommunityCallbacks(),
}) {
  final stocks = _Stocks();
  final feed = _Feed();
  MarketInstrumentDirectory.forSource(stocks).replace(_instruments);
  return (stocks: stocks, feed: feed, deps: FakeDependencies(stocks: stocks, feed: feed, callbacks: callbacks));
}

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('CommunityIndexFeed shows the index header and the feed of the main code', (tester) async {
    _bigScreen(tester);
    final s = _setup();
    await pumpCommunity(tester, const CommunityIndexFeed(indexCode: 'srikehati'), dependencies: s.deps);

    expect(find.text(r'$SRI-KEHATI'), findsWidgets);
    expect(find.text('Indeks'), findsOneWidget);
    expect(find.text('Indeks SRI-KEHATI'), findsOneWidget);
    expect(find.text('Emiten dengan kinerja keberlanjutan baik'), findsOneWidget);
    expect(find.text(r'Juga ditulis $SRIKEHATI'), findsOneWidget);
    expect(find.text('Diskusi'), findsOneWidget);
    expect(s.stocks.requested, ['SRI-KEHATI']);
    expect(s.feed.scopes, [const FeedScope.stock('SRI-KEHATI')]);

    await tester.tap(find.text('Pantau'));
    await tester.pump();
    expect(s.stocks.watched, ['SRI-KEHATI']);
  });

  testWidgets('a closed index room disables the discussion button', (tester) async {
    _bigScreen(tester);
    final s = _setup();
    await pumpCommunity(tester, const CommunityIndexFeed(indexCode: 'LQ45'), dependencies: s.deps);

    final button = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Room ditutup'));
    expect(button.onPressed, isNull);
  });

  testWidgets('the indexHeader builder receives the index details', (tester) async {
    _bigScreen(tester);
    final s = _setup();
    CommunityIndexHeaderDetails? seen;
    await pumpCommunity(
      tester,
      CommunityIndexFeed(
        indexCode: 'JCI',
        builders: CommunityFeedBuilders(
          indexHeader: (context, details, fallback) {
            seen = details;
            return Text('header ${details.code} ${details.aliases.join('/')} ${details.roomEnabled}');
          },
        ),
      ),
      dependencies: s.deps,
    );

    expect(find.text('header IHSG COMPOSITE/JCI true'), findsOneWidget);
    expect(seen?.kindLabel, 'Indeks');
    expect(seen?.found, isTrue);
    expect(seen?.onOpenDiscussion, isNotNull);
  });

  testWidgets('CommunityIndexList lists the indices and opens one', (tester) async {
    _bigScreen(tester);
    final opened = <String>[];
    final s = _setup(callbacks: CommunityCallbacks(onIndexTap: (_, code) => opened.add(code)));
    await pumpCommunity(tester, const CommunityIndexList(showStats: false), dependencies: s.deps);

    expect(find.text(r'$IHSG'), findsOneWidget);
    expect(find.text('Indeks LQ45'), findsOneWidget);

    await tester.tap(find.text(r'$SRI-KEHATI'));
    expect(opened, ['SRI-KEHATI']);
  });

  testWidgets('the indexTile builder replaces each row', (tester) async {
    _bigScreen(tester);
    final s = _setup();
    final opened = <String>[];
    await pumpCommunity(
      tester,
      CommunityIndexList(
        showStats: false,
        onOpen: (_, instrument) => opened.add(instrument.code),
        builders: CommunityFeedBuilders(
          indexTile: (context, details, fallback) =>
              TextButton(onPressed: details.onOpen, child: Text('tile ${details.code} ${details.kindLabel}')),
        ),
      ),
      dependencies: s.deps,
    );

    expect(find.textContaining('tile '), findsNWidgets(3));
    await tester.tap(find.text('tile LQ45 Indeks'));
    expect(opened, ['LQ45']);
  });

  testWidgets('index cashtags render whole, aliases open the main code', (tester) async {
    _bigScreen(tester);
    final indexes = <String>[];
    final stocks = <String>[];
    final s = _setup(
      callbacks: CommunityCallbacks(
        onIndexTap: (_, code) => indexes.add(code),
        onStockTap: (_, code) => stocks.add(code),
      ),
    );
    await pumpCommunity(
      tester,
      const SocialText(r'$SRI-KEHATI-nya naik, $composite ikut, $BBCA juga'),
      dependencies: s.deps,
    );

    final rich = tester.widget<Text>(find.byType(Text)).textSpan!.toPlainText();
    expect(rich, r'$SRI-KEHATI-nya naik, $composite ikut, $BBCA juga');

    final spans = <TextSpan>[];
    tester.widget<Text>(find.byType(Text)).textSpan!.visitChildren((span) {
      if (span is TextSpan && span.recognizer != null) spans.add(span);
      return true;
    });
    expect(spans.map((s) => s.text), [r'$SRI-KEHATI', r'$composite', r'$BBCA']);
    for (final span in spans) {
      (span.recognizer! as dynamic).onTap();
    }
    expect(indexes, ['SRI-KEHATI', 'IHSG']);
    expect(stocks, ['BBCA']);
  });

  testWidgets('composer suggestions put matching indices first', (tester) async {
    _bigScreen(tester);
    final s = _setup(
      callbacks: CommunityCallbacks(
        stockSearch: (query) async => const [
          StockSuggestion(code: 'SRIL', name: 'Sri Rejeki Isman'),
          StockSuggestion(code: 'SRIKEHATI'),
        ],
      ),
    );
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pumpCommunity(
      tester,
      CommunityComposerField(controller: controller, hintText: 'Tulis'),
      dependencies: s.deps,
    );

    await tester.enterText(find.byType(TextField), r'$SRI');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text(r'$SRI-KEHATI'), findsOneWidget);
    expect(find.text('Indeks SRI-KEHATI · Indeks'), findsOneWidget);
    expect(find.text(r'$SRIL'), findsOneWidget);
    expect(find.text(r'$SRIKEHATI'), findsNothing);

    await tester.tap(find.text(r'$SRI-KEHATI'));
    await tester.pump();
    expect(controller.text, r'$SRI-KEHATI ');
  });

  testWidgets('watching through an alias unwatches the main code', (tester) async {
    _bigScreen(tester);
    final s = _setup();
    await pumpCommunity(tester, const CommunityStockFeed(stockCode: 'COMPOSITE'), dependencies: s.deps);

    await tester.tap(find.text('Pantau'));
    await tester.pump();
    expect(s.stocks.watched, ['IHSG']);

    await tester.tap(find.text('Dipantau'));
    await tester.pump();
    expect(s.stocks.watched, isEmpty);
  });
}
