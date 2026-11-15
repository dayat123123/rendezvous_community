import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/services/community_trade_share.dart';

abstract interface class CommunityTradeShareDependencies {
  CommunityTradeShare get tradeShare;
}

class CommunityTradeShareScope extends InheritedWidget {
  const CommunityTradeShareScope({super.key, required this.dependencies, required super.child});

  final CommunityTradeShareDependencies dependencies;

  static CommunityTradeShareDependencies of(BuildContext context) =>
      maybeOf(context) ??
      (throw StateError('No CommunityTradeShareScope found and RendezvousCommunity is not initialized'));

  static CommunityTradeShareDependencies? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityTradeShareScope>()?.dependencies ??
      (RendezvousCommunity.isInitialized ? RendezvousCommunity.instance : null);

  static CommunityTradeShare? serviceOf(BuildContext context) => maybeOf(context)?.tradeShare;

  @override
  bool updateShouldNotify(CommunityTradeShareScope oldWidget) => !identical(dependencies, oldWidget.dependencies);
}
