import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';

const guestNameMinLength = 2;
const guestNameMaxLength = 60;
const guestLoginIdMaxLength = 50;
const guestDescriptionMinLength = 10;
const guestDescriptionMaxLength = 1000;
const guestMessageMaxLength = 2000;

final _loginIdPattern = RegExp(r'^[A-Z0-9._@-]{1,50}$');

enum GuestSupportField { name, loginId, problem, description }

enum GuestSupportFieldIssue { required, tooShort, tooLong, invalid }

enum GuestSupportError {
  disabled,
  loginLimit,
  invalidName,
  invalidLoginId,
  invalidProblem,
  invalidDescription,
  invalidMessage,
  ticketNotActive,
  sessionExpired,
  rateLimited,
  network,
  unknown,
}

int _length(String value) => value.runes.length;

String? normalizeGuestLoginId(String? raw) {
  final value = raw?.trim().toUpperCase() ?? '';
  return value.isEmpty ? null : value;
}

bool isGuestLoginId(String value) => _loginIdPattern.hasMatch(value);

Map<GuestSupportField, GuestSupportFieldIssue> validateGuestSupportForm({
  required String name,
  String? loginId,
  String? problem,
  required String description,
  Iterable<String> problems = guestProblemCodes,
}) {
  final issues = <GuestSupportField, GuestSupportFieldIssue>{};
  final cleanName = name.trim();
  if (cleanName.isEmpty) {
    issues[GuestSupportField.name] = GuestSupportFieldIssue.required;
  } else if (_length(cleanName) < guestNameMinLength) {
    issues[GuestSupportField.name] = GuestSupportFieldIssue.tooShort;
  } else if (_length(cleanName) > guestNameMaxLength) {
    issues[GuestSupportField.name] = GuestSupportFieldIssue.tooLong;
  }
  final cleanLogin = normalizeGuestLoginId(loginId);
  if (cleanLogin != null) {
    if (_length(cleanLogin) > guestLoginIdMaxLength) {
      issues[GuestSupportField.loginId] = GuestSupportFieldIssue.tooLong;
    } else if (!isGuestLoginId(cleanLogin)) {
      issues[GuestSupportField.loginId] = GuestSupportFieldIssue.invalid;
    }
  }
  if (problem == null || problem.isEmpty) {
    issues[GuestSupportField.problem] = GuestSupportFieldIssue.required;
  } else if (!guestProblemCodes.contains(problem) || !problems.contains(problem)) {
    issues[GuestSupportField.problem] = GuestSupportFieldIssue.invalid;
  }
  final cleanDescription = description.trim();
  if (cleanDescription.isEmpty) {
    issues[GuestSupportField.description] = GuestSupportFieldIssue.required;
  } else if (_length(cleanDescription) < guestDescriptionMinLength) {
    issues[GuestSupportField.description] = GuestSupportFieldIssue.tooShort;
  } else if (_length(cleanDescription) > guestDescriptionMaxLength) {
    issues[GuestSupportField.description] = GuestSupportFieldIssue.tooLong;
  }
  return issues;
}

bool isGuestMessageValid(String body) {
  final length = _length(body.trim());
  return length >= 1 && length <= guestMessageMaxLength;
}

GuestSupportError guestSupportErrorOf(Object error) {
  final mapped = mapError(error);
  return switch (mapped.code) {
    'guest_disabled' => GuestSupportError.disabled,
    'guest_login_limit' => GuestSupportError.loginLimit,
    'invalid_name' => GuestSupportError.invalidName,
    'invalid_login_id' => GuestSupportError.invalidLoginId,
    'invalid_problem' => GuestSupportError.invalidProblem,
    'invalid_description' => GuestSupportError.invalidDescription,
    'invalid_body' => GuestSupportError.invalidMessage,
    'ticket_not_active' => GuestSupportError.ticketNotActive,
    'guest_session_expired' => GuestSupportError.sessionExpired,
    _ => switch (mapped.kind) {
      CommunityErrorKind.rateLimited => GuestSupportError.rateLimited,
      CommunityErrorKind.unauthenticated => GuestSupportError.sessionExpired,
      CommunityErrorKind.network => GuestSupportError.network,
      _ => GuestSupportError.unknown,
    },
  };
}
