import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/repositories/trade_share_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

class TradeActivityDetailState {
  const TradeActivityDetailState({this.status = LoadStatus.initial, this.activity, this.error});

  final LoadStatus status;
  final TradeActivity? activity;
  final Object? error;
}

class TradeActivityDetailCubit extends Cubit<TradeActivityDetailState> {
  TradeActivityDetailCubit(this._repository, {required this.activityId, TradeActivity? initial})
    : super(
        TradeActivityDetailState(status: initial == null ? LoadStatus.initial : LoadStatus.ready, activity: initial),
      );

  final TradeShareRepository _repository;
  final String activityId;

  Future<void> load() async {
    final shown = state.activity;
    if (shown == null) emit(const TradeActivityDetailState(status: LoadStatus.loading));
    try {
      final activity = await _repository.activity(activityId);
      if (!isClosed) {
        emit(
          TradeActivityDetailState(
            status: LoadStatus.ready,
            activity: activity.trader == null && shown?.trader != null ? _withTrader(activity, shown!) : activity,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      emit(
        shown == null
            ? TradeActivityDetailState(status: LoadStatus.failure, error: e)
            : TradeActivityDetailState(status: LoadStatus.ready, activity: shown, error: e),
      );
    }
  }

  static TradeActivity _withTrader(TradeActivity activity, TradeActivity shown) => TradeActivity(
    id: activity.id,
    traderId: activity.traderId,
    trader: shown.trader,
    stock: activity.stock,
    side: activity.side,
    lots: activity.lots,
    orderLots: activity.orderLots,
    shares: activity.shares,
    price: activity.price,
    partial: activity.partial,
    additional: activity.additional,
    completedAt: activity.completedAt,
    texts: activity.texts,
    disclaimers: activity.disclaimers,
    cursor: activity.cursor,
  );
}
