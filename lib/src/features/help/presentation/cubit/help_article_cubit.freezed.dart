// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_article_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HelpArticleState {

 HelpArticle get article; bool get loading; bool get offline; Object? get error; bool get sending; bool get commentSent; Object? get actionError; int get actionErrorId;
/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpArticleStateCopyWith<HelpArticleState> get copyWith => _$HelpArticleStateCopyWithImpl<HelpArticleState>(this as HelpArticleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpArticleState&&(identical(other.article, article) || other.article == article)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.offline, offline) || other.offline == offline)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.commentSent, commentSent) || other.commentSent == commentSent)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,article,loading,offline,const DeepCollectionEquality().hash(error),sending,commentSent,const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'HelpArticleState(article: $article, loading: $loading, offline: $offline, error: $error, sending: $sending, commentSent: $commentSent, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class $HelpArticleStateCopyWith<$Res>  {
  factory $HelpArticleStateCopyWith(HelpArticleState value, $Res Function(HelpArticleState) _then) = _$HelpArticleStateCopyWithImpl;
@useResult
$Res call({
 HelpArticle article, bool loading, bool offline, Object? error, bool sending, bool commentSent, Object? actionError, int actionErrorId
});


$HelpArticleCopyWith<$Res> get article;

}
/// @nodoc
class _$HelpArticleStateCopyWithImpl<$Res>
    implements $HelpArticleStateCopyWith<$Res> {
  _$HelpArticleStateCopyWithImpl(this._self, this._then);

  final HelpArticleState _self;
  final $Res Function(HelpArticleState) _then;

/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? article = null,Object? loading = null,Object? offline = null,Object? error = freezed,Object? sending = null,Object? commentSent = null,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_self.copyWith(
article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as HelpArticle,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,commentSent: null == commentSent ? _self.commentSent : commentSent // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpArticleCopyWith<$Res> get article {
  
  return $HelpArticleCopyWith<$Res>(_self.article, (value) {
    return _then(_self.copyWith(article: value));
  });
}
}


/// Adds pattern-matching-related methods to [HelpArticleState].
extension HelpArticleStatePatterns on HelpArticleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpArticleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpArticleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpArticleState value)  $default,){
final _that = this;
switch (_that) {
case _HelpArticleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpArticleState value)?  $default,){
final _that = this;
switch (_that) {
case _HelpArticleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HelpArticle article,  bool loading,  bool offline,  Object? error,  bool sending,  bool commentSent,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpArticleState() when $default != null:
return $default(_that.article,_that.loading,_that.offline,_that.error,_that.sending,_that.commentSent,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HelpArticle article,  bool loading,  bool offline,  Object? error,  bool sending,  bool commentSent,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _HelpArticleState():
return $default(_that.article,_that.loading,_that.offline,_that.error,_that.sending,_that.commentSent,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HelpArticle article,  bool loading,  bool offline,  Object? error,  bool sending,  bool commentSent,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _HelpArticleState() when $default != null:
return $default(_that.article,_that.loading,_that.offline,_that.error,_that.sending,_that.commentSent,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _HelpArticleState extends HelpArticleState {
  const _HelpArticleState({required this.article, this.loading = false, this.offline = false, this.error, this.sending = false, this.commentSent = false, this.actionError, this.actionErrorId = 0}): super._();
  

@override final  HelpArticle article;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool offline;
@override final  Object? error;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool commentSent;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpArticleStateCopyWith<_HelpArticleState> get copyWith => __$HelpArticleStateCopyWithImpl<_HelpArticleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpArticleState&&(identical(other.article, article) || other.article == article)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.offline, offline) || other.offline == offline)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.commentSent, commentSent) || other.commentSent == commentSent)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,article,loading,offline,const DeepCollectionEquality().hash(error),sending,commentSent,const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'HelpArticleState(article: $article, loading: $loading, offline: $offline, error: $error, sending: $sending, commentSent: $commentSent, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$HelpArticleStateCopyWith<$Res> implements $HelpArticleStateCopyWith<$Res> {
  factory _$HelpArticleStateCopyWith(_HelpArticleState value, $Res Function(_HelpArticleState) _then) = __$HelpArticleStateCopyWithImpl;
@override @useResult
$Res call({
 HelpArticle article, bool loading, bool offline, Object? error, bool sending, bool commentSent, Object? actionError, int actionErrorId
});


@override $HelpArticleCopyWith<$Res> get article;

}
/// @nodoc
class __$HelpArticleStateCopyWithImpl<$Res>
    implements _$HelpArticleStateCopyWith<$Res> {
  __$HelpArticleStateCopyWithImpl(this._self, this._then);

  final _HelpArticleState _self;
  final $Res Function(_HelpArticleState) _then;

/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? article = null,Object? loading = null,Object? offline = null,Object? error = freezed,Object? sending = null,Object? commentSent = null,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_HelpArticleState(
article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as HelpArticle,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,commentSent: null == commentSent ? _self.commentSent : commentSent // ignore: cast_nullable_to_non_nullable
as bool,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of HelpArticleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpArticleCopyWith<$Res> get article {
  
  return $HelpArticleCopyWith<$Res>(_self.article, (value) {
    return _then(_self.copyWith(article: value));
  });
}
}

// dart format on
