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

class CommunitySupportPageHeaderDetails {
  const CommunitySupportPageHeaderDetails({
    required this.title,
    this.subtitle,
    this.onBack,
    this.onClose,
    this.ticket,
    this.downloadLabel,
    this.onDownload,
    this.downloading = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final SupportTicket? ticket;
  final String? downloadLabel;
  final VoidCallback? onDownload;
  final bool downloading;

  bool get canDownload => onDownload != null;
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
    this.survey,
    this.values = const [1, 2, 3, 4, 5],
    this.ratingLabels = const {},
    this.selectedReasons = const {},
    this.onToggleReason,
    this.reasons,
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
  final SupportSurvey? survey;
  final List<int> values;
  final Map<int, String> ratingLabels;
  final Set<String> selectedReasons;
  final ValueChanged<String>? onToggleReason;
  final Widget? reasons;

  bool get canSubmit => onSubmit != null;

  bool get faces => survey?.scale == 3;

  bool get asksReasons => survey?.asksReasons(rating) ?? false;
}

class CommunitySupportSurveyReasonsDetails {
  const CommunitySupportSurveyReasonsDetails({
    required this.reasons,
    required this.selected,
    required this.title,
    required this.hint,
    required this.onToggle,
  });

  final List<SupportSurveyReason> reasons;
  final Set<String> selected;
  final String title;
  final String hint;
  final ValueChanged<String> onToggle;
}

class CommunitySupportIncidentDetails {
  const CommunitySupportIncidentDetails({
    required this.incident,
    required this.tone,
    required this.icon,
    required this.levelLabel,
    required this.dismissLabel,
    required this.onDismiss,
    this.moreLabel,
    this.onMore,
  });

  final SupportIncident incident;
  final CommunitySupportTone tone;
  final IconData icon;
  final String levelLabel;
  final String dismissLabel;
  final VoidCallback onDismiss;
  final String? moreLabel;
  final VoidCallback? onMore;

  String get title => incident.title;

  String get body => incident.body;

  SupportIncidentLevel get level => incident.level;
}

class CommunitySupportIntakeDetails {
  const CommunitySupportIntakeDetails({
    required this.topic,
    required this.title,
    required this.hint,
    required this.fields,
    required this.answers,
    required this.errors,
    required this.fieldViews,
    required this.submitLabel,
    required this.backLabel,
    required this.busy,
    required this.onSubmit,
    required this.onBack,
    this.icon,
    this.notice,
  });

  final SupportTopic topic;
  final String title;
  final String hint;
  final List<SupportIntakeField> fields;
  final Map<String, String> answers;
  final Map<String, String> errors;
  final List<Widget> fieldViews;
  final String submitLabel;
  final String backLabel;
  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final IconData? icon;
  final String? notice;

  bool get valid => errors.isEmpty;
}

class CommunitySupportIntakeFieldDetails {
  const CommunitySupportIntakeFieldDetails({
    required this.field,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.enabled,
    this.error,
    this.optionalLabel,
    this.controller,
    this.onPickDate,
    this.dateLabel,
    this.pickDateLabel,
  });

  final SupportIntakeField field;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? error;
  final String? optionalLabel;
  final TextEditingController? controller;
  final VoidCallback? onPickDate;
  final String? dateLabel;
  final String? pickDateLabel;

  SupportIntakeType get type => field.type;

  bool get isRequired => field.isRequired;

  List<SupportIntakeOption> get options => field.options;
}

class CommunitySupportReplySuggestionsDetails {
  const CommunitySupportReplySuggestionsDetails({required this.replies, required this.label, this.onSelect});

  final List<String> replies;
  final String label;
  final ValueChanged<String>? onSelect;

  bool get enabled => onSelect != null;
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

  bool get danger => topic.danger;
}
