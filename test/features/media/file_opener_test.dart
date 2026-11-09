import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/src/features/media/presentation/file_opener.dart';

void main() {
  final remote = Uri.parse('https://api.test/storage/v1/object/sign/cs-documents/rooms/r/u/a.docx?token=t');

  test('Windows downloads the file and opens it with the default app', () async {
    final saved = <(String, String, int)>[];
    final launched = <Uri>[];
    final opener = CommunityFileOpener(
      platform: TargetPlatform.windows,
      web: false,
      client: MockClient((request) async => http.Response.bytes(Uint8List(12), 200)),
      save: (bytes, {required folder, required fileName}) async {
        saved.add((folder, fileName, bytes.length));
        return r'C:\Temp\rendezvous_community\downloads\x\Surat Kuasa.docx';
      },
      launch: (uri) async {
        launched.add(uri);
        return true;
      },
    );

    expect(await opener.open(remote, fileName: 'Surat Kuasa.docx', key: 'rooms/r/u/a.docx'), isTrue);

    expect(saved.single.$2, 'Surat Kuasa.docx');
    expect(saved.single.$3, 12);
    expect(saved.single.$1, hasLength(16));
    expect(launched.single.scheme, 'file');
  });

  test('a failed download does not open anything', () async {
    final launched = <Uri>[];
    final opener = CommunityFileOpener(
      platform: TargetPlatform.windows,
      web: false,
      client: MockClient((request) async => http.Response('gone', 404)),
      save: (bytes, {required folder, required fileName}) async => fail('must not save'),
      launch: (uri) async {
        launched.add(uri);
        return true;
      },
    );

    expect(await opener.open(remote, fileName: 'a.docx', key: 'k'), isFalse);
    expect(launched, isEmpty);
  });

  test('Android and iOS hand the signed link to the system', () async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final launched = <Uri>[];
      final opener = CommunityFileOpener(
        platform: platform,
        web: false,
        client: MockClient((request) async => fail('must not download')),
        launch: (uri) async {
          launched.add(uri);
          return true;
        },
      );

      expect(await opener.open(remote, fileName: 'a.docx', key: 'k'), isTrue);
      expect(launched, [remote]);
    }
  });

  test('safeDownloadName removes path and reserved characters', () {
    expect(safeDownloadName(r'..\..\evil:name?.docx'), '_.._evil_name_.docx');
    expect(safeDownloadName('   '), 'file');
    expect(safeDownloadName('Laporan Q3.xlsx'), 'Laporan Q3.xlsx');
  });
}
