import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';

import '../../../support/fakes.dart';
import '../../../support/legal_fakes.dart';

class _Feed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged([
    Post(
      id: 'p-1',
      author: alice,
      body: r'Analisis $BBCA hari ini',
      commentCount: 5,
      createdAt: now.subtract(const Duration(hours: 1)),
      cursor: 'c',
    ),
  ]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Comments extends FakeCommentRepository implements SortedCommentRepository {
  _Comments({this.consentFailures = 0});

  int consentFailures;
  final sorted = <Map<String, Object?>>[];
  final created = <String>[];

  static final _all = [
    for (var i = 1; i <= 5; i++) comment('k$i', depth: 0, path: '00000000000$i', body: 'Komentar ke-$i'),
  ];

  @override
  Future<List<ThreadComment>> getSortedThread(
    String postId, {
    required CommunityCommentSort sort,
    String? cursor,
    int maxDepth = 3,
    int limit = 20,
    int repliesLimit = 3,
  }) async {
    sorted.add({'sort': sort, 'cursor': cursor, 'limit': limit});
    final ordered = sort == CommunityCommentSort.latest ? _all.reversed.toList() : _all;
    final offset = cursor == null ? 0 : int.parse(cursor);
    return ordered.skip(offset).take(limit).toList();
  }

  @override
  Future<ThreadComment> createComment({required String postId, String? parentId, required String body}) async {
    if (consentFailures > 0) {
      consentFailures--;
      throw consentRequired;
    }
    created.add(body);
    return comment('new', depth: 0, path: '000000000099', body: body, author: me);
  }
}

class _OldServer extends FakeCommentRepository implements SortedCommentRepository {
  @override
  Future<List<ThreadComment>> getSortedThread(
    String postId, {
    required CommunityCommentSort sort,
    String? cursor,
    int maxDepth = 3,
    int limit = 20,
    int repliesLimit = 3,
  }) async => throw const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202');
}

Future<void> _pump(
  WidgetTester tester,
  _Comments comments, {
  CommunityPostOpenMode mode = CommunityPostOpenMode.inlineComments,
  FakeAccount? account,
}) async {
  tester.view.physicalSize = const Size(600, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpCommunity(
    tester,
    CommunityFeedList(scope: const FeedScope.user('u-a'), emptyMessage: 'Kosong', postOpenMode: mode),
    dependencies: FakeDependencies(feed: _Feed(), comments: comments),
    account: account,
  );
}

Future<void> _openComments(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Komentar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('inline mode opens the comments under the card without pushing a route', (tester) async {
    final comments = _Comments();
    await _pump(tester, comments);
    final routes = Navigator.of(tester.element(find.byType(CommunityFeedList)));

    await _openComments(tester);

    expect(find.byType(CommunityPostDetail), findsNothing);
    expect(routes.canPop(), isFalse);
    expect(find.byType(CommunityPostComments), findsOneWidget);
    expect(find.text('Komentar ke-1'), findsOneWidget);
    expect(find.text('Komentar ke-3'), findsOneWidget);
    expect(find.text('Komentar ke-4'), findsNothing);
    expect(comments.sorted.single, {'sort': CommunityCommentSort.top, 'cursor': null, 'limit': 3});
    expect(find.text('Disarankan'), findsOneWidget);
    expect(find.text('Lihat 2 komentar lainnya'), findsOneWidget);
    final field = tester.widget<TextField>(
      find.descendant(of: find.byType(CommunityPostComments), matching: find.byType(TextField)),
    );
    expect(field.focusNode!.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Komentar'));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostComments), findsNothing);
  });

  testWidgets('"View more comments" loads the next page inline', (tester) async {
    final comments = _Comments();
    await _pump(tester, comments);
    await _openComments(tester);

    await tester.tap(find.text('Lihat 2 komentar lainnya'));
    await tester.pumpAndSettle();

    expect(comments.sorted.last, {'sort': CommunityCommentSort.top, 'cursor': '3', 'limit': 10});
    expect(find.text('Komentar ke-5'), findsOneWidget);
    expect(find.textContaining('komentar lainnya'), findsNothing);
    expect(find.byType(CommunityPostDetail), findsNothing);
  });

  testWidgets('a sent comment shows at once and bumps the count on the card', (tester) async {
    final comments = _Comments();
    await _pump(tester, comments);
    await _openComments(tester);

    final field = find.descendant(of: find.byType(CommunityPostComments), matching: find.byType(TextField));
    await tester.enterText(field, 'Setuju, target 10.500');
    await tester.tap(find.byTooltip('Balas'));
    await tester.pumpAndSettle();

    expect(comments.created, ['Setuju, target 10.500']);
    expect(find.text('Setuju, target 10.500'), findsOneWidget);
    final first = tester.getTopLeft(find.text('Setuju, target 10.500'));
    expect(first.dy, lessThan(tester.getTopLeft(find.text('Komentar ke-1')).dy));
    expect(find.descendant(of: find.byTooltip('Komentar'), matching: find.text('6')), findsOneWidget);
  });

  testWidgets('switching to Newest reloads the comments in that order', (tester) async {
    final comments = _Comments();
    await _pump(tester, comments);
    await _openComments(tester);

    await tester.tap(find.text('Disarankan'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PopupMenuItem<CommunityCommentSort>, 'Terbaru'));
    await tester.pumpAndSettle();

    expect(comments.sorted.last['sort'], CommunityCommentSort.latest);
    expect(find.text('Komentar ke-5'), findsOneWidget);
    expect(find.text('Komentar ke-1'), findsNothing);
  });

  testWidgets('Escape closes the inline comments on desktop', (tester) async {
    await _pump(tester, _Comments());
    await _openComments(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(CommunityPostComments), findsNothing);
  });

  testWidgets('consent_required asks for consent, then sends the comment', (tester) async {
    final comments = _Comments(consentFailures: 1);
    final legal = FakeLegalRepository([updatedGuidelines]);
    await _pump(tester, comments, account: FakeAccount(legal));
    await _openComments(tester);

    final field = find.descendant(of: find.byType(CommunityPostComments), matching: find.byType(TextField));
    await tester.enterText(field, 'Komentar setelah setuju');
    await tester.tap(find.byTooltip('Balas'));
    await tester.pumpAndSettle();

    expect(find.text('Persetujuan diperlukan'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Setuju'));
    await tester.pumpAndSettle();

    expect(legal.accepted, ['d-guide']);
    expect(comments.created, ['Komentar setelah setuju']);
    expect(find.text('Komentar setelah setuju'), findsOneWidget);
  });

  testWidgets('navigate mode still opens CommunityPostDetail', (tester) async {
    final comments = _Comments();
    await _pump(tester, comments, mode: CommunityPostOpenMode.navigate);

    await _openComments(tester);

    expect(find.byType(CommunityPostDetail), findsOneWidget);
    expect(find.byType(CommunityPostComments), findsNothing);
    expect(comments.sorted.map((r) => r['sort']), [CommunityCommentSort.top]);
    expect(find.byTooltip('Urutkan komentar'), findsOneWidget);
    expect(find.text('Disarankan'), findsOneWidget);
  });

  test('an older server without comment sorting falls back to oldest first and hides the sort menu', () async {
    final comments = _OldServer();
    final cubit = CommentThreadCubit(
      feed: _Feed(),
      comments: comments,
      postId: 'p-1',
      sort: CommunityCommentSort.top,
      firstPageSize: 3,
      fetchPost: false,
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status.name, 'ready');
    expect(cubit.state.sortSupported, isFalse);
    expect(comments.requests, hasLength(1));
    expect(cubit.state.children[topLevelKey], ['c1', 't2']);
  });
}
