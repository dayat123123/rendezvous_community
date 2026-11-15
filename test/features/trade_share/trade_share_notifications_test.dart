import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/notifications/data/models/notification_model.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/trade_share_fakes.dart';

AppNotification _notification(String id, String type, Map<String, Object?> payload, {UserSummary? actor = alice}) =>
    NotificationModel.fromJson({
      'id': id,
      'type': type,
      'actor_id': actor?.id,
      'actor_username': actor?.username,
      'actor_display_name': actor?.displayName,
      'payload': payload,
      'event_count': 1,
      'read_at': null,
      'created_at': DateTime.now().toUtc().subtract(const Duration(minutes: 3)).toIso8601String(),
      'cursor': 'c-$id',
    }).toEntity()!;

final _activity = _notification('n-trade', 'trade_activity', {
  'activity_id': 'act-9',
  'trader_id': alice.id,
  'stock': 'BBCA',
  'side': 'buy',
  'lots': 25,
  'price': 9150,
  'partial': false,
  'additional': false,
  'text': {
    'id': {'title': r'Alice membeli $BBCA', 'body': '25 lot @ 9.150'},
    'en': {'title': r'Alice bought $BBCA', 'body': '25 lots @ 9,150'},
  },
});

final _approved = _notification('n-approved', 'trade_share', {
  'action': 'approved',
  'status': 'active',
  'title': 'Pengajuan berbagi trade disetujui',
}, actor: null);

final _request = _notification('n-request', 'trade_share', {
  'action': 'subscription_request',
  'subscriber_id': bob.id,
  'title': 'Bob ingin berlangganan trade Anda',
}, actor: bob);

final _rejected = _notification('n-rejected', 'trade_share', {
  'action': 'rejected',
  'status': 'rejected',
  'reason': 'Data belum lengkap',
}, actor: null);

final _follow = _notification('n-follow', 'follow', {'follower_id': bob.id}, actor: bob);

class _Notifications extends FakeNotificationRepository {
  _Notifications(this.items);

  final List<AppNotification> items;
  final marked = <List<String>?>[];

  @override
  Future<Paged<AppNotification>> getNotifications({String? cursor, int limit = 30}) async => Paged(items);

  @override
  Future<int> unreadCount() async => items.length;

  @override
  Future<void> markRead({List<String>? ids}) async => marked.add(ids);
}

Future<FakeTradeShareRepository> _pumpList(
  WidgetTester tester,
  List<AppNotification> items, {
  TradeShareStatus? status,
  bool withTrade = true,
}) async {
  final repo = FakeTradeShareRepository(status: status);
  final trade = FakeTradeShareDependencies(repo);
  addTearDown(trade.dispose);
  final notifications = _Notifications(items);
  addTearDown(notifications.dispose);
  await pumpTradeApp(
    tester,
    const CommunityNotificationList(),
    trade: withTrade ? trade : null,
    dependencies: FakeDependencies(notifications: notifications),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('inbox', () {
    test('trade notification types are parsed', () {
      expect(_activity.type, NotificationType.tradeActivity);
      expect(_activity.isTrade, isTrue);
      expect(_activity.tradeActivityId, 'act-9');
      expect(_request.type, NotificationType.tradeShare);
      expect(_request.tradeAction, 'subscription_request');
      expect(_follow.isTrade, isFalse);
      final activity = TradeActivity.fromPayload(_activity.payload, trader: _activity.actor)!;
      expect(activity.lots, 25);
      expect(activity.trader?.id, alice.id);
    });

    testWidgets('trade items render the server text and the Trade filter separates them', (tester) async {
      await _pumpList(tester, [_activity, _follow, _approved, _rejected, _request]);

      expect(find.text(r'Alice membeli $BBCA'), findsOneWidget);
      expect(find.text('25 lot @ 9.150'), findsOneWidget);
      expect(find.text('Pengajuan berbagi trade disetujui'), findsOneWidget);
      expect(find.text('Pelanggan Anda kini menerima notifikasi trade Anda.'), findsOneWidget);
      expect(find.text('Pengajuan berbagi trade ditolak'), findsOneWidget);
      expect(find.text('Data belum lengkap'), findsOneWidget);
      expect(find.text('Bob ingin berlangganan trade Anda'), findsOneWidget);
      expect(find.text('Bob mulai mengikuti Anda'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('notification-filter-trade')));
      await tester.pumpAndSettle();
      expect(find.text('Bob mulai mengikuti Anda'), findsNothing);
      expect(find.text(r'Alice membeli $BBCA'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('notification-filter-all')));
      await tester.pumpAndSettle();
      expect(find.text('Bob mulai mengikuti Anda'), findsOneWidget);
    });

    testWidgets('the Trade filter shows its own empty state', (tester) async {
      await _pumpList(tester, [_follow]);

      await tester.tap(find.byKey(const ValueKey('notification-filter-trade')));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada notifikasi trade.'), findsOneWidget);
    });

    testWidgets('no filter is offered when the feature is off or not installed', (tester) async {
      await _pumpList(tester, [_follow], status: tradeStatus(enabled: false));
      expect(find.byKey(const ValueKey('notification-filter-trade')), findsNothing);

      await _pumpList(tester, [_follow], withTrade: false);
      expect(find.byKey(const ValueKey('notification-filter-trade')), findsNothing);
    });

    testWidgets('tapping a trade activity opens its detail with the disclaimer', (tester) async {
      final repo = await _pumpList(tester, [_activity]);

      await tester.tap(find.text(r'Alice membeli $BBCA'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('activity'));
      expect(find.text('Detail aktivitas trade'), findsOneWidget);
      expect(find.text('Bukan rekomendasi dari server.'), findsOneWidget);
      expect(find.byKey(const ValueKey('trade-open-stock')), findsOneWidget);
    });

    testWidgets('a subscription request opens the requests of the trader', (tester) async {
      final repo = await _pumpList(tester, [_request]);

      await tester.tap(find.text('Bob ingin berlangganan trade Anda'));
      await tester.pumpAndSettle();

      expect(find.text('Pelanggan trade'), findsOneWidget);
      expect(repo.subscriberQueries.single.$1, TradeSubscriberStatus.pending);
    });

    testWidgets('a status update opens the trade share settings', (tester) async {
      await _pumpList(tester, [_approved]);

      await tester.tap(find.text('Pengajuan berbagi trade disetujui'));
      await tester.pumpAndSettle();

      expect(find.text('Berbagi aktivitas trade'), findsWidgets);
    });

    testWidgets('English uses the English server text', (tester) async {
      final trade = FakeTradeShareDependencies();
      addTearDown(trade.dispose);
      final notifications = _Notifications([_activity]);
      addTearDown(notifications.dispose);
      await pumpTradeApp(
        tester,
        const CommunityNotificationList(),
        trade: trade,
        locale: const Locale('en'),
        dependencies: FakeDependencies(notifications: notifications),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'Alice bought $BBCA'), findsOneWidget);
      expect(find.text('25 lots @ 9,150'), findsOneWidget);
      expect(find.text('Trades'), findsOneWidget);
    });
  });

  group('push', () {
    Future<(FakeTradeShareRepository, List<Map<String, Object?>>)> pumpPush(
      WidgetTester tester,
      Map<String, Object?> data, {
      void Function(bool handled)? onHandled,
    }) async {
      final olt = <Map<String, Object?>>[];
      final repo = FakeTradeShareRepository();
      final trade = FakeTradeShareDependencies(repo);
      addTearDown(trade.dispose);
      final notifications = _Notifications(const []);
      addTearDown(notifications.dispose);
      await pumpTradeApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              final handled = openCommunityPush(context, data);
              onHandled?.call(handled);
            },
            child: const Text('push'),
          ),
        ),
        trade: trade,
        dependencies: FakeDependencies(
          notifications: notifications,
          callbacks: CommunityCallbacks(onOltNotificationTap: (_, payload) => olt.add(payload)),
        ),
      );
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();
      return (repo, olt);
    }

    testWidgets('a trade activity push opens the detail', (tester) async {
      late bool handled;
      final (repo, _) = await pumpPush(tester, {
        'source': 'rendezvous_community',
        'type': 'trade_activity',
        'kind': 'trade_activity',
        'activity_id': 'act-7',
        'trader_id': alice.id,
        'stock': 'BBCA',
      }, onHandled: (value) => handled = value);

      expect(handled, isTrue);
      expect(isCommunityPush({'source': 'rendezvous_community', 'type': 'trade_activity'}), isTrue);
      expect(repo.calls, contains('activity'));
      expect(find.text('Detail aktivitas trade'), findsOneWidget);
    });

    testWidgets('trade share pushes open the subscribers or the settings', (tester) async {
      final (repo, _) = await pumpPush(tester, {
        'source': 'rendezvous_community',
        'type': 'trade_share',
        'action': 'subscription_request',
        'screen': 'trade_subscribers',
      });
      expect(find.text('Pelanggan trade'), findsOneWidget);
      expect(repo.subscriberQueries.single.$1, TradeSubscriberStatus.pending);
    });

    testWidgets('a decision push opens the trade share settings', (tester) async {
      await pumpPush(tester, {
        'source': 'rendezvous_community',
        'type': 'trade_share',
        'action': 'approved',
        'screen': 'trade_share_settings',
      });

      expect(find.text('Berbagi aktivitas trade'), findsWidgets);
    });

    testWidgets('an approved subscription push opens the trader profile', (tester) async {
      late bool handled;
      await pumpPush(tester, {
        'source': 'rendezvous_community',
        'type': 'trade_share',
        'action': 'subscription_approved',
        'trader_id': alice.id,
      }, onHandled: (value) => handled = value);

      expect(handled, isTrue);
      expect(find.byType(CommunityUserProfile), findsOneWidget);
    });

    testWidgets('the owner trade push stays with the OLT handler', (tester) async {
      late bool handled;
      final (_, olt) = await pumpPush(tester, {
        'kind': 'olt.trade.matched',
        'type': 'trade_matched',
        'screen': '/trade-list',
        'stock': 'BBCA',
        'side': 'buy',
      }, onHandled: (value) => handled = value);

      expect(handled, isTrue);
      expect(olt.single['screen'], '/trade-list');
      expect(find.text('Detail aktivitas trade'), findsNothing);
    });
  });

  group('notification settings', () {
    Future<void> pumpSettings(WidgetTester tester, TradeShareStatus status) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.notificationPreferences.preferences = const NotificationPreferences(
        types: [
          NotificationTypePreference(type: 'like', inApp: true),
          NotificationTypePreference(type: 'trade_activity', inApp: true),
          NotificationTypePreference(type: 'trade_share', inApp: true),
          NotificationTypePreference(type: 'olt.trade', inApp: true),
        ],
      );
      final trade = FakeTradeShareDependencies(FakeTradeShareRepository(status: status));
      addTearDown(trade.dispose);
      await pumpFeatureApp(
        tester,
        CommunityTradeShareScope(
          dependencies: trade,
          child: const SingleChildScrollView(child: CommunityNotificationSettings()),
        ),
        features: features,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('trade types are labelled while the feature is on', (tester) async {
      await pumpSettings(tester, tradeStatus());

      expect(find.text('Aktivitas trade'), findsOneWidget);
      expect(find.text('Trade dari trader yang Anda langgan'), findsOneWidget);
      expect(find.text('Berbagi trade'), findsOneWidget);
      expect(find.text('Status pengajuan dan permintaan langganan'), findsOneWidget);
      expect(find.text('trade_activity'), findsNothing);
    });

    testWidgets('trade types are hidden when the feature is off', (tester) async {
      await pumpSettings(tester, tradeStatus(enabled: false));

      expect(find.text('Aktivitas trade'), findsNothing);
      expect(find.text('Berbagi trade'), findsNothing);
      expect(find.text('Transaksi'), findsOneWidget);
    });
  });
}
