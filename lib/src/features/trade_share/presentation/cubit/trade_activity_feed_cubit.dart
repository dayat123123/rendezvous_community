import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_cubit.dart';

class TradeActivityFeedCubit extends TradeListCubit<TradeActivity> {
  TradeActivityFeedCubit(this._repository, {this.pageSize = 30});

  final TradeShareRepository _repository;
  final int pageSize;

  @override
  Future<Paged<TradeActivity>> fetch(String? cursor) => _repository.activityFeed(cursor: cursor, limit: pageSize);

  @override
  String keyOf(TradeActivity item) => item.id;
}
