import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

void showCommunityError(BuildContext context, Object error) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.communityL10n.errorMessage(error))));
}

void showCommunityMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmCommunityAction(BuildContext context, String message, {String? confirmLabel}) async {
  final l10n = context.communityL10n;
  final builder = CommunitySharedBuilders.of(context, listen: false).confirmDialog;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final details = CommunityConfirmDetails(
        message: message,
        confirmLabel: confirmLabel ?? l10n.delete,
        cancelLabel: l10n.cancel,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      );
      final fallback = AlertDialog(
        content: Text(details.message),
        actions: [
          TextButton(onPressed: details.onCancel, child: Text(details.cancelLabel)),
          FilledButton(onPressed: details.onConfirm, child: Text(details.confirmLabel)),
        ],
      );
      return builder == null ? fallback : builder(context, details, fallback);
    },
  );
  return ok ?? false;
}
