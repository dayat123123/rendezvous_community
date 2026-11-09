import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/help_fakes.dart';

class _MockSupport extends Mock implements SupportRepository {}

class _SupportDeps implements CommunitySupportDependencies {
  _SupportDeps(this.support, this.supportChat);

  @override
  final SupportRepository support;
  @override
  final ChatRepository supportChat;
}

const _topics = [
  SupportTopic(code: 'account', name: 'Akun & Login', icon: 'account'),
  SupportTopic(code: 'funds', name: 'Deposit/Tarik Dana'),
];

SupportTicket _ticket() => SupportTicket(
  id: 't-1',
  ticketNumber: 'CS-20261109-0001',
  roomId: 'r-cs',
  topic: 'account',
  status: SupportStatus.open,
  createdAt: DateTime.utc(2026, 11, 9),
);

void main() {
  late _MockSupport support;
  late FakeHelpRepository help;

  setUp(() {
    support = _MockSupport();
    help = FakeHelpRepository(suggestions: const [pinArticle, loginArticle]);
    when(() => support.topics(language: any(named: 'language'))).thenAnswer((_) async => _topics);
    when(() => support.home()).thenAnswer((_) async => const SupportHome(supportName: 'CS OLT'));
    when(() => support.watchTicket(any())).thenAnswer((_) => const Stream.empty());
    when(
      () => support.openTicket(
        topic: any(named: 'topic'),
        language: any(named: 'language'),
        screen: any(named: 'screen'),
        complaint: any(named: 'complaint'),
      ),
    ).thenAnswer((_) async => _ticket());
  });

  void verifyOpened(String topic) => verify(
    () => support.openTicket(
      topic: topic,
      language: any(named: 'language'),
      screen: any(named: 'screen'),
      complaint: any(named: 'complaint'),
    ),
  ).called(1);

  void verifyNotOpened() => verifyNever(
    () => support.openTicket(
      topic: any(named: 'topic'),
      language: any(named: 'language'),
      screen: any(named: 'screen'),
      complaint: any(named: 'complaint'),
    ),
  );

  Future<FakeChatRepository> pump(WidgetTester tester, {bool withHelp = true}) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final chat = FakeChatRepository();
    Widget body = CommunitySupportScope(dependencies: _SupportDeps(support, chat), child: const CommunitySupportChat());
    if (withHelp) body = CommunityHelpScope(dependencies: FakeHelpDependencies(help), child: body);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityScope(
            dependencies: FakeDependencies(chat: chat),
            child: body,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return chat;
  }

  testWidgets('after picking a topic, up to three articles are suggested before the ticket is created', (tester) async {
    final chat = await pump(tester);

    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    expect(help.topicLookups, ['account']);
    expect(find.text('Mungkin ini membantu'), findsOneWidget);
    expect(find.textContaining('Akun & Login. Bila belum terjawab'), findsOneWidget);
    expect(find.text('Bagaimana cara mengganti PIN?'), findsOneWidget);
    expect(find.text('Tidak bisa masuk ke aplikasi'), findsOneWidget);
    verifyNotOpened();

    await tester.tap(find.text('Lanjut chat dengan CS'));
    await tester.pumpAndSettle();
    verifyOpened('account');
    await chat.dispose();
  });

  testWidgets('choose another topic returns to the picker without creating a ticket', (tester) async {
    final chat = await pump(tester);
    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pilih topik lain'));
    await tester.pumpAndSettle();

    expect(find.text('Mungkin ini membantu'), findsNothing);
    expect(find.text('Deposit/Tarik Dana'), findsOneWidget);
    verifyNotOpened();
    await chat.dispose();
  });

  testWidgets('a suggested article opens, and its CS chat button returns and creates the ticket', (tester) async {
    final chat = await pump(tester);
    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bagaimana cara mengganti PIN?'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah ini membantu?'), findsOneWidget);
    await tester.tap(find.text('Chat CS'));
    await tester.pumpAndSettle();

    expect(find.text('Apakah ini membantu?'), findsNothing);
    verifyOpened('account');
    await chat.dispose();
  });

  testWidgets('when suggestions fail, the ticket is created right away as before', (tester) async {
    help.suggestionError = const CommunityException(CommunityErrorKind.network);
    final chat = await pump(tester);

    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    expect(find.text('Mungkin ini membantu'), findsNothing);
    verifyOpened('account');
    await chat.dispose();
  });

  testWidgets('when a topic has no articles, the ticket is created right away', (tester) async {
    help.suggestions = const [];
    final chat = await pump(tester);

    await tester.tap(find.text('Deposit/Tarik Dana'));
    await tester.pumpAndSettle();

    expect(find.text('Mungkin ini membantu'), findsNothing);
    verifyOpened('funds');
    await chat.dispose();
  });

  testWidgets('a slow suggestion request does not hold the customer longer than the timeout', (tester) async {
    help.holdSuggestions = Completer<List<HelpArticle>>();
    final chat = await pump(tester);

    await tester.tap(find.text('Akun & Login'));
    await tester.pump(const Duration(seconds: 1));
    verifyNotOpened();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    verifyOpened('account');
    expect(find.text('Mungkin ini membantu'), findsNothing);
    await chat.dispose();
  });

  testWidgets('without a help repository the picker behaves exactly as before', (tester) async {
    final chat = await pump(tester, withHelp: false);

    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    expect(help.topicLookups, isEmpty);
    verifyOpened('account');
    await chat.dispose();
  });

  testWidgets('the suggestions step can be replaced through the help builders', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final chat = FakeChatRepository();
    CommunityHelpSuggestionsDetails? seen;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: CommunityBuildersScope(
          builders: CommunityBuilders(
            help: CommunityHelpBuilders(
              topicSuggestions: (context, d, fallback) {
                seen = d;
                return TextButton(onPressed: d.onContinue, child: Text('${d.articles.length} saran'));
              },
            ),
          ),
          child: Scaffold(
            body: CommunityScope(
              dependencies: FakeDependencies(chat: chat),
              child: CommunityHelpScope(
                dependencies: FakeHelpDependencies(help),
                child: CommunitySupportScope(
                  dependencies: _SupportDeps(support, chat),
                  child: const CommunitySupportChat(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Akun & Login'));
    await tester.pumpAndSettle();

    expect(seen?.topicCode, 'account');
    expect(seen?.topic?.name, 'Akun & Login');
    await tester.tap(find.text('2 saran'));
    await tester.pumpAndSettle();
    verifyOpened('account');
    await chat.dispose();
  });
}
