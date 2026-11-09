import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_ticket.freezed.dart';

enum SupportStatus { open, claimed, waitingCustomer, resolved, closed }

@freezed
abstract class SupportAgent with _$SupportAgent {
  const factory SupportAgent({required String displayName, String? agentCode}) = _SupportAgent;
}

@freezed
abstract class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    required String ticketNumber,
    required String roomId,
    required String topic,
    String? topicName,
    required SupportStatus status,
    int? queueAhead,
    SupportAgent? agent,
    DateTime? complaintReceivedAt,
    DateTime? complaintDueAt,
    required DateTime createdAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenUntil,
    int? rating,
    @Default(false) bool canRate,
    int? etaMinutes,
    @Default(<String>[]) List<String> quickReplies,
  }) = _SupportTicket;

  const SupportTicket._();

  bool get isActive =>
      status == SupportStatus.open || status == SupportStatus.claimed || status == SupportStatus.waitingCustomer;

  bool reopenable(DateTime now) => status == SupportStatus.resolved && (reopenUntil?.isAfter(now) ?? false);
}

@freezed
abstract class SupportHome with _$SupportHome {
  const factory SupportHome({
    String? roomId,
    required String supportName,
    SupportTicket? ticket,
    @Default(false) bool active,
    @Default(0) int unreadCount,
    @Default(true) bool serviceOpen,
    DateTime? nextOpenAt,
    @Default(SupportTopicPickerTexts()) SupportTopicPickerTexts topicPicker,
    @Default(<SupportIncident>[]) List<SupportIncident> incidents,
    @Default(<String, SupportSurvey>{}) Map<String, SupportSurvey> surveys,
  }) = _SupportHome;

  const SupportHome._();

  SupportSurvey? survey(String languageCode) => surveys[languageCode] ?? surveys['id'];

  List<SupportIncident> activeIncidents(DateTime now) => [
    for (final incident in incidents)
      if (incident.activeAt(now)) incident,
  ];

  String? topicTitle(String languageCode) => topicPicker.title[languageCode];

  String? topicHint(String languageCode) => topicPicker.hint[languageCode];

  bool showsConversation(DateTime now) =>
      roomId != null && (active || (ticket?.reopenable(now) ?? false) || (ticket?.canRate ?? false));
}

@freezed
abstract class SupportTopic with _$SupportTopic {
  const factory SupportTopic({
    required String code,
    required String name,
    String? helpUrl,
    @Default(false) bool urgent,
    String? description,
    String? icon,
    @Default('normal') String style,
    @Default(<SupportIntakeField>[]) List<SupportIntakeField> intake,
  }) = _SupportTopic;

  const SupportTopic._();

  bool get danger => style == 'danger';

  bool get hasIntake => intake.isNotEmpty;
}

enum SupportIntakeType { text, number, date, choice }

@freezed
abstract class SupportIntakeOption with _$SupportIntakeOption {
  const factory SupportIntakeOption({required String value, required String label}) = _SupportIntakeOption;
}

@freezed
abstract class SupportIntakeField with _$SupportIntakeField {
  const factory SupportIntakeField({
    required String key,
    required SupportIntakeType type,
    required String label,
    @Default(false) bool isRequired,
    @Default(<SupportIntakeOption>[]) List<SupportIntakeOption> options,
  }) = _SupportIntakeField;

  const SupportIntakeField._();

  String? optionLabel(String value) => options.where((o) => o.value == value).firstOrNull?.label;
}

enum SupportIncidentLevel { info, warning, critical }

@freezed
abstract class SupportIncident with _$SupportIncident {
  const factory SupportIncident({
    required String id,
    required String title,
    required String body,
    @Default(SupportIncidentLevel.info) SupportIncidentLevel level,
    DateTime? startsAt,
    DateTime? endsAt,
    String? faqArticleId,
  }) = _SupportIncident;

  const SupportIncident._();

  bool activeAt(DateTime now) => endsAt == null || endsAt!.isAfter(now);
}

@freezed
abstract class SupportSurveyReason with _$SupportSurveyReason {
  const factory SupportSurveyReason({required String code, required String label}) = _SupportSurveyReason;
}

@freezed
abstract class SupportSurvey with _$SupportSurvey {
  const factory SupportSurvey({
    required String question,
    @Default(5) int scale,
    @Default(2) int lowMax,
    @Default(<SupportSurveyReason>[]) List<SupportSurveyReason> reasons,
  }) = _SupportSurvey;

  const SupportSurvey._();

  List<int> get values => scale == 3 ? const [1, 3, 5] : const [1, 2, 3, 4, 5];

  bool isLow(int rating) => rating > 0 && rating <= lowMax;

  bool asksReasons(int rating) => reasons.isNotEmpty && isLow(rating);
}

@freezed
abstract class SupportTopicPickerTexts with _$SupportTopicPickerTexts {
  const factory SupportTopicPickerTexts({
    @Default(<String, String>{}) Map<String, String> title,
    @Default(<String, String>{}) Map<String, String> hint,
  }) = _SupportTopicPickerTexts;
}

@freezed
abstract class SensitiveCheck with _$SensitiveCheck {
  const factory SensitiveCheck({@Default(false) bool masked, @Default(<String>[]) List<String> kinds}) =
      _SensitiveCheck;
}

@freezed
abstract class SupportNotice with _$SupportNotice {
  const factory SupportNotice({
    required String id,
    required String title,
    required String body,
    String? ticketId,
    String? roomId,
  }) = _SupportNotice;
}
