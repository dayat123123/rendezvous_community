import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_builders.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class TradeShareUnavailableView extends StatelessWidget {
  const TradeShareUnavailableView({super.key});

  @override
  Widget build(BuildContext context) {
    final details = CommunityTradeUnavailableDetails(
      message: context.communityL10n.tradeShareUnavailable,
      icon: CommunityStyle.of(context).icons.tradeShare,
    );
    return buildTradeSharePart(
      (b) => b.unavailable,
      context,
      details,
      CommunityEmptyView(message: details.message, icon: details.icon),
    );
  }
}

class TradeLoadingState extends StatelessWidget {
  const TradeLoadingState({super.key, required this.area});

  final CommunityTradeArea area;

  @override
  Widget build(BuildContext context) => buildTradeSharePart(
    (b) => b.loading,
    context,
    CommunityTradeLoadingDetails(area: area),
    const CommunityLoadingView(),
  );
}

class TradeErrorState extends StatelessWidget {
  const TradeErrorState({super.key, required this.area, required this.error, required this.onRetry});

  final CommunityTradeArea area;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => buildTradeSharePart(
    (b) => b.error,
    context,
    CommunityTradeErrorDetails(
      area: area,
      error: error,
      message: context.communityL10n.errorMessage(error),
      onRetry: onRetry,
    ),
    CommunityErrorView(error: error, onRetry: onRetry),
  );
}

class TradeEmptyState extends StatelessWidget {
  const TradeEmptyState({super.key, required this.area, required this.message, required this.icon});

  final CommunityTradeArea area;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => buildTradeSharePart(
    (b) => b.empty,
    context,
    CommunityTradeEmptyDetails(area: area, message: message, icon: icon),
    CommunityEmptyView(message: message, icon: icon),
  );
}

class TradeStatusPill extends StatelessWidget {
  const TradeStatusPill({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final Color tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final icon = this.icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(tone.withValues(alpha: 0.12), style.surface),
        borderRadius: style.radii.badgeRadius,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: tone), SizedBox(width: spacing.xxs)],
            Text(label, style: style.typography.badge.copyWith(color: tone)),
          ],
        ),
      ),
    );
  }
}

class TradeNotificationPreview extends StatelessWidget {
  const TradeNotificationPreview({super.key, required this.user, required this.title, required this.body});

  final UserSummary? user;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.surface,
          borderRadius: style.radii.cardRadius,
          border: Border.fromBorderSide(style.borderSide),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityAvatar(user: user, radius: 18),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      key: const ValueKey('trade-preview-title'),
                      style: style.typography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    if (body.isNotEmpty) ...[
                      SizedBox(height: spacing.xxs),
                      Text(body, key: const ValueKey('trade-preview-body'), style: style.typography.meta),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showTradeShareDocument(
  BuildContext context,
  TradeShareDocument document, {
  String? acceptLabel,
  String? confirmLabel,
}) async {
  final carry = carryCommunityBuilders(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) =>
        carry(_TradeDocumentDialog(document: document, acceptLabel: acceptLabel, confirmLabel: confirmLabel)),
  );
  return result ?? false;
}

class _TradeDocumentDialog extends StatefulWidget {
  const _TradeDocumentDialog({required this.document, this.acceptLabel, this.confirmLabel});

  final TradeShareDocument document;
  final String? acceptLabel;
  final String? confirmLabel;

  @override
  State<_TradeDocumentDialog> createState() => _TradeDocumentDialogState();
}

class _TradeDocumentDialogState extends State<_TradeDocumentDialog> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final acceptLabel = widget.acceptLabel;
    final confirmLabel = widget.confirmLabel;
    final document = widget.document;
    return AlertDialog(
      title: Text(document.title.isEmpty ? l10n.tradeShareTerms : document.title),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: SelectableText(document.body, style: style.typography.body.copyWith(height: 1.5)),
              ),
            ),
            if (acceptLabel != null)
              CheckboxListTile(
                key: const ValueKey('trade-document-accept'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: style.accent,
                value: _accepted,
                onChanged: (value) => setState(() => _accepted = value ?? false),
                title: Text(acceptLabel, style: style.typography.body.copyWith(fontSize: 14)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(confirmLabel == null ? l10n.close : l10n.cancel),
        ),
        if (confirmLabel != null)
          FilledButton(
            key: const ValueKey('trade-document-confirm'),
            onPressed: acceptLabel == null || _accepted ? () => Navigator.pop(context, true) : null,
            child: Text(confirmLabel),
          ),
      ],
    );
  }
}
