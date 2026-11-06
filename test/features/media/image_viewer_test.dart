import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/image_viewer.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class _Media extends Fake implements MediaRepository {
  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) async =>
      AuthorizedImage('https://img.test/${attachment.path}', const {});
}

class _InfoChat extends FakeChatRepository implements MessageInfoRepository {
  _InfoChat({super.rooms, super.members, super.messages});

  @override
  Future<MessageInfo> getMessageInfo(String messageId) async =>
      MessageInfo(messageId: messageId, sentAt: DateTime.now().toUtc());
}

const _photos = [
  Attachment(path: 'rooms/dm/u-me/a.png', bucket: 'attachments', mime: 'image/png'),
  Attachment(path: 'rooms/dm/u-me/b.png', bucket: 'attachments', mime: 'image/png'),
];

ChatMessage _photoMessage() => ChatMessage(
  id: 'p-1',
  roomId: 'dm',
  senderId: me.id,
  sender: me,
  body: 'Bukti transfer',
  attachments: _photos,
  createdAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
);

CommunityImageLoader _loader() => CommunityImageLoader(client: MockClient((_) async => http.Response.bytes(_png, 200)));

Future<void> _pump(WidgetTester tester, ChatRepository chat) async {
  useScreen(tester, const Size(900, 900));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityImageScope(
          loader: _loader(),
          child: CommunityScope(
            dependencies: FakeDependencies(chat: chat, mediaRepository: _Media()),
            child: const CommunityChatRoom(roomId: 'dm'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _photoTiles() => find.bySemanticsLabel('Lihat gambar');

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  testWidgets('tapping a photo in a chat bubble opens a full-screen viewer that pages and closes with Esc', (
    tester,
  ) async {
    await _pump(
      tester,
      FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: [_photoMessage()]),
    );

    await tester.tap(_photoTiles().first);
    await _settle(tester);
    expect(find.text('1 dari 2'), findsOneWidget);
    expect(find.byTooltip('Unduh'), findsOneWidget);
    expect(find.byTooltip('Gambar sebelumnya'), findsNothing);

    await tester.tap(find.byTooltip('Gambar berikutnya'));
    await _settle(tester);
    expect(find.text('2 dari 2'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await _settle(tester);
    expect(find.text('1 dari 2'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.byTooltip('Unduh'), findsNothing);
  });

  testWidgets('download saves the original image bytes with an image file name', (tester) async {
    await _pump(tester, FakeChatRepository(rooms: [directRoom()], members: directMembers()));
    final saved = <(String, String, int)>[];
    final context = tester.element(find.byType(CommunityChatRoom));
    unawaited(
      showCommunityImageViewer(
        context,
        images: _photos,
        initialIndex: 1,
        saver: (context, bytes, {required name, required mimeType}) async {
          saved.add((name, mimeType, bytes.length));
          return true;
        },
      ),
    );
    await _settle(tester);
    expect(find.text('2 dari 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Unduh'));
    await _settle(tester);

    expect(saved, hasLength(1));
    expect(saved.single.$1, matches(RegExp(r'^chat-image-\d{8}-\d{6}\.png$')));
    expect(saved.single.$2, 'image/png');
    expect(saved.single.$3, _png.length);
    expect(find.text('Gambar disimpan'), findsOneWidget);
  });

  testWidgets('message info shows the photos of the message and opens them in the viewer', (tester) async {
    await _pump(tester, _InfoChat(rooms: [directRoom()], members: directMembers(), messages: [_photoMessage()]));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Bukti transfer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lainnya').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Info pesan'));
    await tester.pumpAndSettle();

    final info = find.byType(Dialog);
    expect(find.descendant(of: info, matching: _photoTiles()), findsNWidgets(2));
    expect(find.descendant(of: info, matching: find.text('Bukti transfer')), findsOneWidget);

    await tester.tap(find.descendant(of: info, matching: _photoTiles()).last);
    await _settle(tester);
    expect(find.text('2 dari 2'), findsOneWidget);
  });
}
