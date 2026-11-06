import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';

final _imageFile = RegExp(r'\.(png|jpe?g|gif|webp|bmp)$', caseSensitive: false);

typedef ClipboardImageReader = Future<Uint8List?> Function();

Future<Uint8List?> readClipboardImage() async {
  try {
    final image = await Pasteboard.image;
    if (image != null && image.isNotEmpty) return image;
    for (final path in await Pasteboard.files()) {
      if (_imageFile.hasMatch(path)) return await XFile(path).readAsBytes();
    }
  } on Object catch (error) {
    CommunityLoggers.chat.warning('Could not read an image from the clipboard', error);
  }
  return null;
}
