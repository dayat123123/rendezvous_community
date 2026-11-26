import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/models/post_research_model.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';

import '../../support/fakes.dart';

Map<String, Object?> _document({int version = 1, List<Object?>? blocks}) => {
  'version': version,
  'badge': 'Ringkasan otomatis',
  'title': 'Laporan Keuangan Kuartal III 2026',
  'subtitle': 'PT Bank Central Asia Tbk. · Belum diaudit',
  'headline': 'Laba bersih kuartal III naik 9,0% YoY',
  'blocks':
      blocks ??
      [
        {'type': 'paragraph', 'text': 'BBCA membukukan laba bersih kuartal III Rp15,68 T.'},
        {
          'type': 'metrics',
          'metrics': [
            {'label': 'Laba bersih kuartal III', 'value': 'Rp15,68 T', 'change': '+9,0% YoY', 'trend': 'up'},
            {'label': 'ROE disetahunkan', 'value': '21,3%', 'change': 'tahun lalu 21,5%', 'trend': 'down'},
            {'label': 'Kredit', 'value': 'Rp1.039,44 T'},
            {'value': 'tanpa label'},
          ],
        },
        {
          'type': 'chart',
          'points': [1, 2, 3],
        },
        {
          'type': 'list',
          'style': 'numbered',
          'items': ['Pendapatan bunga bersih Rp22,54 T.', 'Kredit Rp1.039,44 T.', 7],
        },
        {
          'type': 'list',
          'style': 'bulleted',
          'items': ['CASA 85,3%.'],
        },
        {'type': 'callout', 'title': 'Poin utama', 'text': 'Beban cadangan kerugian turun 49,1% YoY.'},
      ],
  'disclaimer': 'Diolah otomatis dari laporan keuangan emiten. Bukan rekomendasi investasi.',
  'future_field': true,
};

Map<String, Object?> _element({Object? document}) => {
  'type': 'research',
  'research_id': 'rs-1',
  'kind': 'financial_report',
  'stock_code': 'BBCA',
  'document': document ?? _document(),
};

Post _post({PostResearch? research}) => Post(
  id: 'p-1',
  author: alice,
  body: 'BBCA laba bersih kuartal III naik 9,0% YoY (teks polos).',
  research: research,
  createdAt: now,
  cursor: 'c',
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(),
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('parsing', () {
    test('reads the research element and its blocks in order', () {
      final research = researchFromAttachments([
        {'type': 'stock', 'code': 'BBCA'},
        _element(),
      ])!;

      expect(research.id, 'rs-1');
      expect(research.kind, 'financial_report');
      expect(research.stockCode, 'BBCA');
      final doc = research.document;
      expect(doc.badge, 'Ringkasan otomatis');
      expect(doc.title, 'Laporan Keuangan Kuartal III 2026');
      expect(doc.subtitle, 'PT Bank Central Asia Tbk. · Belum diaudit');
      expect(doc.headline, 'Laba bersih kuartal III naik 9,0% YoY');
      expect(doc.disclaimer, startsWith('Diolah otomatis'));
      expect(doc.blocks, hasLength(5));
      expect(doc.blocks[0], isA<ResearchParagraph>());
      final metrics = doc.blocks[1] as ResearchMetrics;
      expect(metrics.metrics, hasLength(3));
      expect(metrics.metrics[0].trend, ResearchTrend.up);
      expect(metrics.metrics[1].trend, ResearchTrend.down);
      expect(metrics.metrics[2].trend, isNull);
      expect(metrics.metrics[2].change, isNull);
      final numbered = doc.blocks[2] as ResearchList;
      expect(numbered.numbered, isTrue);
      expect(numbered.items, ['Pendapatan bunga bersih Rp22,54 T.', 'Kredit Rp1.039,44 T.']);
      expect((doc.blocks[3] as ResearchList).numbered, isFalse);
      final callout = doc.blocks[4] as ResearchCallout;
      expect(callout.title, 'Poin utama');
      expect(callout.text, 'Beban cadangan kerugian turun 49,1% YoY.');
    });

    test('unsupported versions, broken documents and plain posts give no card', () {
      expect(researchFromAttachments([_element(document: _document(version: 2))]), isNull);
      expect(researchFromAttachments([_element(document: 'oops')]), isNull);
      expect(researchFromAttachments([_element(document: _document(blocks: const []))..['document'] = null]), isNull);
      expect(
        researchFromAttachments(const [
          {'type': 'stock', 'code': 'BBCA'},
        ]),
        isNull,
      );
      expect(researchFromAttachments(null), isNull);
      expect(
        researchFromAttachments([
          _element(document: {'version': 1, 'blocks': const []}),
        ]),
        isNull,
      );
    });

    test('at most 20 blocks are kept', () {
      final research = researchFromAttachments([
        _element(
          document: _document(
            blocks: [
              for (var i = 0; i < 25; i++) {'type': 'paragraph', 'text': 'p$i'},
            ],
          ),
        ),
      ])!;
      expect(research.document.blocks, hasLength(20));
    });

    test('feed rows carry the research while other attachments stay the same', () {
      final post = FeedPostModel.fromJson({
        'id': 'p-1',
        'author_id': 'u-1',
        'author_username': 'olt_research',
        'body': 'teks polos',
        'attachments': [
          {'path': 'posts/u-1/a.jpg', 'mime': 'image/jpeg'},
          _element(),
        ],
        'created_at': '2026-11-26T03:00:00Z',
      }).toEntity();

      expect(post.attachments, hasLength(1));
      expect(post.research?.document.headline, 'Laba bersih kuartal III naik 9,0% YoY');
      expect(post.research, researchFromAttachments([_element()]));
    });
  });

  group('card', () {
    final research = researchFromAttachments([_element()])!;

    testWidgets('replaces the plain body in the post card', (tester) async {
      await _pump(
        tester,
        PostCard(
          post: _post(research: research),
          onLike: () {},
          expanded: true,
        ),
      );

      expect(find.byType(CommunityResearchCard), findsOneWidget);
      expect(find.textContaining('teks polos'), findsNothing);
      expect(find.text('Laba bersih kuartal III naik 9,0% YoY'), findsOneWidget);
      expect(find.text('Ringkasan otomatis'), findsOneWidget);
      expect(find.text('Rp15,68 T'), findsOneWidget);
      expect(find.text('+9,0% YoY'), findsOneWidget);
      expect(find.text('Poin utama'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.textContaining('Bukan rekomendasi investasi'), findsOneWidget);
    });

    testWidgets('posts without research keep their body', (tester) async {
      await _pump(tester, PostCard(post: _post(), onLike: () {}, expanded: true));

      expect(find.byType(CommunityResearchCard), findsNothing);
      expect(find.textContaining('teks polos'), findsOneWidget);
    });

    testWidgets('the card starts collapsed in the feed and expands on tap', (tester) async {
      await _pump(tester, CommunityResearchCard(research: research));

      expect(find.text('Laba bersih kuartal III naik 9,0% YoY'), findsOneWidget);
      expect(find.text('Poin utama'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('research-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Poin utama'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('research-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Poin utama'), findsNothing);
    });

    testWidgets('apps can restyle the card through the feed builders', (tester) async {
      CommunityResearchDetails? seen;
      await _pump(
        tester,
        CommunityFeedBuildersScope(
          builders: CommunityFeedBuilders(
            researchCard: (context, d, fallback) {
              seen = d;
              return Text('custom ${d.research.document.headline}');
            },
          ),
          child: PostCard(
            post: _post(research: research),
            onLike: () {},
          ),
        ),
      );

      expect(find.text('custom Laba bersih kuartal III naik 9,0% YoY'), findsOneWidget);
      expect(seen?.post.id, 'p-1');
      expect(seen?.initiallyExpanded, isFalse);
      expect(find.textContaining('teks polos'), findsNothing);
    });
  });
}
