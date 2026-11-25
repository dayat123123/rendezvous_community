import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_updates.dart';
import 'package:rendezvous_community/src/features/trending/domain/entities/trending.dart';
import 'package:rendezvous_community/src/features/trending/domain/repositories/trending_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'trending_cubit.freezed.dart';

@freezed
abstract class TrendingState with _$TrendingState {
  const factory TrendingState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(TrendWindow.day) TrendWindow window,
    TrendingSnapshot? snapshot,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _TrendingState;
}

class TrendingCubit extends Cubit<TrendingState> {
  TrendingCubit(this._trending, {this._feed, TrendWindow window = TrendWindow.day})
    : super(TrendingState(window: window));

  final TrendingRepository _trending;
  final FeedRepository? _feed;

  Future<void> load({TrendWindow? window}) async {
    final target = window ?? state.window;
    emit(state.copyWith(status: LoadStatus.loading, window: target, error: null));
    try {
      final snapshot = await _trending.trending(window: target);
      if (!isClosed && state.window == target) emit(state.copyWith(status: LoadStatus.ready, snapshot: snapshot));
    } catch (e) {
      if (!isClosed && state.window == target) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> toggleLike(Post post) => react(post, toggledLikeReaction(_find(post)));

  Future<void> react(Post post, String? emoji) async {
    final feed = _feed;
    if (feed == null) return;
    final current = _find(post);
    final next = applyPostReaction(current, emoji);
    if (identical(next, current)) return;
    _replace(next);
    try {
      final saved = await sendPostReaction(feed, post.id, next.myReaction);
      if (saved != null) _replace(saved.copyWith(cursor: current.cursor));
    } catch (e) {
      _replace(current);
      if (!isClosed) emit(state.copyWith(actionError: e, actionErrorId: state.actionErrorId + 1));
    }
  }

  Post _find(Post post) => state.snapshot?.posts.where((p) => p.id == post.id).firstOrNull ?? post;

  void _replace(Post post) {
    final snapshot = state.snapshot;
    if (snapshot == null || isClosed) return;
    emit(
      state.copyWith(snapshot: snapshot.copyWith(posts: [for (final p in snapshot.posts) p.id == post.id ? post : p])),
    );
  }
}
