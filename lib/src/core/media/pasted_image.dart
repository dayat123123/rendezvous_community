import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:rendezvous_community/src/core/media/image_mime.dart';

const maxChatImageBytes = 5 * 1024 * 1024;
const _maxSide = 4096;

typedef PastedImage = ({Uint8List bytes, String mimeType});

String? sniffImageMime(Uint8List b) {
  bool at(int offset, List<int> bytes) {
    if (b.length < offset + bytes.length) return false;
    for (var i = 0; i < bytes.length; i++) {
      if (b[offset + i] != bytes[i]) return false;
    }
    return true;
  }

  if (at(0, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) return 'image/png';
  if (at(0, const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (at(0, 'GIF8'.codeUnits)) return gifMimeType;
  if (at(0, 'RIFF'.codeUnits) && at(8, 'WEBP'.codeUnits)) return 'image/webp';
  return null;
}

Future<PastedImage?> preparePastedImage(Uint8List bytes, {int maxBytes = maxChatImageBytes}) async {
  final mime = sniffImageMime(bytes);
  if (mime != null && bytes.length <= maxBytes) return (bytes: bytes, mimeType: mime);
  var scale = 1.0;
  for (var attempt = 0; attempt < 8; attempt++) {
    final png = await _encodePng(bytes, scale);
    if (png == null) return null;
    if (png.length <= maxBytes) return (bytes: png, mimeType: 'image/png');
    scale *= 0.75;
  }
  return null;
}

Future<Uint8List?> _encodePng(Uint8List bytes, double scale) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    final longest = descriptor.width > descriptor.height ? descriptor.width : descriptor.height;
    final fit = longest > _maxSide ? _maxSide / longest : 1.0;
    final factor = fit * scale;
    codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * factor).round().clamp(1, _maxSide),
      targetHeight: (descriptor.height * factor).round().clamp(1, _maxSide),
    );
    image = (await codec.getNextFrame()).image;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } on Object {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}
