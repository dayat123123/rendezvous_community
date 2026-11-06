import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

class MessageRecipientInfo {
  const MessageRecipientInfo({
    required this.user,
    required this.delivered,
    required this.read,
    this.deliveredAt,
    this.readAt,
  });

  final UserSummary user;
  final bool delivered;
  final bool read;
  final DateTime? deliveredAt;
  final DateTime? readAt;
}

class MessageInfo {
  const MessageInfo({required this.messageId, required this.sentAt, this.recipients = const []});

  final String messageId;
  final DateTime sentAt;
  final List<MessageRecipientInfo> recipients;

  List<MessageRecipientInfo> get readBy => [
    for (final r in recipients)
      if (r.read) r,
  ];

  List<MessageRecipientInfo> get deliveredOnly => [
    for (final r in recipients)
      if (r.delivered && !r.read) r,
  ];

  int get pending => recipients.where((r) => !r.delivered).length;
}

MessageInfo messageInfoFromJson(Map<String, dynamic> json) {
  DateTime? time(Object? value) => value is String ? DateTime.tryParse(value) : null;
  return MessageInfo(
    messageId: json['message_id'] as String,
    sentAt: DateTime.parse(json['sent_at'] as String),
    recipients: [
      for (final row in (json['recipients'] as List? ?? const []).whereType<Map<String, dynamic>>())
        MessageRecipientInfo(
          user: UserSummary(
            id: row['user_id'] as String,
            username: row['username'] as String? ?? '',
            displayName: row['display_name'] as String?,
            avatarUrl: row['avatar_url'] as String?,
          ),
          delivered: row['delivered'] == true || row['read'] == true,
          read: row['read'] == true,
          deliveredAt: time(row['delivered_at']),
          readAt: time(row['read_at']),
        ),
    ],
  );
}
