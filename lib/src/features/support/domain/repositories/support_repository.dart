import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_transcript.dart';

abstract interface class SupportRepository {
  Future<SupportHome> home();

  Future<List<SupportTopic>> topics({String language = 'id'});

  Future<SupportTicket> openTicket({
    required String topic,
    String language = 'id',
    String? screen,
    bool complaint = false,
    Map<String, String>? intake,
  });

  Future<List<SupportTicket>> myTickets();

  Future<List<ChatMessage>> ticketMessages(String ticketId);

  Future<SupportTicket> closeTicket(String ticketId);

  Future<SupportTicket> rateTicket(String ticketId, int rating, {String? comment, List<String>? reasons});

  Future<List<SupportIncident>> serviceStatus({String language = 'id'});

  Future<SupportTranscript> transcript(String ticketId);

  Future<SupportTicket> requestComplaint();

  Future<SupportTicket> reportFakeCs(String description);

  Future<SensitiveCheck> checkSensitive(String text);

  Future<CommunityAttachmentPolicy> attachmentPolicy();

  Stream<void> watchTicket(String roomId);

  Stream<SupportNotice> notices();
}
