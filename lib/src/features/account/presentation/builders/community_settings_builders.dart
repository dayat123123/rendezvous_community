import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunitySettingsBuilders {
  const CommunitySettingsBuilders({
    this.dmPolicy,
    this.notificationType,
    this.reportDialog,
    this.appealDialog,
    this.appealTile,
    this.loading,
    this.empty,
    this.error,
    this.consent,
    this.legalDocumentTile,
    this.legalReader,
    this.accountTile,
    this.deleteAccountDialog,
  });

  final CommunityPartBuilder<CommunityDmPolicyDetails>? dmPolicy;
  final CommunityPartBuilder<CommunityNotificationTypeDetails>? notificationType;
  final CommunityPartBuilder<CommunityReportDetails>? reportDialog;
  final CommunityPartBuilder<CommunityAppealDialogDetails>? appealDialog;
  final CommunityPartBuilder<CommunityAppealTileDetails>? appealTile;
  final CommunityPartBuilder<CommunitySettingsLoadingDetails>? loading;
  final CommunityPartBuilder<CommunitySettingsEmptyDetails>? empty;
  final CommunityPartBuilder<CommunitySettingsErrorDetails>? error;
  final CommunityPartBuilder<CommunityConsentDetails>? consent;
  final CommunityPartBuilder<CommunityLegalDocumentTileDetails>? legalDocumentTile;
  final CommunityPartBuilder<CommunityLegalReaderDetails>? legalReader;
  final CommunityPartBuilder<CommunityAccountTileDetails>? accountTile;
  final CommunityPartBuilder<CommunityDeleteAccountDetails>? deleteAccountDialog;

  static CommunitySettingsBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunitySettingsBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunitySettingsBuildersScope>();
    return scope?.builders ?? const CommunitySettingsBuilders();
  }

  CommunitySettingsBuilders merge(CommunitySettingsBuilders? other) {
    if (other == null) return this;
    return CommunitySettingsBuilders(
      dmPolicy: other.dmPolicy ?? dmPolicy,
      notificationType: other.notificationType ?? notificationType,
      reportDialog: other.reportDialog ?? reportDialog,
      appealDialog: other.appealDialog ?? appealDialog,
      appealTile: other.appealTile ?? appealTile,
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      consent: other.consent ?? consent,
      legalDocumentTile: other.legalDocumentTile ?? legalDocumentTile,
      legalReader: other.legalReader ?? legalReader,
      accountTile: other.accountTile ?? accountTile,
      deleteAccountDialog: other.deleteAccountDialog ?? deleteAccountDialog,
    );
  }
}

class CommunitySettingsBuildersScope extends InheritedWidget {
  const CommunitySettingsBuildersScope({super.key, required this.builders, required super.child});

  final CommunitySettingsBuilders builders;

  @override
  bool updateShouldNotify(CommunitySettingsBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildSettingsPart<T>(
  CommunityPartBuilder<T>? Function(CommunitySettingsBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunitySettingsBuilders.of(context)), context, details, fallback);
