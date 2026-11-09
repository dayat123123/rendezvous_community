import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/help/data/models/help_models.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';

class HelpRepositoryImpl implements HelpRepository {
  HelpRepositoryImpl({required this._cs, required this._cache, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const cacheVersion = 1;

  final SocialRemoteDataSource _cs;
  final LocalValues _cache;
  final DateTime Function() _clock;

  static String cacheKey(String language) => 'help_center_$language';

  static String _language(String language) => language == 'en' ? 'en' : 'id';

  HelpArticle _article(Object? json) => HelpArticleModel.fromJson(json! as Map<String, dynamic>).toEntity();

  List<HelpArticle> _articles(Object? rows) => [
    for (final row in rows as List<Object?>? ?? const <Object?>[]) _article(row),
  ];

  @override
  Future<HelpCenterContent> helpCenter({String language = 'id'}) async {
    final lang = _language(language);
    final raw = (await _cs.rpcValue('faq', {'p_language': lang})) as Map<String, dynamic>? ?? const {};
    final content = HelpCenterModel.fromJson(raw).toEntity();
    try {
      await _cache.write(cacheKey(lang), {
        'version': cacheVersion,
        'saved_at': _clock().toUtc().toIso8601String(),
        'data': raw,
      });
    } catch (e) {
      CommunityLoggers.offline.event(
        Level.WARNING,
        'Help center cache write failed',
        fields: {'errorType': e.runtimeType.toString()},
        error: e,
      );
    }
    return content;
  }

  @override
  Future<HelpCenterContent?> cachedHelpCenter({String language = 'id'}) async {
    try {
      final stored = await _cache.read(cacheKey(_language(language)));
      if (stored == null || stored['version'] != cacheVersion) return null;
      final data = stored['data'];
      if (data is! Map<String, dynamic>) return null;
      final savedAt = DateTime.tryParse(stored['saved_at'] as String? ?? '') ?? _clock().toUtc();
      return HelpCenterModel.fromJson(data).toEntity(savedAt: savedAt);
    } catch (e) {
      CommunityLoggers.offline.event(
        Level.WARNING,
        'Help center cache unreadable',
        fields: {'errorType': e.runtimeType.toString()},
        error: e,
      );
      return null;
    }
  }

  @override
  Future<List<HelpArticle>> search(String query, {String language = 'id'}) async =>
      _articles(await _cs.rpcValue('faq_search', {'p_query': query.trim(), 'p_language': _language(language)}));

  @override
  Future<HelpArticle> article(String id, {String language = 'id'}) async =>
      _article(await _cs.rpcValue('faq_article', {'p_id': id, 'p_language': _language(language)}));

  @override
  Future<HelpFeedback> sendFeedback(String articleId, {required bool helpful, String? comment}) async {
    final text = comment?.trim();
    final result = await _cs.rpcValue('faq_feedback', {
      'p_article_id': articleId,
      'p_helpful': helpful,
      'p_comment': text == null || text.isEmpty ? null : text,
    });
    CommunityLoggers.support.event(
      Level.INFO,
      'Help article feedback sent',
      fields: {'articleId': articleId, 'helpful': helpful, 'hasComment': text != null && text.isNotEmpty},
    );
    return HelpFeedbackModel.fromJson(result! as Map<String, dynamic>).toEntity();
  }

  @override
  Future<List<HelpArticle>> articlesForTopic(String topic, {String language = 'id', int limit = 3}) async => _articles(
    await _cs.rpcValue('faq_for_topic', {'p_topic': topic, 'p_language': _language(language), 'p_limit': limit}),
  );
}
