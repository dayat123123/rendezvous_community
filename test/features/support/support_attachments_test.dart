import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/video_attachments.dart';

import '../../support/attachment_fixtures.dart';
import '../../support/fakes.dart';

const _video = Attachment(
  path: 'rooms/r-cs/u-1/v.mp4',
  bucket: 'cs-videos',
  mime: 'video/mp4',
  name: 'rekaman layar.mp4',
  size: 3400000,
  duration: 42.4,
  width: 1280,
  height: 720,
  thumbnail: 'rooms/r-cs/u-1/v.jpg',
);

Attachment _doc(String name, String mime, int size) =>
    Attachment(path: 'rooms/r-cs/a-1/$name', bucket: 'cs-documents', mime: mime, name: name, size: size);

final _documents = [
  _doc('Formulir.pdf', 'application/pdf', 182000),
  _doc('Surat Kuasa.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 24000),
  _doc('Mutasi.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 51200),
  _doc('Panduan.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 2400000),
  _doc('transaksi.csv', 'text/csv', 900),
  _doc('catatan.txt', 'text/plain', 2048),
];

class _Media extends Fake implements MediaRepository {
  final uploads = <(CommunityAttachmentKind, String, String)>[];
  Completer<void>? gate;
  Object? failure;

  @override
  Future<Uri> documentUri(Attachment attachment) async => Uri.parse('https://api.test/sign/${attachment.path}');

  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) => Completer<AuthorizedImage>().future;

  @override
  Future<Attachment> uploadSupportFile(
    String roomId,
    Uint8List bytes, {
    required String name,
    required CommunityAttachmentKind kind,
    required CommunityAttachmentFormat format,
  }) async {
    uploads.add((kind, name, format.mime));
    await gate?.future;
    final error = failure;
    if (error != null) throw error;
    return Attachment(
      path: 'rooms/$roomId/u-1/x.${format.extension}',
      bucket: kind == CommunityAttachmentKind.video ? 'cs-videos' : 'cs-documents',
      mime: format.mime,
      name: name,
      size: bytes.length,
    );
  }
}

Widget _app(Widget child, {MediaRepository? media, ChatRepository? chat, Locale locale = const Locale('id')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(chat: chat, mediaRepository: media),
          child: child,
        ),
      ),
    );

FakeChatRepository _chat({List<ChatMessage> messages = const []}) {
  final now = DateTime.now().toUtc();
  return FakeChatRepository(
    rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, name: 'CS OLT', createdAt: now, lastReadAt: now)],
    members: [RoomMember(user: me, lastReadAt: now, lastDeliveredAt: now, joinedAt: now)],
    messages: messages,
  );
}

XFile _picked(String name, {int size = 256}) => XFile.fromData(Uint8List(size), name: name, path: name, length: size);

void main() {
  final policy = CommunityAttachmentPolicy.fromJson(serverPolicy());

  group('composer', () {
    testWidgets('offers the server formats and stages documents and videos', (tester) async {
      final chat = _chat();
      List<XTypeGroup>? offered;
      await tester.pumpWidget(
        _app(
          CommunityChatRoom(
            roomId: 'r-cs',
            repository: chat,
            composer: MessageComposer(
              allowDocuments: true,
              attachmentPolicy: policy,
              openFilesPicker: ({acceptedTypeGroups = const [], initialDirectory, confirmButtonText}) async {
                offered = acceptedTypeGroups;
                return [_picked('Surat Kuasa.docx'), _picked('rekaman.mp4'), _picked('virus.exe')];
              },
            ),
          ),
          chat: chat,
          media: _Media(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Lampirkan foto, video, atau dokumen'));
      await tester.pumpAndSettle();

      expect([for (final g in offered!) g.label], ['Foto', 'Video', 'Dokumen']);
      expect(find.text('Surat Kuasa.docx'), findsOneWidget);
      expect(find.text('rekaman.mp4'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
      expect(find.textContaining('virus.exe tidak bisa dikirim'), findsOneWidget);
      await chat.dispose();
    });

    testWidgets('an old server keeps the images and PDF picker', (tester) async {
      final chat = _chat();
      List<XTypeGroup>? offered;
      await tester.pumpWidget(
        _app(
          CommunityChatRoom(
            roomId: 'r-cs',
            repository: chat,
            composer: MessageComposer(
              allowDocuments: true,
              openFilesPicker: ({acceptedTypeGroups = const [], initialDirectory, confirmButtonText}) async {
                offered = acceptedTypeGroups;
                return const [];
              },
            ),
          ),
          chat: chat,
          media: _Media(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Lampirkan gambar atau PDF'));
      await tester.pumpAndSettle();

      expect(offered!.last.extensions, ['pdf']);
      expect(offered!.any((g) => g.extensions?.contains('mp4') ?? false), isFalse);
      await chat.dispose();
    });

    testWidgets('shows the checking state while the media service scans the file', (tester) async {
      final chat = _chat();
      final media = _Media()..gate = Completer<void>();
      await tester.pumpWidget(
        _app(
          CommunityChatRoom(
            roomId: 'r-cs',
            repository: chat,
            composer: MessageComposer(
              allowDocuments: true,
              attachmentPolicy: policy,
              openFilesPicker: ({acceptedTypeGroups = const [], initialDirectory, confirmButtonText}) async => [
                _picked('Mutasi.xlsx'),
              ],
            ),
          ),
          chat: chat,
          media: media,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Lampirkan foto, video, atau dokumen'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Kirim'));
      await tester.pump();

      expect(find.text('Memeriksa file…'), findsOneWidget);
      expect(media.uploads.single, (
        CommunityAttachmentKind.document,
        'Mutasi.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ));

      media.gate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Memeriksa file…'), findsNothing);
      expect(chat.sentAttachments.single.single.mime, startsWith('application/vnd.openxmlformats'));
      await chat.dispose();
    });

    for (final (code, text) in [
      ('malware_detected', 'File ditolak karena pemindai antivirus mendeteksi isi berbahaya.'),
      ('video_too_long', 'Video terlalu panjang. Potong videonya, lalu kirim lagi.'),
      ('office_macro', 'Dokumen berisi makro dan ditolak demi keamanan.'),
    ]) {
      testWidgets('explains the $code upload error', (tester) async {
        final chat = _chat();
        final media = _Media()..failure = CommunityException(CommunityErrorKind.invalidInput, code: code);
        await tester.pumpWidget(
          _app(
            CommunityChatRoom(
              roomId: 'r-cs',
              repository: chat,
              composer: MessageComposer(
                allowDocuments: true,
                attachmentPolicy: policy,
                openFilesPicker: ({acceptedTypeGroups = const [], initialDirectory, confirmButtonText}) async => [
                  _picked(code == 'video_too_long' ? 'panjang.mp4' : 'Laporan.docx'),
                ],
              ),
            ),
            chat: chat,
            media: media,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Lampirkan foto, video, atau dokumen'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Kirim'));
        await tester.pumpAndSettle();

        expect(find.textContaining(text), findsOneWidget);
        expect(chat.sentAttachments, isEmpty);
        await chat.dispose();
      });
    }
  });

  group('document cards', () {
    testWidgets('show the type, name, and size of each office format', (tester) async {
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: DocumentAttachments(attachments: _documents, color: Colors.black),
          ),
          media: _Media(),
        ),
      );

      expect(find.text('PDF · 178 KB'), findsOneWidget);
      expect(find.text('Word · 23 KB'), findsOneWidget);
      expect(find.text('Excel · 50 KB'), findsOneWidget);
      expect(find.text('PowerPoint · 2.3 MB'), findsOneWidget);
      expect(find.text('CSV · 900 B'), findsOneWidget);
      expect(find.text('Teks · 2 KB'), findsOneWidget);
      for (final icon in [
        Icons.picture_as_pdf_outlined,
        Icons.article_outlined,
        Icons.table_chart_outlined,
        Icons.slideshow_outlined,
        Icons.grid_on_outlined,
        Icons.notes_outlined,
      ]) {
        expect(find.byIcon(icon), findsOneWidget);
      }
    });

    testWidgets('tapping a Word card opens the signed URL', (tester) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        _app(
          DocumentAttachments(
            attachments: [_documents[1]],
            color: Colors.black,
            onOpen: (uri) async {
              opened.add(uri);
              return true;
            },
          ),
          media: _Media(),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Buka Surat Kuasa.docx'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse('https://api.test/sign/rooms/r-cs/a-1/Surat Kuasa.docx')]);
    });

    testWidgets('the document builder receives the type', (tester) async {
      await tester.pumpWidget(
        _app(
          CommunityFeedBuildersScope(
            builders: CommunityFeedBuilders(document: (context, d, fallback) => Text('${d.type.name}:${d.typeLabel}')),
            child: DocumentAttachments(attachments: [_documents[2]], color: Colors.black),
          ),
          media: _Media(),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('excel:Excel'), findsOneWidget);
    });
  });

  group('video bubble', () {
    testWidgets('shows the duration and plays in the app where video_player works', (tester) async {
      final played = <Uri>[];
      await tester.pumpWidget(
        _app(
          VideoAttachments(
            attachments: const [_video],
            color: Colors.black,
            playsInApp: true,
            onPlay: (context, video, uri) async => played.add(uri),
          ),
          media: _Media(),
        ),
      );
      await tester.pump();

      expect(find.text('0:42'), findsOneWidget);
      expect(find.text('3.2 MB'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Putar video 0:42'));
      await tester.pumpAndSettle();

      expect(played, [Uri.parse('https://api.test/sign/rooms/r-cs/u-1/v.mp4')]);
    });

    testWidgets('on Windows the video is downloaded and opened in the system player', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final external = <Uri>[];
      await tester.pumpWidget(
        _app(
          VideoAttachments(
            attachments: const [_video],
            color: Colors.black,
            onPlay: (context, video, uri) async => fail('must not play in the app'),
            onOpenExternal: (uri) async {
              external.add(uri);
              return true;
            },
          ),
          media: _Media(),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Putar video 0:42'));
      await tester.pumpAndSettle();

      expect(external, [Uri.parse('https://api.test/sign/rooms/r-cs/u-1/v.mp4')]);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a failed system player opening is explained', (tester) async {
      await tester.pumpWidget(
        _app(
          VideoAttachments(
            attachments: const [_video],
            color: Colors.black,
            playsInApp: false,
            onOpenExternal: (uri) async => false,
          ),
          media: _Media(),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Putar video 0:42'));
      await tester.pumpAndSettle();

      expect(find.text('Video tidak bisa dibuka. Coba lagi.'), findsOneWidget);
    });

    testWidgets('the video builder replaces the bubble', (tester) async {
      await tester.pumpWidget(
        _app(
          CommunityChatBuildersScope(
            builders: CommunityChatBuilders(
              video: (context, d, fallback) => Text('${d.name} ${d.durationLabel} ${d.duration?.inSeconds}'),
            ),
            child: const VideoAttachments(attachments: [_video], color: Colors.black),
          ),
          media: _Media(),
        ),
      );

      expect(find.text('rekaman layar.mp4 0:42 42'), findsOneWidget);
    });

    testWidgets('the player explains when the video cannot start and offers the system player', (tester) async {
      var external = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: CommunityLocalizations.localizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: CommunityVideoPlayerPage(
            uri: Uri.parse('https://api.test/v.mp4'),
            title: 'rekaman.mp4',
            onOpenExternal: () async {
              external++;
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Video tidak bisa diputar di sini'), findsOneWidget);
      await tester.tap(find.text('Buka di pemutar video'));
      await tester.pumpAndSettle();
      expect(external, 1);
    });
  });

  testWidgets('a support chat shows videos and documents in the bubbles', (tester) async {
    final now = DateTime.now().toUtc();
    final chat = _chat(
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'r-cs',
          senderId: me.id,
          sender: me,
          attachments: [_video, _documents[1]],
          createdAt: now,
        ),
      ],
    );
    await tester.pumpWidget(
      _app(
        CommunityChatRoom(
          roomId: 'r-cs',
          repository: chat,
          composer: MessageComposer(allowDocuments: true, attachmentPolicy: policy),
        ),
        chat: chat,
        media: _Media(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0:42'), findsOneWidget);
    expect(find.text('Surat Kuasa.docx'), findsOneWidget);
    expect(find.text('Word · 23 KB'), findsOneWidget);
    await chat.dispose();
  });

  group('file opener decisions', () {
    test('desktop platforms download first, mobile and web open the link', () {
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.windows, web: false), isTrue);
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.linux, web: false), isTrue);
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.macOS, web: false), isTrue);
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.android, web: false), isFalse);
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.iOS, web: false), isFalse);
      expect(communityOpensDownloadedFiles(platform: TargetPlatform.windows, web: true), isFalse);
    });

    test('video plays in the app on Android, iOS, macOS, and web only', () {
      expect(communityVideoPlaysInApp(platform: TargetPlatform.android, web: false), isTrue);
      expect(communityVideoPlaysInApp(platform: TargetPlatform.iOS, web: false), isTrue);
      expect(communityVideoPlaysInApp(platform: TargetPlatform.macOS, web: false), isTrue);
      expect(communityVideoPlaysInApp(platform: TargetPlatform.windows, web: true), isTrue);
      expect(communityVideoPlaysInApp(platform: TargetPlatform.windows, web: false), isFalse);
      expect(communityVideoPlaysInApp(platform: TargetPlatform.linux, web: false), isFalse);
    });

    test('videoDurationLabel formats minutes and hours', () {
      expect(videoDurationLabel(5), '0:05');
      expect(videoDurationLabel(119.6), '2:00');
      expect(videoDurationLabel(3725), '1:02:05');
      expect(videoDurationLabel(null), '');
    });
  });
}
