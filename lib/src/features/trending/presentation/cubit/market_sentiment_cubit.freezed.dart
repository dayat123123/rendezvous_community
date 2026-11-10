// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_sentiment_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketSentimentState {

 LoadStatus get status; TrendWindow get window; Map<TrendWindow, SentimentBreakdown> get breakdowns; Object? get error;
/// Create a copy of MarketSentimentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketSentimentStateCopyWith<MarketSentimentState> get copyWith => _$MarketSentimentStateCopyWithImpl<MarketSentimentState>(this as MarketSentimentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketSentimentState&&(identical(other.status, status) || other.status == status)&&(identical(other.window, window) || other.window == window)&&const DeepCollectionEquality().equals(other.breakdowns, breakdowns)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,status,window,const DeepCollectionEquality().hash(breakdowns),const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'MarketSentimentState(status: $status, window: $window, breakdowns: $breakdowns, error: $error)';
}


}

/// @nodoc
abstract mixin class $MarketSentimentStateCopyWith<$Res>  {
  factory $MarketSentimentStateCopyWith(MarketSentimentState value, $Res Function(MarketSentimentState) _then) = _$MarketSentimentStateCopyWithImpl;
@useResult
$Res call({
 LoadStatus status, TrendWindow window, Map<TrendWindow, SentimentBreakdown> breakdowns, Object? error
});




}
/// @nodoc
class _$MarketSentimentStateCopyWithImpl<$Res>
    implements $MarketSentimentStateCopyWith<$Res> {
  _$MarketSentimentStateCopyWithImpl(this._self, this._then);

  final MarketSentimentState _self;
  final $Res Function(MarketSentimentState) _then;

/// Create a copy of MarketSentimentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? window = null,Object? breakdowns = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as TrendWindow,breakdowns: null == breakdowns ? _self.breakdowns : breakdowns // ignore: cast_nullable_to_non_nullable
as Map<TrendWindow, SentimentBreakdown>,error: freezed == error ? _self.error : error ,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketSentimentState].
extension MarketSentimentStatePatterns on MarketSentimentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketSentimentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketSentimentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketSentimentState value)  $default,){
final _that = this;
switch (_that) {
case _MarketSentimentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketSentimentState value)?  $default,){
final _that = this;
switch (_that) {
case _MarketSentimentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoadStatus status,  TrendWindow window,  Map<TrendWindow, SentimentBreakdown> breakdowns,  Object? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketSentimentState() when $default != null:
return $default(_that.status,_that.window,_that.breakdowns,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoadStatus status,  TrendWindow window,  Map<TrendWindow, SentimentBreakdown> breakdowns,  Object? error)  $default,) {final _that = this;
switch (_that) {
case _MarketSentimentState():
return $default(_that.status,_that.window,_that.breakdowns,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoadStatus status,  TrendWindow window,  Map<TrendWindow, SentimentBreakdown> breakdowns,  Object? error)?  $default,) {final _that = this;
switch (_that) {
case _MarketSentimentState() when $default != null:
return $default(_that.status,_that.window,_that.breakdowns,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MarketSentimentState extends MarketSentimentState {
  const _MarketSentimentState({this.status = LoadStatus.initial, this.window = TrendWindow.day, final  Map<TrendWindow, SentimentBreakdown> breakdowns = const <TrendWindow, SentimentBreakdown>{}, this.error}): _breakdowns = breakdowns,super._();
  

@override@JsonKey() final  LoadStatus status;
@override@JsonKey() final  TrendWindow window;
 final  Map<TrendWindow, SentimentBreakdown> _breakdowns;
@override@JsonKey() Map<TrendWindow, SentimentBreakdown> get breakdowns {
  if (_breakdowns is EqualUnmodifiableMapView) return _breakdowns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_breakdowns);
}

@override final  Object? error;

/// Create a copy of MarketSentimentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketSentimentStateCopyWith<_MarketSentimentState> get copyWith => __$MarketSentimentStateCopyWithImpl<_MarketSentimentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketSentimentState&&(identical(other.status, status) || other.status == status)&&(identical(other.window, window) || other.window == window)&&const DeepCollectionEquality().equals(other._breakdowns, _breakdowns)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,status,window,const DeepCollectionEquality().hash(_breakdowns),const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'MarketSentimentState(status: $status, window: $window, breakdowns: $breakdowns, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MarketSentimentStateCopyWith<$Res> implements $MarketSentimentStateCopyWith<$Res> {
  factory _$MarketSentimentStateCopyWith(_MarketSentimentState value, $Res Function(_MarketSentimentState) _then) = __$MarketSentimentStateCopyWithImpl;
@override @useResult
$Res call({
 LoadStatus status, TrendWindow window, Map<TrendWindow, SentimentBreakdown> breakdowns, Object? error
});




}
/// @nodoc
class __$MarketSentimentStateCopyWithImpl<$Res>
    implements _$MarketSentimentStateCopyWith<$Res> {
  __$MarketSentimentStateCopyWithImpl(this._self, this._then);

  final _MarketSentimentState _self;
  final $Res Function(_MarketSentimentState) _then;

/// Create a copy of MarketSentimentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? window = null,Object? breakdowns = null,Object? error = freezed,}) {
  return _then(_MarketSentimentState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LoadStatus,window: null == window ? _self.window : window // ignore: cast_nullable_to_non_nullable
as TrendWindow,breakdowns: null == breakdowns ? _self._breakdowns : breakdowns // ignore: cast_nullable_to_non_nullable
as Map<TrendWindow, SentimentBreakdown>,error: freezed == error ? _self.error : error ,
  ));
}


}

// dart format on
