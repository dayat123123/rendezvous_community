import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_account_scope.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/account_settings_cubit.dart';
import 'package:rendezvous_community/src/features/account/presentation/export_saver.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/delete_account_dialog.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/widgets/community_appeals.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_banner.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_legal_document_reader.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/widgets/community_dm_policy_settings.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/widgets/community_notification_settings.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_section_header.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

Future<void> openCommunityAccountSettings(
  BuildContext context, {
  VoidCallback? onAccountDeleted,
  CommunityExportSaver? exportSaver,
}) {
  final account = CommunityAccountScope.of(context);
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  final title = context.communityL10n.accountSettingsTitle;
  final carry = carryCommunityBuilders(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (pageContext) => carry(
        _withFeatures(
          features,
          CommunityAccountScope(
            dependencies: account,
            child: Scaffold(
              appBar: AppBar(title: Text(title)),
              body: SafeArea(
                top: false,
                child: CommunityAccountSettings(
                  exportSaver: exportSaver,
                  onAccountDeleted: () {
                    Navigator.pop(pageContext);
                    onAccountDeleted?.call();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _withFeatures(CommunityFeatureDependencies? features, Widget child) =>
    features == null ? child : CommunityFeatureScope(dependencies: features, child: child);

class CommunityAccountSettings extends StatelessWidget {
  const CommunityAccountSettings({super.key, this.onAccountDeleted, this.exportSaver});

  final VoidCallback? onAccountDeleted;
  final CommunityExportSaver? exportSaver;

  @override
  Widget build(BuildContext context) {
    final account = CommunityAccountScope.of(context);
    return BlocProvider(
      create: (_) => AccountSettingsCubit(account)..load(),
      child: _AccountSettingsView(onAccountDeleted: onAccountDeleted, exportSaver: exportSaver),
    );
  }
}

class _AccountSettingsView extends StatelessWidget {
  const _AccountSettingsView({this.onAccountDeleted, this.exportSaver});

  final VoidCallback? onAccountDeleted;
  final CommunityExportSaver? exportSaver;

  Future<void> _export(BuildContext context) async {
    final cubit = context.read<AccountSettingsCubit>();
    final l10n = context.communityL10n;
    final export = await cubit.exportData();
    if (export == null || !context.mounted) return;
    try {
      final saved = await (exportSaver ?? saveCommunityDataExport)(context, export);
      if (saved && context.mounted) showCommunityMessage(context, l10n.accountExportSaved);
    } catch (e) {
      cubit.exportFailed(e);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<AccountSettingsCubit>();
    final l10n = context.communityL10n;
    final carry = carryCommunityBuilders(context);
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => carry(BlocProvider.value(value: cubit, child: const DeleteAccountDialog())),
    );
    if (deleted != true || !context.mounted) return;
    showCommunityMessage(context, l10n.accountDeleted);
    final callback = onAccountDeleted;
    if (callback != null) {
      callback();
    } else {
      await Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId && b.failedAction == AccountAction.export,
      listener: (context, state) {
        final error = state.actionError!;
        showCommunityMessage(
          context,
          mapError(error).kind == CommunityErrorKind.rateLimited ? l10n.accountExportLimit : l10n.errorMessage(error),
        );
      },
      builder: (context, state) {
        final cubit = context.read<AccountSettingsCubit>();
        final features = context.communityFeatures;
        final social = features == null || features.configService.current.socialEnabled;
        return ColoredBox(
          color: style.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
              child: ListTileTheme(
                data: communitySettingsTileTheme(style),
                child: ListView(
                  children: [
                    const CommunityConsentBanner(),
                    CommunitySectionHeader(title: l10n.accountLegalSection),
                    CommunitySettingsGroup(
                      children: switch (state.status) {
                        LoadStatus.initial || LoadStatus.loading => const [
                          CommunitySettingsLoading(area: CommunitySettingsArea.legalDocuments),
                        ],
                        LoadStatus.failure => [
                          CommunitySettingsError(
                            area: CommunitySettingsArea.legalDocuments,
                            error: state.error!,
                            onRetry: () => cubit.load(refresh: true),
                          ),
                        ],
                        LoadStatus.ready => [
                          for (final document in state.documents)
                            CommunityLegalDocumentTile(
                              document: document,
                              placement: CommunityLegalDocumentPlacement.accountSettings,
                              onOpen: () => showCommunityLegalDocument(context, document),
                            ),
                        ],
                      },
                    ),
                    if (features != null && social) ...[
                      CommunitySectionHeader(title: l10n.accountMessagesSection),
                      const CommunitySettingsGroup(children: [CommunityDmPolicySettings()]),
                    ],
                    if (features != null && social && context.communityFeature(CommunityFlags.notificationPrefs)) ...[
                      CommunitySectionHeader(title: l10n.notificationSettings),
                      const CommunitySettingsGroup(children: [CommunityNotificationSettings()]),
                    ],
                    if (features != null) ...[
                      CommunitySectionHeader(title: l10n.accountAppealsSection),
                      CommunitySettingsGroup(
                        children: [
                          _AccountTile(
                            details: CommunityAccountTileDetails(
                              kind: CommunityAccountTileKind.appeals,
                              icon: Icons.gavel_outlined,
                              title: l10n.myAppeals,
                              subtitle: l10n.accountAppealsHint,
                              onTap: () => openCommunityAppeals(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                    CommunitySectionHeader(title: l10n.accountDataSection),
                    CommunitySettingsGroup(
                      children: [
                        _AccountTile(
                          details: CommunityAccountTileDetails(
                            kind: CommunityAccountTileKind.exportData,
                            icon: Icons.download_outlined,
                            title: l10n.accountExport,
                            subtitle: l10n.accountExportHint,
                            busy: state.exporting,
                            onTap: !state.exporting && !state.deleting ? () => _export(context) : null,
                          ),
                        ),
                        _AccountTile(
                          details: CommunityAccountTileDetails(
                            kind: CommunityAccountTileKind.deleteAccount,
                            icon: Icons.delete_forever_outlined,
                            title: l10n.accountDelete,
                            subtitle: l10n.accountDeleteHint,
                            destructive: true,
                            busy: state.deleting,
                            onTap: !state.deleting ? () => _delete(context) : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.details});

  final CommunityAccountTileDetails details;

  @override
  Widget build(BuildContext context) =>
      buildSettingsPart((b) => b.accountTile, context, details, _DefaultAccountTile(details: details));
}

class _DefaultAccountTile extends StatelessWidget {
  const _DefaultAccountTile({required this.details});

  final CommunityAccountTileDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final d = details;
    final tone = d.destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: CommunityToneIcon(icon: d.icon, tone: tone),
      title: Text(d.title, style: tone == null ? null : TextStyle(color: tone)),
      subtitle: Text(d.subtitle),
      trailing: d.busy && d.kind == CommunityAccountTileKind.exportData
          ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: style.accent))
          : d.kind == CommunityAccountTileKind.appeals
          ? Icon(Icons.chevron_right, color: style.textTertiary)
          : null,
      enabled: d.enabled,
      onTap: d.onTap,
    );
  }
}
