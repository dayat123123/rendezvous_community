import 'dart:typed_data';

import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';

class ChatOutgoingFile {
  const ChatOutgoingFile({
    required this.bytes,
    required this.mimeType,
    this.name,
    bool document = false,
    CommunityAttachmentKind? kind,
    this.format,
  }) : kind = kind ?? (document ? CommunityAttachmentKind.document : CommunityAttachmentKind.image);

  final Uint8List bytes;
  final String mimeType;
  final String? name;
  final CommunityAttachmentKind kind;
  final CommunityAttachmentFormat? format;

  bool get document => kind == CommunityAttachmentKind.document;

  bool get video => kind == CommunityAttachmentKind.video;

  int get size => bytes.length;
}
