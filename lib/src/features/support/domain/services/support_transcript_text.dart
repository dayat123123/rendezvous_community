import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_transcript.dart';

class SupportTranscriptLabels {
  const SupportTranscriptLabels({
    required this.title,
    required this.ticket,
    required this.topic,
    required this.created,
    required this.resolved,
    required this.closed,
    required this.customer,
    required this.agent,
    required this.system,
    required this.deleted,
    required this.attachments,
    required this.empty,
  });

  final String title;
  final String ticket;
  final String topic;
  final String created;
  final String resolved;
  final String closed;
  final String customer;
  final String agent;
  final String system;
  final String deleted;
  final String attachments;
  final String empty;
}

class SupportTranscriptFile {
  const SupportTranscriptFile({required this.name, required this.text});

  static const mimeType = 'text/plain';

  final String name;
  final String text;
}

DateTime _local(DateTime value) => value.toLocal();

String supportTranscriptFileName(SupportTranscript transcript, {String prefix = 'transkrip'}) {
  final number = transcript.ticket.ticketNumber.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  return '$prefix-$number.txt';
}

String formatSupportTranscript(
  SupportTranscript transcript,
  SupportTranscriptLabels labels, {
  DateTime Function(DateTime value) toLocal = _local,
}) {
  final time = DateFormat('yyyy-MM-dd HH:mm', 'en_US');
  String stamp(DateTime value) => time.format(toLocal(value));
  final ticket = transcript.ticket;
  final resolvedAt = ticket.resolvedAt;
  final closedAt = ticket.closedAt;
  final lines = <String>[
    labels.title,
    '${labels.ticket}: ${ticket.ticketNumber}',
    '${labels.topic}: ${ticket.topicName ?? ticket.topic}',
    '${labels.created}: ${stamp(ticket.createdAt)}',
    if (resolvedAt != null) '${labels.resolved}: ${stamp(resolvedAt)}',
    if (closedAt != null) '${labels.closed}: ${stamp(closedAt)}',
    '',
  ];
  if (transcript.messages.isEmpty) lines.add(labels.empty);
  for (final message in transcript.messages) {
    final name = message.senderName?.trim();
    final sender = switch (message.sender) {
      SupportTranscriptSender.customer => labels.customer,
      SupportTranscriptSender.agent => name == null || name.isEmpty ? labels.agent : '$name (${labels.agent})',
      SupportTranscriptSender.system => labels.system,
    };
    final body = message.deleted ? labels.deleted : (message.body ?? '').trim();
    final bodyLines = body.isEmpty ? const <String>[] : body.split(RegExp(r'\r?\n'));
    lines.add('[${stamp(message.createdAt)}] $sender:${bodyLines.isEmpty ? '' : ' ${bodyLines.first}'}');
    for (final line in bodyLines.skip(1)) {
      lines.add('    $line');
    }
    if (message.attachments.isNotEmpty) lines.add('    ${labels.attachments}: ${message.attachments.join(', ')}');
  }
  return '${lines.join('\n')}\n';
}
