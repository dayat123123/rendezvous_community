import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/attachment_picker.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../../support/attachment_fixtures.dart';

final _id = lookupCommunityLocalizations(const Locale('id'));

final _png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(32, 0)]);

final _heic = Uint8List.fromList([0, 0, 0, 24, ...'ftyp'.codeUnits, ...'heic'.codeUnits, ...List.filled(12, 0)]);

XFile _file(String name, {int size = 64, Uint8List? bytes, String? mime}) => XFile.fromData(
  bytes ?? Uint8List(size),
  name: name,
  path: name,
  mimeType: mime,
  length: (bytes ?? Uint8List(size)).length,
);

void main() {
  final full = CommunityAttachmentPolicy.fromJson(serverPolicy());

  test('type groups follow the server policy, one per enabled kind', () {
    final groups = attachmentTypeGroups(full, _id);

    expect([for (final g in groups) g.label], ['Foto', 'Video', 'Dokumen']);
    expect(groups[0].extensions, containsAll(['jpg', 'jpeg', 'png', 'webp', 'gif', 'heic', 'heif']));
    expect(groups[0].uniformTypeIdentifiers, containsAll(['public.jpeg', 'public.heic']));
    expect(groups[1].extensions, ['mp4', 'mov', 'webm']);
    expect(groups[1].mimeTypes, ['video/mp4', 'video/quicktime', 'video/webm']);
    expect(groups[1].uniformTypeIdentifiers, ['public.mpeg-4', 'com.apple.quicktime-movie', 'org.webmproject.webm']);
    expect(groups[2].extensions, ['pdf', 'docx', 'xlsx', 'pptx', 'txt', 'csv']);
    expect(groups[2].uniformTypeIdentifiers, contains('org.openxmlformats.wordprocessingml.document'));
    for (final g in groups) {
      expect(g.uniformTypeIdentifiers, isNotEmpty, reason: 'iOS needs UTIs for ${g.label}');
    }
  });

  test('older servers and social chats get the legacy groups', () {
    final legacy = attachmentTypeGroups(CommunityAttachmentPolicy.legacy, _id);
    expect([for (final g in legacy) g.label], ['Foto', 'Dokumen']);
    expect(legacy[1].extensions, ['pdf']);

    final social = attachmentTypeGroups(CommunityAttachmentPolicy.imagesOnly, _id);
    expect([for (final g in social) g.label], ['Foto']);
  });

  test('disabled kinds are left out of the picker', () {
    final policy = CommunityAttachmentPolicy.fromJson(serverPolicy(videos: false));
    expect([for (final g in attachmentTypeGroups(policy, _id)) g.label], ['Foto', 'Dokumen']);
  });

  test('documents and videos keep their name, type, and format', () async {
    final result = await prepareAttachments(
      [_file('Rekening Koran.xlsx'), _file('rekaman layar.mov', mime: 'video/quicktime'), _file('catatan.TXT')],
      full,
      _id,
    );

    expect(result.errors, isEmpty);
    expect(
      [for (final f in result.files) f.kind],
      [CommunityAttachmentKind.document, CommunityAttachmentKind.video, CommunityAttachmentKind.document],
    );
    expect(result.files[0].mimeType, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    expect(result.files[0].name, 'Rekening Koran.xlsx');
    expect(result.files[1].format?.extension, 'mov');
    expect(result.files[2].format?.code, 'txt');
  });

  test('formats outside the policy are rejected with the accepted list', () async {
    final result = await prepareAttachments([_file('makro.docm'), _file('arsip.zip')], full, _id);

    expect(result.files, isEmpty);
    expect(result.errors, hasLength(2));
    expect(result.errors.first, startsWith('makro.docm tidak bisa dikirim. Format yang diterima: JPG, PNG'));
    expect(result.errors.first, contains('MP4'));
    expect(result.errors.first, contains('DOCX'));
  });

  test('files above the kind limit are rejected before upload', () async {
    final policy = CommunityAttachmentPolicy.fromJson(
      serverPolicy()..['videos'] = {...serverPolicy()['videos'] as Map<String, dynamic>, 'max_bytes': 1024},
    );

    final result = await prepareAttachments([_file('panjang.mp4', size: 2048)], policy, _id);

    expect(result.files, isEmpty);
    expect(result.errors.single, 'panjang.mp4 terlalu besar. Batasnya 1 KB.');
  });

  test('HEIC photos are converted to JPEG before sending', () async {
    Uint8List? seen;
    final result = await prepareAttachments(
      [_file('IMG_0042.HEIC', bytes: _heic)],
      full,
      _id,
      heic: (bytes, {int maxBytes = 0}) async {
        seen = bytes;
        return (bytes: Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xDB]), mimeType: 'image/jpeg');
      },
    );

    expect(seen, _heic);
    expect(result.errors, isEmpty);
    expect(result.files.single.mimeType, 'image/jpeg');
    expect(result.files.single.name, 'IMG_0042.jpg');
    expect(result.files.single.kind, CommunityAttachmentKind.image);
  });

  test('a HEIC photo the device cannot convert explains what to do', () async {
    final result = await prepareAttachments(
      [_file('IMG_0042.heic', bytes: _heic)],
      full,
      _id,
      heic: (bytes, {int maxBytes = 0}) async => null,
    );

    expect(result.files, isEmpty);
    expect(result.errors.single, _id.heicUnsupported);
  });

  test('a JPEG that only has a .heic name is sent as a normal image', () async {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(20, 0)]);
    final result = await prepareAttachments(
      [_file('salah-nama.heic', bytes: jpeg)],
      full,
      _id,
      heic: (bytes, {int maxBytes = 0}) async => fail('should not convert'),
    );

    expect(result.files.single.mimeType, 'image/jpeg');
  });

  test('regular images keep going through the image pipeline', () async {
    final result = await prepareAttachments([_file('grafik.png', bytes: _png)], full, _id);

    expect(result.files.single.mimeType, 'image/png');
    expect(result.files.single.kind, CommunityAttachmentKind.image);
  });
}
