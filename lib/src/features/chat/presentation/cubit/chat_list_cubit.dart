import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/network/community_connectivity.dart';
import 'package:rendezvous_community/src/core/network/realtime_status.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/analytics/domain/services/community_analytics.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_events.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_preview.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_cache_repository.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/room_preview_repository.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/stock_preview_schedule.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'chat_list_cubit.freezed.dart';

@freezed
abstract class ChatListState with _$ChatListState {
  const factory ChatListState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(<ChatRoom>[]) List<ChatRoom> rooms,
    String? nextCursor,
    @Default(false) bool loadingMore,
    @Default(<String, Set<String>>{}) Map<String, Set<String>> presence,
    @Default(<String, Map<String, UserSummary>>{}) Map<String, Map<String, UserSummary>> typing,
    UserSummary? me,
    Object? error,
    @Default(false) bool stale,
    Object? actionError,
    @Default(0) int actionErrorId,
  }) = _ChatListState;

  const ChatListState._();

  bool isOnline(ChatRoom room) {
    final other = room.otherUser;
    return other != null && (presence[room.id]?.contains(other.id) ?? false);
  }

  List<UserSummary> typingIn(String roomId) => typing[roomId]?.values.toList() ?? const [];
}

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({
    required this._chat,
    required this._me,
    this.pageSize = 30,
    this.maxWatchedRooms = 30,
    this.typingTimeout = const Duration(seconds: 6),
    this.previewPollInterval = const Duration(seconds: 15),
    this._cache,
    this._connectivity,
    this._random,
    this._clock,
    this._analytics,
  }) : super(const ChatListState());

  final ChatRepository _chat;
  final CommunityAnalytics? _analytics;
  final Future<UserSummary> Function() _me;
  final ChatCacheRepository? _cache;
  final CommunityConnectivity? _connectivity;
  StreamSubscription<bool>? _onlineChanges;
  final int pageSize;
  final int maxWatchedRooms;
  final Duration typingTimeout;
  final Duration previewPollInterval;
  final Random? _random;
  final DateTime Function()? _clock;
  late final StockPreviewSchedule _previewSchedule = StockPreviewSchedule(
    _pollPreviews,
    interval: previewPollInterval,
    random: _random,
    clock: _clock,
  );
  StreamSubscription<void>? _resumes;
  bool _visible = false;
  bool _previewsUnsupported = false;
  StreamSubscription<RoomActivity>? _activity;
  StreamSubscription<RoomRemoval>? _removals;
  StreamSubscription<RoomSignal>? _signals;
  Set<String> _watched = const {};
  final _channels = <String, RealtimeStatus>{};
  final _typingTimers = <String, Timer>{};
  Timer? _debounce;

  Future<void> load() async {
    if (!(state.status == LoadStatus.ready && state.stale)) {
      emit(state.copyWith(status: LoadStatus.loading, error: null));
      _onlineChanges ??= _connectivity?.changes.listen((online) {
        if (isClosed) return;
        _updatePreviewPolling();
        if (online && state.stale) unawaited(load());
      });
      _resumes ??= _connectivity?.resumes.listen((_) => _previewSchedule.nudge());
      await _showCached();
    }
    try {
      final me = await _me();
      final page = await _chat.getRooms(limit: pageSize);
      if (isClosed) return;
      emit(
        state.copyWith(status: LoadStatus.ready, rooms: page.items, nextCursor: page.nextCursor, me: me, stale: false),
      );
      _activity ??= _chat.watchRoomActivity().listen(_onActivity, onError: (Object _) {});
      _removals ??= _chat.watchRoomRemovals().listen((r) => _dropRoom(r.roomId), onError: (Object _) {});
      _watchRooms();
    } catch (e) {
      if (isClosed || (state.status == LoadStatus.ready && state.stale)) return;
      emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> _showCached() async {
    final cache = _cache;
    if (cache == null) return;
    final rooms = await cache.cachedRooms();
    if (rooms.isEmpty || isClosed || state.status == LoadStatus.ready) return;
    final me = await cache.cachedUser();
    if (isClosed || state.status == LoadStatus.ready) return;
    emit(state.copyWith(status: LoadStatus.ready, rooms: rooms, me: me, nextCursor: null, stale: true));
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.status != LoadStatus.ready) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _chat.getRooms(cursor: cursor, limit: pageSize);
      if (isClosed) return;
      final known = {for (final r in state.rooms) r.id};
      emit(
        state.copyWith(
          rooms: [...state.rooms, ...page.items.where((r) => !known.contains(r.id))],
          nextCursor: page.nextCursor,
          loadingMore: false,
        ),
      );
      _watchRooms();
    } catch (_) {
      if (!isClosed) emit(state.copyWith(loadingMore: false));
    }
  }

  Future<void> refresh() async {
    try {
      final fresh = await _chat.getRooms(limit: max(pageSize, state.rooms.length));
      if (isClosed) return;
      final ids = {for (final r in fresh.items) r.id};
      final boundary = fresh.items.lastOrNull;
      final beyond = fresh.hasMore && boundary != null
          ? [
              for (final r in state.rooms)
                if (!ids.contains(r.id) && r.compareListOrder(boundary) > 0) r,
            ]
          : const <ChatRoom>[];
      emit(
        state.copyWith(
          rooms: [...fresh.items, ...beyond],
          nextCursor: beyond.isEmpty ? fresh.nextCursor : state.nextCursor,
          status: LoadStatus.ready,
          stale: false,
        ),
      );
      _watchRooms();
    } catch (_) {}
  }

  void markOpened(String roomId) =>
      emit(state.copyWith(rooms: [for (final r in state.rooms) r.id == roomId ? r.copyWith(unreadCount: 0) : r]));

  Future<bool> hideRoom(ChatRoom room) async {
    if (!room.canHide) return false;
    final ok = await _removeRoom(room, () => _chat.hideRoom(room.id));
    if (ok) _analytics?.record(CommunityAnalyticsEvent.hideRoom, {'room_id': room.id, 'type': room.type.name});
    return ok;
  }

  Future<bool> leaveRoom(ChatRoom room) async =>
      room.canLeave && await _removeRoom(room, () => _chat.leaveRoom(room.id));

  Future<bool> deleteGroup(ChatRoom room) async {
    if (!room.canDeleteGroup) return false;
    final ok = await _removeRoom(room, () => _chat.deleteGroup(room.id));
    if (ok) _analytics?.record(CommunityAnalyticsEvent.deleteGroup, {'room_id': room.id, 'type': room.type.name});
    return ok;
  }

  Future<bool> _removeRoom(ChatRoom room, Future<void> Function() action) async {
    if (!state.rooms.any((r) => r.id == room.id)) return false;
    _dropRoom(room.id);
    try {
      await action();
      return true;
    } catch (e) {
      if (isClosed) return false;
      final rooms = [...state.rooms.where((r) => r.id != room.id), room]..sort((a, b) => a.compareListOrder(b));
      emit(state.copyWith(rooms: rooms, actionError: e, actionErrorId: state.actionErrorId + 1));
      _watchRooms();
      return false;
    }
  }

  void _dropRoom(String roomId) {
    if (isClosed || !state.rooms.any((r) => r.id == roomId)) return;
    emit(
      state.copyWith(
        rooms: [
          for (final r in state.rooms)
            if (r.id != roomId) r,
        ],
      ),
    );
    _watchRooms();
  }

  void _applyEditedPreview(String roomId, String preview) {
    if (!state.rooms.any((r) => r.id == roomId && r.lastMessagePreview != preview)) return;
    emit(
      state.copyWith(
        rooms: [for (final r in state.rooms) r.id == roomId ? r.copyWith(lastMessagePreview: preview) : r],
      ),
    );
  }

  void _onActivity(RoomActivity activity) {
    final sender = activity.senderId;
    if (sender != null) _removeTyping(activity.roomId, sender);
    _scheduleRefresh();
  }

  void _watchRooms() {
    _updatePreviewPolling();
    final me = state.me;
    if (me == null) return;
    final ids = {for (final r in state.rooms.where((r) => r.tracksReceipts).take(maxWatchedRooms)) r.id};
    if (ids.length == _watched.length && ids.containsAll(_watched)) return;
    _watched = ids;
    final previous = _signals;
    _signals = _chat.watchRoomSignals(ids, me: me).listen(_onSignal, onError: (Object _) {});
    unawaited(previous?.cancel());
  }

  RoomPreviewRepository? get _previews => switch (_chat) {
    final RoomPreviewRepository previews => previews,
    _ => null,
  };

  void setVisible(bool visible) {
    if (isClosed || visible == _visible) return;
    _visible = visible;
    _updatePreviewPolling();
  }

  List<String> get _stockRoomIds => [for (final r in state.rooms.where((r) => r.type == RoomType.stock).take(50)) r.id];

  void _updatePreviewPolling() {
    final active =
        _visible &&
        !_previewsUnsupported &&
        _previews != null &&
        state.status == LoadStatus.ready &&
        (_connectivity?.isOnline ?? true) &&
        _stockRoomIds.isNotEmpty;
    active ? _previewSchedule.resume() : _previewSchedule.pause();
  }

  Future<void> _pollPreviews() async {
    final ids = _stockRoomIds;
    final chat = _previews;
    if (isClosed || chat == null || ids.isEmpty) return;
    try {
      final page = await chat.getRoomPreviews(ids);
      if (isClosed) return;
      _previewSchedule.serverInterval = page.pollInterval;
      _applyPreviews(page.previews);
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202' || isClosed) return;
      _previewsUnsupported = true;
      _previewSchedule.pause();
    } catch (_) {}
  }

  void _applyPreviews(List<RoomPreview> previews) {
    final byId = {for (final p in previews) p.roomId: p};
    final rooms = [for (final room in state.rooms) _withPreview(room, byId[room.id])];
    if (!rooms.indexed.any((e) => !identical(e.$2, state.rooms[e.$1]))) return;
    rooms.sort((a, b) => a.compareListOrder(b));
    emit(state.copyWith(rooms: rooms));
  }

  ChatRoom _withPreview(ChatRoom room, RoomPreview? preview) {
    if (preview == null) return room;
    final at = preview.lastMessageAt;
    final previous = room.lastMessageAt;
    if (at != null && previous != null && at.isBefore(previous)) return room;
    final moved = at != null && (previous == null || at.isAfter(previous));
    if (!moved && preview.unreadCount == room.unreadCount) return room;
    if (!moved) return room.copyWith(unreadCount: preview.unreadCount);
    final mine = preview.lastMessageSenderId != null && preview.lastMessageSenderId == state.me?.id;
    return room.copyWith(
      lastMessageAt: at,
      lastMessagePreview: preview.lastMessagePreview,
      lastMessageSenderId: preview.lastMessageSenderId,
      lastMessageStatus: mine ? ReceiptStatus.sent : null,
      unreadCount: preview.unreadCount,
    );
  }

  void _onSignal(RoomSignal signal) {
    if (isClosed) return;
    switch (signal) {
      case RoomTyping(:final roomId, :final user, :final isTyping):
        isTyping ? _addTyping(roomId, user) : _removeTyping(roomId, user.id);
      case RoomReceipt(:final roomId, :final receipt):
        _applyReceipt(roomId, receipt);
      case RoomPresence(:final roomId, :final userIds):
        emit(state.copyWith(presence: {...state.presence, roomId: userIds}));
      case RoomConnection(:final roomId, :final status):
        final previous = _channels[roomId];
        _channels[roomId] = status;
        if (status == RealtimeStatus.connected && previous != null && previous != status) _scheduleRefresh();
      case RoomPreviewEdited(:final roomId, :final preview):
        _applyEditedPreview(roomId, preview);
      case RoomDeleted(:final roomId):
        _dropRoom(roomId);
      case RoomReaction() || RoomStateSignal() || RoomMessageHidden() || RoomTypingSummary():
        return;
    }
  }

  void _applyReceipt(String roomId, MemberReceipt receipt) {
    final room = state.rooms.where((r) => r.id == roomId).firstOrNull;
    final sentAt = room?.lastMessageAt;
    if (room == null || sentAt == null || room.lastMessageSenderId != state.me?.id) return;
    if (room.type != RoomType.direct) return _scheduleRefresh();
    final status = receiptStatus(sentAt, [receipt]);
    if (status.index <= (room.lastMessageStatus?.index ?? 0)) return;
    emit(
      state.copyWith(rooms: [for (final r in state.rooms) r.id == roomId ? r.copyWith(lastMessageStatus: status) : r]),
    );
  }

  void _addTyping(String roomId, UserSummary user) {
    final key = '$roomId/${user.id}';
    _typingTimers[key]?.cancel();
    _typingTimers[key] = Timer(typingTimeout, () => _removeTyping(roomId, user.id));
    emit(
      state.copyWith(
        typing: {
          ...state.typing,
          roomId: {...?state.typing[roomId], user.id: user},
        },
      ),
    );
  }

  void _removeTyping(String roomId, String userId) {
    final users = state.typing[roomId];
    if (isClosed || users == null || !users.containsKey(userId)) return;
    _typingTimers.remove('$roomId/$userId')?.cancel();
    final rest = {...users}..remove(userId);
    emit(state.copyWith(typing: {...state.typing, roomId: rest}..removeWhere((_, v) => v.isEmpty)));
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), refresh);
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    _previewSchedule.dispose();
    await _resumes?.cancel();
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    await _activity?.cancel();
    await _removals?.cancel();
    await _signals?.cancel();
    await _onlineChanges?.cancel();
    return super.close();
  }
}
