import 'package:freezed_annotation/freezed_annotation.dart';

part 'help_article.freezed.dart';

@freezed
abstract class HelpFeedback with _$HelpFeedback {
  const factory HelpFeedback({required bool helpful, String? comment}) = _HelpFeedback;
}

@freezed
abstract class HelpArticle with _$HelpArticle {
  const factory HelpArticle({
    required String id,
    required String category,
    required String question,
    required String answer,
    String? topic,
    DateTime? updatedAt,
    HelpFeedback? feedback,
  }) = _HelpArticle;
}

@freezed
abstract class HelpCategory with _$HelpCategory {
  const factory HelpCategory({
    required String code,
    required String name,
    String? icon,
    @Default(<HelpArticle>[]) List<HelpArticle> articles,
  }) = _HelpCategory;
}

@freezed
abstract class HelpCenterContent with _$HelpCenterContent {
  const factory HelpCenterContent({
    @Default(<HelpCategory>[]) List<HelpCategory> categories,
    DateTime? updatedAt,
    DateTime? savedAt,
  }) = _HelpCenterContent;

  const HelpCenterContent._();

  bool get isEmpty => categories.every((category) => category.articles.isEmpty);

  bool get fromCache => savedAt != null;

  List<HelpArticle> get articles => [for (final category in categories) ...category.articles];

  HelpCategory? category(String code) => categories.where((category) => category.code == code).firstOrNull;

  List<HelpArticle> search(String query, {int limit = 20}) {
    final words = [
      for (final word in query.toLowerCase().trim().split(RegExp(r'\s+')))
        if (word.length >= 2) word,
    ].take(6).toList();
    if (words.isEmpty) return const [];
    final scored = <({HelpArticle article, int rank})>[];
    for (final article in articles) {
      final question = article.question.toLowerCase();
      final text = '$question ${article.answer.toLowerCase()}';
      if (!words.every(text.contains)) continue;
      scored.add((article: article, rank: words.where(question.contains).length));
    }
    scored.sort((a, b) => b.rank.compareTo(a.rank));
    return [for (final entry in scored.take(limit)) entry.article];
  }
}
