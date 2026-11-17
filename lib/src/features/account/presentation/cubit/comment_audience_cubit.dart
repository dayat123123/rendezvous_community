import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'comment_audience_cubit.freezed.dart';

enum CommentSettingSaved { audience, allOff, allOn }

@freezed
abstract class CommentAudienceState with _$CommentAudienceState {
  const factory CommentAudienceState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(CommentAudience.everyone) CommentAudience audience,
    @Default(false) bool allOff,
    @Default(false) bool allOffSupported,
    @Default(false) bool saving,
    @Default(0) int savedId,
    CommentSettingSaved? saved,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _CommentAudienceState;
}

class CommentAudienceCubit extends Cubit<CommentAudienceState> {
  CommentAudienceCubit(this._controls) : super(const CommentAudienceState());

  final CommentControlRepository _controls;

  CommentSettingsRepository? get _settings => switch (_controls) {
    final CommentSettingsRepository settings => settings,
    _ => null,
  };

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final settings = _settings;
      final loaded = settings == null
          ? CommentSettings(audience: await _controls.getCommentAudience())
          : await settings.getCommentSettings();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: LoadStatus.ready,
            audience: loaded.audience,
            allOff: loaded.allOff,
            allOffSupported: settings != null && loaded.allOffAvailable,
          ),
        );
      }
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
      if (!isClosed) {
        emit(
          state.copyWith(
            saving: false,
            audience: saved,
            saved: CommentSettingSaved.audience,
            savedId: state.savedId + 1,
          ),
        );
      }
    } catch (e) {
      _fail(e, audience: before);
    }
  }

  Future<void> setAllOff(bool off) async {
    final settings = _settings;
    final before = state.allOff;
    if (settings == null || !state.allOffSupported || before == off || state.saving) return;
    emit(state.copyWith(saving: true, allOff: off));
    try {
      final saved = await settings.setAllCommentsOff(off);
      if (!isClosed) {
        emit(
          state.copyWith(
            saving: false,
            allOff: saved.allOff,
            audience: saved.audience,
            saved: saved.allOff ? CommentSettingSaved.allOff : CommentSettingSaved.allOn,
            savedId: state.savedId + 1,
          ),
        );
      }
    } catch (e) {
      _fail(e, allOff: before);
    }
  }

  void _fail(Object error, {CommentAudience? audience, bool? allOff}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        saving: false,
        audience: audience ?? state.audience,
        allOff: allOff ?? state.allOff,
        actionError: error,
        actionErrorId: state.actionErrorId + 1,
      ),
    );
  }
}
