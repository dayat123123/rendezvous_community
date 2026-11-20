import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rendezvous_community/src/core/storage/platform_downloads_io.dart';

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('rc-downloads-'));

  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  Directory downloads() => Directory(p.join(root.path, 'rendezvous_community', 'downloads'));

  test('opened attachments are saved under the downloads folder', () async {
    final path = await saveDownloadedFile(
      Uint8List.fromList([1, 2, 3]),
      folder: 'a1',
      fileName: 'ktp.pdf',
      root: () async => root,
    );

    expect(path, p.join(downloads().path, 'a1', 'ktp.pdf'));
    expect(File(path!).readAsBytesSync(), [1, 2, 3]);
  });

  test('clearing removes every opened attachment', () async {
    for (final (folder, name) in [('a1', 'ktp.pdf'), ('b2', 'form.docx')]) {
      await saveDownloadedFile(Uint8List.fromList([1]), folder: folder, fileName: name, root: () async => root);
    }

    await clearDownloadedFiles(root: () async => root);

    expect(downloads().existsSync(), isFalse);
  });

  test('clearing without any downloads does nothing and does not throw', () async {
    await clearDownloadedFiles(root: () async => root);

    expect(downloads().existsSync(), isFalse);
  });

  test('a failing temp directory lookup is ignored', () async {
    await clearDownloadedFiles(root: () async => throw const FileSystemException('no temp'));
  });
}
