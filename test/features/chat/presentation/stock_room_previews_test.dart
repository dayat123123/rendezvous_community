import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/stock_preview_schedule.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';

class _PreviewChat extends FakeChatRepository implements RoomPreviewRepository {
  _PreviewChat({super.rooms});

  final calls = <List<String>>[];
  List<RoomPreview> previews = const [];
  Duration? pollInterval;
  Object? error;

  @override
  Future<RoomPreviewPage> getRoomPreviews(List<String> roomIds) async {
    calls.add(roomIds);
    final failure = error;
    if (failure != null) throw failure;
    return RoomPreviewPage(previews, pollInterval: pollInterval);
  }
}

void main() {
  final earlier = DateTime.utc(2026, 11, 4, 8);
  final later = DateTime.utc(2026, 11, 4, 9);
  late _PreviewChat chat;
  late DateTime now;

  List<ChatRoom> rooms() => [
    ChatRoom(
      id: 'dm',
      type: RoomType.direct,
      lastMessageAt: earlier.add(const Duration(minutes: 30)),
      createdAt: earlier,
      lastReadAt: earlier,
      otherUser: alice,
    ),
    ChatRoom(
      id: 'bbca',
      type: RoomType.stock,
      stockCode: 'BBCA',
      lastMessageAt: earlier,
      createdAt: earlier,
      lastReadAt: earlier,
    ),
    ChatRoom(id: 'tlkm', type: RoomType.stock, stockCode: 'TLKM', createdAt: earlier, lastReadAt: earlier),
  ];

  ChatListCubit build({ChatRepository? repository, CommunityConnectivity? connectivity}) {
    final cubit = ChatListCubit(
      chat: repository ?? chat,
      me: () async => me,
      connectivity: connectivity,
      random: _Fixed(0.5),
      clock: () => now,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> advance(WidgetTester tester, Duration by) async {
    now = now.add(by);
    await tester.pump(by);
  }

  setUp(() {
    now = DateTime.utc(2026, 11, 4, 9, 30);
    chat = _PreviewChat(rooms: rooms());
    addTearDown(chat.dispose);
  });

  testWidgets('the list polls only its stock rooms and only while visible', (tester) async {
    final cubit = build();
    await cubit.load();
    await tester.pump();
    expect(chat.calls, isEmpty);

    cubit.setVisible(true);
    await tester.pump();
    expect(chat.calls.single.toSet(), {'bbca', 'tlkm'});

    await advance(tester, const Duration(seconds: 14));
    expect(chat.calls, hasLength(1));
    await advance(tester, const Duration(seconds: 2));
    expect(chat.calls, hasLength(2));

    cubit.setVisible(false);
    await advance(tester, const Duration(minutes: 2));
    expect(chat.calls, hasLength(2));
  });

  testWidgets('a newer preview updates the room and moves it to the top', (tester) async {
    chat.previews = [
      RoomPreview(
        roomId: 'bbca',
        lastMessageAt: later,
        lastMessagePreview: 'Antre di bid',
        lastMessageSenderId: alice.id,
        unreadCount: 7,
      ),
    ];
    final cubit = build();
    await cubit.load();
    cubit.setVisible(true);
    await tester.pump();

    final top = cubit.state.rooms.first;
    expect(top.id, 'bbca');
    expect(top.lastMessageAt, later);
    expect(top.lastMessagePreview, 'Antre di bid');
    expect(top.unreadCount, 7);
    expect(top.lastMessageStatus, isNull);
    cubit.setVisible(false);
  });

  testWidgets('an older preview never moves the list backwards', (tester) async {
    chat.previews = [
      RoomPreview(
        roomId: 'bbca',
        lastMessageAt: earlier.subtract(const Duration(hours: 1)),
        lastMessagePreview: 'lama',
      ),
    ];
    final cubit = build();
    await cubit.load();
    final before = cubit.state.rooms;
    cubit.setVisible(true);
    await tester.pump();

    expect(cubit.state.rooms, before);
    cubit.setVisible(false);
  });

  testWidgets('the server sets the poll interval within safe bounds', (tester) async {
    chat.pollInterval = const Duration(seconds: 40);
    final cubit = build();
    await cubit.load();
    cubit.setVisible(true);
    await tester.pump();

    await advance(tester, const Duration(seconds: 39));
    expect(chat.calls, hasLength(1));
    await advance(tester, const Duration(seconds: 2));
    expect(chat.calls, hasLength(2));
    cubit.setVisible(false);
  });

  testWidgets('offline pauses polling and coming back resumes it', (tester) async {
    final connectivity = CommunityConnectivity();
    addTearDown(connectivity.dispose);
    final cubit = build(connectivity: connectivity);
    await cubit.load();
    connectivity.report(reachable: false);
    await tester.pump();
    cubit.setVisible(true);
    await advance(tester, const Duration(seconds: 30));
    expect(chat.calls, isEmpty);

    connectivity.report(reachable: true);
    await tester.pump();
    expect(chat.calls, hasLength(1));
    cubit.setVisible(false);
  });

  testWidgets('resuming the app polls at once when the last poll is stale', (tester) async {
    final connectivity = CommunityConnectivity();
    addTearDown(connectivity.dispose);
    final cubit = build(connectivity: connectivity);
    await cubit.load();
    cubit.setVisible(true);
    await tester.pump();
    connectivity.notifyResumed();
    await tester.pump();
    expect(chat.calls, hasLength(1));

    await advance(tester, const Duration(seconds: 6));
    connectivity.notifyResumed();
    await tester.pump();
    expect(chat.calls, hasLength(2));
    cubit.setVisible(false);
  });

  testWidgets('a backend without get_room_previews stops polling for the session', (tester) async {
    chat.error = const CommunityException(CommunityErrorKind.unknown, code: 'PGRST202');
    final cubit = build();
    await cubit.load();
    cubit.setVisible(true);
    await tester.pump();
    await advance(tester, const Duration(minutes: 2));

    expect(chat.calls, hasLength(1));
  });

  testWidgets('a repository without previews and a list without stock rooms never poll', (tester) async {
    final plain = FakeChatRepository(rooms: rooms());
    addTearDown(plain.dispose);
    final cubit = build(repository: plain);
    await cubit.load();
    cubit.setVisible(true);
    await advance(tester, const Duration(minutes: 1));

    chat.rooms = [rooms().first];
    final dmOnly = build();
    await dmOnly.load();
    dmOnly.setVisible(true);
    await advance(tester, const Duration(minutes: 1));
    expect(chat.calls, isEmpty);
  });

  testWidgets('the chat list widget polls only while its ticker mode is enabled', (tester) async {
    await pumpChat(tester, chat, const TickerMode(enabled: false, child: CommunityChatList()));
    expect(chat.calls, isEmpty);

    await pumpChat(tester, chat, const TickerMode(enabled: true, child: CommunityChatList()));
    expect(chat.calls, hasLength(1));

    await pumpChat(tester, chat, const TickerMode(enabled: false, child: CommunityChatList()));
    await tester.pump(const Duration(minutes: 1));
    expect(chat.calls, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });

  group('StockPreviewSchedule', () {
    testWidgets('jitter stays within 75 to 125 percent of the interval', (tester) async {
      var runs = 0;
      final low = StockPreviewSchedule(() async => runs++, interval: const Duration(seconds: 20), random: _Fixed(0));
      addTearDown(low.dispose);
      low.resume();
      await tester.pump();
      expect(runs, 1);
      await tester.pump(const Duration(seconds: 15));
      expect(runs, 2);
      low.dispose();

      runs = 0;
      final high = StockPreviewSchedule(() async => runs++, interval: const Duration(seconds: 20), random: _Fixed(1));
      addTearDown(high.dispose);
      high.resume();
      await tester.pump();
      await tester.pump(const Duration(seconds: 24));
      expect(runs, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(runs, 2);
      high.dispose();
    });

    test('server intervals are clamped between 5 seconds and 5 minutes', () {
      final schedule = StockPreviewSchedule(() async {}, interval: const Duration(seconds: 1));
      expect(schedule.interval, StockPreviewSchedule.minInterval);
      schedule.serverInterval = const Duration(hours: 1);
      expect(schedule.interval, StockPreviewSchedule.maxInterval);
      schedule.serverInterval = null;
      expect(schedule.interval, StockPreviewSchedule.maxInterval);
      schedule.dispose();
    });
  });
}

class _Fixed implements Random {
  _Fixed(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}
