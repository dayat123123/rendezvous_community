import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/moderation_status.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

class CommunityAvatarDetails {
  const CommunityAvatarDetails({
    required this.user,
    required this.name,
    required this.initials,
    required this.radius,
    this.image,
    this.online = false,
    this.onTap,
    this.ringColor,
  });

  final UserSummary? user;
  final String name;
  final String initials;
  final double radius;
  final ImageProvider? image;
  final bool online;
  final VoidCallback? onTap;
  final Color? ringColor;

  double get size => radius * 2;
}

class CommunityUserNameDetails {
  const CommunityUserNameDetails({required this.user, required this.official, required this.showUsername, this.style});

  final UserSummary user;
  final bool official;
  final bool showUsername;
  final TextStyle? style;

  bool get verified => user.isVerified;

  String? get usernameLabel =>
      showUsername && user.displayName != null && user.displayName!.isNotEmpty ? '@${user.username}' : null;
}

class CommunityCardDetails {
  const CommunityCardDetails({
    required this.child,
    required this.padding,
    this.margin,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
}

class CommunityAuthorRowDetails {
  const CommunityAuthorRowDetails({
    required this.user,
    required this.avatar,
    required this.name,
    this.meta,
    this.official = false,
    this.trailing,
    this.onOpenAuthor,
  });

  final UserSummary user;
  final Widget avatar;
  final Widget name;
  final String? meta;
  final bool official;
  final Widget? trailing;
  final VoidCallback? onOpenAuthor;
}

class CommunityActionPillDetails {
  const CommunityActionPillDetails({
    required this.icon,
    this.activeIcon,
    this.label,
    this.count,
    this.countLabel,
    this.active = false,
    this.tooltip,
    this.onPressed,
    this.activeColor,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final int? count;
  final String? countLabel;
  final bool active;
  final String? tooltip;
  final VoidCallback? onPressed;
  final Color? activeColor;

  IconData get effectiveIcon => active ? activeIcon ?? icon : icon;

  String? get text => switch ((label, countLabel)) {
    (null, null) => null,
    (final String l, null) => l,
    (null, final String c) => c,
    (final String l, final String c) => '$l · $c',
  };
}

class CommunityActionButtonDetails {
  const CommunityActionButtonDetails({
    required this.icon,
    required this.tooltip,
    this.activeIcon,
    this.count,
    this.countLabel,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final IconData? activeIcon;
  final int? count;
  final String? countLabel;
  final bool active;
  final VoidCallback? onPressed;

  IconData get effectiveIcon => active ? activeIcon ?? icon : icon;
}

class CommunityActionBarDetails {
  const CommunityActionBarDetails({required this.leading, required this.trailing});

  final List<Widget> leading;
  final List<Widget> trailing;
}

class CommunitySectionHeaderDetails {
  const CommunitySectionHeaderDetails({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;
}

class CommunityDividerDetails {
  const CommunityDividerDetails({this.indent = 0, this.endIndent = 0, this.height});

  final double indent;
  final double endIndent;
  final double? height;
}

class CommunityTagDetails {
  const CommunityTagDetails({required this.label, this.icon, this.selected = false, this.onTap});

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
}

class CommunitySkeletonDetails {
  const CommunitySkeletonDetails({required this.index, required this.itemCount, this.custom = false});

  final int index;
  final int itemCount;
  final bool custom;
}

class CommunityLoadingViewDetails {
  const CommunityLoadingViewDetails({this.message});

  final String? message;
}

class CommunityEmptyViewDetails {
  const CommunityEmptyViewDetails({required this.message, required this.icon, this.action, this.title});

  final String message;
  final IconData icon;
  final Widget? action;
  final String? title;
}

class CommunityErrorViewDetails {
  const CommunityErrorViewDetails({required this.error, required this.message, this.onRetry});

  final Object error;
  final String message;
  final VoidCallback? onRetry;
}

class CommunityDisclaimerDetails {
  const CommunityDisclaimerDetails({required this.text, required this.padding});

  final String text;
  final EdgeInsetsGeometry padding;
}

class CommunityModerationNoticeDetails {
  const CommunityModerationNoticeDetails({
    required this.status,
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.compact,
    this.onAppeal,
  });

  final ModerationStatus status;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback? onAppeal;

  bool get held => status == ModerationStatus.held;
}

class CommunityHeldLabelDetails {
  const CommunityHeldLabelDetails({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

enum CommunitySuggestionKind { stock, user }

class CommunityComposerSuggestionDetails {
  const CommunityComposerSuggestionDetails({
    required this.kind,
    required this.title,
    required this.leading,
    required this.highlighted,
    required this.onSelect,
    this.subtitle,
  });

  final CommunitySuggestionKind kind;
  final String title;
  final String? subtitle;
  final Widget leading;
  final bool highlighted;
  final VoidCallback onSelect;
}

class CommunityConfirmDetails {
  const CommunityConfirmDetails({
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
}

class CommunityLinkConfirmDetails {
  const CommunityLinkConfirmDetails({
    required this.uri,
    required this.domain,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  final Uri uri;
  final String domain;
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
}

class CommunityImageViewerDetails {
  const CommunityImageViewerDetails({
    required this.attachments,
    required this.initialIndex,
    required this.image,
    required this.onClose,
    required this.onDownload,
    this.onCopy,
    this.sender,
    this.timeLabel,
    this.onReply,
    this.reactionChoices = const [],
    this.onReact,
  });

  final List<Attachment> attachments;
  final int initialIndex;
  final Widget Function(Attachment attachment) image;
  final VoidCallback onClose;
  final Future<String?> Function(Attachment attachment) onDownload;
  final Future<String?> Function(Attachment attachment)? onCopy;
  final UserSummary? sender;
  final String? timeLabel;
  final VoidCallback? onReply;
  final List<String> reactionChoices;
  final ValueChanged<String>? onReact;
}

class CommunityImagePlaceholderDetails {
  const CommunityImagePlaceholderDetails({required this.failed});

  final bool failed;
}
