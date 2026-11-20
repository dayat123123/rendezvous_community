import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';

Future<Directory> _downloads(Future<Directory> Function()? root) async =>
    Directory(p.join((await (root ?? getTemporaryDirectory)()).path, 'rendezvous_community', 'downloads'));

Future<String?> saveDownloadedFile(
  Uint8List bytes, {
  required String folder,
  required String fileName,
  Future<Directory> Function()? root,
}) async {
  final directory = Directory(p.join((await _downloads(root)).path, folder));
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, fileName));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<void> clearDownloadedFiles({Future<Directory> Function()? root}) async {
  try {
    final directory = await _downloads(root);
    if (!directory.existsSync()) return;
    var kept = 0;
    for (final entity in directory.listSync(recursive: true).reversed) {
      try {
        await entity.delete();
      } on FileSystemException {
        kept++;
      }
    }
    try {
      await directory.delete();
    } on FileSystemException {
      kept++;
    }
    CommunityLoggers.offline.event(Level.INFO, 'Opened attachments cleared', fields: {'kept': kept});
  } catch (e) {
    CommunityLoggers.offline.event(
      Level.WARNING,
      'Opened attachments could not be cleared',
      fields: {'errorType': e.runtimeType.toString()},
    );
  }
}
