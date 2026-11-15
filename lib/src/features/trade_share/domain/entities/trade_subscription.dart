import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum TradeSubscriptionStatus { pending, active, declined, expired, ended }

enum TradeSubscriberStatus { active, pending }

enum TradeBellState { hidden, subscribe, pending, active, muted, unavailable }

abstract final class TradeSubscribeBlock {
  static const featureDisabled = 'feature_disabled';
  static const self = 'self';
  static const notSharing = 'not_sharing';
  static const notCustomer = 'not_customer';
  static const noLinkedAccount = 'no_linked_account';
  static const sanctioned = 'sanctioned';
  static const blocked = 'blocked';
  static const notFollowing = 'not_following';
  static const riskUnavailable = 'risk_unavailable';
}

class TradeSubscription {
  const TradeSubscription({
    required this.status,
    this.muted = false,
    this.requestedAt,
    this.decidedAt,
    this.expiresAt,
    this.endedAt,
    this.endReason,
  });

  final TradeSubscriptionStatus status;
  final bool muted;
  final DateTime? requestedAt;
  final DateTime? decidedAt;
  final DateTime? expiresAt;
  final DateTime? endedAt;
  final String? endReason;

  bool get isActive => status == TradeSubscriptionStatus.active;

  bool get isPending => status == TradeSubscriptionStatus.pending;
}

class TradeShareProfile {
  const TradeShareProfile({
    this.enabled = false,
    this.sharing = false,
    this.subscribeMode,
    this.subscription,
    this.canSubscribe = false,
    this.blockedReason,
    this.riskDocument,
  });

  final bool enabled;
  final bool sharing;
  final TradeSubscribeMode? subscribeMode;
  final TradeSubscription? subscription;
  final bool canSubscribe;
  final String? blockedReason;
  final TradeShareDocument? riskDocument;

  bool get needsRiskConsent => !(riskDocument?.accepted ?? false);

  TradeBellState get bell {
    if (!enabled) return TradeBellState.hidden;
    final current = subscription;
    if (current != null && current.isActive) return current.muted ? TradeBellState.muted : TradeBellState.active;
    if (current != null && current.isPending) return TradeBellState.pending;
    if (!sharing) return TradeBellState.hidden;
    return canSubscribe ? TradeBellState.subscribe : TradeBellState.unavailable;
  }
}

class TradeSubscriptionEntry {
  const TradeSubscriptionEntry({
    required this.trader,
    required this.subscription,
    this.sharing = true,
    required this.cursor,
  });

  final UserSummary trader;
  final TradeSubscription subscription;
  final bool sharing;
  final String cursor;

  TradeSubscriptionEntry withSubscription(TradeSubscription subscription) =>
      TradeSubscriptionEntry(trader: trader, subscription: subscription, sharing: sharing, cursor: cursor);
}

class TradeSubscriberEntry {
  const TradeSubscriberEntry({
    required this.subscriber,
    required this.status,
    this.requestedAt,
    this.decidedAt,
    this.expiresAt,
    required this.cursor,
  });

  final UserSummary subscriber;
  final TradeSubscriptionStatus status;
  final DateTime? requestedAt;
  final DateTime? decidedAt;
  final DateTime? expiresAt;
  final String cursor;
}
