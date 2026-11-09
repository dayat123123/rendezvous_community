import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

final _today = DateTime.now();

List<ChatMessage> _days() => [
  for (var day = 2; day >= 0; day--)
    for (var i = 0; i < 20; i++)
      ChatMessage(
        id: 'd$day-$i',
        roomId: 'dm',
        senderId: i.isEven ? me.id : alice.id,
        sender: i.isEven ? me : alice,
        body: 'Pesan hari $day nomor $i',
        createdAt: DateTime(_today.year, _today.month, _today.day, 9, i).subtract(Duration(days: day)).toUtc(),
      ),
];

Finder get _pill => find.byKey(const ValueKey('community-floating-date'));

double _opacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byKey(const ValueKey('community-floating-date-fade'))).opacity;

Future<FakeChatRepository> _pump(WidgetTester tester, {CommunityChatBuilders? builders}) async {
  useScreen(tester, const Size(500, 700));
  final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: _days());
  final room = CommunityChatRoom(roomId: 'dm', repository: chat);
  await pumpChat(
    tester,
    chat,
    builders == null
        ? room
        : CommunityBuildersScope(
            builders: CommunityBuilders(chat: builders),
            child: room,
          ),
  );
  return chat;
}

String _label(WidgetTester tester, int daysAgo) {
  final context = tester.element(find.byType(CommunityChatRoom));
  final day = DateTime(_today.year, _today.month, _today.day, 9).subtract(Duration(days: daysAgo));
  return CommunityLocalizations.of(context)!.dayLabel(day);
}

void main() {
  testWidgets('a date pill floats while scrolling older messages and fades out after a pause', (tester) async {
    final chat = await _pump(tester);
    expect(_opacity(tester), 0);

    await tester.drag(find.byType(ListView), const Offset(0, 1300));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(_opacity(tester), 1);
    final shown = (tester.widget<Text>(find.descendant(of: _pill, matching: find.byType(Text))).data)!;
    expect([_label(tester, 1), _label(tester, 2)], contains(shown));

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_opacity(tester), 0);

    await tester.drag(find.byType(ListView), const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(_opacity(tester), 1);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await chat.dispose();
  });

  testWidgets('the pill stays hidden at the latest messages', (tester) async {
    final chat = await _pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(_opacity(tester), 0);
    await chat.dispose();
  });

  testWidgets('the floatingDate builder replaces the pill', (tester) async {
    final chat = await _pump(
      tester,
      builders: CommunityChatBuilders(floatingDate: (context, d, fallback) => Text('F:${d.label}')),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 1300));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.textContaining('F:'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await chat.dispose();
  });
}
