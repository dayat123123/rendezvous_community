import 'package:rendezvous_community/src/core/media/image_mime.dart';

enum CommunityAttachmentKind { document, image, video }

class CommunityAttachmentFormat {
  const CommunityAttachmentFormat({required this.code, required this.mime, required this.extension});

  final String code;
  final String mime;
  final String extension;

  List<String> get extensions => switch (code) {
    'jpeg' => const ['jpg', 'jpeg'],
    _ => [extension],
  };

  @override
  bool operator ==(Object other) =>
      other is CommunityAttachmentFormat && other.code == code && other.mime == mime && other.extension == extension;

  @override
  int get hashCode => Object.hash(code, mime, extension);
}

class CommunityAttachmentRule {
  const CommunityAttachmentRule({
    required this.kind,
    required this.enabled,
    required this.bucket,
    required this.maxBytes,
    this.maxSeconds,
    this.formats = const [],
  });

  const CommunityAttachmentRule.disabled(this.kind, this.bucket)
    : enabled = false,
      maxBytes = 0,
      maxSeconds = null,
      formats = const [];

  final CommunityAttachmentKind kind;
  final bool enabled;
  final String bucket;
  final int maxBytes;
  final int? maxSeconds;
  final List<CommunityAttachmentFormat> formats;

  bool get usable => enabled && formats.isNotEmpty;

  List<String> get extensions => [for (final f in formats) ...f.extensions];

  List<String> get mimeTypes => [for (final f in formats) f.mime];

  int get maxMegabytes => (maxBytes / (1024 * 1024)).ceil();

  CommunityAttachmentFormat? formatFor({String? name, String? mime}) {
    final ext = _extension(name);
    if (ext != null) {
      for (final f in formats) {
        if (f.extensions.contains(ext)) return f;
      }
    }
    final reported = mime?.toLowerCase();
    if (reported == null || reported.isEmpty) return null;
    for (final f in formats) {
      if (f.mime == reported) return f;
    }
    return null;
  }
}

class CommunityAttachmentMatch {
  const CommunityAttachmentMatch(this.rule, this.format);

  final CommunityAttachmentRule rule;
  final CommunityAttachmentFormat format;

  CommunityAttachmentKind get kind => rule.kind;
}

class CommunityAttachmentPolicy {
  const CommunityAttachmentPolicy({required this.documents, required this.images, required this.videos});

  static const legacy = CommunityAttachmentPolicy(
    documents: CommunityAttachmentRule(
      kind: CommunityAttachmentKind.document,
      enabled: true,
      bucket: supportDocumentBucket,
      maxBytes: maxSupportDocumentBytes,
      formats: [CommunityAttachmentFormat(code: 'pdf', mime: pdfMimeType, extension: 'pdf')],
    ),
    images: CommunityAttachmentRule(
      kind: CommunityAttachmentKind.image,
      enabled: true,
      bucket: attachmentBucket,
      maxBytes: 5 * 1024 * 1024,
      formats: _imageFormats,
    ),
    videos: CommunityAttachmentRule.disabled(CommunityAttachmentKind.video, supportVideoBucket),
  );

  static const imagesOnly = CommunityAttachmentPolicy(
    documents: CommunityAttachmentRule.disabled(CommunityAttachmentKind.document, supportDocumentBucket),
    images: CommunityAttachmentRule(
      kind: CommunityAttachmentKind.image,
      enabled: true,
      bucket: attachmentBucket,
      maxBytes: 5 * 1024 * 1024,
      formats: _imageFormats,
    ),
    videos: CommunityAttachmentRule.disabled(CommunityAttachmentKind.video, supportVideoBucket),
  );

  factory CommunityAttachmentPolicy.fromJson(Map<String, dynamic> json) => CommunityAttachmentPolicy(
    documents: _rule(json['documents'], CommunityAttachmentKind.document, supportDocumentBucket),
    images: _rule(json['images'], CommunityAttachmentKind.image, attachmentBucket),
    videos: _rule(json['videos'], CommunityAttachmentKind.video, supportVideoBucket),
  );

  final CommunityAttachmentRule documents;
  final CommunityAttachmentRule images;
  final CommunityAttachmentRule videos;

  List<CommunityAttachmentRule> get rules => [images, videos, documents];

  CommunityAttachmentRule rule(CommunityAttachmentKind kind) => switch (kind) {
    CommunityAttachmentKind.document => documents,
    CommunityAttachmentKind.image => images,
    CommunityAttachmentKind.video => videos,
  };

  bool get acceptsJpeg => images.usable && images.formats.any((f) => f.code == 'jpeg');

  bool get onlyPdfDocuments => documents.formats.every((f) => f.code == 'pdf');

  CommunityAttachmentMatch? match({String? name, String? mime}) {
    for (final rule in rules) {
      if (!rule.usable) continue;
      final format = rule.formatFor(name: name, mime: mime);
      if (format != null) return CommunityAttachmentMatch(rule, format);
    }
    return null;
  }

  static CommunityAttachmentRule _rule(Object? value, CommunityAttachmentKind kind, String fallbackBucket) {
    if (value is! Map) return CommunityAttachmentRule.disabled(kind, fallbackBucket);
    final formats = value['formats'];
    return CommunityAttachmentRule(
      kind: kind,
      enabled: value['enabled'] == true,
      bucket: value['bucket'] is String ? value['bucket'] as String : fallbackBucket,
      maxBytes: (value['max_bytes'] as num?)?.toInt() ?? 0,
      maxSeconds: (value['max_seconds'] as num?)?.toInt(),
      formats: [
        if (formats is List)
          for (final f in formats)
            if (f is Map && f['code'] is String && f['mime'] is String && f['ext'] is String)
              CommunityAttachmentFormat(
                code: f['code'] as String,
                mime: (f['mime'] as String).toLowerCase(),
                extension: (f['ext'] as String).toLowerCase(),
              ),
      ],
    );
  }
}

const _imageFormats = [
  CommunityAttachmentFormat(code: 'jpeg', mime: 'image/jpeg', extension: 'jpg'),
  CommunityAttachmentFormat(code: 'png', mime: 'image/png', extension: 'png'),
  CommunityAttachmentFormat(code: 'webp', mime: 'image/webp', extension: 'webp'),
  CommunityAttachmentFormat(code: 'gif', mime: gifMimeType, extension: 'gif'),
];

String? _extension(String? name) {
  if (name == null) return null;
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return null;
  return name.substring(dot + 1).toLowerCase();
}
