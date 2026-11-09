import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';

abstract interface class HelpRepository {
  Future<HelpCenterContent> helpCenter({String language = 'id'});

  Future<HelpCenterContent?> cachedHelpCenter({String language = 'id'});

  Future<List<HelpArticle>> search(String query, {String language = 'id'});

  Future<HelpArticle> article(String id, {String language = 'id'});

  Future<HelpFeedback> sendFeedback(String articleId, {required bool helpful, String? comment});

  Future<List<HelpArticle>> articlesForTopic(String topic, {String language = 'id', int limit = 3});
}
