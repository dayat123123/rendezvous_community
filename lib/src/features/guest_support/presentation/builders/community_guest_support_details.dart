import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

class CommunityGuestSecurityNoteDetails {
  const CommunityGuestSecurityNoteDetails({required this.title, required this.message, this.compact = false});

  final String title;
  final String message;
  final bool compact;
}

class CommunityGuestFormDetails {
  const CommunityGuestFormDetails({
    required this.title,
    required this.hint,
    required this.securityNote,
    required this.nameController,
    required this.loginIdController,
    required this.descriptionController,
    required this.nameLabel,
    required this.loginIdLabel,
    required this.loginIdHint,
    required this.optionalLabel,
    required this.problemLabel,
    required this.descriptionLabel,
    required this.descriptionHint,
    required this.problems,
    required this.onSelectProblem,
    required this.submitLabel,
    required this.onSubmit,
    this.selectedProblem,
    this.errors = const {},
    this.busy = false,
    this.nameMaxLength = guestNameMaxLength,
    this.loginIdMaxLength = guestLoginIdMaxLength,
    this.descriptionMaxLength = guestDescriptionMaxLength,
  });

  final String title;
  final String hint;
  final Widget securityNote;
  final TextEditingController nameController;
  final TextEditingController loginIdController;
  final TextEditingController descriptionController;
  final String nameLabel;
  final String loginIdLabel;
  final String loginIdHint;
  final String optionalLabel;
  final String problemLabel;
  final String descriptionLabel;
  final String descriptionHint;
  final List<GuestLoginProblem> problems;
  final ValueChanged<String> onSelectProblem;
  final String submitLabel;
  final VoidCallback onSubmit;
  final String? selectedProblem;
  final Map<GuestSupportField, String> errors;
  final bool busy;
  final int nameMaxLength;
  final int loginIdMaxLength;
  final int descriptionMaxLength;

  String? errorFor(GuestSupportField field) => errors[field];
}

class CommunityGuestHeaderDetails {
  const CommunityGuestHeaderDetails({
    required this.title,
    required this.subtitle,
    required this.endLabel,
    this.ticket,
    this.statusLabel,
    this.sessionNote,
    this.onEnd,
    this.busy = false,
    this.reconnectingLabel,
  });

  final String title;
  final String subtitle;
  final String endLabel;
  final SupportTicket? ticket;
  final String? statusLabel;
  final String? sessionNote;
  final VoidCallback? onEnd;
  final bool busy;
  final String? reconnectingLabel;

  SupportStatus? get status => ticket?.status;

  String? get ticketNumber => ticket?.ticketNumber;

  bool get reconnecting => reconnectingLabel != null;
}
