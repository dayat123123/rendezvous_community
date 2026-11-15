import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunityTradeShareBuilders {
  const CommunityTradeShareBuilders({
    this.loading,
    this.empty,
    this.error,
    this.unavailable,
    this.statusCard,
    this.checkRow,
    this.preview,
    this.profileBar,
    this.subscriptionTile,
    this.subscriberTile,
    this.activityTile,
    this.activityDetail,
  });

  final CommunityPartBuilder<CommunityTradeLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityTradeEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityTradeErrorDetails>? error;
  final CommunityPartBuilder<CommunityTradeUnavailableDetails>? unavailable;
  final CommunityPartBuilder<CommunityTradeShareStatusDetails>? statusCard;
  final CommunityPartBuilder<CommunityTradeShareCheckDetails>? checkRow;
  final CommunityPartBuilder<CommunityTradeSharePreviewDetails>? preview;
  final CommunityPartBuilder<CommunityTradeProfileBarDetails>? profileBar;
  final CommunityPartBuilder<CommunityTradeSubscriptionTileDetails>? subscriptionTile;
  final CommunityPartBuilder<CommunityTradeSubscriberTileDetails>? subscriberTile;
  final CommunityPartBuilder<CommunityTradeActivityTileDetails>? activityTile;
  final CommunityPartBuilder<CommunityTradeActivityViewDetails>? activityDetail;

  static CommunityTradeShareBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunityTradeShareBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunityTradeShareBuildersScope>();
    return scope?.builders ?? const CommunityTradeShareBuilders();
  }

  CommunityTradeShareBuilders merge(CommunityTradeShareBuilders? other) {
    if (other == null) return this;
    return CommunityTradeShareBuilders(
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      unavailable: other.unavailable ?? unavailable,
      statusCard: other.statusCard ?? statusCard,
      checkRow: other.checkRow ?? checkRow,
      preview: other.preview ?? preview,
      profileBar: other.profileBar ?? profileBar,
      subscriptionTile: other.subscriptionTile ?? subscriptionTile,
      subscriberTile: other.subscriberTile ?? subscriberTile,
      activityTile: other.activityTile ?? activityTile,
      activityDetail: other.activityDetail ?? activityDetail,
    );
  }
}

class CommunityTradeShareBuildersScope extends InheritedWidget {
  const CommunityTradeShareBuildersScope({super.key, required this.builders, required super.child});

  final CommunityTradeShareBuilders builders;

  @override
  bool updateShouldNotify(CommunityTradeShareBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildTradeSharePart<T>(
  CommunityPartBuilder<T>? Function(CommunityTradeShareBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunityTradeShareBuilders.of(context)), context, details, fallback);
