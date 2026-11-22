import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/help_fakes.dart';

final _pdf = HelpAttachment(
  path: '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf',
  url: Uri.parse('https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf'),
  name: 'Formulir ganti rekening',
  kind: HelpAttachmentKind.document,
  mime: 'application/pdf',
  size: 204800,
);

final _image = HelpAttachment(
  path: '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png',
  url: Uri.parse('https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png'),
  name: 'Contoh isian',
  kind: HelpAttachmentKind.image,
  size: 102400,
);

final _video = HelpAttachment(
  path: '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e03.mp4',
  url: Uri.parse('https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e03.mp4'),
  name: 'Video panduan',
  kind: HelpAttachmentKind.video,
  size: 20971520,
);

HelpArticle _article(List<HelpAttachment> attachments) => HelpArticle(
  id: 'a-form',
  category: 'account',
  question: 'Bagaimana cara mengganti rekening?',
  answer: 'Unduh formulir di bawah.',
  attachments: attachments,
);

Widget _app(
  FakeHelpRepository help,
  HelpArticle article, {
  CommunityHelpAttachmentOpener? onOpen,
  CommunityHelpBuilders builders = const CommunityHelpBuilders(),
  Locale locale = const Locale('id'),
}) {
  help.content = HelpCenterContent(
    categories: [
      HelpCategory(code: 'account', name: 'Akun', articles: [article]),
    ],
  );
  return MaterialApp(
    locale: locale,
    localizationsDelegates: communityLocalizationsDelegates,
    supportedLocales: CommunityLocalizations.supportedLocales,
    home: CommunityBuildersScope(
      builders: CommunityBuilders(help: builders),
      child: Scaffold(
        body: CommunityHelpArticleView(article: article, repository: help, onOpenAttachment: onOpen),
      ),
    ),
  );
}

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('an article lists its PDF, image, and video attachments below the answer', (tester) async {
    _tallView(tester);
    final opened = <HelpAttachment>[];
    await tester.pumpWidget(
      _app(
        FakeHelpRepository(),
        _article([_pdf, _image, _video]),
        onOpen: (context, attachment) async {
          opened.add(attachment);
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lampiran'), findsOneWidget);
    expect(find.text('Formulir ganti rekening'), findsOneWidget);
    expect(find.text('PDF · 200 KB'), findsOneWidget);
    expect(find.text('Gambar · 100 KB'), findsOneWidget);
    expect(find.text('Video · 20 MB'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Lampiran')).dy,
      greaterThan(tester.getTopLeft(find.textContaining('Unduh formulir', findRichText: true)).dy),
    );
    expect(
      tester.getTopLeft(find.text('Lampiran')).dy,
      lessThan(tester.getTopLeft(find.text('Apakah ini membantu?')).dy),
    );
    expect(find.bySemanticsLabel('Buka lampiran Video panduan'), findsOneWidget);

    await tester.tap(find.text('Video panduan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Formulir ganti rekening'));
    await tester.pumpAndSettle();
    expect(opened, [_video, _pdf]);
  });

  testWidgets('an attachment that cannot be opened shows a message', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_app(FakeHelpRepository(), _article([_pdf]), onOpen: (context, attachment) async => false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Formulir ganti rekening'));
    await tester.pumpAndSettle();
    expect(find.text('Lampiran tidak bisa dibuka. Coba lagi.'), findsOneWidget);
  });

  testWidgets('an article without attachments shows no attachment section', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_app(FakeHelpRepository(), _article(const [])));
    await tester.pumpAndSettle();

    expect(find.text('Lampiran'), findsNothing);
    expect(find.text('Apakah ini membantu?'), findsOneWidget);
  });

  testWidgets('the attachment builder replaces each tile and keeps the open action', (tester) async {
    _tallView(tester);
    final opened = <String>[];
    await tester.pumpWidget(
      _app(
        FakeHelpRepository(),
        _article([_pdf, _video]),
        onOpen: (context, attachment) async {
          opened.add(attachment.path);
          return true;
        },
        builders: CommunityHelpBuilders(
          attachment: (context, d, fallback) => TextButton(
            onPressed: d.onOpen,
            child: Text('#${d.index} ${d.kind.name} ${d.kindLabel} ${d.url.pathSegments.last}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#0 document PDF 0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf'), findsOneWidget);
    expect(find.text('#1 video Video 0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e03.mp4'), findsOneWidget);
    expect(find.text('Formulir ganti rekening'), findsNothing);
    await tester.tap(find.textContaining('#1 video'));
    await tester.pumpAndSettle();
    expect(opened, [_video.path]);
  });

  testWidgets('English labels', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_app(FakeHelpRepository(), _article([_image]), locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('Image · 100 KB'), findsOneWidget);
    expect(find.bySemanticsLabel('Open attachment Contoh isian'), findsOneWidget);
  });

  testWidgets('an image attachment opens full screen by default', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_app(FakeHelpRepository(), _article([_image])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contoh isian'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Contoh isian'), findsOneWidget);
  });
}
