import 'dart:async';

import 'package:rendezvous_community/rendezvous_community.dart';

const helpImageUrl =
    'https://olt.example.co.id/storage/v1/object/public/faq-images/3f2b8c1e-5d4a-4b6f-9e21-7a0c9d8e1f23.png';

final helpUpdatedAt = DateTime.utc(2026, 11, 3, 2);

const pinArticle = HelpArticle(
  id: 'a-pin',
  category: 'account',
  question: 'Bagaimana cara mengganti PIN?',
  answer:
      'Buka **Profil** lalu pilih *Keamanan*.\n\n1. Ketuk Ganti PIN\n2. Masukkan PIN lama\n\nPanduan lengkap: [pusat bantuan](https://olt.example.co.id/bantuan).',
  topic: 'account',
);

const loginArticle = HelpArticle(
  id: 'a-login',
  category: 'account',
  question: 'Tidak bisa masuk ke aplikasi',
  answer: 'Pastikan nomor HP sudah terdaftar.\n\n- Periksa sinyal\n- Perbarui aplikasi',
  topic: 'account',
);

const depositArticle = HelpArticle(
  id: 'a-deposit',
  category: 'funds',
  question: 'Berapa lama dana deposit masuk?',
  answer: 'Dana masuk paling lambat **1 jam kerja** setelah transfer.',
  topic: 'funds',
);

HelpCenterContent helpContent({DateTime? savedAt}) => HelpCenterContent(
  categories: const [
    HelpCategory(code: 'account', name: 'Akun & Keamanan', icon: 'shield', articles: [pinArticle, loginArticle]),
    HelpCategory(code: 'funds', name: 'Dana', icon: 'wallet', articles: [depositArticle]),
  ],
  updatedAt: helpUpdatedAt,
  savedAt: savedAt,
);

class FakeHelpRepository implements HelpRepository {
  FakeHelpRepository({HelpCenterContent? content, this.cached, this.suggestions = const []})
    : content = content ?? helpContent();

  HelpCenterContent content;
  HelpCenterContent? cached;
  List<HelpArticle> suggestions;
  Object? centerError;
  Object? searchError;
  Object? articleError;
  Object? feedbackError;
  Object? suggestionError;
  Completer<List<HelpArticle>>? holdSuggestions;
  List<HelpArticle>? searchResults;
  final searches = <String>[];
  final feedback = <({String articleId, bool helpful, String? comment})>[];
  final topicLookups = <String>[];
  final articleReads = <String>[];
  final feedbackByArticle = <String, HelpFeedback>{};

  @override
  Future<HelpCenterContent> helpCenter({String language = 'id'}) async {
    final error = centerError;
    if (error != null) throw error;
    return content;
  }

  @override
  Future<HelpCenterContent?> cachedHelpCenter({String language = 'id'}) async => cached;

  @override
  Future<List<HelpArticle>> search(String query, {String language = 'id'}) async {
    searches.add(query);
    final error = searchError;
    if (error != null) throw error;
    return searchResults ?? content.search(query);
  }

  @override
  Future<HelpArticle> article(String id, {String language = 'id'}) async {
    articleReads.add(id);
    final error = articleError;
    if (error != null) throw error;
    final article = content.articles.firstWhere((a) => a.id == id);
    return article.copyWith(feedback: feedbackByArticle[id]);
  }

  @override
  Future<HelpFeedback> sendFeedback(String articleId, {required bool helpful, String? comment}) async {
    final error = feedbackError;
    if (error != null) throw error;
    feedback.add((articleId: articleId, helpful: helpful, comment: comment));
    return feedbackByArticle[articleId] = HelpFeedback(helpful: helpful, comment: comment);
  }

  @override
  Future<List<HelpArticle>> articlesForTopic(String topic, {String language = 'id', int limit = 3}) async {
    topicLookups.add(topic);
    final error = suggestionError;
    if (error != null) throw error;
    final hold = holdSuggestions;
    if (hold != null) return hold.future;
    return suggestions;
  }
}

class FakeHelpDependencies implements CommunityHelpDependencies {
  FakeHelpDependencies(this.help);

  @override
  final HelpRepository help;
}
