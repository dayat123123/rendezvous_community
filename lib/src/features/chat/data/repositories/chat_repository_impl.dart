import 'dart:async';

import 'package:rendezvous_community/src/core/network/realtime_gateway.dart';
import 'package:rendezvous_community/src/core/network/shared_stream.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/chat/data/local/chat_local_cache.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/chat/data/realtime/room_channel_hub.dart';
import 'package:rendezvous_community/src/features/chat/data/realtime/room_connection.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/message_pages.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_events.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_info.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_preview.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/message_index_repository.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/message_info_repository.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/room_preview_repository.dart';
import 'package:rendezvous_community/src/shared/data/models/attachment_model.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepositoryImpl
    implements ChatRepository, MessageIndexRepository, RoomPreviewRepository, MessageInfoRepository {
  ChatRepositoryImpl(this._api, [this._realtime, this._cache]);

  final SocialRemoteDataSource _api;
  final RealtimeGateway? _realtime;
  final ChatLocalCache? _cache;
  final _roomTypes = <String, RoomType>{};
  late final RoomChannelHub? _hub = _realtime == null
      ? null
      : RoomChannelHub(
          _realtime,
          typing: (roomId, {required isTyping}) async {
            await _api.rpcValue('send_typing', {'p_room_id': roomId, 'p_typing': isTyping});
          },
          presenceFor: _tracksPresence,
        );
  late final SharedStream<RoomActivity> _activity = SharedStream(_createActivityStream);
  late final SharedStream<RoomRemoval> _removals = SharedStream(_createRemovalStream);
  late final SharedStream<RoomMuteNotice> _muteNotices = SharedStream(_createMuteNoticeStream);
  final _unreadChanges = StreamController<void>.broadcast();
  final _localRemovals = StreamController<RoomRemoval>.broadcast();

  @override
  Future<Paged<ChatRoom>> getRooms({String? cursor, int limit = 30}) async {
    final rows = await _api.rpcRows('get_my_rooms', {'p_cursor': cursor, 'p_limit': limit});
    final models = [for (final row in rows) RoomSummaryModel.fromJson(row)];
    if (cursor == null) await _cache?.saveRooms(rows);
    return Paged([
      for (final model in models) _remember(model.toEntity()),
    ], nextCursor: models.length < limit ? null : models.last.cursor);
  }

  @override
  Future<ChatRoom?> getRoom(String roomId) async {
    final rows = await _api.rpcRows('get_my_room', {'p_room_id': roomId});
    return rows.isEmpty ? null : _remember(RoomSummaryModel.fromJson(rows.first).toEntity());
  }

  @override
  Future<RoomPreviewPage> getRoomPreviews(List<String> roomIds) async {
    if (roomIds.isEmpty) return const RoomPreviewPage([]);
    final value = await _api.rpcValue('get_room_previews', {'p_room_ids': roomIds.take(50).toList()});
    return value is Map<String, dynamic> ? parseRoomPreviewPage(value) : const RoomPreviewPage([]);
  }

  ChatRoom _remember(ChatRoom room) {
    _roomTypes[room.id] = room.type;
    return room;
  }

  bool _tracksPresence(String roomId) {
    final type = _roomTypes[roomId];
    return type == null || type == RoomType.direct;
  }

  @override
  Future<Paged<ChatMessage>> getMessages(String roomId, {String? cursor, int limit = 30}) async {
    final rows = await _api.rpcRows('get_messages', {'p_room_id': roomId, 'p_cursor': cursor, 'p_limit': limit});
    final items = [for (final row in rows) ChatMessageModel.fromJson(row).toEntity()];
    final hasMore = items.length >= limit;
    await _cache?.saveMessages(
      roomId,
      rows,
      items,
      window: olderPageWindow(items, cursor: cursor, hasMore: hasMore),
    );
    return Paged(items, nextCursor: hasMore ? items.last.cursor : null);
  }

  @override
  Future<Paged<ChatMessage>> getMessagesAfter(String roomId, String cursor, {int limit = 100}) async {
    final rows = await _api.rpcRows('get_messages', {'p_room_id': roomId, 'p_after': cursor, 'p_limit': limit});
    final items = [for (final row in rows) ChatMessageModel.fromJson(row).toEntity()];
    await _cache?.saveMessages(roomId, rows, items);
    return newerPage(items, limit);
  }

  @override
  Future<MessageIdPage> getMessageIdsAfter(String roomId, String cursor, {int limit = 1000}) async {
    final value = await _api.rpcValue('get_message_ids', {'p_room_id': roomId, 'p_after': cursor, 'p_limit': limit});
    final data = value is Map ? value : const {};
    final ids = data['ids'];
    return MessageIdPage(
      [if (ids is List) ...ids.whereType<String>()],
      last: data['last'] as String?,
      hasMore: data['more'] == true,
    );
  }

  @override
  Future<List<ChatMessage>> getMessagesByIds(String roomId, List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _api.rpcRows('get_messages_by_ids', {'p_room_id': roomId, 'p_ids': ids});
    final items = [for (final row in rows) ChatMessageModel.fromJson(row).toEntity()];
    await _cache?.saveMessages(roomId, rows, items);
    return items;
  }

  @override
  Future<ChatMessage> sendMessage(
    String roomId, {
    required String body,
    required String clientId,
    String? replyToId,
    List<Attachment> attachments = const [],
  }) async {
    final rows = await _api.rpcRows('send_message', {
      'p_room_id': roomId,
      'p_body': body,
      'p_client_id': clientId,
      'p_reply_to_id': replyToId,
      'p_attachments': [for (final a in attachments) AttachmentModel.fromEntity(a).toJson()],
    });
    final sent = ChatMessageModel.fromJson(rows.first).toEntity();
    await _cache?.saveMessages(roomId, [rows.first], [sent]);
    return sent;
  }

  @override
  Future<void> deleteMessage(String messageId) => _api.rpcValue('delete_message', {'p_message_id': messageId});

  @override
  Future<ChatMessage> editMessage(String messageId, String body) async {
    final rows = await _api.rpcRows('edit_message', {'p_message_id': messageId, 'p_body': body});
    final edited = ChatMessageModel.fromJson(rows.first).toEntity();
    await _cache?.saveMessages(edited.roomId, [rows.first], [edited]);
    return edited;
  }

  @override
  Future<void> markRoomRead(String roomId) async {
    await _api.rpcValue('mark_room_read', {'p_room_id': roomId});
    _unreadChanged();
  }

  @override
  Future<int> markDelivered({List<String>? roomIds}) async =>
      ((await _api.rpcValue('mark_rooms_delivered', {'p_room_ids': roomIds})) as num?)?.toInt() ?? 0;

  @override
  Future<Map<String, int>> unreadCounts() async {
    final rows = await _api.rpcRows('get_unread_counts');
    return {for (final row in rows) row['room_id'] as String: (row['unread_count'] as num).toInt()};
  }

  @override
  Future<int> unreadChatCount() async => ((await _api.rpcValue('get_unread_chat_count')) as num?)?.toInt() ?? 0;

  @override
  Stream<void> watchUnreadChanges() => _unreadChanges.stream;

  void _unreadChanged() {
    if (!_unreadChanges.isClosed) _unreadChanges.add(null);
  }

  @override
  Future<String> getOrCreateDirectRoom(String otherUserId) async =>
      (await _api.rpcValue('get_or_create_direct_room', {'p_other_user_id': otherUserId}))! as String;

  @override
  Future<String> createGroupRoom(String name, List<String> memberIds) async =>
      (await _api.rpcValue('create_group_room', {'p_name': name, 'p_member_ids': memberIds}))! as String;

  @override
  Future<String> joinStockRoom(String stockCode) async =>
      (await _api.rpcValue('join_stock_room', {'p_stock_code': stockCode}))! as String;

  @override
  Future<void> leaveRoom(String roomId) async {
    await _api.rpcValue('leave_room', {'p_room_id': roomId});
    await _cache?.forgetRoom(roomId);
    _unreadChanged();
    _removedLocally(roomId, RoomRemovalReason.left);
  }

  @override
  Future<void> hideRoom(String roomId) async {
    await _api.rpcValue('hide_room', {'p_room_id': roomId});
    await _cache?.forgetRoom(roomId);
    _unreadChanged();
    _removedLocally(roomId, RoomRemovalReason.hidden);
  }

  @override
  Future<void> deleteGroup(String roomId) async {
    await _api.rpcValue('delete_group', {'p_room_id': roomId});
    await _cache?.forgetRoom(roomId);
    _unreadChanged();
    _removedLocally(roomId, RoomRemovalReason.groupDeleted);
  }

  void _removedLocally(String roomId, RoomRemovalReason reason) {
    if (!_localRemovals.isClosed) _localRemovals.add(RoomRemoval(roomId: roomId, reason: reason));
  }

  @override
  Future<void> setMuted(String roomId, {required bool muted}) async {
    final me = await _api.requireUserId();
    await _api.update('chat_members', {'muted': muted}, {'room_id': roomId, 'user_id': me});
    _unreadChanged();
  }

  @override
  Future<MessageInfo> getMessageInfo(String messageId) async {
    final value = await _api.rpcValue('get_message_info', {'p_message_id': messageId});
    return messageInfoFromJson(Map<String, dynamic>.from(value! as Map));
  }

  @override
  Future<List<RoomMember>> getMembers(String roomId) async {
    final rows = await _api.rpcRows('get_room_members', {'p_room_id': roomId});
    return [for (final row in rows) RoomMemberModel.fromJson(row).toEntity()];
  }

  @override
  ChatRoomConnection connectRoom(String roomId, {required UserSummary me}) {
    final realtime = _realtime;
    final hub = _hub;
    if (realtime == null || hub == null) return NoopRoomConnection();
    return SupabaseRoomConnection(
      hub,
      roomId,
      me,
      muteNotices: _muteNotices.stream,
      fetchAfter: (cursor) => getMessagesAfter(roomId, cursor),
    );
  }

  @override
  Stream<RoomActivity> watchRoomActivity() => _realtime == null ? const Stream.empty() : _activity.stream;

  @override
  Stream<RoomRemoval> watchRoomRemovals() => Stream.multi((multi) {
    final subscriptions = [
      _localRemovals.stream.listen(multi.add, onError: multi.addError),
      if (_realtime != null) _removals.stream.listen(multi.add, onError: multi.addError),
    ];
    multi.onCancel = () => Future.wait([for (final s in subscriptions) s.cancel()]);
  });

  @override
  Stream<RoomSignal> watchRoomSignals(Set<String> roomIds, {required UserSummary me}) {
    final hub = _hub;
    if (hub == null || roomIds.isEmpty) return const Stream.empty();
    return hub.watchAll(roomIds, me);
  }

  Future<void> dispose() async {
    await _activity.close();
    await _removals.close();
    await _localRemovals.close();
    await _muteNotices.close();
    await _unreadChanges.close();
  }

  Stream<RoomActivity> _createActivityStream() async* {
    final me = await _api.requireUserId();
    yield* _realtime!
        .serverBroadcasts('user:$me', event: 'room_activity')
        .map(parseRoomActivity)
        .where((activity) => activity != null)
        .cast<RoomActivity>();
  }

  Stream<RoomRemoval> _createRemovalStream() async* {
    final me = await _api.requireUserId();
    yield* _realtime!
        .serverBroadcasts('user:$me', event: 'room_removed')
        .map(parseRoomRemoval)
        .where((removal) => removal != null)
        .cast<RoomRemoval>()
        .asyncMap((removal) async {
          await _cache?.forgetRoom(removal.roomId);
          _unreadChanged();
          return removal;
        });
  }

  Stream<RoomMuteNotice> _createMuteNoticeStream() async* {
    final me = await _api.requireUserId();
    yield* _realtime!
        .tableChanges(
          table: 'notifications',
          event: PostgresChangeEvent.insert,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: me),
        )
        .map((payload) => parseRoomMuteNotice(payload.newRecord))
        .where((notice) => notice != null)
        .cast<RoomMuteNotice>();
  }
}
