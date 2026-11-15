import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_activity_detail_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_activity_feed_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_share_profile_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_share_settings_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_subscribers_cubit.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_subscriptions_cubit.dart';

import '../../support/fakes.dart';
import '../../support/trade_share_fakes.dart';

void main() {
  group('CommunityTradeShare', () {
    test('caches the status for five minutes and refreshes after that', () async {
      var clock = DateTime.utc(2026, 11, 15, 9);
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo, clock: () => clock);
      addTearDown(service.dispose);

      expect(service.enabled, isFalse);
      await service.status();
      await service.status();
      expect(repo.statusCalls, 1);
      expect(service.enabled, isTrue);

      clock = clock.add(const Duration(minutes: 4, seconds: 59));
      await service.status();
      expect(repo.statusCalls, 1);

      clock = clock.add(const Duration(seconds: 2));
      await service.status();
      expect(repo.statusCalls, 2);

      await service.status(refresh: true);
      expect(repo.statusCalls, 3);
    });

    test('concurrent callers share one request', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);

      await Future.wait([service.status(), service.status(), service.ensureFresh()]);

      expect(repo.statusCalls, 1);
    });

    test('resume refreshes only a status that was loaded before', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);

      await service.onResumed();
      expect(repo.statusCalls, 0);

      await service.status();
      repo.current = tradeStatus(enabled: false);
      await service.onResumed();

      expect(repo.statusCalls, 2);
      expect(service.enabled, isFalse);
    });

    test('the kill switch seen in a profile hides the feature without a new request', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);
      await service.status();

      service.observeEnabled(false);

      expect(service.enabled, isFalse);
      expect(service.current?.status, TradeSharerStatus.none);
      expect(repo.statusCalls, 1);
    });

    test('a failed first load is retried when the app resumes', () async {
      final repo = FakeTradeShareRepository()..error = tradeError('network');
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);

      expect(await service.ensureFresh(), isNull);
      repo.error = null;
      await service.onResumed();

      expect(repo.statusCalls, 2);
      expect(service.enabled, isTrue);
    });

    test('only a switch to another user forgets the status', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);

      service.onUserChanged('u-1');
      await service.status();
      service.onUserChanged('u-1');
      expect(service.current, isNotNull);

      service.onUserChanged('u-2');
      expect(service.current, isNull);
      await service.status();
      service.onUserChanged(null);
      expect(service.current, isNull);
      await service.onResumed();
      expect(repo.statusCalls, 2);
    });

    test('ensureFresh swallows errors and reset forgets the user', () async {
      final repo = FakeTradeShareRepository()..error = tradeError('network');
      final service = CommunityTradeShare(repo);
      addTearDown(service.dispose);

      expect(await service.ensureFresh(), isNull);

      repo.error = null;
      await service.status();
      expect(service.current, isNotNull);
      service.reset();
      expect(service.current, isNull);
      expect(service.isFresh, isFalse);
    });
  });

  group('TradeShareSettingsCubit', () {
    late FakeTradeShareRepository repo;
    late CommunityTradeShare service;
    late TradeShareSettingsCubit cubit;

    setUp(() {
      repo = FakeTradeShareRepository(
        status: tradeStatus(limits: const TradeShareLimits(minDelayMinutes: 20, forceHideLot: true)),
      );
      service = CommunityTradeShare(repo);
      cubit = TradeShareSettingsCubit(service);
    });

    tearDown(() async {
      await cubit.close();
      service.dispose();
    });

    test('an application starts with all active accounts, both values shown and the minimum delay', () async {
      await cubit.load();

      final draft = cubit.state.draft;
      expect(draft.accounts, {'W137'});
      expect(draft.showPrice, isTrue);
      expect(draft.showLot, isTrue);
      expect(draft.delayMinutes, 20);
      expect(draft.subscribeMode, TradeSubscribeMode.auto);
      expect(cubit.state.canSubmit, isFalse);
    });

    test('submitting needs the terms and sends the terms id', () async {
      await cubit.load();
      cubit
        ..setShowPrice(false)
        ..setDelay(500)
        ..setSubscribeMode(TradeSubscribeMode.approval);
      expect(cubit.state.draft.delayMinutes, 240);
      expect(await cubit.submit(), isFalse);

      cubit.setTermsAccepted(true);
      repo.nextStatus = tradeStatus(
        status: TradeSharerStatus.pending,
        accounts: const [TradeShareAccount(custId: 'W137')],
      );
      expect(await cubit.submit(), isTrue);

      final (application, termsId) = repo.applications.single;
      expect(termsId, 'doc-terms');
      expect(application.accounts, ['W137']);
      expect(application.showPrice, isFalse);
      expect(application.delayMinutes, 240);
      expect(application.subscribeMode, TradeSubscribeMode.approval);
      expect(cubit.state.data?.status, TradeSharerStatus.pending);
      expect(service.current?.status, TradeSharerStatus.pending);
    });

    test('an ineligible profile cannot submit', () async {
      repo.current = tradeStatus(eligible: false);
      await cubit.load();
      cubit.setTermsAccepted(true);

      expect(cubit.state.canSubmit, isFalse);
      expect(await cubit.submit(), isFalse);
      expect(repo.applications, isEmpty);
    });

    test('a scope change asks for confirmation and then saves with p_confirm', () async {
      repo.current = tradeStatus(
        status: TradeSharerStatus.active,
        accounts: const [TradeShareAccount(custId: 'W137')],
        delayMinutes: 30,
      );
      await cubit.load();
      expect(cubit.state.draft.delayMinutes, 30);
      cubit.setShowPrice(false);
      repo.errorFor = (call) => call == 'update' ? tradeError('confirmation_required') : null;

      expect(await cubit.save(), TradeShareSaveResult.confirmationRequired);
      expect(cubit.state.actionErrorId, 0);

      repo.nextStatus = tradeStatus(status: TradeSharerStatus.active, showPrice: false);
      expect(await cubit.save(confirm: true), TradeShareSaveResult.saved);
      expect(repo.updates.map((u) => u.$2), [false, true]);
      expect(repo.updates.last.$1.showPrice, isFalse);
      expect(cubit.state.data?.showPrice, isFalse);
    });

    test('pause, resume and withdraw update the shared status', () async {
      repo.current = tradeStatus(
        status: TradeSharerStatus.active,
        accounts: const [TradeShareAccount(custId: 'W137')],
      );
      await cubit.load();

      repo.nextStatus = tradeStatus(status: TradeSharerStatus.paused, pauseSource: TradePauseSource.user);
      expect(await cubit.pause(), isTrue);
      expect(cubit.state.data?.canResume, isTrue);

      repo.nextStatus = tradeStatus(status: TradeSharerStatus.active);
      expect(await cubit.resume(), isTrue);

      repo.nextStatus = tradeStatus(status: TradeSharerStatus.withdrawn);
      expect(await cubit.withdraw(), isTrue);
      expect(cubit.state.data?.canApply, isTrue);
      expect(repo.calls, containsAllInOrder(['pause', 'resume', 'withdraw']));
    });

    test('an outdated terms error reloads the status', () async {
      await cubit.load();
      cubit.setTermsAccepted(true);
      repo.errorFor = (call) => call == 'apply' ? tradeError('terms_outdated') : null;

      expect(await cubit.submit(), isFalse);

      expect(cubit.state.actionErrorId, 1);
      expect(repo.statusCalls, 2);
      expect(cubit.state.draft.termsAccepted, isFalse);
    });
  });

  group('TradeShareProfileCubit', () {
    test('stays hidden without asking for the profile when the feature is off', () async {
      final repo = FakeTradeShareRepository(status: tradeStatus(enabled: false));
      final service = CommunityTradeShare(repo);
      final cubit = TradeShareProfileCubit(service, traderId: 'u-a');
      addTearDown(service.dispose);
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.bell, TradeBellState.hidden);
      expect(repo.profileCalls, 0);
    });

    test('subscribe, mute, unmute and cancel follow the server view', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      final cubit = TradeShareProfileCubit(service, traderId: 'u-a');
      addTearDown(service.dispose);
      addTearDown(cubit.close);

      await cubit.load();
      expect(cubit.state.bell, TradeBellState.subscribe);

      repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active));
      await cubit.subscribe();
      expect(repo.subscribes.single, ('u-a', 'doc-risk'));
      expect(cubit.state.bell, TradeBellState.active);

      repo.nextProfile = tradeProfile(
        subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
      );
      await cubit.setMuted(true);
      expect(cubit.state.bell, TradeBellState.muted);

      repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.active));
      await cubit.setMuted(false);
      expect(repo.mutes, [('u-a', true), ('u-a', false)]);

      repo.nextProfile = tradeProfile(subscription: const TradeSubscription(status: TradeSubscriptionStatus.ended));
      await cubit.cancel();
      expect(repo.cancels, ['u-a']);
      expect(cubit.state.bell, TradeBellState.subscribe);
    });

    test('a refused subscription reports the error and reloads', () async {
      final repo = FakeTradeShareRepository();
      final service = CommunityTradeShare(repo);
      final cubit = TradeShareProfileCubit(service, traderId: 'u-a');
      addTearDown(service.dispose);
      addTearDown(cubit.close);
      await cubit.load();
      repo.errorFor = (call) => call == 'subscribe' ? tradeError('cannot_subscribe', 'not_following') : null;
      repo.profileView = tradeProfile(canSubscribe: false, blockedReason: 'not_following');

      expect(await cubit.subscribe(), isNull);

      expect(cubit.state.actionErrorId, 1);
      expect(cubit.state.bell, TradeBellState.unavailable);
      expect(repo.profileCalls, 2);
    });
  });

  group('lists', () {
    test('subscriptions mute in place and drop cancelled traders', () async {
      final repo = FakeTradeShareRepository()
        ..subscriptionItems = const [
          TradeSubscriptionEntry(
            trader: alice,
            subscription: TradeSubscription(status: TradeSubscriptionStatus.active),
            cursor: 'c-1',
          ),
          TradeSubscriptionEntry(
            trader: bob,
            subscription: TradeSubscription(status: TradeSubscriptionStatus.pending),
            cursor: 'c-2',
          ),
        ];
      final cubit = TradeSubscriptionsCubit(repo);
      addTearDown(cubit.close);
      await cubit.load();

      repo.nextProfile = tradeProfile(
        subscription: const TradeSubscription(status: TradeSubscriptionStatus.active, muted: true),
      );
      await cubit.setMuted(cubit.state.items.first, muted: true);
      expect(cubit.state.items.first.subscription.muted, isTrue);

      await cubit.cancel(cubit.state.items.last);
      expect(cubit.state.items.map((e) => e.trader.id), [alice.id]);
      expect(repo.cancels, [bob.id]);
    });

    test('subscribers approve, decline and remove', () async {
      final pending = TradeSubscriberEntry(subscriber: alice, status: TradeSubscriptionStatus.pending, cursor: 'c-1');
      final repo = FakeTradeShareRepository()
        ..subscriberItems = {
          TradeSubscriberStatus.pending: [pending, pending.copyWithSubscriber(bob)],
        };
      final cubit = TradeSubscribersCubit(repo, status: TradeSubscriberStatus.pending);
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.decide(cubit.state.items.first, approve: true);
      await cubit.decide(cubit.state.items.first, approve: false);

      expect(repo.decisions, [(alice.id, true), (bob.id, false)]);
      expect(cubit.state.items, isEmpty);
      expect(repo.subscriberQueries.first.$1, TradeSubscriberStatus.pending);
    });

    test('a failed action keeps the row and reports the error', () async {
      final repo = FakeTradeShareRepository()
        ..subscriberItems = {
          TradeSubscriberStatus.active: [
            TradeSubscriberEntry(subscriber: alice, status: TradeSubscriptionStatus.active, cursor: 'c'),
          ],
        }
        ..errorFor = (call) => call == 'remove' ? tradeError('subscription_not_found') : null;
      final cubit = TradeSubscribersCubit(repo);
      addTearDown(cubit.close);
      await cubit.load();

      expect(await cubit.remove(cubit.state.items.single), isFalse);

      expect(cubit.state.items, hasLength(1));
      expect(cubit.state.actionErrorId, 1);
      expect(cubit.state.busy, isEmpty);
    });

    test('the activity feed pages with the cursor and skips duplicates', () async {
      final repo = FakeTradeShareRepository()
        ..feedItems = [tradeActivity(id: 'a-1'), tradeActivity(id: 'a-2')]
        ..feedNextCursor = 'c-a-2'
        ..feedSecondPage = [tradeActivity(id: 'a-2'), tradeActivity(id: 'a-3')];
      final cubit = TradeActivityFeedCubit(repo);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.loadMore();

      expect(cubit.state.items.map((a) => a.id), ['a-1', 'a-2', 'a-3']);
      expect(repo.feedCursors, [null, 'c-a-2']);
      expect(cubit.state.hasMore, isFalse);
    });

    test('the activity detail keeps the payload shown while it reloads', () async {
      final repo = FakeTradeShareRepository()..errorFor = (call) => call == 'activity' ? tradeError('network') : null;
      final cubit = TradeActivityDetailCubit(
        repo,
        activityId: 'a-1',
        initial: tradeActivity(id: 'a-1'),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, LoadStatus.ready);
      expect(cubit.state.activity?.id, 'a-1');
    });
  });
}

extension on TradeSubscriberEntry {
  TradeSubscriberEntry copyWithSubscriber(UserSummary user) =>
      TradeSubscriberEntry(subscriber: user, status: status, cursor: '$cursor-${user.id}');
}
