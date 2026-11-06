import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/src/core/media/pasted_image.dart';

Uint8List _bmp(int width, int height, {bool noise = false}) {
  final random = Random(7);
  final rowSize = (width * 3 + 3) & ~3;
  final pixels = rowSize * height;
  final data = ByteData(54 + pixels)
    ..setUint8(0, 0x42)
    ..setUint8(1, 0x4D)
    ..setUint32(2, 54 + pixels, Endian.little)
    ..setUint32(10, 54, Endian.little)
    ..setUint32(14, 40, Endian.little)
    ..setInt32(18, width, Endian.little)
    ..setInt32(22, height, Endian.little)
    ..setUint16(26, 1, Endian.little)
    ..setUint16(28, 24, Endian.little)
    ..setUint32(34, pixels, Endian.little);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final offset = 54 + y * rowSize + x * 3;
      data
        ..setUint8(offset, noise ? random.nextInt(256) : 0x30)
        ..setUint8(offset + 1, noise ? random.nextInt(256) : 0x90)
        ..setUint8(offset + 2, noise ? random.nextInt(256) : 0xE0);
    }
  }
  return data.buffer.asUint8List();
}

Future<(int, int)> _size(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final size = (frame.image.width, frame.image.height);
  frame.image.dispose();
  codec.dispose();
  return size;
}

void main() {
  test('recognises the formats the server accepts', () {
    expect(sniffImageMime(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])), 'image/png');
    expect(sniffImageMime(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0])), 'image/jpeg');
    expect(sniffImageMime(Uint8List.fromList('GIF89a'.codeUnits)), 'image/gif');
    expect(sniffImageMime(Uint8List.fromList('RIFF\x00\x00\x00\x00WEBP'.codeUnits)), 'image/webp');
    expect(sniffImageMime(_bmp(2, 2)), isNull);
  });

  testWidgets('keeps an accepted image as it is', (tester) async {
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2, 3]);
    final result = await tester.runAsync(() => preparePastedImage(png));
    expect(result?.mimeType, 'image/png');
    expect(identical(result?.bytes, png), isTrue);
  });

  testWidgets('converts a Windows clipboard bitmap to PNG', (tester) async {
    final result = await tester.runAsync(() => preparePastedImage(_bmp(6, 4)));
    expect(result?.mimeType, 'image/png');
    expect(sniffImageMime(result!.bytes), 'image/png');
    expect(await tester.runAsync(() => _size(result.bytes)), (6, 4));
  });

  testWidgets('shrinks an image that is larger than the upload limit', (tester) async {
    const limit = 150 * 1024;
    final result = await tester.runAsync(() => preparePastedImage(_bmp(400, 300, noise: true), maxBytes: limit));
    expect(result?.mimeType, 'image/png');
    expect(result!.bytes.length, lessThanOrEqualTo(limit));
    final (width, height) = (await tester.runAsync(() => _size(result.bytes)))!;
    expect(width, lessThan(400));
    expect(width / height, closeTo(4 / 3, 0.05));
  });

  testWidgets('returns null for data that is not an image', (tester) async {
    final result = await tester.runAsync(() => preparePastedImage(Uint8List.fromList(List.filled(64, 7))));
    expect(result, isNull);
  });
}
