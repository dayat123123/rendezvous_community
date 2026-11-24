import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/realtime_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeGateway {
  RealtimeGateway(this._client);

  final SupabaseClient _client;
  int _seq = 0;
  final _topics = <String, _SharedTopic>{};

  Stream<PostgresChangePayload> tableChanges({
    required String table,
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
    void Function(RealtimeStatus status)? onStatus,
  }) {
    RealtimeChannel? channel;
    late final StreamController<PostgresChangePayload> controller;
    controller = StreamController<PostgresChangePayload>(
      onListen: () {
        onStatus?.call(RealtimeStatus.connecting);
        final topic = 'olt-$table-${_seq++}';
        channel = _client
            .channel(topic)
            .onPostgresChanges(
              event: event,
              schema: 'public',
              table: table,
              filter: filter,
              callback: (payload) {
                if (!controller.isClosed) controller.add(payload);
              },
            )
            .subscribe((status, error) {
              _logChannelStatus(topic, status, error);
              onStatus?.call(mapSubscribeStatus(status));
            });
      },
      onCancel: () async {
        final ch = channel;
        channel = null;
        if (ch != null) await _client.removeChannel(ch);
        await controller.close();
      },
    );
    return controller.stream;
  }

  RealtimeChannel privateChannel(String topic, {String? presenceKey}) =>
      _client.channel(topic, opts: RealtimeChannelConfig(private: true, key: presenceKey ?? ''));

  Stream<Map<String, dynamic>> serverBroadcasts(
    String topic, {
    required String event,
    void Function(RealtimeStatus status)? onStatus,
  }) {
    late final _BroadcastListener listener;
    late final StreamController<Map<String, dynamic>> controller;
    controller = StreamController<Map<String, dynamic>>(
      onListen: () => _join(topic, listener),
      onCancel: () async {
        await _leave(topic, listener);
        await controller.close();
      },
    );
    listener = _BroadcastListener(event, controller, onStatus);
    return controller.stream;
  }

  void _join(String topic, _BroadcastListener listener) {
    listener.onStatus?.call(RealtimeStatus.connecting);
    final shared = _topics[topic];
    if (shared != null) {
      shared.listeners.add(listener);
      final status = shared.status;
      if (status != null) listener.onStatus?.call(status);
      return;
    }
    final channel = privateChannel(topic);
    final created = _SharedTopic(channel)..listeners.add(listener);
    _topics[topic] = created;
    channel
      ..onBroadcast(
        event: '*',
        callback: (payload) {
          if (!identical(_topics[topic], created)) return;
          final event = payload['event'];
          final data = broadcastPayload(payload);
          for (final l in [...created.listeners]) {
            if (l.event == event && !l.controller.isClosed) l.controller.add(data);
          }
        },
      )
      ..subscribe((status, error) {
        _logChannelStatus(topic, status, error);
        if (!identical(_topics[topic], created)) return;
        final mapped = mapSubscribeStatus(status);
        created.status = mapped;
        for (final l in [...created.listeners]) {
          l.onStatus?.call(mapped);
        }
      });
  }

  Future<void> _leave(String topic, _BroadcastListener listener) async {
    final shared = _topics[topic];
    if (shared != null && shared.listeners.remove(listener) && shared.listeners.isEmpty) {
      _topics.remove(topic);
      await remove(shared.channel);
    }
  }

  Future<void> remove(RealtimeChannel channel) => _client.removeChannel(channel);
}

class _SharedTopic {
  _SharedTopic(this.channel);

  final RealtimeChannel channel;
  final listeners = <_BroadcastListener>[];
  RealtimeStatus? status;
}

class _BroadcastListener {
  _BroadcastListener(this.event, this.controller, this.onStatus);

  final String event;
  final StreamController<Map<String, dynamic>> controller;
  final void Function(RealtimeStatus status)? onStatus;
}

void _logChannelStatus(String channel, RealtimeSubscribeStatus status, Object? error) {
  final (level, message) = switch (status) {
    RealtimeSubscribeStatus.subscribed => (Level.FINE, 'Realtime channel subscribed'),
    RealtimeSubscribeStatus.closed => (Level.FINE, 'Realtime channel closed'),
    RealtimeSubscribeStatus.channelError ||
    RealtimeSubscribeStatus.timedOut => (Level.WARNING, 'Realtime channel interrupted, retrying'),
  };
  CommunityLoggers.realtime.event(level, message, fields: {'channel': channel, 'status': status}, error: error);
}

Map<String, dynamic> broadcastPayload(Map<String, dynamic> payload) {
  final inner = payload['payload'];
  return inner is Map ? Map<String, dynamic>.from(inner) : payload;
}

RealtimeStatus mapSubscribeStatus(RealtimeSubscribeStatus status) => switch (status) {
  RealtimeSubscribeStatus.subscribed => RealtimeStatus.connected,
  RealtimeSubscribeStatus.channelError ||
  RealtimeSubscribeStatus.timedOut ||
  RealtimeSubscribeStatus.closed => RealtimeStatus.reconnecting,
};
