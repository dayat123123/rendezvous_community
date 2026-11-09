import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';
import 'package:rendezvous_community/src/features/help/presentation/cubit/help_center_cubit.dart';

part 'help_article_cubit.freezed.dart';

@freezed
abstract class HelpArticleState with _$HelpArticleState {
  const factory HelpArticleState({
    required HelpArticle article,
    @Default(false) bool loading,
    @Default(false) bool offline,
    Object? error,
    @Default(false) bool sending,
    @Default(false) bool commentSent,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _HelpArticleState;

  const HelpArticleState._();

  bool get missing => error != null && mapError(error!).kind == CommunityErrorKind.notFound;
}

class HelpArticleCubit extends Cubit<HelpArticleState> {
  HelpArticleCubit({required this._help, required HelpArticle article, this.language = 'id'})
    : super(HelpArticleState(article: article));

  final HelpRepository _help;
  final String language;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final article = await _help.article(state.article.id, language: language);
      if (isClosed) return;
      emit(state.copyWith(article: article, loading: false, offline: false));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(loading: false, offline: isHelpOfflineError(e), error: isHelpOfflineError(e) ? null : e));
    }
  }

  Future<void> vote(bool helpful) async {
    if (state.sending || state.article.feedback?.helpful == helpful) return;
    await _send(helpful, null, commentSent: false);
  }

  Future<void> submitComment(String comment) async {
    final helpful = state.article.feedback?.helpful;
    final text = comment.trim();
    if (state.sending || helpful == null || text.isEmpty) return;
    await _send(helpful, text, commentSent: true);
  }

  Future<void> _send(bool helpful, String? comment, {required bool commentSent}) async {
    emit(state.copyWith(sending: true));
    try {
      final feedback = await _help.sendFeedback(state.article.id, helpful: helpful, comment: comment);
      if (isClosed) return;
      emit(
        state.copyWith(
          article: state.article.copyWith(feedback: feedback),
          sending: false,
          commentSent: commentSent,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(sending: false, actionError: e, actionErrorId: state.actionErrorId + 1));
    }
  }
}
