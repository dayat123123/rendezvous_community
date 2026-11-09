import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';

part 'help_models.freezed.dart';
part 'help_models.g.dart';

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
abstract class HelpArticleModel with _$HelpArticleModel {
  const factory HelpArticleModel({
    required String id,
    @Default('') String category,
    @Default('') String question,
    @Default('') String answer,
    String? topic,
    DateTime? updatedAt,
    HelpFeedbackModel? feedback,
  }) = _HelpArticleModel;

  const HelpArticleModel._();

  factory HelpArticleModel.fromJson(Map<String, dynamic> json) => _$HelpArticleModelFromJson(json);

  HelpArticle toEntity() => HelpArticle(
    id: id,
    category: category,
    question: question,
    answer: answer,
    topic: topic == null || topic!.isEmpty ? null : topic,
    updatedAt: updatedAt,
    feedback: feedback?.toEntity(),
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

  HelpCategory toEntity() =>
      HelpCategory(code: code, name: name, icon: icon, articles: [for (final a in articles) a.toEntity()]);
}

@freezed
abstract class HelpCenterModel with _$HelpCenterModel {
  const factory HelpCenterModel({
    @Default(<HelpCategoryModel>[]) List<HelpCategoryModel> categories,
    DateTime? updatedAt,
  }) = _HelpCenterModel;

  const HelpCenterModel._();

  factory HelpCenterModel.fromJson(Map<String, dynamic> json) => _$HelpCenterModelFromJson(json);

  HelpCenterContent toEntity({DateTime? savedAt}) => HelpCenterContent(
    categories: [
      for (final category in categories)
        if (category.articles.isNotEmpty) category.toEntity(),
    ],
    updatedAt: updatedAt,
    savedAt: savedAt,
  );
}
