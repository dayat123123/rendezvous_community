import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_jump.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

const _longText =
    'Pesan panjang dari Alice yang cukup panjang supaya gelembungnya dibatasi lebar layar dan teksnya turun beberapa baris';

final _png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 13]);

class _Media extends Fake implements MediaRepository {
  final uploads = <String>[];

  @override
  Future<Attachment> uploadChatImage(String roomId, Uint8List bytes, {required String mimeType}) async {
    uploads.add(mimeType);
    return Attachment(path: '$roomId/pasted.png', bucket: 'attachments', mime: mimeType);
  }
}

ChatMessage _message(
  String id,
  int minute,
  UserSummary sender,
  String body, {
  String? replyTo,
  String? replyUser,
  String? replyBody,
}) => ChatMessage(
  id: id,
  roomId: 'dm',
  senderId: sender.id,
  sender: sender,
  body: body,
  replyToId: replyTo,
  replyToSenderUsername: replyUser,
  replyToBody: replyBody,
  createdAt: chatStart.add(Duration(minutes: minute)),
);

FakeChatRepository _chat(List<ChatMessage> messages) =>
    FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: messages);

Future<void> _pumpRoom(WidgetTester tester, ChatRepository chat, {MediaRepository? media, Widget? composer}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(chat: chat, mediaRepository: media),
          child: CommunityChatRoom(roomId: 'dm', composer: composer),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _quote(String text) => find.ancestor(of: find.text(text), matching: find.byType(InkWell));

Future<void> _pressPaste(WidgetTester tester, {bool focus = true}) async {
  if (focus) {
    await tester.tap(find.byType(TextField));
    await tester.pump();
  }
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a reply quote names the quoted sender by display name, and "Anda" for my own message', (tester) async {
    useScreen(tester, const Size(500, 900));
    await _pumpRoom(
      tester,
      _chat([
        _message('a-1', 1, alice, 'Order saya belum masuk'),
        _message(
          'm-1',
          2,
          me,
          'Sudah dicek ya',
          replyTo: 'a-1',
          replyUser: alice.username,
          replyBody: 'Order saya belum masuk',
        ),
        _message('m-2', 3, me, 'Pesan saya sendiri'),
        _message('m-3', 4, me, 'Lanjutan', replyTo: 'm-2', replyUser: me.username, replyBody: 'Pesan saya sendiri'),
        _message('m-4', 5, me, 'Yang lama', replyTo: 'gone', replyUser: 'cs_cs0004'),
      ]),
    );

    expect(find.descendant(of: _quote('Order saya belum masuk'), matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: _quote('Order saya belum masuk'), matching: find.text('@alice')), findsNothing);
    expect(find.descendant(of: _quote('Pesan saya sendiri'), matching: find.text('Anda')), findsOneWidget);
    expect(find.text('@cs_cs0004'), findsOneWidget);
  });

  testWidgets('hovering a message shows its actions without changing the bubble width', (tester) async {
    useScreen(tester, const Size(420, 900));
    await _pumpRoom(tester, _chat([_message('a-1', 1, alice, _longText)]));
    final bubble = find.ancestor(of: find.text(_longText), matching: find.byType(Container)).first;
    final before = tester.getRect(bubble);
    expect(find.byTooltip('Balas pesan').hitTestable(), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text(_longText)));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Balas pesan').hitTestable(), findsOneWidget);
    expect(tester.getRect(bubble), before);
  });

  testWidgets('replying shows a WhatsApp style preview above the input that can be dismissed', (tester) async {
    useScreen(tester, const Size(500, 900));
    await _pumpRoom(tester, _chat([_message('a-1', 1, alice, 'Order saya belum masuk')]));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Order saya belum masuk')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Balas pesan'));
    await tester.pumpAndSettle();

    final composer = find.byType(MessageComposer);
    expect(find.descendant(of: composer, matching: find.text('Alice')), findsOneWidget);
    expect(find.descendant(of: composer, matching: find.text('Order saya belum masuk')), findsOneWidget);

    await tester.tap(find.descendant(of: composer, matching: find.byTooltip('Batal')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: composer, matching: find.text('Alice')), findsNothing);
  });

  testWidgets('tapping a quote scrolls to the original message and highlights it', (tester) async {
    useScreen(tester, const Size(500, 700));
    final history = chatHistory(80);
    final target = history[1];
    await _pumpRoom(
      tester,
      _chat([
        ...history,
        _message(
          'm-last',
          900,
          me,
          'Membalas pesan lama',
          replyTo: target.id,
          replyUser: target.sender!.username,
          replyBody: target.body,
        ),
      ]),
    );
    final anchor = find.byWidgetPredicate((w) => w is MessageAnchor && w.id == target.id);
    expect(anchor.hitTestable(), findsNothing);

    await tester.tap(_quote(target.body!));
    await tester.pumpAndSettle();

    expect(find.descendant(of: anchor, matching: find.text(target.body!)).hitTestable(), findsOneWidget);
    final highlight = tester.widget<AnimatedContainer>(
      find.descendant(of: anchor, matching: find.byType(AnimatedContainer)).first,
    );
    expect((highlight.decoration! as BoxDecoration).color!.a, greaterThan(0));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final cleared = tester.widget<AnimatedContainer>(
      find.descendant(of: anchor, matching: find.byType(AnimatedContainer)).first,
    );
    expect((cleared.decoration! as BoxDecoration).color!.a, 0);
  });

  testWidgets('a quote whose original is gone shows a notice instead of scrolling', (tester) async {
    useScreen(tester, const Size(500, 900));
    await _pumpRoom(
      tester,
      _chat([_message('m-1', 1, me, 'Halo', replyTo: 'gone', replyUser: 'ghost', replyBody: 'Pesan lama')]),
    );
    await tester.tap(_quote('Pesan lama'));
    await tester.pumpAndSettle();
    expect(find.text('Pesan yang dibalas tidak ditemukan.'), findsOneWidget);
  });

  testWidgets('Ctrl+V queues the clipboard image; it is sent with the typed text only on send', (tester) async {
    useScreen(tester, const Size(500, 900));
    final chat = _chat([_message('a-1', 1, alice, 'Kirim screenshot ya')]);
    final media = _Media();
    await _pumpRoom(
      tester,
      chat,
      media: media,
      composer: MessageComposer(clipboardImage: () async => _png),
    );

    await _pressPaste(tester);
    await _pressPaste(tester, focus: false);

    expect(media.uploads, isEmpty);
    expect(find.byTooltip('Hapus lampiran'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'Ini buktinya');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(media.uploads, ['image/png', 'image/png']);
    expect(chat.sentAttachments.single, hasLength(2));
    expect(find.text('Ini buktinya'), findsOneWidget);
    expect(find.byTooltip('Hapus lampiran'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('at most four attachments can be queued and each can be removed', (tester) async {
    useScreen(tester, const Size(500, 900));
    final media = _Media();
    await _pumpRoom(
      tester,
      _chat([_message('a-1', 1, alice, 'Halo')]),
      media: media,
      composer: MessageComposer(clipboardImage: () async => _png),
    );

    await _pressPaste(tester);
    for (var i = 0; i < 4; i++) {
      await _pressPaste(tester, focus: false);
    }
    expect(find.byTooltip('Hapus lampiran'), findsNWidgets(4));
    expect(find.text('Maksimal 4 lampiran per pesan.'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus lampiran').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus lampiran'), findsNWidgets(3));
    expect(media.uploads, isEmpty);
  });

  testWidgets('Ctrl+V without an image pastes the clipboard text at the cursor', (tester) async {
    useScreen(tester, const Size(500, 900));
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') return <String, Object?>{'text': 'kode order 123'};
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final media = _Media();
    await _pumpRoom(
      tester,
      _chat([_message('a-1', 1, alice, 'Halo')]),
      media: media,
      composer: MessageComposer(clipboardImage: () async => null),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Ini ');
    await _pressPaste(tester, focus: false);

    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Ini kode order 123');
    expect(media.uploads, isEmpty);
  });

  testWidgets('chat text is selectable with the mouse on desktop but keeps long-press actions on phones', (
    tester,
  ) async {
    useScreen(tester, const Size(500, 900));
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await _pumpRoom(tester, _chat([_message('a-1', 1, alice, 'Kode order 4471')]));
    expect(find.ancestor(of: find.text('Kode order 4471'), matching: find.byType(SelectionArea)), findsOneWidget);
    expect(find.ancestor(of: find.byType(TextField), matching: find.byType(SelectionArea)), findsNothing);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await _pumpRoom(tester, _chat([_message('a-1', 1, alice, 'Kode order 4471')]));
    expect(find.byType(SelectionArea), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('the attach button shows a paperclip when PDFs are allowed and an image icon otherwise', (tester) async {
    useScreen(tester, const Size(500, 900));
    await _pumpRoom(tester, _chat([]), composer: const MessageComposer(allowDocuments: true));
    expect(find.byIcon(Icons.attach_file), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNothing);

    await _pumpRoom(tester, _chat([]));
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    expect(find.byIcon(Icons.attach_file), findsNothing);
  });
}
