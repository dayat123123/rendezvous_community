// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_center_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HelpCenterState {

 LoadStatus get status; HelpCenterContent? get content; bool get offline; Object? get error; String get query; bool get searching; List<HelpArticle>? get results; bool get savedResults; Object? get searchError;
/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCenterStateCopyWith<HelpCenterState> get copyWith => _$HelpCenterStateCopyWithImpl<HelpCenterState>(this as HelpCenterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCenterState&&(identical(other.status, status) || other.status == status)&&(identical(other.content, content) || other.content == content)&&(identical(other.offline, offline) || other.offline == offline)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.query, query) || other.query == query)&&(identical(other.searching, searching) || other.searching == searching)&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.savedResults, savedResults) || other.savedResults == savedResults)&&const DeepCollectionEquality().equals(other.searchError, searchError));
}


@override
int get hashCode => Object.hash(runtimeType,status,content,offline,const DeepCollectionEquality().hash(error),query,searching,const DeepCollectionEquality().hash(results),savedResults,const DeepCollectionEquality().hash(searchError));

@override
String toString() {
  return 'HelpCenterState(status: $status, content: $content, offline: $offline, error: $error, query: $query, searching: $searching, results: $results, savedResults: $savedResults, searchError: $searchError)';
}


}

/// @nodoc
abstract mixin class $HelpCenterStateCopyWith<$Res>  {
  factory $HelpCenterStateCopyWith(HelpCenterState value, $Res Function(HelpCenterState) _then) = _$HelpCenterStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, HelpCenterContent? content, bool offline, Object? error, String query, bool searching, List<HelpArticle>? results, bool savedResults, Object? searchError
});


$HelpCenterContentCopyWith<$Res>? get content;

}
/// @nodoc
class _$HelpCenterStateCopyWithImpl<$Res>
    implements $HelpCenterStateCopyWith<$Res> {
  _$HelpCenterStateCopyWithImpl(this._self, this._then);

  final HelpCenterState _self;
  final $Res Function(HelpCenterState) _then;

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? content = freezed,Object? offline = null,Object? error = freezed,Object? query = null,Object? searching = null,Object? results = freezed,Object? savedResults = null,Object? searchError = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as HelpCenterContent?,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<HelpArticle>?,savedResults: null == savedResults ? _self.savedResults : savedResults // ignore: cast_nullable_to_non_nullable
as bool,searchError: freezed == searchError ? _self.searchError : searchError ,
  ));
}
/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpCenterContentCopyWith<$Res>? get content {
    if (_self.content == null) {
    return null;
  }

  return $HelpCenterContentCopyWith<$Res>(_self.content!, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [HelpCenterState].
extension HelpCenterStatePatterns on HelpCenterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCenterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCenterState value)  $default,){
final _that = this;
switch (_that) {
case _HelpCenterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCenterState value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  HelpCenterContent? content,  bool offline,  Object? error,  String query,  bool searching,  List<HelpArticle>? results,  bool savedResults,  Object? searchError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
return $default(_that.status,_that.content,_that.offline,_that.error,_that.query,_that.searching,_that.results,_that.savedResults,_that.searchError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  HelpCenterContent? content,  bool offline,  Object? error,  String query,  bool searching,  List<HelpArticle>? results,  bool savedResults,  Object? searchError)  $default,) {final _that = this;
switch (_that) {
case _HelpCenterState():
return $default(_that.status,_that.content,_that.offline,_that.error,_that.query,_that.searching,_that.results,_that.savedResults,_that.searchError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  HelpCenterContent? content,  bool offline,  Object? error,  String query,  bool searching,  List<HelpArticle>? results,  bool savedResults,  Object? searchError)?  $default,) {final _that = this;
switch (_that) {
case _HelpCenterState() when $default != null:
return $default(_that.status,_that.content,_that.offline,_that.error,_that.query,_that.searching,_that.results,_that.savedResults,_that.searchError);case _:
  return null;

}
}

}

/// @nodoc


class _HelpCenterState extends HelpCenterState {
  const _HelpCenterState({this.status = LoadStatus.initial, this.content, this.offline = false, this.error, this.query = '', this.searching = false, final  List<HelpArticle>? results, this.savedResults = false, this.searchError}): _results = results,super._();
  

@override@JsonKey() final  LoadStatus status;
@override final  HelpCenterContent? content;
@override@JsonKey() final  bool offline;
@override final  Object? error;
@override@JsonKey() final  String query;
@override@JsonKey() final  bool searching;
 final  List<HelpArticle>? _results;
@override List<HelpArticle>? get results {
  final value = _results;
  if (value == null) return null;
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool savedResults;
@override final  Object? searchError;

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCenterStateCopyWith<_HelpCenterState> get copyWith => __$HelpCenterStateCopyWithImpl<_HelpCenterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCenterState&&(identical(other.status, status) || other.status == status)&&(identical(other.content, content) || other.content == content)&&(identical(other.offline, offline) || other.offline == offline)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.query, query) || other.query == query)&&(identical(other.searching, searching) || other.searching == searching)&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.savedResults, savedResults) || other.savedResults == savedResults)&&const DeepCollectionEquality().equals(other.searchError, searchError));
}


@override
int get hashCode => Object.hash(runtimeType,status,content,offline,const DeepCollectionEquality().hash(error),query,searching,const DeepCollectionEquality().hash(_results),savedResults,const DeepCollectionEquality().hash(searchError));

@override
String toString() {
  return 'HelpCenterState(status: $status, content: $content, offline: $offline, error: $error, query: $query, searching: $searching, results: $results, savedResults: $savedResults, searchError: $searchError)';
}


}

/// @nodoc
abstract mixin class _$HelpCenterStateCopyWith<$Res> implements $HelpCenterStateCopyWith<$Res> {
  factory _$HelpCenterStateCopyWith(_HelpCenterState value, $Res Function(_HelpCenterState) _then) = __$HelpCenterStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, HelpCenterContent? content, bool offline, Object? error, String query, bool searching, List<HelpArticle>? results, bool savedResults, Object? searchError
});


@override $HelpCenterContentCopyWith<$Res>? get content;

}
/// @nodoc
class __$HelpCenterStateCopyWithImpl<$Res>
    implements _$HelpCenterStateCopyWith<$Res> {
  __$HelpCenterStateCopyWithImpl(this._self, this._then);

  final _HelpCenterState _self;
  final $Res Function(_HelpCenterState) _then;

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? content = freezed,Object? offline = null,Object? error = freezed,Object? query = null,Object? searching = null,Object? results = freezed,Object? savedResults = null,Object? searchError = freezed,}) {
  return _then(_HelpCenterState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as HelpCenterContent?,offline: null == offline ? _self.offline : offline // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,results: freezed == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<HelpArticle>?,savedResults: null == savedResults ? _self.savedResults : savedResults // ignore: cast_nullable_to_non_nullable
as bool,searchError: freezed == searchError ? _self.searchError : searchError ,
  ));
}

/// Create a copy of HelpCenterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpCenterContentCopyWith<$Res>? get content {
    if (_self.content == null) {
    return null;
  }

  return $HelpCenterContentCopyWith<$Res>(_self.content!, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}

// dart format on
