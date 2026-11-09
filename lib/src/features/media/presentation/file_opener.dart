import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/storage/platform_downloads.dart';
import 'package:url_launcher/url_launcher.dart';

typedef DocumentOpener = Future<bool> Function(Uri uri);

typedef CommunityDownloadSaver =
    Future<String?> Function(Uint8List bytes, {required String folder, required String fileName});

bool communityOpensDownloadedFiles({TargetPlatform? platform, bool web = kIsWeb}) =>
    !web &&
    switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.linux || TargetPlatform.macOS => true,
      _ => false,
    };

bool communityVideoPlaysInApp({TargetPlatform? platform, bool web = kIsWeb}) =>
    web ||
    switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

String safeDownloadName(String name, {String fallback = 'file'}) {
  final cleaned = name
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '')
      .trim();
  if (cleaned.isEmpty) return fallback;
  return cleaned.length > 120 ? cleaned.substring(cleaned.length - 120) : cleaned;
}

class CommunityFileOpener {
  const CommunityFileOpener({
    this.client,
    this.save = saveDownloadedFile,
    this.launch,
    this.platform,
    this.web = kIsWeb,
  });

  final http.Client? client;
  final CommunityDownloadSaver save;
  final DocumentOpener? launch;
  final TargetPlatform? platform;
  final bool web;

  Future<bool> _launch(Uri uri, {required bool local}) =>
      (launch ?? (uri) => launchUrl(uri, mode: local ? LaunchMode.platformDefault : LaunchMode.externalApplication))(
        uri,
      );

  Future<bool> open(Uri remote, {required String fileName, required String key}) async {
    if (!communityOpensDownloadedFiles(platform: platform, web: web)) return _launch(remote, local: false);
    final shared = client;
    final http.Response response;
    if (shared != null) {
      response = await shared.get(remote).timeout(const Duration(minutes: 2));
    } else {
      final own = http.Client();
      try {
        response = await own.get(remote).timeout(const Duration(minutes: 2));
      } finally {
        own.close();
      }
    }
    if (response.statusCode != 200) {
      CommunityLoggers.chat.warning('Attachment download failed with status ${response.statusCode}');
      return false;
    }
    final folder = sha1.convert(utf8.encode(key)).toString().substring(0, 16);
    final path = await save(response.bodyBytes, folder: folder, fileName: safeDownloadName(fileName));
    if (path == null) return _launch(remote, local: false);
    return _launch(Uri.file(path), local: true);
  }
}
