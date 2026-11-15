import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/cubit/trade_list_state.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

abstract class TradeListCubit<T> extends Cubit<TradeListState<T>> {
  TradeListCubit() : super(TradeListState<T>());

  Future<Paged<T>> fetch(String? cursor);

  String keyOf(T item);

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: () => null));
    try {
      final page = await fetch(null);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, items: page.items, nextCursor: () => page.nextCursor));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: () => e));
    }
  }

  Future<void> refresh() async {
    try {
      final page = await fetch(null);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, items: page.items, nextCursor: () => page.nextCursor));
    } catch (e) {
      fail(e);
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.status != LoadStatus.ready) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await fetch(cursor);
      if (isClosed) return;
      final known = {for (final item in state.items) keyOf(item)};
      emit(
        state.copyWith(
          items: [
            ...state.items,
            for (final item in page.items)
              if (!known.contains(keyOf(item))) item,
          ],
          nextCursor: () => page.nextCursor,
          loadingMore: false,
        ),
      );
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loadingMore: false));
    }
  }

  Future<bool> runFor(String key, Future<void> Function() action) async {
    if (state.busy.contains(key)) return false;
    emit(state.copyWith(busy: {...state.busy, key}));
    try {
      await action();
      return true;
    } catch (e) {
      fail(e);
      return false;
    } finally {
      if (!isClosed) emit(state.copyWith(busy: {...state.busy}..remove(key)));
    }
  }

  void replace(String key, T? item) {
    if (isClosed) return;
    emit(
      state.copyWith(
        items: [
          for (final current in state.items)
            if (keyOf(current) != key) current else ?item,
        ],
      ),
    );
  }

  void fail(Object error) {
    if (!isClosed) emit(state.copyWith(actionError: error, actionErrorId: state.actionErrorId + 1));
  }
}
