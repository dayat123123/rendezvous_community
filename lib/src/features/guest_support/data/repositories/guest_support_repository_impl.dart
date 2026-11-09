import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/anonymous_rpc.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/guest_support/data/models/guest_support_models.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/repositories/guest_support_repository.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';

class GuestSupportRepositoryImpl implements GuestSupportRepository {
  GuestSupportRepositoryImpl(this._rpc);

  final AnonymousRpcCall _rpc;

  static String _language(String language) => language == 'en' ? 'en' : 'id';

  @override
  Future<GuestSupportConfig> config({String language = 'id'}) async {
    try {
      return parseGuestConfig(await _rpc('guest_config', {'p_language': _language(language)}));
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202') rethrow;
      CommunityLoggers.support.info('Server has no guest support endpoint; guest complaints are unavailable');
      return const GuestSupportConfig();
    }
  }

  @override
  Future<GuestSupportSession> start({
    required String name,
    String? loginId,
    required String problem,
    required String description,
    String language = 'id',
  }) async {
    final session = parseGuestSession(
      await _rpc('guest_start', {
        'p_name': name.trim(),
        'p_login_id': normalizeGuestLoginId(loginId),
        'p_problem': problem,
        'p_description': description.trim(),
        'p_language': _language(language),
      }),
    );
    CommunityLoggers.support.event(
      Level.INFO,
      'Guest support ticket opened',
      fields: {
        'ticketId': session.ticket.id,
        'problem': problem,
        'hasLoginId': normalizeGuestLoginId(loginId) != null,
        'expiresAt': session.token.expiresAt,
      },
    );
    return session;
  }

  @override
  Future<GuestSupportSnapshot> poll(String token) async =>
      parseGuestSnapshot(await _rpc('guest_poll', {'p_token': token}));

  @override
  Future<ChatMessage> send(String token, {required String body, required String clientId}) async =>
      parseGuestMessage(await _rpc('guest_send', {'p_token': token, 'p_body': body.trim(), 'p_client_id': clientId}));

  @override
  Future<void> end(String token) async {
    await _rpc('guest_end', {'p_token': token});
    CommunityLoggers.support.info('Guest support session ended by the customer');
  }
}
