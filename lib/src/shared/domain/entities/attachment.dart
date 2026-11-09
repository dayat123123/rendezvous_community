import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';

part 'attachment.freezed.dart';

@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    required String path,
    String? bucket,
    String? mime,
    String? name,
    int? size,
    int? width,
    int? height,
    double? duration,
    String? thumbnail,
    @Default(false) bool held,
  }) = _Attachment;

  const Attachment._();

  bool get isVideo => bucket == supportVideoBucket || (mime?.startsWith('video/') ?? false);

  bool get isDocument => !isVideo && (bucket == supportDocumentBucket || mime == pdfMimeType);

  bool get isImage => !isVideo && !isDocument;
}
