import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class _NoDisk implements ImageDiskCache {
  @override
  Future<Uint8List?> read(String key) async => null;

  @override
  Future<void> write(String key, Uint8List bytes) async {}

  @override
  Future<void> wipe() async {}
}

class _Media extends Fake implements MediaRepository {
  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) async =>
      AuthorizedImage('https://img.test/${attachment.path}', const {});
}

const _photo = Attachment(
  path: 'rooms/dm/u-me/a.png',
  bucket: 'attachments',
  mime: 'image/png',
  width: 1200,
  height: 900,
);

ChatMessage _message(String id, {String? body}) => ChatMessage(
  id: id,
  roomId: 'dm',
  senderId: me.id,
  sender: me,
  body: body,
  attachments: const [_photo],
  createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
);

Future<void> _pump(WidgetTester tester, ChatMessage message) async {
  useScreen(tester, const Size(900, 900));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityImageScope(
          loader: CommunityImageLoader(
            disk: _NoDisk(),
            client: MockClient((_) async => http.Response.bytes(_png, 200)),
          ),
          child: CommunityScope(
            dependencies: FakeDependencies(
              chat: FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: [message]),
              mediaRepository: _Media(),
            ),
            child: const CommunityChatRoom(roomId: 'dm'),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Rect _bubble(WidgetTester tester, String id) => tester.getRect(find.byKey(ValueKey('chat-bubble-$id')));

Rect _image(WidgetTester tester) =>
    tester.getRect(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Lihat gambar'));

void main() {
  testWidgets('a photo fills the bubble edge to edge with the caption below it', (tester) async {
    await _pump(tester, _message('p-1', body: 'Bukti transfer'));
    final bubble = _bubble(tester, 'p-1');
    final image = _image(tester);
    final caption = tester.getRect(find.text('Bukti transfer'));

    expect(image.left, bubble.left);
    expect(image.right, bubble.right);
    expect(image.top, bubble.top);
    expect(caption.top, greaterThanOrEqualTo(image.bottom));
    expect(caption.left, greaterThan(image.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a photo without text shows its time on top of the photo', (tester) async {
    final message = _message('p-2');
    await _pump(tester, message);
    final bubble = _bubble(tester, 'p-2');
    final image = _image(tester);
    final l10n = CommunityLocalizations.of(tester.element(find.byType(CommunityChatRoom)))!;
    final time = tester.getRect(find.text(l10n.clockTime(message.createdAt)));

    expect(image.top, bubble.top);
    expect(image.bottom, bubble.bottom);
    expect(image.contains(time.center), isTrue);
    expect(tester.takeException(), isNull);
  });
}
