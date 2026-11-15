import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_subscription.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/services/community_trade_share.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

class TradeShareProfileState {
  const TradeShareProfileState({
    this.status = LoadStatus.initial,
    this.profile,
    this.busy = false,
    this.actionError,
    this.actionErrorId = 0,
  });

  final LoadStatus status;
  final TradeShareProfile? profile;
  final bool busy;
  final Object? actionError;
  final int actionErrorId;

  TradeBellState get bell => profile?.bell ?? TradeBellState.hidden;

  TradeShareProfileState copyWith({
    LoadStatus? status,
    TradeShareProfile? profile,
    bool? busy,
    Object? actionError,
    int? actionErrorId,
  }) => TradeShareProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    busy: busy ?? this.busy,
    actionError: actionError ?? this.actionError,
    actionErrorId: actionErrorId ?? this.actionErrorId,
  );
}

class TradeShareProfileCubit extends Cubit<TradeShareProfileState> {
  TradeShareProfileCubit(this._service, {required this.traderId}) : super(const TradeShareProfileState());

  final CommunityTradeShare _service;
  final String traderId;

  Future<void> load() async {
    if (state.status != LoadStatus.ready) emit(state.copyWith(status: LoadStatus.loading));
    final status = await _service.ensureFresh();
    if (isClosed) return;
    if (status == null || !status.enabled) {
      emit(TradeShareProfileState(status: LoadStatus.ready, actionErrorId: state.actionErrorId));
      return;
    }
    try {
      final profile = await _service.repository.profile(traderId);
      _service.observeEnabled(profile.enabled);
      if (!isClosed) emit(state.copyWith(status: LoadStatus.ready, profile: profile));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure));
    }
  }

  Future<TradeShareProfile?> subscribe() {
    final risk = state.profile?.riskDocument;
    if (risk == null) return Future.value();
    return _run(() => _service.repository.subscribe(traderId, riskDocumentId: risk.id));
  }

  Future<TradeShareProfile?> setMuted(bool muted) =>
      _run(() => _service.repository.muteSubscription(traderId, muted: muted));

  Future<TradeShareProfile?> cancel() => _run(() => _service.repository.cancelSubscription(traderId));

  Future<TradeShareProfile?> _run(Future<TradeShareProfile> Function() action) async {
    if (state.busy) return null;
    emit(state.copyWith(busy: true));
    try {
      final profile = await action();
      _service.observeEnabled(profile.enabled);
      if (!isClosed) emit(state.copyWith(status: LoadStatus.ready, profile: profile, busy: false));
      return profile;
    } catch (e) {
      if (isClosed) return null;
      emit(state.copyWith(busy: false, actionError: e, actionErrorId: state.actionErrorId + 1));
      final code = mapError(e).code;
      if (code == 'risk_outdated' || code == 'cannot_subscribe' || code == 'subscription_not_found') {
        await load();
      }
      return null;
    }
  }
}
