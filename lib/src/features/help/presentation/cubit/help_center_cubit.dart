import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/repositories/support_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'help_center_cubit.freezed.dart';

const helpQueryMinLength = 2;
const helpQueryMaxLength = 100;

bool isHelpOfflineError(Object error) => switch (mapError(error).kind) {
  CommunityErrorKind.network || CommunityErrorKind.unavailable => true,
  _ => false,
};

@freezed
abstract class HelpCenterState with _$HelpCenterState {
  const factory HelpCenterState({
    @Default(LoadStatus.initial) LoadStatus status,
    HelpCenterContent? content,
    @Default(false) bool offline,
    Object? error,
    @Default('') String query,
    @Default(false) bool searching,
    List<HelpArticle>? results,
    @Default(false) bool savedResults,
    Object? searchError,
    @Default(<SupportIncident>[]) List<SupportIncident> incidents,
  }) = _HelpCenterState;

  const HelpCenterState._();

  bool get searchActive => query.trim().length >= helpQueryMinLength;
}

class HelpCenterCubit extends Cubit<HelpCenterState> {
  HelpCenterCubit({
    required this._help,
    this._support,
    this.language = 'id',
    this.searchDelay = const Duration(milliseconds: 350),
  }) : super(const HelpCenterState());

  final HelpRepository _help;
  final SupportRepository? _support;
  final String language;
  final Duration searchDelay;
  Timer? _debounce;
  int _request = 0;
  bool _loading = false;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    final incidents = _loadIncidents();
    try {
      if (state.content == null) {
        emit(state.copyWith(status: LoadStatus.loading, error: null));
        final cached = await _help.cachedHelpCenter(language: language);
        if (isClosed) return;
        if (cached != null && state.content == null) {
          emit(state.copyWith(status: LoadStatus.ready, content: cached));
        }
      }
      final content = await _help.helpCenter(language: language);
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.ready, content: content, offline: false, error: null));
      if (state.searchActive && state.savedResults) unawaited(_search(state.query.trim()));
    } catch (e) {
      if (isClosed) return;
      if (state.content != null) {
        emit(state.copyWith(status: LoadStatus.ready, offline: true, error: e));
      } else {
        emit(state.copyWith(status: LoadStatus.failure, error: e));
      }
    } finally {
      _loading = false;
    }
    await incidents;
  }

  Future<void> _loadIncidents() async {
    final support = _support;
    if (support == null) return;
    try {
      final incidents = await support.serviceStatus(language: language);
      if (!isClosed) emit(state.copyWith(incidents: incidents));
    } catch (e) {
      CommunityLoggers.support.event(
        Level.FINE,
        'Service status unavailable in help center',
        fields: {'errorType': e.runtimeType.toString()},
      );
    }
  }

  void search(String query) {
    _debounce?.cancel();
    final value = query.trim();
    if (value.length < helpQueryMinLength) {
      _request++;
      emit(state.copyWith(query: query, searching: false, results: null, savedResults: false, searchError: null));
      return;
    }
    final content = state.content;
    if (state.offline && content != null) {
      _request++;
      emit(
        state.copyWith(
          query: query,
          searching: false,
          results: content.search(value),
          savedResults: true,
          searchError: null,
        ),
      );
      return;
    }
    emit(state.copyWith(query: query, searching: true, searchError: null));
    _debounce = Timer(searchDelay, () => _search(value));
  }

  void clearSearch() => search('');

  Future<void> _search(String value) async {
    final request = ++_request;
    try {
      final results = await _help.search(value, language: language);
      if (isClosed || request != _request) return;
      emit(state.copyWith(searching: false, results: results, savedResults: false, searchError: null));
    } catch (e) {
      if (isClosed || request != _request) return;
      final content = state.content;
      if (content != null && isHelpOfflineError(e)) {
        emit(state.copyWith(searching: false, results: content.search(value), savedResults: true, searchError: null));
      } else {
        emit(state.copyWith(searching: false, results: null, searchError: e));
      }
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
