import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/media/presentation/file_opener.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, ShareResultStatus;
import 'package:url_launcher/url_launcher.dart';

typedef CommunityFileSaver =
    Future<bool> Function(BuildContext context, Uri remote, {required String fileName, required String mimeType});

bool communitySavesWithDialog({TargetPlatform? platform, bool web = kIsWeb}) =>
    !web &&
    switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => true,
      _ => false,
    };

Uri communityDownloadUri(Uri remote, String fileName) =>
    remote.replace(queryParameters: {...remote.queryParameters, 'download': fileName});

Future<Uint8List?> _fetch(Uri remote, http.Client? client) async {
  final own = client == null ? http.Client() : null;
  try {
    final response = await (client ?? own!).get(remote).timeout(const Duration(minutes: 2));
    if (response.statusCode == 200) return response.bodyBytes;
    CommunityLoggers.chat.warning('Attachment download failed with status ${response.statusCode}');
    return null;
  } finally {
    own?.close();
  }
}

Future<bool> saveCommunityFile(
  BuildContext context,
  Uri remote, {
  required String fileName,
  required String mimeType,
  http.Client? client,
  bool web = kIsWeb,
  TargetPlatform? platform,
}) async {
  final name = safeDownloadName(fileName);
  if (web) return launchUrl(communityDownloadUri(remote, name), mode: LaunchMode.externalApplication);
  final box = context.findRenderObject();
  final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  final bytes = await _fetch(remote, client);
  if (bytes == null) return false;
  final file = XFile.fromData(bytes, mimeType: mimeType, name: name, length: bytes.length);
  if (communitySavesWithDialog(platform: platform, web: web)) {
    final location = await getSaveLocation(suggestedName: name);
    if (location == null) return false;
    await file.saveTo(location.path);
    return true;
  }
  final result = await SharePlus.instance.share(
    ShareParams(files: [file], fileNameOverrides: [name], sharePositionOrigin: origin),
  );
  return result.status != ShareResultStatus.dismissed;
}
