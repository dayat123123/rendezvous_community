import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';

ChatMessage _notice({Map<String, Object?> payload = const {}, String body = 'Tiket diambil oleh Hendi – CS Resmi.'}) =>
    ChatMessage(
      id: 'sys-1',
      roomId: 'r-cs',
      body: body,
      kind: MessageKind.system,
      senderRole: SenderRole.system,
      payload: payload,
      createdAt: DateTime.utc(2026, 11, 6, 7, 54),
    );

const _texts = {
  'code': 'ticket_claimed',
  'texts': {'id': 'Tiket diambil oleh Hendi – CS Resmi.', 'en': 'Your ticket is now handled by Hendi – Official CS.'},
};

Widget _app(Locale locale, ChatMessage message) => MaterialApp(
  locale: locale,
  localizationsDelegates: CommunityLocalizations.localizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  home: Scaffold(body: SupportSystemNotice(message: message)),
);

void main() {
  test('picks the system message text for the app language and falls back to the stored body', () {
    expect(supportNoticeText(_notice(payload: _texts), 'en'), 'Your ticket is now handled by Hendi – Official CS.');
    expect(supportNoticeText(_notice(payload: _texts), 'id'), 'Tiket diambil oleh Hendi – CS Resmi.');
    expect(supportNoticeText(_notice(payload: _texts), 'fr'), 'Tiket diambil oleh Hendi – CS Resmi.');
    expect(supportNoticeText(_notice(), 'en'), 'Tiket diambil oleh Hendi – CS Resmi.');
    expect(
      supportNoticeText(
        _notice(
          payload: const {
            'texts': {'en': '  '},
          },
        ),
        'en',
      ),
      'Tiket diambil oleh Hendi – CS Resmi.',
    );
  });

  testWidgets('a system notice follows a language switch while the chat is open', (tester) async {
    final message = _notice(payload: _texts);
    await tester.pumpWidget(_app(const Locale('id'), message));
    expect(find.text('Tiket diambil oleh Hendi – CS Resmi.'), findsOneWidget);

    await tester.pumpWidget(_app(const Locale('en'), message));
    await tester.pumpAndSettle();
    expect(find.text('Your ticket is now handled by Hendi – Official CS.'), findsOneWidget);
    expect(find.text('Tiket diambil oleh Hendi – CS Resmi.'), findsNothing);
  });
}
