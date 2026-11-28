import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'quoted_post.freezed.dart';

@freezed
abstract class QuotedPost with _$QuotedPost {
  const factory QuotedPost({
    required String id,
    @Default(true) bool available,
    UserSummary? author,
    @Default(false) bool authorIsOfficial,
    @Default('') String body,
    Sentiment? sentiment,
    @Default(<Attachment>[]) List<Attachment> attachments,
    @Default(<String>[]) List<String> stockCodes,
    DateTime? createdAt,
  }) = _QuotedPost;

  const QuotedPost._();

  factory QuotedPost.fromPost(Post post) => QuotedPost(
    id: post.id,
    author: post.author,
    authorIsOfficial: post.authorIsOfficial,
    body: post.body,
    sentiment: post.sentiment,
    attachments: post.attachments,
    stockCodes: post.stockCodes,
    createdAt: post.createdAt,
  );

  Attachment? get image =>
      attachments.where((a) => a.isImage && (a.mime == null || a.mime!.startsWith('image/'))).firstOrNull;
}
