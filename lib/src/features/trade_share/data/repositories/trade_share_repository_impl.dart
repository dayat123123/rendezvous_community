import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/network/json_values.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/data/models/trade_share_models.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_share.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';

class TradeShareRepositoryImpl implements TradeShareRepository {
  TradeShareRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  Future<TradeShareStatus> _status(String fn, [Map<String, Object?> params = const {}]) async =>
      tradeShareStatusFromJson(await _api.rpcValue(fn, params));

  Future<TradeShareProfile> _profile(String fn, Map<String, Object?> params) async =>
      tradeShareProfileFromJson(await _api.rpcValue(fn, params));

  Map<String, Object?> _settings(TradeShareApplication settings) => {
    'p_accounts': settings.accounts,
    'p_show_price': settings.showPrice,
    'p_show_lot': settings.showLot,
    'p_delay_minutes': settings.delayMinutes,
    'p_subscribe_mode': tradeSubscribeModeToJson(settings.subscribeMode),
  };

  @override
  Future<TradeShareStatus> status() => _status('get_trade_share_status');

  @override
  Future<TradeShareStatus> apply(TradeShareApplication application, {required String termsDocumentId}) =>
      _status('submit_trade_share_application', {..._settings(application), 'p_terms_document_id': termsDocumentId});

  @override
  Future<TradeShareStatus> updateSettings(TradeShareApplication settings, {bool confirm = false}) =>
      _status('update_trade_share_settings', {..._settings(settings), 'p_confirm': confirm});

  @override
  Future<TradeShareStatus> pause() => _status('pause_trade_share');

  @override
  Future<TradeShareStatus> resume() => _status('resume_trade_share');

  @override
  Future<TradeShareStatus> withdraw() => _status('withdraw_trade_share');

  @override
  Future<TradeShareProfile> profile(String traderId) => _profile('get_trade_share_profile', {'p_trader': traderId});

  @override
  Future<TradeShareProfile> subscribe(String traderId, {required String riskDocumentId}) =>
      _profile('request_trade_subscription', {'p_trader': traderId, 'p_risk_document_id': riskDocumentId});

  @override
  Future<TradeShareProfile> cancelSubscription(String traderId) =>
      _profile('cancel_trade_subscription', {'p_trader': traderId});

  @override
  Future<TradeShareProfile> muteSubscription(String traderId, {required bool muted}) =>
      _profile('mute_trade_subscription', {'p_trader': traderId, 'p_muted': muted});

  @override
  Future<Paged<TradeSubscriptionEntry>> subscriptions({String? cursor, int limit = 30}) async {
    final rows = jsonList(await _api.rpcValue('my_trade_subscriptions', {'p_cursor': cursor, 'p_limit': limit}));
    return _page(rows, limit, tradeSubscriptionEntryFromJson);
  }

  @override
  Future<Paged<TradeSubscriberEntry>> subscribers({
    TradeSubscriberStatus status = TradeSubscriberStatus.active,
    String? cursor,
    int limit = 30,
  }) async {
    final rows = jsonList(
      await _api.rpcValue('my_trade_subscribers', {'p_status': status.name, 'p_cursor': cursor, 'p_limit': limit}),
    );
    return _page(rows, limit, tradeSubscriberEntryFromJson);
  }

  @override
  Future<TradeSubscriptionStatus> decideSubscriber(String subscriberId, {required bool approve}) async {
    final result = jsonMap(
      await _api.rpcValue('decide_trade_subscription', {'p_subscriber': subscriberId, 'p_approve': approve}),
    );
    return tradeSubscriptionStatusFromJson(result['status']);
  }

  @override
  Future<void> removeSubscriber(String subscriberId) =>
      _api.rpcValue('remove_trade_subscriber', {'p_subscriber': subscriberId});

  @override
  Future<Paged<TradeActivity>> activityFeed({String? cursor, int limit = 30}) async {
    final rows = jsonList(await _api.rpcValue('trade_activity_feed', {'p_cursor': cursor, 'p_limit': limit}));
    return _page(rows, limit, tradeActivityFromJson);
  }

  @override
  Future<TradeActivity> activity(String activityId) async {
    final activity = tradeActivityFromJson(
      jsonMap(await _api.rpcValue('trade_activity_detail', {'p_activity': activityId})),
    );
    if (activity == null) {
      throw const CommunityException(CommunityErrorKind.notFound, code: 'activity_not_found');
    }
    return activity;
  }

  static Paged<T> _page<T>(List<Map<String, dynamic>> rows, int limit, T? Function(Map<String, dynamic>) parse) {
    final items = [for (final row in rows) ?parse(row)];
    final last = rows.isEmpty ? null : rows.last['cursor'];
    return Paged(items, nextCursor: rows.length < limit || last is! String || last.isEmpty ? null : last);
  }
}
