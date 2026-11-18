import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

const _budi = UserSummary(id: 'u-budi', username: 'budi', displayName: 'Budi Santoso');

class _Profiles extends Fake implements ProfileRepository {
  int searches = 0;

  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async {
    searches++;
    return const [_budi];
  }
}

ChatRoom _room(RoomType type) => ChatRoom(
  id: 'r',
  type: type,
  name: type == RoomType.group ? 'Grup Saham' : null,
  stockCode: type == RoomType.stock ? 'BBCA' : null,
  createdAt: chatStart,
  lastReadAt: chatStart,
  otherUser: type == RoomType.direct ? alice : null,
);

Future<_Profiles> _pumpRoom(WidgetTester tester, RoomType type) async {
  final profiles = _Profiles();
  final chat = FakeChatRepository(
    rooms: [_room(type)],
    members: directMembers(),
    messages: [
      ChatMessage(
        id: 'm-1',
        roomId: 'r',
        senderId: alice.id,
        sender: alice,
        body: 'Cek @Budi soal \$BBCA',
        createdAt: chatStart.add(const Duration(minutes: 1)),
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(chat: chat, profiles: profiles),
          child: CommunityChatRoom(roomId: 'r', repository: chat),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return profiles;
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).last, text);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

Finder _body(String text) => find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == text);

void main() {
  for (final type in [RoomType.direct, RoomType.group]) {
    testWidgets('${type.name} chat has no @ or \$ suggestions and shows tags as plain text', (tester) async {
      final profiles = await _pumpRoom(tester, type);

      expect(_body('Cek @Budi soal \$BBCA'), findsOneWidget);
      await tester.tapOnText(find.textRange.ofSubstring('@Budi'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityChatRoom), findsOneWidget);

      await _type(tester, 'Halo @bu');
      expect(find.text('Budi Santoso'), findsNothing);
      await _type(tester, 'Beli \$BB');
      expect(find.text('\$BBCA'), findsNothing);
      expect(profiles.searches, 0);
    });
  }

  testWidgets('stock rooms keep @ suggestions and linked tags', (tester) async {
    final profiles = await _pumpRoom(tester, RoomType.stock);

    expect(_body('Cek @budi soal \$BBCA'), findsOneWidget);
    await _type(tester, 'Halo @bu');
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(profiles.searches, 1);
  });
}
