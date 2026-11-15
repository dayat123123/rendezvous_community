import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:rendezvous_community/src/features/trade_share/data/repositories/trade_share_repository_impl.dart';

import '../../support/mock_api.dart';

Map<String, dynamic> statusJson({String? status = 'active', bool enabled = true}) => {
  'enabled': enabled,
  'status': status,
  'pause_source': null,
  'show_price': false,
  'show_lot': true,
  'delay_minutes': 30,
  'subscribe_mode': 'approval',
  'applied_at': '2026-11-15T02:00:00Z',
  'decided_at': '2026-11-15T03:00:00Z',
  'decision_reason': null,
  'suspended_until': null,
  'cooldown_until': null,
  'accounts': [
    {'cust_id': 'W137', 'state': 'active'},
    {'cust_id': 'W200', 'state': 'shared_link'},
  ],
  'subscribers': {'active': 12, 'pending': 3},
  'limits': {'min_delay_minutes': 20, 'max_delay_minutes': 120, 'force_hide_price': true, 'force_hide_lot': false},
  'eligibility': {
    'eligible': false,
    'checks': [
      {'code': 'feature_enabled', 'ok': true},
      {'code': 'account_age', 'ok': false},
    ],
    'accounts': [
      {'cust_id': 'W137', 'state': 'active'},
      {'cust_id': 'W300', 'state': 'expired'},
    ],
    'cooldown_until': '2026-12-01T00:00:00Z',
    'terms_document': {
      'id': 'doc-terms',
      'version': 3,
      'title': 'S&K',
      'body': 'Isi',
      'effective_at': '2026-11-01T00:00:00Z',
    },
  },
};

Map<String, dynamic> profileJson({Map<String, dynamic>? subscription, bool accepted = false}) => {
  'enabled': true,
  'sharing': true,
  'subscribe_mode': 'auto',
  'subscription': subscription,
  'can_subscribe': subscription == null,
  'blocked_reason': subscription == null ? null : 'not_following',
  'risk_document': {
    'id': 'doc-risk',
    'version': 1,
    'title': 'Risiko',
    'body': 'Bukan rekomendasi',
    'accepted': accepted,
  },
};

Map<String, dynamic> activityJson(String id) => {
  'activity_id': id,
  'trader_id': 'u-a',
  'stock': 'BBCA',
  'side': 'sell',
  'lots': 10.5,
  'order_lots': 25,
  'shares': 1050,
  'price': 9150,
  'partial': true,
  'additional': false,
  'completed_at': '2026-11-15T03:30:00Z',
  'text': {
    'id': {'title': r'Alice menjual $BBCA', 'body': '10,5 dari 25 lot @ 9.150 · sebagian'},
    'en': {'title': r'Alice sold $BBCA', 'body': '10.5 of 25 lots @ 9,150 · partial'},
  },
  'trader': {
    'id': 'u-a',
    'username': 'alice',
    'display_name': 'Alice',
    'avatar_url': null,
    'is_verified': true,
    'is_official': false,
  },
  'cursor': 'cur-$id',
};

void main() {
  late MockApi api;
  late TradeShareRepositoryImpl repo;

  setUp(() {
    api = mockApi();
    repo = TradeShareRepositoryImpl(api);
  });

  test('status maps the trader view, limits, subscribers and eligibility', () async {
    when(() => api.rpcValue('get_trade_share_status', {})).thenAnswer((_) async => statusJson());

    final status = await repo.status();

    expect(status.enabled, isTrue);
    expect(status.status, TradeSharerStatus.active);
    expect(status.showPrice, isFalse);
    expect(status.delayMinutes, 30);
    expect(status.subscribeMode, TradeSubscribeMode.approval);
    expect(status.accounts.map((a) => (a.custId, a.state)), [
      ('W137', TradeShareAccountState.active),
      ('W200', TradeShareAccountState.sharedLink),
    ]);
    expect(status.activeSubscribers, 12);
    expect(status.pendingSubscribers, 3);
    expect(status.limits.minDelayMinutes, 20);
    expect(status.limits.maxDelayMinutes, 120);
    expect(status.limits.forceHidePrice, isTrue);
    expect(status.eligibility.eligible, isFalse);
    expect(status.eligibility.failedChecks.single.code, 'account_age');
    expect(status.eligibility.accounts.last.state, TradeShareAccountState.expired);
    expect(status.eligibility.cooldownUntil, DateTime.utc(2026, 12));
    expect(status.eligibility.termsDocument?.id, 'doc-terms');
    expect(status.eligibility.termsDocument?.version, 3);
    expect(status.canPause, isTrue);
    expect(status.canEdit, isTrue);
    expect(status.canApply, isFalse);
  });

  test('a disabled or empty status keeps safe defaults', () async {
    when(() => api.rpcValue('get_trade_share_status', {})).thenAnswer((_) async => {'enabled': false});

    final status = await repo.status();

    expect(status.enabled, isFalse);
    expect(status.status, TradeSharerStatus.none);
    expect(status.canApply, isFalse);
    expect(status.limits.minDelayMinutes, 15);
    expect(status.eligibility.checks, isEmpty);
  });

  test('apply sends the chosen settings and the terms document id', () async {
    when(() => api.rpcValue('submit_trade_share_application', any())).thenAnswer((_) async => statusJson());

    await repo.apply(
      const TradeShareApplication(
        accounts: ['W137'],
        showPrice: false,
        delayMinutes: 45,
        subscribeMode: TradeSubscribeMode.approval,
      ),
      termsDocumentId: 'doc-terms',
    );

    final params = verify(() => api.rpcValue('submit_trade_share_application', captureAny())).captured.single;
    expect(params, {
      'p_accounts': ['W137'],
      'p_show_price': false,
      'p_show_lot': true,
      'p_delay_minutes': 45,
      'p_subscribe_mode': 'approval',
      'p_terms_document_id': 'doc-terms',
    });
  });

  test('update settings forwards the confirmation flag', () async {
    when(() => api.rpcValue('update_trade_share_settings', any())).thenAnswer((_) async => statusJson());

    await repo.updateSettings(const TradeShareApplication(accounts: ['W137'], delayMinutes: 15), confirm: true);

    final params = verify(() => api.rpcValue('update_trade_share_settings', captureAny())).captured.single;
    expect(params, {
      'p_accounts': ['W137'],
      'p_show_price': true,
      'p_show_lot': true,
      'p_delay_minutes': 15,
      'p_subscribe_mode': 'auto',
      'p_confirm': true,
    });
  });

  test('pause, resume and withdraw call their RPCs without parameters', () async {
    for (final fn in ['pause_trade_share', 'resume_trade_share', 'withdraw_trade_share']) {
      when(() => api.rpcValue(fn, {})).thenAnswer((_) async => statusJson(status: 'paused'));
    }

    expect((await repo.pause()).status, TradeSharerStatus.paused);
    await repo.resume();
    await repo.withdraw();

    verify(() => api.rpcValue('pause_trade_share', {})).called(1);
    verify(() => api.rpcValue('resume_trade_share', {})).called(1);
    verify(() => api.rpcValue('withdraw_trade_share', {})).called(1);
  });

  test('profile, subscribe, mute and cancel pass the trader and risk ids', () async {
    when(() => api.rpcValue('get_trade_share_profile', {'p_trader': 'u-a'})).thenAnswer((_) async => profileJson());
    when(
      () => api.rpcValue('request_trade_subscription', {'p_trader': 'u-a', 'p_risk_document_id': 'doc-risk'}),
    ).thenAnswer(
      (_) async => profileJson(
        subscription: {'status': 'pending', 'muted': false, 'expires_at': '2026-11-29T00:00:00Z'},
        accepted: true,
      ),
    );
    when(
      () => api.rpcValue('mute_trade_subscription', {'p_trader': 'u-a', 'p_muted': true}),
    ).thenAnswer((_) async => profileJson(subscription: {'status': 'active', 'muted': true}));
    when(
      () => api.rpcValue('cancel_trade_subscription', {'p_trader': 'u-a'}),
    ).thenAnswer((_) async => profileJson(subscription: {'status': 'ended', 'end_reason': 'cancelled'}));

    final profile = await repo.profile('u-a');
    expect(profile.bell, TradeBellState.subscribe);
    expect(profile.needsRiskConsent, isTrue);
    expect(profile.riskDocument?.id, 'doc-risk');

    final pending = await repo.subscribe('u-a', riskDocumentId: 'doc-risk');
    expect(pending.bell, TradeBellState.pending);
    expect(pending.subscription?.expiresAt, DateTime.utc(2026, 11, 29));
    expect(pending.needsRiskConsent, isFalse);

    expect((await repo.muteSubscription('u-a', muted: true)).bell, TradeBellState.muted);
    final ended = await repo.cancelSubscription('u-a');
    expect(ended.subscription?.status, TradeSubscriptionStatus.ended);
    expect(ended.subscription?.endReason, 'cancelled');
  });

  test('subscriptions page through the cursor and skip incomplete rows', () async {
    when(() => api.rpcValue('my_trade_subscriptions', {'p_cursor': null, 'p_limit': 2})).thenAnswer(
      (_) async => [
        {
          'trader': {'id': 'u-a', 'username': 'alice', 'display_name': 'Alice'},
          'sharing': false,
          'cursor': 'c-1',
          'status': 'active',
          'muted': true,
          'requested_at': '2026-11-10T00:00:00Z',
        },
        {'trader': null, 'status': 'active', 'cursor': 'c-2'},
      ],
    );

    final page = await repo.subscriptions(limit: 2);

    expect(page.items.single.trader.username, 'alice');
    expect(page.items.single.sharing, isFalse);
    expect(page.items.single.subscription.muted, isTrue);
    expect(page.nextCursor, 'c-2');
  });

  test('subscribers send the status filter and map entries', () async {
    when(
      () => api.rpcValue('my_trade_subscribers', {'p_status': 'pending', 'p_cursor': 'c-9', 'p_limit': 30}),
    ).thenAnswer(
      (_) async => [
        {
          'subscriber': {'id': 'u-b', 'username': 'bob_user', 'display_name': 'Bob'},
          'status': 'pending',
          'requested_at': '2026-11-14T00:00:00Z',
          'expires_at': '2026-11-28T00:00:00Z',
          'cursor': 'c-10',
        },
      ],
    );

    final page = await repo.subscribers(status: TradeSubscriberStatus.pending, cursor: 'c-9');

    expect(page.items.single.subscriber.id, 'u-b');
    expect(page.items.single.status, TradeSubscriptionStatus.pending);
    expect(page.items.single.expiresAt, DateTime.utc(2026, 11, 28));
    expect(page.nextCursor, isNull);
  });

  test('decide and remove subscriber pass the subscriber id', () async {
    when(
      () => api.rpcValue('decide_trade_subscription', {'p_subscriber': 'u-b', 'p_approve': false}),
    ).thenAnswer((_) async => {'status': 'declined'});
    when(() => api.rpcValue('remove_trade_subscriber', {'p_subscriber': 'u-b'})).thenAnswer((_) async => {});

    expect(await repo.decideSubscriber('u-b', approve: false), TradeSubscriptionStatus.declined);
    await repo.removeSubscriber('u-b');

    verify(() => api.rpcValue('remove_trade_subscriber', {'p_subscriber': 'u-b'})).called(1);
  });

  test('activity feed and detail map payload, trader, texts and disclaimer', () async {
    when(
      () => api.rpcValue('trade_activity_feed', {'p_cursor': null, 'p_limit': 1}),
    ).thenAnswer((_) async => [activityJson('a-1')]);
    when(() => api.rpcValue('trade_activity_detail', {'p_activity': 'a-1'})).thenAnswer(
      (_) async => {
        ...activityJson('a-1'),
        'disclaimer': {'id': 'Bukan rekomendasi.', 'en': 'Not a recommendation.'},
      },
    );

    final page = await repo.activityFeed(limit: 1);
    final activity = page.items.single;
    expect(page.nextCursor, 'cur-a-1');
    expect(activity.side, TradeSide.sell);
    expect(activity.lots, 10.5);
    expect(activity.orderLots, 25);
    expect(activity.price, 9150);
    expect(activity.partial, isTrue);
    expect(activity.trader?.name, 'Alice');
    expect(activity.text('en')?.title, r'Alice sold $BBCA');
    expect(activity.text('fr')?.title, r'Alice menjual $BBCA');

    final detail = await repo.activity('a-1');
    expect(detail.disclaimer('en'), 'Not a recommendation.');
    expect(detail.disclaimer('id'), 'Bukan rekomendasi.');
  });

  test('an empty detail answer becomes not found', () async {
    when(() => api.rpcValue('trade_activity_detail', {'p_activity': 'x'})).thenAnswer((_) async => null);

    await expectLater(
      repo.activity('x'),
      throwsA(isA<CommunityException>().having((e) => e.code, 'code', 'activity_not_found')),
    );
  });

  test('legal documents leave out the trade sharing documents', () async {
    when(() => api.rpcRows('get_legal_documents')).thenAnswer(
      (_) async => [
        {'id': 'd-1', 'kind': 'terms', 'version': 1, 'title': 'S&K', 'effective_at': '2026-01-01T00:00:00Z'},
        {
          'id': 'd-2',
          'kind': 'trade_share_terms',
          'version': 1,
          'title': 'S&K trade',
          'effective_at': '2026-01-01T00:00:00Z',
        },
        {
          'id': 'd-3',
          'kind': 'trade_share_risk',
          'version': 1,
          'title': 'Risiko',
          'effective_at': '2026-01-01T00:00:00Z',
        },
      ],
    );

    final documents = await LegalRepositoryImpl(api).getDocuments();

    expect(documents.map((d) => d.id), ['d-1']);
  });
}
