import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'suggested_users_cubit.freezed.dart';

@freezed
abstract class SuggestedUsersState with _$SuggestedUsersState {
  const factory SuggestedUsersState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(<SuggestedUser>[]) List<SuggestedUser> users,
    @Default(<String>{}) Set<String> following,
    @Default(<String>{}) Set<String> pending,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _SuggestedUsersState;
}

class SuggestedUsersCubit extends Cubit<SuggestedUsersState> {
  SuggestedUsersCubit({required this._suggestions, required this._profiles, this.limit = 5})
    : super(const SuggestedUsersState());

  final SuggestedUsersRepository _suggestions;
  final ProfileRepository _profiles;
  final int limit;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final users = await _suggestions.suggestedUsers(limit: limit);
      if (!isClosed) emit(state.copyWith(status: LoadStatus.ready, users: users));
    } catch (e) {
      final mapped = mapError(e);
      CommunityLoggers.feed.event(
        Level.WARNING,
        'Failed to load suggested users',
        fields: {'kind': mapped.kind, 'code': mapped.code},
      );
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> toggleFollow(String userId) async {
    if (state.pending.contains(userId)) return;
    final follow = !state.following.contains(userId);
    emit(
      state.copyWith(
        pending: {...state.pending, userId},
        following: follow ? {...state.following, userId} : ({...state.following}..remove(userId)),
      ),
    );
    try {
      follow ? await _profiles.follow(userId) : await _profiles.unfollow(userId);
      if (!isClosed) emit(state.copyWith(pending: {...state.pending}..remove(userId)));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          pending: {...state.pending}..remove(userId),
          following: follow ? ({...state.following}..remove(userId)) : {...state.following, userId},
          actionError: e,
          actionErrorId: state.actionErrorId + 1,
        ),
      );
    }
  }
}
