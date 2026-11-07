import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

List<String> _tappable(WidgetTester tester) {
  final spans = <String>[];
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.recognizer != null) spans.add(span.text!);
      return true;
    });
  }
  return spans;
}

void main() {
  testWidgets('SocialText makes emails, Indonesian phone numbers and www links tappable', (tester) async {
    await pumpFeatureApp(
      tester,
      const SocialText('Email cs@olt.test, telepon 0812-3456-7890, situs www.olt.co.id. Tiket CS-20261107-0003'),
    );
    expect(_tappable(tester), ['cs@olt.test', '0812-3456-7890', 'www.olt.co.id']);
  });

  testWidgets('tapping an email offers to send an email or copy it', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpFeatureApp(tester, const SocialText('Kirim ke cs@olt.test ya'));

    await tester.tapOnText(find.textRange.ofSubstring('cs@olt.test'));
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    expect(find.descendant(of: dialog, matching: find.text('cs@olt.test')), findsOneWidget);
    expect(find.descendant(of: dialog, matching: find.text('Kirim email')), findsOneWidget);

    await tester.tap(find.descendant(of: dialog, matching: find.text('Salin')));
    await tester.pumpAndSettle();
    expect(copied, ['cs@olt.test']);
    expect(find.text('Email disalin'), findsOneWidget);
  });

  testWidgets('the call action opens the tel link with the plain number', (tester) async {
    final opened = <Uri>[];
    await pumpFeatureApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showCommunityContactActions(
            context,
            Uri.parse('tel:081234567890'),
            launcher: (uri) async {
              opened.add(uri);
              return true;
            },
          ),
          child: const Text('go'),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('081234567890'), findsOneWidget);
    await tester.tap(find.text('Telepon'));
    await tester.pumpAndSettle();
    expect(opened.single.toString(), 'tel:081234567890');
  });

  testWidgets('the contactActions builder replaces the dialog', (tester) async {
    CommunityContactActionsDetails? seen;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: CommunityBuildersScope(
          builders: CommunityBuilders(
            shared: CommunitySharedBuilders(
              contactActions: (context, d, fallback) {
                seen = d;
                return Dialog(
                  child: TextButton(onPressed: d.onCancel, child: Text('C:${d.value}:${d.phone}')),
                );
              },
            ),
          ),
          child: Scaffold(
            body: CommunityScope(dependencies: FakeDependencies(), child: const SocialText('Hubungi 081234567890')),
          ),
        ),
      ),
    );
    await tester.tapOnText(find.textRange.ofSubstring('081234567890'));
    await tester.pumpAndSettle();
    expect(find.text('C:081234567890:true'), findsOneWidget);
    expect(seen!.openLabel, 'Telepon');
    await tester.tap(find.text('C:081234567890:true'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('customer service chat bubbles make links, emails and phone numbers tappable', (tester) async {
    useScreen(tester, const Size(500, 900));
    final chat = FakeChatRepository(
      rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: chatStart, lastReadAt: chatStart)],
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'r-cs',
          senderId: alice.id,
          sender: alice,
          senderRole: SenderRole.agent,
          body: r'Koneksi https://greenvest.olt.test:29001, email cs@olt.test, telepon 021-5091234, $BBCA @budi',
          createdAt: chatStart,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: CommunityLocalizations.localizationsDelegates,
        supportedLocales: CommunityLocalizations.supportedLocales,
        home: Scaffold(
          body: CommunityScope(
            dependencies: FakeDependencies(chat: chat),
            child: CommunityChatRoom(roomId: 'r-cs', repository: chat, showHeader: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_tappable(tester), containsAllInOrder(['https://greenvest.olt.test:29001', 'cs@olt.test', '021-5091234']));
    expect(_tappable(tester), isNot(contains(r'$BBCA')));
    expect(_tappable(tester), isNot(contains('@budi')));
  });
}
