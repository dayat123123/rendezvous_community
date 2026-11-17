// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_audience_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentAudienceState {

 LoadStatus get status; CommentAudience get audience; bool get allOff; bool get allOffSupported; bool get saving; int get savedId; CommentSettingSaved? get saved; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of CommentAudienceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentAudienceStateCopyWith<CommentAudienceState> get copyWith => _$CommentAudienceStateCopyWithImpl<CommentAudienceState>(this as CommentAudienceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommentAudienceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentAudienceState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.audience, _this.audience) || other.audience == _this.audience)&&(identical(other.allOff, _this.allOff) || other.allOff == _this.allOff)&&(identical(other.allOffSupported, _this.allOffSupported) || other.allOffSupported == _this.allOffSupported)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.savedId, _this.savedId) || other.savedId == _this.savedId)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&const DeepCollectionEquality().equals(other.error, _this.error)&&const DeepCollectionEquality().equals(other.actionError, _this.actionError)&&(identical(other.actionErrorId, _this.actionErrorId) || other.actionErrorId == _this.actionErrorId));
}


@override
int get hashCode {
  final _this = this as CommentAudienceState;
  return Object.hash(runtimeType,_this.status,_this.audience,_this.allOff,_this.allOffSupported,_this.saving,_this.savedId,_this.saved,const DeepCollectionEquality().hash(_this.error),const DeepCollectionEquality().hash(_this.actionError),_this.actionErrorId);
}

@override
String toString() {
  final _this = this as CommentAudienceState;
  return 'CommentAudienceState(status: ${_this.status}, audience: ${_this.audience}, allOff: ${_this.allOff}, allOffSupported: ${_this.allOffSupported}, saving: ${_this.saving}, savedId: ${_this.savedId}, saved: ${_this.saved}, error: ${_this.error}, actionError: ${_this.actionError}, actionErrorId: ${_this.actionErrorId})';
}


}

/// @nodoc
abstract mixin class $CommentAudienceStateCopyWith<$Res>  {
  factory $CommentAudienceStateCopyWith(CommentAudienceState value, $Res Function(CommentAudienceState) _then) = _$CommentAudienceStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, CommentAudience audience, bool allOff, bool allOffSupported, bool saving, int savedId, CommentSettingSaved? saved, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class _$CommentAudienceStateCopyWithImpl<$Res>
    implements $CommentAudienceStateCopyWith<$Res> {
  _$CommentAudienceStateCopyWithImpl(this._self, this._then);

  final CommentAudienceState _self;
  final $Res Function(CommentAudienceState) _then;

/// Create a copy of CommentAudienceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? audience = null,Object? allOff = null,Object? allOffSupported = null,Object? saving = null,Object? savedId = null,Object? saved = freezed,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(CommentAudienceState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as CommentAudience,allOff: null == allOff ? _self.allOff : allOff // ignore: cast_nullable_to_non_nullable
as bool,allOffSupported: null == allOffSupported ? _self.allOffSupported : allOffSupported // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,savedId: null == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as int,saved: freezed == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as CommentSettingSaved?,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentAudienceState].
extension CommentAudienceStatePatterns on CommentAudienceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentAudienceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentAudienceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentAudienceState value)  $default,){
final _that = this;
switch (_that) {
case _CommentAudienceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentAudienceState value)?  $default,){
final _that = this;
switch (_that) {
case _CommentAudienceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  CommentAudience audience,  bool allOff,  bool allOffSupported,  bool saving,  int savedId,  CommentSettingSaved? saved,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentAudienceState() when $default != null:
return $default(_that.status,_that.audience,_that.allOff,_that.allOffSupported,_that.saving,_that.savedId,_that.saved,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  CommentAudience audience,  bool allOff,  bool allOffSupported,  bool saving,  int savedId,  CommentSettingSaved? saved,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _CommentAudienceState():
return $default(_that.status,_that.audience,_that.allOff,_that.allOffSupported,_that.saving,_that.savedId,_that.saved,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  CommentAudience audience,  bool allOff,  bool allOffSupported,  bool saving,  int savedId,  CommentSettingSaved? saved,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _CommentAudienceState() when $default != null:
return $default(_that.status,_that.audience,_that.allOff,_that.allOffSupported,_that.saving,_that.savedId,_that.saved,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _CommentAudienceState implements CommentAudienceState {
  const _CommentAudienceState({this.status = LoadStatus.initial, this.audience = CommentAudience.everyone, this.allOff = false, this.allOffSupported = false, this.saving = false, this.savedId = 0, this.saved, this.error, this.actionError, this.actionErrorId = 0});
  

@override@JsonKey() final  LoadStatus status;
@override@JsonKey() final  CommentAudience audience;
@override@JsonKey() final  bool allOff;
@override@JsonKey() final  bool allOffSupported;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  int savedId;
@override final  CommentSettingSaved? saved;
@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of CommentAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentAudienceStateCopyWith<_CommentAudienceState> get copyWith => __$CommentAudienceStateCopyWithImpl<_CommentAudienceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentAudienceState&&(identical(other.status, status) || other.status == status)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.allOff, allOff) || other.allOff == allOff)&&(identical(other.allOffSupported, allOffSupported) || other.allOffSupported == allOffSupported)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.savedId, savedId) || other.savedId == savedId)&&(identical(other.saved, saved) || other.saved == saved)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,audience,allOff,allOffSupported,saving,savedId,saved,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);
}

@override
String toString() {
    return 'CommentAudienceState(status: $status, audience: $audience, allOff: $allOff, allOffSupported: $allOffSupported, saving: $saving, savedId: $savedId, saved: $saved, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$CommentAudienceStateCopyWith<$Res> implements $CommentAudienceStateCopyWith<$Res> {
  factory _$CommentAudienceStateCopyWith(_CommentAudienceState value, $Res Function(_CommentAudienceState) _then) = __$CommentAudienceStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, CommentAudience audience, bool allOff, bool allOffSupported, bool saving, int savedId, CommentSettingSaved? saved, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class __$CommentAudienceStateCopyWithImpl<$Res>
    implements _$CommentAudienceStateCopyWith<$Res> {
  __$CommentAudienceStateCopyWithImpl(this._self, this._then);

  final _CommentAudienceState _self;
  final $Res Function(_CommentAudienceState) _then;

/// Create a copy of CommentAudienceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? audience = null,Object? allOff = null,Object? allOffSupported = null,Object? saving = null,Object? savedId = null,Object? saved = freezed,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_CommentAudienceState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as CommentAudience,allOff: null == allOff ? _self.allOff : allOff // ignore: cast_nullable_to_non_nullable
as bool,allOffSupported: null == allOffSupported ? _self.allOffSupported : allOffSupported // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,savedId: null == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as int,saved: freezed == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as CommentSettingSaved?,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
