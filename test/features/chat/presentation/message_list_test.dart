import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

void main() {
  FakeChatRepository repository(int count) =>
      FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: chatHistory(count));

  testWidgets('first page does not fill the screen: older messages load without scrolling', (tester) async {
    useScreen(tester, const Size(1000, 3000));
    final chat = repository(45);
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));

    expect(chat.olderCursors, hasLength(2));
    expect(find.text('Pesan 1'), findsOneWidget);
    expect(find.text('Pesan 45'), findsOneWidget);
  });

  testWidgets('screen is full: the next page loads only when scrolling near the oldest message', (tester) async {
    useScreen(tester, const Size(1000, 700));
    final chat = repository(45);
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));
    expect(chat.olderCursors, [null]);

    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(chat.olderCursors, hasLength(2));
  });

  testWidgets('sending a message scrolls back to the newest message once', (tester) async {
    useScreen(tester, const Size(1000, 700));
    final chat = repository(45);
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));
    final list = find.byType(ListView);
    await tester.drag(list, const Offset(0, 1500));
    await tester.pumpAndSettle();
    final position = tester
        .state<ScrollableState>(find.descendant(of: list, matching: find.byType(Scrollable)))
        .position;
    expect(position.pixels, greaterThan(0));

    await tester.enterText(find.byType(TextField), 'Pesan baru saya');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(position.pixels, position.minScrollExtent);
    expect(find.text('Pesan baru saya').hitTestable(), findsOneWidget);

    await tester.drag(list, const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(position.pixels, greaterThan(0));
  });
}
