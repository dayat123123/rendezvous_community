import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:rendezvous_community/src/core/media/heic_image.dart';

Uint8List _ftyp(String brand) => Uint8List.fromList([0, 0, 0, 24, ...'ftyp'.codeUnits, ...brand.codeUnits, 0, 0, 0, 0]);

void main() {
  test('detects HEIC and HEIF by their ftyp brand', () {
    for (final brand in ['heic', 'heix', 'hevc', 'mif1', 'msf1']) {
      expect(isHeicImage(_ftyp(brand)), isTrue, reason: brand);
    }
    expect(isHeicImage(_ftyp('avif')), isFalse);
    expect(isHeicImage(_ftyp('isom')), isFalse);
  });

  test('falls back to the file name or reported type when there are no bytes', () {
    expect(isHeicImage(null, name: 'IMG_0001.HEIC'), isTrue);
    expect(isHeicImage(null, name: 'IMG_0001.heif'), isTrue);
    expect(isHeicImage(null, mimeType: 'image/heic'), isTrue);
    expect(isHeicImage(null, name: 'IMG_0001.jpg', mimeType: 'image/jpeg'), isFalse);
  });

  test('a real JPEG named .heic is not treated as HEIC', () {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(12, 0)]);
    expect(isHeicImage(jpeg, name: 'IMG_0001.HEIC'), isFalse);
  });

  test('conversion is planned only for HEIC and only when JPEG is accepted', () {
    final heic = _ftyp('heic');
    expect(heicConversionFor(heic, name: 'a.heic', acceptsJpeg: true), HeicConversion.convert);
    expect(heicConversionFor(heic, name: 'a.heic', acceptsJpeg: false), HeicConversion.notAccepted);
    expect(
      heicConversionFor(Uint8List.fromList(List.filled(16, 1)), name: 'a.png', acceptsJpeg: true),
      HeicConversion.none,
    );
  });

  test('convertImageToJpeg re-encodes what the platform decoder can read as JPEG', () async {
    final source = img.Image(width: 64, height: 48);
    img.fill(source, color: img.ColorRgb8(12, 95, 255));
    final png = img.encodePng(source);

    final jpeg = await convertImageToJpeg(png);

    expect(jpeg, isNotNull);
    expect(jpeg!.mimeType, 'image/jpeg');
    expect(jpeg.bytes.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
    final decoded = img.decodeJpg(jpeg.bytes)!;
    expect((decoded.width, decoded.height), (64, 48));
  });

  test('convertImageToJpeg returns null when the platform cannot decode the photo', () async {
    expect(await convertImageToJpeg(_ftyp('heic')), isNull);
  });
}
