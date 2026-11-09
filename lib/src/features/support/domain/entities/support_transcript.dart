import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

part 'support_transcript.freezed.dart';

enum SupportTranscriptSender { customer, agent, system }

@freezed
abstract class SupportTranscriptMessage with _$SupportTranscriptMessage {
  const factory SupportTranscriptMessage({
    required DateTime createdAt,
    required SupportTranscriptSender sender,
    String? senderName,
    String? body,
    @Default(false) bool deleted,
    @Default(<String>[]) List<String> attachments,
  }) = _SupportTranscriptMessage;
}

@freezed
abstract class SupportTranscript with _$SupportTranscript {
  const factory SupportTranscript({
    required SupportTicket ticket,
    @Default(<SupportTranscriptMessage>[]) List<SupportTranscriptMessage> messages,
  }) = _SupportTranscript;
}
