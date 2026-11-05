import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/appeals/domain/entities/appeal.dart';
import 'package:rendezvous_community/src/features/legal/domain/entities/legal_document.dart';
import 'package:rendezvous_community/src/features/message_requests/domain/entities/message_request.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/notification_preferences.dart';

class CommunitySettingsOption<T> {
  const CommunitySettingsOption({required this.value, required this.label, this.hint});

  final T value;
  final String label;
  final String? hint;
}

enum CommunitySettingsArea {
  appeals,
  sanctions,
  moderatedContent,
  myAppeals,
  legalDocuments,
  consent,
  dmPolicy,
  notificationPreferences,
}

class CommunitySettingsLoadingDetails {
  const CommunitySettingsLoadingDetails(this.area);

  final CommunitySettingsArea area;
}

class CommunitySettingsEmptyDetails {
  const CommunitySettingsEmptyDetails({required this.area, required this.message});

  final CommunitySettingsArea area;
  final String message;
}

class CommunitySettingsErrorDetails {
  const CommunitySettingsErrorDetails({
    required this.area,
    required this.error,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final CommunitySettingsArea area;
  final Object error;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
}

class CommunityDmPolicyDetails {
  const CommunityDmPolicyDetails({
    required this.policy,
    required this.title,
    required this.options,
    required this.saving,
    this.onChanged,
  });

  final DmPolicy policy;
  final String title;
  final List<CommunitySettingsOption<DmPolicy>> options;
  final bool saving;
  final ValueChanged<DmPolicy>? onChanged;
}

class CommunityNotificationTypeDetails {
  const CommunityNotificationTypeDetails({
    required this.preference,
    required this.label,
    required this.inAppLabel,
    required this.pushLabel,
    required this.onPushChanged,
    this.description,
    this.onInAppChanged,
  });

  final NotificationTypePreference preference;
  final String label;
  final String? description;
  final String inAppLabel;
  final String pushLabel;
  final ValueChanged<bool>? onInAppChanged;
  final ValueChanged<bool> onPushChanged;

  String get type => preference.type;

  bool get supportsInApp => preference.supportsInApp;

  bool get inApp => preference.inApp ?? true;

  bool get push => preference.push;

  bool get locked => preference.inAppLocked;

  bool get isOlt => preference.isOlt;
}

class CommunityReportDetails {
  const CommunityReportDetails({
    required this.target,
    required this.targetId,
    required this.title,
    required this.options,
    required this.selected,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.submitting,
    required this.submitLabel,
    required this.cancelLabel,
    this.error,
    this.errorMessage,
    this.onSelect,
    this.onSubmit,
    this.onCancel,
  });

  final ReportTarget target;
  final String targetId;
  final String title;
  final List<CommunitySettingsOption<ReportReason>> options;
  final ReportReason selected;
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool submitting;
  final String submitLabel;
  final String cancelLabel;
  final Object? error;
  final String? errorMessage;
  final ValueChanged<ReportReason>? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
}

class CommunityAppealDialogDetails {
  const CommunityAppealDialogDetails({
    required this.targetType,
    required this.title,
    required this.hint,
    required this.controller,
    required this.maxLength,
    required this.canSubmit,
    required this.submitting,
    required this.submitLabel,
    required this.cancelLabel,
    this.error,
    this.errorMessage,
    this.onSubmit,
    this.onCancel,
  });

  final AppealTargetType targetType;
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final bool canSubmit;
  final bool submitting;
  final String submitLabel;
  final String cancelLabel;
  final Object? error;
  final String? errorMessage;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
}

enum CommunityAppealTileKind { sanction, moderatedContent, appeal }

class CommunityAppealTileDetails {
  const CommunityAppealTileDetails({
    required this.kind,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.appealLabel,
    this.sanction,
    this.moderated,
    this.appeal,
    this.status,
    this.onAppeal,
  });

  final CommunityAppealTileKind kind;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String appealLabel;
  final Sanction? sanction;
  final ModeratedContent? moderated;
  final Appeal? appeal;
  final AppealStatus? status;
  final VoidCallback? onAppeal;
}

enum CommunityLegalDocumentPlacement { consent, accountSettings }

class CommunityLegalDocumentTileDetails {
  const CommunityLegalDocumentTileDetails({
    required this.document,
    required this.placement,
    required this.icon,
    required this.meta,
    required this.onOpen,
    this.changes,
    this.actionLabel,
  });

  final LegalDocument document;
  final CommunityLegalDocumentPlacement placement;
  final IconData icon;
  final String meta;
  final String? changes;
  final String? actionLabel;
  final VoidCallback onOpen;

  String get title => document.title;
}

class CommunityConsentDetails {
  const CommunityConsentDetails({
    required this.documents,
    required this.intro,
    required this.agreeLabel,
    required this.agreed,
    required this.submitting,
    required this.canAccept,
    required this.acceptLabel,
    required this.laterLabel,
    required this.onOpenDocument,
    this.title,
    this.error,
    this.errorMessage,
    this.onAgreedChanged,
    this.onAccept,
    this.onLater,
  });

  final List<LegalDocument> documents;
  final String? title;
  final String intro;
  final String agreeLabel;
  final bool agreed;
  final bool submitting;
  final bool canAccept;
  final String acceptLabel;
  final String laterLabel;
  final Object? error;
  final String? errorMessage;
  final ValueChanged<bool>? onAgreedChanged;
  final VoidCallback? onAccept;
  final VoidCallback? onLater;
  final ValueChanged<LegalDocument> onOpenDocument;
}

class CommunityLegalReaderDetails {
  const CommunityLegalReaderDetails({
    required this.document,
    required this.meta,
    required this.changesLabel,
    required this.padding,
    this.title,
  });

  final LegalDocument document;
  final String? title;
  final String meta;
  final String changesLabel;
  final EdgeInsetsGeometry padding;

  String get body => document.body;

  String? get changes => document.changeSummary;
}

enum CommunityAccountTileKind { appeals, exportData, deleteAccount }

class CommunityAccountTileDetails {
  const CommunityAccountTileDetails({
    required this.kind,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.destructive = false,
    this.busy = false,
    this.onTap,
  });

  final CommunityAccountTileKind kind;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;
  final bool busy;
  final VoidCallback? onTap;

  bool get enabled => onTap != null;
}

class CommunityDeleteConsequence {
  const CommunityDeleteConsequence({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class CommunityDeleteAccountDetails {
  const CommunityDeleteAccountDetails({
    required this.title,
    required this.intro,
    required this.consequences,
    required this.controller,
    required this.confirmWord,
    required this.fieldLabel,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.progressLabel,
    required this.canConfirm,
    required this.deleting,
    this.error,
    this.errorMessage,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String intro;
  final List<CommunityDeleteConsequence> consequences;
  final TextEditingController controller;
  final String confirmWord;
  final String fieldLabel;
  final String confirmLabel;
  final String cancelLabel;
  final String progressLabel;
  final bool canConfirm;
  final bool deleting;
  final Object? error;
  final String? errorMessage;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
}
