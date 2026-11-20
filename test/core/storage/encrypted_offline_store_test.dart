import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rendezvous_community/src/core/storage/offline_store.dart';
import 'package:rendezvous_community/src/core/storage/platform_offline_stores_io.dart';

const _keyA = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
const _keyB = 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210';
const _secret = 'rekening 1234567890 atas nama Budi';

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('rc-encrypted-'));

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  FileOfflineStoreFactory factory([String? key]) =>
      FileOfflineStoreFactory(root: () async => root, encryptionKey: key == null ? null : () async => key);

  File cacheFile(String key) => File(p.join(root.path, 'rendezvous_community', '$key.sqlite'));

  Future<void> remember(OfflineStoreFactory stores, {String text = _secret}) async {
    final store = await stores.open('u1');
    await store.writeMeta('note', {'text': text});
    await store.close();
  }

  Future<Map<String, dynamic>?> recall(OfflineStoreFactory stores) async {
    final store = await stores.open('u1');
    final value = await store.readMeta('note');
    await store.close();
    return value;
  }

  test('an encrypted cache file holds no readable chat text', () async {
    await remember(factory(_keyA));

    final bytes = cacheFile('u1').readAsBytesSync();
    expect(bytes, isNotEmpty);
    expect(isPlainSqliteFile(cacheFile('u1')), isFalse);
    expect(latin1.decode(bytes).contains('rekening'), isFalse);
  });

  test('the same key reads the cached data back', () async {
    await remember(factory(_keyA));

    expect(await recall(factory(_keyA)), {'text': _secret});
  });

  test('a different key resets the cache instead of failing', () async {
    await remember(factory(_keyA));

    expect(await recall(factory(_keyB)), isNull);
    await remember(factory(_keyB), text: 'fresh');
    expect(await recall(factory(_keyB)), {'text': 'fresh'});
  });

  test('an older unencrypted cache file is replaced by an encrypted one', () async {
    await remember(factory());
    expect(isPlainSqliteFile(cacheFile('u1')), isTrue);

    expect(await recall(factory(_keyA)), isNull);
    expect(isPlainSqliteFile(cacheFile('u1')), isFalse);
  });

  test('an invalid key keeps the cache in memory and writes nothing to disk', () async {
    final stores = factory('not-a-key');
    final store = await stores.open('u1');
    await store.writeMeta('note', {'text': _secret});

    expect(await store.readMeta('note'), {'text': _secret});
    expect(cacheFile('u1').existsSync(), isFalse);
    await store.close();
  });

  test('without a key the cache stays a plain database as before', () async {
    await remember(factory());

    expect(isPlainSqliteFile(cacheFile('u1')), isTrue);
    expect(await recall(factory()), {'text': _secret});
  });
}
