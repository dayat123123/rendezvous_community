import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_account_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_legal_document_reader.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class CommunityConsentBanner extends StatelessWidget {
  const CommunityConsentBanner({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final consent = CommunityAccountScope.maybeOf(context)?.consent;
    if (consent == null) return const SizedBox.shrink();
    consent.ensureLoaded();
    return ListenableBuilder(
      listenable: consent,
      builder: (context, _) {
        final documents = consent.bannerDocuments;
        if (documents.isEmpty) return const SizedBox.shrink();
        final l10n = context.communityL10n;
        final titles = l10n.legalTitles(documents);
        final details = CommunityConsentBannerDetails(
          documents: documents,
          message: documents.every((d) => d.isUpdate)
              ? l10n.consentBannerUpdated(titles)
              : l10n.consentBannerRequired(titles),
          reviewLabel: l10n.consentReview,
          dismissLabel: l10n.close,
          margin: margin,
          onReview: () async {
            final accepted = await showCommunityConsent(context);
            if (accepted && context.mounted) showCommunityMessage(context, l10n.consentAccepted);
          },
          onDismiss: consent.dismissBanner,
        );
        return buildSystemPart((b) => b.consentBanner, context, details, _DefaultConsentBanner(details: details));
      },
    );
  }
}

class _DefaultConsentBanner extends StatelessWidget {
  const _DefaultConsentBanner({required this.details});

  final CommunityConsentBannerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    return Padding(
      padding: d.margin,
      child: Material(
        color: Color.alphaBlend(style.accent.withValues(alpha: 0.05), style.surface),
        shape: Border(
          bottom: BorderSide(color: style.divider, width: style.borderWidth),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.xs, spacing.sm),
          child: Row(
            children: [
              const CommunityToneIcon(icon: Icons.policy_outlined, size: 32),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(d.message, style: style.typography.meta.copyWith(color: style.textPrimary)),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                onPressed: d.onReview,
                child: Text(d.reviewLabel),
              ),
              IconButton(
                tooltip: d.dismissLabel,
                onPressed: d.onDismiss,
                icon: Icon(Icons.close, size: 20, color: style.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
