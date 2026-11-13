import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/repositories/support_repository.dart';
import 'package:rendezvous_community/src/features/support/domain/services/support_intake.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'support_cubit.freezed.dart';

enum SupportNoticeKind { closed, complaintFiled, fakeReported, rated }

@freezed
abstract class SupportState with _$SupportState {
  const factory SupportState({
    @Default(LoadStatus.initial) LoadStatus status,
    SupportHome? home,
    @Default(<SupportTopic>[]) List<SupportTopic> topics,
    @Default(false) bool picking,
    @Default(false) bool history,
    @Default(false) bool busy,
    @Default(SensitiveCheck()) SensitiveCheck sensitive,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
    SupportNoticeKind? notice,
    @Default(0) int noticeId,
    String? suggesting,
    String? suggestionTopic,
    @Default(<HelpArticle>[]) List<HelpArticle> suggestions,
    CommunityAttachmentPolicy? attachmentPolicy,
    @Default(false) bool leavingMessage,
    String? intakeTopic,
  }) = _SupportState;

  const SupportState._();

  SupportTicket? get ticket => home?.ticket;

  bool showsConversation(DateTime now) =>
      (history && home?.roomId != null) || (!picking && (home?.showsConversation(now) ?? false));

  bool canRate(String ticketId) => ticket?.id == ticketId && (ticket?.canRate ?? false);

  bool get showsSuggestions => suggestionTopic != null && (suggestions.isNotEmpty || leavingMessage);

  SupportTopic? topicByCode(String code) => topics.where((t) => t.code == code).firstOrNull;

  bool get serviceOpen => home?.serviceOpen ?? true;
}

class SupportCubit extends Cubit<SupportState> {
  SupportCubit({
    required this._support,
    this._help,
    this.topic,
    this.screen,
    this.language = 'id',
    this.suggestionTimeout = const Duration(seconds: 4),
  }) : super(const SupportState());

  final SupportRepository _support;
  final HelpRepository? _help;
  final Duration suggestionTimeout;
  final String? topic;
  final String? screen;
  final String language;
  StreamSubscription<void>? _ticketEvents;
  String? _watchedRoom;
  Timer? _sensitiveDebounce;
  int _sensitiveRequest = 0;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final results = await Future.wait([_support.home(), _support.topics(language: language)]);
      if (isClosed) return;
      final home = await _localized(results[0] as SupportHome);
      if (isClosed) return;
      final initialTopic = topic;
      final unreadClosed =
          initialTopic == null &&
          home.roomId != null &&
          home.unreadCount > 0 &&
          !home.showsConversation(DateTime.now());
      emit(
        state.copyWith(
          status: LoadStatus.ready,
          home: home,
          topics: results[1] as List<SupportTopic>,
          history: state.history || unreadClosed,
        ),
      );
      _watch(home.roomId);
      unawaited(loadAttachmentPolicy());
      if (home.active || initialTopic == null) return;
      if (state.topicByCode(initialTopic)?.hasIntake ?? false) {
        emit(state.copyWith(picking: true, intakeTopic: initialTopic));
        return;
      }
      await start(initialTopic);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> loadAttachmentPolicy() async {
    try {
      final policy = await _support.attachmentPolicy();
      if (!isClosed) emit(state.copyWith(attachmentPolicy: policy));
    } catch (e) {
      CommunityLoggers.support.warning('Could not load the attachment policy; keeping the previous one', e);
    }
  }

  void _watch(String? roomId) {
    if (roomId == null || roomId == _watchedRoom) return;
    _watchedRoom = roomId;
    unawaited(_ticketEvents?.cancel());
    _ticketEvents = _support.watchTicket(roomId).listen((_) => refresh());
  }

  Future<SupportHome> _localized(SupportHome home) async {
    if (home.incidents.isEmpty || language == 'id') return home;
    try {
      return home.copyWith(incidents: await _support.serviceStatus(language: language));
    } catch (e) {
      CommunityLoggers.support.event(
        Level.FINE,
        'Localized service status unavailable',
        fields: {'errorType': e.runtimeType.toString()},
      );
      return home;
    }
  }

  Future<void> refresh() async {
    try {
      final home = await _localized(await _support.home());
      if (isClosed) return;
      emit(state.copyWith(home: home));
      _watch(home.roomId);
    } catch (_) {}
  }

  void pickTopic() => emit(
    state.copyWith(
      picking: true,
      history: false,
      suggestionTopic: null,
      suggestions: const [],
      leavingMessage: false,
      intakeTopic: null,
    ),
  );

  void showHistory() => emit(state.copyWith(picking: false, history: true));

  Future<void> select(String topic) async {
    if (state.busy || state.suggesting != null) return;
    final closedHours = !state.serviceOpen;
    final help = _help;
    if (help == null && !closedHours) return proceed(topic);
    var articles = const <HelpArticle>[];
    if (help != null) {
      emit(state.copyWith(suggesting: topic));
      try {
        articles = await help.articlesForTopic(topic, language: language).timeout(suggestionTimeout);
      } catch (e) {
        CommunityLoggers.support.event(
          Level.FINE,
          'Help suggestions unavailable',
          fields: {'topic': topic, 'errorType': e.runtimeType.toString()},
        );
      }
      if (isClosed) return;
    }
    if (articles.isEmpty && !closedHours) {
      emit(state.copyWith(suggesting: null));
      return proceed(topic);
    }
    emit(state.copyWith(suggesting: null, suggestionTopic: topic, suggestions: articles, leavingMessage: closedHours));
  }

  void dismissSuggestions() =>
      emit(state.copyWith(suggestionTopic: null, suggestions: const [], leavingMessage: false));

  Future<void> proceed(String topic) async {
    if (state.busy) return;
    if (!(state.topicByCode(topic)?.hasIntake ?? false)) return start(topic);
    emit(state.copyWith(intakeTopic: topic, suggestionTopic: null, suggestions: const []));
  }

  void cancelIntake() => emit(state.copyWith(intakeTopic: null, leavingMessage: false));

  Future<bool> submitIntake(Map<String, String> answers) async {
    final code = state.intakeTopic;
    if (code == null) return false;
    final fields = state.topicByCode(code)?.intake ?? const <SupportIntakeField>[];
    if (validateSupportIntake(fields, answers).isNotEmpty) return false;
    await start(code, intake: supportIntakePayload(fields, answers));
    return state.intakeTopic == null;
  }

  Future<void> start(String topic, {Map<String, String>? intake}) => _act(() async {
    await _support.openTicket(
      topic: topic,
      language: language,
      screen: screen,
      intake: intake == null || intake.isEmpty ? null : intake,
    );
    await refresh();
    if (!isClosed) {
      emit(
        state.copyWith(
          picking: false,
          history: false,
          suggestionTopic: null,
          suggestions: const [],
          leavingMessage: false,
          intakeTopic: null,
        ),
      );
    }
  });

  Future<void> closeTicket() => _act(() async {
    final ticket = state.ticket;
    if (ticket == null || !ticket.isActive) return;
    await _support.closeTicket(ticket.id);
    await refresh();
  }, notice: SupportNoticeKind.closed);

  Future<void> fileComplaint() => _act(() async {
    await _support.requestComplaint();
    await refresh();
  }, notice: SupportNoticeKind.complaintFiled);

  Future<void> reportFakeCs(String description) => _act(() async {
    await _support.reportFakeCs(description);
    await refresh();
    if (!isClosed) emit(state.copyWith(picking: false));
  }, notice: SupportNoticeKind.fakeReported);

  Future<void> rate(String ticketId, int rating, {String? comment, List<String>? reasons}) => _act(() async {
    await _support.rateTicket(
      ticketId,
      rating,
      comment: comment,
      reasons: reasons == null || reasons.isEmpty ? null : reasons,
    );
    await refresh();
  }, notice: SupportNoticeKind.rated);

  void checkText(String text) {
    _sensitiveDebounce?.cancel();
    final value = text.trim();
    if (value.length < 4) {
      if (state.sensitive.masked) emit(state.copyWith(sensitive: const SensitiveCheck()));
      return;
    }
    _sensitiveDebounce = Timer(const Duration(milliseconds: 600), () async {
      final request = ++_sensitiveRequest;
      try {
        final check = await _support.checkSensitive(value);
        if (!isClosed && request == _sensitiveRequest) emit(state.copyWith(sensitive: check));
      } catch (_) {}
    });
  }

  Future<void> _act(Future<void> Function() action, {SupportNoticeKind? notice}) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      await action();
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            notice: notice ?? state.notice,
            noticeId: notice == null ? state.noticeId : state.noticeId + 1,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) emit(state.copyWith(busy: false, actionError: e, actionErrorId: state.actionErrorId + 1));
    }
  }

  @override
  Future<void> close() async {
    _sensitiveDebounce?.cancel();
    await _ticketEvents?.cancel();
    return super.close();
  }
}
