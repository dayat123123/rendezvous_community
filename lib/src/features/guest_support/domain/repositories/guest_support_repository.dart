import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

abstract interface class GuestSupportRepository {
  Future<GuestSupportConfig> config({String language = 'id'});

  Future<GuestSupportSession> start({
    required String name,
    String? loginId,
    required String problem,
    required String description,
    String language = 'id',
  });

  Future<GuestSupportSnapshot> poll(String token);

  Future<ChatMessage> send(String token, {required String body, required String clientId});

  Future<SupportTicket?> end(String token);
}
