import 'package:rendezvous_community/src/features/post/domain/entities/comment_sort.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';

abstract interface class CommentRepository {
  Future<List<ThreadComment>> getThread(
    String postId, {
    String? rootCommentId,
    int maxDepth = 3,
    String? cursor,
    int limit = 20,
    int repliesLimit = 3,
    bool includeRoot = false,
  });

  Future<ThreadComment> createComment({required String postId, String? parentId, required String body});

  Future<void> deleteComment(String commentId);

  Future<void> likeComment(String commentId);

  Future<void> unlikeComment(String commentId);

  Stream<String> watchComments(String postId);
}

abstract interface class SortedCommentRepository {
  Future<List<ThreadComment>> getSortedThread(
    String postId, {
    required CommunityCommentSort sort,
    String? cursor,
    int maxDepth = 3,
    int limit = 20,
    int repliesLimit = 3,
  });
}
