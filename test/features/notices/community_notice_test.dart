import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/notifications/data/models/notification_model.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

const _payload = <String, Object?>{
  'notice_id': 'nt-1',
  'banner_id': 'b-1',
  'title': 'Server mock trading',
  'body': 'Server dipakai mock trading malam ini.',
  'level': 'warning',
  'link_url': 'olt://mock-trading',
  'cta_label': 'Buka simulasi',
  'image_url': 'https://cdn.olt.example/mock.png',
  'sent_at': '2026-11-18T12:00:00Z',
};

AppNotification _noticeNotification() => NotificationModel.fromJson({
  'id': 'n-1',
  'type': 'announcement',
  'actor_id': null,
  'payload': _payload,
  'event_count': 1,
  'read_at': null,
  'created_at': '2026-11-18T12:00:00Z',
  'cursor': 'c-1',
}).toEntity()!;

class _Notifications extends FakeNotificationRepository {
  _Notifications(this.items);

  final List<AppNotification> items;

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async => Paged(items);

  @override
  Future<int> unreadCount() async => items.length;

  @override
  Future<void> markRead({List<String>? ids}) async {}
}

void main() {
  test('a notice is read from the notification payload, keeping only http images', () {
    final notice = CommunityNotice.fromJson(_payload, notificationId: 'n-1');
    expect(notice.id, 'nt-1');
    expect(notice.level, CommunityBannerLevel.warning);
    expect(notice.link, Uri.parse('olt://mock-trading'));
    expect(notice.ctaLabel, 'Buka simulasi');
    expect(notice.imageUrl, 'https://cdn.olt.example/mock.png');
    expect(notice.sentAt, DateTime.utc(2026, 11, 18, 12));
    expect(notice.notificationId, 'n-1');
    expect(notice.toBanner().id, 'b-1');
    expect(CommunityNotice.fromJson({..._payload, 'image_url': 'file:///etc/passwd'}).imageUrl, isNull);
    expect(CommunityNotice.fromJson({'id': 'x', 'title': 'Info'}).level, CommunityBannerLevel.info);
  });

  testWidgets('the info page shows the notice and hands its link to onBannerLink', (tester) async {
    final opened = <Uri>[];
    await pumpFeatureApp(
      tester,
      CommunityNoticeView(
        notice: CommunityNotice.fromJson(_payload),
        onBannerLink: (context, uri, banner) async {
          opened.add(uri);
          return true;
        },
      ),
      features: FakeFeatureDependencies(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server mock trading'), findsOneWidget);
    expect(find.text('Server dipakai mock trading malam ini.'), findsOneWidget);
    expect(find.text('Peringatan'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    await tester.tap(find.text('Buka simulasi'));
    await tester.pump();
    expect(opened, [Uri.parse('olt://mock-trading')]);
  });

  testWidgets('a notice without a link has no button', (tester) async {
    await pumpFeatureApp(
      tester,
      const CommunityNoticeView(
        notice: CommunityNotice(id: 'nt-2', title: 'Libur bursa'),
      ),
      features: FakeFeatureDependencies(),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('Info'), findsOneWidget);
  });

  testWidgets('system.notice replaces the info page and receives its details', (tester) async {
    await pumpFeatureApp(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(
          system: CommunitySystemBuilders(
            notice: (context, d, fallback) =>
                TextButton(onPressed: d.onOpen, child: Text('custom ${d.title} ${d.levelLabel} ${d.openLabel}')),
          ),
        ),
        child: CommunityNoticeView(notice: CommunityNotice.fromJson(_payload)),
      ),
      features: FakeFeatureDependencies(),
    );
    await tester.pumpAndSettle();
    expect(find.text('custom Server mock trading Peringatan Buka simulasi'), findsOneWidget);
    expect(find.text('Server dipakai mock trading malam ini.'), findsNothing);
  });

  testWidgets('tapping an info notification opens the in-app info page, not Stream', (tester) async {
    await pumpFeatureApp(
      tester,
      const CommunityNotificationList(),
      dependencies: FakeDependencies(notifications: _Notifications([_noticeNotification()])),
      features: FakeFeatureDependencies(),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);

    await tester.tap(find.text('Server mock trading'));
    await tester.pumpAndSettle();

    expect(find.text('Informasi'), findsOneWidget);
    expect(find.text('Server dipakai mock trading malam ini.'), findsOneWidget);
    expect(find.text('Buka simulasi'), findsOneWidget);
  });

  testWidgets('a notice push loads the info page from the server', (tester) async {
    final features = FakeFeatureDependencies();
    features.notices.notices['nt-9'] = const CommunityNotice(id: 'nt-9', title: 'Pemeliharaan', body: 'Pukul 22.00');
    late bool handled;
    await pumpFeatureApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => handled = openCommunityPush(context, {
            'source': 'rendezvous_community',
            'type': 'announcement',
            'notification_id': 'n-9',
            'notice_id': 'nt-9',
          }),
          child: const Text('push'),
        ),
      ),
      dependencies: FakeDependencies(notifications: _Notifications(const [])),
      features: features,
    );
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(features.notices.requested, ['nt-9']);
    expect(find.text('Pemeliharaan'), findsOneWidget);
    expect(find.text('Pukul 22.00'), findsOneWidget);
  });

  testWidgets('a notice that is gone shows a clear message and can retry', (tester) async {
    final features = FakeFeatureDependencies();
    await pumpFeatureApp(
      tester,
      CommunityNoticePage(noticeId: 'nt-x', repository: features.notices),
      features: features,
    );
    await tester.pumpAndSettle();
    expect(find.text('Informasi ini tidak tersedia lagi.'), findsOneWidget);

    features.notices.notices['nt-x'] = const CommunityNotice(id: 'nt-x', title: 'Sudah ada');
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Sudah ada'), findsOneWidget);
  });
}
