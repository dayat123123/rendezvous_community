// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_reaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostReactor {

 UserSummary get user; String get emoji; DateTime? get reactedAt; bool get isMe; bool get isFollowing; String? get cursor;
/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostReactorCopyWith<PostReactor> get copyWith => _$PostReactorCopyWithImpl<PostReactor>(this as PostReactor, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PostReactor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostReactor&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji)&&(identical(other.reactedAt, _this.reactedAt) || other.reactedAt == _this.reactedAt)&&(identical(other.isMe, _this.isMe) || other.isMe == _this.isMe)&&(identical(other.isFollowing, _this.isFollowing) || other.isFollowing == _this.isFollowing)&&(identical(other.cursor, _this.cursor) || other.cursor == _this.cursor));
}


@override
int get hashCode {
  final _this = this as PostReactor;
  return Object.hash(runtimeType,_this.user,_this.emoji,_this.reactedAt,_this.isMe,_this.isFollowing,_this.cursor);
}

@override
String toString() {
  final _this = this as PostReactor;
  return 'PostReactor(user: ${_this.user}, emoji: ${_this.emoji}, reactedAt: ${_this.reactedAt}, isMe: ${_this.isMe}, isFollowing: ${_this.isFollowing}, cursor: ${_this.cursor})';
}


}

/// @nodoc
abstract mixin class $PostReactorCopyWith<$Res>  {
  factory $PostReactorCopyWith(PostReactor value, $Res Function(PostReactor) _then) = _$PostReactorCopyWithImpl;
@useResult
$Res call({
 UserSummary user, String emoji, DateTime? reactedAt, bool isMe, bool isFollowing, String? cursor
});


$UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$PostReactorCopyWithImpl<$Res>
    implements $PostReactorCopyWith<$Res> {
  _$PostReactorCopyWithImpl(this._self, this._then);

  final PostReactor _self;
  final $Res Function(PostReactor) _then;

/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? emoji = null,Object? reactedAt = freezed,Object? isMe = null,Object? isFollowing = null,Object? cursor = freezed,}) {
  return _then(PostReactor(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reactedAt: freezed == reactedAt ? _self.reactedAt : reactedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostReactor].
extension PostReactorPatterns on PostReactor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostReactor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostReactor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostReactor value)  $default,){
final _that = this;
switch (_that) {
case _PostReactor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostReactor value)?  $default,){
final _that = this;
switch (_that) {
case _PostReactor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSummary user,  String emoji,  DateTime? reactedAt,  bool isMe,  bool isFollowing,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostReactor() when $default != null:
return $default(_that.user,_that.emoji,_that.reactedAt,_that.isMe,_that.isFollowing,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSummary user,  String emoji,  DateTime? reactedAt,  bool isMe,  bool isFollowing,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _PostReactor():
return $default(_that.user,_that.emoji,_that.reactedAt,_that.isMe,_that.isFollowing,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSummary user,  String emoji,  DateTime? reactedAt,  bool isMe,  bool isFollowing,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _PostReactor() when $default != null:
return $default(_that.user,_that.emoji,_that.reactedAt,_that.isMe,_that.isFollowing,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _PostReactor implements PostReactor {
  const _PostReactor({required this.user, required this.emoji, this.reactedAt, this.isMe = false, this.isFollowing = false, this.cursor});
  

@override final  UserSummary user;
@override final  String emoji;
@override final  DateTime? reactedAt;
@override@JsonKey() final  bool isMe;
@override@JsonKey() final  bool isFollowing;
@override final  String? cursor;

/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostReactorCopyWith<_PostReactor> get copyWith => __$PostReactorCopyWithImpl<_PostReactor>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostReactor&&(identical(other.user, user) || other.user == user)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.reactedAt, reactedAt) || other.reactedAt == reactedAt)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,emoji,reactedAt,isMe,isFollowing,cursor);
}

@override
String toString() {
    return 'PostReactor(user: $user, emoji: $emoji, reactedAt: $reactedAt, isMe: $isMe, isFollowing: $isFollowing, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$PostReactorCopyWith<$Res> implements $PostReactorCopyWith<$Res> {
  factory _$PostReactorCopyWith(_PostReactor value, $Res Function(_PostReactor) _then) = __$PostReactorCopyWithImpl;
@override @useResult
$Res call({
 UserSummary user, String emoji, DateTime? reactedAt, bool isMe, bool isFollowing, String? cursor
});


@override $UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$PostReactorCopyWithImpl<$Res>
    implements _$PostReactorCopyWith<$Res> {
  __$PostReactorCopyWithImpl(this._self, this._then);

  final _PostReactor _self;
  final $Res Function(_PostReactor) _then;

/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? emoji = null,Object? reactedAt = freezed,Object? isMe = null,Object? isFollowing = null,Object? cursor = freezed,}) {
  return _then(_PostReactor(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,reactedAt: freezed == reactedAt ? _self.reactedAt : reactedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostReactor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
