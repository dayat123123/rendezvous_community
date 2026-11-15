import 'package:rendezvous_community/src/core/network/json_values.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/shared/data/models/user_summary_model.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

String? _text(Object? value) => value is String && value.isNotEmpty ? value : null;

bool _bool(Object? value, {bool fallback = false}) => value is bool ? value : fallback;

int? _int(Object? value) => switch (value) {
  final num n => n.toInt(),
  final String s => int.tryParse(s),
  _ => null,
};

DateTime? _time(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;

TradeSharerStatus tradeSharerStatusFromJson(Object? value) => switch (value) {
  'pending' => TradeSharerStatus.pending,
  'active' => TradeSharerStatus.active,
  'paused' => TradeSharerStatus.paused,
  'suspended' => TradeSharerStatus.suspended,
  'rejected' => TradeSharerStatus.rejected,
  'revoked' => TradeSharerStatus.revoked,
  'withdrawn' => TradeSharerStatus.withdrawn,
  _ => TradeSharerStatus.none,
};

TradeSubscribeMode? tradeSubscribeModeFromJson(Object? value) => switch (value) {
  'auto' => TradeSubscribeMode.auto,
  'approval' => TradeSubscribeMode.approval,
  _ => null,
};

String tradeSubscribeModeToJson(TradeSubscribeMode mode) => switch (mode) {
  TradeSubscribeMode.auto => 'auto',
  TradeSubscribeMode.approval => 'approval',
};

TradeShareAccountState tradeShareAccountStateFromJson(Object? value) => switch (value) {
  'active' => TradeShareAccountState.active,
  'unlinked' => TradeShareAccountState.unlinked,
  'expired' => TradeShareAccountState.expired,
  'shared_link' => TradeShareAccountState.sharedLink,
  'excluded' => TradeShareAccountState.excluded,
  _ => TradeShareAccountState.unknown,
};

TradeSubscriptionStatus tradeSubscriptionStatusFromJson(Object? value) => switch (value) {
  'pending' => TradeSubscriptionStatus.pending,
  'active' => TradeSubscriptionStatus.active,
  'declined' => TradeSubscriptionStatus.declined,
  'expired' => TradeSubscriptionStatus.expired,
  _ => TradeSubscriptionStatus.ended,
};

List<TradeShareAccount> _accounts(Object? value) => [
  for (final row in jsonList(value))
    if (_text(row['cust_id']) != null)
      TradeShareAccount(custId: row['cust_id'] as String, state: tradeShareAccountStateFromJson(row['state'])),
];

TradeShareDocument? tradeShareDocumentFromJson(Object? value) {
  final json = jsonMap(value);
  final id = _text(json['id']);
  if (id == null) return null;
  return TradeShareDocument(
    id: id,
    version: _int(json['version']) ?? 1,
    title: _text(json['title']) ?? '',
    body: json['body'] is String ? json['body'] as String : '',
    effectiveAt: _time(json['effective_at']),
    accepted: _bool(json['accepted']),
  );
}

TradeShareEligibility tradeShareEligibilityFromJson(Object? value) {
  final json = jsonMap(value);
  return TradeShareEligibility(
    eligible: _bool(json['eligible']),
    checks: [
      for (final row in jsonList(json['checks']))
        if (_text(row['code']) != null) TradeShareCheck(code: row['code'] as String, ok: _bool(row['ok'])),
    ],
    accounts: _accounts(json['accounts']),
    cooldownUntil: _time(json['cooldown_until']),
    termsDocument: tradeShareDocumentFromJson(json['terms_document']),
  );
}

TradeShareLimits tradeShareLimitsFromJson(Object? value) {
  final json = jsonMap(value);
  const fallback = TradeShareLimits();
  return TradeShareLimits(
    minDelayMinutes: _int(json['min_delay_minutes']) ?? fallback.minDelayMinutes,
    maxDelayMinutes: _int(json['max_delay_minutes']) ?? fallback.maxDelayMinutes,
    forceHidePrice: _bool(json['force_hide_price']),
    forceHideLot: _bool(json['force_hide_lot']),
  );
}

TradeShareStatus tradeShareStatusFromJson(Object? value) {
  final json = jsonMap(value);
  final subscribers = jsonMap(json['subscribers']);
  return TradeShareStatus(
    enabled: _bool(json['enabled']),
    status: tradeSharerStatusFromJson(json['status']),
    pauseSource: switch (json['pause_source']) {
      'user' => TradePauseSource.user,
      'system' => TradePauseSource.system,
      _ => null,
    },
    showPrice: _bool(json['show_price'], fallback: true),
    showLot: _bool(json['show_lot'], fallback: true),
    delayMinutes: _int(json['delay_minutes']),
    subscribeMode: tradeSubscribeModeFromJson(json['subscribe_mode']) ?? TradeSubscribeMode.auto,
    appliedAt: _time(json['applied_at']),
    decidedAt: _time(json['decided_at']),
    decisionReason: _text(json['decision_reason']),
    suspendedUntil: _time(json['suspended_until']),
    cooldownUntil: _time(json['cooldown_until']),
    accounts: _accounts(json['accounts']),
    activeSubscribers: _int(subscribers['active']) ?? 0,
    pendingSubscribers: _int(subscribers['pending']) ?? 0,
    limits: tradeShareLimitsFromJson(json['limits']),
    eligibility: tradeShareEligibilityFromJson(json['eligibility']),
  );
}

TradeSubscription? tradeSubscriptionFromJson(Object? value) {
  final json = jsonMap(value);
  if (_text(json['status']) == null) return null;
  return TradeSubscription(
    status: tradeSubscriptionStatusFromJson(json['status']),
    muted: _bool(json['muted']),
    requestedAt: _time(json['requested_at']),
    decidedAt: _time(json['decided_at']),
    expiresAt: _time(json['expires_at']),
    endedAt: _time(json['ended_at']),
    endReason: _text(json['end_reason']),
  );
}

TradeShareProfile tradeShareProfileFromJson(Object? value) {
  final json = jsonMap(value);
  return TradeShareProfile(
    enabled: _bool(json['enabled']),
    sharing: _bool(json['sharing']),
    subscribeMode: tradeSubscribeModeFromJson(json['subscribe_mode']),
    subscription: tradeSubscriptionFromJson(json['subscription']),
    canSubscribe: _bool(json['can_subscribe']),
    blockedReason: _text(json['blocked_reason']),
    riskDocument: tradeShareDocumentFromJson(json['risk_document']),
  );
}

UserSummary? tradeUserFromJson(Object? value) {
  final json = jsonMap(value);
  if (_text(json['id']) == null) return null;
  return UserSummaryModel.fromJson({
    ...json,
    'username': json['username'] is String ? json['username'] : '',
  }).toEntity();
}

TradeSubscriptionEntry? tradeSubscriptionEntryFromJson(Map<String, dynamic> json) {
  final trader = tradeUserFromJson(json['trader']);
  final subscription = tradeSubscriptionFromJson(json);
  if (trader == null || subscription == null) return null;
  return TradeSubscriptionEntry(
    trader: trader,
    subscription: subscription,
    sharing: _bool(json['sharing'], fallback: true),
    cursor: _text(json['cursor']) ?? '',
  );
}

TradeSubscriberEntry? tradeSubscriberEntryFromJson(Map<String, dynamic> json) {
  final subscriber = tradeUserFromJson(json['subscriber']);
  if (subscriber == null) return null;
  return TradeSubscriberEntry(
    subscriber: subscriber,
    status: tradeSubscriptionStatusFromJson(json['status']),
    requestedAt: _time(json['requested_at']),
    decidedAt: _time(json['decided_at']),
    expiresAt: _time(json['expires_at']),
    cursor: _text(json['cursor']) ?? '',
  );
}

TradeActivity? tradeActivityFromJson(Map<String, dynamic> json) =>
    TradeActivity.fromPayload(json, trader: tradeUserFromJson(json['trader']));
