import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/help_fakes.dart';

const _network = CommunityException(CommunityErrorKind.network, message: 'offline');

Widget _app(
  FakeHelpRepository help, {
  List<String?>? contacted,
  CommunityHelpBuilders builders = const CommunityHelpBuilders(),
  Locale locale = const Locale('id'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: CommunityLocalizations.localizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  home: CommunityBuildersScope(
    builders: CommunityBuilders(help: builders),
    child: Scaffold(
      body: CommunityHelpScope(
        dependencies: FakeHelpDependencies(help),
        child: CommunityHelpCenter(onContactSupport: contacted == null ? null : (_, topic) => contacted.add(topic)),
      ),
    ),
  ),
);

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  test('merge keeps every slot and lets the newer set win', () {
    Widget a<T>(BuildContext c, T d, Widget f) => f;
    Widget b<T>(BuildContext c, T d, Widget f) => const SizedBox();
    final full = CommunityHelpBuilders(
      loading: a,
      empty: a,
      error: a,
      searchField: a,
      categoryTile: a,
      articleTile: a,
      articleDetail: a,
      feedback: a,
      contact: a,
      offlineNotice: a,
      topicSuggestions: a,
    );
    List<Object?> slots(CommunityHelpBuilders x) => [
      x.loading,
      x.empty,
      x.error,
      x.searchField,
      x.categoryTile,
      x.articleTile,
      x.articleDetail,
      x.feedback,
      x.contact,
      x.offlineNotice,
      x.topicSuggestions,
    ];
    expect(slots(const CommunityHelpBuilders().merge(full)), slots(full));
    expect(slots(full.merge(const CommunityHelpBuilders())), slots(full));
    expect(identical(full.merge(null), full), isTrue);
    final tile = CommunityHelpBuilders(articleTile: b);
    expect(full.merge(tile).articleTile, same(tile.articleTile));
    expect(full.merge(tile).feedback, same(full.feedback));
    final merged = const CommunityBuilders().merge(CommunityBuilders(help: tile));
    expect(merged.help.articleTile, same(tile.articleTile));
  });

  testWidgets('categories open their articles and an article shows the formatted answer', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository();
    final contacted = <String?>[];
    await tester.pumpWidget(_app(help, contacted: contacted));
    await tester.pumpAndSettle();

    expect(find.text('Akun & Keamanan'), findsOneWidget);
    expect(find.text('2 artikel'), findsOneWidget);
    expect(find.text('Dana'), findsOneWidget);
    expect(find.byIcon(Icons.gpp_maybe_outlined), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

    await tester.tap(find.text('Akun & Keamanan'));
    await tester.pumpAndSettle();
    expect(find.text('Tidak bisa masuk ke aplikasi'), findsOneWidget);
    await tester.tap(find.text('Bagaimana cara mengganti PIN?'));
    await tester.pumpAndSettle();

    expect(help.articleReads, ['a-pin']);
    expect(find.text('Bagaimana cara mengganti PIN?'), findsOneWidget);
    expect(find.textContaining('Profil', findRichText: true), findsWidgets);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.textContaining('pusat bantuan', findRichText: true), findsOneWidget);
    expect(find.text('Apakah ini membantu?'), findsOneWidget);

    await tester.tap(find.text('Chat CS'));
    expect(contacted, ['account']);
  });

  testWidgets('feedback: vote, then an optional comment', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityHelpArticleView(article: depositArticle, repository: help),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Tidak'));
    await tester.pumpAndSettle();
    expect(help.feedback.single, (articleId: 'a-deposit', helpful: false, comment: null));
    expect(find.text('Terima kasih atas masukan Anda.'), findsOneWidget);

    final send = find.widgetWithText(FilledButton, 'Kirim');
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Dana saya belum masuk setelah 2 jam');
    await tester.pump();
    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(help.feedback.last, (
      articleId: 'a-deposit',
      helpful: false,
      comment: 'Dana saya belum masuk setelah 2 jam',
    ));
    expect(find.text('Komentar Anda sudah terkirim.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a vote that fails shows the error and keeps the article', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository()
      ..feedbackError = const CommunityException(CommunityErrorKind.rateLimited, code: 'rate_limited');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityHelpArticleView(article: depositArticle, repository: help),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Terima kasih atas masukan Anda.'), findsNothing);
  });

  testWidgets('an earlier vote from the server is shown as selected', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository()
      ..feedbackByArticle['a-deposit'] = const HelpFeedback(helpful: true, comment: 'Ok');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityHelpArticleView(article: depositArticle, repository: help),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Ya'), findsOneWidget);
    expect(find.text('Komentar Anda sudah terkirim.'), findsOneWidget);
  });

  testWidgets('answer images from the faq-images bucket render with alt text and a broken-image fallback', (
    tester,
  ) async {
    _tallView(tester);
    final help = FakeHelpRepository();
    const article = HelpArticle(
      id: 'a-image',
      category: 'account',
      question: 'Contoh layar',
      answer: 'Lihat layar berikut:\n\n![Layar ganti PIN]($helpImageUrl)\n\n![](https://evil.example/x.png)',
    );
    help.content = HelpCenterContent(
      categories: [
        const HelpCategory(code: 'account', name: 'Akun', articles: [article]),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityHelpArticleView(article: article, repository: help),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images, hasLength(1));
    expect((images.single.image as NetworkImage).url, helpImageUrl);
    expect(images.single.semanticLabel, 'Layar ganti PIN');
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(find.ancestor(of: find.byType(Image), matching: find.byType(InkWell)), findsNothing);
  });

  testWidgets('search waits for typing to pause, lists matches, and says when nothing matches', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository();
    final contacted = <String?>[];
    await tester.pumpWidget(_app(help, contacted: contacted));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'dep');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'deposit');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(help.searches, ['deposit']);
    expect(find.text('Berapa lama dana deposit masuk?'), findsOneWidget);
    expect(find.text('Akun & Keamanan'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada artikel yang cocok dengan “zzz”.'), findsOneWidget);
    await tester.tap(find.text('Chat CS'));
    expect(contacted, [null]);

    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('Akun & Keamanan'), findsOneWidget);
  });

  testWidgets('a rate-limited search shows the error message', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository()
      ..searchError = const CommunityException(CommunityErrorKind.rateLimited, code: 'rate_limited');
    await tester.pumpWidget(_app(help));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pin');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(CommunityErrorView), findsOneWidget);
  });

  testWidgets('offline: the saved help center opens with a notice, searches locally, and refreshes on retry', (
    tester,
  ) async {
    _tallView(tester);
    final help = FakeHelpRepository(cached: helpContent(savedAt: DateTime.utc(2026, 11, 8)))..centerError = _network;
    await tester.pumpWidget(_app(help));
    await tester.pumpAndSettle();

    expect(find.text('Anda sedang offline. Menampilkan Pusat Bantuan yang tersimpan.'), findsOneWidget);
    expect(find.text('Akun & Keamanan'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pin');
    await tester.pumpAndSettle();
    expect(help.searches, isEmpty);
    expect(find.text('Hasil dari Pusat Bantuan yang tersimpan.'), findsOneWidget);
    expect(find.text('Bagaimana cara mengganti PIN?'), findsOneWidget);

    help.centerError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Anda sedang offline. Menampilkan Pusat Bantuan yang tersimpan.'), findsNothing);
  });

  testWidgets('offline without a saved copy shows the error with retry', (tester) async {
    final help = FakeHelpRepository()..centerError = _network;
    await tester.pumpWidget(_app(help));
    await tester.pumpAndSettle();

    expect(find.byType(CommunityErrorView), findsOneWidget);
    help.centerError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Akun & Keamanan'), findsOneWidget);
  });

  testWidgets('an empty help center still offers the CS chat', (tester) async {
    final help = FakeHelpRepository(content: const HelpCenterContent());
    await tester.pumpWidget(_app(help, contacted: []));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada artikel bantuan.'), findsOneWidget);
    expect(find.text('Chat CS'), findsOneWidget);
  });

  testWidgets('English texts', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_app(FakeHelpRepository(), locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('2 articles'), findsOneWidget);
    expect(find.text('1 article'), findsOneWidget);
    expect(find.text('Still need help?'), findsOneWidget);
    expect(find.text('Chat with CS'), findsOneWidget);
  });

  testWidgets('builders replace the category tile, contact block and article parts', (tester) async {
    _tallView(tester);
    final help = FakeHelpRepository();
    CommunityHelpArticleDetails? detail;
    CommunityHelpFeedbackDetails? feedback;
    await tester.pumpWidget(
      _app(
        help,
        contacted: [],
        builders: CommunityHelpBuilders(
          categoryTile: (context, d, fallback) =>
              TextButton(onPressed: d.onOpen, child: Text('Kategori ${d.code} (${d.articleCount})')),
          contact: (context, d, fallback) => TextButton(onPressed: d.onContact, child: Text('Hubungi ${d.topic}')),
          articleDetail: (context, d, fallback) {
            detail = d;
            return Column(children: [Text('Detail ${d.title}'), d.feedback]);
          },
          feedback: (context, d, fallback) {
            feedback = d;
            return Text('Suara ${d.voted}');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kategori account (2)'), findsOneWidget);
    expect(find.text('Hubungi null'), findsOneWidget);
    await tester.tap(find.text('Kategori funds (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Hubungi funds'), findsOneWidget);
    await tester.tap(find.text('Berapa lama dana deposit masuk?'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Berapa lama dana deposit masuk?'), findsOneWidget);
    expect(detail?.categoryName, 'Dana');
    expect(detail?.topic, 'funds');
    expect(detail?.updatedLabel, isNull);
    expect(find.text('Suara false'), findsOneWidget);
    feedback!.onVote!(true);
    await tester.pumpAndSettle();
    expect(find.text('Suara true'), findsOneWidget);
  });
}
