import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_filter.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_sort.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/pinned_post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';

abstract interface class FeedRepository {
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20});

  Future<Post?> getPost(String postId);

  Future<List<PinnedPost>> getPinned(FeedScope scope);

  Future<Post> createPost({
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    PollDraft? poll,
    String? clientId,
  });

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId);

  Future<void> unlikePost(String postId);

  Stream<PostChange> watchPosts({String? postId});
}

abstract interface class FeedQueryRepository {
  Future<Paged<Post>> queryFeed(
    FeedScope scope, {
    CommunityFeedSort sort = CommunityFeedSort.latest,
    bool mediaOnly = false,
    String? filter,
    String? cursor,
    int limit = 20,
  });
}

abstract interface class FeedFilterRepository {
  Future<List<FeedFilter>> getFeedFilters({bool refresh = false});
}

abstract interface class CommentControlRepository implements FeedRepository {
  @override
  Future<Post> createPost({
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    PollDraft? poll,
    String? clientId,
    CommentAudience? commentAudience,
  });

  Future<CommentAudience> getCommentAudience();

  Future<CommentAudience> setCommentAudience(CommentAudience audience);

  Future<Post> setPostCommentAudience(String postId, CommentAudience audience);
}

abstract interface class CommentSettingsRepository {
  Future<CommentSettings> getCommentSettings();

  Future<CommentSettings> setAllCommentsOff(bool off);

  Stream<CommentSettings> watchCommentSettings();
}
