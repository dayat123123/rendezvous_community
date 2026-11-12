// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market_instrument.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketInstrument {

 String get code; String get name; MarketInstrumentKind get kind; String? get description; List<String> get aliases; int get position; bool get roomEnabled;
/// Create a copy of MarketInstrument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketInstrumentCopyWith<MarketInstrument> get copyWith => _$MarketInstrumentCopyWithImpl<MarketInstrument>(this as MarketInstrument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketInstrument&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.aliases, aliases)&&(identical(other.position, position) || other.position == position)&&(identical(other.roomEnabled, roomEnabled) || other.roomEnabled == roomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,kind,description,const DeepCollectionEquality().hash(aliases),position,roomEnabled);

@override
String toString() {
  return 'MarketInstrument(code: $code, name: $name, kind: $kind, description: $description, aliases: $aliases, position: $position, roomEnabled: $roomEnabled)';
}


}

/// @nodoc
abstract mixin class $MarketInstrumentCopyWith<$Res>  {
  factory $MarketInstrumentCopyWith(MarketInstrument value, $Res Function(MarketInstrument) _then) = _$MarketInstrumentCopyWithImpl;
@useResult
$Res call({
 String code, String name, MarketInstrumentKind kind, String? description, List<String> aliases, int position, bool roomEnabled
});




}
/// @nodoc
class _$MarketInstrumentCopyWithImpl<$Res>
    implements $MarketInstrumentCopyWith<$Res> {
  _$MarketInstrumentCopyWithImpl(this._self, this._then);

  final MarketInstrument _self;
  final $Res Function(MarketInstrument) _then;

/// Create a copy of MarketInstrument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? kind = null,Object? description = freezed,Object? aliases = null,Object? position = null,Object? roomEnabled = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarketInstrumentKind,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,roomEnabled: null == roomEnabled ? _self.roomEnabled : roomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketInstrument].
extension MarketInstrumentPatterns on MarketInstrument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketInstrument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketInstrument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketInstrument value)  $default,){
final _that = this;
switch (_that) {
case _MarketInstrument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketInstrument value)?  $default,){
final _that = this;
switch (_that) {
case _MarketInstrument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  MarketInstrumentKind kind,  String? description,  List<String> aliases,  int position,  bool roomEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketInstrument() when $default != null:
return $default(_that.code,_that.name,_that.kind,_that.description,_that.aliases,_that.position,_that.roomEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  MarketInstrumentKind kind,  String? description,  List<String> aliases,  int position,  bool roomEnabled)  $default,) {final _that = this;
switch (_that) {
case _MarketInstrument():
return $default(_that.code,_that.name,_that.kind,_that.description,_that.aliases,_that.position,_that.roomEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  MarketInstrumentKind kind,  String? description,  List<String> aliases,  int position,  bool roomEnabled)?  $default,) {final _that = this;
switch (_that) {
case _MarketInstrument() when $default != null:
return $default(_that.code,_that.name,_that.kind,_that.description,_that.aliases,_that.position,_that.roomEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _MarketInstrument implements MarketInstrument {
  const _MarketInstrument({required this.code, required this.name, this.kind = MarketInstrumentKind.stockIndex, this.description, final  List<String> aliases = const <String>[], this.position = 0, this.roomEnabled = true}): _aliases = aliases;
  

@override final  String code;
@override final  String name;
@override@JsonKey() final  MarketInstrumentKind kind;
@override final  String? description;
 final  List<String> _aliases;
@override@JsonKey() List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

@override@JsonKey() final  int position;
@override@JsonKey() final  bool roomEnabled;

/// Create a copy of MarketInstrument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketInstrumentCopyWith<_MarketInstrument> get copyWith => __$MarketInstrumentCopyWithImpl<_MarketInstrument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketInstrument&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._aliases, _aliases)&&(identical(other.position, position) || other.position == position)&&(identical(other.roomEnabled, roomEnabled) || other.roomEnabled == roomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,kind,description,const DeepCollectionEquality().hash(_aliases),position,roomEnabled);

@override
String toString() {
  return 'MarketInstrument(code: $code, name: $name, kind: $kind, description: $description, aliases: $aliases, position: $position, roomEnabled: $roomEnabled)';
}


}

/// @nodoc
abstract mixin class _$MarketInstrumentCopyWith<$Res> implements $MarketInstrumentCopyWith<$Res> {
  factory _$MarketInstrumentCopyWith(_MarketInstrument value, $Res Function(_MarketInstrument) _then) = __$MarketInstrumentCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, MarketInstrumentKind kind, String? description, List<String> aliases, int position, bool roomEnabled
});




}
/// @nodoc
class __$MarketInstrumentCopyWithImpl<$Res>
    implements _$MarketInstrumentCopyWith<$Res> {
  __$MarketInstrumentCopyWithImpl(this._self, this._then);

  final _MarketInstrument _self;
  final $Res Function(_MarketInstrument) _then;

/// Create a copy of MarketInstrument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? kind = null,Object? description = freezed,Object? aliases = null,Object? position = null,Object? roomEnabled = null,}) {
  return _then(_MarketInstrument(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarketInstrumentKind,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,roomEnabled: null == roomEnabled ? _self.roomEnabled : roomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
