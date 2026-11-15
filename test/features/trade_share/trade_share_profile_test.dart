import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/trade_share_fakes.dart';

class _EmptyFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => const Paged([]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Profiles extends Fake implements ProfileRepository {
  _Profiles({this.isMe = false, this.following = true});

  final bool isMe;
  bool following;

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => UserProfile(
    user: alice,
    followerCount: 10,
    followingCount: 2,
    postCount: 0,
    createdAt: now,
    isMe: isMe,
    isFollowing: following,
    followsMe: false,
    isBlocked: false,
  );

  @override
  Future<void> follow(String userId) async => following = true;

  @override
  Future<void> unfollow(String userId) async => following = false;
}

Future<FakeTradeShareRepository> _pumpProfile(
  WidgetTester tester,
  TradeShareProfile profile, {
  TradeShareStatus? status,
  bool isMe = false,
  bool following = true,
}) async {
  final repo = FakeTradeShareRepository(status: status, profile: profile);
  final trade = FakeTradeShareDependencies(repo);
  addTearDown(trade.dispose);
  await pumpTradeApp(
    tester,
    CommunityUserProfile(userId: alice.id),
    trade: trade,
    dependencies: FakeDependencies(
      feed: _EmptyFeed(),
      profiles: _Profiles(isMe: isMe, following: following),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder get _bell => find.byKey(const ValueKey('trade-bell'));

void main() {
  testWidgets('a sharing trader shows the badge; the first subscription asks to accept the risk statement', (
    tester,
  ) async {
    final repo = await _pumpProfile(tester, tradeProfile());

    expect(find.text('Membagikan trade'), findsOneWidget);
    expect(find.descendant(of: _bell, matching: find.text('Notifikasi trade')), findsOneWidget);

    await tester.tap(_bell);
    await tester.pumpAndSettle();
    expect(find.text('Informasi ini bukan rekomendasi.'), findsOneWidget);
    final confirm = find.byKey(const ValueKey('trade-document-confirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active));
    await tester.tap(find.byKey(const ValueKey('trade-document-accept')));
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(repo.subscribes.single, (alice.id, 'doc-risk'));
    expect(find.descendant(of: _bell, matching: find.text('Berlangganan')), findsOneWidget);
    expect(find.text('Anda akan menerima notifikasi trade dari Alice.'), findsOneWidget);
  });

  testWidgets('closing the risk statement does not subscribe', (tester) async {
    final repo = await _pumpProfile(tester, tradeProfile());

    await tester.tap(_bell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(repo.subscribes, isEmpty);
  });

  testWidgets('an accepted risk statement subscribes directly and approval mode waits for the trader', (tester) async {
    final repo = await _pumpProfile(
      tester,
      tradeProfile(
        mode: TradeSubscribeMode.approval,
        risk: const TradeShareDocument(id: 'doc-risk', version: 1, title: 'Risiko', body: 'Isi', accepted: true),
      ),
    );
    repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.pending));

    await tester.tap(_bell);
    await tester.pumpAndSettle();

    expect(find.text('Isi'), findsNothing);
    expect(repo.subscribes, hasLength(1));
    expect(find.descendant(of: _bell, matching: find.text('Menunggu persetujuan')), findsOneWidget);
    expect(find.text('Permintaan dikirim. Menunggu persetujuan trader.'), findsOneWidget);

    repo.nextProfile = tradeProfile();
    await tester.tap(_bell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batalkan permintaan'));
    await tester.pumpAndSettle();
    expect(repo.cancels, [alice.id]);
    expect(find.descendant(of: _bell, matching: find.text('Notifikasi trade')), findsOneWidget);
  });

  testWidgets('an active subscription can be muted, unmuted and cancelled', (tester) async {
    final repo = await _pumpProfile(
      tester,
      tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active)),
    );

    repo.nextProfile = tradeProfile(
      subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
    );
    await tester.tap(_bell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bisukan notifikasi trade'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: _bell, matching: find.text('Dibisukan')), findsOneWidget);

    repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active));
    await tester.tap(_bell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aktifkan notifikasi trade'));
    await tester.pumpAndSettle();
    expect(repo.mutes, [(alice.id, true), (alice.id, false)]);

    repo.nextProfile = tradeProfile();
    await tester.tap(_bell);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Berhenti berlangganan'));
    await tester.pumpAndSettle();
    expect(find.text('Berhenti menerima notifikasi trade dari Alice?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Berhenti berlangganan'));
    await tester.pumpAndSettle();

    expect(repo.cancels, [alice.id]);
    expect(find.descendant(of: _bell, matching: find.text('Notifikasi trade')), findsOneWidget);
  });

  testWidgets('a blocked subscription shows why it is unavailable', (tester) async {
    await _pumpProfile(tester, tradeProfile(canSubscribe: false, blockedReason: 'not_following'), following: false);

    expect(find.text('Notifikasi trade tidak tersedia'), findsOneWidget);
    expect(find.text('Ikuti trader ini untuk berlangganan notifikasi trade.'), findsOneWidget);
    expect(tester.widget<ButtonStyleButton>(_bell).onPressed, isNull);
  });

  testWidgets('following the trader reloads the trade bell', (tester) async {
    final repo = await _pumpProfile(
      tester,
      tradeProfile(canSubscribe: false, blockedReason: 'not_following'),
      following: false,
    );
    expect(repo.profileCalls, 1);

    repo.profileView = tradeProfile();
    await tester.tap(find.text('Ikuti'));
    await tester.pumpAndSettle();

    expect(repo.profileCalls, 2);
    expect(find.descendant(of: _bell, matching: find.text('Notifikasi trade')), findsOneWidget);
  });

  testWidgets('a subscription to a trader who stopped for now stays manageable', (tester) async {
    await _pumpProfile(
      tester,
      tradeProfile(sharing: false, subscription: const TradeSubscription(status: TradeSubscriptionStatus.active)),
    );

    expect(find.text('Membagikan trade'), findsNothing);
    expect(find.text('Trader ini sedang tidak membagikan trade.'), findsOneWidget);
    expect(_bell, findsOneWidget);
  });

  testWidgets('nothing is shown for a profile that does not share trades', (tester) async {
    await _pumpProfile(tester, tradeProfile(sharing: false));

    expect(find.text('Membagikan trade'), findsNothing);
    expect(_bell, findsNothing);
  });

  testWidgets('the kill switch hides the bell without loading the trade profile', (tester) async {
    final repo = await _pumpProfile(tester, tradeProfile(), status: tradeStatus(enabled: false));

    expect(_bell, findsNothing);
    expect(find.text('Membagikan trade'), findsNothing);
    expect(repo.profileCalls, 0);
  });

  testWidgets('the own profile never asks for the trade bell', (tester) async {
    final repo = await _pumpProfile(tester, tradeProfile(), isMe: true);

    expect(_bell, findsNothing);
    expect(repo.profileCalls, 0);
  });

  testWidgets('a profile without trade share dependencies stays unchanged', (tester) async {
    await pumpTradeApp(
      tester,
      CommunityUserProfile(userId: alice.id),
      dependencies: FakeDependencies(feed: _EmptyFeed(), profiles: _Profiles()),
    );
    await tester.pumpAndSettle();

    expect(_bell, findsNothing);
    expect(find.text('Mengikuti'), findsWidgets);
  });
}
