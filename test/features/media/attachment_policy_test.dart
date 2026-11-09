import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_repository_impl.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

import '../../support/attachment_fixtures.dart';
import '../../support/mock_api.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

class _MockSupport extends Mock implements SupportRepository {}

void main() {
  group('CommunityAttachmentPolicy', () {
    test('parses every kind with its bucket, limits, and formats', () {
      final policy = CommunityAttachmentPolicy.fromJson(serverPolicy());

      expect(policy.documents.bucket, 'cs-documents');
      expect(policy.documents.maxBytes, 10485760);
      expect(policy.documents.maxMegabytes, 10);
      expect([for (final f in policy.documents.formats) f.code], ['pdf', 'docx', 'xlsx', 'pptx', 'txt', 'csv']);
      expect(policy.videos.maxSeconds, 120);
      expect(policy.videos.extensions, ['mp4', 'mov', 'webm']);
      expect(policy.images.extensions, ['jpg', 'jpeg', 'png', 'webp', 'gif']);
      expect(policy.acceptsJpeg, isTrue);
      expect(policy.onlyPdfDocuments, isFalse);
    });

    test('matches files by extension first and by reported type as a fallback', () {
      final policy = CommunityAttachmentPolicy.fromJson(serverPolicy());

      expect(policy.match(name: 'Laporan.DOCX')?.format.code, 'docx');
      expect(policy.match(name: 'data.csv', mime: 'application/vnd.ms-excel')?.format.mime, 'text/csv');
      expect(policy.match(name: 'rekaman.MOV')?.kind, CommunityAttachmentKind.video);
      expect(policy.match(name: 'foto.jpeg')?.format.extension, 'jpg');
      expect(policy.match(name: 'scan', mime: 'application/pdf')?.format.code, 'pdf');
      expect(policy.match(name: 'makro.docm'), isNull);
      expect(policy.match(name: 'lama.doc'), isNull);
      expect(policy.match(name: 'arsip.zip', mime: 'application/zip'), isNull);
    });

    test('a disabled kind or a missing section offers nothing', () {
      final json = serverPolicy(videos: false)..remove('documents');
      final policy = CommunityAttachmentPolicy.fromJson(json);

      expect(policy.videos.usable, isFalse);
      expect(policy.documents.usable, isFalse);
      expect(policy.match(name: 'rekaman.mp4'), isNull);
      expect(policy.match(name: 'surat.pdf'), isNull);
      expect(policy.match(name: 'foto.png')?.kind, CommunityAttachmentKind.image);
    });

    test('ignores malformed format entries', () {
      final policy = CommunityAttachmentPolicy.fromJson({
        'documents': {
          'enabled': true,
          'max_bytes': 1048576,
          'formats': [
            {'code': 'pdf', 'mime': 'application/pdf', 'ext': 'pdf'},
            {'code': 'docx'},
            'xlsx',
          ],
        },
      });

      expect([for (final f in policy.documents.formats) f.code], ['pdf']);
      expect(policy.documents.bucket, 'cs-documents');
    });

    test('the legacy policy keeps the old behaviour of images and PDF only', () {
      const legacy = CommunityAttachmentPolicy.legacy;

      expect(legacy.documents.extensions, ['pdf']);
      expect(legacy.documents.maxBytes, 10 * 1024 * 1024);
      expect(legacy.videos.usable, isFalse);
      expect(legacy.onlyPdfDocuments, isTrue);
      expect(legacy.match(name: 'a.docx'), isNull);
      expect(CommunityAttachmentPolicy.imagesOnly.match(name: 'a.pdf'), isNull);
      expect(CommunityAttachmentPolicy.imagesOnly.match(name: 'a.webp')?.kind, CommunityAttachmentKind.image);
    });
  });

  group('SupportRepositoryImpl.attachmentPolicy', () {
    late MockApi cs;
    late SupportRepositoryImpl repo;

    setUp(() {
      cs = mockApi();
      repo = SupportRepositoryImpl(cs: cs, notifications: _MockNotifications());
    });

    test('reads the policy from the server', () async {
      when(() => cs.rpcValue('attachment_policy')).thenAnswer((_) async => serverPolicy());

      final policy = await repo.attachmentPolicy();

      expect(policy.videos.usable, isTrue);
      expect(policy.documents.formats, hasLength(6));
    });

    test('falls back to images and PDF when the server has no policy endpoint', () async {
      when(() => cs.rpcValue('attachment_policy')).thenThrow(
        const CommunityException(CommunityErrorKind.unknown, code: 'PGRST202', message: 'Could not find the function'),
      );

      final policy = await repo.attachmentPolicy();

      expect(identical(policy, CommunityAttachmentPolicy.legacy), isTrue);
    });

    test('other failures surface so the caller can retry later', () async {
      when(
        () => cs.rpcValue('attachment_policy'),
      ).thenThrow(const CommunityException(CommunityErrorKind.network, message: 'offline'));

      expect(repo.attachmentPolicy(), throwsA(isA<CommunityException>()));
    });
  });

  group('SupportCubit', () {
    late _MockSupport support;

    setUp(() {
      support = _MockSupport();
      when(
        () => support.home(),
      ).thenAnswer((_) async => const SupportHome(roomId: 'r-cs', supportName: 'CS OLT', active: false));
      when(() => support.topics(language: any(named: 'language'))).thenAnswer((_) async => const []);
      when(() => support.watchTicket(any())).thenAnswer((_) => const Stream.empty());
    });

    test('loads the attachment policy after the home screen', () async {
      final policy = CommunityAttachmentPolicy.fromJson(serverPolicy());
      when(() => support.attachmentPolicy()).thenAnswer((_) async => policy);
      final cubit = SupportCubit(support: support);

      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.attachmentPolicy, same(policy));
      await cubit.close();
    });

    test('keeps no policy when loading fails so the composer uses the legacy one', () async {
      when(() => support.attachmentPolicy()).thenThrow(const CommunityException(CommunityErrorKind.network));
      final cubit = SupportCubit(support: support);

      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.attachmentPolicy, isNull);
      expect(cubit.state.status.name, 'ready');
      await cubit.close();
    });
  });

  group('upload error messages', () {
    const codes = {
      'kind_disabled': ('Jenis lampiran ini sedang tidak diterima di chat CS.', 'not accepted in support chat'),
      'policy_unavailable': ('Daftar format lampiran belum bisa dimuat', 'could not be loaded'),
      'office_macro': ('Dokumen berisi makro', 'contains macros'),
      'office_unsafe': ('objek tertanam yang tidak aman', 'unsafe embedded object'),
      'archive_bomb': ('Isi dokumen tidak wajar', 'abnormal'),
      'invalid_text': ('UTF-8', 'UTF-8'),
      'invalid_video': ('Video rusak', 'damaged'),
      'video_too_long': ('Video terlalu panjang', 'too long'),
      'malware_detected': ('antivirus', 'virus scanner'),
      'scanner_unavailable': ('Pemeriksaan file sedang tidak tersedia', 'unavailable'),
      'unsupported_type': ('Jenis file tidak didukung', 'not supported'),
      'file_too_large': ('File terlalu besar', 'too large'),
      'attachment_not_allowed': ('tidak diterima di chat ini', 'not accepted in this chat'),
      'attachment_too_large': ('melebihi batas ukuran', 'larger than this chat allows'),
      'attachment_too_long': ('batas durasi', 'longer than allowed'),
    };

    for (final MapEntry(key: code, value: (id, en)) in codes.entries) {
      test('$code has Indonesian and English text', () {
        final error = mapMediaError(422, code: code, message: 'internal detail');
        expect(lookupCommunityLocalizations(const Locale('id')).errorMessage(error), contains(id));
        expect(lookupCommunityLocalizations(const Locale('en')).errorMessage(error), contains(en));
      });
    }
  });
}
