import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/realtime_gateway.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';
import 'package:rendezvous_community/src/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rendezvous_community/src/features/support/data/models/support_models.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_transcript.dart';
import 'package:rendezvous_community/src/features/support/domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({required this._cs, this._realtime, required this._notifications});

  final SocialRemoteDataSource _cs;
  final RealtimeGateway? _realtime;
  final NotificationRepository _notifications;

  SupportTicket _ticket(Object? json) => SupportTicketModel.fromJson(json! as Map<String, dynamic>).toEntity();

  @override
  Future<SupportHome> home() async =>
      SupportHomeModel.fromJson((await _cs.rpcValue('support_home'))! as Map<String, dynamic>).toEntity();

  @override
  Future<List<SupportTopic>> topics({String language = 'id'}) async {
    final rows = (await _cs.rpcValue('topics', {'p_language': language})) as List<Object?>? ?? const [];
    return [
      for (final row in rows.cast<Map<String, dynamic>>())
        SupportTopic(
          code: row['code'] as String,
          name: row['name'] as String,
          helpUrl: row['help_url'] as String?,
          urgent: row['urgent'] == true,
          description: row['description'] as String?,
          icon: row['icon'] as String?,
          style: row['style'] as String? ?? 'normal',
          intake: parseSupportIntake(row['intake']),
        ),
    ];
  }

  @override
  Future<SupportTicket> openTicket({
    required String topic,
    String language = 'id',
    String? screen,
    bool complaint = false,
    Map<String, String>? intake,
  }) async {
    final answers = intake == null || intake.isEmpty ? null : intake;
    final ticket = _ticket(
      await _cs.rpcValue('open_ticket', {
        'p_topic': topic,
        'p_language': language,
        'p_screen': screen,
        'p_complaint': complaint,
        'p_intake': ?answers,
      }),
    );
    CommunityLoggers.support.event(
      Level.INFO,
      'Support ticket opened',
      fields: {'ticketId': ticket.id, 'topic': topic, 'status': ticket.status, 'intakeAnswers': answers?.length ?? 0},
    );
    return ticket;
  }

  @override
  Future<List<SupportTicket>> myTickets() async {
    final rows = (await _cs.rpcValue('my_tickets')) as List<Object?>? ?? const [];
    return [for (final row in rows) _ticket(row)];
  }

  @override
  Future<List<ChatMessage>> ticketMessages(String ticketId) async {
    final rows = await _cs.rpcRows('ticket_messages', {'p_ticket_id': ticketId});
    return [for (final row in rows) ChatMessageModel.fromJson(row).toEntity()];
  }

  @override
  Future<SupportTicket> closeTicket(String ticketId) async =>
      _ticket(await _cs.rpcValue('close_ticket', {'p_ticket_id': ticketId}));

  @override
  Future<SupportTicket> rateTicket(String ticketId, int rating, {String? comment, List<String>? reasons}) async {
    final codes = reasons == null || reasons.isEmpty ? null : reasons.toSet().toList();
    return _ticket(
      await _cs.rpcValue('rate_ticket', {
        'p_ticket_id': ticketId,
        'p_rating': rating,
        'p_comment': comment,
        'p_reasons': ?codes,
      }),
    );
  }

  @override
  Future<List<SupportIncident>> serviceStatus({String language = 'id'}) async {
    try {
      final value = await _cs.rpcValue('service_status', {'p_language': language == 'en' ? 'en' : 'id'});
      return parseSupportIncidents(value is Map<String, dynamic> ? value['incidents'] : null);
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202' && e.kind != CommunityErrorKind.notFound) rethrow;
      CommunityLoggers.support.info('Server has no service status endpoint; showing no incidents');
      return const [];
    }
  }

  @override
  Future<SupportTranscript> transcript(String ticketId) async {
    final transcript = parseSupportTranscript(
      (await _cs.rpcValue('ticket_transcript', {'p_ticket_id': ticketId}))! as Map<String, dynamic>,
    );
    CommunityLoggers.support.event(
      Level.INFO,
      'Support transcript loaded',
      fields: {'ticketId': ticketId, 'messages': transcript.messages.length},
    );
    return transcript;
  }

  @override
  Future<SupportTicket> requestComplaint() async => _ticket(await _cs.rpcValue('request_complaint'));

  @override
  Future<SupportTicket> reportFakeCs(String description) async =>
      _ticket(await _cs.rpcValue('report_fake_cs', {'p_description': description}));

  @override
  Future<SensitiveCheck> checkSensitive(String text) async {
    final result = (await _cs.rpcValue('check_sensitive', {'p_text': text}))! as Map<String, dynamic>;
    return SensitiveCheck(
      masked: result['masked'] == true || result['requests_secret'] == true,
      kinds: [for (final k in result['kinds'] as List<Object?>? ?? const []) '$k'],
    );
  }

  @override
  Future<CommunityAttachmentPolicy> attachmentPolicy() async {
    try {
      final value = await _cs.rpcValue('attachment_policy');
      if (value is Map<String, dynamic>) return CommunityAttachmentPolicy.fromJson(value);
      CommunityLoggers.support.warning('Attachment policy response was not an object; using the legacy policy');
      return CommunityAttachmentPolicy.legacy;
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202' && e.kind != CommunityErrorKind.notFound) rethrow;
      CommunityLoggers.support.info('Server has no attachment policy endpoint; using the legacy policy');
      return CommunityAttachmentPolicy.legacy;
    }
  }

  @override
  Stream<void> watchTicket(String roomId) {
    final realtime = _realtime;
    if (realtime == null) return const Stream.empty();
    return Stream.multi((multi) {
      final channel = realtime.privateChannel('cs:room:$roomId');
      channel
        ..onBroadcast(event: 'ticket', callback: (_) => multi.add(null))
        ..subscribe();
      multi.onCancel = () => realtime.remove(channel);
    });
  }

  @override
  Stream<SupportNotice> notices() => Stream.multi((multi) {
    final seen = <String>{};
    var primed = false;
    Future<void> poll() async {
      try {
        final page = await _notifications.getNotifications(limit: 10);
        for (final n in page.items.reversed) {
          if (!seen.add('${n.id}:${n.createdAt.microsecondsSinceEpoch}')) continue;
          if (!primed || n.payload['room_type'] != 'support' || n.isRead) continue;
          multi.add(_notice(n));
        }
        primed = true;
      } catch (_) {}
    }

    unawaited(poll());
    final subscription = _notifications.watchNotifications().listen((_) => poll());
    multi.onCancel = subscription.cancel;
  });

  SupportNotice _notice(AppNotification n) => SupportNotice(
    id: n.id,
    title: n.actor?.name ?? (n.payload['room_name'] as String? ?? ''),
    body: n.snippet ?? '',
    ticketId: n.payload['ticket_id'] as String?,
    roomId: n.roomId,
  );
}
