import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/text/social_text_parser.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/entities/guest_support.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/repositories/guest_session_store.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/repositories/guest_support_repository.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:uuid/uuid.dart';

part 'guest_support_cubit.freezed.dart';

enum GuestSupportPhase { loading, disabled, form, chat, ended, failure }

enum GuestSupportEndReason { resolved, closed, expired, ended }

@freezed
abstract class GuestSupportState with _$GuestSupportState {
  const factory GuestSupportState({
    @Default(GuestSupportPhase.loading) GuestSupportPhase phase,
    GuestSupportConfig? config,
    GuestSupportToken? token,
    SupportTicket? ticket,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool starting,
    @Default(false) bool sending,
    @Default(false) bool ending,
    @Default(false) bool reconnecting,
    GuestSupportEndReason? endReason,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _GuestSupportState;

  const GuestSupportState._();

  bool get busy => starting || sending || ending;

  bool get canSend => phase == GuestSupportPhase.chat && (ticket?.isActive ?? false) && !ending;

  List<GuestLoginProblem> get problems => config?.problems ?? const [];
}

class GuestSupportCubit extends Cubit<GuestSupportState> {
  GuestSupportCubit({
    required this._repository,
    required this._store,
    this.language = 'id',
    this.pollInterval = const Duration(seconds: 4),
    this.maxBackoff = const Duration(seconds: 60),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const GuestSupportState());

  final GuestSupportRepository _repository;
  final CommunityGuestSessionStore _store;
  final String language;
  final Duration pollInterval;
  final Duration maxBackoff;
  final DateTime Function() _clock;
  static const _uuid = Uuid();
  Timer? _timer;
  int _failures = 0;
  bool _visible = true;
  bool _polling = false;

  Duration get nextPollDelay {
    if (_failures == 0) return pollInterval;
    final factor = math.pow(2, math.min(_failures, 10)).toInt();
    final delay = pollInterval * factor;
    return delay > maxBackoff ? maxBackoff : delay;
  }

  Future<void> load() async {
    _timer?.cancel();
    emit(state.copyWith(phase: GuestSupportPhase.loading, error: null));
    final saved = await _read();
    if (isClosed) return;
    if (saved != null && saved.validAt(_clock())) {
      try {
        final snapshot = await _repository.poll(saved.token);
        if (isClosed) return;
        _failures = 0;
        CommunityLoggers.support.info('Guest support session resumed');
        _apply(snapshot, saved.copyWith(expiresAt: snapshot.expiresAt), fresh: true);
        unawaited(_backgroundConfig());
        return;
      } catch (e) {
        if (isClosed) return;
        if (guestSupportErrorOf(e) != GuestSupportError.sessionExpired) {
          emit(state.copyWith(phase: GuestSupportPhase.failure, error: e));
          return;
        }
        CommunityLoggers.support.info('Saved guest support session has expired; showing the form');
      }
    }
    if (saved != null) await _clear();
    await _loadConfig();
  }

  Future<void> _backgroundConfig() async {
    try {
      final config = await _repository.config(language: language);
      if (!isClosed) emit(state.copyWith(config: config));
    } catch (e) {
      CommunityLoggers.support.fine('Guest support config could not be refreshed in the background', e);
    }
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _repository.config(language: language);
      if (isClosed) return;
      emit(
        state.copyWith(
          phase: config.enabled ? GuestSupportPhase.form : GuestSupportPhase.disabled,
          config: config,
          error: null,
        ),
      );
    } catch (e) {
      if (!isClosed) emit(state.copyWith(phase: GuestSupportPhase.failure, error: e));
    }
  }

  Future<bool> start({
    required String name,
    String? loginId,
    required String? problem,
    required String description,
  }) async {
    if (state.starting || state.phase != GuestSupportPhase.form) return false;
    final issues = validateGuestSupportForm(
      name: name,
      loginId: loginId,
      problem: problem,
      description: description,
      problems: state.problems.isEmpty ? guestProblemCodes : state.problems.map((p) => p.code),
    );
    if (issues.isNotEmpty) return false;
    emit(state.copyWith(starting: true));
    try {
      final session = await _repository.start(
        name: name,
        loginId: loginId,
        problem: problem!,
        description: description,
        language: language,
      );
      if (isClosed) return true;
      await _write(session.token);
      _failures = 0;
      emit(
        state.copyWith(
          phase: GuestSupportPhase.chat,
          token: session.token,
          ticket: session.ticket,
          messages: const [],
          starting: false,
          reconnecting: false,
          endReason: null,
        ),
      );
      await poll();
      return true;
    } catch (e) {
      if (isClosed) return false;
      final disabled = guestSupportErrorOf(e) == GuestSupportError.disabled;
      emit(
        state.copyWith(
          starting: false,
          phase: disabled ? GuestSupportPhase.disabled : state.phase,
          actionError: e,
          actionErrorId: state.actionErrorId + 1,
        ),
      );
      return false;
    }
  }

  Future<void> poll() async {
    final token = state.token;
    if (token == null || state.phase != GuestSupportPhase.chat || _polling) return;
    _timer?.cancel();
    if (!token.validAt(_clock())) {
      await _expire();
      return;
    }
    _polling = true;
    try {
      final snapshot = await _repository.poll(token.token);
      if (isClosed) return;
      _failures = 0;
      _apply(snapshot, token.copyWith(expiresAt: snapshot.expiresAt));
    } catch (e) {
      if (isClosed) return;
      if (guestSupportErrorOf(e) == GuestSupportError.sessionExpired) {
        await _expire();
        return;
      }
      _failures++;
      CommunityLoggers.support.event(
        Level.FINE,
        'Guest support poll failed, backing off',
        fields: {'failures': _failures, 'delayMs': nextPollDelay.inMilliseconds},
      );
      emit(state.copyWith(reconnecting: true));
    } finally {
      _polling = false;
    }
    _schedule();
  }

  void setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    if (!visible) {
      _timer?.cancel();
      return;
    }
    if (state.phase == GuestSupportPhase.chat) unawaited(poll());
  }

  void _schedule() {
    _timer?.cancel();
    if (isClosed || !_visible || state.phase != GuestSupportPhase.chat) return;
    _timer = Timer(nextPollDelay, () => unawaited(poll()));
  }

  void _apply(GuestSupportSnapshot snapshot, GuestSupportToken token, {bool fresh = false}) {
    final serverClientIds = {for (final m in snapshot.messages) ?m.clientId};
    final serverIds = {for (final m in snapshot.messages) m.id};
    final pending = [
      for (final m in fresh ? const <ChatMessage>[] : state.messages)
        if (m.isLocal && !serverClientIds.contains(m.clientId) && !serverIds.contains(m.id)) m,
    ];
    final ticket = snapshot.ticket;
    final messages = [...snapshot.messages, ...pending];
    if (!ticket.isActive) {
      _timer?.cancel();
      unawaited(_clear());
      CommunityLoggers.support.event(
        Level.INFO,
        'Guest support ticket finished',
        fields: {'ticketId': ticket.id, 'status': ticket.status},
      );
      emit(
        state.copyWith(
          phase: GuestSupportPhase.ended,
          token: null,
          ticket: ticket,
          messages: messages,
          reconnecting: false,
          endReason: ticket.status == SupportStatus.resolved
              ? GuestSupportEndReason.resolved
              : GuestSupportEndReason.closed,
        ),
      );
      return;
    }
    if (token.expiresAt != state.token?.expiresAt) unawaited(_write(token));
    emit(
      state.copyWith(
        phase: GuestSupportPhase.chat,
        token: token,
        ticket: ticket,
        messages: messages,
        reconnecting: false,
      ),
    );
    if (fresh) _schedule();
  }

  Future<bool> send(String body) async {
    final token = state.token;
    final ticket = state.ticket;
    final text = lowercaseMentions(body.trim());
    if (token == null || ticket == null || !state.canSend || state.sending || !isGuestMessageValid(text)) {
      return false;
    }
    final clientId = _uuid.v4();
    final local = ChatMessage(
      id: 'local-$clientId',
      roomId: ticket.roomId,
      body: text,
      clientId: clientId,
      createdAt: _clock().toUtc(),
      status: MessageStatus.sending,
      senderRole: SenderRole.customer,
      ticketId: ticket.id,
    );
    emit(state.copyWith(sending: true, messages: [...state.messages, local]));
    try {
      final sent = await _repository.send(token.token, body: text, clientId: clientId);
      if (isClosed) return true;
      final already = state.messages.any((m) => m.id == sent.id);
      emit(
        state.copyWith(
          sending: false,
          messages: [
            for (final m in state.messages)
              if (m.clientId == clientId && m.isLocal) ...[if (!already) sent] else m,
          ],
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;
      final kind = guestSupportErrorOf(e);
      emit(
        state.copyWith(
          sending: false,
          messages: [
            for (final m in state.messages)
              if (m.clientId == clientId && m.isLocal)
                m.copyWith(status: MessageStatus.failed, sendError: e is CommunityException ? e : null)
              else
                m,
          ],
          actionError: e,
          actionErrorId: state.actionErrorId + 1,
        ),
      );
      if (kind == GuestSupportError.sessionExpired) await _expire();
      if (kind == GuestSupportError.ticketNotActive) await poll();
      return false;
    }
  }

  Future<bool> retry(String clientId) async {
    final failed = state.messages.where((m) => m.isLocal && m.clientId == clientId).firstOrNull;
    if (failed == null || failed.status != MessageStatus.failed) return false;
    emit(
      state.copyWith(
        messages: [
          for (final m in state.messages)
            if (m != failed) m,
        ],
      ),
    );
    return send(failed.body ?? '');
  }

  void discard(String clientId) => emit(
    state.copyWith(
      messages: [
        for (final m in state.messages)
          if (!(m.isLocal && m.clientId == clientId)) m,
      ],
    ),
  );

  Future<void> end() async {
    final token = state.token;
    if (token == null || state.ending) return;
    _timer?.cancel();
    emit(state.copyWith(ending: true));
    SupportTicket? ended;
    try {
      ended = await _repository.end(token.token);
    } catch (e) {
      if (isClosed) return;
      if (guestSupportErrorOf(e) != GuestSupportError.sessionExpired) {
        emit(state.copyWith(ending: false, actionError: e, actionErrorId: state.actionErrorId + 1));
        _schedule();
        return;
      }
    }
    await _clear();
    if (isClosed) return;
    emit(
      state.copyWith(
        phase: GuestSupportPhase.ended,
        token: null,
        ticket: ended ?? state.ticket?.copyWith(status: SupportStatus.closed),
        ending: false,
        reconnecting: false,
        endReason: GuestSupportEndReason.ended,
      ),
    );
  }

  Future<void> restart() async {
    _timer?.cancel();
    _failures = 0;
    await _clear();
    if (isClosed) return;
    final config = state.config;
    emit(
      GuestSupportState(
        phase: config == null
            ? GuestSupportPhase.loading
            : (config.enabled ? GuestSupportPhase.form : GuestSupportPhase.disabled),
        config: config,
        actionErrorId: state.actionErrorId,
      ),
    );
    if (config == null) await _loadConfig();
  }

  Future<void> _expire() async {
    _timer?.cancel();
    await _clear();
    if (isClosed) return;
    CommunityLoggers.support.info('Guest support session expired');
    emit(
      state.copyWith(
        phase: GuestSupportPhase.ended,
        token: null,
        sending: false,
        ending: false,
        reconnecting: false,
        endReason: GuestSupportEndReason.expired,
      ),
    );
  }

  Future<GuestSupportToken?> _read() async {
    try {
      return await _store.read();
    } catch (e) {
      CommunityLoggers.support.warning('Guest support session store could not be read', e);
      return null;
    }
  }

  Future<void> _write(GuestSupportToken token) async {
    try {
      await _store.write(token);
    } catch (e) {
      CommunityLoggers.support.warning('Guest support session store could not be written', e);
    }
  }

  Future<void> _clear() async {
    try {
      await _store.clear();
    } catch (e) {
      CommunityLoggers.support.warning('Guest support session store could not be cleared', e);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
