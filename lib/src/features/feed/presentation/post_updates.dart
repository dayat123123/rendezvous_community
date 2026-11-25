import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';

Post applyPostUpdate(Post post, PostUpdated change, {String? currentUserId}) {
  final mine = post.commentAudience != null || (currentUserId != null && post.author.id == currentUserId);
  final turnedOff = change.commentsOff == true && !post.commentsOff && !mine;
  final hidden = post.commentCountHidden || turnedOff;
  return post.copyWith(
    likeCount: change.likeCount,
    reactionSummary: _summaryAfterUpdate(post, change),
    commentCount: hidden ? 0 : change.commentCount,
    canComment: turnedOff ? false : post.canComment,
    commentRestriction: turnedOff ? CommentAudience.off : post.commentRestriction,
    topComment: turnedOff ? null : post.topComment,
  );
}

bool shouldReloadAfterUpdate(Post post, PostUpdated change) =>
    post.commentsOff && change.commentsOff == false && post.commentAudience == null && !post.commentsOffByAccount;

bool isOwnPost(Post post, String? currentUserId) =>
    post.commentAudience != null || (currentUserId != null && post.author.id == currentUserId);

Post lockByAccount(Post post) => post.copyWith(
  commentsOffByAccount: true,
  canComment: false,
  commentRestriction: CommentAudience.off,
  topComment: null,
);

List<PostReactionCount> _summaryAfterUpdate(Post post, PostUpdated change) {
  final server = change.reactionSummary;
  if (server != null) {
    return [
      for (final r in server)
        if (r.count > 0) r,
    ];
  }
  if (change.likeCount == post.likeCount) return post.reactionSummary;
  final onlyLikes = post.reactionSummary.every((r) => r.emoji == postLikeReaction);
  if (!onlyLikes) return post.reactionSummary;
  return [if (change.likeCount > 0) PostReactionCount(emoji: postLikeReaction, count: change.likeCount)];
}

String? toggledLikeReaction(Post post) => post.effectiveReaction == null ? postLikeReaction : null;

Future<Post?> sendPostReaction(FeedRepository feed, String postId, String? emoji) async {
  final value = normalizePostReaction(emoji);
  if (feed case final PostReactionRepository reactions) return reactions.setPostReaction(postId, value);
  if (value == null) {
    await feed.unlikePost(postId);
  } else if (value == postLikeReaction) {
    await feed.likePost(postId);
  } else {
    throw const CommunityException(CommunityErrorKind.unavailable, code: postReactionsUnavailableCode);
  }
  return null;
}
