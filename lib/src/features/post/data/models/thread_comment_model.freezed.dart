// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thread_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThreadCommentModel {

 String get id; String get postId; String? get parentId; String? get authorId; String? get authorUsername; String? get authorDisplayName; String? get authorAvatarUrl; bool get authorIsVerified; String? get body; bool get isDeleted; int get depth; String get path; int get likeCount; int get replyCount; bool get likedByMe; DateTime? get editedAt; DateTime get createdAt; String get cursor; String? get moderationStatus;
/// Create a copy of ThreadCommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreadCommentModelCopyWith<ThreadCommentModel> get copyWith => _$ThreadCommentModelCopyWithImpl<ThreadCommentModel>(this as ThreadCommentModel, _$identity);

  /// Serializes this ThreadCommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ThreadCommentModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreadCommentModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.authorId, _this.authorId) || other.authorId == _this.authorId)&&(identical(other.authorUsername, _this.authorUsername) || other.authorUsername == _this.authorUsername)&&(identical(other.authorDisplayName, _this.authorDisplayName) || other.authorDisplayName == _this.authorDisplayName)&&(identical(other.authorAvatarUrl, _this.authorAvatarUrl) || other.authorAvatarUrl == _this.authorAvatarUrl)&&(identical(other.authorIsVerified, _this.authorIsVerified) || other.authorIsVerified == _this.authorIsVerified)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&(identical(other.depth, _this.depth) || other.depth == _this.depth)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.likeCount, _this.likeCount) || other.likeCount == _this.likeCount)&&(identical(other.replyCount, _this.replyCount) || other.replyCount == _this.replyCount)&&(identical(other.likedByMe, _this.likedByMe) || other.likedByMe == _this.likedByMe)&&(identical(other.editedAt, _this.editedAt) || other.editedAt == _this.editedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor)&&(identical(other.moderationStatus, _this.moderationStatus) || other.moderationStatus == _this.moderationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ThreadCommentModel;
  return Object.hashAll([runtimeType,_this.id,_this.postId,_this.parentId,_this.authorId,_this.authorUsername,_this.authorDisplayName,_this.authorAvatarUrl,_this.authorIsVerified,_this.body,_this.isDeleted,_this.depth,_this.path,_this.likeCount,_this.replyCount,_this.likedByMe,_this.editedAt,_this.createdAt,_this.cursor,_this.moderationStatus]);
}

@override
String toString() {
  final _this = this as ThreadCommentModel;
  return 'ThreadCommentModel(id: ${_this.id}, postId: ${_this.postId}, parentId: ${_this.parentId}, authorId: ${_this.authorId}, authorUsername: ${_this.authorUsername}, authorDisplayName: ${_this.authorDisplayName}, authorAvatarUrl: ${_this.authorAvatarUrl}, authorIsVerified: ${_this.authorIsVerified}, body: ${_this.body}, isDeleted: ${_this.isDeleted}, depth: ${_this.depth}, path: ${_this.path}, likeCount: ${_this.likeCount}, replyCount: ${_this.replyCount}, likedByMe: ${_this.likedByMe}, editedAt: ${_this.editedAt}, createdAt: ${_this.createdAt}, cursor: ${_this.cursor}, moderationStatus: ${_this.moderationStatus})';
}


}

/// @nodoc
abstract mixin class $ThreadCommentModelCopyWith<$Res>  {
  factory $ThreadCommentModelCopyWith(ThreadCommentModel value, $Res Function(ThreadCommentModel) _then) = _$ThreadCommentModelCopyWithImpl;
@useResult
$Res call({
 String id, String postId, String? parentId, String? authorId, String? authorUsername, String? authorDisplayName, String? authorAvatarUrl, bool authorIsVerified, String? body, bool isDeleted, int depth, String path, int likeCount, int replyCount, bool likedByMe, DateTime? editedAt, DateTime createdAt, String cursor, String? moderationStatus
});




}
/// @nodoc
class _$ThreadCommentModelCopyWithImpl<$Res>
    implements $ThreadCommentModelCopyWith<$Res> {
  _$ThreadCommentModelCopyWithImpl(this._self, this._then);

  final ThreadCommentModel _self;
  final $Res Function(ThreadCommentModel) _then;

/// Create a copy of ThreadCommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? parentId = freezed,Object? authorId = freezed,Object? authorUsername = freezed,Object? authorDisplayName = freezed,Object? authorAvatarUrl = freezed,Object? authorIsVerified = null,Object? body = freezed,Object? isDeleted = null,Object? depth = null,Object? path = null,Object? likeCount = null,Object? replyCount = null,Object? likedByMe = null,Object? editedAt = freezed,Object? createdAt = null,Object? cursor = null,Object? moderationStatus = freezed,}) {
  return _then(ThreadCommentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorIsVerified: null == authorIsVerified ? _self.authorIsVerified : authorIsVerified // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThreadCommentModel].
extension ThreadCommentModelPatterns on ThreadCommentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThreadCommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThreadCommentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThreadCommentModel value)  $default,){
final _that = this;
switch (_that) {
case _ThreadCommentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThreadCommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _ThreadCommentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String postId,  String? parentId,  String? authorId,  String? authorUsername,  String? authorDisplayName,  String? authorAvatarUrl,  bool authorIsVerified,  String? body,  bool isDeleted,  int depth,  String path,  int likeCount,  int replyCount,  bool likedByMe,  DateTime? editedAt,  DateTime createdAt,  String cursor,  String? moderationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThreadCommentModel() when $default != null:
return $default(_that.id,_that.postId,_that.parentId,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorIsVerified,_that.body,_that.isDeleted,_that.depth,_that.path,_that.likeCount,_that.replyCount,_that.likedByMe,_that.editedAt,_that.createdAt,_that.cursor,_that.moderationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String postId,  String? parentId,  String? authorId,  String? authorUsername,  String? authorDisplayName,  String? authorAvatarUrl,  bool authorIsVerified,  String? body,  bool isDeleted,  int depth,  String path,  int likeCount,  int replyCount,  bool likedByMe,  DateTime? editedAt,  DateTime createdAt,  String cursor,  String? moderationStatus)  $default,) {final _that = this;
switch (_that) {
case _ThreadCommentModel():
return $default(_that.id,_that.postId,_that.parentId,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorIsVerified,_that.body,_that.isDeleted,_that.depth,_that.path,_that.likeCount,_that.replyCount,_that.likedByMe,_that.editedAt,_that.createdAt,_that.cursor,_that.moderationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String postId,  String? parentId,  String? authorId,  String? authorUsername,  String? authorDisplayName,  String? authorAvatarUrl,  bool authorIsVerified,  String? body,  bool isDeleted,  int depth,  String path,  int likeCount,  int replyCount,  bool likedByMe,  DateTime? editedAt,  DateTime createdAt,  String cursor,  String? moderationStatus)?  $default,) {final _that = this;
switch (_that) {
case _ThreadCommentModel() when $default != null:
return $default(_that.id,_that.postId,_that.parentId,_that.authorId,_that.authorUsername,_that.authorDisplayName,_that.authorAvatarUrl,_that.authorIsVerified,_that.body,_that.isDeleted,_that.depth,_that.path,_that.likeCount,_that.replyCount,_that.likedByMe,_that.editedAt,_that.createdAt,_that.cursor,_that.moderationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThreadCommentModel extends ThreadCommentModel {
  const _ThreadCommentModel({required this.id, required this.postId, this.parentId, this.authorId, this.authorUsername, this.authorDisplayName, this.authorAvatarUrl, this.authorIsVerified = false, this.body, this.isDeleted = false, required this.depth, required this.path, this.likeCount = 0, this.replyCount = 0, this.likedByMe = false, this.editedAt, required this.createdAt, required this.cursor, this.moderationStatus}): super._();
  factory _ThreadCommentModel.fromJson(Map<String, dynamic> json) => _$ThreadCommentModelFromJson(json);

@override final  String id;
@override final  String postId;
@override final  String? parentId;
@override final  String? authorId;
@override final  String? authorUsername;
@override final  String? authorDisplayName;
@override final  String? authorAvatarUrl;
@override@JsonKey() final  bool authorIsVerified;
@override final  String? body;
@override@JsonKey() final  bool isDeleted;
@override final  int depth;
@override final  String path;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int replyCount;
@override@JsonKey() final  bool likedByMe;
@override final  DateTime? editedAt;
@override final  DateTime createdAt;
@override final  String cursor;
@override final  String? moderationStatus;

/// Create a copy of ThreadCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThreadCommentModelCopyWith<_ThreadCommentModel> get copyWith => __$ThreadCommentModelCopyWithImpl<_ThreadCommentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreadCommentModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThreadCommentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorDisplayName, authorDisplayName) || other.authorDisplayName == authorDisplayName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.authorIsVerified, authorIsVerified) || other.authorIsVerified == authorIsVerified)&&(identical(other.body, body) || other.body == body)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.path, path) || other.path == path)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.likedByMe, likedByMe) || other.likedByMe == likedByMe)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,postId,parentId,authorId,authorUsername,authorDisplayName,authorAvatarUrl,authorIsVerified,body,isDeleted,depth,path,likeCount,replyCount,likedByMe,editedAt,createdAt,cursor,moderationStatus]);
}

@override
String toString() {
    return 'ThreadCommentModel(id: $id, postId: $postId, parentId: $parentId, authorId: $authorId, authorUsername: $authorUsername, authorDisplayName: $authorDisplayName, authorAvatarUrl: $authorAvatarUrl, authorIsVerified: $authorIsVerified, body: $body, isDeleted: $isDeleted, depth: $depth, path: $path, likeCount: $likeCount, replyCount: $replyCount, likedByMe: $likedByMe, editedAt: $editedAt, createdAt: $createdAt, cursor: $cursor, moderationStatus: $moderationStatus)';
}


}

/// @nodoc
abstract mixin class _$ThreadCommentModelCopyWith<$Res> implements $ThreadCommentModelCopyWith<$Res> {
  factory _$ThreadCommentModelCopyWith(_ThreadCommentModel value, $Res Function(_ThreadCommentModel) _then) = __$ThreadCommentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String postId, String? parentId, String? authorId, String? authorUsername, String? authorDisplayName, String? authorAvatarUrl, bool authorIsVerified, String? body, bool isDeleted, int depth, String path, int likeCount, int replyCount, bool likedByMe, DateTime? editedAt, DateTime createdAt, String cursor, String? moderationStatus
});




}
/// @nodoc
class __$ThreadCommentModelCopyWithImpl<$Res>
    implements _$ThreadCommentModelCopyWith<$Res> {
  __$ThreadCommentModelCopyWithImpl(this._self, this._then);

  final _ThreadCommentModel _self;
  final $Res Function(_ThreadCommentModel) _then;

/// Create a copy of ThreadCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? parentId = freezed,Object? authorId = freezed,Object? authorUsername = freezed,Object? authorDisplayName = freezed,Object? authorAvatarUrl = freezed,Object? authorIsVerified = null,Object? body = freezed,Object? isDeleted = null,Object? depth = null,Object? path = null,Object? likeCount = null,Object? replyCount = null,Object? likedByMe = null,Object? editedAt = freezed,Object? createdAt = null,Object? cursor = null,Object? moderationStatus = freezed,}) {
  return _then(_ThreadCommentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,authorDisplayName: freezed == authorDisplayName ? _self.authorDisplayName : authorDisplayName // ignore: cast_nullable_to_non_nullable
as String?,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,authorIsVerified: null == authorIsVerified ? _self.authorIsVerified : authorIsVerified // ignore: cast_nullable_to_non_nullable
as bool,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,cursor: null == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
