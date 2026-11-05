import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunitySystemBuilders {
  const CommunitySystemBuilders({this.banner, this.unavailable, this.offlineBanner, this.consentBanner, this.popup});

  final CommunityPartBuilder<CommunityBannerDetails>? banner;
  final CommunityPartBuilder<CommunityUnavailableDetails>? unavailable;
  final CommunityPartBuilder<CommunityOfflineDetails>? offlineBanner;
  final CommunityPartBuilder<CommunityConsentBannerDetails>? consentBanner;
  final CommunityPartBuilder<CommunityPromoPopupDetails>? popup;

  static CommunitySystemBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunitySystemBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunitySystemBuildersScope>();
    return scope?.builders ?? const CommunitySystemBuilders();
  }

  CommunitySystemBuilders merge(CommunitySystemBuilders? other) {
    if (other == null) return this;
    return CommunitySystemBuilders(
      banner: other.banner ?? banner,
      unavailable: other.unavailable ?? unavailable,
      offlineBanner: other.offlineBanner ?? offlineBanner,
      consentBanner: other.consentBanner ?? consentBanner,
      popup: other.popup ?? popup,
    );
  }
}

class CommunitySystemBuildersScope extends InheritedWidget {
  const CommunitySystemBuildersScope({super.key, required this.builders, required super.child});

  final CommunitySystemBuilders builders;

  @override
  bool updateShouldNotify(CommunitySystemBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildSystemPart<T>(
  CommunityPartBuilder<T>? Function(CommunitySystemBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunitySystemBuilders.of(context)), context, details, fallback);
