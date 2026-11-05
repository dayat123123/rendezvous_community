import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';

import '../../../support/fakes.dart';

class _MockSupport extends Mock implements SupportRepository {}

class _SupportDeps implements CommunitySupportDependencies {
  _SupportDeps(this.support, this.supportChat);

  @override
  final SupportRepository support;
  @override
  final ChatRepository supportChat;
}

SupportTicket _ticket({SupportStatus status = SupportStatus.claimed, bool canRate = false}) => SupportTicket(
  id: 't-1',
  ticketNumber: 'CS-20261030-0001',
  roomId: 'r-cs',
  topic: 'orders',
  topicName: 'Order & Transaksi',
  status: status,
  agent: status == SupportStatus.claimed ? const SupportAgent(displayName: 'Nadia') : null,
  createdAt: DateTime.utc(2026, 10, 30, 3),
  canRate: canRate,
);

SupportHome _home({SupportTicket? current, String? roomId = 'r-cs', bool serviceOpen = true, DateTime? nextOpenAt}) =>
    SupportHome(
      roomId: roomId,
      supportName: 'CS OLT',
      ticket: current,
      active: current?.isActive ?? false,
      serviceOpen: serviceOpen,
      nextOpenAt: nextOpenAt,
    );

const _topics = [
  SupportTopic(code: 'orders', name: 'Order & Transaksi'),
  SupportTopic(code: 'fraud', name: 'Penipuan', urgent: true),
];

const _nadia = UserSummary(id: 'a-1', username: 'cs_nadia', displayName: 'Nadia');

List<ChatMessage> _messages() => [
  ChatMessage(
    id: 'm-2',
    roomId: 'r-cs',
    body: 'Tiket selesai.',
    createdAt: now,
    kind: MessageKind.csat,
    senderRole: SenderRole.system,
    ticketId: 't-1',
    payload: const {'code': 'ticket_resolved'},
  ),
  ChatMessage(
    id: 'm-1',
    roomId: 'r-cs',
    senderId: _nadia.id,
    sender: _nadia,
    body: 'Apakah sudah bisa login?',
    createdAt: now.subtract(const Duration(minutes: 1)),
    kind: MessageKind.quickReply,
    senderRole: SenderRole.agent,
    ticketId: 't-1',
    payload: const {
      'options': ['Sudah', 'Belum'],
    },
  ),
];

Widget _app(Widget child, {CommunitySupportBuilders support = const CommunitySupportBuilders()}) => MaterialApp(
  locale: const Locale('id'),
  localizationsDelegates: CommunityLocalizations.localizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  home: CommunityBuildersScope(
    builders: CommunityBuilders(support: support),
    child: Scaffold(body: child),
  ),
);

Future<FakeChatRepository> _pumpChat(
  WidgetTester tester,
  SupportRepository support, {
  CommunitySupportBuilders builders = const CommunitySupportBuilders(),
  List<ChatMessage> messages = const [],
}) async {
  final chat = FakeChatRepository(
    rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: now, lastReadAt: now)],
    messages: messages,
  );
  await tester.pumpWidget(
    _app(
      CommunityScope(
        dependencies: FakeDependencies(chat: chat),
        child: CommunitySupportScope(dependencies: _SupportDeps(support, chat), child: const CommunitySupportChat()),
      ),
      support: builders,
    ),
  );
  await tester.pumpAndSettle();
  return chat;
}

Widget _tag(BuildContext context, Object details, Widget fallback) => const SizedBox.shrink();

void main() {
  late _MockSupport support;

  setUp(() {
    support = _MockSupport();
    when(() => support.topics(language: any(named: 'language'))).thenAnswer((_) async => _topics);
    when(() => support.watchTicket(any())).thenAnswer((_) => const Stream.empty());
  });

  test('merge keeps every slot and lets the newer set win', () {
    Widget a<T>(BuildContext c, T d, Widget f) => f;
    final full = CommunitySupportBuilders(
      loading: a,
      empty: a,
      error: a,
      header: a,
      banner: a,
      ticketTile: a,
      sensitiveWarning: a,
      closedBar: a,
      ratingDialog: a,
      fakeCsWarning: a,
      systemNotice: a,
      officialSender: a,
      quickReplies: a,
      helpLink: a,
      topicPicker: a,
      topicTile: a,
    );
    List<Object?> slots(CommunitySupportBuilders b) => [
      b.loading,
      b.empty,
      b.error,
      b.header,
      b.banner,
      b.ticketTile,
      b.sensitiveWarning,
      b.closedBar,
      b.ratingDialog,
      b.fakeCsWarning,
      b.systemNotice,
      b.officialSender,
      b.quickReplies,
      b.helpLink,
      b.topicPicker,
      b.topicTile,
    ];
    expect(slots(const CommunitySupportBuilders().merge(full)), slots(full));
    expect(slots(full.merge(const CommunitySupportBuilders())), slots(full));
    expect(identical(full.merge(null), full), isTrue);
    final header = CommunitySupportBuilders(header: _tag);
    expect(full.merge(header).header, same(header.header));
    expect(full.merge(header).banner, same(full.banner));
  });

  testWidgets('fallbacks: ticket header with soft status, official badge and out-of-hours banner', (tester) async {
    when(
      () => support.home(),
    ).thenAnswer((_) async => _home(current: _ticket(), serviceOpen: false, nextOpenAt: DateTime(2026, 11, 5, 8)));
    final chat = await _pumpChat(tester, support);

    expect(find.text('#CS-20261030-0001 · Order & Transaksi'), findsOneWidget);
    expect(find.text('Ditangani oleh Nadia – CS Resmi'), findsOneWidget);
    expect(find.text('CS Resmi'), findsOneWidget);
    expect(find.byTooltip('Menu bantuan'), findsOneWidget);
    expect(find.textContaining('di luar jam layanan'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('header, banner, closed bar, system notice and quick replies builders replace the defaults', (
    tester,
  ) async {
    when(() => support.home()).thenAnswer(
      (_) async => _home(
        current: _ticket(status: SupportStatus.closed, canRate: true),
        serviceOpen: false,
        nextOpenAt: DateTime(2026, 11, 5, 8),
      ),
    );
    CommunitySupportHeaderDetails? header;
    final chat = await _pumpChat(
      tester,
      support,
      messages: _messages(),
      builders: CommunitySupportBuilders(
        header: (context, d, fallback) {
          header = d;
          return Text('H:${d.ticketNumber}:${d.statusLabel}');
        },
        banner: (context, d, fallback) => Text('B:${d.tone.name}'),
        closedBar: (context, d, fallback) => TextButton(onPressed: d.onNewTicket, child: Text('N:${d.ticketNumber}')),
        systemNotice: (context, d, fallback) => Text('S:${d.code}:${d.onRate != null}'),
        quickReplies: (context, d, fallback) => Text('Q:${d.options.join(',')}:${d.enabled}'),
        officialSender: (context, d, fallback) => Text('O:${d.name}'),
        topicPicker: (context, d, fallback) => Text('P:${d.topics.length}:${d.busy}'),
      ),
    );

    expect(find.text('H:CS-20261030-0001:Ditutup'), findsOneWidget);
    expect(header!.onEndChat, isNull);
    expect(header!.onNewTicket, isNotNull);
    expect(header!.onReportFake, isNotNull);
    expect(header!.menuTooltip, 'Menu bantuan');
    expect(find.text('B:warning'), findsOneWidget);
    expect(find.text('S:ticket_resolved:true'), findsOneWidget);
    expect(find.text('Q:Sudah,Belum:true'), findsOneWidget);
    expect(find.byTooltip('Menu bantuan'), findsNothing);

    await tester.tap(find.text('N:CS-20261030-0001'));
    await tester.pumpAndSettle();
    expect(find.text('P:2:false'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('topic picker fallback lists topic tiles through the topicTile builder', (tester) async {
    when(() => support.home()).thenAnswer((_) async => _home(roomId: null));
    final chat = await _pumpChat(
      tester,
      support,
      builders: CommunitySupportBuilders(
        topicTile: (context, d, fallback) =>
            TextButton(onPressed: d.onSelect, child: Text('T:${d.topic.code}:${d.urgent}')),
      ),
    );

    expect(find.text('Apa yang bisa kami bantu?'), findsOneWidget);
    expect(find.text('T:orders:false'), findsOneWidget);
    expect(find.text('T:fraud:true'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('sensitive warning goes through its builder', (tester) async {
    when(() => support.home()).thenAnswer((_) async => _home(current: _ticket()));
    when(
      () => support.checkSensitive(any()),
    ).thenAnswer((_) async => const SensitiveCheck(masked: true, kinds: ['otp', 'card']));
    final chat = await _pumpChat(
      tester,
      support,
      builders: CommunitySupportBuilders(
        sensitiveWarning: (context, d, fallback) =>
            Column(mainAxisSize: MainAxisSize.min, children: [Text('W:${d.kinds.join(',')}'), fallback]),
      ),
    );

    await tester.enterText(find.byType(TextField), 'OTP saya 123456');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text('W:otp,card'), findsOneWidget);
    expect(find.textContaining('akan disamarkan'), findsOneWidget);
    await chat.dispose();
  });

  testWidgets('ticket list: loading, empty, error and tile builders', (tester) async {
    final tickets = [_ticket(), _ticket(status: SupportStatus.closed).copyWith(id: 't-2', ticketNumber: 'CS-2')];
    when(() => support.myTickets()).thenAnswer((_) async => tickets);
    final chat = FakeChatRepository();
    Widget list(CommunitySupportBuilders builders) => _app(
      CommunityScope(
        dependencies: FakeDependencies(chat: chat),
        child: CommunitySupportScope(dependencies: _SupportDeps(support, chat), child: const CommunitySupportTickets()),
      ),
      support: builders,
    );

    await tester.pumpWidget(list(const CommunitySupportBuilders()));
    await tester.pumpAndSettle();
    expect(find.text('CS-20261030-0001 · Order & Transaksi'), findsOneWidget);
    expect(find.text('Ditangani oleh Nadia – CS Resmi'), findsOneWidget);
    expect(find.text('Ditutup'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      list(
        CommunitySupportBuilders(
          ticketTile: (context, d, fallback) => Text('K:${d.number}:${d.closed}'),
          loading: (context, d, fallback) => const Text('loading'),
        ),
      ),
    );
    expect(find.text('loading'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('K:CS-20261030-0001:false'), findsOneWidget);
    expect(find.text('K:CS-2:true'), findsOneWidget);

    when(() => support.myTickets()).thenAnswer((_) async => const []);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(list(CommunitySupportBuilders(empty: (context, d, fallback) => Text('E:${d.message}'))));
    await tester.pumpAndSettle();
    expect(find.text('E:Belum ada tiket.'), findsOneWidget);

    when(() => support.myTickets()).thenAnswer((_) async => throw StateError('x'));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(list(CommunitySupportBuilders(error: (context, d, fallback) => const Text('failed'))));
    await tester.pumpAndSettle();
    expect(find.text('failed'), findsOneWidget);
  });

  testWidgets('rating dialog: fallback stars submit, builder gets controller and handlers', (tester) async {
    SupportRating? result;
    Widget opener(CommunitySupportBuilders builders) => _app(
      Builder(
        builder: (context) =>
            TextButton(onPressed: () async => result = await askSupportRating(context), child: const Text('open')),
      ),
      support: builders,
    );

    await tester.pumpWidget(opener(const CommunitySupportBuilders()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    await tester.tap(find.byTooltip('4'));
    await tester.pump();
    await tester.tap(find.text('Kirim nilai'));
    await tester.pumpAndSettle();
    expect(result?.rating, 4);
    expect(result?.comment, isNull);

    await tester.pumpWidget(
      opener(
        CommunitySupportBuilders(
          ratingDialog: (context, d, fallback) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('R:${d.rating}:${d.canSubmit}'),
                TextButton(onPressed: () => d.onRate(5), child: const Text('five')),
                TextButton(
                  onPressed: () {
                    d.controller.text = ' mantap ';
                    d.onSubmit?.call();
                  },
                  child: const Text('send'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('R:0:false'), findsOneWidget);
    await tester.tap(find.text('five'));
    await tester.pump();
    expect(find.text('R:5:true'), findsOneWidget);
    await tester.tap(find.text('send'));
    await tester.pumpAndSettle();
    expect(result?.rating, 5);
    expect(result?.comment, 'mantap');
  });

  testWidgets('fake CS report dialog enables submit after five characters', (tester) async {
    String? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) =>
              TextButton(onPressed: () async => result = await askFakeCsReport(context), child: const Text('open')),
        ),
        support: CommunitySupportBuilders(
          fakeCsWarning: (context, d, fallback) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('F:${d.canSubmit}'),
              Expanded(child: fallback),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('F:false'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'akun palsu minta OTP');
    await tester.pump();
    expect(find.text('F:true'), findsOneWidget);
    await tester.tap(find.text('Kirim'));
    await tester.pumpAndSettle();
    expect(result, 'akun palsu minta OTP');
  });

  testWidgets('help link and official sender builders', (tester) async {
    Uri? opened;
    final message = ChatMessage(
      id: 'm-h',
      roomId: 'r-cs',
      body: 'Panduan',
      createdAt: now,
      kind: MessageKind.helpLink,
      senderRole: SenderRole.agent,
      payload: const {'url': 'https://olt.example/help'},
    );
    Widget parts(CommunitySupportBuilders builders) => _app(
      CommunitySupportMessageActions(
        onOpenLink: (uri) => opened = uri,
        child: Column(
          children: [
            const OfficialSenderLabel(sender: _nadia, color: Colors.blue),
            SupportMessageExtras(message: message, color: Colors.blue, mine: false),
          ],
        ),
      ),
      support: builders,
    );

    await tester.pumpWidget(parts(const CommunitySupportBuilders()));
    expect(find.text('Nadia'), findsOneWidget);
    expect(find.text('CS Resmi'), findsOneWidget);
    await tester.tap(find.text('Buka panduan'));
    expect(opened, Uri.parse('https://olt.example/help'));

    opened = null;
    await tester.pumpWidget(
      parts(
        CommunitySupportBuilders(
          helpLink: (context, d, fallback) => TextButton(onPressed: d.onOpen, child: Text('L:${d.uri.host}')),
          officialSender: (context, d, fallback) => Text('O:${d.name}'),
        ),
      ),
    );
    await tester.tap(find.text('L:olt.example'));
    expect(opened, Uri.parse('https://olt.example/help'));
    expect(find.text('O:Nadia'), findsOneWidget);
  });
}
