// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowListState {

 LoadStatus get status; List<FollowListEntry> get entries; String? get nextCursor; bool get loadingMore; Set<String> get pending; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowListStateCopyWith<FollowListState> get copyWith => _$FollowListStateCopyWithImpl<FollowListState>(this as FollowListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowListState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&const DeepCollectionEquality().equals(other.pending, pending)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(entries),nextCursor,loadingMore,const DeepCollectionEquality().hash(pending),const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'FollowListState(status: $status, entries: $entries, nextCursor: $nextCursor, loadingMore: $loadingMore, pending: $pending, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class $FollowListStateCopyWith<$Res>  {
  factory $FollowListStateCopyWith(FollowListState value, $Res Function(FollowListState) _then) = _$FollowListStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, List<FollowListEntry> entries, String? nextCursor, bool loadingMore, Set<String> pending, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class _$FollowListStateCopyWithImpl<$Res>
    implements $FollowListStateCopyWith<$Res> {
  _$FollowListStateCopyWithImpl(this._self, this._then);

  final FollowListState _self;
  final $Res Function(FollowListState) _then;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? entries = null,Object? nextCursor = freezed,Object? loadingMore = null,Object? pending = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FollowListEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowListState].
extension FollowListStatePatterns on FollowListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowListState value)  $default,){
final _that = this;
switch (_that) {
case _FollowListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowListState value)?  $default,){
final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  List<FollowListEntry> entries,  String? nextCursor,  bool loadingMore,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
return $default(_that.status,_that.entries,_that.nextCursor,_that.loadingMore,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  List<FollowListEntry> entries,  String? nextCursor,  bool loadingMore,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _FollowListState():
return $default(_that.status,_that.entries,_that.nextCursor,_that.loadingMore,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  List<FollowListEntry> entries,  String? nextCursor,  bool loadingMore,  Set<String> pending,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
return $default(_that.status,_that.entries,_that.nextCursor,_that.loadingMore,_that.pending,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _FollowListState implements FollowListState {
  const _FollowListState({this.status = LoadStatus.initial, final  List<FollowListEntry> entries = const <FollowListEntry>[], this.nextCursor, this.loadingMore = false, final  Set<String> pending = const <String>{}, this.error, this.actionError, this.actionErrorId = 0}): _entries = entries,_pending = pending;
  

@override@JsonKey() final  LoadStatus status;
 final  List<FollowListEntry> _entries;
@override@JsonKey() List<FollowListEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool loadingMore;
 final  Set<String> _pending;
@override@JsonKey() Set<String> get pending {
  if (_pending is EqualUnmodifiableSetView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pending);
}

@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowListStateCopyWith<_FollowListState> get copyWith => __$FollowListStateCopyWithImpl<_FollowListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowListState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&const DeepCollectionEquality().equals(other._pending, _pending)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_entries),nextCursor,loadingMore,const DeepCollectionEquality().hash(_pending),const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'FollowListState(status: $status, entries: $entries, nextCursor: $nextCursor, loadingMore: $loadingMore, pending: $pending, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$FollowListStateCopyWith<$Res> implements $FollowListStateCopyWith<$Res> {
  factory _$FollowListStateCopyWith(_FollowListState value, $Res Function(_FollowListState) _then) = __$FollowListStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, List<FollowListEntry> entries, String? nextCursor, bool loadingMore, Set<String> pending, Object? error, Object? actionError, int actionErrorId
});




}
/// @nodoc
class __$FollowListStateCopyWithImpl<$Res>
    implements _$FollowListStateCopyWith<$Res> {
  __$FollowListStateCopyWithImpl(this._self, this._then);

  final _FollowListState _self;
  final $Res Function(_FollowListState) _then;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? entries = null,Object? nextCursor = freezed,Object? loadingMore = null,Object? pending = null,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_FollowListState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FollowListEntry>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
