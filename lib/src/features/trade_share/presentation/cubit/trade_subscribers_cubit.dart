import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_cubit.dart';

class TradeSubscribersCubit extends TradeListCubit<TradeSubscriberEntry> {
  TradeSubscribersCubit(this._repository, {this.status = TradeSubscriberStatus.active, this.pageSize = 30});

  final TradeShareRepository _repository;
  final TradeSubscriberStatus status;
  final int pageSize;

  @override
  Future<Paged<TradeSubscriberEntry>> fetch(String? cursor) =>
      _repository.subscribers(status: status, cursor: cursor, limit: pageSize);

  @override
  String keyOf(TradeSubscriberEntry item) => item.subscriber.id;

  Future<bool> decide(TradeSubscriberEntry entry, {required bool approve}) => runFor(entry.subscriber.id, () async {
    await _repository.decideSubscriber(entry.subscriber.id, approve: approve);
    replace(entry.subscriber.id, null);
  });

  Future<bool> remove(TradeSubscriberEntry entry) => runFor(entry.subscriber.id, () async {
    await _repository.removeSubscriber(entry.subscriber.id);
    replace(entry.subscriber.id, null);
  });
}
