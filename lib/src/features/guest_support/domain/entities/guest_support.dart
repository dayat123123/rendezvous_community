import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

part 'guest_support.freezed.dart';

const guestProblemCodes = ['password', 'pin', 'locked', 'other'];

@freezed
abstract class GuestLoginProblem with _$GuestLoginProblem {
  const factory GuestLoginProblem({required String code, required String label}) = _GuestLoginProblem;
}

@freezed
abstract class GuestSupportConfig with _$GuestSupportConfig {
  const factory GuestSupportConfig({
    @Default(false) bool enabled,
    @Default(24) int sessionHours,
    @Default(<GuestLoginProblem>[]) List<GuestLoginProblem> problems,
  }) = _GuestSupportConfig;
}

@freezed
abstract class GuestSupportToken with _$GuestSupportToken {
  const factory GuestSupportToken({required String token, required DateTime expiresAt}) = _GuestSupportToken;

  const GuestSupportToken._();

  bool validAt(DateTime now) => token.isNotEmpty && expiresAt.isAfter(now);

  @override
  String toString() => 'GuestSupportToken(expiresAt: $expiresAt)';
}

@freezed
abstract class GuestSupportSession with _$GuestSupportSession {
  const factory GuestSupportSession({required GuestSupportToken token, required SupportTicket ticket}) =
      _GuestSupportSession;
}

@freezed
abstract class GuestSupportSnapshot with _$GuestSupportSnapshot {
  const factory GuestSupportSnapshot({
    required DateTime expiresAt,
    required SupportTicket ticket,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
  }) = _GuestSupportSnapshot;
}
