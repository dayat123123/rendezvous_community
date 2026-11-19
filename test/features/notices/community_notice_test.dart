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

  group('system.noticeHeader', () {
    Future<void> openPage(WidgetTester tester, {CommunityBuilders? builders}) async {
      Widget opener = Builder(
        builder: (context) => TextButton(
          onPressed: () => openCommunityNotice(context, notice: CommunityNotice.fromJson(_payload)),
          child: const Text('buka info'),
        ),
      );
      if (builders != null) opener = CommunityBuildersScope(builders: builders, child: opener);
      await pumpFeatureApp(tester, opener, features: FakeFeatureDependencies());
      await tester.tap(find.text('buka info'));
      await tester.pumpAndSettle();
    }

    testWidgets('without the slot the info page keeps its app bar', (tester) async {
      await openPage(tester);
      expect(find.byType(CommunityNoticePage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('replaces the app bar and can go back', (tester) async {
      await openPage(
        tester,
        builders: CommunityBuilders(
          system: CommunitySystemBuilders(
            noticeHeader: (context, d, fallback) => Row(
              children: [
                Text('header ${d.title}'),
                if (d.onBack != null) TextButton(onPressed: d.onBack, child: const Text('kembali')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
      expect(find.text('header Informasi'), findsOneWidget);
      expect(find.text('Server mock trading'), findsOneWidget);

      await tester.tap(find.text('kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityNoticePage), findsNothing);
      expect(find.text('buka info'), findsOneWidget);
    });

    test('is kept and overridden by merge', () {
      Widget first(BuildContext context, CommunityNoticeHeaderDetails d, Widget fallback) => fallback;
      Widget second(BuildContext context, CommunityNoticeHeaderDetails d, Widget fallback) => const SizedBox();
      final base = CommunitySystemBuilders(noticeHeader: first);
      expect(base.merge(const CommunitySystemBuilders()).noticeHeader, same(first));
      expect(base.merge(CommunitySystemBuilders(noticeHeader: second)).noticeHeader, same(second));
    });
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

  group('long info text', () {
    const preview = CommunityNotice(
      id: 'nt-long',
      title: 'Pemeliharaan',
      body: 'Mulai pukul 22.00…',
      bodyTruncated: true,
    );
    const full = CommunityNotice(id: 'nt-long', title: 'Pemeliharaan', body: 'Mulai pukul 22.00 sampai 02.00 WIB.');

    test('the notification payload marks a shortened body', () {
      expect(CommunityNotice.fromJson({..._payload, 'body_truncated': true}).bodyTruncated, isTrue);
      expect(CommunityNotice.fromJson(_payload).bodyTruncated, isFalse);
    });

    testWidgets('a shortened body shows at once, then the full text from the server', (tester) async {
      final features = FakeFeatureDependencies();
      features.notices.notices['nt-long'] = full;
      await pumpFeatureApp(
        tester,
        CommunityNoticePage(notice: preview, repository: features.notices),
        features: features,
      );
      expect(find.text('Mulai pukul 22.00…'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(features.notices.requested, ['nt-long']);
      expect(find.text('Mulai pukul 22.00 sampai 02.00 WIB.'), findsOneWidget);
    });

    testWidgets('system.notice receives the full text once it loads', (tester) async {
      final features = FakeFeatureDependencies();
      features.notices.notices['nt-long'] = full;
      await pumpFeatureApp(
        tester,
        CommunityBuildersScope(
          builders: CommunityBuilders(
            system: CommunitySystemBuilders(notice: (context, d, fallback) => Text('custom ${d.body}')),
          ),
          child: CommunityNoticePage(notice: preview, repository: features.notices),
        ),
        features: features,
      );
      await tester.pumpAndSettle();
      expect(find.text('custom Mulai pukul 22.00 sampai 02.00 WIB.'), findsOneWidget);
    });

    testWidgets('a notice that is not shortened, such as one built from a banner, makes no request', (tester) async {
      final features = FakeFeatureDependencies();
      await pumpFeatureApp(
        tester,
        CommunityNoticePage(
          notice: const CommunityNotice(id: 'banner-1', bannerId: 'banner-1', title: 'Strip', body: 'Isi strip'),
          repository: features.notices,
        ),
        features: features,
      );
      await tester.pumpAndSettle();
      expect(features.notices.requested, isEmpty);
      expect(find.text('Isi strip'), findsOneWidget);
    });

    testWidgets('when the full text cannot load the preview stays readable', (tester) async {
      final features = FakeFeatureDependencies();
      await pumpFeatureApp(
        tester,
        CommunityNoticePage(notice: preview, repository: features.notices),
        features: features,
      );
      await tester.pumpAndSettle();
      expect(features.notices.requested, ['nt-long']);
      expect(find.text('Mulai pukul 22.00…'), findsOneWidget);
      expect(find.text('Informasi ini tidak tersedia lagi.'), findsNothing);
    });
  });
}
