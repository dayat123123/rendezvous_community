import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/edit/presentation/widgets/edit_content_dialog.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/comment_tree.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

class _Feed extends FakeFeedRepository {
  _Feed(this.posts);

  final List<Post> posts;

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(posts);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Stocks implements StockRepository {
  final watched = <String>[];

  @override
  Future<Stock?> getStock(String code) async => Stock(code: code, watcherCount: 3);

  @override
  Future<void> watch(String code) async => watched.add(code);

  @override
  Future<void> unwatch(String code) async => watched.remove(code);
}

class _HashtagSearch extends FakeSearchRepository {
  @override
  Future<Paged<Post>> hashtagFeed(String tag, {String? cursor, int limit = 20}) async => const Paged.empty();
}

class _HashtagFeatures extends FakeFeatureDependencies {
  _HashtagFeatures() : super(config: loadedConfig());

  final _search = _HashtagSearch();

  @override
  FakeSearchRepository get search => _search;
}

class _Profiles extends Fake implements ProfileRepository {
  _Profiles(this.profile);

  final UserProfile profile;

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => profile;
}

class _Deps extends FakeDependencies {
  _Deps({super.feed, super.stocks, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  ProfileRepository get profiles => profileRepository ?? super.profiles;
}

Post _post({String id = 'p-1', UserSummary author = alice, Poll? poll}) => Post(
  id: id,
  author: author,
  body: r'Analisis $BBCA #bank',
  stockCodes: const ['BBCA'],
  hashtags: const ['bank'],
  likeCount: 3,
  createdAt: now,
  cursor: id,
  poll: poll,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  CommunityBuilders builders = const CommunityBuilders(),
  CommunityDependencies? deps,
  FakeFeatureDependencies? features,
}) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final scoped = features == null ? child : CommunityFeatureScope(dependencies: features, child: child);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: deps ?? FakeDependencies(),
          child: CommunityBuildersScope(builders: builders, child: scoped),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _wrap(String label, Widget fallback) =>
    Column(mainAxisSize: MainAxisSize.min, children: [Text(label), fallback]);

void main() {
  group('feed builders', () {
    testWidgets('feed tabs, compose prompt, post menu and default tags', (tester) async {
      final selected = <CommunityFeedTab>[];
      CommunityComposePromptDetails? prompt;
      CommunityPostDetails? menu;
      await _pump(
        tester,
        CommunityStreamFeed(
          builders: CommunityFeedBuilders(
            feedTabs: (context, d, fallback) => Row(
              children: [
                for (final (i, tab) in d.tabs.indexed)
                  TextButton(
                    onPressed: () {
                      selected.add(tab);
                      d.onSelect(tab);
                    },
                    child: Text('tab ${d.labels[i]} ${tab == d.selected}'),
                  ),
              ],
            ),
            composePrompt: (context, d, fallback) {
              prompt = d;
              return _wrap('prompt', fallback);
            },
            postMenu: (context, d, fallback) {
              menu = d;
              return Text('menu ${d.post.id} ${d.onReport != null}');
            },
          ),
        ),
        deps: _Deps(feed: _Feed([_post()])),
      );

      expect(find.text('tab Terbaru true'), findsOneWidget);
      expect(find.text('prompt'), findsOneWidget);
      expect(find.text('Apa pendapat Anda tentang pasar hari ini?'), findsOneWidget);
      expect(prompt!.user, me);
      expect(find.text('menu p-1 true'), findsOneWidget);
      expect(menu!.isMine, isFalse);
      expect(find.widgetWithText(RawChip, r'$BBCA'), findsNothing);

      await tester.tap(find.text('tab Mengikuti false'));
      await tester.pumpAndSettle();
      expect(selected, [CommunityFeedTab.following]);
      expect(find.text('tab Mengikuti true'), findsOneWidget);
    });

    testWidgets('thread header, thread rows, comment and reply composer', (tester) async {
      final deps = FakeDependencies();
      final more = <CommunityThreadMoreKind>[];
      CommunityReplyComposerDetails? composer;
      await _pump(
        tester,
        const CommunityPostDetail(postId: 'p-1'),
        deps: deps,
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            threadHeader: (context, d, fallback) => Text('header ${d.commentCount} ${d.label}'),
            threadMore: (context, d, fallback) {
              more.add(d.kind);
              return d.kind == CommunityThreadMoreKind.moreReplies
                  ? TextButton(onPressed: d.onTap, child: Text('lagi ${d.remaining} ${d.level}'))
                  : fallback;
            },
            replyComposer: (context, d, fallback) {
              composer = d;
              return Row(
                children: [
                  Expanded(child: d.field),
                  TextButton(onPressed: d.onSend, child: Text('kirim ${d.replyingLabel}')),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('header 7 Komentar (7)'), findsOneWidget);
      expect(more, containsAll([CommunityThreadMoreKind.moreReplies, CommunityThreadMoreKind.continueThread]));
      expect(find.text('Lanjutkan thread →'), findsOneWidget);
      expect(composer!.hintText, 'Tulis komentar…');
      expect(composer!.sending, isFalse);

      await tester.tap(find.text('lagi 1 1'));
      await tester.pumpAndSettle();
      expect(deps.comments.requests.last['root'], 'c1');
      expect(find.text('Balasan C'), findsOneWidget);

      final level2 = find.ancestor(of: find.text('Level 2'), matching: find.byType(CommentTile)).first;
      await tester.tap(find.descendant(of: level2, matching: find.text('Balas')).first);
      await tester.pumpAndSettle();
      expect(find.text('kirim Membalas Bob'), findsOneWidget);
      expect(composer!.onCancelReply, isNotNull);
    });

    testWidgets('thread context receives the root comment and opens the post', (tester) async {
      CommunityThreadContextDetails? context;
      await _pump(
        tester,
        const CommunityPostDetail(postId: 'p-1', rootCommentId: 'c1'),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            threadContext: (ctx, d, fallback) {
              context = d;
              return Text('konteks ${d.label} ${d.actionLabel}');
            },
          ),
        ),
      );
      expect(find.text('konteks Melanjutkan thread Post'), findsOneWidget);
      expect(context!.root.id, 'c1');
    });

    testWidgets('compose toolbar, sentiment and poll editor', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      CommunityPollEditorDetails? editor;
      await _pump(
        tester,
        const CommunityComposePost(),
        features: features,
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            composeToolbar: (context, d, fallback) => Row(
              children: [
                TextButton(onPressed: d.onAddPoll, child: Text('polling ${d.hasPoll}')),
                Text('kirim ${d.canPost} ${d.submitLabel}'),
              ],
            ),
            composeSentiment: (context, d, fallback) => Wrap(
              children: [
                for (final (i, option) in d.options.indexed)
                  TextButton(
                    onPressed: () => d.onChanged(option),
                    child: Text('${d.labels[i]} ${option == d.selected}'),
                  ),
              ],
            ),
            pollEditor: (context, d, fallback) {
              editor = d;
              return _wrap('editor ${d.options.length} ${d.durationLabels[d.duration]}', fallback);
            },
          ),
        ),
      );

      expect(find.text('kirim true Kirim'), findsOneWidget);
      await tester.tap(find.text('Bullish false'));
      await tester.pumpAndSettle();
      expect(find.text('Bullish true'), findsOneWidget);

      await tester.tap(find.text('polling false'));
      await tester.pumpAndSettle();
      expect(find.text('polling true'), findsOneWidget);
      expect(find.text('editor 2 1 hari'), findsOneWidget);
      expect(editor!.controllers, hasLength(2));
      expect(editor!.onRemoveOption, isNull);
      expect(find.byKey(const ValueKey('poll-option-0')), findsOneWidget);

      editor!.onAddOption!();
      await tester.pumpAndSettle();
      expect(find.text('editor 3 1 hari'), findsOneWidget);
      expect(editor!.onRemoveOption, isNotNull);
    });

    testWidgets('poll options can be replaced and vote through the cubit', (tester) async {
      final deps = FakeDependencies();
      deps.polls.onVote = (_, optionId) => Poll(
        endsAt: now.add(const Duration(hours: 2)),
        closed: false,
        totalVotes: 1,
        myOptionId: optionId,
        resultsVisible: true,
        options: const [
          PollOption(id: 'a', label: 'Naik', votes: 1),
          PollOption(id: 'b', label: 'Turun', votes: 0),
        ],
      );
      await _pump(
        tester,
        CommunityPollView(
          postId: 'p-1',
          poll: Poll(
            endsAt: now.add(const Duration(hours: 2)),
            closed: false,
            totalVotes: 0,
            resultsVisible: false,
            options: const [
              PollOption(id: 'a', label: 'Naik'),
              PollOption(id: 'b', label: 'Turun'),
            ],
          ),
        ),
        deps: deps,
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            pollOption: (context, d, fallback) => d.showResults
                ? Text('hasil ${d.option.label} ${d.percentLabel} ${d.mine}')
                : TextButton(onPressed: d.onVote, child: Text('pilih ${d.index} ${d.option.label}')),
          ),
        ),
      );

      await tester.tap(find.text('pilih 0 Naik'));
      await tester.pumpAndSettle();
      expect(deps.polls.votes, [('p-1', 'a')]);
      expect(find.text('hasil Naik 100% true'), findsOneWidget);
      expect(find.text('hasil Turun 0% false'), findsOneWidget);
    });

    testWidgets('attachment images and documents', (tester) async {
      const image = Attachment(path: 'u/a.jpg', mime: 'image/jpeg');
      const pdf = Attachment(path: 'u/laporan.pdf', mime: 'application/pdf', name: 'laporan.pdf', size: 2048);
      await _pump(
        tester,
        const Column(
          children: [
            SizedBox(height: 200, child: AttachmentGrid(attachments: [image, image])),
            DocumentAttachments(attachments: [pdf], color: Colors.indigo),
          ],
        ),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            attachmentImage: (context, d, fallback) => Text('gambar ${d.index}/${d.count} ${d.held}'),
            document: (context, d, fallback) =>
                TextButton(onPressed: d.onOpen, child: Text('dok ${d.name} ${d.sizeLabel} ${d.opening}')),
          ),
        ),
      );
      expect(find.text('gambar 0/2 false'), findsOneWidget);
      expect(find.text('gambar 1/2 false'), findsOneWidget);
      expect(find.text('dok laporan.pdf PDF · 2 KB false'), findsOneWidget);
    });

    testWidgets('draft tiles get the preview and working handlers', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.draftRepository.saved['d1'] = PostDraft(
        clientDraftId: 'd1',
        body: r'Draf $BBCA',
        updatedAt: now,
        serverUpdatedAt: now,
      );
      await _pump(
        tester,
        const CommunityPostDrafts(),
        features: features,
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            draftTile: (context, d, fallback) =>
                TextButton(onPressed: d.onDelete, child: Text('draf ${d.preview} ${d.synced} ${d.deleteLabel}')),
          ),
        ),
      );
      await tester.tap(find.text(r'draf Draf $BBCA true Hapus'));
      await tester.pumpAndSettle();
      expect(features.draftRepository.deleted, ['d1']);
    });

    testWidgets('stock header toggles watching through its details', (tester) async {
      final stocks = _Stocks();
      await _pump(
        tester,
        const CommunityStockFeed(stockCode: 'bbca', stockName: 'Bank Central Asia'),
        deps: _Deps(feed: _Feed(const []), stocks: stocks),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            stockHeader: (context, d, fallback) => TextButton(
              onPressed: d.onToggleWatch,
              child: Text('saham ${d.code} ${d.subtitle} ${d.watchLabel} ${d.found}'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('saham BBCA Bank Central Asia · 3 pemantau Pantau true'));
      await tester.pumpAndSettle();
      expect(stocks.watched, ['BBCA']);
      expect(find.text('saham BBCA Bank Central Asia · 4 pemantau Dipantau true'), findsOneWidget);
    });

    testWidgets('the edit dialog builder receives the field and returns the saved text', (tester) async {
      String? result;
      await _pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await showEditContentDialog(context, title: 'Edit post', initial: 'Lama', maxLength: 50),
            child: const Text('buka'),
          ),
        ),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            editDialog: (context, d, fallback) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('dialog ${d.title} ${d.maxLength} ${d.saveLabel}'),
                  d.field,
                  TextButton(onPressed: d.onSave, child: const Text('simpan')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      expect(find.text('dialog Edit post 50 Simpan'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Baru');
      await tester.tap(find.text('simpan'));
      await tester.pumpAndSettle();
      expect(result, 'Baru');
    });

    testWidgets('defaults render without builders in light and dark', (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            locale: const Locale('id'),
            localizationsDelegates: CommunityLocalizations.localizationsDelegates,
            supportedLocales: CommunityLocalizations.supportedLocales,
            home: Scaffold(
              body: CommunityScope(
                dependencies: FakeDependencies(
                  feed: _Feed([_post(author: me), _post(id: 'p-2')]),
                ),
                child: const CommunityStreamFeed(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.more_horiz), findsNWidgets(2));
        expect(find.text('Suka · 3'), findsNWidgets(2));
      }
    });

    testWidgets('feed posts split a short first line into a title and truncate with read more', (tester) async {
      final opened = <String>[];
      final long = List.filled(12, 'Kalimat analisis yang cukup panjang untuk memenuhi beberapa baris.').join(' ');
      await _pump(
        tester,
        const CommunityFeedList(scope: FeedScope.global(), emptyMessage: 'Kosong'),
        deps: FakeDependencies(
          feed: _Feed([_post().copyWith(body: 'Judul pendek\n$long')]),
          callbacks: CommunityCallbacks(onPostTap: (context, id) => opened.add(id)),
        ),
      );
      expect(find.text('Judul pendek'), findsOneWidget);
      await tester.tap(find.text('… Baca lebih lanjut'));
      await tester.pumpAndSettle();
      expect(opened, ['p-1']);
    });

    testWidgets('the detail shows topic chips and a sticky action bar', (tester) async {
      await _pump(tester, const CommunityPostDetail(postId: 'p-1'));
      expect(find.text(r'$BBCA'), findsOneWidget);
      expect(find.byType(CommunityActionPill), findsOneWidget);
      expect(find.text('… Baca lebih lanjut'), findsNothing);
    });

    testWidgets('edge to edge grids show four tiles and a count for the rest', (tester) async {
      const image = Attachment(path: 'u/a.jpg', mime: 'image/jpeg');
      await _pump(
        tester,
        const AttachmentGrid(attachments: [image, image, image, image, image, image], edgeToEdge: true),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(attachmentImage: (context, d, fallback) => Text('img ${d.index}')),
        ),
      );
      expect(find.textContaining('img '), findsNWidgets(4));
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('default post cards and thread meet tap target and contrast guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const CommunityStreamFeed(), deps: _Deps(feed: _Feed([_post()])));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await _pump(tester, const CommunityPostDetail(postId: 'p-1'));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('discovery builders', () {
    testWidgets('search field, tabs, results and sections', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.search.answer = (query, type, cursor) => SearchResults(
        query: query,
        type: type,
        users: const [UserSearchResult(user: alice, followerCount: 5)],
        stocks: const [StockSearchResult(code: 'BBCA', posts7d: 4, watcherCount: 2, isWatching: true)],
        hashtags: const [HashtagSummary(tag: 'bbca', postCount: 2)],
      );
      CommunitySearchFieldDetails? field;
      await _pump(
        tester,
        const CommunitySearch(initialQuery: 'bbca'),
        features: features,
        builders: CommunityBuilders(
          discovery: CommunityDiscoveryBuilders(
            searchField: (context, d, fallback) {
              field = d;
              return _wrap('field ${d.hintText}', fallback);
            },
            searchTabs: (context, d, fallback) => Wrap(
              children: [
                for (final (i, type) in d.types.indexed)
                  TextButton(onPressed: () => d.onSelect(type), child: Text('${d.labels[i]} ${type == d.selected}')),
              ],
            ),
            userResult: (context, d, fallback) => Text('user ${d.user.username} ${d.subtitle}'),
            stockResult: (context, d, fallback) => Text('saham ${d.code} ${d.watching}'),
            hashtag: (context, d, fallback) => Text('tag ${d.tag} ${d.placement.name} ${d.countLabel}'),
          ),
        ),
      );

      expect(field!.controller.text, 'bbca');
      expect(find.text(r'field Cari post, pengguna, $KODE, #hashtag'), findsOneWidget);
      expect(find.text('Semua true'), findsOneWidget);
      expect(find.text('user alice @alice · 5 pengikut'), findsOneWidget);
      expect(find.text('saham BBCA true'), findsOneWidget);
      expect(find.text('tag bbca searchResult 2 post (7 hari)'), findsOneWidget);

      await tester.tap(find.text('Saham & Indeks false'));
      await tester.pumpAndSettle();
      expect(features.search.queries.last.$2, SearchType.stocks);
      expect(find.text('Saham & Indeks true'), findsOneWidget);

      field!.onClear();
      await tester.pumpAndSettle();
      expect(field!.controller.text, isEmpty);
    });

    testWidgets('empty state, suggestions and the hashtag header', (tester) async {
      final features = _HashtagFeatures();
      addTearDown(features.dispose);
      features.search.trending = const [HashtagSummary(tag: 'ipo', postCount: 3)];
      await _pump(
        tester,
        const CommunitySearch(),
        features: features,
        builders: CommunityBuilders(
          discovery: CommunityDiscoveryBuilders(
            hashtag: (context, d, fallback) => TextButton(onPressed: d.onOpen, child: Text('saran ${d.rank} ${d.tag}')),
            empty: (context, d, fallback) => Text('kosong ${d.message}'),
          ),
        ),
      );
      await tester.tap(find.text('saran 1 ipo'));
      await tester.pumpAndSettle();
      expect(features.search.queries.single.$1, '#ipo');
      expect(find.text('kosong Tidak ada hasil untuk "#ipo".'), findsOneWidget);

      await _pump(
        tester,
        const CommunityHashtagFeed(tag: 'IPO'),
        features: features,
        deps: _Deps(feed: _Feed(const [])),
        builders: CommunityBuilders(
          discovery: CommunityDiscoveryBuilders(
            hashtagHeader: (context, d, fallback) => Text('judul #${d.tag} ${d.header == null}'),
          ),
        ),
      );
      expect(find.text('judul #ipo true'), findsOneWidget);
    });

    testWidgets('trending tabs, stock rows and the sentiment bar', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.trending.snapshot = (window) => TrendingSnapshot(
        window: window,
        stocks: [
          TrendingStock(code: window == TrendWindow.day ? 'BBCA' : 'TLKM', posts: 5, bullishPct: 60, bearishPct: 20),
        ],
        rising: const [RisingStock(code: 'GOTO', posts: 9, growthPct: 350)],
      );
      CommunityTrendingTabsDetails? tabs;
      final bars = <CommunitySentimentBarDetails>[];
      await _pump(
        tester,
        const CommunityTrending(),
        features: features,
        builders: CommunityBuilders(
          discovery: CommunityDiscoveryBuilders(
            trendingTabs: (context, d, fallback) {
              tabs = d;
              return _wrap('tabs ${d.labels.join(',')} ${d.windowLabels.join(',')}', fallback);
            },
            trendingStock: (context, d, fallback) => d.kind == CommunityTrendingStockKind.rising
                ? Text('naik ${d.rank} ${d.code} ${d.growthLabel}')
                : _wrap('tren ${d.rank} ${d.code} ${d.postsLabel} ${d.hasSentiment}', fallback),
            sentimentBar: (context, d, fallback) {
              bars.add(d);
              return fallback;
            },
          ),
        ),
      );

      expect(find.text('tabs Saham & Indeks,Naik daun,Populer,Hashtag 24 jam,7 hari'), findsOneWidget);
      expect(find.text('tren 1 BBCA 5 post true'), findsOneWidget);
      expect(bars.last.neutralPct, 20);
      expect(find.byType(SentimentBar), findsOneWidget);

      tabs!.onWindowChanged(TrendWindow.week);
      await tester.pumpAndSettle();
      expect(find.text('tren 1 TLKM 5 post true'), findsOneWidget);

      tabs!.onSelect!(CommunityTrendingTab.rising);
      await tester.pumpAndSettle();
      expect(find.text('naik 1 GOTO +350%'), findsOneWidget);
    });

    testWidgets('stock sentiment details and window switching', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.trending.sentiment = const StockSentiment(
        code: 'BBCA',
        day: SentimentBreakdown(posts: 3, bullish: 2, bearish: 1, bullishPct: 67, bearishPct: 33),
      );
      CommunityStockSentimentDetails? details;
      await _pump(
        tester,
        const CommunityStockSentiment(stockCode: 'bbca'),
        features: features,
        builders: CommunityBuilders(
          discovery: CommunityDiscoveryBuilders(
            stockSentiment: (context, d, fallback) {
              details = d;
              return d.hasData ? Text('${d.code} ${d.bullishLabel} ${d.basedOnLabel}') : Text(d.noDataLabel);
            },
          ),
        ),
      );
      expect(find.text('BBCA Bullish 67% Dari 3 post'), findsOneWidget);
      details!.onWindowChanged(TrendWindow.week);
      await tester.pumpAndSettle();
      expect(find.text('Belum ada post berlabel sentimen.'), findsOneWidget);
      expect(details!.window, TrendWindow.week);
    });

    testWidgets('default search and trending meet tap target and contrast guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.search.answer = (query, type, cursor) => SearchResults(
        query: query,
        type: type,
        users: const [UserSearchResult(user: alice, followerCount: 5)],
        stocks: const [StockSearchResult(code: 'BBCA', posts7d: 4, watcherCount: 2)],
        hashtags: const [HashtagSummary(tag: 'bbca', postCount: 2)],
      );
      features.trending.snapshot = (window) => TrendingSnapshot(
        window: window,
        stocks: const [TrendingStock(code: 'BBCA', posts: 5, bullishPct: 60, bearishPct: 20, growthPct: 10)],
      );
      await _pump(tester, const CommunitySearch(initialQuery: 'bbca'), features: features);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await _pump(tester, const CommunityTrending(), features: features);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    test('merge keeps the parent slot unless the child sets it', () {
      Widget a(BuildContext c, CommunityHashtagDetails d, Widget f) => const Text('a');
      Widget b(BuildContext c, CommunityHashtagDetails d, Widget f) => const Text('b');
      Widget s(BuildContext c, CommunitySearchFieldDetails d, Widget f) => const Text('s');
      final merged = CommunityDiscoveryBuilders(
        hashtag: a,
        searchField: s,
      ).merge(CommunityDiscoveryBuilders(hashtag: b));
      expect(merged.hashtag, b);
      expect(merged.searchField, s);
      expect(CommunityDiscoveryBuilders(hashtag: a).merge(null).hashtag, a);
    });
  });

  group('profile builders', () {
    testWidgets('the menu builder receives the profile handlers', (tester) async {
      CommunityProfileDetails? details;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: alice.id,
          builders: CommunityProfileBuilders(
            menu: (context, d, fallback) {
              details = d;
              return Text('menu ${d.profile.user.username} ${d.onReport != null} ${d.onBlock != null}');
            },
          ),
        ),
        deps: _Deps(
          feed: _Feed(const []),
          profileRepository: _Profiles(
            UserProfile(
              user: alice,
              followerCount: 1,
              followingCount: 1,
              postCount: 1,
              createdAt: now,
              isMe: false,
              isFollowing: false,
              followsMe: true,
              isBlocked: false,
            ),
          ),
        ),
      );
      expect(find.text('menu alice true true'), findsOneWidget);
      expect(find.text('Mengikuti Anda'), findsOneWidget);
      expect(details!.onUnblock, isNull);
    });
  });
}
