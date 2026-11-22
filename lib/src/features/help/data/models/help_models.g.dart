// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HelpFeedbackModel _$HelpFeedbackModelFromJson(Map<String, dynamic> json) =>
    _HelpFeedbackModel(helpful: json['helpful'] as bool, comment: json['comment'] as String?);

Map<String, dynamic> _$HelpFeedbackModelToJson(_HelpFeedbackModel instance) => <String, dynamic>{
  'helpful': instance.helpful,
  'comment': instance.comment,
};

_HelpAttachmentModel _$HelpAttachmentModelFromJson(Map<String, dynamic> json) => _HelpAttachmentModel(
  path: json['path'] as String? ?? '',
  name: json['name'] as String? ?? '',
  mime: json['mime'] as String?,
  size: (json['size'] as num?)?.toInt(),
);

Map<String, dynamic> _$HelpAttachmentModelToJson(_HelpAttachmentModel instance) => <String, dynamic>{
  'path': instance.path,
  'name': instance.name,
  'mime': instance.mime,
  'size': instance.size,
};

_HelpArticleModel _$HelpArticleModelFromJson(Map<String, dynamic> json) => _HelpArticleModel(
  id: json['id'] as String,
  category: json['category'] as String? ?? '',
  question: json['question'] as String? ?? '',
  answer: json['answer'] as String? ?? '',
  topic: json['topic'] as String?,
  updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
  feedback: json['feedback'] == null ? null : HelpFeedbackModel.fromJson(json['feedback'] as Map<String, dynamic>),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => HelpAttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HelpAttachmentModel>[],
);

Map<String, dynamic> _$HelpArticleModelToJson(_HelpArticleModel instance) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'question': instance.question,
  'answer': instance.answer,
  'topic': instance.topic,
  'updated_at': instance.updatedAt?.toIso8601String(),
  'feedback': instance.feedback?.toJson(),
  'attachments': instance.attachments.map((e) => e.toJson()).toList(),
};

_HelpCategoryModel _$HelpCategoryModelFromJson(Map<String, dynamic> json) => _HelpCategoryModel(
  code: json['code'] as String,
  name: json['name'] as String? ?? '',
  icon: json['icon'] as String?,
  articles:
      (json['articles'] as List<dynamic>?)?.map((e) => HelpArticleModel.fromJson(e as Map<String, dynamic>)).toList() ??
      const <HelpArticleModel>[],
);

Map<String, dynamic> _$HelpCategoryModelToJson(_HelpCategoryModel instance) => <String, dynamic>{
  'code': instance.code,
  'name': instance.name,
  'icon': instance.icon,
  'articles': instance.articles.map((e) => e.toJson()).toList(),
};

_HelpCenterModel _$HelpCenterModelFromJson(Map<String, dynamic> json) => _HelpCenterModel(
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => HelpCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HelpCategoryModel>[],
  updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$HelpCenterModelToJson(_HelpCenterModel instance) => <String, dynamic>{
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
