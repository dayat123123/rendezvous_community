import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_account_scope.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/legal/domain/entities/legal_document.dart';
import 'package:rendezvous_community/src/features/legal/domain/services/consent_gate.dart';
import 'package:rendezvous_community/src/features/legal/presentation/cubit/consent_cubit.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_legal_document_reader.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<bool> showCommunityConsent(BuildContext context) {
  final account = CommunityAccountScope.maybeOf(context);
  if (account == null) return Future.value(false);
  return account.consent.prompt(() => _presentConsent(context, account));
}

ConsentGate? communityConsentGate(BuildContext context) {
  if (CommunityAccountScope.maybeOf(context) == null) return null;
  return ConsentGate(() async => context.mounted && await showCommunityConsent(context));
}

Future<bool> _presentConsent(BuildContext context, CommunityAccountDependencies account) async {
  if (!context.mounted) return false;
  final l10n = context.communityL10n;
  final carry = carryCommunityBuilders(context);
  Widget view(BuildContext routeContext, {required bool showTitle}) => carry(
    CommunityAccountScope(
      dependencies: account,
      child: CommunityConsentView(showTitle: showTitle, onDone: (accepted) => Navigator.pop(routeContext, accepted)),
    ),
  );
  final bool? accepted;
  if (CommunityBreakpoints.isWide(context)) {
    accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final style = CommunityStyle.of(dialogContext);
        return Dialog(
          backgroundColor: style.surface,
          shape: communityDialogShape(style),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85),
            child: view(dialogContext, showTitle: true),
          ),
        );
      },
    );
  } else {
    accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (pageContext) => Scaffold(
          appBar: AppBar(title: Text(l10n.consentTitle)),
          body: SafeArea(top: false, child: view(pageContext, showTitle: false)),
        ),
      ),
    );
  }
  return accepted ?? false;
}

class CommunityConsentView extends StatelessWidget {
  const CommunityConsentView({super.key, required this.onDone, this.showTitle = true});

  final ValueChanged<bool> onDone;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final account = CommunityAccountScope.of(context);
    return BlocProvider(
      create: (_) => ConsentCubit(account.consent)..load(),
      child: BlocConsumer<ConsentCubit, ConsentState>(
        listenWhen: (a, b) => !a.accepted && b.accepted,
        listener: (_, _) => onDone(true),
        builder: (context, state) => PopScope(
          canPop: !state.submitting,
          child: switch (state.status) {
            LoadStatus.initial || LoadStatus.loading => const CommunitySettingsLoading(
              area: CommunitySettingsArea.consent,
              fallback: Padding(padding: EdgeInsets.all(48), child: CommunityLoadingView()),
            ),
            LoadStatus.failure => _ConsentFailure(error: state.error!, onLater: () => onDone(false)),
            LoadStatus.ready => _ConsentContent(state: state, showTitle: showTitle, onLater: () => onDone(false)),
          },
        ),
      ),
    );
  }
}

class _ConsentFailure extends StatelessWidget {
  const _ConsentFailure({required this.error, required this.onLater});

  final Object error;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final retry = context.read<ConsentCubit>().load;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: CommunitySettingsError(
            area: CommunitySettingsArea.consent,
            error: error,
            onRetry: retry,
            fallback: CommunityErrorView(error: error, onRetry: retry),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(style.spacing.xl, 0, style.spacing.xl, style.spacing.lg),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
              onPressed: onLater,
              child: Text(context.communityL10n.consentLater),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentContent extends StatelessWidget {
  const _ConsentContent({required this.state, required this.showTitle, required this.onLater});

  final ConsentState state;
  final bool showTitle;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<ConsentCubit>();
    final error = state.actionError;
    final details = CommunityConsentDetails(
      documents: state.documents,
      title: showTitle ? l10n.consentTitle : null,
      intro: l10n.consentIntro,
      agreeLabel: l10n.consentAgree(l10n.legalTitles(state.documents)),
      agreed: state.agreed,
      submitting: state.submitting,
      canAccept: state.canAccept,
      acceptLabel: l10n.consentAccept,
      laterLabel: l10n.consentLater,
      error: error,
      errorMessage: error == null ? null : l10n.errorMessage(error),
      onAgreedChanged: state.submitting ? null : cubit.setAgreed,
      onAccept: state.canAccept ? cubit.accept : null,
      onLater: state.submitting ? null : onLater,
      onOpenDocument: (document) => showCommunityLegalDocument(context, document),
    );
    return buildSettingsPart((b) => b.consent, context, details, _ConsentBody(details: details));
  }
}

class _ConsentBody extends StatelessWidget {
  const _ConsentBody({required this.details});

  final CommunityConsentDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final title = d.title;
    final errorMessage = d.errorMessage;
    final onAgreedChanged = d.onAgreedChanged;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title, style: style.typography.title.copyWith(fontSize: 20)),
                SizedBox(height: spacing.sm),
              ],
              Text(d.intro, style: style.typography.body.copyWith(color: style.textSecondary)),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            addAutomaticKeepAlives: false,
            itemCount: d.documents.length,
            separatorBuilder: (_, _) => Divider(
              height: style.borderWidth,
              thickness: style.borderWidth,
              color: style.divider,
              indent: spacing.lg,
            ),
            itemBuilder: (context, i) {
              final document = d.documents[i];
              return CommunityLegalDocumentTile(
                document: document,
                placement: CommunityLegalDocumentPlacement.consent,
                onOpen: () => d.onOpenDocument(document),
              );
            },
          ),
        ),
        SizedBox(height: spacing.sm),
        CheckboxListTile(
          value: d.agreed,
          onChanged: onAgreedChanged == null ? null : (value) => onAgreedChanged(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg),
          activeColor: style.accent,
          checkColor: style.onAccent,
          title: Text(d.agreeLabel, style: style.typography.body.copyWith(fontSize: 14)),
        ),
        if (errorMessage != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xl),
            child: Text(
              errorMessage,
              style: style.typography.meta.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.xl, spacing.sm, spacing.xl, spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
                onPressed: d.onLater,
                child: Text(d.laterLabel),
              ),
              SizedBox(width: spacing.sm),
              FilledButton(
                style: style.primaryButtonStyle(),
                onPressed: d.onAccept,
                child: d.submitting
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
                      )
                    : Text(d.acceptLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityLegalDocumentTile extends StatelessWidget {
  const CommunityLegalDocumentTile({super.key, required this.document, required this.placement, required this.onOpen});

  final LegalDocument document;
  final CommunityLegalDocumentPlacement placement;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final consent = placement == CommunityLegalDocumentPlacement.consent;
    final summary = document.changeSummary;
    final details = CommunityLegalDocumentTileDetails(
      document: document,
      placement: placement,
      icon: legalDocumentIcon(document.kind),
      meta: l10n.legalMeta(document),
      changes: consent && summary != null ? '${l10n.legalChanges}: $summary' : null,
      actionLabel: consent ? l10n.consentRead : null,
      onOpen: onOpen,
    );
    return buildSettingsPart((b) => b.legalDocumentTile, context, details, _DefaultLegalDocumentTile(details: details));
  }
}

class _DefaultLegalDocumentTile extends StatelessWidget {
  const _DefaultLegalDocumentTile({required this.details});

  final CommunityLegalDocumentTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final d = details;
    final changes = d.changes;
    final actionLabel = d.actionLabel;
    final tile = ListTileTheme(
      data: communitySettingsTileTheme(style),
      child: ListTile(
        leading: CommunityToneIcon(icon: d.icon),
        title: Text(d.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d.meta),
            if (changes != null)
              Padding(
                padding: EdgeInsets.only(top: style.spacing.xxs),
                child: Text(
                  changes,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: style.typography.meta.copyWith(color: style.textPrimary),
                ),
              ),
          ],
        ),
        trailing: actionLabel == null
            ? Icon(Icons.chevron_right, color: style.textTertiary)
            : TextButton(
                style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                onPressed: d.onOpen,
                child: Text(actionLabel),
              ),
        onTap: d.onOpen,
      ),
    );
    if (d.placement == CommunityLegalDocumentPlacement.accountSettings) return tile;
    return Material(color: style.surface, child: tile);
  }
}

IconData legalDocumentIcon(LegalDocumentKind kind) => switch (kind) {
  LegalDocumentKind.terms => Icons.description_outlined,
  LegalDocumentKind.communityGuidelines => Icons.groups_outlined,
  LegalDocumentKind.privacy => Icons.privacy_tip_outlined,
  LegalDocumentKind.other => Icons.article_outlined,
};
