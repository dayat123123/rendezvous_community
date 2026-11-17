import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'comment_audience_cubit.freezed.dart';

@freezed
abstract class CommentAudienceState with _$CommentAudienceState {
  const factory CommentAudienceState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(CommentAudience.everyone) CommentAudience audience,
    @Default(false) bool saving,
    @Default(0) int savedId,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _CommentAudienceState;
}

class CommentAudienceCubit extends Cubit<CommentAudienceState> {
  CommentAudienceCubit(this._controls) : super(const CommentAudienceState());

  final CommentControlRepository _controls;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final audience = await _controls.getCommentAudience();
      if (!isClosed) emit(state.copyWith(status: LoadStatus.ready, audience: audience));
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> setAudience(CommentAudience audience) async {
    final before = state.audience;
    if (before == audience || state.saving || audience == CommentAudience.off) return;
    emit(state.copyWith(saving: true, audience: audience));
    try {
      final saved = await _controls.setCommentAudience(audience);
      if (!isClosed) emit(state.copyWith(saving: false, audience: saved, savedId: state.savedId + 1));
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(saving: false, audience: before, actionError: e, actionErrorId: state.actionErrorId + 1));
      }
    }
  }
}
