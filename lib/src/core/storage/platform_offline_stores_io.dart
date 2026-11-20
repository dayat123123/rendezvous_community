import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/storage/community_database.dart';
import 'package:rendezvous_community/src/core/storage/drift_offline_store.dart';
import 'package:rendezvous_community/src/core/storage/memory_offline_store.dart';
import 'package:rendezvous_community/src/core/storage/offline_store.dart';

OfflineStoreFactory platformOfflineStores({Future<String> Function()? encryptionKey}) =>
    FileOfflineStoreFactory(encryptionKey: encryptionKey);

final _plainHeader = ascii.encode('SQLite format 3\x00');
final _hexKey = RegExp(r'^[0-9a-fA-F]{64}$');

bool isPlainSqliteFile(File file) {
  if (!file.existsSync()) return false;
  final handle = file.openSync();
  try {
    final header = handle.readSync(_plainHeader.length);
    if (header.length < _plainHeader.length) return false;
    for (var i = 0; i < header.length; i++) {
      if (header[i] != _plainHeader[i]) return false;
    }
    return true;
  } finally {
    handle.closeSync();
  }
}

class FileOfflineStoreFactory implements OfflineStoreFactory {
  FileOfflineStoreFactory({Future<Directory> Function()? root, this._encryptionKey})
    : _root = root ?? getApplicationSupportDirectory;

  static const _folder = 'rendezvous_community';
  static const _extension = '.sqlite';
  static const _sidecars = ['', '-wal', '-shm', '-journal'];

  final Future<Directory> Function() _root;
  final Future<String> Function()? _encryptionKey;
  final _memory = MemoryOfflineStoreFactory();

  Future<Directory> _directory() async {
    final directory = Directory(p.join((await _root()).path, _folder));
    return directory.create(recursive: true);
  }

  Future<File> _file(String key) async => File(p.join((await _directory()).path, '$key$_extension'));

  @override
  Future<List<String>> keys() async {
    final directory = await _directory();
    return [
      for (final entity in directory.listSync().whereType<File>())
        if (entity.path.endsWith(_extension)) p.basenameWithoutExtension(entity.path),
      ...await _memory.keys(),
    ];
  }

  @override
  Future<OfflineStore> open(String key) async {
    final file = await _file(key);
    final encryptionKey = _encryptionKey;
    if (encryptionKey == null) return DriftOfflineStore(CommunityDatabase(NativeDatabase.createInBackground(file)));
    final hex = await encryptionKey();
    if (!_hexKey.hasMatch(hex)) return _inMemory(key, 'Offline cache key is invalid; keeping the cache in memory');
    final store = await _openEncrypted(file, hex) ?? await _resetAndOpen(key, file, hex);
    return store ?? _inMemory(key, 'Offline cache encryption is unavailable; keeping the cache in memory');
  }

  Future<DriftOfflineStore?> _resetAndOpen(String key, File file, String hex) async {
    await _deleteFiles(key);
    CommunityLoggers.offline.event(Level.INFO, 'Offline cache could not be opened with the current key; recreating it');
    return _openEncrypted(file, hex);
  }

  Future<DriftOfflineStore?> _openEncrypted(File file, String hex) async {
    final db = CommunityDatabase(NativeDatabase.createInBackground(file, setup: _applyKey(hex)));
    try {
      await db.customSelect('SELECT count(*) FROM sqlite_master').get();
    } catch (_) {
      await db.close();
      return null;
    }
    if (!isPlainSqliteFile(file)) return DriftOfflineStore(db);
    await db.close();
    return null;
  }

  Future<OfflineStore> _inMemory(String key, String reason) async {
    await _deleteFiles(key);
    CommunityLoggers.offline.event(Level.WARNING, reason);
    return _memory.open(key);
  }

  Future<void> _deleteFiles(String key) async {
    final base = (await _file(key)).path;
    for (final suffix in _sidecars) {
      final file = File('$base$suffix');
      if (file.existsSync()) await file.delete();
    }
  }

  @override
  Future<void> delete(String key) async {
    await _deleteFiles(key);
    await _memory.delete(key);
  }
}

DatabaseSetup _applyKey(String hex) =>
    (raw) => raw.execute("PRAGMA hexkey = '$hex';");
