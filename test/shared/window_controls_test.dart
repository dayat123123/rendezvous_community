import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/help_attachments.dart';

Widget _app(Widget home, Size controls) => CommunityWindowControls(
  size: controls,
  child: MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: communityLocalizationsDelegates,
    supportedLocales: CommunityLocalizations.supportedLocales,
    home: home,
  ),
);

final _help = HelpImagePage(
  attachment: HelpAttachment(
    path: '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png',
    url: Uri.parse('https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png'),
    name: 'Chart tab example',
    kind: HelpAttachmentKind.image,
  ),
);

final _video = CommunityVideoPlayerPage(uri: Uri.parse('https://api.test/v.mp4'), title: 'tutorial.mp4');

void main() {
  test('window controls default to nothing reserved', () {
    expect(const CommunityWindowControls(size: Size(80, 30), child: SizedBox()).size, const Size(80, 30));
  });

  for (final (name, page, title) in [('help image', _help, 'Chart tab example'), ('video', _video, 'tutorial.mp4')]) {
    testWidgets('the $name page title sits below the window controls', (tester) async {
      await tester.pumpWidget(_app(page, const Size(80, 30)));
      await tester.pump();
      expect(tester.getRect(find.text(title)).top, greaterThanOrEqualTo(30));
      expect(tester.getRect(find.byTooltip('Close')).top, greaterThanOrEqualTo(30));
    });

    testWidgets('the $name page keeps its usual top without window controls', (tester) async {
      await tester.pumpWidget(_app(page, Size.zero));
      await tester.pump();
      expect(tester.getRect(find.text(title)).top, lessThan(30));
    });
  }
}
