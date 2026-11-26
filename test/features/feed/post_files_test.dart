import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/data/models/post_info_card_model.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';

import '../../support/fakes.dart';

Map<String, Object?> _file(String name, {String mime = 'application/pdf', int? size = 120000, String? path}) => {
  'type': 'file',
  'file': {
    'bucket': 'post-files',
    'path': path ?? 'acc/u-1/$name',
    'name': name,
    'mime': mime,
    'size': ?size,
    'pages': 12,
  },
};

class _Media extends Fake implements MediaRepository {
  final opened = <Attachment>[];

  @override
  Future<Uri> documentUri(Attachment attachment) async {
    opened.add(attachment);
    throw StateError('offline');
  }
}

Post _post(List<Attachment> files) =>
    Post(id: 'p-1', author: alice, body: 'Laporan tahunan sudah terbit.', files: files, createdAt: now, cursor: 'c');

Future<void> _pump(WidgetTester tester, Widget child, {MediaRepository? media}) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(mediaRepository: media),
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('parsing', () {
    test('reads file elements apart from images and keeps at most five', () {
      final files = postFilesFromAttachments([
        {'path': 'posts/u-1/a.jpg', 'mime': 'image/jpeg'},
        _file('Laporan Tahunan 2025.pdf'),
        _file('Data.xlsx', mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', size: null),
        {'type': 'file', 'file': 'oops'},
        {
          'type': 'file',
          'file': {'bucket': 'post-files', 'name': 'no-path.pdf'},
        },
        _file('c.csv', mime: 'text/csv'),
        _file('d.docx', mime: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
        _file('e.pptx', mime: 'application/vnd.openxmlformats-officedocument.presentationml.presentation'),
        _file('f.pdf'),
      ]);

      expect(files.map((f) => f.name), ['Laporan Tahunan 2025.pdf', 'Data.xlsx', 'c.csv', 'd.docx', 'e.pptx']);
      final first = files.first;
      expect(first.bucket, 'post-files');
      expect(first.path, 'acc/u-1/Laporan Tahunan 2025.pdf');
      expect(first.mime, 'application/pdf');
      expect(first.size, 120000);
      expect(first.isDocument, isTrue);
      expect(files[1].size, isNull);
      expect(postFilesFromAttachments(null), isEmpty);
    });

    test('feed rows keep images and files apart', () {
      final post = FeedPostModel.fromJson({
        'id': 'p-1',
        'author_id': 'u-1',
        'author_username': 'olt_research',
        'body': 'teks',
        'attachments': [
          {'path': 'posts/u-1/a.jpg', 'mime': 'image/jpeg'},
          _file('Laporan.pdf'),
        ],
        'created_at': '2026-11-26T03:00:00Z',
      }).toEntity();

      expect(post.attachments.map((a) => a.path), ['posts/u-1/a.jpg']);
      expect(post.files.map((f) => f.name), ['Laporan.pdf']);
    });
  });

  group('post card', () {
    final files = postFilesFromAttachments([
      _file('Laporan Tahunan 2025.pdf'),
      _file('Data.xlsx', mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', size: 2400000),
    ]);

    testWidgets('lists the files under the body with type and size', (tester) async {
      await _pump(tester, PostCard(post: _post(files), onLike: () {}, expanded: true));

      expect(find.byType(CommunityPostFiles), findsOneWidget);
      expect(find.text('Laporan Tahunan 2025.pdf'), findsOneWidget);
      expect(find.text('PDF · 117 KB'), findsOneWidget);
      expect(find.text('Data.xlsx'), findsOneWidget);
      expect(find.textContaining('2.3 MB'), findsOneWidget);
      expect(find.textContaining('Laporan tahunan sudah terbit.'), findsOneWidget);
    });

    testWidgets('post files use the same tile as help center attachments', (tester) async {
      await _pump(tester, PostCard(post: _post(files), onLike: () {}, expanded: true));

      final tiles = find.byType(CommunityFileTile);
      expect(tiles, findsNWidgets(2));
      final pdf = tester.widget<CommunityFileTile>(tiles.first);
      expect(pdf.name, 'Laporan Tahunan 2025.pdf');
      expect(pdf.meta, 'PDF · 117 KB');
      expect(pdf.icon, Icons.picture_as_pdf_outlined);
      expect(tester.widget<CommunityFileTile>(tiles.last).icon, Icons.table_chart_outlined);
    });

    testWidgets('chat documents keep the compact tile', (tester) async {
      await _pump(tester, DocumentAttachments(attachments: files, color: Colors.black));

      expect(find.byType(CommunityFileTile), findsNothing);
      expect(find.text('Laporan Tahunan 2025.pdf'), findsOneWidget);
    });

    testWidgets('a file opens through a signed url from its own bucket', (tester) async {
      final media = _Media();
      await _pump(
        tester,
        PostCard(post: _post(files), onLike: () {}, expanded: true),
        media: media,
      );

      await tester.tap(find.text('Laporan Tahunan 2025.pdf'));
      await tester.pumpAndSettle();

      expect(media.opened.single.bucket, 'post-files');
      expect(media.opened.single.path, 'acc/u-1/Laporan Tahunan 2025.pdf');
    });

    testWidgets('files show under an info card too', (tester) async {
      final card = infoCardFromAttachments([
        {
          'type': 'card',
          'source': 'manual',
          'document': {'version': 1, 'title': 'Ringkasan', 'headline': 'Laba naik'},
        },
      ]);
      await _pump(
        tester,
        PostCard(
          post: _post(files).copyWith(card: card),
          onLike: () {},
          expanded: true,
        ),
      );

      expect(find.byType(CommunityInfoCard), findsOneWidget);
      expect(find.text('Laporan Tahunan 2025.pdf'), findsOneWidget);
    });

    testWidgets('posts without files show no file list', (tester) async {
      await _pump(tester, PostCard(post: _post(const []), onLike: () {}, expanded: true));

      expect(find.byType(CommunityPostFiles), findsOneWidget);
      expect(find.text('PDF · 117 KB'), findsNothing);
    });

    testWidgets('apps can restyle the file list through the feed builders', (tester) async {
      CommunityPostDetails? seen;
      await _pump(
        tester,
        CommunityFeedBuildersScope(
          builders: CommunityFeedBuilders(
            postFiles: (context, d, fallback) {
              seen = d;
              return Text('files ${d.post.files.length}');
            },
          ),
          child: PostCard(post: _post(files), onLike: () {}),
        ),
      );

      expect(find.text('files 2'), findsOneWidget);
      expect(seen?.post.id, 'p-1');
    });
  });
}
