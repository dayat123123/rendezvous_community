import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_bubble.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

ChatRoom _group() => ChatRoom(id: 'g', type: RoomType.group, name: 'Grup', createdAt: chatStart, lastReadAt: chatStart);

ChatMessage _message(String id, UserSummary sender, int minute) => ChatMessage(
  id: id,
  roomId: 'g',
  senderId: sender.id,
  sender: sender,
  body: 'Pesan $id',
  createdAt: chatStart.add(Duration(minutes: minute)),
);

FakeChatRepository _groupChat() => FakeChatRepository(
  rooms: [_group()],
  members: [
    for (final user in [me, alice])
      RoomMember(user: user, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
  ],
  messages: [_message('a1', alice, 1), _message('a2', alice, 2), _message('m1', me, 10)],
);

Future<void> _pumpApp(WidgetTester tester, Widget child, {bool disableAnimations = false}) => tester.pumpWidget(
  MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: CommunityLocalizations.localizationsDelegates,
    supportedLocales: CommunityLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  testWidgets('message details mark the end of a group and avatar slots in group rooms', (tester) async {
    final seen = <String, CommunityMessageDetails>{};
    final chat = _groupChat();
    await pumpChat(
      tester,
      chat,
      CommunityChatRoom(
        roomId: 'g',
        repository: chat,
        builders: CommunityChatBuilders(
          message: (context, d, fallback) {
            seen[d.message.id] = d;
            return fallback;
          },
        ),
      ),
    );

    expect(seen['a1']!.startsGroup, isTrue);
    expect(seen['a1']!.endsGroup, isFalse);
    expect(seen['a2']!.startsGroup, isFalse);
    expect(seen['a2']!.endsGroup, isTrue);
    expect(seen['a1']!.showAvatar, isTrue);
    expect(seen['m1']!.showAvatar, isFalse);
    expect(seen['m1']!.endsGroup, isTrue);
    expect(find.byType(CommunityAvatar), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('direct rooms never reserve an avatar slot', (tester) async {
    final seen = <CommunityMessageDetails>[];
    final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: chatHistory(3));
    await pumpChat(
      tester,
      chat,
      CommunityChatRoom(
        roomId: 'dm',
        repository: chat,
        builders: CommunityChatBuilders(
          message: (context, d, fallback) {
            seen.add(d);
            return fallback;
          },
        ),
      ),
    );

    expect(seen, isNotEmpty);
    expect(seen.every((d) => !d.showAvatar), isTrue);
    await chat.dispose();
  });

  testWidgets('composer keeps the hint and send icon and greys the button while empty', (tester) async {
    final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: chatHistory(1));
    await pumpChat(tester, chat, CommunityChatRoom(roomId: 'dm', repository: chat));
    final context = tester.element(find.byType(CommunityChatRoom));
    final style = CommunityStyle.of(context);
    Color? background() => tester
        .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
        .style
        ?.backgroundColor
        ?.resolve(const {});

    expect(find.text('Tulis pesan…'), findsOneWidget);
    expect(background(), style.pill);
    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.pump();
    expect(background(), style.accent);
    await chat.dispose();
  });

  testWidgets('receipt builder receives the read colour override', (tester) async {
    CommunityReceiptDetails? seen;
    await _pumpApp(
      tester,
      CommunityChatBuildersScope(
        builders: CommunityChatBuilders(
          receipt: (context, d, fallback) {
            seen = d;
            return fallback;
          },
        ),
        child: const ReceiptIcon(receipt: ReceiptStatus.read, color: Colors.grey, readColor: Colors.white),
      ),
    );

    expect(seen!.read, isTrue);
    expect(seen!.readColor, Colors.white);
    expect(tester.widget<Icon>(find.byIcon(Icons.done_all)).color, Colors.white);
  });

  testWidgets('typing bubble animates a bounded number of cycles', (tester) async {
    await _pumpApp(tester, const TypingBubble(label: 'Alice sedang mengetik…'));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.bySemanticsLabel('Alice sedang mengetik…'), findsOneWidget);
  });

  testWidgets('typing bubble stays still when animations are disabled', (tester) async {
    await _pumpApp(tester, const TypingBubble(label: 'mengetik…', user: alice), disableAnimations: true);
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(CommunityAvatar), findsOneWidget);
  });

  test('fallback bubbles and sender names meet AA contrast', () {
    for (final seed in const [Color(0xFF0B5FFF), Color(0xFF1B8A3A), Color(0xFF6750A4)]) {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
        );
        final t = CommunityTheme.fallback(theme);
        expect(chatContrast(t.onMyBubble, t.myBubble), greaterThanOrEqualTo(4.5));
        final meta = Color.alphaBlend(t.onMyBubble.withValues(alpha: 0.82), t.myBubble);
        expect(chatContrast(meta, t.myBubble), greaterThanOrEqualTo(4.5), reason: '$seed $brightness');
        final otherMeta = Color.alphaBlend(t.onOtherBubble.withValues(alpha: 0.82), t.otherBubble);
        expect(chatContrast(otherMeta, t.otherBubble), greaterThanOrEqualTo(4.5), reason: '$seed $brightness');
        expect(chatContrast(t.onOtherBubble, t.otherBubble), greaterThanOrEqualTo(4.5));
        expect(chatContrast(t.onUnreadBadge, t.unreadBadge), greaterThanOrEqualTo(4.5));
        for (var i = 0; i < 40; i++) {
          final color = chatSenderColor('user-$i', t.otherBubble, fallback: t.link);
          expect(chatContrast(color, t.otherBubble), greaterThanOrEqualTo(4.5), reason: 'user-$i $brightness');
        }
      }
    }
  });
}
