import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

ChatMessage _message(String id, int minute, UserSummary sender, String body) => ChatMessage(
  id: id,
  roomId: 'dm',
  senderId: sender.id,
  sender: sender,
  body: body,
  createdAt: chatStart.add(Duration(minutes: minute)),
);

Future<void> _pumpRoom(WidgetTester tester, {CommunitySwipeToReplySettings? settings}) async {
  useScreen(tester, const Size(500, 900));
  final chat = FakeChatRepository(
    rooms: [directRoom()],
    members: directMembers(),
    messages: [_message('m-1', 2, me, 'Sudah saya cek'), _message('a-1', 1, alice, 'Order saya belum masuk')],
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(chat: chat),
          child: settings == null
              ? const CommunityChatRoom(roomId: 'dm')
              : CommunitySwipeToReplyScope(
                  settings: settings,
                  child: const CommunityChatRoom(roomId: 'dm'),
                ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _replyPreview(String text) => find.descendant(of: find.byType(MessageComposer), matching: find.text(text));

void main() {
  testWidgets('swiping a message to the right replies to it with a haptic tick, like WhatsApp', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await _pumpRoom(tester);

    final bubble = find.text('Order saya belum masuk').first;
    final start = tester.getTopLeft(bubble);
    final gesture = await tester.startGesture(tester.getCenter(bubble));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    expect(tester.getTopLeft(bubble).dx, greaterThan(start.dx + 40));
    expect(find.byIcon(Icons.reply), findsWidgets);
    expect(haptics, ['HapticFeedbackType.lightImpact']);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_replyPreview('Alice'), findsOneWidget);
    expect(tester.getTopLeft(bubble).dx, start.dx);
    expect(tester.testTextInput.hasAnyClients, isTrue);
  });

  testWidgets('my own messages can be swiped to reply too', (tester) async {
    await _pumpRoom(tester);
    await tester.drag(find.text('Sudah saya cek'), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(_replyPreview('Anda'), findsOneWidget);
  });

  testWidgets('a short swipe, a left swipe, or a mouse drag does not reply', (tester) async {
    await _pumpRoom(tester);
    final bubble = find.text('Order saya belum masuk');

    await tester.drag(bubble, const Offset(30, 0));
    await tester.pumpAndSettle();
    await tester.drag(bubble, const Offset(-120, 0));
    await tester.pumpAndSettle();
    await tester.drag(bubble, const Offset(120, 0), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(_replyPreview('Alice'), findsNothing);
  });

  testWidgets('host settings: a larger threshold, left swipes for my own messages, and no haptic', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await _pumpRoom(
      tester,
      settings: const CommunitySwipeToReplySettings(threshold: 100, mine: CommunitySwipeDirection.left, haptic: false),
    );

    await tester.drag(find.text('Order saya belum masuk'), const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(_replyPreview('Alice'), findsNothing);

    await tester.drag(find.text('Sudah saya cek'), const Offset(140, 0));
    await tester.pumpAndSettle();
    expect(_replyPreview('Anda'), findsNothing);

    await tester.drag(find.text('Sudah saya cek'), const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(_replyPreview('Anda'), findsOneWidget);
    expect(haptics, isEmpty);
  });

  testWidgets('host settings can turn swipe to reply off', (tester) async {
    await _pumpRoom(tester, settings: const CommunitySwipeToReplySettings(enabled: false));
    await tester.drag(find.text('Order saya belum masuk'), const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(_replyPreview('Alice'), findsNothing);
  });
}
