import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum CommunitySupportTone { neutral, info, warning, danger }

class CommunitySupportHeaderDetails {
  const CommunitySupportHeaderDetails({
    required this.title,
    required this.subtitle,
    required this.menuTooltip,
    this.ticket,
    this.statusLabel,
    this.busy = false,
    this.onComplaint,
    this.onReportFake,
    this.onEndChat,
    this.onNewTicket,
    this.onShowTickets,
    this.onClose,
  });

  final String title;
  final String subtitle;
  final String menuTooltip;
  final SupportTicket? ticket;
  final String? statusLabel;
  final bool busy;
  final VoidCallback? onComplaint;
  final VoidCallback? onReportFake;
  final VoidCallback? onEndChat;
  final VoidCallback? onNewTicket;
  final VoidCallback? onShowTickets;
  final VoidCallback? onClose;

  SupportStatus? get status => ticket?.status;

  String? get ticketNumber => ticket?.ticketNumber;
}

class CommunitySupportBannerDetails {
  const CommunitySupportBannerDetails({required this.message, this.tone = CommunitySupportTone.info, this.icon});

  final String message;
  final CommunitySupportTone tone;
  final IconData? icon;
}

class CommunitySupportTicketDetails {
  const CommunitySupportTicketDetails({
    required this.ticket,
    required this.title,
    required this.statusLabel,
    required this.meta,
    required this.timeLabel,
    required this.icon,
    required this.onOpen,
  });

  final SupportTicket ticket;
  final String title;
  final String statusLabel;
  final String meta;
  final String timeLabel;
  final IconData icon;
  final VoidCallback onOpen;

  String get number => ticket.ticketNumber;

  bool get closed => !ticket.isActive;
}

class CommunitySensitiveWarningDetails {
  const CommunitySensitiveWarningDetails({required this.kinds, required this.message});

  final List<String> kinds;
  final String message;
}

class CommunitySupportClosedDetails {
  const CommunitySupportClosedDetails({
    required this.ticketNumber,
    required this.message,
    required this.newTicketLabel,
    required this.onNewTicket,
  });

  final String ticketNumber;
  final String message;
  final String newTicketLabel;
  final VoidCallback onNewTicket;
}

class CommunitySupportRatingDetails {
  const CommunitySupportRatingDetails({
    required this.rating,
    required this.controller,
    required this.title,
    required this.commentLabel,
    required this.submitLabel,
    required this.cancelLabel,
    required this.onRate,
    required this.onCancel,
    this.onSubmit,
    this.maxRating = 5,
  });

  final int rating;
  final TextEditingController controller;
  final String title;
  final String commentLabel;
  final String submitLabel;
  final String cancelLabel;
  final ValueChanged<int> onRate;
  final VoidCallback onCancel;
  final VoidCallback? onSubmit;
  final int maxRating;

  bool get canSubmit => onSubmit != null;
}

class CommunityFakeCsDetails {
  const CommunityFakeCsDetails({
    required this.controller,
    required this.title,
    required this.hintText,
    required this.submitLabel,
    required this.cancelLabel,
    required this.onCancel,
    this.onSubmit,
  });

  final TextEditingController controller;
  final String title;
  final String hintText;
  final String submitLabel;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback? onSubmit;

  bool get canSubmit => onSubmit != null;
}

class CommunitySupportNoticeDetails {
  const CommunitySupportNoticeDetails({
    required this.message,
    required this.text,
    required this.icon,
    required this.timeLabel,
    this.rateLabel,
    this.onRate,
  });

  final ChatMessage message;
  final String text;
  final IconData icon;
  final String timeLabel;
  final String? rateLabel;
  final VoidCallback? onRate;

  String? get code => message.systemCode;

  MessageKind get kind => message.kind;
}

class CommunityOfficialSenderDetails {
  const CommunityOfficialSenderDetails({required this.sender, required this.color});

  final UserSummary sender;
  final Color color;

  String get name => sender.name;
}

class CommunityQuickRepliesDetails {
  const CommunityQuickRepliesDetails({required this.message, required this.options, required this.mine, this.onSelect});

  final ChatMessage message;
  final List<String> options;
  final bool mine;
  final ValueChanged<String>? onSelect;

  bool get enabled => onSelect != null;
}

class CommunityHelpLinkDetails {
  const CommunityHelpLinkDetails({required this.uri, required this.label, required this.onOpen});

  final Uri uri;
  final String label;
  final VoidCallback onOpen;
}

class CommunitySupportTopicPickerDetails {
  const CommunitySupportTopicPickerDetails({
    required this.topics,
    required this.title,
    required this.hint,
    required this.busy,
    required this.onSelect,
    this.historyLabel,
    this.onShowHistory,
  });

  final List<SupportTopic> topics;
  final String title;
  final String hint;
  final bool busy;
  final ValueChanged<String> onSelect;
  final String? historyLabel;
  final VoidCallback? onShowHistory;
}

class CommunitySupportTopicDetails {
  const CommunitySupportTopicDetails({required this.topic, required this.icon, required this.busy, this.onSelect});

  final SupportTopic topic;
  final IconData icon;
  final bool busy;
  final VoidCallback? onSelect;

  bool get urgent => topic.urgent;
}
