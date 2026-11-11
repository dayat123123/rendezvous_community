import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/new_group_dialog.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';
import '../../../support/feature_fakes.dart';

Widget _app(Widget child, {CommunityChatBuilders builders = const CommunityChatBuilders()}) => MaterialApp(
  locale: const Locale('id'),
  localizationsDelegates: CommunityLocalizations.localizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  home: Scaffold(
    body: CommunityScope(
      dependencies: FakeDependencies(),
      child: CommunityBuildersScope(
        builders: CommunityBuilders(chat: builders),
        child: child,
      ),
    ),
  ),
);

Widget _marker(BuildContext context, Object details, Widget fallback) => const SizedBox();

MessageRequest _request() => MessageRequest(
  roomId: 'r-1',
  sender: alice,
  messageCount: 2,
  lastMessagePreview: 'Halo kak',
  createdAt: DateTime.utc(2026, 11, 3, 5),
);

void main() {
  test('merge takes every new chat slot from the nested set and keeps the host ones', () {
    Widget host(BuildContext c, Object d, Widget f) => const Text('host');
    Widget nested(BuildContext c, Object d, Widget f) => const Text('nested');
    final hostSet = CommunityChatBuilders(
      deliveryNotice: host,
      reactionPicker: host,
      reactions: host,
      receipt: host,
      messageActions: host,
      roomNotice: host,
      moderationBanner: host,
      moderationDialog: host,
      roomAvatar: host,
      newGroupDialog: host,
      shareTarget: host,
      sharedPost: host,
      stockCardPicker: host,
      requestsEntry: host,
      requestTile: host,
      requestIntro: host,
      requestActions: host,
      requestBubble: host,
      groupEvent: host,
      groupNotice: host,
      groupMember: host,
    );
    final kept = hostSet.merge(const CommunityChatBuilders());
    final replaced = hostSet.merge(
      CommunityChatBuilders(
        deliveryNotice: nested,
        reactionPicker: nested,
        reactions: nested,
        receipt: nested,
        messageActions: nested,
        roomNotice: nested,
        moderationBanner: nested,
        moderationDialog: nested,
        roomAvatar: nested,
        newGroupDialog: nested,
        shareTarget: nested,
        sharedPost: nested,
        stockCardPicker: nested,
        requestsEntry: nested,
        requestTile: nested,
        requestIntro: nested,
        requestActions: nested,
        requestBubble: nested,
        groupEvent: nested,
        groupNotice: nested,
        groupMember: nested,
      ),
    );
    List<Object?> slots(CommunityChatBuilders b) => [
      b.deliveryNotice,
      b.reactionPicker,
      b.reactions,
      b.receipt,
      b.messageActions,
      b.roomNotice,
      b.moderationBanner,
      b.moderationDialog,
      b.roomAvatar,
      b.newGroupDialog,
      b.shareTarget,
      b.sharedPost,
      b.stockCardPicker,
      b.requestsEntry,
      b.requestTile,
      b.requestIntro,
      b.requestActions,
      b.requestBubble,
      b.groupEvent,
      b.groupNotice,
      b.groupMember,
    ];
    expect(slots(kept), everyElement(same(host)));
    expect(slots(replaced), everyElement(same(nested)));
    expect(const CommunityChatBuilders(receipt: _marker).merge(null).receipt, same(_marker));
  });

  testWidgets('room avatar, receipt, reactions and the reaction picker use their builders', (tester) async {
    final picked = <String>[];
    final room = directRoom();
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            CommunityRoomAvatar(room: room, online: true, radius: 18),
            const ReceiptIcon(receipt: ReceiptStatus.read, color: Colors.grey),
            ReactionChips(
              reactions: const [MessageReaction(emoji: '👍', count: 2, mine: true)],
              onReact: picked.add,
              isMine: true,
            ),
            ReactionPicker(choices: const ['👍', '🔥'], selected: '🔥', onSelected: picked.add),
          ],
        ),
        builders: CommunityChatBuilders(
          roomAvatar: (context, d, fallback) => Text('avatar ${d.room.id} ${d.radius} ${d.online}'),
          receipt: (context, d, fallback) => Text('centang ${d.read} ${d.semanticLabel}'),
          reactions: (context, d, fallback) => TextButton(
            onPressed: () => d.onReact!(d.reactions.single.emoji),
            child: Text('reaksi ${d.reactions.single.count} ${d.isMine}'),
          ),
          reactionPicker: (context, d, fallback) => TextButton(
            onPressed: () => d.onSelected(d.choices.first),
            child: Text('pilih ${d.choices.join()} ${d.selected}'),
          ),
        ),
      ),
    );

    expect(find.text('avatar dm 18.0 true'), findsOneWidget);
    expect(find.text('centang true Dibaca'), findsOneWidget);
    await tester.tap(find.text('reaksi 2 true'));
    await tester.tap(find.text('pilih 👍🔥 🔥'));
    expect(picked, ['👍', '👍']);
  });

  testWidgets('fallbacks render the default avatar, ticks and reactions without builders', (tester) async {
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            CommunityRoomAvatar(
              room: ChatRoom(id: 'g', type: RoomType.group, name: 'Grup', createdAt: chatStart, lastReadAt: chatStart),
            ),
            const ReceiptIcon(receipt: ReceiptStatus.delivered, color: Colors.grey),
            const ReactionChips(reactions: [MessageReaction(emoji: '🔥', count: 3)]),
          ],
        ),
      ),
    );
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    expect(find.byIcon(Icons.done_all), findsOneWidget);
    expect(find.text('🔥 3'), findsOneWidget);
  });

  testWidgets('shared post and stock card picker builders get display-ready details', (tester) async {
    List<String>? sent;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Column(
            children: [
              SharedPostCard(
                postId: 'p-1',
                sharedPost: const SharedPost(postId: 'p-1', author: alice, body: 'Analisis BBCA'),
                onOpen: () {},
              ),
              TextButton(onPressed: () async => sent = await showStockCardPicker(context), child: const Text('buka')),
            ],
          ),
        ),
        builders: CommunityChatBuilders(
          sharedPost: (context, d, fallback) =>
              Text('post ${d.postId} ${d.post?.body} ${d.loading} ${d.available} ${d.onOpen != null}'),
          stockCardPicker: (context, d, fallback) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: d.controller),
                Text('kartu ${d.codes.join(',')} maks ${d.max}'),
              ],
            ),
            actions: [
              TextButton(onPressed: d.onAdd, child: const Text('tambah')),
              TextButton(onPressed: d.onSend, child: const Text('kirim kartu')),
            ],
          ),
        ),
      ),
    );
    expect(find.text('post p-1 Analisis BBCA false true true'), findsOneWidget);

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    expect(find.text('kartu  maks 3'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'bbca');
    await tester.pump();
    await tester.tap(find.text('tambah'));
    await tester.pump();
    expect(find.text('kartu BBCA maks 3'), findsOneWidget);
    await tester.tap(find.text('kirim kartu'));
    await tester.pumpAndSettle();
    expect(sent, ['BBCA']);
  });

  testWidgets('the new group dialog builder enables create only after a name is typed', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(onPressed: () => showNewGroupDialog(context), child: const Text('grup')),
        ),
        builders: CommunityChatBuilders(
          newGroupDialog: (context, d, fallback) => AlertDialog(
            content: TextField(controller: d.nameController, onChanged: d.onNameChanged),
            actions: [Text('bisa ${d.canCreate} ${d.selected.length} ${d.creating}')],
          ),
        ),
      ),
    );
    await tester.tap(find.text('grup'));
    await tester.pumpAndSettle();
    expect(find.text('bisa false 0 false'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Investor');
    await tester.pump();
    expect(find.text('bisa true 0 false'), findsOneWidget);
  });

  testWidgets('the delivery notice builder receives the failed message and its handlers', (tester) async {
    useScreen(tester, const Size(900, 1200));
    final chat = FakeChatRepository(rooms: [directRoom()], members: directMembers(), messages: chatHistory(1))
      ..sendError = Exception('offline');
    await pumpChat(
      tester,
      chat,
      CommunityChatRoom(
        roomId: 'dm',
        builders: CommunityChatBuilders(
          deliveryNotice: (context, d, fallback) =>
              TextButton(onPressed: d.onRetry, child: Text('status ${d.failed} ${d.label} ${d.onDiscard != null}')),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Tertunda');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(find.text('status true Gagal terkirim. Ketuk untuk kirim ulang. true'), findsOneWidget);

    chat.sendError = null;
    await tester.tap(find.text('status true Gagal terkirim. Ketuk untuk kirim ulang. true'));
    await tester.pumpAndSettle();
    expect(find.textContaining('status '), findsNothing);
  });

  testWidgets('the share sheet uses the share target builder for every room', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    final chat = FakeChatRepository(rooms: [directRoom()]);
    final post = Post(id: 'p-1', author: alice, body: 'Halo', createdAt: chatStart, cursor: 'c');
    await pumpFeatureApp(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(
          chat: CommunityChatBuilders(
            shareTarget: (context, d, fallback) =>
                TextButton(onPressed: d.onShare, child: Text('kirim ke ${d.title} ${d.sending}')),
          ),
        ),
        child: Builder(
          builder: (context) =>
              TextButton(onPressed: () => showSharePostToChat(context, post), child: const Text('bagikan')),
        ),
      ),
      dependencies: FakeDependencies(chat: chat),
      features: features,
    );
    await tester.tap(find.text('bagikan'));
    await tester.pumpAndSettle();
    expect(find.text('kirim ke Alice false'), findsOneWidget);
    await tester.tap(find.text('kirim ke Alice false'));
    await tester.pumpAndSettle();
    expect(features.chatExtras.shares.single.$1, 'dm');
  });

  testWidgets('message request builders: entry, tile, intro, bubble, and actions', (tester) async {
    final features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    features.messageRequests
      ..requests = [_request()]
      ..count = 1;
    final chat = FakeChatRepository(
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'r-1',
          senderId: alice.id,
          sender: alice,
          body: 'Lihat ini',
          createdAt: DateTime.utc(2026, 11, 3, 5),
        ),
      ],
    );
    addTearDown(chat.dispose);
    await pumpFeatureApp(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(
          chat: CommunityChatBuilders(
            requestsEntry: (context, d, fallback) =>
                TextButton(onPressed: d.onOpen, child: Text('masuk ${d.label} ${d.count}')),
            requestTile: (context, d, fallback) =>
                TextButton(onPressed: d.onOpen, child: Text('tile ${d.request.sender.name}: ${d.preview}')),
            requestIntro: (context, d, fallback) => Text('intro ${d.message}'),
            requestBubble: (context, d, fallback) => Text('gelembung ${d.message.body} ${d.isMine}'),
            requestActions: (context, d, fallback) =>
                TextButton(onPressed: d.onDecline, child: Text('tolak ${d.busy}')),
          ),
        ),
        child: const MessageRequestsEntry(),
      ),
      dependencies: FakeDependencies(chat: chat),
      features: features,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('masuk Permintaan pesan 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('tile Alice: Halo kak'));
    await tester.pumpAndSettle();
    expect(find.textContaining('intro '), findsOneWidget);
    expect(find.text('gelembung Lihat ini false'), findsOneWidget);
    await tester.tap(find.text('tolak false'));
    await tester.pumpAndSettle();
    expect(features.messageRequests.responses.single, ('r-1', MessageRequestAction.decline));
  });
}
