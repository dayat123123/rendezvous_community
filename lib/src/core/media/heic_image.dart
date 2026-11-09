import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:rendezvous_community/src/core/media/pasted_image.dart';

const heicMimeTypes = {'image/heic', 'image/heif', 'image/heic-sequence', 'image/heif-sequence'};

const _heicBrands = {'heic', 'heix', 'heim', 'heis', 'hevc', 'hevx', 'hevm', 'hevs', 'mif1', 'msf1'};

const _jpegQuality = 85;
const _maxJpegSide = 3072;

typedef JpegConverter = Future<PastedImage?> Function(Uint8List bytes, {int maxBytes});

enum HeicConversion { none, convert, notAccepted }

bool hasHeicName(String? name) {
  final lower = name?.toLowerCase() ?? '';
  return lower.endsWith('.heic') || lower.endsWith('.heif');
}

bool isHeicImage(Uint8List? bytes, {String? name, String? mimeType}) {
  if (bytes != null && bytes.length >= 12) {
    if (sniffImageMime(bytes) != null) return false;
    final box = String.fromCharCodes(bytes.sublist(4, 8));
    if (box == 'ftyp') return _heicBrands.contains(String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase());
  }
  return heicMimeTypes.contains(mimeType?.toLowerCase()) || hasHeicName(name);
}

HeicConversion heicConversionFor(Uint8List? bytes, {String? name, String? mimeType, required bool acceptsJpeg}) {
  if (!isHeicImage(bytes, name: name, mimeType: mimeType)) return HeicConversion.none;
  return acceptsJpeg ? HeicConversion.convert : HeicConversion.notAccepted;
}

Future<PastedImage?> convertImageToJpeg(Uint8List bytes, {int maxBytes = maxChatImageBytes}) async {
  var side = _maxJpegSide;
  for (var attempt = 0; attempt < 5; attempt++) {
    final pixels = await _decode(bytes, side);
    if (pixels == null) return null;
    final jpeg = await compute(_encodeJpeg, pixels);
    if (jpeg.length <= maxBytes) return (bytes: jpeg, mimeType: 'image/jpeg');
    side = (side * 0.75).round();
  }
  return null;
}

typedef _Pixels = ({Uint8List rgba, int width, int height});

Uint8List _encodeJpeg(_Pixels pixels) {
  final image = img.Image.fromBytes(
    width: pixels.width,
    height: pixels.height,
    bytes: pixels.rgba.buffer,
    bytesOffset: pixels.rgba.offsetInBytes,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return img.encodeJpg(image, quality: _jpegQuality, chroma: img.JpegChroma.yuv420);
}

Future<_Pixels?> _decode(Uint8List bytes, int maxSide) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    final longest = descriptor.width > descriptor.height ? descriptor.width : descriptor.height;
    final factor = longest > maxSide ? maxSide / longest : 1.0;
    codec = await descriptor.instantiateCodec(
      targetWidth: (descriptor.width * factor).round().clamp(1, maxSide),
      targetHeight: (descriptor.height * factor).round().clamp(1, maxSide),
    );
    image = (await codec.getNextFrame()).image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    if (data == null) return null;
    return (
      rgba: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      width: image.width,
      height: image.height,
    );
  } on Object {
    return null;
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}
