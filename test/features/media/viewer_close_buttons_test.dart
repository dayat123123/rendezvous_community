import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/help_attachments.dart';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: communityLocalizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets('the help image page closes from the right like the image viewer', (tester) async {
    await tester.pumpWidget(
      _app(
        HelpImagePage(
          attachment: HelpAttachment(
            path: '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png',
            url: Uri.parse(
              'https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png',
            ),
            name: 'Chart tab example',
            kind: HelpAttachmentKind.image,
          ),
        ),
      ),
    );
    await tester.pump();

    final close = find.byTooltip('Close');
    expect(close, findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(tester.getCenter(close).dx, greaterThan(tester.getCenter(find.text('Chart tab example')).dx));
    expect(tester.widget<Text>(find.text('Chart tab example')).style?.color, Colors.white);
  });

  testWidgets('the video page puts open in player just left of close, on the right', (tester) async {
    await tester.pumpWidget(
      _app(
        CommunityVideoPlayerPage(
          uri: Uri.parse('https://api.test/v.mp4'),
          title: 'tutorial.mp4',
          onOpenExternal: () async => true,
        ),
      ),
    );
    await tester.pump();

    final close = find.byTooltip('Close');
    final external = find.byTooltip('Open in video player');
    expect(close, findsOneWidget);
    expect(external, findsOneWidget);
    final title = tester.getCenter(find.text('tutorial.mp4')).dx;
    final externalX = tester.getCenter(external).dx;
    final closeX = tester.getCenter(close).dx;
    expect(externalX, greaterThan(title));
    expect(closeX, greaterThan(externalX));
    expect(tester.widget<Text>(find.text('tutorial.mp4')).style?.color, Colors.white);
  });
}
