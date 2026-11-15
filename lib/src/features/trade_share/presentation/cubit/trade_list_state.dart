import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

class TradeListState<T> {
  const TradeListState({
    this.status = LoadStatus.initial,
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.busy = const {},
    this.error,
    this.actionError,
    this.actionErrorId = 0,
  });

  final LoadStatus status;
  final List<T> items;
  final String? nextCursor;
  final bool loadingMore;
  final Set<String> busy;
  final Object? error;
  final Object? actionError;
  final int actionErrorId;

  bool get hasMore => nextCursor != null;

  TradeListState<T> copyWith({
    LoadStatus? status,
    List<T>? items,
    String? Function()? nextCursor,
    bool? loadingMore,
    Set<String>? busy,
    Object? Function()? error,
    Object? actionError,
    int? actionErrorId,
  }) => TradeListState<T>(
    status: status ?? this.status,
    items: items ?? this.items,
    nextCursor: nextCursor == null ? this.nextCursor : nextCursor(),
    loadingMore: loadingMore ?? this.loadingMore,
    busy: busy ?? this.busy,
    error: error == null ? this.error : error(),
    actionError: actionError ?? this.actionError,
    actionErrorId: actionErrorId ?? this.actionErrorId,
  );
}
