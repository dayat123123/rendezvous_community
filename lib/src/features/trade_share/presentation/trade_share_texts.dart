import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

extension TradeShareTexts on CommunityLocalizations {
  String get tradeLanguage => localeName.split('_').first;

  String tradeDate(DateTime time) => DateFormat.yMMMd(localeName).add_Hm().format(time.toLocal());

  String tradeNumber(num value) => NumberFormat.decimalPattern(localeName).format(value);

  String tradeStatusLabel(TradeSharerStatus status) => switch (status) {
    TradeSharerStatus.none => tradeShareStatusNone,
    TradeSharerStatus.pending => tradeShareStatusPending,
    TradeSharerStatus.active => tradeShareStatusActive,
    TradeSharerStatus.paused => tradeShareStatusPaused,
    TradeSharerStatus.suspended => tradeShareStatusSuspended,
    TradeSharerStatus.rejected => tradeShareStatusRejected,
    TradeSharerStatus.revoked => tradeShareStatusRevoked,
    TradeSharerStatus.withdrawn => tradeShareStatusWithdrawn,
  };

  String tradeStatusHint(TradeShareStatus status) => switch (status.status) {
    TradeSharerStatus.none => tradeShareHintNone,
    TradeSharerStatus.pending => tradeShareHintPending,
    TradeSharerStatus.active => tradeShareHintActive(status.delayMinutes ?? status.limits.minDelayMinutes),
    TradeSharerStatus.paused when status.pauseSource == TradePauseSource.system => tradeShareHintPausedSystem,
    TradeSharerStatus.paused => tradeShareHintPaused,
    TradeSharerStatus.suspended => tradeShareHintSuspended,
    TradeSharerStatus.rejected => tradeShareHintRejected,
    TradeSharerStatus.revoked => tradeShareHintRevoked,
    TradeSharerStatus.withdrawn => tradeShareHintWithdrawn,
  };

  String tradeCheckLabel(String code) => switch (code) {
    TradeShareCheckCode.featureEnabled => tradeShareCheckFeature,
    TradeShareCheckCode.pilotInvited => tradeShareCheckPilot,
    TradeShareCheckCode.regularProfile => tradeShareCheckProfile,
    TradeShareCheckCode.notSanctioned => tradeShareCheckSanction,
    TradeShareCheckCode.accountAge => tradeShareCheckAge,
    TradeShareCheckCode.cooldown => tradeShareCheckCooldown,
    TradeShareCheckCode.linkedAccount => tradeShareCheckAccount,
    TradeShareCheckCode.termsAvailable => tradeShareCheckTerms,
    _ => code,
  };

  String? tradeCheckHint(String code, {DateTime? cooldownUntil}) => switch (code) {
    TradeShareCheckCode.featureEnabled => tradeShareUnavailable,
    TradeShareCheckCode.pilotInvited => tradeShareCheckPilotHint,
    TradeShareCheckCode.regularProfile => tradeShareCheckProfileHint,
    TradeShareCheckCode.notSanctioned => tradeShareCheckSanctionHint,
    TradeShareCheckCode.accountAge => tradeShareCheckAgeHint,
    TradeShareCheckCode.cooldown when cooldownUntil != null => tradeShareCooldown(tradeDate(cooldownUntil)),
    TradeShareCheckCode.linkedAccount => tradeShareCheckAccountHint,
    TradeShareCheckCode.termsAvailable => tradeShareCheckTermsHint,
    _ => null,
  };

  String tradeAccountState(TradeShareAccountState state) => switch (state) {
    TradeShareAccountState.active => tradeShareAccountActive,
    TradeShareAccountState.unlinked => tradeShareAccountUnlinked,
    TradeShareAccountState.expired => tradeShareAccountExpired,
    TradeShareAccountState.sharedLink => tradeShareAccountSharedLink,
    TradeShareAccountState.excluded || TradeShareAccountState.unknown => tradeShareAccountExcluded,
  };

  String tradeBlockedReason(String? reason) => switch (reason) {
    TradeSubscribeBlock.featureDisabled => tradeShareUnavailable,
    TradeSubscribeBlock.self => tradeBlockedSelf,
    TradeSubscribeBlock.notSharing => tradeNotSharingNow,
    TradeSubscribeBlock.notCustomer => tradeBlockedNotCustomer,
    TradeSubscribeBlock.noLinkedAccount => tradeBlockedNoAccount,
    TradeSubscribeBlock.sanctioned => tradeBlockedSanctioned,
    TradeSubscribeBlock.notFollowing => tradeBlockedNotFollowing,
    TradeSubscribeBlock.riskUnavailable => tradeBlockedRisk,
    _ => tradeBlockedBlocked,
  };

  String tradeSideLabel(TradeSide side) => side == TradeSide.sell ? tradeSideSell : tradeSideBuy;

  String tradeHeadline(String name, TradeSide side, String stock) =>
      side == TradeSide.sell ? tradeSharePreviewSell(name, stock) : tradeSharePreviewBuy(name, stock);

  String tradeVolume(num lots, {num? orderLots, bool partial = false, bool additional = false}) =>
      partial && orderLots != null && !additional
      ? tradeShareLotsOf(tradeNumber(lots), tradeNumber(orderLots))
      : tradeShareLots(tradeNumber(lots));

  String tradeSummary({num? lots, num? orderLots, int? price, bool partial = false, bool additional = false}) {
    final volume = lots == null
        ? null
        : tradeVolume(lots, orderLots: orderLots, partial: partial, additional: additional);
    final priced = price == null ? null : '@ ${tradeNumber(price)}';
    final head = [?volume, ?priced].join(' ');
    return [if (head.isNotEmpty) head, if (partial) tradeSharePartial].join(' · ');
  }

  TradeActivityText tradeActivityText(TradeActivity activity) {
    final server = activity.text(tradeLanguage);
    if (server != null) return server;
    final name = activity.trader?.name ?? someone;
    return TradeActivityText(
      title: tradeHeadline(name, activity.side, activity.stock),
      body: tradeSummary(
        lots: activity.lots,
        orderLots: activity.orderLots,
        price: activity.price,
        partial: activity.partial,
        additional: activity.additional,
      ),
    );
  }

  String tradePreviewBody({required bool showLot, required bool showPrice}) =>
      tradeSummary(lots: showLot ? 25 : null, price: showPrice ? 9150 : null);
}
