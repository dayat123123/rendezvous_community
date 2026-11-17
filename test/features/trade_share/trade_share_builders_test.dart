import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/notifications/data/models/notification_model.dart';

import '../../support/fakes.dart';
import '../../support/trade_share_fakes.dart';

Widget _scoped(CommunityTradeShareBuilders builders, Widget child) => CommunityBuildersScope(
  builders: CommunityBuilders(tradeShare: builders),
  child: child,
);

Future<FakeTradeShareRepository> _pump(
  WidgetTester tester,
  CommunityTradeShareBuilders builders,
  Widget child, {
  FakeTradeShareRepository? repository,
  CommunityDependencies? dependencies,
  bool settle = true,
}) async {
  final repo = repository ?? FakeTradeShareRepository();
  final trade = FakeTradeShareDependencies(repo);
  addTearDown(trade.dispose);
  await pumpTradeApp(
    tester,
    _scoped(builders, child),
    trade: trade,
    dependencies: dependencies,
    size: const Size(900, 3000),
  );
  if (settle) await tester.pumpAndSettle();
  return repo;
}

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

AppNotification _notification(String id, String type, Map<String, Object?> payload) => NotificationModel.fromJson({
  'id': id,
  'type': type,
  'actor_id': alice.id,
  'actor_username': alice.username,
  'actor_display_name': alice.displayName,
  'payload': payload,
  'created_at': DateTime.now().toUtc().toIso8601String(),
  'cursor': 'c-$id',
}).toEntity()!;

void main() {
  test('merge keeps every slot and lets the newer set win', () {
    Widget a<T>(BuildContext c, T d, Widget f) => f;
    Widget b<T>(BuildContext c, T d, Widget f) => const SizedBox();
    final full = CommunityTradeShareBuilders(
      loading: a,
      empty: a,
      error: a,
      unavailable: a,
      statusCard: a,
      checkRow: a,
      preview: a,
      profileBar: a,
      subscriptionTile: a,
      subscriberTile: a,
      activityTile: a,
      activityDetail: a,
    );
    List<Object?> slots(CommunityTradeShareBuilders x) => [
      x.loading,
      x.empty,
      x.error,
      x.unavailable,
      x.statusCard,
      x.checkRow,
      x.preview,
      x.profileBar,
      x.subscriptionTile,
      x.subscriberTile,
      x.activityTile,
      x.activityDetail,
    ];
    expect(slots(const CommunityTradeShareBuilders().merge(full)), slots(full));
    expect(slots(full.merge(const CommunityTradeShareBuilders())), slots(full));
    expect(identical(full.merge(null), full), isTrue);
    final tile = CommunityTradeShareBuilders(activityTile: b);
    expect(full.merge(tile).activityTile, same(tile.activityTile));
    expect(full.merge(tile).profileBar, same(full.profileBar));
    final merged = const CommunityBuilders().merge(CommunityBuilders(tradeShare: tile));
    expect(merged.tradeShare.activityTile, same(tile.activityTile));
  });

  group('settings', () {
    testWidgets('status card, check rows and preview use their slots', (tester) async {
      final repo = await _pump(
        tester,
        CommunityTradeShareBuilders(
          statusCard: (context, d, fallback) => TextButton(onPressed: d.onPause, child: Text('status:${d.label}')),
          checkRow: (context, d, fallback) => Text('check:${d.check.code}:${d.ok}'),
          preview: (context, d, fallback) => Text('preview:${d.title}|${d.body}|${d.showLot}'),
        ),
        const CommunityTradeShareSettings(),
        repository: FakeTradeShareRepository(
          status: tradeStatus(
            status: TradeSharerStatus.active,
            accounts: const [TradeShareAccount(custId: 'W137')],
          ),
        ),
      );

      expect(find.text('status:Aktif'), findsOneWidget);
      expect(find.text(r'preview:Budi Santoso membeli $BBCA|25 lot @ 9.150|true'), findsOneWidget);
      expect(find.text('Punya rekening tertaut yang aktif'), findsNothing);

      repo.nextStatus = tradeStatus(status: TradeSharerStatus.paused, pauseSource: TradePauseSource.user);
      await tester.tap(find.text('status:Aktif'));
      await tester.pumpAndSettle();
      expect(repo.calls, contains('pause'));
      expect(find.text('status:Dijeda'), findsOneWidget);
    });

    testWidgets('eligibility rows use the check slot while the other parts stay default', (tester) async {
      await _pump(
        tester,
        CommunityTradeShareBuilders(checkRow: (context, d, fallback) => Text('check:${d.check.code}:${d.ok}')),
        const CommunityTradeShareSettings(),
      );

      expect(find.text('check:linked_account:true'), findsOneWidget);
      expect(find.text('Belum mengajukan'), findsOneWidget);
      expect(find.text(r'Budi Santoso membeli $BBCA'), findsOneWidget);
    });

    testWidgets('error and unavailable states use their slots', (tester) async {
      final repo = FakeTradeShareRepository()..error = tradeError('network');
      await _pump(
        tester,
        CommunityTradeShareBuilders(
          error: (context, d, fallback) => TextButton(onPressed: d.onRetry, child: Text('error:${d.area.name}')),
          unavailable: (context, d, fallback) => Text('off:${d.message}'),
        ),
        const CommunityTradeShareSettings(),
        repository: repo,
      );
      expect(find.text('error:settings'), findsOneWidget);

      repo
        ..error = null
        ..current = tradeStatus(enabled: false);
      await tester.tap(find.text('error:settings'));
      await tester.pumpAndSettle();
      expect(find.text('off:Fitur berbagi trade sedang tidak tersedia.'), findsOneWidget);
    });
  });

  group('profile bar', () {
    testWidgets('the slot gets the bell state and working actions', (tester) async {
      final repo = await _pump(
        tester,
        CommunityTradeShareBuilders(
          profileBar: (context, d, fallback) => Column(
            children: [
              Text('bar:${d.bell.name}:${d.bellLabel}:${d.sharing}:${d.badgeLabel}'),
              if (d.onSubscribe != null) TextButton(onPressed: d.onSubscribe, child: const Text('ikut')),
              if (d.onMute != null) TextButton(onPressed: d.onMute, child: const Text('bisu')),
            ],
          ),
        ),
        const CommunityTradeShareProfileBar(user: alice),
        repository: FakeTradeShareRepository(
          profile: tradeProfile(
            risk: const TradeShareDocument(id: 'doc-risk', version: 1, title: 'Risiko', body: 'Isi', accepted: true),
          ),
        ),
      );

      expect(find.text('bar:subscribe:Notifikasi trade:true:Membagikan trade'), findsOneWidget);
      expect(find.byKey(const ValueKey('trade-bell')), findsNothing);

      repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active));
      await tester.tap(find.text('ikut'));
      await tester.pumpAndSettle();
      expect(repo.subscribes.single, (alice.id, 'doc-risk'));
      expect(find.text('bar:active:Berlangganan:true:Membagikan trade'), findsOneWidget);

      repo.nextProfile = tradeProfile(
        subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
      );
      await tester.tap(find.text('bisu'));
      await tester.pumpAndSettle();
      expect(repo.mutes.single, (alice.id, true));
      expect(find.text('bar:muted:Dibisukan:true:Membagikan trade'), findsOneWidget);
    });

    testWidgets('without the slot the default badge and bell render', (tester) async {
      await _pump(tester, const CommunityTradeShareBuilders(), const CommunityTradeShareProfileBar(user: alice));

      expect(find.text('Membagikan trade'), findsOneWidget);
      expect(find.byKey(const ValueKey('trade-bell')), findsOneWidget);
    });
  });

  group('lists', () {
    testWidgets('subscription rows use their slot', (tester) async {
      final repo = FakeTradeShareRepository()
        ..subscriptionItems = const [
          TradeSubscriptionEntry(
            trader: alice,
            subscription: TradeSubscription(status: TradeSubscriptionStatus.active),
            cursor: 'c-1',
          ),
        ];
      await _pump(
        tester,
        CommunityTradeShareBuilders(
          subscriptionTile: (context, d, fallback) => TextButton(
            onPressed: d.onToggleMute,
            child: Text('sub:${d.trader.name}:${d.statusLabel}:${d.muteLabel}'),
          ),
        ),
        const CommunityTradeSubscriptions(),
        repository: repo,
      );

      expect(find.text('sub:Alice:Berlangganan:Bisukan notifikasi trade'), findsOneWidget);
      repo.nextProfile = tradeProfile(
        subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
      );
      await tester.tap(find.textContaining('sub:Alice'));
      await tester.pumpAndSettle();
      expect(repo.mutes.single, (alice.id, true));
      expect(find.text('Aktivitas trade'), findsOneWidget);
    });

    testWidgets('subscriber rows use their slot', (tester) async {
      final repo = FakeTradeShareRepository()
        ..subscriberItems = {
          TradeSubscriberStatus.pending: [
            const TradeSubscriberEntry(subscriber: bob, status: TradeSubscriptionStatus.pending, cursor: 'p-1'),
          ],
        };
      await _pump(
        tester,
        CommunityTradeShareBuilders(
          subscriberTile: (context, d, fallback) => TextButton(
            onPressed: d.onApprove,
            child: Text('subscriber:${d.subscriber.name}:${d.pending}:${d.onRemove == null}'),
          ),
        ),
        const CommunityTradeSubscribers(initialRequests: true),
        repository: repo,
      );

      await tester.tap(find.text('subscriber:Bob:true:true'));
      await tester.pumpAndSettle();
      expect(repo.decisions.single, (bob.id, true));
    });

    testWidgets('empty lists use the empty slot with their area', (tester) async {
      await _pump(
        tester,
        CommunityTradeShareBuilders(empty: (context, d, fallback) => Text('empty:${d.area.name}:${d.message}')),
        const CommunityTradeSubscriptions(showActivityLink: false),
      );

      expect(find.text('empty:subscriptions:Anda belum berlangganan trader mana pun.'), findsOneWidget);
    });
  });

  group('activity', () {
    testWidgets('feed tiles and the detail use their slots, and the stock action reaches onStockTap', (tester) async {
      final stocks = <String>[];
      final repo = FakeTradeShareRepository()..feedItems = [tradeActivity()];
      await _pump(
        tester,
        CommunityTradeShareBuilders(
          activityTile: (context, d, fallback) =>
              TextButton(onPressed: d.onTap, child: Text('tile:${d.placement.name}:${d.title}:${d.body}')),
          activityDetail: (context, d, fallback) => Column(
            children: [
              Text('detail:${d.disclaimer}:${d.facts.length}:${d.openStockLabel}'),
              TextButton(onPressed: d.onOpenStock, child: const Text('saham')),
            ],
          ),
        ),
        const CommunityTradeActivityFeed(),
        repository: repo,
        dependencies: FakeDependencies(callbacks: CommunityCallbacks(onStockTap: (_, code) => stocks.add(code))),
      );

      expect(find.text(r'tile:feed:Alice membeli $BBCA:25 lot @ 9.150'), findsOneWidget);
      await tester.tap(find.textContaining('tile:feed'));
      await tester.pumpAndSettle();

      expect(find.text(r'detail:Bukan rekomendasi dari server.:5:Buka $BBCA'), findsOneWidget);
      expect(find.byKey(const ValueKey('trade-disclaimer')), findsNothing);
      await tester.tap(find.text('saham'));
      await tester.pump();
      expect(stocks, ['BBCA']);
    });

    testWidgets('the loading state uses its slot', (tester) async {
      await _pump(
        tester,
        CommunityTradeShareBuilders(loading: (context, d, fallback) => Text('loading:${d.area.name}')),
        const CommunityTradeActivityDetail(activityId: 'act-1'),
        settle: false,
      );

      expect(find.text('loading:activityDetail'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('trade-disclaimer')), findsOneWidget);
    });

    testWidgets('trade notifications use the activity tile slot with the notification placement', (tester) async {
      final notifications = _Notifications([
        _notification('n-trade', 'trade_activity', {
          'activity_id': 'act-9',
          'stock': 'BBCA',
          'side': 'sell',
          'text': {
            'id': {'title': r'Alice menjual $BBCA', 'body': '5 lot'},
          },
        }),
        _notification('n-follow', 'follow', {'follower_id': alice.id}),
      ]);
      addTearDown(notifications.dispose);
      await _pump(
        tester,
        CommunityTradeShareBuilders(
          activityTile: (context, d, fallback) =>
              Text('tile:${d.placement.name}:${d.notification?.id}:${d.title}:${d.isRead}'),
        ),
        const CommunityNotificationList(),
        dependencies: FakeDependencies(notifications: notifications),
      );

      expect(find.text(r'tile:notification:n-trade:Alice menjual $BBCA:false'), findsOneWidget);
      expect(find.text('Alice mulai mengikuti Anda'), findsOneWidget);
    });

    testWidgets('without the slot trade notifications keep the default notification row', (tester) async {
      final notifications = _Notifications([
        _notification('n-trade', 'trade_activity', {
          'activity_id': 'act-9',
          'stock': 'BBCA',
          'side': 'buy',
          'text': {
            'id': {'title': r'Alice membeli $BBCA', 'body': '5 lot'},
          },
        }),
      ]);
      addTearDown(notifications.dispose);
      await _pump(
        tester,
        const CommunityTradeShareBuilders(),
        const CommunityNotificationList(),
        dependencies: FakeDependencies(notifications: notifications),
      );

      expect(find.text(r'Alice membeli $BBCA'), findsOneWidget);
      expect(find.byType(CommunityAvatar), findsOneWidget);
    });
  });
}
