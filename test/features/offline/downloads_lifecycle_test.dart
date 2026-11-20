import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/core/storage/memory_offline_store.dart';

void main() {
  final expiresAt = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': 'u', 'exp': expiresAt}))).replaceAll('=', '');
  late Map<String, String> user;
  late int clears;

  setUp(() {
    user = {'id': 'u-1', 'username': 'budi_santoso'};
    clears = 0;
  });

  RendezvousCommunity community() {
    final instance = RendezvousCommunity.create(
      supabaseUrl: 'http://api.test',
      anonKey: 'anon',
      tokenProvider: () async => 'olt-host',
      trackDelivery: false,
      offlineStores: MemoryOfflineStoreFactory(),
      imageDiskCache: const NoImageDiskCache(),
      clearDownloads: () async => clears++,
      httpClient: MockClient((request) async {
        return switch (request.url.path) {
          '/bridge/v1/exchange' => http.Response(
            jsonEncode({
              'access_token': 'eyJhbGciOiJIUzI1NiJ9.$payload.c2lnbmF0dXJl',
              'expires_at': expiresAt,
              'user': user,
            }),
            200,
            request: request,
          ),
          '/rest/v1/rpc/delete_my_account' => http.Response('', 204, request: request),
          _ => http.Response('[]', 200, request: request),
        };
      }),
    );
    addTearDown(instance.dispose);
    return instance;
  }

  test('files left from an earlier run are cleared when the package starts', () async {
    community();
    await pumpEventQueue();

    expect(clears, 1);
  });

  test('signing out clears opened attachments', () async {
    final c = community();
    await c.ensureSignedIn();
    await pumpEventQueue();
    final before = clears;

    await c.signOut();

    expect(clears, before + 1);
  });

  test('deleting the account clears opened attachments', () async {
    final c = community();
    await c.ensureSignedIn();
    await pumpEventQueue();
    final before = clears;

    await c.deleteMyAccount();

    expect(clears, before + 1);
  });

  test('clearing the local cache clears opened attachments', () async {
    final c = community();
    await c.ensureSignedIn();
    await pumpEventQueue();
    final before = clears;

    await c.clearLocalCache();

    expect(clears, before + 1);
  });

  test('a different user signing in clears the previous user attachments', () async {
    final c = community();
    await c.ensureSignedIn();
    await pumpEventQueue();
    final before = clears;

    await c.signOut();
    user = {'id': 'u-2', 'username': 'sari'};
    await c.ensureSignedIn();
    await pumpEventQueue();

    expect(clears, greaterThan(before));
  });
}
