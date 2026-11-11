import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';

const _budi = UserSummary(id: 'u-budi', username: 'BudiSantoso', displayName: 'Budi Santoso');

class _Profiles extends Fake implements ProfileRepository {
  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async => const [_budi];
}

Future<void> _pump(WidgetTester tester, Widget child, {CommunityCallbacks callbacks = const CommunityCallbacks()}) =>
    tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: CommunityScope(
          dependencies: FakeDependencies(profiles: _Profiles(), callbacks: callbacks),
          child: Scaffold(body: child),
        ),
      ),
    );

String _plain(WidgetTester tester, Finder finder) => tester.widget<RichText>(finder).text.toPlainText();

void main() {
  testWidgets('choosing a user suggestion inserts the username in lowercase', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, CommunityComposerField(controller: controller, hintText: 'Tulis'));

    await tester.enterText(find.byType(TextField), 'Halo @bud');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.tap(find.text('Budi Santoso'));
    await tester.pump();

    expect(controller.text, 'Halo @budisantoso ');
  });

  testWidgets('SocialText shows mentions in lowercase and still opens the user', (tester) async {
    UserSummary? opened;
    await _pump(
      tester,
      const SocialText('Cek analisis @BudiSantoso soal \$BBCA'),
      callbacks: CommunityCallbacks(onUserTap: (_, user) => opened = user),
    );

    final rich = find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('@'));
    expect(_plain(tester, rich), 'Cek analisis @budisantoso soal \$BBCA');

    await tester.tapOnText(find.textRange.ofSubstring('@budisantoso'));
    expect(opened?.username.toLowerCase(), 'budisantoso');
  });

  testWidgets('chat bubbles show mentions in lowercase', (tester) async {
    final chat = FakeChatRepository(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'dm',
          senderId: alice.id,
          sender: alice,
          body: 'Halo @BudiSantoso',
          createdAt: chatStart.add(const Duration(minutes: 1)),
        ),
      ],
    );
    await pumpChat(tester, chat, CommunityChatRoom(roomId: 'dm', repository: chat));

    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'Halo @budisantoso'), findsOneWidget);
    expect(find.textContaining('@BudiSantoso', findRichText: true), findsNothing);
  });
}
