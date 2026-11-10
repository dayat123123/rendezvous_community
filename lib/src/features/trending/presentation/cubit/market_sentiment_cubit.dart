import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/domain/repositories/trending_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'market_sentiment_cubit.freezed.dart';

@freezed
abstract class MarketSentimentState with _$MarketSentimentState {
  const factory MarketSentimentState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(TrendWindow.day) TrendWindow window,
    @Default(<TrendWindow, SentimentBreakdown>{}) Map<TrendWindow, SentimentBreakdown> breakdowns,
    Object? error,
  }) = _MarketSentimentState;

  const MarketSentimentState._();

  SentimentBreakdown? get current => breakdowns[window];
}

class MarketSentimentCubit extends Cubit<MarketSentimentState> {
  MarketSentimentCubit(this._trending, {TrendWindow window = TrendWindow.day})
    : super(MarketSentimentState(window: window));

  final TrendingInsightsRepository _trending;

  Future<void> load() async {
    final window = state.window;
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final breakdown = await _trending.marketSentiment(window: window);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, breakdowns: {...state.breakdowns, window: breakdown}));
    } catch (e) {
      final mapped = mapError(e);
      CommunityLoggers.feed.event(
        Level.WARNING,
        'Failed to load market sentiment',
        fields: {'window': window.value, 'kind': mapped.kind, 'code': mapped.code},
      );
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> setWindow(TrendWindow window) async {
    if (window == state.window) return;
    emit(state.copyWith(window: window));
    if (!state.breakdowns.containsKey(window)) await load();
  }
}
