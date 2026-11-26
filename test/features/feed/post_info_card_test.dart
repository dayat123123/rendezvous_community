import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/models/post_info_card_model.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';

import '../../support/fakes.dart';

Map<String, Object?> _document({int version = 1, List<Object?>? blocks, String? badge = 'Ringkasan otomatis'}) => {
  'version': version,
  'badge': ?badge,
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

Map<String, Object?> _research({Object? document}) => {
  'type': 'card',
  'source': 'research',
  'research_id': 'rs-1',
  'kind': 'financial_report',
  'stock_code': 'BBCA',
  'document': document ?? _document(),
};

Map<String, Object?> _manual({Object? document}) => {
  'type': 'card',
  'source': 'manual',
  'research_id': 'ignored',
  'kind': 'ignored',
  'document': document ?? _document(badge: null),
};

Post _post({PostInfoCard? card}) => Post(
  id: 'p-1',
  author: alice,
  body: 'BBCA laba bersih kuartal III naik 9,0% YoY (teks polos).',
  card: card,
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
    test('reads a research card and its blocks in order', () {
      final card = infoCardFromAttachments([
        {'type': 'stock', 'code': 'BBCA'},
        _research(),
      ])!;

      expect(card.source, InfoCardSource.research);
      expect(card.researchId, 'rs-1');
      expect(card.kind, 'financial_report');
      expect(card.stockCode, 'BBCA');
      final doc = card.document;
      expect(doc.badge, 'Ringkasan otomatis');
      expect(doc.title, 'Laporan Keuangan Kuartal III 2026');
      expect(doc.subtitle, 'PT Bank Central Asia Tbk. · Belum diaudit');
      expect(doc.headline, 'Laba bersih kuartal III naik 9,0% YoY');
      expect(doc.disclaimer, startsWith('Diolah otomatis'));
      expect(doc.blocks, hasLength(5));
      expect(doc.blocks[0], isA<InfoCardParagraph>());
      final metrics = doc.blocks[1] as InfoCardMetrics;
      expect(metrics.metrics, hasLength(3));
      expect(metrics.metrics[0].trend, InfoCardTrend.up);
      expect(metrics.metrics[1].trend, InfoCardTrend.down);
      expect(metrics.metrics[2].trend, isNull);
      expect(metrics.metrics[2].change, isNull);
      final numbered = doc.blocks[2] as InfoCardList;
      expect(numbered.numbered, isTrue);
      expect(numbered.items, ['Pendapatan bunga bersih Rp22,54 T.', 'Kredit Rp1.039,44 T.']);
      expect((doc.blocks[3] as InfoCardList).numbered, isFalse);
      final callout = doc.blocks[4] as InfoCardCallout;
      expect(callout.title, 'Poin utama');
      expect(callout.text, 'Beban cadangan kerugian turun 49,1% YoY.');
    });

    test('manual cards have no research id, kind or badge', () {
      final card = infoCardFromAttachments([_manual()])!;

      expect(card.source, InfoCardSource.manual);
      expect(card.researchId, isNull);
      expect(card.kind, isNull);
      expect(card.stockCode, isNull);
      expect(card.document.badge, isNull);
      expect(card.document.headline, 'Laba bersih kuartal III naik 9,0% YoY');
    });

    test('the old research type is not a card', () {
      expect(infoCardFromAttachments([_research()..['type'] = 'research']), isNull);
    });

    test('unsupported versions, broken documents and plain posts give no card', () {
      expect(infoCardFromAttachments([_research(document: _document(version: 2))]), isNull);
      expect(infoCardFromAttachments([_research(document: 'oops')]), isNull);
      expect(
        infoCardFromAttachments(const [
          {'type': 'stock', 'code': 'BBCA'},
        ]),
        isNull,
      );
      expect(infoCardFromAttachments(null), isNull);
      expect(
        infoCardFromAttachments([
          _research(document: {'version': 1, 'blocks': const []}),
        ]),
        isNull,
      );
    });

    test('at most 20 blocks are kept', () {
      final card = infoCardFromAttachments([
        _research(
          document: _document(
            blocks: [
              for (var i = 0; i < 25; i++) {'type': 'paragraph', 'text': 'p$i'},
            ],
          ),
        ),
      ])!;
      expect(card.document.blocks, hasLength(20));
    });

    test('feed rows carry the card while other attachments stay the same', () {
      final post = FeedPostModel.fromJson({
        'id': 'p-1',
        'author_id': 'u-1',
        'author_username': 'olt_research',
        'body': 'teks polos',
        'attachments': [
          {'path': 'posts/u-1/a.jpg', 'mime': 'image/jpeg'},
          _research(),
        ],
        'created_at': '2026-11-26T03:00:00Z',
      }).toEntity();

      expect(post.attachments, hasLength(1));
      expect(post.card?.document.headline, 'Laba bersih kuartal III naik 9,0% YoY');
      expect(post.card, infoCardFromAttachments([_research()]));
    });
  });

  group('card', () {
    final research = infoCardFromAttachments([_research()])!;
    final manual = infoCardFromAttachments([_manual()])!;

    testWidgets('replaces the plain body in the post card', (tester) async {
      await _pump(
        tester,
        PostCard(
          post: _post(card: research),
          onLike: () {},
          expanded: true,
        ),
      );

      expect(find.byType(CommunityInfoCard), findsOneWidget);
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

    testWidgets('a manual card without a badge still renders', (tester) async {
      await _pump(
        tester,
        PostCard(
          post: _post(card: manual),
          onLike: () {},
          expanded: true,
        ),
      );

      expect(find.byType(CommunityInfoCard), findsOneWidget);
      expect(find.text('Ringkasan otomatis'), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
      expect(find.text('Laba bersih kuartal III naik 9,0% YoY'), findsOneWidget);
      expect(find.textContaining('teks polos'), findsNothing);
    });

    testWidgets('posts without a card keep their body', (tester) async {
      await _pump(tester, PostCard(post: _post(), onLike: () {}, expanded: true));

      expect(find.byType(CommunityInfoCard), findsNothing);
      expect(find.textContaining('teks polos'), findsOneWidget);
    });

    testWidgets('the card starts collapsed in the feed and expands on tap', (tester) async {
      await _pump(tester, CommunityInfoCard(card: research));

      expect(find.text('Laba bersih kuartal III naik 9,0% YoY'), findsOneWidget);
      expect(find.text('Poin utama'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('info-card-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Poin utama'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('info-card-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Poin utama'), findsNothing);
    });

    testWidgets('apps can restyle the card through the feed builders', (tester) async {
      CommunityInfoCardDetails? seen;
      await _pump(
        tester,
        CommunityFeedBuildersScope(
          builders: CommunityFeedBuilders(
            infoCard: (context, d, fallback) {
              seen = d;
              return Text('custom ${d.card.document.headline}');
            },
          ),
          child: PostCard(
            post: _post(card: research),
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
