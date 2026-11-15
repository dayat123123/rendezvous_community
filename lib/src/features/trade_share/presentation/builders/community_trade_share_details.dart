import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum CommunityTradeArea { settings, subscriptions, subscribers, activityFeed, activityDetail }

enum CommunityTradeActivityPlacement { feed, notification }

class CommunityTradeLoadingDetails {
  const CommunityTradeLoadingDetails({required this.area});

  final CommunityTradeArea area;
}

class CommunityTradeEmptyDetails {
  const CommunityTradeEmptyDetails({required this.area, required this.message, required this.icon});

  final CommunityTradeArea area;
  final String message;
  final IconData icon;
}

class CommunityTradeErrorDetails {
  const CommunityTradeErrorDetails({
    required this.area,
    required this.error,
    required this.message,
    required this.onRetry,
  });

  final CommunityTradeArea area;
  final Object error;
  final String message;
  final VoidCallback onRetry;
}

class CommunityTradeUnavailableDetails {
  const CommunityTradeUnavailableDetails({required this.message, required this.icon});

  final String message;
  final IconData icon;
}

class CommunityTradeShareStatusDetails {
  const CommunityTradeShareStatusDetails({
    required this.status,
    required this.title,
    required this.label,
    required this.hint,
    required this.icon,
    required this.tone,
    this.reason,
    this.suspendedUntil,
    this.cooldown,
    this.intro,
    this.busy = false,
    required this.pauseLabel,
    required this.resumeLabel,
    required this.withdrawLabel,
    this.onPause,
    this.onResume,
    this.onWithdraw,
  });

  final TradeShareStatus status;
  final String title;
  final String label;
  final String hint;
  final IconData icon;
  final Color tone;
  final String? reason;
  final String? suspendedUntil;
  final String? cooldown;
  final String? intro;
  final bool busy;
  final String pauseLabel;
  final String resumeLabel;
  final String withdrawLabel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onWithdraw;
}

class CommunityTradeShareCheckDetails {
  const CommunityTradeShareCheckDetails({required this.check, required this.label, this.hint});

  final TradeShareCheck check;
  final String label;
  final String? hint;

  bool get ok => check.ok;
}

class CommunityTradeSharePreviewDetails {
  const CommunityTradeSharePreviewDetails({
    required this.user,
    required this.title,
    required this.body,
    required this.showLot,
    required this.showPrice,
  });

  final UserSummary? user;
  final String title;
  final String body;
  final bool showLot;
  final bool showPrice;
}

class CommunityTradeProfileBarDetails {
  const CommunityTradeProfileBarDetails({
    required this.user,
    required this.profile,
    required this.bell,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.bellLabel,
    required this.bellIcon,
    this.hint,
    this.busy = false,
    this.onBell,
    this.onSubscribe,
    this.onMute,
    this.onUnmute,
    this.onCancel,
  });

  final UserSummary user;
  final TradeShareProfile profile;
  final TradeBellState bell;
  final String badgeLabel;
  final IconData badgeIcon;
  final String bellLabel;
  final IconData bellIcon;
  final String? hint;
  final bool busy;
  final VoidCallback? onBell;
  final VoidCallback? onSubscribe;
  final VoidCallback? onMute;
  final VoidCallback? onUnmute;
  final VoidCallback? onCancel;

  bool get sharing => profile.sharing;
}

class CommunityTradeSubscriptionTileDetails {
  const CommunityTradeSubscriptionTileDetails({
    required this.entry,
    required this.statusLabel,
    required this.subtitle,
    this.busy = false,
    required this.muteLabel,
    required this.cancelLabel,
    required this.onOpen,
    this.onToggleMute,
    required this.onCancel,
  });

  final TradeSubscriptionEntry entry;
  final String statusLabel;
  final String subtitle;
  final bool busy;
  final String muteLabel;
  final String cancelLabel;
  final VoidCallback onOpen;
  final VoidCallback? onToggleMute;
  final VoidCallback onCancel;

  UserSummary get trader => entry.trader;

  bool get muted => entry.subscription.muted;

  bool get pending => entry.subscription.isPending;
}

class CommunityTradeSubscriberTileDetails {
  const CommunityTradeSubscriberTileDetails({
    required this.entry,
    this.subtitle,
    this.busy = false,
    required this.approveLabel,
    required this.declineLabel,
    required this.removeLabel,
    required this.onOpen,
    this.onApprove,
    this.onDecline,
    this.onRemove,
  });

  final TradeSubscriberEntry entry;
  final String? subtitle;
  final bool busy;
  final String approveLabel;
  final String declineLabel;
  final String removeLabel;
  final VoidCallback onOpen;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onRemove;

  UserSummary get subscriber => entry.subscriber;

  bool get pending => entry.status == TradeSubscriptionStatus.pending;
}

class CommunityTradeActivityTileDetails {
  const CommunityTradeActivityTileDetails({
    required this.activity,
    required this.placement,
    required this.title,
    required this.body,
    this.timeLabel,
    this.notification,
    required this.onTap,
  });

  final TradeActivity activity;
  final CommunityTradeActivityPlacement placement;
  final String title;
  final String body;
  final String? timeLabel;
  final AppNotification? notification;
  final VoidCallback onTap;

  bool get isRead => notification?.isRead ?? true;
}

class CommunityTradeActivityFact {
  const CommunityTradeActivityFact({required this.label, required this.value});

  final String label;
  final String value;
}

class CommunityTradeActivityViewDetails {
  const CommunityTradeActivityViewDetails({
    required this.activity,
    required this.title,
    required this.body,
    required this.facts,
    required this.badges,
    required this.disclaimer,
    required this.openStockLabel,
    required this.onOpenStock,
    this.onOpenTrader,
  });

  final TradeActivity activity;
  final String title;
  final String body;
  final List<CommunityTradeActivityFact> facts;
  final List<String> badges;
  final String disclaimer;
  final String openStockLabel;
  final VoidCallback onOpenStock;
  final VoidCallback? onOpenTrader;
}
