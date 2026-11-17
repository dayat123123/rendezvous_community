// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_extras.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageReaction {

 String get emoji; int get count; bool get mine;
/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageReactionCopyWith<MessageReaction> get copyWith => _$MessageReactionCopyWithImpl<MessageReaction>(this as MessageReaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MessageReaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageReaction&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.mine, _this.mine) || other.mine == _this.mine));
}


@override
int get hashCode {
  final _this = this as MessageReaction;
  return Object.hash(runtimeType,_this.emoji,_this.count,_this.mine);
}

@override
String toString() {
  final _this = this as MessageReaction;
  return 'MessageReaction(emoji: ${_this.emoji}, count: ${_this.count}, mine: ${_this.mine})';
}


}

/// @nodoc
abstract mixin class $MessageReactionCopyWith<$Res>  {
  factory $MessageReactionCopyWith(MessageReaction value, $Res Function(MessageReaction) _then) = _$MessageReactionCopyWithImpl;
@useResult
$Res call({
 String emoji, int count, bool mine
});




}
/// @nodoc
class _$MessageReactionCopyWithImpl<$Res>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._self, this._then);

  final MessageReaction _self;
  final $Res Function(MessageReaction) _then;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,Object? count = null,Object? mine = null,}) {
  return _then(MessageReaction(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageReaction].
extension MessageReactionPatterns on MessageReaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageReaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageReaction value)  $default,){
final _that = this;
switch (_that) {
case _MessageReaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageReaction value)?  $default,){
final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String emoji,  int count,  bool mine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
return $default(_that.emoji,_that.count,_that.mine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String emoji,  int count,  bool mine)  $default,) {final _that = this;
switch (_that) {
case _MessageReaction():
return $default(_that.emoji,_that.count,_that.mine);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String emoji,  int count,  bool mine)?  $default,) {final _that = this;
switch (_that) {
case _MessageReaction() when $default != null:
return $default(_that.emoji,_that.count,_that.mine);case _:
  return null;

}
}

}

/// @nodoc


class _MessageReaction implements MessageReaction {
  const _MessageReaction({required this.emoji, required this.count, this.mine = false});
  

@override final  String emoji;
@override final  int count;
@override@JsonKey() final  bool mine;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageReactionCopyWith<_MessageReaction> get copyWith => __$MessageReactionCopyWithImpl<_MessageReaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageReaction&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.count, count) || other.count == count)&&(identical(other.mine, mine) || other.mine == mine));
}


@override
int get hashCode {
    return Object.hash(runtimeType,emoji,count,mine);
}

@override
String toString() {
    return 'MessageReaction(emoji: $emoji, count: $count, mine: $mine)';
}


}

/// @nodoc
abstract mixin class _$MessageReactionCopyWith<$Res> implements $MessageReactionCopyWith<$Res> {
  factory _$MessageReactionCopyWith(_MessageReaction value, $Res Function(_MessageReaction) _then) = __$MessageReactionCopyWithImpl;
@override @useResult
$Res call({
 String emoji, int count, bool mine
});




}
/// @nodoc
class __$MessageReactionCopyWithImpl<$Res>
    implements _$MessageReactionCopyWith<$Res> {
  __$MessageReactionCopyWithImpl(this._self, this._then);

  final _MessageReaction _self;
  final $Res Function(_MessageReaction) _then;

/// Create a copy of MessageReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? count = null,Object? mine = null,}) {
  return _then(_MessageReaction(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,mine: null == mine ? _self.mine : mine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SharedPost {

 String get postId; bool get available; UserSummary? get author; String? get body; List<Attachment> get attachments; Sentiment? get sentiment; List<String> get stockCodes; int get likeCount; int get commentCount; DateTime? get createdAt;
/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedPostCopyWith<SharedPost> get copyWith => _$SharedPostCopyWithImpl<SharedPost>(this as SharedPost, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SharedPost;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedPost&&(identical(other.postId, _this.postId) || other.postId == _this.postId)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&(identical(other.sentiment, _this.sentiment) || other.sentiment == _this.sentiment)&&const DeepCollectionEquality().equals(other.stockCodes, _this.stockCodes)&&(identical(other.likeCount, _this.likeCount) || other.likeCount == _this.likeCount)&&(identical(other.commentCount, _this.commentCount) || other.commentCount == _this.commentCount)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as SharedPost;
  return Object.hash(runtimeType,_this.postId,_this.available,_this.author,_this.body,const DeepCollectionEquality().hash(_this.attachments),_this.sentiment,const DeepCollectionEquality().hash(_this.stockCodes),_this.likeCount,_this.commentCount,_this.createdAt);
}

@override
String toString() {
  final _this = this as SharedPost;
  return 'SharedPost(postId: ${_this.postId}, available: ${_this.available}, author: ${_this.author}, body: ${_this.body}, attachments: ${_this.attachments}, sentiment: ${_this.sentiment}, stockCodes: ${_this.stockCodes}, likeCount: ${_this.likeCount}, commentCount: ${_this.commentCount}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SharedPostCopyWith<$Res>  {
  factory $SharedPostCopyWith(SharedPost value, $Res Function(SharedPost) _then) = _$SharedPostCopyWithImpl;
@useResult
$Res call({
 String postId, bool available, UserSummary? author, String? body, List<Attachment> attachments, Sentiment? sentiment, List<String> stockCodes, int likeCount, int commentCount, DateTime? createdAt
});


$UserSummaryCopyWith<$Res>? get author;

}
/// @nodoc
class _$SharedPostCopyWithImpl<$Res>
    implements $SharedPostCopyWith<$Res> {
  _$SharedPostCopyWithImpl(this._self, this._then);

  final SharedPost _self;
  final $Res Function(SharedPost) _then;

/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? available = null,Object? author = freezed,Object? body = freezed,Object? attachments = null,Object? sentiment = freezed,Object? stockCodes = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = freezed,}) {
  return _then(SharedPost(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,stockCodes: null == stockCodes ? _self.stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [SharedPost].
extension SharedPostPatterns on SharedPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedPost value)  $default,){
final _that = this;
switch (_that) {
case _SharedPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedPost value)?  $default,){
final _that = this;
switch (_that) {
case _SharedPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  bool available,  UserSummary? author,  String? body,  List<Attachment> attachments,  Sentiment? sentiment,  List<String> stockCodes,  int likeCount,  int commentCount,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedPost() when $default != null:
return $default(_that.postId,_that.available,_that.author,_that.body,_that.attachments,_that.sentiment,_that.stockCodes,_that.likeCount,_that.commentCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  bool available,  UserSummary? author,  String? body,  List<Attachment> attachments,  Sentiment? sentiment,  List<String> stockCodes,  int likeCount,  int commentCount,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SharedPost():
return $default(_that.postId,_that.available,_that.author,_that.body,_that.attachments,_that.sentiment,_that.stockCodes,_that.likeCount,_that.commentCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  bool available,  UserSummary? author,  String? body,  List<Attachment> attachments,  Sentiment? sentiment,  List<String> stockCodes,  int likeCount,  int commentCount,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SharedPost() when $default != null:
return $default(_that.postId,_that.available,_that.author,_that.body,_that.attachments,_that.sentiment,_that.stockCodes,_that.likeCount,_that.commentCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _SharedPost implements SharedPost {
  const _SharedPost({required this.postId, this.available = true, this.author, this.body,  List<Attachment> attachments = const <Attachment>[], this.sentiment,  List<String> stockCodes = const <String>[], this.likeCount = 0, this.commentCount = 0, this.createdAt}): _attachments = attachments,_stockCodes = stockCodes;
  

@override final  String postId;
@override@JsonKey() final  bool available;
@override final  UserSummary? author;
@override final  String? body;
 final  List<Attachment> _attachments;
@override@JsonKey() List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  Sentiment? sentiment;
 final  List<String> _stockCodes;
@override@JsonKey() List<String> get stockCodes {
  if (_stockCodes is EqualUnmodifiableListView) return _stockCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stockCodes);
}

@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override final  DateTime? createdAt;

/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedPostCopyWith<_SharedPost> get copyWith => __$SharedPostCopyWithImpl<_SharedPost>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedPost&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.available, available) || other.available == available)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&const DeepCollectionEquality().equals(other.stockCodes, _stockCodes)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,postId,available,author,body,const DeepCollectionEquality().hash(_attachments),sentiment,const DeepCollectionEquality().hash(_stockCodes),likeCount,commentCount,createdAt);
}

@override
String toString() {
    return 'SharedPost(postId: $postId, available: $available, author: $author, body: $body, attachments: $attachments, sentiment: $sentiment, stockCodes: $stockCodes, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SharedPostCopyWith<$Res> implements $SharedPostCopyWith<$Res> {
  factory _$SharedPostCopyWith(_SharedPost value, $Res Function(_SharedPost) _then) = __$SharedPostCopyWithImpl;
@override @useResult
$Res call({
 String postId, bool available, UserSummary? author, String? body, List<Attachment> attachments, Sentiment? sentiment, List<String> stockCodes, int likeCount, int commentCount, DateTime? createdAt
});


@override $UserSummaryCopyWith<$Res>? get author;

}
/// @nodoc
class __$SharedPostCopyWithImpl<$Res>
    implements _$SharedPostCopyWith<$Res> {
  __$SharedPostCopyWithImpl(this._self, this._then);

  final _SharedPost _self;
  final $Res Function(_SharedPost) _then;

/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? available = null,Object? author = freezed,Object? body = freezed,Object? attachments = null,Object? sentiment = freezed,Object? stockCodes = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = freezed,}) {
  return _then(_SharedPost(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,stockCodes: null == stockCodes ? _self._stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SharedPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on
