import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';

final _sentAt = DateTime.now().subtract(const Duration(minutes: 30));

Widget _styled(CommunityStyle Function(CommunityStyle style) customize, Widget child) => Builder(
  builder: (context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(extensions: [customize(CommunityStyle.fallback(theme))]),
      child: child,
    );
  },
);

Widget _menuApp(CommunityStyle Function(CommunityStyle style) customize) => MaterialApp(
  home: Scaffold(
    body: _styled(
      customize,
      PopupMenuButton<String>(
        itemBuilder: (menuContext) => [
          communityMenuItem(menuContext, value: 'edit', icon: Icons.edit_outlined, label: 'Ubah'),
          communityMenuItem(menuContext, value: 'plain', label: 'Tanpa ikon'),
          communityMenuItem(menuContext, value: 'delete', icon: Icons.delete_outlined, label: 'Hapus', danger: true),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('popup menu items follow menuItemHeight and menuIconSize, with or without an icon', (tester) async {
    for (final (height, iconSize) in [(36.0, 17.0), (44.0, 20.0)]) {
      await tester.pumpWidget(_menuApp((s) => s.copyWith(menuItemHeight: height, menuIconSize: iconSize)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      for (final label in ['Ubah', 'Tanpa ikon', 'Hapus']) {
        expect(tester.getSize(find.widgetWithText(PopupMenuItem<String>, label)).height, height, reason: label);
      }
      expect(tester.widget<Icon>(find.byIcon(Icons.edit_outlined)).size, iconSize);
      expect(tester.widget<Text>(find.text('Ubah')).style?.fontSize, 12);

      await tester.tapAt(const Offset(400, 500));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the default style uses 36 high items, secondary icons and the danger color', (tester) async {
    late CommunityStyle style;
    await tester.pumpWidget(
      _menuApp((s) {
        style = s;
        return s;
      }),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(style.menuItemHeight, 36);
    expect(style.menuIconSize, 17);
    expect(style.icons, const CommunityIcons());
    expect(tester.widget<Icon>(find.byIcon(Icons.edit_outlined)).color, style.textSecondary);
    expect(tester.widget<Text>(find.text('Ubah')).style?.color, style.textPrimary);
    expect(tester.widget<Icon>(find.byIcon(Icons.delete_outlined)).color, style.danger);
    expect(tester.widget<Text>(find.text('Hapus')).style?.color, style.danger);
  });

  testWidgets('the message menu uses the icons from CommunityStyle and the danger color for delete', (tester) async {
    useScreen(tester, const Size(500, 900));
    const danger = Color(0xFFAA0011);
    const icons = CommunityIcons(
      reply: Icons.keyboard_return,
      copy: Icons.file_copy,
      delete: Icons.dangerous,
      moreVertical: Icons.menu,
    );
    final chat = FakeChatRepository(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'dm',
          senderId: me.id,
          sender: me,
          body: 'Order sudah saya kirim',
          createdAt: _sentAt,
        ),
      ],
    );
    addTearDown(chat.dispose);
    await pumpChat(
      tester,
      chat,
      _styled((s) => s.copyWith(icons: icons, danger: danger), const CommunityChatRoom(roomId: 'dm')),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Order sudah saya kirim')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.keyboard_return).hitTestable(), findsOneWidget);
    expect(find.descendant(of: find.byTooltip('Lainnya'), matching: find.byIcon(Icons.menu)), findsOneWidget);

    await tester.tap(find.byTooltip('Lainnya').hitTestable());
    await tester.pumpAndSettle();

    Finder inItem(String label, IconData icon) =>
        find.descendant(of: find.widgetWithText(PopupMenuItem<VoidCallback>, label), matching: find.byIcon(icon));
    expect(inItem('Balas pesan', Icons.keyboard_return), findsOneWidget);
    expect(inItem('Salin', Icons.file_copy), findsOneWidget);
    expect(tester.widget<Icon>(inItem('Hapus', Icons.dangerous)).color, danger);
    expect(tester.widget<Icon>(inItem('Salin', Icons.file_copy)).color, isNot(danger));
    final deleteLabel = find.descendant(
      of: find.widgetWithText(PopupMenuItem<VoidCallback>, 'Hapus'),
      matching: find.text('Hapus'),
    );
    expect(tester.widget<Text>(deleteLabel).style?.color, danger);
    expect(tester.getSize(find.widgetWithText(PopupMenuItem<VoidCallback>, 'Salin')).height, 36);
  });

  testWidgets('the mobile message sheet uses the custom icons and keeps touch-sized rows', (tester) async {
    useScreen(tester, const Size(500, 900));
    final chat = FakeChatRepository(
      rooms: [directRoom()],
      members: directMembers(),
      messages: [
        ChatMessage(
          id: 'm-1',
          roomId: 'dm',
          senderId: me.id,
          sender: me,
          body: 'Order sudah saya kirim',
          createdAt: _sentAt,
        ),
      ],
    );
    addTearDown(chat.dispose);
    await pumpChat(
      tester,
      chat,
      _styled(
        (s) => s.copyWith(icons: const CommunityIcons(copy: Icons.file_copy)),
        const CommunityChatRoom(roomId: 'dm'),
      ),
    );

    await tester.longPress(find.text('Order sudah saya kirim'));
    await tester.pumpAndSettle();

    final copy = find.widgetWithText(ListTile, 'Salin');
    expect(find.descendant(of: copy, matching: find.byIcon(Icons.file_copy)), findsOneWidget);
    expect(tester.getSize(copy).height, greaterThanOrEqualTo(48));
  });
}
