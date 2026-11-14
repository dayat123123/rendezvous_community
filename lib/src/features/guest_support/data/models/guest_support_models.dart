import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';
import 'package:rendezvous_community/src/features/support/data/models/support_models.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

Map<String, dynamic> _object(Object? raw, String what) {
  if (raw is Map<String, dynamic>) return raw;
  throw CommunityException(CommunityErrorKind.unknown, message: 'Guest support $what response was not an object');
}

DateTime _time(Object? raw, String what) {
  final time = raw is String ? DateTime.tryParse(raw) : null;
  if (time == null) {
    throw CommunityException(CommunityErrorKind.unknown, message: 'Guest support $what has no valid expiry');
  }
  return time;
}

SupportTicket parseGuestTicket(Object? raw) => SupportTicketModel.fromJson(_object(raw, 'ticket')).toEntity();

GuestSupportConfig parseGuestConfig(Object? raw) {
  final json = _object(raw, 'config');
  final hours = json['session_hours'];
  return GuestSupportConfig(
    enabled: json['enabled'] == true,
    sessionHours: hours is num && hours > 0 ? hours.toInt() : 24,
    problems: [
      for (final row in json['problems'] as List<Object?>? ?? const <Object?>[])
        if (row is Map<String, dynamic>)
          if ((row['code'], row['label']) case (
            final String code,
            final String label,
          ) when code.trim().isNotEmpty && label.trim().isNotEmpty)
            GuestLoginProblem(code: code.trim(), label: label.trim()),
    ],
  );
}

GuestSupportSession parseGuestSession(Object? raw) {
  final json = _object(raw, 'start');
  final token = json['token'];
  if (token is! String || token.isEmpty) {
    throw const CommunityException(CommunityErrorKind.unknown, message: 'Guest support start returned no token');
  }
  return GuestSupportSession(
    token: GuestSupportToken(token: token, expiresAt: _time(json['expires_at'], 'session')),
    ticket: parseGuestTicket(json['ticket']),
  );
}

SupportTicket? parseGuestEnd(Object? raw) => switch (raw) {
  {'ticket': final Map<String, dynamic> ticket} => parseGuestTicket(ticket),
  _ => null,
};

ChatMessage parseGuestMessage(Object? raw) => ChatMessageModel.fromJson(_object(raw, 'message')).toEntity();

GuestSupportSnapshot parseGuestSnapshot(Object? raw) {
  final json = _object(raw, 'poll');
  final messages = [
    for (final row in json['messages'] as List<Object?>? ?? const <Object?>[])
      if (row is Map<String, dynamic>) parseGuestMessage(row),
  ];
  return GuestSupportSnapshot(
    expiresAt: _time(json['expires_at'], 'poll'),
    ticket: parseGuestTicket(json['ticket']),
    messages: messages,
  );
}
