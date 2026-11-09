import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'fakes.dart';
import 'help_fakes.dart';

class MockSupport extends Mock implements SupportRepository {}

class SupportDeps implements CommunitySupportDependencies {
  SupportDeps(this.support, this.supportChat);

  @override
  final SupportRepository support;
  @override
  final ChatRepository supportChat;
}

class RecordingChatRepository extends FakeChatRepository {
  RecordingChatRepository({super.rooms, super.messages});

  final sentBodies = <String>[];

  @override
  Future<ChatMessage> sendMessage(
    String roomId, {
    required String body,
    required String clientId,
    String? replyToId,
    List<Attachment> attachments = const [],
  }) {
    sentBodies.add(body);
    return super.sendMessage(roomId, body: body, clientId: clientId, replyToId: replyToId, attachments: attachments);
  }
}

SupportTicket supportTicket({
  SupportStatus status = SupportStatus.claimed,
  bool canRate = false,
  int? queueAhead,
  int? etaMinutes,
  List<String> quickReplies = const [],
  String topic = 'orders',
}) => SupportTicket(
  id: 't-1',
  ticketNumber: 'CS-20261109-0001',
  roomId: 'r-cs',
  topic: topic,
  topicName: 'Order & Transaksi',
  status: status,
  agent: status == SupportStatus.claimed ? const SupportAgent(displayName: 'Nadia') : null,
  createdAt: DateTime.utc(2026, 11, 9, 2),
  resolvedAt: status == SupportStatus.resolved || status == SupportStatus.closed ? DateTime.utc(2026, 11, 9, 3) : null,
  canRate: canRate,
  queueAhead: queueAhead,
  etaMinutes: etaMinutes,
  quickReplies: quickReplies,
);

const intakeFields = [
  SupportIntakeField(key: 'order_no', type: SupportIntakeType.text, label: 'Nomor order', isRequired: true),
  SupportIntakeField(key: 'amount', type: SupportIntakeType.number, label: 'Nominal'),
  SupportIntakeField(key: 'trade_date', type: SupportIntakeType.date, label: 'Tanggal transaksi'),
  SupportIntakeField(
    key: 'channel',
    type: SupportIntakeType.choice,
    label: 'Kanal',
    isRequired: true,
    options: [
      SupportIntakeOption(value: 'app', label: 'Aplikasi'),
      SupportIntakeOption(value: 'web', label: 'Web'),
    ],
  ),
];

const supportTopics = [
  SupportTopic(code: 'orders', name: 'Order & Transaksi', intake: intakeFields),
  SupportTopic(code: 'funds', name: 'Deposit/Tarik Dana'),
];

void stubSupport(MockSupport support, {SupportHome? home, List<SupportTopic> topics = supportTopics}) {
  when(() => support.home()).thenAnswer((_) async => home ?? const SupportHome(supportName: 'CS OLT'));
  when(() => support.topics(language: any(named: 'language'))).thenAnswer((_) async => topics);
  when(() => support.watchTicket(any())).thenAnswer((_) => const Stream.empty());
  when(() => support.attachmentPolicy()).thenAnswer((_) async => CommunityAttachmentPolicy.legacy);
  when(() => support.checkSensitive(any())).thenAnswer((_) async => const SensitiveCheck());
}

void stubOpenTicket(MockSupport support, SupportTicket ticket) => when(
  () => support.openTicket(
    topic: any(named: 'topic'),
    language: any(named: 'language'),
    screen: any(named: 'screen'),
    complaint: any(named: 'complaint'),
    intake: any(named: 'intake'),
  ),
).thenAnswer((_) async => ticket);

Widget supportApp(Widget child, {Locale locale = const Locale('id'), CommunityBuilders? builders}) {
  Widget body = child;
  if (builders != null) body = CommunityBuildersScope(builders: builders, child: body);
  return MaterialApp(
    locale: locale,
    localizationsDelegates: CommunityLocalizations.localizationsDelegates,
    supportedLocales: CommunityLocalizations.supportedLocales,
    home: Scaffold(body: body),
  );
}

Future<FakeChatRepository> pumpSupportChat(
  WidgetTester tester,
  SupportRepository support, {
  FakeChatRepository? chat,
  FakeHelpRepository? help,
  Locale locale = const Locale('id'),
  CommunityBuilders? builders,
}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repository =
      chat ??
      FakeChatRepository(
        rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: DateTime.now(), lastReadAt: DateTime.now())],
      );
  Widget body = CommunitySupportScope(
    dependencies: SupportDeps(support, repository),
    child: const CommunitySupportChat(),
  );
  if (help != null) body = CommunityHelpScope(dependencies: FakeHelpDependencies(help), child: body);
  await tester.pumpWidget(
    supportApp(
      CommunityScope(
        dependencies: FakeDependencies(chat: repository),
        child: body,
      ),
      locale: locale,
      builders: builders,
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}
