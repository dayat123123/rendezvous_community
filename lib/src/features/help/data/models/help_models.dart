import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';

part 'help_models.freezed.dart';
part 'help_models.g.dart';

typedef HelpFileUrl = Uri? Function(String path);

const helpFilesBucket = 'faq-files';

final _helpFilePath = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(pdf|jpg|png|webp|mp4|webm|mov)$',
);

const _kindByExtension = {
  'pdf': HelpAttachmentKind.document,
  'jpg': HelpAttachmentKind.image,
  'png': HelpAttachmentKind.image,
  'webp': HelpAttachmentKind.image,
  'mp4': HelpAttachmentKind.video,
  'webm': HelpAttachmentKind.video,
  'mov': HelpAttachmentKind.video,
};

@freezed
abstract class HelpFeedbackModel with _$HelpFeedbackModel {
  const factory HelpFeedbackModel({required bool helpful, String? comment}) = _HelpFeedbackModel;

  const HelpFeedbackModel._();

  factory HelpFeedbackModel.fromJson(Map<String, dynamic> json) => _$HelpFeedbackModelFromJson(json);

  HelpFeedback toEntity() {
    final text = comment?.trim();
    return HelpFeedback(helpful: helpful, comment: text == null || text.isEmpty ? null : text);
  }
}

@freezed
abstract class HelpAttachmentModel with _$HelpAttachmentModel {
  const factory HelpAttachmentModel({@Default('') String path, @Default('') String name, String? mime, int? size}) =
      _HelpAttachmentModel;

  const HelpAttachmentModel._();

  factory HelpAttachmentModel.fromJson(Map<String, dynamic> json) => _$HelpAttachmentModelFromJson(json);

  HelpAttachment? toEntity(HelpFileUrl fileUrl) {
    final match = _helpFilePath.firstMatch(path);
    if (match == null) return null;
    final url = fileUrl(path);
    if (url == null) return null;
    final label = name.trim();
    return HelpAttachment(
      path: path,
      url: url,
      name: label.isEmpty ? path : label,
      kind: _kindByExtension[match.group(1)]!,
      mime: mime,
      size: size == null || size! < 0 ? null : size,
    );
  }
}

@freezed
abstract class HelpArticleModel with _$HelpArticleModel {
  const factory HelpArticleModel({
    required String id,
    @Default('') String category,
    @Default('') String question,
    @Default('') String answer,
    String? topic,
    DateTime? updatedAt,
    HelpFeedbackModel? feedback,
    @Default(<HelpAttachmentModel>[]) List<HelpAttachmentModel> attachments,
  }) = _HelpArticleModel;

  const HelpArticleModel._();

  factory HelpArticleModel.fromJson(Map<String, dynamic> json) => _$HelpArticleModelFromJson(json);

  HelpArticle toEntity({HelpFileUrl? fileUrl}) => HelpArticle(
    id: id,
    category: category,
    question: question,
    answer: answer,
    topic: topic == null || topic!.isEmpty ? null : topic,
    updatedAt: updatedAt,
    feedback: feedback?.toEntity(),
    attachments: fileUrl == null
        ? const []
        : [
            for (final attachment in attachments.take(10))
              if (attachment.toEntity(fileUrl) case final HelpAttachment entity) entity,
          ],
  );
}

@freezed
abstract class HelpCategoryModel with _$HelpCategoryModel {
  const factory HelpCategoryModel({
    required String code,
    @Default('') String name,
    String? icon,
    @Default(<HelpArticleModel>[]) List<HelpArticleModel> articles,
  }) = _HelpCategoryModel;

  const HelpCategoryModel._();

  factory HelpCategoryModel.fromJson(Map<String, dynamic> json) => _$HelpCategoryModelFromJson(json);

  HelpCategory toEntity({HelpFileUrl? fileUrl}) => HelpCategory(
    code: code,
    name: name,
    icon: icon,
    articles: [for (final a in articles) a.toEntity(fileUrl: fileUrl)],
  );
}

@freezed
abstract class HelpCenterModel with _$HelpCenterModel {
  const factory HelpCenterModel({
    @Default(<HelpCategoryModel>[]) List<HelpCategoryModel> categories,
    DateTime? updatedAt,
  }) = _HelpCenterModel;

  const HelpCenterModel._();

  factory HelpCenterModel.fromJson(Map<String, dynamic> json) => _$HelpCenterModelFromJson(json);

  HelpCenterContent toEntity({DateTime? savedAt, HelpFileUrl? fileUrl}) => HelpCenterContent(
    categories: [
      for (final category in categories)
        if (category.articles.isNotEmpty) category.toEntity(fileUrl: fileUrl),
    ],
    updatedAt: updatedAt,
    savedAt: savedAt,
  );
}
