// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mention_policy_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MentionPolicyState {

 LoadStatus get status; MentionPolicy get policy; bool get saving; int get savedId; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of MentionPolicyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MentionPolicyStateCopyWith<MentionPolicyState> get copyWith => _$MentionPolicyStateCopyWithImpl<MentionPolicyState>(this as MentionPolicyState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MentionPolicyState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MentionPolicyState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.policy, _this.policy) || other.policy == _this.policy)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.savedId, _this.savedId) || other.savedId == _this.savedId)&&const DeepCollectionEquality().equals(other.error, _this.error)&&const DeepCollectionEquality().equals(other.actionError, _this.actionError)&&(identical(other.actionErrorId, _this.actionErrorId) || other.actionErrorId == _this.actionErrorId));
}


@override
int get hashCode {
  final _this = this as MentionPolicyState;
  return Object.hash(runtimeType,_this.status,_this.policy,_this.saving,_this.savedId,const DeepCollectionEquality().hash(_this.error),const DeepCollectionEquality().hash(_this.actionError),_this.actionErrorId);
}

@override
String toString() {
  final _this = this as MentionPolicyState;
  return 'MentionPolicyState(status: ${_this.status}, policy: ${_this.policy}, saving: ${_this.saving}, savedId: ${_this.savedId}, error: ${_this.error}, actionError: ${_this.actionError}, actionErrorId: ${_this.actionErrorId})';
}


}

/// @nodoc
abstract mixin class $MentionPolicyStateCopyWith<$Res>  {
  factory $MentionPolicyStateCopyWith(MentionPolicyState value, $Res Function(MentionPolicyState) _then) = _$MentionPolicyStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, MentionPolicy policy, bool saving, int savedId, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class _$MentionPolicyStateCopyWithImpl<$Res>
    implements $MentionPolicyStateCopyWith<$Res> {
  _$MentionPolicyStateCopyWithImpl(this._self, this._then);

  final MentionPolicyState _self;
  final $Res Function(MentionPolicyState) _then;

/// Create a copy of MentionPolicyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? policy = null,Object? saving = null,Object? savedId = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(MentionPolicyState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as MentionPolicy,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,savedId: null == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MentionPolicyState].
extension MentionPolicyStatePatterns on MentionPolicyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MentionPolicyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MentionPolicyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MentionPolicyState value)  $default,){
final _that = this;
switch (_that) {
case _MentionPolicyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MentionPolicyState value)?  $default,){
final _that = this;
switch (_that) {
case _MentionPolicyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  MentionPolicy policy,  bool saving,  int savedId,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MentionPolicyState() when $default != null:
return $default(_that.status,_that.policy,_that.saving,_that.savedId,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  MentionPolicy policy,  bool saving,  int savedId,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _MentionPolicyState():
return $default(_that.status,_that.policy,_that.saving,_that.savedId,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  MentionPolicy policy,  bool saving,  int savedId,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _MentionPolicyState() when $default != null:
return $default(_that.status,_that.policy,_that.saving,_that.savedId,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _MentionPolicyState implements MentionPolicyState {
  const _MentionPolicyState({this.status = LoadStatus.initial, this.policy = MentionPolicy.everyone, this.saving = false, this.savedId = 0, this.error, this.actionError, this.actionErrorId = 0});
  

@override@JsonKey() final  LoadStatus status;
@override@JsonKey() final  MentionPolicy policy;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  int savedId;
@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of MentionPolicyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MentionPolicyStateCopyWith<_MentionPolicyState> get copyWith => __$MentionPolicyStateCopyWithImpl<_MentionPolicyState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MentionPolicyState&&(identical(other.status, status) || other.status == status)&&(identical(other.policy, policy) || other.policy == policy)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.savedId, savedId) || other.savedId == savedId)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,policy,saving,savedId,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);
}

@override
String toString() {
    return 'MentionPolicyState(status: $status, policy: $policy, saving: $saving, savedId: $savedId, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$MentionPolicyStateCopyWith<$Res> implements $MentionPolicyStateCopyWith<$Res> {
  factory _$MentionPolicyStateCopyWith(_MentionPolicyState value, $Res Function(_MentionPolicyState) _then) = __$MentionPolicyStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, MentionPolicy policy, bool saving, int savedId, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class __$MentionPolicyStateCopyWithImpl<$Res>
    implements _$MentionPolicyStateCopyWith<$Res> {
  __$MentionPolicyStateCopyWithImpl(this._self, this._then);

  final _MentionPolicyState _self;
  final $Res Function(_MentionPolicyState) _then;

/// Create a copy of MentionPolicyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? policy = null,Object? saving = null,Object? savedId = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_MentionPolicyState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,policy: null == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as MentionPolicy,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,savedId: null == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
