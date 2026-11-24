import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

AppNotification _notice(String url) => AppNotification(
  id: 'n-1',
  type: NotificationType.announcement,
  payload: {'notice_id': 'nt-1', 'image_url': url},
  createdAt: DateTime.utc(2026, 11, 24),
  cursor: 'c-1',
);

Future<void> _pump(WidgetTester tester, http.Response Function() respond, String url) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CommunityImageScope(
        loader: CommunityImageLoader(client: MockClient((_) async => respond())),
        child: CommunityImagePersistence(
          persist: false,
          child: Center(
            child: CommunityNotificationThumbnail(
              notification: _notice(url),
              margin: const EdgeInsetsDirectional.only(start: 12),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
  await tester.pump();
}

void main() {
  testWidgets('a picture that loads is shown with its margin', (tester) async {
    await _pump(tester, () => http.Response.bytes(_png, 200), 'https://cdn.example.com/ok.png');
    expect(
      find.descendant(of: find.byType(CommunityNotificationThumbnail), matching: find.byType(Image)),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(CommunityNotificationThumbnail)).width, 44 + 12);
  });

  testWidgets('a dead link leaves no box behind', (tester) async {
    await _pump(tester, () => http.Response('', 404), 'https://cdn.example.com/gone.png');
    expect(
      find.descendant(of: find.byType(CommunityNotificationThumbnail), matching: find.byType(Image)),
      findsNothing,
    );
    expect(tester.getSize(find.byType(CommunityNotificationThumbnail)), Size.zero);
  });

  testWidgets('a link that is not a picture leaves no box behind', (tester) async {
    await _pump(
      tester,
      () => http.Response('<html>berita</html>', 200, headers: {'content-type': 'text/html'}),
      'https://news.example.com/artikel',
    );
    expect(tester.getSize(find.byType(CommunityNotificationThumbnail)), Size.zero);
  });
}
