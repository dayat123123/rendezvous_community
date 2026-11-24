import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_tile.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../../support/fakes.dart';

void main() {
  final at = DateTime.now().toUtc();

  Future<void> pumpTile(WidgetTester tester, ChatRoom room, {List<UserSummary> typing = const []}) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: RoomTile(room: room, me: me, online: false, typing: typing, selected: false, onTap: () {}),
      ),
    ),
  );

  ChatRoom dm(ReceiptStatus status) => ChatRoom(
    id: 'dm',
    type: RoomType.direct,
    lastMessageAt: at,
    lastMessagePreview: 'Sudah lihat BBCA?',
    lastMessageSenderId: me.id,
    lastMessageStatus: status,
    createdAt: at,
    lastReadAt: at,
    otherUser: alice,
  );

  testWidgets('a typing DM shows "mengetik…"', (tester) async {
    await pumpTile(tester, dm(ReceiptStatus.sent), typing: [alice]);
    expect(find.text('mengetik…'), findsOneWidget);
    expect(find.text('Sudah lihat BBCA?'), findsNothing);
  });

  testWidgets('a typing group names the typist', (tester) async {
    final group = ChatRoom(id: 'g', type: RoomType.group, name: 'Grup', createdAt: at, lastReadAt: at);
    await pumpTile(tester, group, typing: [alice]);
    expect(find.text('Alice sedang mengetik…'), findsOneWidget);
  });

  testWidgets('last message ticks: one, two grey, two blue', (tester) async {
    await pumpTile(tester, dm(ReceiptStatus.sent));
    expect(find.byIcon(Icons.done), findsOneWidget);

    await pumpTile(tester, dm(ReceiptStatus.delivered));
    final delivered = tester.widget<Icon>(find.byIcon(Icons.done_all));
    expect(delivered.color, isNot(CommunityTheme.fallback(ThemeData()).readReceipt));

    await pumpTile(tester, dm(ReceiptStatus.read));
    final read = tester.widget<Icon>(find.byIcon(Icons.done_all));
    final context = tester.element(find.byType(RoomTile));
    expect(read.color, CommunityTheme.of(context).readReceipt);
    expect(find.text('Sudah lihat BBCA?'), findsOneWidget);
  });

  Future<void> pumpActions(WidgetTester tester, ChatRoom room, {VoidCallback? onPin, VoidCallback? onUnpin}) =>
      tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: communityLocalizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Scaffold(
            body: RoomTile(
              room: room,
              me: me,
              online: false,
              typing: const [],
              selected: false,
              onTap: () {},
              onHide: () {},
              onPin: onPin,
              onUnpin: onUnpin,
            ),
          ),
        ),
      );

  testWidgets('the actions offer pinning an unpinned chat', (tester) async {
    var pinned = 0;
    await pumpActions(tester, dm(ReceiptStatus.sent), onPin: () => pinned++, onUnpin: () {});
    expect(find.byIcon(Icons.push_pin), findsNothing);
    await tester.longPress(find.byType(RoomTile));
    await tester.pumpAndSettle();
    expect(find.text('Lepas sematan'), findsNothing);
    await tester.tap(find.text('Sematkan chat'));
    await tester.pumpAndSettle();
    expect(pinned, 1);
  });

  testWidgets('a pinned chat shows the pin and offers unpinning', (tester) async {
    var unpinned = 0;
    await pumpActions(
      tester,
      dm(ReceiptStatus.sent).copyWith(pinnedAt: at),
      onPin: () {},
      onUnpin: () => unpinned++,
    );
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
    await tester.longPress(find.byType(RoomTile));
    await tester.pumpAndSettle();
    expect(find.text('Sematkan chat'), findsNothing);
    await tester.tap(find.text('Lepas sematan'));
    await tester.pumpAndSettle();
    expect(unpinned, 1);
  });

  testWidgets('support chats show the pin without pin actions', (tester) async {
    final support = ChatRoom(id: 'cs', type: RoomType.support, name: 'CS', createdAt: at, lastReadAt: at);
    await pumpActions(tester, support, onPin: () {}, onUnpin: () {});
    expect(find.byIcon(Icons.push_pin), findsOneWidget);
    await tester.longPress(find.byType(RoomTile));
    await tester.pumpAndSettle();
    expect(find.text('Sematkan chat'), findsNothing);
    expect(find.text('Lepas sematan'), findsNothing);
  });

  test('the pin limit has its own message', () {
    final l10n = lookupCommunityLocalizations(const Locale('id'));
    expect(
      l10n.errorMessage(const CommunityException(CommunityErrorKind.invalidInput, code: 'pin_limit')),
      l10n.errorPinLimit,
    );
  });
}
