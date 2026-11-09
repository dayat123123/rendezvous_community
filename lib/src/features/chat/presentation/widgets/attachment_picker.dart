import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:rendezvous_community/src/core/media/heic_image.dart';
import 'package:rendezvous_community/src/core/media/pasted_image.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/outgoing_file.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

const _utis = {
  'jpeg': ['public.jpeg'],
  'png': ['public.png'],
  'webp': ['org.webmproject.webp'],
  'gif': ['com.compuserve.gif'],
  'heic': ['public.heic', 'public.heif'],
  'pdf': ['com.adobe.pdf'],
  'docx': ['org.openxmlformats.wordprocessingml.document'],
  'xlsx': ['org.openxmlformats.spreadsheetml.sheet'],
  'pptx': ['org.openxmlformats.presentationml.presentation'],
  'txt': ['public.plain-text'],
  'csv': ['public.comma-separated-values-text'],
  'mp4': ['public.mpeg-4'],
  'mov': ['com.apple.quicktime-movie'],
  'webm': ['org.webmproject.webm'],
};

const _heicExtensions = ['heic', 'heif'];

const _anyLength = 1 << 62;

class AttachmentPickResult {
  const AttachmentPickResult(this.files, this.errors);

  final List<ChatOutgoingFile> files;
  final List<String> errors;
}

String _groupLabel(CommunityLocalizations l10n, CommunityAttachmentKind kind) => switch (kind) {
  CommunityAttachmentKind.image => l10n.attachmentGroupImages,
  CommunityAttachmentKind.video => l10n.attachmentGroupVideos,
  CommunityAttachmentKind.document => l10n.attachmentGroupDocuments,
};

List<XTypeGroup> attachmentTypeGroups(CommunityAttachmentPolicy policy, CommunityLocalizations l10n) => [
  for (final rule in policy.rules)
    if (rule.usable)
      XTypeGroup(
        label: _groupLabel(l10n, rule.kind),
        extensions: [
          ...rule.extensions,
          if (rule.kind == CommunityAttachmentKind.image && policy.acceptsJpeg) ..._heicExtensions,
        ],
        mimeTypes: [
          ...rule.mimeTypes,
          if (rule.kind == CommunityAttachmentKind.image && policy.acceptsJpeg) ...heicMimeTypes.take(2),
        ],
        uniformTypeIdentifiers: [
          for (final f in rule.formats) ...?_utis[f.code],
          if (rule.kind == CommunityAttachmentKind.image && policy.acceptsJpeg) ...?_utis['heic'],
        ],
      ),
];

String acceptedFormatsLabel(CommunityAttachmentPolicy policy) => [
  for (final rule in policy.rules)
    if (rule.usable)
      for (final f in rule.formats) f.extension.toUpperCase(),
].join(', ');

String attachmentLimitLabel(int bytes) => documentSize(bytes);

Future<AttachmentPickResult> prepareAttachments(
  List<XFile> picked,
  CommunityAttachmentPolicy policy,
  CommunityLocalizations l10n, {
  JpegConverter heic = convertImageToJpeg,
}) async {
  final files = <ChatOutgoingFile>[];
  final errors = <String>[];
  for (final file in picked) {
    final name = file.name;
    final mime = file.mimeType;
    if (hasHeicName(name) || heicMimeTypes.contains(mime?.toLowerCase())) {
      final result = await _heic(await file.readAsBytes(), name, mime, policy, l10n, heic);
      result is ChatOutgoingFile ? files.add(result) : errors.add(result as String);
      continue;
    }
    final match = policy.match(name: name, mime: mime);
    if (match == null) {
      errors.add(l10n.attachmentFormatRejected(name, acceptedFormatsLabel(policy)));
      continue;
    }
    final rule = match.rule;
    if (match.kind == CommunityAttachmentKind.image) {
      final image = await _image(await file.readAsBytes(), name, policy, l10n);
      image is ChatOutgoingFile ? files.add(image) : errors.add(image as String);
      continue;
    }
    final length = await _length(file);
    if (rule.maxBytes > 0 && length > rule.maxBytes) {
      errors.add(l10n.attachmentFileTooLarge(name, attachmentLimitLabel(rule.maxBytes)));
      continue;
    }
    files.add(
      ChatOutgoingFile(
        bytes: await file.readAsBytes(),
        mimeType: match.format.mime,
        name: name,
        kind: match.kind,
        format: match.format,
      ),
    );
  }
  return AttachmentPickResult(files, errors);
}

Future<int> _length(XFile file) async {
  try {
    return await file.length();
  } on Object {
    return _anyLength;
  }
}

Future<Object> _heic(
  Uint8List bytes,
  String name,
  String? mime,
  CommunityAttachmentPolicy policy,
  CommunityLocalizations l10n,
  JpegConverter heic,
) async {
  switch (heicConversionFor(bytes, name: name, mimeType: mime, acceptsJpeg: policy.acceptsJpeg)) {
    case HeicConversion.none:
      return _image(bytes, name, policy, l10n);
    case HeicConversion.notAccepted:
      return l10n.attachmentFormatRejected(name, acceptedFormatsLabel(policy));
    case HeicConversion.convert:
      final jpeg = await heic(bytes, maxBytes: _imageLimit(policy));
      if (jpeg == null) return l10n.heicUnsupported;
      return ChatOutgoingFile(bytes: jpeg.bytes, mimeType: jpeg.mimeType, name: _jpegName(name));
  }
}

Future<Object> _image(
  Uint8List bytes,
  String name,
  CommunityAttachmentPolicy policy,
  CommunityLocalizations l10n,
) async {
  final image = await preparePastedImage(bytes, maxBytes: _imageLimit(policy));
  if (image == null) return l10n.imageTooLarge;
  if (policy.images.formatFor(mime: image.mimeType) == null) {
    return l10n.attachmentFormatRejected(name, acceptedFormatsLabel(policy));
  }
  return ChatOutgoingFile(bytes: image.bytes, mimeType: image.mimeType, name: name);
}

int _imageLimit(CommunityAttachmentPolicy policy) {
  final max = policy.images.maxBytes;
  return max > 0 ? max : maxChatImageBytes;
}

String _jpegName(String name) {
  final dot = name.lastIndexOf('.');
  return '${dot < 0 ? name : name.substring(0, dot)}.jpg';
}
