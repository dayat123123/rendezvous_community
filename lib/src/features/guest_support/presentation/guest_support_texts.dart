import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

String guestFieldIssueText(CommunityLocalizations l10n, GuestSupportField field, GuestSupportFieldIssue issue) =>
    switch (field) {
      GuestSupportField.name =>
        issue == GuestSupportFieldIssue.required
            ? l10n.guestSupportNameRequired
            : l10n.guestSupportNameLength(guestNameMinLength, guestNameMaxLength),
      GuestSupportField.loginId => l10n.guestSupportLoginIdInvalid(guestLoginIdMaxLength),
      GuestSupportField.problem => l10n.guestSupportProblemRequired,
      GuestSupportField.description =>
        issue == GuestSupportFieldIssue.required
            ? l10n.guestSupportDescriptionRequired
            : l10n.guestSupportDescriptionLength(guestDescriptionMinLength, guestDescriptionMaxLength),
    };

GuestSupportField? guestErrorField(Object error) => switch (guestSupportErrorOf(error)) {
  GuestSupportError.invalidName => GuestSupportField.name,
  GuestSupportError.invalidLoginId => GuestSupportField.loginId,
  GuestSupportError.invalidProblem => GuestSupportField.problem,
  GuestSupportError.invalidDescription => GuestSupportField.description,
  _ => null,
};

String guestErrorText(CommunityLocalizations l10n, Object error, {bool sending = false}) =>
    switch (guestSupportErrorOf(error)) {
      GuestSupportError.disabled => l10n.guestSupportDisabled,
      GuestSupportError.loginLimit => l10n.guestErrorLoginLimit,
      GuestSupportError.rateLimited => sending ? l10n.guestErrorMessageRate : l10n.guestErrorRateLimited,
      GuestSupportError.invalidName => l10n.guestSupportNameLength(guestNameMinLength, guestNameMaxLength),
      GuestSupportError.invalidLoginId => l10n.guestSupportLoginIdInvalid(guestLoginIdMaxLength),
      GuestSupportError.invalidProblem => l10n.guestSupportProblemRequired,
      GuestSupportError.invalidDescription => l10n.guestSupportDescriptionLength(
        guestDescriptionMinLength,
        guestDescriptionMaxLength,
      ),
      GuestSupportError.invalidMessage => l10n.guestErrorInvalidMessage(guestMessageMaxLength),
      GuestSupportError.ticketNotActive => l10n.guestErrorTicketNotActive,
      GuestSupportError.sessionExpired => l10n.guestErrorSessionExpired,
      GuestSupportError.network || GuestSupportError.unknown => l10n.errorMessage(error),
    };

String guestEndedText(CommunityLocalizations l10n, GuestSupportEndReason reason, String? ticketNumber) {
  final number = ticketNumber ?? '';
  return switch (reason) {
    GuestSupportEndReason.resolved => l10n.guestSupportEndedResolved(number),
    GuestSupportEndReason.closed => l10n.guestSupportEndedClosed(number),
    GuestSupportEndReason.expired => l10n.guestSupportEndedExpired,
    GuestSupportEndReason.ended => l10n.guestSupportEndedByYou(number),
  };
}
