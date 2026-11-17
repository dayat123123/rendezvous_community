import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';

Post applyPostUpdate(Post post, PostUpdated change, {String? currentUserId}) {
  final mine = post.commentAudience != null || (currentUserId != null && post.author.id == currentUserId);
  final turnedOff = change.commentsOff == true && !post.commentsOff && !mine;
  final hidden = post.commentCountHidden || turnedOff;
  return post.copyWith(
    likeCount: change.likeCount,
    commentCount: hidden ? 0 : change.commentCount,
    canComment: turnedOff ? false : post.canComment,
    commentRestriction: turnedOff ? CommentAudience.off : post.commentRestriction,
    topComment: turnedOff ? null : post.topComment,
  );
}

bool shouldReloadAfterUpdate(Post post, PostUpdated change) =>
    post.commentsOff && change.commentsOff == false && post.commentAudience == null;
