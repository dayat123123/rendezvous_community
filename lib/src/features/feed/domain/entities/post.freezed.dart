// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostReactionCount {

 String get emoji; int get count;
/// Create a copy of PostReactionCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostReactionCountCopyWith<PostReactionCount> get copyWith => _$PostReactionCountCopyWithImpl<PostReactionCount>(this as PostReactionCount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostReactionCount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostReactionCount&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as PostReactionCount;
  return Object.hash(runtimeType,_this.emoji,_this.count);
}

@override
String toString() {
  final _this = this as PostReactionCount;
  return 'PostReactionCount(emoji: ${_this.emoji}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $PostReactionCountCopyWith<$Res>  {
  factory $PostReactionCountCopyWith(PostReactionCount value, $Res Function(PostReactionCount) _then) = _$PostReactionCountCopyWithImpl;
@useResult
$Res call({
 String emoji, int count
});




}
/// @nodoc
class _$PostReactionCountCopyWithImpl<$Res>
    implements $PostReactionCountCopyWith<$Res> {
  _$PostReactionCountCopyWithImpl(this._self, this._then);

  final PostReactionCount _self;
  final $Res Function(PostReactionCount) _then;

/// Create a copy of PostReactionCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? count = null,}) {
  return _then(PostReactionCount(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PostReactionCount].
extension PostReactionCountPatterns on PostReactionCount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostReactionCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostReactionCount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostReactionCount value)  $default,){
final _that = this;
switch (_that) {
case _PostReactionCount():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostReactionCount value)?  $default,){
final _that = this;
switch (_that) {
case _PostReactionCount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostReactionCount() when $default != null:
return $default(_that.emoji,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  int count)  $default,) {final _that = this;
switch (_that) {
case _PostReactionCount():
return $default(_that.emoji,_that.count);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  int count)?  $default,) {final _that = this;
switch (_that) {
case _PostReactionCount() when $default != null:
return $default(_that.emoji,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _PostReactionCount implements PostReactionCount {
  const _PostReactionCount({required this.emoji, required this.count});
  

@override final  String emoji;
@override final  int count;

/// Create a copy of PostReactionCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostReactionCountCopyWith<_PostReactionCount> get copyWith => __$PostReactionCountCopyWithImpl<_PostReactionCount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostReactionCount&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,emoji,count);
}

@override
String toString() {
    return 'PostReactionCount(emoji: $emoji, count: $count)';
}


}

/// @nodoc
abstract mixin class _$PostReactionCountCopyWith<$Res> implements $PostReactionCountCopyWith<$Res> {
  factory _$PostReactionCountCopyWith(_PostReactionCount value, $Res Function(_PostReactionCount) _then) = __$PostReactionCountCopyWithImpl;
@override @useResult
$Res call({
 String emoji, int count
});




}
/// @nodoc
class __$PostReactionCountCopyWithImpl<$Res>
    implements _$PostReactionCountCopyWith<$Res> {
  __$PostReactionCountCopyWithImpl(this._self, this._then);

  final _PostReactionCount _self;
  final $Res Function(_PostReactionCount) _then;

/// Create a copy of PostReactionCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? count = null,}) {
  return _then(_PostReactionCount(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Post {

 String get id; UserSummary get author; String get body; Sentiment? get sentiment; List<Attachment> get attachments; int get likeCount; int get commentCount; List<String> get stockCodes; bool get likedByMe; Poll? get poll; DateTime? get editedAt; DateTime get createdAt; String get cursor; bool get isBookmarked; List<String> get hashtags; bool get isBot; bool get authorIsOfficial; ModerationStatus? get moderationStatus; ThreadComment? get topComment; bool get canComment; CommentAudience? get commentAudience; CommentAudience? get commentRestriction; bool get commentsOffByAccount; String? get myReaction; List<PostReactionCount> get reactionSummary; PostInfoCard? get card;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Post;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.sentiment, _this.sentiment) || other.sentiment == _this.sentiment)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&(identical(other.likeCount, _this.likeCount) || other.likeCount == _this.likeCount)&&(identical(other.commentCount, _this.commentCount) || other.commentCount == _this.commentCount)&&const DeepCollectionEquality().equals(other.stockCodes, _this.stockCodes)&&(identical(other.likedByMe, _this.likedByMe) || other.likedByMe == _this.likedByMe)&&(identical(other.poll, _this.poll) || other.poll == _this.poll)&&(identical(other.editedAt, _this.editedAt) || other.editedAt == _this.editedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&(identical(other.isBookmarked, _this.isBookmarked) || other.isBookmarked == _this.isBookmarked)&&const DeepCollectionEquality().equals(other.hashtags, _this.hashtags)&&(identical(other.isBot, _this.isBot) || other.isBot == _this.isBot)&&(identical(other.authorIsOfficial, _this.authorIsOfficial) || other.authorIsOfficial == _this.authorIsOfficial)&&(identical(other.moderationStatus, _this.moderationStatus) || other.moderationStatus == _this.moderationStatus)&&(identical(other.topComment, _this.topComment) || other.topComment == _this.topComment)&&(identical(other.canComment, _this.canComment) || other.canComment == _this.canComment)&&(identical(other.commentAudience, _this.commentAudience) || other.commentAudience == _this.commentAudience)&&(identical(other.commentRestriction, _this.commentRestriction) || other.commentRestriction == _this.commentRestriction)&&(identical(other.commentsOffByAccount, _this.commentsOffByAccount) || other.commentsOffByAccount == _this.commentsOffByAccount)&&(identical(other.myReaction, _this.myReaction) || other.myReaction == _this.myReaction)&&const DeepCollectionEquality().equals(other.reactionSummary, _this.reactionSummary)&&(identical(other.card, _this.card) || other.card == _this.card));
}


@override
int get hashCode {
  final _this = this as Post;
  return Object.hashAll([runtimeType,_this.id,_this.author,_this.body,_this.sentiment,const DeepCollectionEquality().hash(_this.attachments),_this.likeCount,_this.commentCount,const DeepCollectionEquality().hash(_this.stockCodes),_this.likedByMe,_this.poll,_this.editedAt,_this.createdAt,_this.cursor,_this.isBookmarked,const DeepCollectionEquality().hash(_this.hashtags),_this.isBot,_this.authorIsOfficial,_this.moderationStatus,_this.topComment,_this.canComment,_this.commentAudience,_this.commentRestriction,_this.commentsOffByAccount,_this.myReaction,const DeepCollectionEquality().hash(_this.reactionSummary),_this.card]);
}

@override
String toString() {
  final _this = this as Post;
  return 'Post(id: ${_this.id}, author: ${_this.author}, body: ${_this.body}, sentiment: ${_this.sentiment}, attachments: ${_this.attachments}, likeCount: ${_this.likeCount}, commentCount: ${_this.commentCount}, stockCodes: ${_this.stockCodes}, likedByMe: ${_this.likedByMe}, poll: ${_this.poll}, editedAt: ${_this.editedAt}, createdAt: ${_this.createdAt}, cursor: ${_this.cursor}, isBookmarked: ${_this.isBookmarked}, hashtags: ${_this.hashtags}, isBot: ${_this.isBot}, authorIsOfficial: ${_this.authorIsOfficial}, moderationStatus: ${_this.moderationStatus}, topComment: ${_this.topComment}, canComment: ${_this.canComment}, commentAudience: ${_this.commentAudience}, commentRestriction: ${_this.commentRestriction}, commentsOffByAccount: ${_this.commentsOffByAccount}, myReaction: ${_this.myReaction}, reactionSummary: ${_this.reactionSummary}, card: ${_this.card})';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, UserSummary author, String body, Sentiment? sentiment, List<Attachment> attachments, int likeCount, int commentCount, List<String> stockCodes, bool likedByMe, Poll? poll, DateTime? editedAt, DateTime createdAt, String cursor, bool isBookmarked, List<String> hashtags, bool isBot, bool authorIsOfficial, ModerationStatus? moderationStatus, ThreadComment? topComment, bool canComment, CommentAudience? commentAudience, CommentAudience? commentRestriction, bool commentsOffByAccount, String? myReaction, List<PostReactionCount> reactionSummary, PostInfoCard? card
});


$UserSummaryCopyWith<$Res> get author;$PollCopyWith<$Res>? get poll;$ThreadCommentCopyWith<$Res>? get topComment;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? body = null,Object? sentiment = freezed,Object? attachments = null,Object? likeCount = null,Object? commentCount = null,Object? stockCodes = null,Object? likedByMe = null,Object? poll = freezed,Object? editedAt = freezed,Object? createdAt = null,Object? cursor = null,Object? isBookmarked = null,Object? hashtags = null,Object? isBot = null,Object? authorIsOfficial = null,Object? moderationStatus = freezed,Object? topComment = freezed,Object? canComment = null,Object? commentAudience = freezed,Object? commentRestriction = freezed,Object? commentsOffByAccount = null,Object? myReaction = freezed,Object? reactionSummary = null,Object? card = freezed,}) {
  return _then(Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,stockCodes: null == stockCodes ? _self.stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,hashtags: null == hashtags ? _self.hashtags : hashtags // ignore: cast_nullable_to_non_nullable
as List<String>,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,authorIsOfficial: null == authorIsOfficial ? _self.authorIsOfficial : authorIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus?,topComment: freezed == topComment ? _self.topComment : topComment // ignore: cast_nullable_to_non_nullable
as ThreadComment?,canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,commentAudience: freezed == commentAudience ? _self.commentAudience : commentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentRestriction: freezed == commentRestriction ? _self.commentRestriction : commentRestriction // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentsOffByAccount: null == commentsOffByAccount ? _self.commentsOffByAccount : commentsOffByAccount // ignore: cast_nullable_to_non_nullable
as bool,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,reactionSummary: null == reactionSummary ? _self.reactionSummary : reactionSummary // ignore: cast_nullable_to_non_nullable
as List<PostReactionCount>,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as PostInfoCard?,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get author {
  
  return $UserSummaryCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadCommentCopyWith<$Res>? get topComment {
    if (_self.topComment == null) {
    return null;
  }

  return $ThreadCommentCopyWith<$Res>(_self.topComment!, (value) {
    return _then(_self.copyWith(topComment: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UserSummary author,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  int likeCount,  int commentCount,  List<String> stockCodes,  bool likedByMe,  Poll? poll,  DateTime? editedAt,  DateTime createdAt,  String cursor,  bool isBookmarked,  List<String> hashtags,  bool isBot,  bool authorIsOfficial,  ModerationStatus? moderationStatus,  ThreadComment? topComment,  bool canComment,  CommentAudience? commentAudience,  CommentAudience? commentRestriction,  bool commentsOffByAccount,  String? myReaction,  List<PostReactionCount> reactionSummary,  PostInfoCard? card)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.author,_that.body,_that.sentiment,_that.attachments,_that.likeCount,_that.commentCount,_that.stockCodes,_that.likedByMe,_that.poll,_that.editedAt,_that.createdAt,_that.cursor,_that.isBookmarked,_that.hashtags,_that.isBot,_that.authorIsOfficial,_that.moderationStatus,_that.topComment,_that.canComment,_that.commentAudience,_that.commentRestriction,_that.commentsOffByAccount,_that.myReaction,_that.reactionSummary,_that.card);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UserSummary author,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  int likeCount,  int commentCount,  List<String> stockCodes,  bool likedByMe,  Poll? poll,  DateTime? editedAt,  DateTime createdAt,  String cursor,  bool isBookmarked,  List<String> hashtags,  bool isBot,  bool authorIsOfficial,  ModerationStatus? moderationStatus,  ThreadComment? topComment,  bool canComment,  CommentAudience? commentAudience,  CommentAudience? commentRestriction,  bool commentsOffByAccount,  String? myReaction,  List<PostReactionCount> reactionSummary,  PostInfoCard? card)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.author,_that.body,_that.sentiment,_that.attachments,_that.likeCount,_that.commentCount,_that.stockCodes,_that.likedByMe,_that.poll,_that.editedAt,_that.createdAt,_that.cursor,_that.isBookmarked,_that.hashtags,_that.isBot,_that.authorIsOfficial,_that.moderationStatus,_that.topComment,_that.canComment,_that.commentAudience,_that.commentRestriction,_that.commentsOffByAccount,_that.myReaction,_that.reactionSummary,_that.card);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UserSummary author,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  int likeCount,  int commentCount,  List<String> stockCodes,  bool likedByMe,  Poll? poll,  DateTime? editedAt,  DateTime createdAt,  String cursor,  bool isBookmarked,  List<String> hashtags,  bool isBot,  bool authorIsOfficial,  ModerationStatus? moderationStatus,  ThreadComment? topComment,  bool canComment,  CommentAudience? commentAudience,  CommentAudience? commentRestriction,  bool commentsOffByAccount,  String? myReaction,  List<PostReactionCount> reactionSummary,  PostInfoCard? card)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.author,_that.body,_that.sentiment,_that.attachments,_that.likeCount,_that.commentCount,_that.stockCodes,_that.likedByMe,_that.poll,_that.editedAt,_that.createdAt,_that.cursor,_that.isBookmarked,_that.hashtags,_that.isBot,_that.authorIsOfficial,_that.moderationStatus,_that.topComment,_that.canComment,_that.commentAudience,_that.commentRestriction,_that.commentsOffByAccount,_that.myReaction,_that.reactionSummary,_that.card);case _:
  return null;

}
}

}

/// @nodoc


class _Post extends Post {
  const _Post({required this.id, required this.author, required this.body, this.sentiment,  List<Attachment> attachments = const <Attachment>[], this.likeCount = 0, this.commentCount = 0,  List<String> stockCodes = const <String>[], this.likedByMe = false, this.poll, this.editedAt, required this.createdAt, required this.cursor, this.isBookmarked = false,  List<String> hashtags = const <String>[], this.isBot = false, this.authorIsOfficial = false, this.moderationStatus, this.topComment, this.canComment = true, this.commentAudience, this.commentRestriction, this.commentsOffByAccount = false, this.myReaction,  List<PostReactionCount> reactionSummary = const <PostReactionCount>[], this.card}): _attachments = attachments,_stockCodes = stockCodes,_hashtags = hashtags,_reactionSummary = reactionSummary,super._();
  

@override final  String id;
@override final  UserSummary author;
@override final  String body;
@override final  Sentiment? sentiment;
 final  List<Attachment> _attachments;
@override@JsonKey() List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
 final  List<String> _stockCodes;
@override@JsonKey() List<String> get stockCodes {
  if (_stockCodes is EqualUnmodifiableListView) return _stockCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stockCodes);
}

@override@JsonKey() final  bool likedByMe;
@override final  Poll? poll;
@override final  DateTime? editedAt;
@override final  DateTime createdAt;
@override final  String cursor;
@override@JsonKey() final  bool isBookmarked;
 final  List<String> _hashtags;
@override@JsonKey() List<String> get hashtags {
  if (_hashtags is EqualUnmodifiableListView) return _hashtags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hashtags);
}

@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool authorIsOfficial;
@override final  ModerationStatus? moderationStatus;
@override final  ThreadComment? topComment;
@override@JsonKey() final  bool canComment;
@override final  CommentAudience? commentAudience;
@override final  CommentAudience? commentRestriction;
@override@JsonKey() final  bool commentsOffByAccount;
@override final  String? myReaction;
 final  List<PostReactionCount> _reactionSummary;
@override@JsonKey() List<PostReactionCount> get reactionSummary {
  if (_reactionSummary is EqualUnmodifiableListView) return _reactionSummary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactionSummary);
}

@override final  PostInfoCard? card;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&const DeepCollectionEquality().equals(other.stockCodes, _stockCodes)&&(identical(other.likedByMe, likedByMe) || other.likedByMe == likedByMe)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked)&&const DeepCollectionEquality().equals(other.hashtags, _hashtags)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.authorIsOfficial, authorIsOfficial) || other.authorIsOfficial == authorIsOfficial)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.topComment, topComment) || other.topComment == topComment)&&(identical(other.canComment, canComment) || other.canComment == canComment)&&(identical(other.commentAudience, commentAudience) || other.commentAudience == commentAudience)&&(identical(other.commentRestriction, commentRestriction) || other.commentRestriction == commentRestriction)&&(identical(other.commentsOffByAccount, commentsOffByAccount) || other.commentsOffByAccount == commentsOffByAccount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&const DeepCollectionEquality().equals(other.reactionSummary, _reactionSummary)&&(identical(other.card, card) || other.card == card));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,author,body,sentiment,const DeepCollectionEquality().hash(_attachments),likeCount,commentCount,const DeepCollectionEquality().hash(_stockCodes),likedByMe,poll,editedAt,createdAt,cursor,isBookmarked,const DeepCollectionEquality().hash(_hashtags),isBot,authorIsOfficial,moderationStatus,topComment,canComment,commentAudience,commentRestriction,commentsOffByAccount,myReaction,const DeepCollectionEquality().hash(_reactionSummary),card]);
}

@override
String toString() {
    return 'Post(id: $id, author: $author, body: $body, sentiment: $sentiment, attachments: $attachments, likeCount: $likeCount, commentCount: $commentCount, stockCodes: $stockCodes, likedByMe: $likedByMe, poll: $poll, editedAt: $editedAt, createdAt: $createdAt, cursor: $cursor, isBookmarked: $isBookmarked, hashtags: $hashtags, isBot: $isBot, authorIsOfficial: $authorIsOfficial, moderationStatus: $moderationStatus, topComment: $topComment, canComment: $canComment, commentAudience: $commentAudience, commentRestriction: $commentRestriction, commentsOffByAccount: $commentsOffByAccount, myReaction: $myReaction, reactionSummary: $reactionSummary, card: $card)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, UserSummary author, String body, Sentiment? sentiment, List<Attachment> attachments, int likeCount, int commentCount, List<String> stockCodes, bool likedByMe, Poll? poll, DateTime? editedAt, DateTime createdAt, String cursor, bool isBookmarked, List<String> hashtags, bool isBot, bool authorIsOfficial, ModerationStatus? moderationStatus, ThreadComment? topComment, bool canComment, CommentAudience? commentAudience, CommentAudience? commentRestriction, bool commentsOffByAccount, String? myReaction, List<PostReactionCount> reactionSummary, PostInfoCard? card
});


@override $UserSummaryCopyWith<$Res> get author;@override $PollCopyWith<$Res>? get poll;@override $ThreadCommentCopyWith<$Res>? get topComment;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? body = null,Object? sentiment = freezed,Object? attachments = null,Object? likeCount = null,Object? commentCount = null,Object? stockCodes = null,Object? likedByMe = null,Object? poll = freezed,Object? editedAt = freezed,Object? createdAt = null,Object? cursor = null,Object? isBookmarked = null,Object? hashtags = null,Object? isBot = null,Object? authorIsOfficial = null,Object? moderationStatus = freezed,Object? topComment = freezed,Object? canComment = null,Object? commentAudience = freezed,Object? commentRestriction = freezed,Object? commentsOffByAccount = null,Object? myReaction = freezed,Object? reactionSummary = null,Object? card = freezed,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,stockCodes: null == stockCodes ? _self._stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as Poll?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,hashtags: null == hashtags ? _self._hashtags : hashtags // ignore: cast_nullable_to_non_nullable
as List<String>,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,authorIsOfficial: null == authorIsOfficial ? _self.authorIsOfficial : authorIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus?,topComment: freezed == topComment ? _self.topComment : topComment // ignore: cast_nullable_to_non_nullable
as ThreadComment?,canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,commentAudience: freezed == commentAudience ? _self.commentAudience : commentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentRestriction: freezed == commentRestriction ? _self.commentRestriction : commentRestriction // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentsOffByAccount: null == commentsOffByAccount ? _self.commentsOffByAccount : commentsOffByAccount // ignore: cast_nullable_to_non_nullable
as bool,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,reactionSummary: null == reactionSummary ? _self._reactionSummary : reactionSummary // ignore: cast_nullable_to_non_nullable
as List<PostReactionCount>,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as PostInfoCard?,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get author {
  
  return $UserSummaryCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThreadCommentCopyWith<$Res>? get topComment {
    if (_self.topComment == null) {
    return null;
  }

  return $ThreadCommentCopyWith<$Res>(_self.topComment!, (value) {
    return _then(_self.copyWith(topComment: value));
  });
}
}

/// @nodoc
mixin _$FeedScope {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedScope()';
}


}

/// @nodoc
class $FeedScopeCopyWith<$Res>  {
$FeedScopeCopyWith(FeedScope _, $Res Function(FeedScope) __);
}


/// Adds pattern-matching-related methods to [FeedScope].
extension FeedScopePatterns on FeedScope {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GlobalFeedScope value)?  global,TResult Function( FollowingFeedScope value)?  following,TResult Function( StockFeedScope value)?  stock,TResult Function( UserFeedScope value)?  user,TResult Function( StocksFeedScope value)?  stocks,TResult Function( OfficialFeedScope value)?  official,TResult Function( ForYouFeedScope value)?  forYou,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GlobalFeedScope() when global != null:
return global(_that);case FollowingFeedScope() when following != null:
return following(_that);case StockFeedScope() when stock != null:
return stock(_that);case UserFeedScope() when user != null:
return user(_that);case StocksFeedScope() when stocks != null:
return stocks(_that);case OfficialFeedScope() when official != null:
return official(_that);case ForYouFeedScope() when forYou != null:
return forYou(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GlobalFeedScope value)  global,required TResult Function( FollowingFeedScope value)  following,required TResult Function( StockFeedScope value)  stock,required TResult Function( UserFeedScope value)  user,required TResult Function( StocksFeedScope value)  stocks,required TResult Function( OfficialFeedScope value)  official,required TResult Function( ForYouFeedScope value)  forYou,}){
final _that = this;
switch (_that) {
case GlobalFeedScope():
return global(_that);case FollowingFeedScope():
return following(_that);case StockFeedScope():
return stock(_that);case UserFeedScope():
return user(_that);case StocksFeedScope():
return stocks(_that);case OfficialFeedScope():
return official(_that);case ForYouFeedScope():
return forYou(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GlobalFeedScope value)?  global,TResult? Function( FollowingFeedScope value)?  following,TResult? Function( StockFeedScope value)?  stock,TResult? Function( UserFeedScope value)?  user,TResult? Function( StocksFeedScope value)?  stocks,TResult? Function( OfficialFeedScope value)?  official,TResult? Function( ForYouFeedScope value)?  forYou,}){
final _that = this;
switch (_that) {
case GlobalFeedScope() when global != null:
return global(_that);case FollowingFeedScope() when following != null:
return following(_that);case StockFeedScope() when stock != null:
return stock(_that);case UserFeedScope() when user != null:
return user(_that);case StocksFeedScope() when stocks != null:
return stocks(_that);case OfficialFeedScope() when official != null:
return official(_that);case ForYouFeedScope() when forYou != null:
return forYou(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  global,TResult Function()?  following,TResult Function( String code)?  stock,TResult Function( String userId)?  user,TResult Function( List<String> codes)?  stocks,TResult Function()?  official,TResult Function()?  forYou,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GlobalFeedScope() when global != null:
return global();case FollowingFeedScope() when following != null:
return following();case StockFeedScope() when stock != null:
return stock(_that.code);case UserFeedScope() when user != null:
return user(_that.userId);case StocksFeedScope() when stocks != null:
return stocks(_that.codes);case OfficialFeedScope() when official != null:
return official();case ForYouFeedScope() when forYou != null:
return forYou();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  global,required TResult Function()  following,required TResult Function( String code)  stock,required TResult Function( String userId)  user,required TResult Function( List<String> codes)  stocks,required TResult Function()  official,required TResult Function()  forYou,}) {final _that = this;
switch (_that) {
case GlobalFeedScope():
return global();case FollowingFeedScope():
return following();case StockFeedScope():
return stock(_that.code);case UserFeedScope():
return user(_that.userId);case StocksFeedScope():
return stocks(_that.codes);case OfficialFeedScope():
return official();case ForYouFeedScope():
return forYou();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  global,TResult? Function()?  following,TResult? Function( String code)?  stock,TResult? Function( String userId)?  user,TResult? Function( List<String> codes)?  stocks,TResult? Function()?  official,TResult? Function()?  forYou,}) {final _that = this;
switch (_that) {
case GlobalFeedScope() when global != null:
return global();case FollowingFeedScope() when following != null:
return following();case StockFeedScope() when stock != null:
return stock(_that.code);case UserFeedScope() when user != null:
return user(_that.userId);case StocksFeedScope() when stocks != null:
return stocks(_that.codes);case OfficialFeedScope() when official != null:
return official();case ForYouFeedScope() when forYou != null:
return forYou();case _:
  return null;

}
}

}

/// @nodoc


class GlobalFeedScope implements FeedScope {
  const GlobalFeedScope();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalFeedScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedScope.global()';
}


}




/// @nodoc


class FollowingFeedScope implements FeedScope {
  const FollowingFeedScope();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowingFeedScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedScope.following()';
}


}




/// @nodoc


class StockFeedScope implements FeedScope {
  const StockFeedScope(this.code);
  

 final  String code;

/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockFeedScopeCopyWith<StockFeedScope> get copyWith => _$StockFeedScopeCopyWithImpl<StockFeedScope>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StockFeedScope&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code);
}

@override
String toString() {
    return 'FeedScope.stock(code: $code)';
}


}

/// @nodoc
abstract mixin class $StockFeedScopeCopyWith<$Res> implements $FeedScopeCopyWith<$Res> {
  factory $StockFeedScopeCopyWith(StockFeedScope value, $Res Function(StockFeedScope) _then) = _$StockFeedScopeCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$StockFeedScopeCopyWithImpl<$Res>
    implements $StockFeedScopeCopyWith<$Res> {
  _$StockFeedScopeCopyWithImpl(this._self, this._then);

  final StockFeedScope _self;
  final $Res Function(StockFeedScope) _then;

/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(StockFeedScope(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UserFeedScope implements FeedScope {
  const UserFeedScope(this.userId);
  

 final  String userId;

/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFeedScopeCopyWith<UserFeedScope> get copyWith => _$UserFeedScopeCopyWithImpl<UserFeedScope>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFeedScope&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId);
}

@override
String toString() {
    return 'FeedScope.user(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $UserFeedScopeCopyWith<$Res> implements $FeedScopeCopyWith<$Res> {
  factory $UserFeedScopeCopyWith(UserFeedScope value, $Res Function(UserFeedScope) _then) = _$UserFeedScopeCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$UserFeedScopeCopyWithImpl<$Res>
    implements $UserFeedScopeCopyWith<$Res> {
  _$UserFeedScopeCopyWithImpl(this._self, this._then);

  final UserFeedScope _self;
  final $Res Function(UserFeedScope) _then;

/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(UserFeedScope(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class StocksFeedScope implements FeedScope {
  const StocksFeedScope( List<String> codes): _codes = codes;
  

 final  List<String> _codes;
 List<String> get codes {
  if (_codes is EqualUnmodifiableListView) return _codes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codes);
}


/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StocksFeedScopeCopyWith<StocksFeedScope> get copyWith => _$StocksFeedScopeCopyWithImpl<StocksFeedScope>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StocksFeedScope&&const DeepCollectionEquality().equals(other.codes, _codes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_codes));
}

@override
String toString() {
    return 'FeedScope.stocks(codes: $codes)';
}


}

/// @nodoc
abstract mixin class $StocksFeedScopeCopyWith<$Res> implements $FeedScopeCopyWith<$Res> {
  factory $StocksFeedScopeCopyWith(StocksFeedScope value, $Res Function(StocksFeedScope) _then) = _$StocksFeedScopeCopyWithImpl;
@useResult
$Res call({
 List<String> codes
});




}
/// @nodoc
class _$StocksFeedScopeCopyWithImpl<$Res>
    implements $StocksFeedScopeCopyWith<$Res> {
  _$StocksFeedScopeCopyWithImpl(this._self, this._then);

  final StocksFeedScope _self;
  final $Res Function(StocksFeedScope) _then;

/// Create a copy of FeedScope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? codes = null,}) {
  return _then(StocksFeedScope(
null == codes ? _self._codes : codes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class OfficialFeedScope implements FeedScope {
  const OfficialFeedScope();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OfficialFeedScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedScope.official()';
}


}




/// @nodoc


class ForYouFeedScope implements FeedScope {
  const ForYouFeedScope();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForYouFeedScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedScope.forYou()';
}


}




// dart format on
