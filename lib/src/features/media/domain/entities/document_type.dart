import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';

enum CommunityDocumentType { pdf, word, excel, powerPoint, csv, text, other }

CommunityDocumentType documentTypeOf(Attachment attachment) {
  final mime = attachment.mime?.toLowerCase() ?? '';
  final byMime = switch (mime) {
    pdfMimeType => CommunityDocumentType.pdf,
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => CommunityDocumentType.word,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => CommunityDocumentType.excel,
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => CommunityDocumentType.powerPoint,
    'text/csv' => CommunityDocumentType.csv,
    'text/plain' => CommunityDocumentType.text,
    _ => null,
  };
  if (byMime != null) return byMime;
  final name = (attachment.name?.isNotEmpty ?? false) ? attachment.name! : attachment.path;
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  return switch (ext) {
    'pdf' => CommunityDocumentType.pdf,
    'docx' => CommunityDocumentType.word,
    'xlsx' => CommunityDocumentType.excel,
    'pptx' => CommunityDocumentType.powerPoint,
    'csv' => CommunityDocumentType.csv,
    'txt' => CommunityDocumentType.text,
    _ => CommunityDocumentType.other,
  };
}
