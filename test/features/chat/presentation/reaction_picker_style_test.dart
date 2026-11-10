import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/chat_app.dart';
import '../../../support/fakes.dart';
import '../../../support/feature_fakes.dart';

Future<FakeFeatureDependencies> _pumpRoom(WidgetTester tester) async {
  useScreen(tester, const Size(900, 900));
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  final chat = FakeChatRepository(
    rooms: [directRoom()],
    members: directMembers(),
    messages: [
      ChatMessage(
        id: 'm-1',
        roomId: 'dm',
        senderId: alice.id,
        sender: alice,
        body: 'Halo kak',
        createdAt: chatStart.add(const Duration(minutes: 1)),
      ),
    ],
  );
  addTearDown(chat.dispose);
  await pumpFeatureApp(
    tester,
    const CommunityChatRoom(roomId: 'dm'),
    dependencies: FakeDependencies(chat: chat),
    features: features,
  );
  await tester.pumpAndSettle();
  return features;
}

Future<void> _openPicker(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.text('Halo kak')));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Beri reaksi').hitTestable());
  await tester.pumpAndSettle();
}

final _desktop = TargetPlatformVariant.only(TargetPlatform.windows);

Finder _emoji(String emoji) => find.descendant(of: find.byType(ReactionPicker), matching: find.text(emoji));

Finder _cell(String emoji) => find.ancestor(of: _emoji(emoji), matching: find.byType(SizedBox)).first;

void main() {
  testWidgets('the hover reaction menu draws emoji at full opacity', (tester) async {
    await _pumpRoom(tester);
    await _openPicker(tester);

    for (final emoji in defaultMessageReactions) {
      final text = tester.widget<RichText>(find.descendant(of: _emoji(emoji), matching: find.byType(RichText)));
      expect(text.text.style!.color!.a, 1, reason: emoji);
    }
  }, variant: _desktop);

  testWidgets('the reaction picker stays compact', (tester) async {
    await _pumpRoom(tester);
    await _openPicker(tester);

    final first = tester.getRect(_cell('👍'));
    final last = tester.getRect(_cell('🔥'));
    expect(first.size, const Size.square(36));
    expect(last.right - first.left, lessThanOrEqualTo(240));
    final text = tester.widget<RichText>(find.descendant(of: _emoji('👍'), matching: find.byType(RichText)));
    expect(text.text.style!.fontSize, 20);
  }, variant: _desktop);

  testWidgets('picking an emoji from the hover menu reacts and closes the menu', (tester) async {
    final features = await _pumpRoom(tester);
    await _openPicker(tester);

    await tester.tap(_emoji('🔥'));
    await tester.pumpAndSettle();

    expect(features.chatExtras.reactions, [('m-1', '🔥')]);
    expect(find.byType(ReactionPicker), findsNothing);
  }, variant: _desktop);
}
