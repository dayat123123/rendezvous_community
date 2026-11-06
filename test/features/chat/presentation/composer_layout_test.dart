import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

Future<Rect> _fieldRect(WidgetTester tester, VisualDensity density) async {
  useScreen(tester, const Size(480, 800));
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(visualDensity: density),
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(
            chat: FakeChatRepository(rooms: [directRoom()], members: directMembers()),
          ),
          child: const CommunityChatRoom(roomId: 'dm'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return tester.getRect(find.byType(TextField));
}

void main() {
  testWidgets('the message input keeps its height and centring when the app uses compact density', (tester) async {
    final standard = await _fieldRect(tester, VisualDensity.standard);
    final compact = await _fieldRect(tester, VisualDensity.compact);

    expect(compact.height, standard.height);
    expect(compact.height, greaterThanOrEqualTo(48));
    final attach = tester.getRect(find.byIcon(Icons.add_photo_alternate_outlined));
    expect((compact.center.dy - attach.center.dy).abs(), lessThanOrEqualTo(1));
  });
}
