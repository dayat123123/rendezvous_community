import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';

class CommunityNotificationDetails {
  const CommunityNotificationDetails({
    required this.notification,
    required this.title,
    required this.icon,
    required this.timeLabel,
    required this.onTap,
    this.snippet,
    this.important = false,
  });

  final AppNotification notification;
  final String title;
  final String? snippet;
  final IconData icon;
  final String timeLabel;
  final bool important;
  final VoidCallback onTap;

  bool get isRead => notification.isRead;

  bool get isOlt => notification.isOlt;
}

class CommunityNotificationIconDetails {
  const CommunityNotificationIconDetails({
    required this.notification,
    required this.icon,
    this.important = false,
    this.size = 40,
  });

  final AppNotification notification;
  final IconData icon;
  final bool important;
  final double size;

  bool get isOlt => notification.isOlt;

  bool get isRead => notification.isRead;
}

class CommunityNotificationHeaderDetails {
  const CommunityNotificationHeaderDetails({required this.title, required this.unread, this.onMarkAllRead});

  final String title;
  final int unread;
  final VoidCallback? onMarkAllRead;
}

enum CommunityNotificationSection { newer, earlier }

class CommunityNotificationSectionDetails {
  const CommunityNotificationSectionDetails({required this.section, required this.title});

  final CommunityNotificationSection section;
  final String title;
}
