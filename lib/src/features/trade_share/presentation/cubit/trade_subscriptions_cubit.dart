import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_cubit.dart';

class TradeSubscriptionsCubit extends TradeListCubit<TradeSubscriptionEntry> {
  TradeSubscriptionsCubit(this._repository, {this.pageSize = 30});

  final TradeShareRepository _repository;
  final int pageSize;

  @override
  Future<Paged<TradeSubscriptionEntry>> fetch(String? cursor) =>
      _repository.subscriptions(cursor: cursor, limit: pageSize);

  @override
  String keyOf(TradeSubscriptionEntry item) => item.trader.id;

  Future<bool> setMuted(TradeSubscriptionEntry entry, {required bool muted}) => runFor(entry.trader.id, () async {
    final profile = await _repository.muteSubscription(entry.trader.id, muted: muted);
    final subscription = profile.subscription;
    replace(
      entry.trader.id,
      subscription != null && (subscription.isActive || subscription.isPending)
          ? entry.withSubscription(subscription)
          : null,
    );
  });

  Future<bool> cancel(TradeSubscriptionEntry entry) => runFor(entry.trader.id, () async {
    await _repository.cancelSubscription(entry.trader.id);
    replace(entry.trader.id, null);
  });
}
