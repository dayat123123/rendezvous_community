import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_info_card.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/moderation_status.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'post.freezed.dart';

enum Sentiment { bullish, bearish, neutral }

const postLikeReaction = '👍';

const defaultPostReactions = <String>['👍', '❤️', '😂', '😮', '😢', '🔥'];

@freezed
abstract class PostReactionCount with _$PostReactionCount {
  const factory PostReactionCount({required String emoji, required int count}) = _PostReactionCount;
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    required UserSummary author,
    required String body,
    Sentiment? sentiment,
    @Default(<Attachment>[]) List<Attachment> attachments,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(<String>[]) List<String> stockCodes,
    @Default(false) bool likedByMe,
    Poll? poll,
    DateTime? editedAt,
    required DateTime createdAt,
    required String cursor,
    @Default(false) bool isBookmarked,
    @Default(<String>[]) List<String> hashtags,
    @Default(false) bool isBot,
    @Default(false) bool authorIsOfficial,
    ModerationStatus? moderationStatus,
    ThreadComment? topComment,
    @Default(true) bool canComment,
    CommentAudience? commentAudience,
    CommentAudience? commentRestriction,
    @Default(false) bool commentsOffByAccount,
    String? myReaction,
    @Default(<PostReactionCount>[]) List<PostReactionCount> reactionSummary,
    PostInfoCard? card,
    @Default(<Attachment>[]) List<Attachment> files,
  }) = _Post;

  const Post._();

  bool get commentsOff =>
      commentsOffByAccount || commentAudience == CommentAudience.off || commentRestriction == CommentAudience.off;

  bool get commentCountHidden => commentRestriction == CommentAudience.off && commentAudience == null;

  bool get isHeld => moderationStatus == ModerationStatus.held;

  bool get isHidden => moderationStatus == ModerationStatus.hidden;

  String? get effectiveReaction => myReaction ?? (likedByMe ? postLikeReaction : null);

  List<PostReactionCount> get effectiveReactionSummary => reactionSummary.isNotEmpty || likeCount <= 0
      ? reactionSummary
      : [PostReactionCount(emoji: postLikeReaction, count: likeCount)];
}

@freezed
sealed class FeedScope with _$FeedScope {
  const factory FeedScope.global() = GlobalFeedScope;

  const factory FeedScope.following() = FollowingFeedScope;

  const factory FeedScope.stock(String code) = StockFeedScope;

  const factory FeedScope.user(String userId) = UserFeedScope;

  const factory FeedScope.stocks(List<String> codes) = StocksFeedScope;

  const factory FeedScope.official() = OfficialFeedScope;

  const factory FeedScope.forYou() = ForYouFeedScope;
}

sealed class PostChange {
  const PostChange(this.postId);
  final String postId;
}

class PostInserted extends PostChange {
  const PostInserted(
    super.postId, {
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.hasMedia = false,
  });
  final String authorId;
  final String body;
  final DateTime createdAt;
  final bool hasMedia;
}

class PostUpdated extends PostChange {
  const PostUpdated(
    super.postId, {
    required this.likeCount,
    required this.commentCount,
    required this.deleted,
    this.commentsOff,
    this.reactionSummary,
  });
  final int likeCount;
  final int commentCount;
  final bool deleted;
  final bool? commentsOff;
  final List<PostReactionCount>? reactionSummary;
}
