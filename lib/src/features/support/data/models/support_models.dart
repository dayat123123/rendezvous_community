import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_transcript.dart';

part 'support_models.freezed.dart';
part 'support_models.g.dart';

const _statuses = {
  'open': SupportStatus.open,
  'claimed': SupportStatus.claimed,
  'waiting_customer': SupportStatus.waitingCustomer,
  'resolved': SupportStatus.resolved,
  'closed': SupportStatus.closed,
};

@freezed
abstract class SupportTicketModel with _$SupportTicketModel {
  const factory SupportTicketModel({
    required String id,
    required String ticketNumber,
    required String roomId,
    required String topic,
    String? topicName,
    required String status,
    int? queueAhead,
    Map<String, dynamic>? agent,
    Map<String, dynamic>? complaint,
    required DateTime createdAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    DateTime? reopenUntil,
    int? rating,
    @Default(false) bool canRate,
    int? etaMinutes,
    List<Object?>? quickReplies,
  }) = _SupportTicketModel;

  const SupportTicketModel._();

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) => _$SupportTicketModelFromJson(json);

  SupportTicket toEntity() => SupportTicket(
    id: id,
    ticketNumber: ticketNumber,
    roomId: roomId,
    topic: topic,
    topicName: topicName,
    status: _statuses[status] ?? SupportStatus.closed,
    queueAhead: queueAhead,
    agent: agent == null
        ? null
        : SupportAgent(
            displayName: agent!['display_name'] as String? ?? '',
            agentCode: agent!['agent_code'] as String?,
          ),
    complaintReceivedAt: DateTime.tryParse(complaint?['received_at'] as String? ?? ''),
    complaintDueAt: DateTime.tryParse(complaint?['due_at'] as String? ?? ''),
    createdAt: createdAt,
    resolvedAt: resolvedAt,
    closedAt: closedAt,
    reopenUntil: reopenUntil,
    rating: rating,
    canRate: canRate,
    etaMinutes: etaMinutes,
    quickReplies: [
      for (final reply in quickReplies ?? const <Object?>[])
        if (reply is String && reply.trim().isNotEmpty) reply.trim(),
    ],
  );
}

@freezed
abstract class SupportHomeModel with _$SupportHomeModel {
  const factory SupportHomeModel({
    String? roomId,
    @Default('') String supportName,
    SupportTicketModel? ticket,
    @Default(false) bool active,
    @Default(0) int unreadCount,
    @Default(true) bool serviceOpen,
    DateTime? nextOpenAt,
    Map<String, dynamic>? topicPicker,
    List<Object?>? incidents,
    Map<String, dynamic>? survey,
  }) = _SupportHomeModel;

  const SupportHomeModel._();

  factory SupportHomeModel.fromJson(Map<String, dynamic> json) => _$SupportHomeModelFromJson(json);

  SupportHome toEntity() => SupportHome(
    roomId: roomId,
    supportName: supportName,
    ticket: ticket?.toEntity(),
    active: active,
    unreadCount: unreadCount,
    serviceOpen: serviceOpen,
    nextOpenAt: nextOpenAt,
    topicPicker: SupportTopicPickerTexts(title: _texts(topicPicker?['title']), hint: _texts(topicPicker?['hint'])),
    incidents: parseSupportIncidents(incidents),
    surveys: {
      for (final entry in survey?.entries ?? const <MapEntry<String, dynamic>>[])
        entry.key: ?parseSupportSurvey(entry.value),
    },
  );

  static Map<String, String> _texts(Object? raw) => {
    if (raw is Map)
      for (final entry in raw.entries)
        if (entry.value is String && (entry.value as String).trim().isNotEmpty) '${entry.key}': entry.value as String,
  };
}

const _incidentLevels = {
  'info': SupportIncidentLevel.info,
  'warning': SupportIncidentLevel.warning,
  'critical': SupportIncidentLevel.critical,
};

const _intakeTypes = {
  'text': SupportIntakeType.text,
  'number': SupportIntakeType.number,
  'date': SupportIntakeType.date,
  'choice': SupportIntakeType.choice,
};

const _senders = {
  'customer': SupportTranscriptSender.customer,
  'agent': SupportTranscriptSender.agent,
  'system': SupportTranscriptSender.system,
};

String? _text(Object? value) => value is String && value.trim().isNotEmpty ? value.trim() : null;

DateTime? _time(Object? value) => value is String ? DateTime.tryParse(value) : null;

List<Map<String, dynamic>> _objects(Object? raw) => [
  if (raw is List)
    for (final item in raw)
      if (item is Map<String, dynamic>) item,
];

List<SupportIncident> parseSupportIncidents(Object? raw) => [
  for (final row in _objects(raw))
    if ((_text(row['id']), _text(row['title'])) case (final id?, final title?))
      SupportIncident(
        id: id,
        title: title,
        body: _text(row['body']) ?? '',
        level: _incidentLevels[row['level']] ?? SupportIncidentLevel.info,
        startsAt: _time(row['starts_at']),
        endsAt: _time(row['ends_at']),
        faqArticleId: _text(row['faq_article_id']),
      ),
];

SupportSurvey? parseSupportSurvey(Object? raw) {
  if (raw is! Map<String, dynamic>) return null;
  final question = _text(raw['question']);
  if (question == null) return null;
  final scale = raw['scale'] is num ? (raw['scale'] as num).toInt() : 5;
  final lowMax = raw['low_max'] is num ? (raw['low_max'] as num).toInt() : 2;
  return SupportSurvey(
    question: question,
    scale: scale == 3 ? 3 : 5,
    lowMax: lowMax.clamp(1, 4),
    reasons: [
      for (final row in _objects(raw['reasons']))
        if ((_text(row['code']), _text(row['label'])) case (final code?, final label?))
          SupportSurveyReason(code: code, label: label),
    ],
  );
}

List<SupportIntakeField> parseSupportIntake(Object? raw) => [
  for (final row in _objects(raw))
    if ((_text(row['key']), _intakeTypes[row['type']], _text(row['label'])) case (
      final key?,
      final type?,
      final label?,
    ))
      SupportIntakeField(
        key: key,
        type: type,
        label: label,
        isRequired: row['required'] == true,
        options: [
          for (final option in _objects(row['options']))
            if ((_text(option['value']), _text(option['label'])) case (final value?, final optionLabel?))
              SupportIntakeOption(value: value, label: optionLabel),
        ],
      ),
];

SupportTranscript parseSupportTranscript(Map<String, dynamic> raw) => SupportTranscript(
  ticket: SupportTicketModel.fromJson(raw['ticket']! as Map<String, dynamic>).toEntity(),
  messages: [
    for (final row in _objects(raw['messages']))
      if (_time(row['created_at']) case final createdAt?)
        SupportTranscriptMessage(
          createdAt: createdAt,
          sender: _senders[row['sender']] ?? SupportTranscriptSender.system,
          senderName: _text(row['sender_name']),
          body: row['body'] as String?,
          deleted: row['deleted'] == true,
          attachments: [for (final name in row['attachments'] as List<Object?>? ?? const <Object?>[]) ?_text(name)],
        ),
  ],
);
