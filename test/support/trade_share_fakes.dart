import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'fakes.dart';

const termsDocument = TradeShareDocument(
  id: 'doc-terms',
  version: 2,
  title: 'S&K Berbagi Trade',
  body: 'Isi syarat dan ketentuan berbagi trade.',
);

const riskDocument = TradeShareDocument(
  id: 'doc-risk',
  version: 1,
  title: 'Pernyataan risiko',
  body: 'Informasi ini bukan rekomendasi.',
);

const eligibleChecks = [
  TradeShareCheck(code: TradeShareCheckCode.featureEnabled, ok: true),
  TradeShareCheck(code: TradeShareCheckCode.pilotInvited, ok: true),
  TradeShareCheck(code: TradeShareCheckCode.regularProfile, ok: true),
  TradeShareCheck(code: TradeShareCheckCode.linkedAccount, ok: true),
  TradeShareCheck(code: TradeShareCheckCode.termsAvailable, ok: true),
];

TradeShareStatus tradeStatus({
  bool enabled = true,
  TradeSharerStatus status = TradeSharerStatus.none,
  bool eligible = true,
  List<TradeShareCheck> checks = eligibleChecks,
  List<TradeShareAccount> candidates = const [
    TradeShareAccount(custId: 'W137'),
    TradeShareAccount(custId: 'W200', state: TradeShareAccountState.expired),
  ],
  List<TradeShareAccount> accounts = const [],
  TradeShareLimits limits = const TradeShareLimits(),
  bool showPrice = true,
  bool showLot = true,
  int? delayMinutes,
  TradeSubscribeMode subscribeMode = TradeSubscribeMode.auto,
  TradePauseSource? pauseSource,
  String? decisionReason,
  DateTime? cooldownUntil,
  DateTime? suspendedUntil,
  int activeSubscribers = 0,
  int pendingSubscribers = 0,
  TradeShareDocument? terms = termsDocument,
}) => TradeShareStatus(
  enabled: enabled,
  status: status,
  pauseSource: pauseSource,
  showPrice: showPrice,
  showLot: showLot,
  delayMinutes: delayMinutes,
  subscribeMode: subscribeMode,
  decisionReason: decisionReason,
  cooldownUntil: cooldownUntil,
  suspendedUntil: suspendedUntil,
  accounts: accounts,
  activeSubscribers: activeSubscribers,
  pendingSubscribers: pendingSubscribers,
  limits: limits,
  eligibility: TradeShareEligibility(
    eligible: eligible,
    checks: checks,
    accounts: candidates,
    cooldownUntil: cooldownUntil,
    termsDocument: terms,
  ),
);

TradeShareProfile tradeProfile({
  bool enabled = true,
  bool sharing = true,
  TradeSubscription? subscription,
  bool canSubscribe = true,
  String? blockedReason,
  TradeShareDocument? risk = riskDocument,
  TradeSubscribeMode mode = TradeSubscribeMode.auto,
}) => TradeShareProfile(
  enabled: enabled,
  sharing: sharing,
  subscribeMode: mode,
  subscription: subscription,
  canSubscribe: canSubscribe,
  blockedReason: blockedReason,
  riskDocument: risk,
);

TradeActivity tradeActivity({
  String id = 'act-1',
  UserSummary? trader = alice,
  bool partial = false,
  num? lots = 25,
  int? price = 9150,
}) => TradeActivity(
  id: id,
  traderId: trader?.id,
  trader: trader,
  stock: 'BBCA',
  side: TradeSide.buy,
  lots: lots,
  orderLots: partial ? 50 : null,
  price: price,
  partial: partial,
  completedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 20)),
  texts: const {
    'id': TradeActivityText(title: r'Alice membeli $BBCA', body: '25 lot @ 9.150'),
    'en': TradeActivityText(title: r'Alice bought $BBCA', body: '25 lots @ 9,150'),
  },
  disclaimers: const {'id': 'Bukan rekomendasi dari server.'},
  cursor: 'c-$id',
);

class FakeTradeShareRepository implements TradeShareRepository {
  FakeTradeShareRepository({TradeShareStatus? status, TradeShareProfile? profile})
    : current = status ?? tradeStatus(),
      profileView = profile ?? tradeProfile();

  TradeShareStatus current;
  TradeShareProfile profileView;
  TradeShareStatus? nextStatus;
  TradeShareProfile? nextProfile;
  Object? error;
  Object? Function(String call)? errorFor;
  int statusCalls = 0;
  int profileCalls = 0;
  final calls = <String>[];
  final applications = <(TradeShareApplication, String)>[];
  final updates = <(TradeShareApplication, bool)>[];
  final subscribes = <(String, String)>[];
  final mutes = <(String, bool)>[];
  final cancels = <String>[];
  final decisions = <(String, bool)>[];
  final removals = <String>[];
  final subscriberQueries = <(TradeSubscriberStatus, String?)>[];
  final feedCursors = <String?>[];
  List<TradeSubscriptionEntry> subscriptionItems = const [];
  Map<TradeSubscriberStatus, List<TradeSubscriberEntry>> subscriberItems = const {};
  List<TradeActivity> feedItems = const [];
  String? feedNextCursor;
  List<TradeActivity> feedSecondPage = const [];
  TradeActivity? detail;

  void _check(String call) {
    calls.add(call);
    final failure = errorFor?.call(call) ?? error;
    if (failure != null) throw failure;
  }

  TradeShareStatus _nextStatus() {
    final next = nextStatus;
    if (next != null) {
      current = next;
      nextStatus = null;
    }
    return current;
  }

  TradeShareProfile _nextProfile() {
    final next = nextProfile;
    if (next != null) {
      profileView = next;
      nextProfile = null;
    }
    return profileView;
  }

  @override
  Future<TradeShareStatus> status() async {
    statusCalls++;
    _check('status');
    return current;
  }

  @override
  Future<TradeShareStatus> apply(TradeShareApplication application, {required String termsDocumentId}) async {
    _check('apply');
    applications.add((application, termsDocumentId));
    return _nextStatus();
  }

  @override
  Future<TradeShareStatus> updateSettings(TradeShareApplication settings, {bool confirm = false}) async {
    updates.add((settings, confirm));
    _check(confirm ? 'update_confirmed' : 'update');
    return _nextStatus();
  }

  @override
  Future<TradeShareStatus> pause() async {
    _check('pause');
    return _nextStatus();
  }

  @override
  Future<TradeShareStatus> resume() async {
    _check('resume');
    return _nextStatus();
  }

  @override
  Future<TradeShareStatus> withdraw() async {
    _check('withdraw');
    return _nextStatus();
  }

  @override
  Future<TradeShareProfile> profile(String traderId) async {
    profileCalls++;
    _check('profile');
    return profileView;
  }

  @override
  Future<TradeShareProfile> subscribe(String traderId, {required String riskDocumentId}) async {
    _check('subscribe');
    subscribes.add((traderId, riskDocumentId));
    return _nextProfile();
  }

  @override
  Future<TradeShareProfile> cancelSubscription(String traderId) async {
    _check('cancel');
    cancels.add(traderId);
    return _nextProfile();
  }

  @override
  Future<TradeShareProfile> muteSubscription(String traderId, {required bool muted}) async {
    _check('mute');
    mutes.add((traderId, muted));
    return _nextProfile();
  }

  @override
  Future<Paged<TradeSubscriptionEntry>> subscriptions({String? cursor, int limit = 30}) async {
    _check('subscriptions');
    return Paged(subscriptionItems);
  }

  @override
  Future<Paged<TradeSubscriberEntry>> subscribers({
    TradeSubscriberStatus status = TradeSubscriberStatus.active,
    String? cursor,
    int limit = 30,
  }) async {
    _check('subscribers');
    subscriberQueries.add((status, cursor));
    return Paged(subscriberItems[status] ?? const []);
  }

  @override
  Future<TradeSubscriptionStatus> decideSubscriber(String subscriberId, {required bool approve}) async {
    _check('decide');
    decisions.add((subscriberId, approve));
    return approve ? TradeSubscriptionStatus.active : TradeSubscriptionStatus.declined;
  }

  @override
  Future<void> removeSubscriber(String subscriberId) async {
    _check('remove');
    removals.add(subscriberId);
  }

  @override
  Future<Paged<TradeActivity>> activityFeed({String? cursor, int limit = 30}) async {
    _check('feed');
    feedCursors.add(cursor);
    if (cursor != null) return Paged(feedSecondPage);
    return Paged(feedItems, nextCursor: feedNextCursor);
  }

  @override
  Future<TradeActivity> activity(String activityId) async {
    _check('activity');
    return detail ?? tradeActivity(id: activityId);
  }
}

class FakeTradeShareDependencies implements CommunityTradeShareDependencies {
  FakeTradeShareDependencies([FakeTradeShareRepository? repository])
    : repository = repository ?? FakeTradeShareRepository();

  final FakeTradeShareRepository repository;

  @override
  late final CommunityTradeShare tradeShare = CommunityTradeShare(repository);

  void dispose() => tradeShare.dispose();
}

Future<void> pumpTradeApp(
  WidgetTester tester,
  Widget child, {
  FakeTradeShareDependencies? trade,
  CommunityDependencies? dependencies,
  Locale locale = const Locale('id'),
  Size size = const Size(900, 1400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget body = child;
  if (trade != null) body = CommunityTradeShareScope(dependencies: trade, child: body);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(dependencies: dependencies ?? FakeDependencies(), child: body),
      ),
    ),
  );
}

CommunityException tradeError(String code, [String? message]) =>
    CommunityException(CommunityErrorKind.invalidInput, code: code, message: message);
