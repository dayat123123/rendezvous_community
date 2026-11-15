import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/trade_share_fakes.dart';

final _since = DateTime.utc(2026, 11, 1, 2);

Future<FakeTradeShareRepository> _pump(
  WidgetTester tester,
  Widget child, {
  FakeTradeShareRepository? repository,
  CommunityCallbacks callbacks = const CommunityCallbacks(),
}) async {
  final repo = repository ?? FakeTradeShareRepository();
  final trade = FakeTradeShareDependencies(repo);
  addTearDown(trade.dispose);
  await pumpTradeApp(
    tester,
    child,
    trade: trade,
    dependencies: FakeDependencies(callbacks: callbacks),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('subscriptions', () {
    FakeTradeShareRepository repository() => FakeTradeShareRepository()
      ..subscriptionItems = [
        TradeSubscriptionEntry(
          trader: alice,
          subscription: TradeSubscription(status: TradeSubscriptionStatus.active, decidedAt: _since),
          cursor: 'c-1',
        ),
        const TradeSubscriptionEntry(
          trader: bob,
          subscription: TradeSubscription(status: TradeSubscriptionStatus.pending),
          sharing: false,
          cursor: 'c-2',
        ),
      ]
      ..feedItems = [tradeActivity()];

    testWidgets('list traders with their status, mute and cancel', (tester) async {
      final repo = await _pump(tester, const CommunityTradeSubscriptions(), repository: repository());

      expect(find.text('Alice'), findsOneWidget);
      expect(find.textContaining('Berlangganan · Berlangganan sejak'), findsOneWidget);
      expect(find.text('Menunggu persetujuan · Trader ini sedang tidak membagikan trade.'), findsOneWidget);
      expect(find.byKey(ValueKey('trade-mute-${bob.id}')), findsNothing);

      repo.nextProfile = tradeProfile(
        subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
      );
      await tester.tap(find.byKey(ValueKey('trade-mute-${alice.id}')));
      await tester.pumpAndSettle();
      expect(repo.mutes.single, (alice.id, true));
      expect(find.textContaining('Dibisukan'), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('trade-cancel-${bob.id}')));
      await tester.pumpAndSettle();
      expect(repo.cancels, [bob.id]);
      expect(find.text('Bob'), findsNothing);

      await tester.tap(find.byKey(ValueKey('trade-cancel-${alice.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Berhenti menerima notifikasi trade dari Alice?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Berhenti berlangganan'));
      await tester.pumpAndSettle();
      expect(repo.cancels, [bob.id, alice.id]);
      expect(find.text('Anda belum berlangganan trader mana pun.'), findsOneWidget);
    });

    testWidgets('open the activity feed, then the detail with the disclaimer and the stock action', (tester) async {
      final stocks = <String>[];
      final repo = await _pump(
        tester,
        const CommunityTradeSubscriptionsPage(),
        repository: repository(),
        callbacks: CommunityCallbacks(onStockTap: (_, code) => stocks.add(code)),
      );

      await tester.tap(find.text('Aktivitas trade'));
      await tester.pumpAndSettle();
      expect(find.text(r'Alice membeli $BBCA'), findsOneWidget);
      expect(find.text('25 lot @ 9.150'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('trade-activity-act-1')));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('activity'));
      expect(find.text('Detail aktivitas trade'), findsOneWidget);
      expect(find.text('Beli'), findsOneWidget);
      expect(find.text(r'$BBCA'), findsOneWidget);
      expect(find.text('9.150'), findsOneWidget);
      expect(find.text('Bukan rekomendasi dari server.'), findsOneWidget);
      expect(find.textContaining(RegExp('ikuti order', caseSensitive: false)), findsNothing);

      await tester.tap(find.byKey(const ValueKey('trade-open-stock')));
      await tester.pump();
      expect(stocks, ['BBCA']);
    });

    testWidgets('the page is replaced by a notice when the feature is off', (tester) async {
      final repo = FakeTradeShareRepository(status: tradeStatus(enabled: false));
      await _pump(tester, const CommunityTradeSubscriptions(), repository: repo);

      expect(find.text('Fitur berbagi trade sedang tidak tersedia.'), findsOneWidget);
      expect(find.text('Aktivitas trade'), findsNothing);
    });
  });

  group('subscribers', () {
    testWidgets('a trader approves, declines and removes subscribers', (tester) async {
      final repo = FakeTradeShareRepository()
        ..subscriberItems = {
          TradeSubscriberStatus.pending: [
            TradeSubscriberEntry(
              subscriber: alice,
              status: TradeSubscriptionStatus.pending,
              expiresAt: DateTime.utc(2026, 11, 29),
              cursor: 'p-1',
            ),
            const TradeSubscriberEntry(subscriber: bob, status: TradeSubscriptionStatus.pending, cursor: 'p-2'),
          ],
          TradeSubscriberStatus.active: [
            TradeSubscriberEntry(
              subscriber: bob,
              status: TradeSubscriptionStatus.active,
              decidedAt: _since,
              cursor: 'a-1',
            ),
          ],
        };
      await _pump(tester, const CommunityTradeSubscribers(initialRequests: true), repository: repo);

      expect(find.textContaining('Kedaluwarsa'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('trade-approve-${alice.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('trade-decline-${bob.id}')));
      await tester.pumpAndSettle();
      expect(repo.decisions, [(alice.id, true), (bob.id, false)]);
      expect(find.text('Tidak ada permintaan langganan.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('trade-subscribers-active')));
      await tester.pumpAndSettle();
      expect(find.text('Bob'), findsOneWidget);
      expect(find.textContaining('Berlangganan sejak'), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('trade-remove-${bob.id}')));
      await tester.pumpAndSettle();
      expect(find.text('Keluarkan Bob dari pelanggan trade Anda?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Keluarkan'));
      await tester.pumpAndSettle();

      expect(repo.removals, [bob.id]);
      expect(find.text('Belum ada pelanggan.'), findsOneWidget);
      expect(repo.subscriberQueries.map((q) => q.$1), [TradeSubscriberStatus.pending, TradeSubscriberStatus.active]);
    });

    testWidgets('an error is shown and the request stays', (tester) async {
      final repo = FakeTradeShareRepository()
        ..subscriberItems = {
          TradeSubscriberStatus.pending: [
            const TradeSubscriberEntry(subscriber: alice, status: TradeSubscriptionStatus.pending, cursor: 'p-1'),
          ],
        }
        ..errorFor = (call) => call == 'decide' ? tradeError('request_not_found') : null;
      await _pump(tester, const CommunityTradeSubscribers(initialRequests: true), repository: repo);

      await tester.tap(find.byKey(ValueKey('trade-approve-${alice.id}')));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('activity', () {
    testWidgets('the feed shows an empty state', (tester) async {
      await _pump(tester, const CommunityTradeActivityFeed());

      expect(find.text('Belum ada aktivitas trade.'), findsOneWidget);
    });

    testWidgets('hidden price and lots are labelled in the detail', (tester) async {
      final repo = FakeTradeShareRepository()..detail = tradeActivity(lots: null, price: null);
      await _pump(tester, const CommunityTradeActivityDetail(activityId: 'act-1'), repository: repo);

      expect(find.text('Disembunyikan trader'), findsNWidgets(2));
      expect(find.text('Bukan rekomendasi dari server.'), findsOneWidget);
    });

    testWidgets('a partial fill is labelled and the local disclaimer is used when the server sends none', (
      tester,
    ) async {
      final repo = FakeTradeShareRepository()
        ..detail = TradeActivity(
          id: 'act-2',
          stock: 'TLKM',
          side: TradeSide.sell,
          lots: 10,
          orderLots: 25,
          partial: true,
        );
      await _pump(tester, const CommunityTradeActivityDetail(activityId: 'act-2'), repository: repo);

      expect(find.text(r'Seseorang menjual $TLKM'), findsOneWidget);
      expect(find.text('10 dari 25 lot · sebagian'), findsOneWidget);
      expect(find.text('Terisi sebagian'), findsOneWidget);
      expect(find.text('Jual'), findsOneWidget);
      expect(
        find.text('Informasi ini bukan rekomendasi. Keputusan investasi sepenuhnya tanggung jawab Anda.'),
        findsOneWidget,
      );
    });
  });

  group('gate', () {
    testWidgets('shows the child only while the feature is on', (tester) async {
      final repo = await _pump(tester, const CommunityTradeShareGate(child: Text('Menu trade')));
      expect(find.text('Menu trade'), findsOneWidget);

      repo.current = tradeStatus(enabled: false);
      final service = CommunityTradeShareScope.serviceOf(tester.element(find.byType(CommunityTradeShareGate)))!;
      await service.status(refresh: true);
      await tester.pumpAndSettle();
      expect(find.text('Menu trade'), findsNothing);
    });

    testWidgets('hides the child without trade share dependencies', (tester) async {
      await pumpTradeApp(tester, const CommunityTradeShareGate(fallback: Text('Tidak ada'), child: Text('Menu trade')));
      await tester.pumpAndSettle();

      expect(find.text('Menu trade'), findsNothing);
      expect(find.text('Tidak ada'), findsOneWidget);
    });
  });
}
