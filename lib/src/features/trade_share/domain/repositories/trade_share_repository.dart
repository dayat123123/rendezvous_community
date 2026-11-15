import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';

abstract interface class TradeShareRepository {
  Future<TradeShareStatus> status();

  Future<TradeShareStatus> apply(TradeShareApplication application, {required String termsDocumentId});

  Future<TradeShareStatus> updateSettings(TradeShareApplication settings, {bool confirm = false});

  Future<TradeShareStatus> pause();

  Future<TradeShareStatus> resume();

  Future<TradeShareStatus> withdraw();

  Future<TradeShareProfile> profile(String traderId);

  Future<TradeShareProfile> subscribe(String traderId, {required String riskDocumentId});

  Future<TradeShareProfile> cancelSubscription(String traderId);

  Future<TradeShareProfile> muteSubscription(String traderId, {required bool muted});

  Future<Paged<TradeSubscriptionEntry>> subscriptions({String? cursor, int limit = 30});

  Future<Paged<TradeSubscriberEntry>> subscribers({
    TradeSubscriberStatus status = TradeSubscriberStatus.active,
    String? cursor,
    int limit = 30,
  });

  Future<TradeSubscriptionStatus> decideSubscriber(String subscriberId, {required bool approve});

  Future<void> removeSubscriber(String subscriberId);

  Future<Paged<TradeActivity>> activityFeed({String? cursor, int limit = 30});

  Future<TradeActivity> activity(String activityId);
}
