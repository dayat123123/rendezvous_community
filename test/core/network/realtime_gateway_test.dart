import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/src/core/network/realtime_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockClient extends Mock implements SupabaseClient {}

class _MockChannel extends Mock implements RealtimeChannel {}

class _Gateway extends RealtimeGateway {
  _Gateway() : super(_MockClient());

  final opened = <String>[];
  final removed = <RealtimeChannel>[];
  final handlers = <void Function(Map<String, dynamic>)>[];

  @override
  RealtimeChannel privateChannel(String topic, {String? presenceKey}) {
    opened.add(topic);
    final channel = _MockChannel();
    when(
      () => channel.onBroadcast(
        event: any(named: 'event'),
        callback: any(named: 'callback'),
      ),
    ).thenAnswer((call) {
      final event = call.namedArguments[#event] as String;
      final callback = call.namedArguments[#callback] as void Function(Map<String, dynamic>);
      handlers.add((payload) {
        if (event == '*' || event == payload['event']) callback(payload);
      });
      return channel;
    });
    when(() => channel.subscribe(any())).thenReturn(channel);
    return channel;
  }

  @override
  Future<void> remove(RealtimeChannel channel) async => removed.add(channel);

  void broadcast(String event, Map<String, dynamic> payload) {
    for (final handler in [...handlers]) {
      handler({'type': 'broadcast', 'event': event, 'payload': payload});
    }
  }
}

void main() {
  test('two events on the same topic share one channel', () async {
    final gateway = _Gateway();
    final activity = <Map<String, dynamic>>[];
    final removals = <Map<String, dynamic>>[];
    final a = gateway.serverBroadcasts('user:u-me', event: 'room_activity').listen(activity.add);
    final b = gateway.serverBroadcasts('user:u-me', event: 'room_removed').listen(removals.add);
    await pumpEventQueue();

    expect(gateway.opened, ['user:u-me']);

    gateway
      ..broadcast('room_activity', {'room_id': 'r-1'})
      ..broadcast('room_removed', {'room_id': 'r-2'});
    await pumpEventQueue();

    expect(activity, [
      {'room_id': 'r-1'},
    ]);
    expect(removals, [
      {'room_id': 'r-2'},
    ]);

    await a.cancel();
    expect(gateway.removed, isEmpty);
    gateway.broadcast('room_removed', {'room_id': 'r-3'});
    await pumpEventQueue();
    expect(removals.length, 2);

    await b.cancel();
    expect(gateway.removed, hasLength(1));
  });

  test('a topic opened again after it was released gets a new channel', () async {
    final gateway = _Gateway();
    final first = gateway.serverBroadcasts('user:u-me', event: 'room_activity').listen((_) {});
    await pumpEventQueue();
    await first.cancel();
    final received = <Map<String, dynamic>>[];
    final second = gateway.serverBroadcasts('user:u-me', event: 'room_activity').listen(received.add);
    await pumpEventQueue();

    expect(gateway.opened, ['user:u-me', 'user:u-me']);
    gateway.broadcast('room_activity', {'room_id': 'r-1'});
    await pumpEventQueue();
    expect(received, hasLength(1));
    await second.cancel();
  });
}
