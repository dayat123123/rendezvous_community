// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_info_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupInfoState {

 LoadStatus get status; ChatRoom? get room; String? get meId; List<RoomMember> get members; bool get busy; bool get left; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupInfoStateCopyWith<GroupInfoState> get copyWith => _$GroupInfoStateCopyWithImpl<GroupInfoState>(this as GroupInfoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupInfoState&&(identical(other.status, status) || other.status == status)&&(identical(other.room, room) || other.room == room)&&(identical(other.meId, meId) || other.meId == meId)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.left, left) || other.left == left)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,room,meId,const DeepCollectionEquality().hash(members),busy,left,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'GroupInfoState(status: $status, room: $room, meId: $meId, members: $members, busy: $busy, left: $left, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class $GroupInfoStateCopyWith<$Res>  {
  factory $GroupInfoStateCopyWith(GroupInfoState value, $Res Function(GroupInfoState) _then) = _$GroupInfoStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, ChatRoom? room, String? meId, List<RoomMember> members, bool busy, bool left, Object? error, Object? actionError, int actionErrorId
});


$ChatRoomCopyWith<$Res>? get room;

}
/// @nodoc
class _$GroupInfoStateCopyWithImpl<$Res>
    implements $GroupInfoStateCopyWith<$Res> {
  _$GroupInfoStateCopyWithImpl(this._self, this._then);

  final GroupInfoState _self;
  final $Res Function(GroupInfoState) _then;

/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? room = freezed,Object? meId = freezed,Object? members = null,Object? busy = null,Object? left = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as ChatRoom?,meId: freezed == meId ? _self.meId : meId // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<RoomMember>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $ChatRoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupInfoState].
extension GroupInfoStatePatterns on GroupInfoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupInfoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupInfoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupInfoState value)  $default,){
final _that = this;
switch (_that) {
case _GroupInfoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupInfoState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupInfoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  ChatRoom? room,  String? meId,  List<RoomMember> members,  bool busy,  bool left,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupInfoState() when $default != null:
return $default(_that.status,_that.room,_that.meId,_that.members,_that.busy,_that.left,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  ChatRoom? room,  String? meId,  List<RoomMember> members,  bool busy,  bool left,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _GroupInfoState():
return $default(_that.status,_that.room,_that.meId,_that.members,_that.busy,_that.left,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  ChatRoom? room,  String? meId,  List<RoomMember> members,  bool busy,  bool left,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _GroupInfoState() when $default != null:
return $default(_that.status,_that.room,_that.meId,_that.members,_that.busy,_that.left,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _GroupInfoState extends GroupInfoState {
  const _GroupInfoState({this.status = LoadStatus.initial, this.room, this.meId, final  List<RoomMember> members = const <RoomMember>[], this.busy = false, this.left = false, this.error, this.actionError, this.actionErrorId = 0}): _members = members,super._();
  

@override@JsonKey() final  LoadStatus status;
@override final  ChatRoom? room;
@override final  String? meId;
 final  List<RoomMember> _members;
@override@JsonKey() List<RoomMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool left;
@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupInfoStateCopyWith<_GroupInfoState> get copyWith => __$GroupInfoStateCopyWithImpl<_GroupInfoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupInfoState&&(identical(other.status, status) || other.status == status)&&(identical(other.room, room) || other.room == room)&&(identical(other.meId, meId) || other.meId == meId)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.left, left) || other.left == left)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,room,meId,const DeepCollectionEquality().hash(_members),busy,left,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'GroupInfoState(status: $status, room: $room, meId: $meId, members: $members, busy: $busy, left: $left, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$GroupInfoStateCopyWith<$Res> implements $GroupInfoStateCopyWith<$Res> {
  factory _$GroupInfoStateCopyWith(_GroupInfoState value, $Res Function(_GroupInfoState) _then) = __$GroupInfoStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, ChatRoom? room, String? meId, List<RoomMember> members, bool busy, bool left, Object? error, Object? actionError, int actionErrorId
});


@override $ChatRoomCopyWith<$Res>? get room;

}
/// @nodoc
class __$GroupInfoStateCopyWithImpl<$Res>
    implements _$GroupInfoStateCopyWith<$Res> {
  __$GroupInfoStateCopyWithImpl(this._self, this._then);

  final _GroupInfoState _self;
  final $Res Function(_GroupInfoState) _then;

/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? room = freezed,Object? meId = freezed,Object? members = null,Object? busy = null,Object? left = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_GroupInfoState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as ChatRoom?,meId: freezed == meId ? _self.meId : meId // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<RoomMember>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GroupInfoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $ChatRoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}

// dart format on
