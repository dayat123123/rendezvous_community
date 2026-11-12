import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/post/presentation/cubit/comment_thread_cubit.dart';

import '../../support/fakes.dart';

class _Comments extends FakeCommentRepository {
  _Comments(this.rows);

  final List<ThreadComment> rows;
  final deleted = <String>[];
  Object? deleteError;

  @override
  Future<List<ThreadComment>> getThread(
    String postId, {
    String? rootCommentId,
    int maxDepth = 3,
    String? cursor,
    int limit = 20,
    int repliesLimit = 3,
    bool includeRoot = false,
  }) async => rows;

  @override
  Future<void> deleteComment(String commentId) async {
    final error = deleteError;
    if (error != null) throw error;
    deleted.add(commentId);
  }
}

void main() {
  List<ThreadComment> thread() => [
    comment('a', depth: 0, path: '000000000001', body: 'A', replyCount: 1),
    comment('b', parentId: 'a', depth: 1, path: '000000000001.000000000002', body: 'B', replyCount: 1),
    comment('c', parentId: 'b', depth: 2, path: '000000000001.000000000002.000000000003', body: 'C'),
    comment('d', depth: 0, path: '000000000004', body: 'D'),
  ];

  Future<CommentThreadCubit> load(_Comments comments) async {
    final cubit = CommentThreadCubit(feed: FakeFeedRepository(), comments: comments, postId: 'p-1', fetchPost: false);
    addTearDown(cubit.close);
    await cubit.load();
    return cubit;
  }

  List<String> rows(CommentThreadCubit cubit) => [
    for (final row in buildThreadRows(cubit.state, maxLevels: 4))
      if (row is CommentRow) '${row.comment.id}@${row.level}',
  ];

  test('a deleted reply disappears and its reply moves up to the nearest parent', () async {
    final comments = _Comments(thread());
    final cubit = await load(comments);

    await cubit.deleteComment(cubit.state.comments['b']!);

    expect(comments.deleted, ['b']);
    expect(cubit.state.comments.containsKey('b'), isFalse);
    expect(rows(cubit), ['a@0', 'c@1', 'd@0']);
    final c = cubit.state.comments['c']!;
    expect(c.parentId, 'a');
    expect(c.depth, 1);
    expect(c.path, '000000000001.000000000003');
    expect(cubit.state.comments['a']!.replyCount, 1);
  });

  test('replies of a deleted top-level comment become top-level', () async {
    final cubit = await load(_Comments(thread()));

    await cubit.deleteComment(cubit.state.comments['a']!);

    expect(rows(cubit), ['b@0', 'c@1', 'd@0']);
    expect(cubit.state.comments['b']!.parentId, isNull);
    expect(cubit.state.comments['b']!.depth, 0);
  });

  test('a failed delete restores the thread', () async {
    final comments = _Comments(thread())..deleteError = Exception('offline');
    final cubit = await load(comments);

    await cubit.deleteComment(cubit.state.comments['b']!);

    expect(rows(cubit), ['a@0', 'b@1', 'c@2', 'd@0']);
    expect(cubit.state.actionError, isNotNull);
  });

  test('deleted rows from an older server never reach the UI', () async {
    final legacy = thread()
      ..[1] = comment('b', parentId: 'a', depth: 1, path: '000000000001.000000000002', deleted: true, replyCount: 1);
    final cubit = await load(_Comments(legacy));

    expect(cubit.state.comments.values.where((c) => c.isDeleted), isEmpty);
    expect(rows(cubit), ['a@0', 'c@1', 'd@0']);
  });
}
