import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';

const _budi = UserSummary(id: 'u-budi', username: 'BudiSantoso', displayName: 'Budi Santoso');

class _Profiles extends Fake implements ProfileRepository, FollowListRepository {
  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => UserProfile(
    user: _budi,
    followerCount: 1,
    followingCount: 1,
    postCount: 0,
    createdAt: now,
    isMe: false,
    isFollowing: false,
    followsMe: false,
    isBlocked: false,
  );

  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async => const [_budi];

  @override
  Future<Paged<FollowListEntry>> followList(
    String userId,
    FollowListKind kind, {
    String? cursor,
    int limit = 30,
  }) async => const Paged([FollowListEntry(user: _budi)]);
}

class _EmptyFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => const Paged([]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  useScreen(tester, const Size(900, 1400));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(feed: _EmptyFeed(), profiles: _Profiles()),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('profile header shows the lowercase handle', (tester) async {
    await _pump(tester, const CommunityUserProfile(userId: 'u-budi'));

    expect(find.text('@budisantoso'), findsOneWidget);
    expect(find.textContaining('BudiSantoso'), findsNothing);
  });

  testWidgets('follow list rows and the pushed page title use the lowercase handle', (tester) async {
    await _pump(tester, const CommunityUserProfile(userId: 'u-budi'));

    await tester.tap(find.text('Pengikut'));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(AppBar), matching: find.text('@budisantoso')), findsOneWidget);
    expect(find.descendant(of: find.byType(CommunityFollowList), matching: find.text('@budisantoso')), findsOneWidget);
  });

  testWidgets('CommunityUserName shows the lowercase handle next to the name', (tester) async {
    await _pump(tester, const CommunityUserName(user: _budi));

    expect(find.textContaining('@budisantoso', findRichText: true), findsOneWidget);
    expect(find.textContaining('@BudiSantoso', findRichText: true), findsNothing);
  });

  testWidgets('composer user suggestions show the lowercase handle', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, CommunityComposerField(controller: controller, hintText: 'Tulis'));

    await tester.enterText(find.byType(TextField), '@bud');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('@budisantoso'), findsOneWidget);
  });

  testWidgets('direct chat header shows the lowercase handle', (tester) async {
    final room = ChatRoom(
      id: 'dm',
      type: RoomType.direct,
      createdAt: chatStart,
      lastReadAt: chatStart,
      otherUser: _budi,
    );
    final chat = FakeChatRepository(
      rooms: [room],
      members: [
        RoomMember(user: me, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
        RoomMember(user: _budi, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
      ],
    );
    await pumpChat(tester, chat, CommunityChatRoom(roomId: 'dm', repository: chat));

    expect(find.text('@budisantoso'), findsOneWidget);
  });
}
