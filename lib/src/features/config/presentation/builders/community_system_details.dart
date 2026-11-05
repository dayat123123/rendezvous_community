import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/legal/domain/entities/legal_document.dart';

class CommunityBannerDetails {
  const CommunityBannerDetails({
    required this.banner,
    required this.icon,
    required this.openLabel,
    required this.dismissLabel,
    this.onOpen,
    this.onDismiss,
  });

  final CommunityBanner banner;
  final IconData icon;
  final String openLabel;
  final String dismissLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onDismiss;

  String get title => banner.title;

  String get message => banner.body;

  CommunityBannerLevel get level => banner.level;
}

class CommunityUnavailableDetails {
  const CommunityUnavailableDetails({required this.reason, required this.icon, required this.message, this.title});

  final CommunityUnavailableReason reason;
  final IconData icon;
  final String? title;
  final String message;

  bool get socialDisabled => reason == CommunityUnavailableReason.socialDisabled;
}

class CommunityOfflineDetails {
  const CommunityOfflineDetails({required this.message});

  final String message;
}

class CommunityConsentBannerDetails {
  const CommunityConsentBannerDetails({
    required this.documents,
    required this.message,
    required this.reviewLabel,
    required this.dismissLabel,
    required this.margin,
    required this.onReview,
    required this.onDismiss,
  });

  final List<LegalDocument> documents;
  final String message;
  final String reviewLabel;
  final String dismissLabel;
  final EdgeInsetsGeometry margin;
  final VoidCallback onReview;
  final VoidCallback onDismiss;

  bool get updated => documents.every((d) => d.isUpdate);
}

class CommunityPromoPopupDetails {
  const CommunityPromoPopupDetails({
    required this.banner,
    required this.ctaLabel,
    required this.laterLabel,
    required this.closeLabel,
    required this.semanticLabel,
    required this.onClose,
    this.onCta,
  });

  final CommunityBanner banner;
  final String ctaLabel;
  final String laterLabel;
  final String closeLabel;
  final String semanticLabel;
  final VoidCallback? onCta;
  final VoidCallback onClose;

  String? get imageUrl => banner.imageUrl;

  String get title => banner.title;

  String get body => banner.body;

  bool get dismissible => banner.dismissible;

  bool get hasLink => onCta != null;
}
