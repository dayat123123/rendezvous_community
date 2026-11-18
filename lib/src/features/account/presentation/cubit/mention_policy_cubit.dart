import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/mention_policy.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'mention_policy_cubit.freezed.dart';

@freezed
abstract class MentionPolicyState with _$MentionPolicyState {
  const factory MentionPolicyState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(MentionPolicy.everyone) MentionPolicy policy,
    @Default(false) bool saving,
    @Default(0) int savedId,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _MentionPolicyState;
}

class MentionPolicyCubit extends Cubit<MentionPolicyState> {
  MentionPolicyCubit(this._repository) : super(const MentionPolicyState());

  final MentionPolicyRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final policy = await _repository.getMentionPolicy();
      if (!isClosed) emit(state.copyWith(status: LoadStatus.ready, policy: policy));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> setPolicy(MentionPolicy policy) async {
    final before = state.policy;
    if (before == policy || state.saving) return;
    emit(state.copyWith(saving: true, policy: policy));
    try {
      final saved = await _repository.setMentionPolicy(policy);
      if (!isClosed) emit(state.copyWith(saving: false, policy: saved, savedId: state.savedId + 1));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(saving: false, policy: before, actionError: e, actionErrorId: state.actionErrorId + 1));
      }
    }
  }
}
