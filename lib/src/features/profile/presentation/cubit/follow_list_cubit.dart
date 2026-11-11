import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'follow_list_cubit.freezed.dart';

@freezed
abstract class FollowListState with _$FollowListState {
  const factory FollowListState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(<FollowListEntry>[]) List<FollowListEntry> entries,
    String? nextCursor,
    @Default(false) bool loadingMore,
    @Default(<String>{}) Set<String> pending,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _FollowListState;
}

class FollowListCubit extends Cubit<FollowListState> {
  FollowListCubit({
    required this._lists,
    required this._profiles,
    required this.userId,
    required this.kind,
    this.pageSize = 30,
  }) : super(const FollowListState());

  final FollowListRepository _lists;
  final ProfileRepository _profiles;
  final String userId;
  final FollowListKind kind;
  final int pageSize;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final page = await _lists.followList(userId, kind, limit: pageSize);
      if (!isClosed) {
        emit(state.copyWith(status: LoadStatus.ready, entries: page.items, nextCursor: page.nextCursor));
      }
    } catch (e) {
      _logFailure('Failed to load the follow list', e);
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.status != LoadStatus.ready) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _lists.followList(userId, kind, cursor: cursor, limit: pageSize);
      if (isClosed) return;
      final known = {for (final e in state.entries) e.user.id};
      emit(
        state.copyWith(
          entries: [...state.entries, ...page.items.where((e) => !known.contains(e.user.id))],
          nextCursor: page.nextCursor,
          loadingMore: false,
        ),
      );
    } catch (e) {
      _logFailure('Failed to load more of the follow list', e);
      if (!isClosed) emit(state.copyWith(loadingMore: false));
    }
  }

  Future<void> toggleFollow(String targetId) async {
    if (state.pending.contains(targetId)) return;
    final entry = state.entries.where((e) => e.user.id == targetId && !e.isMe).firstOrNull;
    if (entry == null) return;
    final follow = !entry.isFollowing;
    emit(state.copyWith(pending: {...state.pending, targetId}, entries: _withFollowing(targetId, follow)));
    try {
      follow ? await _profiles.follow(targetId) : await _profiles.unfollow(targetId);
      if (!isClosed) emit(state.copyWith(pending: {...state.pending}..remove(targetId)));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          pending: {...state.pending}..remove(targetId),
          entries: _withFollowing(targetId, !follow),
          actionError: e,
          actionErrorId: state.actionErrorId + 1,
        ),
      );
    }
  }

  List<FollowListEntry> _withFollowing(String targetId, bool following) => [
    for (final e in state.entries) e.user.id == targetId ? e.copyWith(isFollowing: following) : e,
  ];

  void _logFailure(String message, Object error) {
    final mapped = mapError(error);
    CommunityLoggers.account.event(
      Level.WARNING,
      message,
      fields: {'kind': mapped.kind, 'code': mapped.code, 'list': kind.name},
    );
  }
}
