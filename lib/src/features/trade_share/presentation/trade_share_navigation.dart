import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_trade_share_scope.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_share_page.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_subscribers_page.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_subscriptions_page.dart';

Widget Function(Widget child) carryTradeShareScopes(BuildContext context) {
  final dependencies = context.getInheritedWidgetOfExactType<CommunityScope>()?.dependencies;
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  final trade = context.getInheritedWidgetOfExactType<CommunityTradeShareScope>()?.dependencies;
  final carry = carryCommunityBuilders(context);
  return (child) {
    Widget page = child;
    if (trade != null) page = CommunityTradeShareScope(dependencies: trade, child: page);
    if (features != null) page = CommunityFeatureScope(dependencies: features, child: page);
    if (dependencies != null) page = CommunityScope(dependencies: dependencies, child: page);
    return carry(page);
  };
}

Future<T?> _push<T>(BuildContext context, Widget page) {
  final carry = carryTradeShareScopes(context);
  return Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => carry(page)));
}

bool canOpenTradeShare(BuildContext context) => CommunityTradeShareScope.maybeOf(context) != null;

Future<void> openCommunityTradeShare(BuildContext context) => _push<void>(context, const CommunityTradeSharePage());

Future<void> openCommunityTradeSubscriptions(BuildContext context) =>
    _push<void>(context, const CommunityTradeSubscriptionsPage());

Future<void> openCommunityTradeSubscribers(BuildContext context, {bool requests = false}) =>
    _push<void>(context, CommunityTradeSubscribersPage(initialRequests: requests));

Future<void> openCommunityTradeActivityFeed(BuildContext context) =>
    _push<void>(context, const CommunityTradeActivityFeedPage());

Future<void> openCommunityTradeActivity(BuildContext context, String activityId, {TradeActivity? activity}) =>
    _push<void>(context, CommunityTradeActivityPage(activityId: activityId, activity: activity));
