import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/help/data/repositories/help_repository_impl.dart';

import '../../support/mock_api.dart';

Map<String, dynamic> articleJson(String id, {String category = 'account', String? topic = 'account'}) => {
  'id': id,
  'category': category,
  'question': 'Pertanyaan $id',
  'answer': 'Jawaban **$id**',
  'topic': topic,
  'updated_at': '2026-11-03T02:00:00+00:00',
};

Map<String, dynamic> faqJson() => {
  'categories': [
    {
      'code': 'account',
      'name': 'Akun & Keamanan',
      'icon': 'shield',
      'articles': [articleJson('a-1'), articleJson('a-2', topic: null)],
    },
    {'code': 'empty', 'name': 'Kosong', 'icon': null, 'articles': null},
  ],
  'updated_at': '2026-11-03T02:00:00+00:00',
};

class _BrokenValues implements LocalValues {
  @override
  Future<Map<String, dynamic>?> read(String key) async => throw StateError('disk');

  @override
  Future<void> write(String key, Map<String, dynamic> value) async => throw StateError('disk');
}

void main() {
  late MockApi cs;
  late MemoryLocalValues values;
  late HelpRepositoryImpl repo;
  final clock = DateTime.utc(2026, 11, 9, 8);

  setUp(() {
    cs = mockApi();
    values = MemoryLocalValues();
    repo = HelpRepositoryImpl(cs: cs, cache: values, clock: () => clock);
  });

  test('help center maps categories and articles and skips empty categories', () async {
    when(() => cs.rpcValue('faq', {'p_language': 'id'})).thenAnswer((_) async => faqJson());

    final content = await repo.helpCenter();

    expect(content.categories.map((c) => c.code), ['account']);
    final category = content.categories.single;
    expect(category.name, 'Akun & Keamanan');
    expect(category.icon, 'shield');
    expect(category.articles.map((a) => a.id), ['a-1', 'a-2']);
    expect(category.articles.first.topic, 'account');
    expect(category.articles.last.topic, isNull);
    expect(category.articles.first.updatedAt, DateTime.utc(2026, 11, 3, 2));
    expect(content.updatedAt, DateTime.utc(2026, 11, 3, 2));
    expect(content.fromCache, isFalse);
  });

  test('a successful help center response is cached per language and read back offline', () async {
    when(() => cs.rpcValue('faq', {'p_language': 'en'})).thenAnswer((_) async => faqJson());

    expect(await repo.cachedHelpCenter(language: 'en'), isNull);
    await repo.helpCenter(language: 'en');

    expect(await repo.cachedHelpCenter(), isNull);
    final cached = await repo.cachedHelpCenter(language: 'en');
    expect(cached?.categories.single.articles, hasLength(2));
    expect(cached?.savedAt, clock);
    expect(cached?.fromCache, isTrue);
  });

  test('an unknown cache version or broken storage is ignored', () async {
    await values.write(HelpRepositoryImpl.cacheKey('id'), {'version': 99, 'data': faqJson()});
    expect(await repo.cachedHelpCenter(), isNull);

    final broken = HelpRepositoryImpl(cs: cs, cache: _BrokenValues());
    when(() => cs.rpcValue('faq', any())).thenAnswer((_) async => faqJson());
    expect((await broken.helpCenter()).categories, hasLength(1));
    expect(await broken.cachedHelpCenter(), isNull);
  });

  test('search, article with feedback, and articles for a topic', () async {
    when(
      () => cs.rpcValue('faq_search', {'p_query': 'pin', 'p_language': 'id'}),
    ).thenAnswer((_) async => [articleJson('a-1')]);
    when(() => cs.rpcValue('faq_article', {'p_id': 'a-1', 'p_language': 'id'})).thenAnswer(
      (_) async => {
        ...articleJson('a-1'),
        'feedback': {'helpful': false, 'comment': '  '},
      },
    );
    when(
      () => cs.rpcValue('faq_for_topic', {'p_topic': 'account', 'p_language': 'id', 'p_limit': 3}),
    ).thenAnswer((_) async => [articleJson('a-1'), articleJson('a-2')]);

    expect((await repo.search('  pin ')).single.id, 'a-1');
    final article = await repo.article('a-1');
    expect(article.feedback, const HelpFeedback(helpful: false));
    expect((await repo.articlesForTopic('account')).map((a) => a.id), ['a-1', 'a-2']);
  });

  test('attachments become public faq-files URLs and unknown paths are dropped', () async {
    when(
      () => cs.publicUrl('faq-files', any()),
    ).thenAnswer((call) => 'https://api.olt.test/storage/v1/object/public/faq-files/${call.positionalArguments[1]}');
    when(() => cs.rpcValue('faq_article', {'p_id': 'a-1', 'p_language': 'id'})).thenAnswer(
      (_) async => {
        ...articleJson('a-1'),
        'attachments': [
          {
            'path': '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf',
            'name': '  Formulir  ',
            'kind': 'image',
            'mime': 'application/pdf',
            'size': 204800,
          },
          {'path': '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e03.mov', 'name': '', 'size': -1},
          {'path': '../../etc/passwd.pdf', 'name': 'jahat'},
          {'path': '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e04.exe', 'name': 'program'},
        ],
      },
    );

    final article = await repo.article('a-1');

    expect(article.attachments, hasLength(2));
    final pdf = article.attachments.first;
    expect(pdf.kind, HelpAttachmentKind.document);
    expect(pdf.name, 'Formulir');
    expect(pdf.size, 204800);
    expect(
      pdf.url.toString(),
      'https://api.olt.test/storage/v1/object/public/faq-files/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf',
    );
    final video = article.attachments.last;
    expect(video.kind, HelpAttachmentKind.video);
    expect(video.name, '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e03.mov');
    expect(video.size, isNull);
  });

  test('the cached help center keeps attachments for offline reading', () async {
    when(
      () => cs.publicUrl('faq-files', any()),
    ).thenAnswer((call) => 'https://cdn.test/${call.positionalArguments[1]}');
    when(() => cs.rpcValue('faq', {'p_language': 'id'})).thenAnswer(
      (_) async => {
        'categories': [
          {
            'code': 'account',
            'name': 'Akun',
            'articles': [
              {
                ...articleJson('a-1'),
                'attachments': [
                  {'path': '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png', 'name': 'Contoh'},
                ],
              },
            ],
          },
        ],
      },
    );

    await repo.helpCenter();
    final cached = await repo.cachedHelpCenter();

    final attachment = cached!.articles.single.attachments.single;
    expect(attachment.kind, HelpAttachmentKind.image);
    expect(attachment.url, Uri.parse('https://cdn.test/0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e02.png'));
  });

  test('attachments are skipped when the storage URL cannot be built', () async {
    when(() => cs.publicUrl(any(), any())).thenThrow(StateError('no storage'));
    when(() => cs.rpcValue('faq_article', any())).thenAnswer(
      (_) async => {
        ...articleJson('a-1'),
        'attachments': [
          {'path': '0b6c1a52-3f4e-4c1d-9a7e-2f1b3c4d5e01.pdf', 'name': 'Formulir'},
        ],
      },
    );

    final article = await repo.article('a-1');
    expect(article.attachments, isEmpty);
    expect(article.question, 'Pertanyaan a-1');
  });

  test('feedback trims the comment and sends null for an empty one', () async {
    when(() => cs.rpcValue('faq_feedback', any())).thenAnswer((_) async => {'helpful': true, 'comment': 'Jelas'});

    final feedback = await repo.sendFeedback('a-1', helpful: true, comment: '  Jelas ');
    await repo.sendFeedback('a-1', helpful: true, comment: '   ');

    expect(feedback, const HelpFeedback(helpful: true, comment: 'Jelas'));
    verify(
      () => cs.rpcValue('faq_feedback', {'p_article_id': 'a-1', 'p_helpful': true, 'p_comment': 'Jelas'}),
    ).called(1);
    verify(() => cs.rpcValue('faq_feedback', {'p_article_id': 'a-1', 'p_helpful': true, 'p_comment': null})).called(1);
  });

  test('local search matches every word and ranks question matches first', () {
    final content = HelpCenterContent(
      categories: [
        HelpCategory(
          code: 'c',
          name: 'C',
          articles: [
            const HelpArticle(id: '1', category: 'c', question: 'Deposit dana', answer: 'Lewat bank'),
            const HelpArticle(id: '2', category: 'c', question: 'Tarik', answer: 'Dana ditarik lewat bank'),
            const HelpArticle(id: '3', category: 'c', question: 'PIN', answer: 'Ganti PIN'),
          ],
        ),
      ],
    );
    expect(content.search('dana bank').map((a) => a.id), ['1', '2']);
    expect(content.search('x'), isEmpty);
  });
}
