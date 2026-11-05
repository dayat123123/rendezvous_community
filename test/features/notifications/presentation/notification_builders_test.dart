import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../../support/fakes.dart';
import '../../../support/feature_fakes.dart';

class _Notifications extends FakeNotificationRepository {
  _Notifications(this.items);

  final List<AppNotification> items;

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async => Paged(items);

  @override
  Future<int> unreadCount() async => items.where((n) => !n.isRead).length;

  @override
  Future<void> markRead({List<String>? ids}) async {}
}

final _items = [
  AppNotification(
    id: 'n-1',
    type: NotificationType.reply,
    actor: alice,
    payload: const {'post_id': 'p-1', 'snippet': 'Setuju, valuasi masih wajar'},
    createdAt: now.subtract(const Duration(minutes: 5)),
    cursor: 'c-1',
  ),
  AppNotification(
    id: 'n-2',
    type: NotificationType.announcement,
    payload: const {'source': 'olt', 'kind': 'olt.info', 'category': 'important', 'title': 'Pemeliharaan sistem'},
    readAt: now,
    createdAt: now.subtract(const Duration(hours: 2)),
    cursor: 'c-2',
  ),
];

void main() {
  test('merge keeps every slot including icon', () {
    Widget a<T>(BuildContext c, T d, Widget f) => f;
    final full = CommunityNotificationBuilders(item: a, header: a, loading: a, empty: a, error: a, icon: a);
    final merged = const CommunityNotificationBuilders().merge(full);
    expect(merged.icon, same(full.icon));
    expect(merged.item, same(full.item));
    expect(full.merge(const CommunityNotificationBuilders()).icon, same(full.icon));
    Widget b<T>(BuildContext c, T d, Widget f) => const SizedBox();
    expect(full.merge(CommunityNotificationBuilders(icon: b)).icon, isNot(same(full.icon)));
    final sectioned = CommunityNotificationBuilders(section: a);
    expect(const CommunityNotificationBuilders().merge(sectioned).section, same(sectioned.section));
    expect(sectioned.merge(const CommunityNotificationBuilders()).section, same(sectioned.section));
  });

  testWidgets('unread rows sit under "Baru" and read rows under "Sebelumnya"', (tester) async {
    final repo = _Notifications(_items);
    await pumpFeatureApp(
      tester,
      const CommunityNotificationList(),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    final fresh = tester.getTopLeft(find.text('Baru')).dy;
    final reply = tester.getTopLeft(find.text('Alice membalas Anda')).dy;
    final earlier = tester.getTopLeft(find.text('Sebelumnya')).dy;
    final olt = tester.getTopLeft(find.text('Pemeliharaan sistem')).dy;
    expect(fresh, lessThan(reply));
    expect(reply, lessThan(earlier));
    expect(earlier, lessThan(olt));
    final title = tester.widget<Text>(find.text('Alice membalas Anda'));
    final spans = (title.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.firstWhere((s) => s.text == 'Alice').style?.fontWeight, FontWeight.w700);
    await repo.dispose();
  });

  testWidgets('without unread rows there are no section headers', (tester) async {
    final repo = _Notifications([_items.last]);
    await pumpFeatureApp(
      tester,
      const CommunityNotificationList(),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Baru'), findsNothing);
    expect(find.text('Sebelumnya'), findsNothing);
    expect(find.text('Pemeliharaan sistem'), findsOneWidget);
    await repo.dispose();
  });

  testWidgets('section builder replaces the group headers', (tester) async {
    final repo = _Notifications(_items);
    final seen = <CommunityNotificationSection>[];
    await pumpFeatureApp(
      tester,
      CommunityNotificationList(
        builders: CommunityNotificationBuilders(
          section: (context, d, fallback) {
            seen.add(d.section);
            return Text('S:${d.title}');
          },
        ),
      ),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('S:Baru'), findsOneWidget);
    expect(find.text('S:Sebelumnya'), findsOneWidget);
    expect(find.text('Baru'), findsNothing);
    expect(seen.toSet(), {CommunityNotificationSection.newer, CommunityNotificationSection.earlier});
    await repo.dispose();
  });

  testWidgets('fallback rows show the type icon, unread marker and time', (tester) async {
    final repo = _Notifications(_items);
    await pumpFeatureApp(
      tester,
      const CommunityNotificationList(),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice membalas Anda'), findsOneWidget);
    expect(find.text('Setuju, valuasi masih wajar'), findsOneWidget);
    expect(find.text('Pemeliharaan sistem'), findsOneWidget);
    expect(find.byIcon(Icons.reply), findsOneWidget);
    expect(find.byIcon(Icons.notification_important_outlined), findsOneWidget);
    expect(find.byType(CommunityAvatar), findsOneWidget);
    expect(find.text('Tandai semua dibaca'), findsOneWidget);
    await repo.dispose();
  });

  testWidgets('icon builder replaces only the type indicator', (tester) async {
    final repo = _Notifications(_items);
    final seen = <CommunityNotificationIconDetails>[];
    await pumpFeatureApp(
      tester,
      CommunityNotificationList(
        builders: CommunityNotificationBuilders(
          icon: (context, d, fallback) {
            seen.add(d);
            return Text('I:${d.notification.id}:${d.important}:${d.isOlt}');
          },
        ),
      ),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('I:n-1:false:false'), findsOneWidget);
    expect(find.text('I:n-2:true:true'), findsOneWidget);
    expect(find.text('Alice membalas Anda'), findsOneWidget);
    expect(seen.firstWhere((d) => d.notification.id == 'n-1').size, lessThan(32));
    await repo.dispose();
  });

  testWidgets('item and header builders still win over the default row', (tester) async {
    final repo = _Notifications(_items);
    await pumpFeatureApp(
      tester,
      CommunityNotificationList(
        builders: CommunityNotificationBuilders(
          item: (context, d, fallback) => Text('N:${d.title}:${d.isRead}'),
          header: (context, d, fallback) => Text('U:${d.unread}'),
          icon: (context, d, fallback) => const Text('unused'),
        ),
      ),
      dependencies: FakeDependencies(notifications: repo),
    );
    await tester.pumpAndSettle();

    expect(find.text('N:Alice membalas Anda:false'), findsOneWidget);
    expect(find.text('N:Pemeliharaan sistem:true'), findsOneWidget);
    expect(find.text('U:1'), findsOneWidget);
    expect(find.text('unused'), findsNothing);
    await repo.dispose();
  });
}
