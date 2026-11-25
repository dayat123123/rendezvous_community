import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_tile.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/notifications/data/models/notification_model.dart';

import '../support/chat_app.dart';
import '../support/fakes.dart';
import '../support/feature_fakes.dart';
import '../support/legal_fakes.dart';

Post _post(String id, String body, int hoursAgo) => Post(
  id: id,
  author: alice,
  body: body,
  createdAt: now.subtract(Duration(hours: hoursAgo)),
  cursor: 'c-$id',
);

class _Feed extends FakeFeedRepository {
  List<Post> items = [_post('p-1', 'Post lama', 2)];

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(items);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

AppNotification _notification(String id, String minute) => NotificationModel.fromJson({
  'id': id,
  'type': 'followed_post',
  'actor_id': alice.id,
  'actor_username': alice.username,
  'actor_display_name': alice.displayName,
  'payload': {'post_id': 'p-$id', 'author_id': alice.id},
  'event_count': 1,
  'read_at': null,
  'created_at': '2026-11-03T05:$minute:00Z',
  'cursor': 'c-$id',
}).toEntity()!;

class _Notifications extends FakeNotificationRepository {
  List<AppNotification> items = [_notification('n-1', '00'), _notification('n-2', '01')];

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async => Paged(items);

  @override
  Future<int> unreadCount() async => items.length;

  @override
  Future<void> markRead({List<String>? ids}) async {}
}

void main() {
  testWidgets('a new post at the top keeps the cards below mounted', (tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final feed = _Feed();
    await pumpCommunity(
      tester,
      const CommunityFeedList(scope: FeedScope.user('u-a'), emptyMessage: 'Kosong'),
      dependencies: FakeDependencies(feed: feed),
    );
    Element card() => tester.element(find.ancestor(of: find.text('Post lama'), matching: find.byType(PostCard)));
    final before = card();

    feed.items = [_post('p-2', 'Post baru', 1), ...feed.items];
    await tester.element(find.byType(PostCard).first).read<FeedCubit>().refresh();
    await tester.pumpAndSettle();

    expect(find.text('Post baru'), findsOneWidget);
    expect(identical(card(), before), isTrue);
  });

  testWidgets('an incoming chat message keeps the bubbles above mounted', (tester) async {
    useScreen(tester, const Size(500, 900));
    final history = chatHistory(3);
    final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: history);
    await pumpChat(tester, chat, const CommunityChatRoom(roomId: 'dm'));
    final before = tester.element(find.byKey(const ValueKey('h-001')));

    chat.roomEvents.add(
      MessageUpserted(
        ChatMessage(
          id: 'h-004',
          roomId: 'dm',
          senderId: alice.id,
          sender: alice,
          body: 'Pesan baru',
          createdAt: chatStart.add(const Duration(minutes: 30)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pesan baru'), findsOneWidget);
    expect(identical(tester.element(find.byKey(const ValueKey('h-001'))), before), isTrue);
  });

  testWidgets('a new notification keeps the rows below mounted', (tester) async {
    final notifications = _Notifications();
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    await pumpFeatureApp(
      tester,
      const CommunityNotificationList(),
      dependencies: FakeDependencies(notifications: notifications),
      features: features,
    );
    await tester.pumpAndSettle();
    final before = tester.element(find.byKey(const ValueKey('n-1')));

    notifications.items = [_notification('n-3', '05'), ...notifications.items];
    notifications.changes.add(null);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('n-3')), findsOneWidget);
    expect(identical(tester.element(find.byKey(const ValueKey('n-1'))), before), isTrue);
  });

  testWidgets('a room moving to the top keeps the other tiles mounted', (tester) async {
    useScreen(tester, const Size(500, 900));
    final alicesRoom = ChatRoom(
      id: 'dm-a',
      type: RoomType.direct,
      createdAt: chatStart,
      lastReadAt: chatStart,
      lastMessageAt: chatStart.add(const Duration(minutes: 10)),
      otherUser: alice,
    );
    final bobsRoom = ChatRoom(
      id: 'dm-b',
      type: RoomType.direct,
      createdAt: chatStart,
      lastReadAt: chatStart,
      lastMessageAt: chatStart.add(const Duration(minutes: 5)),
      otherUser: bob,
    );
    final chat = FakeChatRepository(rooms: [alicesRoom, bobsRoom]);
    await pumpChat(tester, chat, const CommunityChatList());
    Element tile(String name) => tester.element(find.ancestor(of: find.text(name), matching: find.byType(RoomTile)));
    final bob0 = tile('Bob');
    final alice0 = tile('Alice');

    chat.rooms = [alicesRoom, bobsRoom.copyWith(lastMessageAt: chatStart.add(const Duration(minutes: 20)))];
    await tester.element(find.byType(RoomTile).first).read<ChatListCubit>().refresh();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('Bob')).dy, lessThan(tester.getTopLeft(find.text('Alice')).dy));
    expect(identical(tile('Bob'), bob0), isTrue);
    expect(identical(tile('Alice'), alice0), isTrue);
  });
}
