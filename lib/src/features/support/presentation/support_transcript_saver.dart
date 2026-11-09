import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_transcript.dart';
import 'package:rendezvous_community/src/features/support/domain/services/support_transcript_text.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, ShareResultStatus;

typedef CommunityTranscriptSaver = Future<bool> Function(BuildContext context, SupportTranscriptFile file);

const _textFiles = XTypeGroup(
  label: 'TXT',
  extensions: ['txt'],
  mimeTypes: [SupportTranscriptFile.mimeType],
  uniformTypeIdentifiers: ['public.plain-text'],
);

bool get _savesWithDialog =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => true,
      _ => false,
    };

SupportTranscriptLabels supportTranscriptLabels(CommunityLocalizations l10n) => SupportTranscriptLabels(
  title: l10n.supportTranscriptTitle,
  ticket: l10n.supportTranscriptTicket,
  topic: l10n.supportTranscriptTopic,
  created: l10n.supportTranscriptCreated,
  resolved: l10n.supportTranscriptResolved,
  closed: l10n.supportTranscriptClosed,
  customer: l10n.supportTranscriptCustomer,
  agent: l10n.supportTranscriptAgent,
  system: l10n.supportTranscriptSystem,
  deleted: l10n.supportTranscriptDeleted,
  attachments: l10n.supportTranscriptAttachments,
  empty: l10n.supportTranscriptEmpty,
);

SupportTranscriptFile supportTranscriptFile(SupportTranscript transcript, CommunityLocalizations l10n) =>
    SupportTranscriptFile(
      name: supportTranscriptFileName(transcript, prefix: l10n.supportTranscriptFilePrefix),
      text: formatSupportTranscript(transcript, supportTranscriptLabels(l10n)),
    );

Future<bool> saveSupportTranscript(BuildContext context, SupportTranscriptFile transcript) async {
  final bytes = Uint8List.fromList(utf8.encode(transcript.text));
  final file = XFile.fromData(
    bytes,
    mimeType: SupportTranscriptFile.mimeType,
    name: transcript.name,
    length: bytes.length,
  );
  if (_savesWithDialog) {
    final location = await getSaveLocation(suggestedName: transcript.name, acceptedTypeGroups: const [_textFiles]);
    if (location == null) return false;
    await file.saveTo(location.path);
    return true;
  }
  final box = context.findRenderObject();
  final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  final result = await SharePlus.instance.share(
    ShareParams(
      files: [file],
      fileNameOverrides: [transcript.name],
      subject: transcript.name,
      sharePositionOrigin: origin,
    ),
  );
  return result.status != ShareResultStatus.dismissed;
}
