enum TradeSharerStatus { none, pending, active, paused, suspended, rejected, revoked, withdrawn }

enum TradePauseSource { user, system }

enum TradeSubscribeMode { auto, approval }

enum TradeShareAccountState { active, unlinked, expired, sharedLink, excluded, unknown }

abstract final class TradeShareCheckCode {
  static const featureEnabled = 'feature_enabled';
  static const pilotInvited = 'pilot_invited';
  static const regularProfile = 'regular_profile';
  static const notSanctioned = 'not_sanctioned';
  static const accountAge = 'account_age';
  static const cooldown = 'cooldown';
  static const linkedAccount = 'linked_account';
  static const termsAvailable = 'terms_available';
}

class TradeShareCheck {
  const TradeShareCheck({required this.code, required this.ok});

  final String code;
  final bool ok;
}

class TradeShareAccount {
  const TradeShareAccount({required this.custId, this.state = TradeShareAccountState.active});

  final String custId;
  final TradeShareAccountState state;

  bool get isActive => state == TradeShareAccountState.active;
}

class TradeShareDocument {
  const TradeShareDocument({
    required this.id,
    required this.version,
    required this.title,
    required this.body,
    this.effectiveAt,
    this.accepted = false,
  });

  final String id;
  final int version;
  final String title;
  final String body;
  final DateTime? effectiveAt;
  final bool accepted;
}

class TradeShareEligibility {
  const TradeShareEligibility({
    this.eligible = false,
    this.checks = const [],
    this.accounts = const [],
    this.cooldownUntil,
    this.termsDocument,
  });

  final bool eligible;
  final List<TradeShareCheck> checks;
  final List<TradeShareAccount> accounts;
  final DateTime? cooldownUntil;
  final TradeShareDocument? termsDocument;

  List<TradeShareCheck> get failedChecks => [
    for (final check in checks)
      if (!check.ok) check,
  ];
}

class TradeShareLimits {
  const TradeShareLimits({
    this.minDelayMinutes = 15,
    this.maxDelayMinutes = 240,
    this.forceHidePrice = false,
    this.forceHideLot = false,
  });

  final int minDelayMinutes;
  final int maxDelayMinutes;
  final bool forceHidePrice;
  final bool forceHideLot;

  int clampDelay(int minutes) => minutes < minDelayMinutes
      ? minDelayMinutes
      : minutes > maxDelayMinutes
      ? maxDelayMinutes
      : minutes;
}

const _applicable = {
  TradeSharerStatus.none,
  TradeSharerStatus.rejected,
  TradeSharerStatus.revoked,
  TradeSharerStatus.withdrawn,
};

const _editable = {TradeSharerStatus.pending, TradeSharerStatus.active, TradeSharerStatus.paused};

const _running = {
  TradeSharerStatus.pending,
  TradeSharerStatus.active,
  TradeSharerStatus.paused,
  TradeSharerStatus.suspended,
};

class TradeShareStatus {
  const TradeShareStatus({
    this.enabled = false,
    this.status = TradeSharerStatus.none,
    this.pauseSource,
    this.showPrice = true,
    this.showLot = true,
    this.delayMinutes,
    this.subscribeMode = TradeSubscribeMode.auto,
    this.appliedAt,
    this.decidedAt,
    this.decisionReason,
    this.suspendedUntil,
    this.cooldownUntil,
    this.accounts = const [],
    this.activeSubscribers = 0,
    this.pendingSubscribers = 0,
    this.limits = const TradeShareLimits(),
    this.eligibility = const TradeShareEligibility(),
  });

  final bool enabled;
  final TradeSharerStatus status;
  final TradePauseSource? pauseSource;
  final bool showPrice;
  final bool showLot;
  final int? delayMinutes;
  final TradeSubscribeMode subscribeMode;
  final DateTime? appliedAt;
  final DateTime? decidedAt;
  final String? decisionReason;
  final DateTime? suspendedUntil;
  final DateTime? cooldownUntil;
  final List<TradeShareAccount> accounts;
  final int activeSubscribers;
  final int pendingSubscribers;
  final TradeShareLimits limits;
  final TradeShareEligibility eligibility;

  bool get canApply => enabled && _applicable.contains(status);

  bool get canEdit => enabled && _editable.contains(status);

  bool get canPause => enabled && status == TradeSharerStatus.active;

  bool get canResume => enabled && status == TradeSharerStatus.paused;

  bool get canWithdraw => enabled && _running.contains(status);

  bool get isTrader => status != TradeSharerStatus.none;

  bool get inCooldown {
    final until = cooldownUntil ?? eligibility.cooldownUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  TradeShareStatus withEnabled(bool enabled) => TradeShareStatus(
    enabled: enabled,
    status: status,
    pauseSource: pauseSource,
    showPrice: showPrice,
    showLot: showLot,
    delayMinutes: delayMinutes,
    subscribeMode: subscribeMode,
    appliedAt: appliedAt,
    decidedAt: decidedAt,
    decisionReason: decisionReason,
    suspendedUntil: suspendedUntil,
    cooldownUntil: cooldownUntil,
    accounts: accounts,
    activeSubscribers: activeSubscribers,
    pendingSubscribers: pendingSubscribers,
    limits: limits,
    eligibility: eligibility,
  );
}

class TradeShareApplication {
  const TradeShareApplication({
    required this.accounts,
    this.showPrice = true,
    this.showLot = true,
    required this.delayMinutes,
    this.subscribeMode = TradeSubscribeMode.auto,
  });

  final List<String> accounts;
  final bool showPrice;
  final bool showLot;
  final int delayMinutes;
  final TradeSubscribeMode subscribeMode;
}
