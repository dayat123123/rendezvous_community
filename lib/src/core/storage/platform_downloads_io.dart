import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> saveDownloadedFile(Uint8List bytes, {required String folder, required String fileName}) async {
  final root = await getTemporaryDirectory();
  final directory = Directory(p.join(root.path, 'rendezvous_community', 'downloads', folder));
  await directory.create(recursive: true);
  final file = File(p.join(directory.path, fileName));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
