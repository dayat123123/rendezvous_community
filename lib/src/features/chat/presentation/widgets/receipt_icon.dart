import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';

class ReceiptIcon extends StatelessWidget {
  const ReceiptIcon({
    super.key,
    required this.receipt,
    required this.color,
    this.sendStatus = MessageStatus.sent,
    this.size = 16,
    this.readColor,
  });

  final ReceiptStatus? receipt;
  final MessageStatus sendStatus;
  final Color color;
  final double size;
  final Color? readColor;

  @override
  Widget build(BuildContext context) {
    final builder = CommunityChatBuilders.of(context).receipt;
    final fallback = _DefaultReceipt(
      receipt: receipt,
      sendStatus: sendStatus,
      color: color,
      size: size,
      readColor: readColor,
    );
    if (builder == null) return fallback;
    final l10n = context.communityL10n;
    final label = switch (sendStatus) {
      MessageStatus.sending => l10n.messageSending,
      MessageStatus.pending => l10n.messagePending,
      MessageStatus.failed => l10n.messageFailed,
      MessageStatus.sent => switch (receipt) {
        null => null,
        ReceiptStatus.sent => l10n.messageSent,
        ReceiptStatus.delivered => l10n.messageDelivered,
        ReceiptStatus.read => l10n.messageRead,
      },
    };
    final details = CommunityReceiptDetails(
      receipt: receipt,
      sendStatus: sendStatus,
      color: color,
      size: size,
      semanticLabel: label,
      readColor: readColor,
    );
    return builder(context, details, fallback);
  }
}

class _DefaultReceipt extends StatelessWidget {
  const _DefaultReceipt({
    required this.receipt,
    required this.sendStatus,
    required this.color,
    required this.size,
    this.readColor,
  });

  final ReceiptStatus? receipt;
  final MessageStatus sendStatus;
  final Color color;
  final double size;
  final Color? readColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return switch (sendStatus) {
      MessageStatus.sending => Icon(Icons.schedule, size: size - 2, color: color, semanticLabel: l10n.messageSending),
      MessageStatus.pending => Icon(
        Icons.cloud_upload_outlined,
        size: size - 2,
        color: color,
        semanticLabel: l10n.messagePending,
      ),
      MessageStatus.failed => Icon(
        Icons.error_outline,
        size: size - 2,
        color: Theme.of(context).colorScheme.error,
        semanticLabel: l10n.messageFailed,
      ),
      MessageStatus.sent => switch (receipt) {
        null => const SizedBox.shrink(),
        ReceiptStatus.sent => Icon(Icons.done, size: size, color: color, semanticLabel: l10n.messageSent),
        ReceiptStatus.delivered => Icon(Icons.done_all, size: size, color: color, semanticLabel: l10n.messageDelivered),
        ReceiptStatus.read => Icon(
          Icons.done_all,
          size: size,
          color: readColor ?? CommunityTheme.of(context).readReceipt,
          semanticLabel: l10n.messageRead,
        ),
      },
    };
  }
}
