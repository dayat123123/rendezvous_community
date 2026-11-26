import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/data/models/post_research_model.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/comment_audience.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_research.dart';
import 'package:rendezvous_community/src/features/poll/data/models/poll_model.dart';
import 'package:rendezvous_community/src/features/post/data/models/thread_comment_model.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';
import 'package:rendezvous_community/src/shared/data/models/attachment_model.dart';
import 'package:rendezvous_community/src/shared/domain/entities/moderation_status.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'feed_post_model.freezed.dart';
part 'feed_post_model.g.dart';

Sentiment? parseSentiment(String? value) => value == null ? null : Sentiment.values.asNameMap()[value];

List<PostReactionCount>? parsePostReactionSummary(Object? value) {
  final raw = switch (value) {
    final String text when text.trim().startsWith('[') => _decodeList(text),
    _ => value,
  };
  if (raw is! List) return null;
  final counts = <String, int>{};
  for (final item in raw) {
    if (item is! Map) continue;
    final emoji = normalizePostReaction(item['emoji'] is String ? item['emoji'] as String : null);
    final count = item['count'] is num ? (item['count'] as num).toInt() : 0;
    if (emoji == null || count <= 0) continue;
    counts[emoji] = (counts[emoji] ?? 0) + count;
  }
  return [for (final MapEntry(:key, :value) in counts.entries) PostReactionCount(emoji: key, count: value)];
}

Object? _decodeList(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}

@freezed
abstract class FeedPostModel with _$FeedPostModel {
  const factory FeedPostModel({
    required String id,
    required String authorId,
    required String authorUsername,
    String? authorDisplayName,
    String? authorAvatarUrl,
    @Default(false) bool authorIsVerified,
    required String body,
    String? sentiment,
    @JsonKey(fromJson: attachmentsFromJson) @Default(<AttachmentModel>[]) List<AttachmentModel> attachments,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(<String>[]) List<String> stockCodes,
    @Default(false) bool likedByMe,
    PollModel? poll,
    DateTime? editedAt,
    required DateTime createdAt,
    @Default('') String cursor,
    bool? isBookmarked,
    List<String>? hashtags,
    bool? isBot,
    bool? authorIsOfficial,
    String? moderationStatus,
    Map<String, dynamic>? topComment,
    bool? canComment,
    String? commentAudience,
    String? commentRestriction,
    bool? commentsOffByAccount,
    String? myReaction,
    Object? reactionSummary,
    @JsonKey(readValue: readPostAttachments, fromJson: researchFromAttachments, includeToJson: false)
    PostResearch? research,
  }) = _FeedPostModel;

  const FeedPostModel._();

  factory FeedPostModel.fromJson(Map<String, dynamic> json) => _$FeedPostModelFromJson(json);

  Post toEntity() => Post(
    id: id,
    author: UserSummary(
      id: authorId,
      username: authorUsername,
      displayName: authorDisplayName,
      avatarUrl: authorAvatarUrl,
      isVerified: authorIsVerified,
    ),
    body: body,
    sentiment: parseSentiment(sentiment),
    attachments: [for (final a in attachments) a.toEntity()],
    likeCount: likeCount,
    commentCount: commentCount,
    stockCodes: stockCodes,
    likedByMe: likedByMe,
    poll: poll?.toEntity(),
    editedAt: editedAt,
    createdAt: createdAt,
    cursor: cursor,
    isBookmarked: isBookmarked ?? false,
    hashtags: hashtags ?? const [],
    isBot: isBot ?? false,
    authorIsOfficial: authorIsOfficial ?? false,
    moderationStatus: parseModerationStatus(moderationStatus),
    topComment: _parseTopComment(),
    canComment: canComment ?? true,
    commentAudience: CommentAudience.fromWire(commentAudience),
    commentRestriction: CommentAudience.fromWire(commentRestriction),
    commentsOffByAccount: commentsOffByAccount ?? false,
    myReaction: normalizePostReaction(myReaction) ?? (likedByMe ? postLikeReaction : null),
    reactionSummary:
        parsePostReactionSummary(reactionSummary) ??
        [if (likeCount > 0) PostReactionCount(emoji: postLikeReaction, count: likeCount)],
    research: research,
  );

  ThreadComment? _parseTopComment() {
    final json = topComment;
    if (json == null) return null;
    try {
      return ThreadCommentModel.fromJson(json).toEntity();
    } on Object {
      return null;
    }
  }
}

@freezed
abstract class PostRowModel with _$PostRowModel {
  const factory PostRowModel({
    required String id,
    required String authorId,
    @Default('') String body,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    DateTime? deletedAt,
    required DateTime createdAt,
    @Default(<Object?>[]) List<Object?> attachments,
    String? commentAudience,
    Object? reactionSummary,
  }) = _PostRowModel;

  factory PostRowModel.fromJson(Map<String, dynamic> json) => _$PostRowModelFromJson(json);
}
