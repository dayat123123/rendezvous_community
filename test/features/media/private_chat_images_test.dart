import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_info_view.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

class _RecordingDisk implements ImageDiskCache {
  final reads = <String>[];
  final writes = <String>[];

  @override
  Future<Uint8List?> read(String key) async {
    reads.add(key);
    return null;
  }

  @override
  Future<void> write(String key, Uint8List bytes) async => writes.add(key);

  @override
  Future<void> wipe() async {}
}

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

Future<void> _pump(WidgetTester tester, _RecordingDisk disk, Widget child, {ChatRepository? chat}) async {
  useScreen(tester, const Size(900, 900));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityImageScope(
          loader: CommunityImageLoader(
            disk: disk,
            client: MockClient((_) async => http.Response.bytes(_png, 200)),
          ),
          child: CommunityScope(
            dependencies: FakeDependencies(chat: chat, mediaRepository: _Media()),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

FakeChatRepository _dm() =>
    _InfoChat(rooms: [directRoom()], members: directMembers(), messages: [_photoMessage()]);

void main() {
  testWidgets('photos in a direct chat never touch the disk cache', (tester) async {
    final disk = _RecordingDisk();
    await _pump(tester, disk, const CommunityChatRoom(roomId: 'dm'), chat: _dm());
    await _settle(tester);

    expect(find.bySemanticsLabel('Lihat gambar'), findsNWidgets(2));
    expect(disk.writes.where((key) => key.contains('u-me/')), isEmpty);
    expect(disk.reads.where((key) => key.contains('u-me/')), isEmpty);
  });

  testWidgets('opening a chat photo in the viewer keeps it off the disk', (tester) async {
    final disk = _RecordingDisk();
    await _pump(tester, disk, const CommunityChatRoom(roomId: 'dm'), chat: _dm());

    await tester.tap(find.bySemanticsLabel('Lihat gambar').last);
    await _settle(tester);

    expect(find.text('2 dari 2'), findsOneWidget);
    expect(disk.writes.where((key) => key.contains('u-me/')), isEmpty);
  });

  testWidgets('message info keeps chat photos off the disk', (tester) async {
    final disk = _RecordingDisk();
    await _pump(tester, disk, const CommunityChatRoom(roomId: 'dm'), chat: _dm());
    useScreen(tester, const Size(420, 900));
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Bukti transfer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lainnya').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Info pesan'));
    await _settle(tester);

    final info = find.byType(MessageInfoView);
    expect(find.descendant(of: info, matching: find.bySemanticsLabel('Lihat gambar')), findsNWidgets(2));
    expect(disk.writes.where((key) => key.contains('u-me/')), isEmpty);
  });

  testWidgets('feed images outside a chat still use the disk cache', (tester) async {
    final disk = _RecordingDisk();
    await _pump(
      tester,
      disk,
      const AttachmentGrid(attachments: [Attachment(path: 'posts/p-1/feed.png', mime: 'image/png')], maxHeight: 200),
    );
    await _settle(tester);

    expect(disk.writes.where((key) => key.contains('feed.png')), isNotEmpty);
  });
}
