// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggested_users_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SuggestedUsersState {

 LoadStatus get status; List<SuggestedUser> get users; Set<String> get following; Set<String> get pending; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of SuggestedUsersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedUsersStateCopyWith<SuggestedUsersState> get copyWith => _$SuggestedUsersStateCopyWithImpl<SuggestedUsersState>(this as SuggestedUsersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedUsersState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.users, users)&&const DeepCollectionEquality().equals(other.following, following)&&const DeepCollectionEquality().equals(other.pending, pending)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(users),const DeepCollectionEquality().hash(following),const DeepCollectionEquality().hash(pending),const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'SuggestedUsersState(status: $status, users: $users, following: $following, pending: $pending, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class $SuggestedUsersStateCopyWith<$Res>  {
  factory $SuggestedUsersStateCopyWith(SuggestedUsersState value, $Res Function(SuggestedUsersState) _then) = _$SuggestedUsersStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, List<SuggestedUser> users, Set<String> following, Set<String> pending, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class _$SuggestedUsersStateCopyWithImpl<$Res>
    implements $SuggestedUsersStateCopyWith<$Res> {
  _$SuggestedUsersStateCopyWithImpl(this._self, this._then);

  final SuggestedUsersState _self;
  final $Res Function(SuggestedUsersState) _then;

/// Create a copy of SuggestedUsersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? users = null,Object? following = null,Object? pending = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<SuggestedUser>,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as Set<String>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedUsersState].
extension SuggestedUsersStatePatterns on SuggestedUsersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedUsersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedUsersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedUsersState value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedUsersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedUsersState value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedUsersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  List<SuggestedUser> users,  Set<String> following,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedUsersState() when $default != null:
return $default(_that.status,_that.users,_that.following,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  List<SuggestedUser> users,  Set<String> following,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _SuggestedUsersState():
return $default(_that.status,_that.users,_that.following,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  List<SuggestedUser> users,  Set<String> following,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedUsersState() when $default != null:
return $default(_that.status,_that.users,_that.following,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _SuggestedUsersState implements SuggestedUsersState {
  const _SuggestedUsersState({this.status = LoadStatus.initial, final  List<SuggestedUser> users = const <SuggestedUser>[], final  Set<String> following = const <String>{}, final  Set<String> pending = const <String>{}, this.error, this.actionError, this.actionErrorId = 0}): _users = users,_following = following,_pending = pending;
  

@override@JsonKey() final  LoadStatus status;
 final  List<SuggestedUser> _users;
@override@JsonKey() List<SuggestedUser> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

 final  Set<String> _following;
@override@JsonKey() Set<String> get following {
  if (_following is EqualUnmodifiableSetView) return _following;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_following);
}

 final  Set<String> _pending;
@override@JsonKey() Set<String> get pending {
  if (_pending is EqualUnmodifiableSetView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pending);
}

@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of SuggestedUsersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedUsersStateCopyWith<_SuggestedUsersState> get copyWith => __$SuggestedUsersStateCopyWithImpl<_SuggestedUsersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedUsersState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._users, _users)&&const DeepCollectionEquality().equals(other._following, _following)&&const DeepCollectionEquality().equals(other._pending, _pending)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_users),const DeepCollectionEquality().hash(_following),const DeepCollectionEquality().hash(_pending),const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'SuggestedUsersState(status: $status, users: $users, following: $following, pending: $pending, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$SuggestedUsersStateCopyWith<$Res> implements $SuggestedUsersStateCopyWith<$Res> {
  factory _$SuggestedUsersStateCopyWith(_SuggestedUsersState value, $Res Function(_SuggestedUsersState) _then) = __$SuggestedUsersStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, List<SuggestedUser> users, Set<String> following, Set<String> pending, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class __$SuggestedUsersStateCopyWithImpl<$Res>
    implements _$SuggestedUsersStateCopyWith<$Res> {
  __$SuggestedUsersStateCopyWithImpl(this._self, this._then);

  final _SuggestedUsersState _self;
  final $Res Function(_SuggestedUsersState) _then;

/// Create a copy of SuggestedUsersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? users = null,Object? following = null,Object? pending = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_SuggestedUsersState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<SuggestedUser>,following: null == following ? _self._following : following // ignore: cast_nullable_to_non_nullable
as Set<String>,pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
