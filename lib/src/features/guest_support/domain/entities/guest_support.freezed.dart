// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_support.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GuestLoginProblem {

 String get code; String get label;
/// Create a copy of GuestLoginProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestLoginProblemCopyWith<GuestLoginProblem> get copyWith => _$GuestLoginProblemCopyWithImpl<GuestLoginProblem>(this as GuestLoginProblem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestLoginProblem&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'GuestLoginProblem(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class $GuestLoginProblemCopyWith<$Res>  {
  factory $GuestLoginProblemCopyWith(GuestLoginProblem value, $Res Function(GuestLoginProblem) _then) = _$GuestLoginProblemCopyWithImpl;
@useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class _$GuestLoginProblemCopyWithImpl<$Res>
    implements $GuestLoginProblemCopyWith<$Res> {
  _$GuestLoginProblemCopyWithImpl(this._self, this._then);

  final GuestLoginProblem _self;
  final $Res Function(GuestLoginProblem) _then;

/// Create a copy of GuestLoginProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? label = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestLoginProblem].
extension GuestLoginProblemPatterns on GuestLoginProblem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestLoginProblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestLoginProblem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestLoginProblem value)  $default,){
final _that = this;
switch (_that) {
case _GuestLoginProblem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestLoginProblem value)?  $default,){
final _that = this;
switch (_that) {
case _GuestLoginProblem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestLoginProblem() when $default != null:
return $default(_that.code,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String label)  $default,) {final _that = this;
switch (_that) {
case _GuestLoginProblem():
return $default(_that.code,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String label)?  $default,) {final _that = this;
switch (_that) {
case _GuestLoginProblem() when $default != null:
return $default(_that.code,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _GuestLoginProblem implements GuestLoginProblem {
  const _GuestLoginProblem({required this.code, required this.label});
  

@override final  String code;
@override final  String label;

/// Create a copy of GuestLoginProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestLoginProblemCopyWith<_GuestLoginProblem> get copyWith => __$GuestLoginProblemCopyWithImpl<_GuestLoginProblem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestLoginProblem&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'GuestLoginProblem(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class _$GuestLoginProblemCopyWith<$Res> implements $GuestLoginProblemCopyWith<$Res> {
  factory _$GuestLoginProblemCopyWith(_GuestLoginProblem value, $Res Function(_GuestLoginProblem) _then) = __$GuestLoginProblemCopyWithImpl;
@override @useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class __$GuestLoginProblemCopyWithImpl<$Res>
    implements _$GuestLoginProblemCopyWith<$Res> {
  __$GuestLoginProblemCopyWithImpl(this._self, this._then);

  final _GuestLoginProblem _self;
  final $Res Function(_GuestLoginProblem) _then;

/// Create a copy of GuestLoginProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? label = null,}) {
  return _then(_GuestLoginProblem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GuestSupportConfig {

 bool get enabled; int get sessionHours; List<GuestLoginProblem> get problems;
/// Create a copy of GuestSupportConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestSupportConfigCopyWith<GuestSupportConfig> get copyWith => _$GuestSupportConfigCopyWithImpl<GuestSupportConfig>(this as GuestSupportConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestSupportConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.sessionHours, sessionHours) || other.sessionHours == sessionHours)&&const DeepCollectionEquality().equals(other.problems, problems));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,sessionHours,const DeepCollectionEquality().hash(problems));

@override
String toString() {
  return 'GuestSupportConfig(enabled: $enabled, sessionHours: $sessionHours, problems: $problems)';
}


}

/// @nodoc
abstract mixin class $GuestSupportConfigCopyWith<$Res>  {
  factory $GuestSupportConfigCopyWith(GuestSupportConfig value, $Res Function(GuestSupportConfig) _then) = _$GuestSupportConfigCopyWithImpl;
@useResult
$Res call({
 bool enabled, int sessionHours, List<GuestLoginProblem> problems
});




}
/// @nodoc
class _$GuestSupportConfigCopyWithImpl<$Res>
    implements $GuestSupportConfigCopyWith<$Res> {
  _$GuestSupportConfigCopyWithImpl(this._self, this._then);

  final GuestSupportConfig _self;
  final $Res Function(GuestSupportConfig) _then;

/// Create a copy of GuestSupportConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? sessionHours = null,Object? problems = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,sessionHours: null == sessionHours ? _self.sessionHours : sessionHours // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as List<GuestLoginProblem>,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestSupportConfig].
extension GuestSupportConfigPatterns on GuestSupportConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestSupportConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestSupportConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestSupportConfig value)  $default,){
final _that = this;
switch (_that) {
case _GuestSupportConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestSupportConfig value)?  $default,){
final _that = this;
switch (_that) {
case _GuestSupportConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int sessionHours,  List<GuestLoginProblem> problems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestSupportConfig() when $default != null:
return $default(_that.enabled,_that.sessionHours,_that.problems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int sessionHours,  List<GuestLoginProblem> problems)  $default,) {final _that = this;
switch (_that) {
case _GuestSupportConfig():
return $default(_that.enabled,_that.sessionHours,_that.problems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int sessionHours,  List<GuestLoginProblem> problems)?  $default,) {final _that = this;
switch (_that) {
case _GuestSupportConfig() when $default != null:
return $default(_that.enabled,_that.sessionHours,_that.problems);case _:
  return null;

}
}

}

/// @nodoc


class _GuestSupportConfig implements GuestSupportConfig {
  const _GuestSupportConfig({this.enabled = false, this.sessionHours = 24, final  List<GuestLoginProblem> problems = const <GuestLoginProblem>[]}): _problems = problems;
  

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int sessionHours;
 final  List<GuestLoginProblem> _problems;
@override@JsonKey() List<GuestLoginProblem> get problems {
  if (_problems is EqualUnmodifiableListView) return _problems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_problems);
}


/// Create a copy of GuestSupportConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestSupportConfigCopyWith<_GuestSupportConfig> get copyWith => __$GuestSupportConfigCopyWithImpl<_GuestSupportConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestSupportConfig&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.sessionHours, sessionHours) || other.sessionHours == sessionHours)&&const DeepCollectionEquality().equals(other._problems, _problems));
}


@override
int get hashCode => Object.hash(runtimeType,enabled,sessionHours,const DeepCollectionEquality().hash(_problems));

@override
String toString() {
  return 'GuestSupportConfig(enabled: $enabled, sessionHours: $sessionHours, problems: $problems)';
}


}

/// @nodoc
abstract mixin class _$GuestSupportConfigCopyWith<$Res> implements $GuestSupportConfigCopyWith<$Res> {
  factory _$GuestSupportConfigCopyWith(_GuestSupportConfig value, $Res Function(_GuestSupportConfig) _then) = __$GuestSupportConfigCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int sessionHours, List<GuestLoginProblem> problems
});




}
/// @nodoc
class __$GuestSupportConfigCopyWithImpl<$Res>
    implements _$GuestSupportConfigCopyWith<$Res> {
  __$GuestSupportConfigCopyWithImpl(this._self, this._then);

  final _GuestSupportConfig _self;
  final $Res Function(_GuestSupportConfig) _then;

/// Create a copy of GuestSupportConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? sessionHours = null,Object? problems = null,}) {
  return _then(_GuestSupportConfig(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,sessionHours: null == sessionHours ? _self.sessionHours : sessionHours // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self._problems : problems // ignore: cast_nullable_to_non_nullable
as List<GuestLoginProblem>,
  ));
}


}

/// @nodoc
mixin _$GuestSupportToken {

 String get token; DateTime get expiresAt;
/// Create a copy of GuestSupportToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestSupportTokenCopyWith<GuestSupportToken> get copyWith => _$GuestSupportTokenCopyWithImpl<GuestSupportToken>(this as GuestSupportToken, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestSupportToken&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,token,expiresAt);



}

/// @nodoc
abstract mixin class $GuestSupportTokenCopyWith<$Res>  {
  factory $GuestSupportTokenCopyWith(GuestSupportToken value, $Res Function(GuestSupportToken) _then) = _$GuestSupportTokenCopyWithImpl;
@useResult
$Res call({
 String token, DateTime expiresAt
});




}
/// @nodoc
class _$GuestSupportTokenCopyWithImpl<$Res>
    implements $GuestSupportTokenCopyWith<$Res> {
  _$GuestSupportTokenCopyWithImpl(this._self, this._then);

  final GuestSupportToken _self;
  final $Res Function(GuestSupportToken) _then;

/// Create a copy of GuestSupportToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestSupportToken].
extension GuestSupportTokenPatterns on GuestSupportToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestSupportToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestSupportToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestSupportToken value)  $default,){
final _that = this;
switch (_that) {
case _GuestSupportToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestSupportToken value)?  $default,){
final _that = this;
switch (_that) {
case _GuestSupportToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestSupportToken() when $default != null:
return $default(_that.token,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _GuestSupportToken():
return $default(_that.token,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _GuestSupportToken() when $default != null:
return $default(_that.token,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _GuestSupportToken extends GuestSupportToken {
  const _GuestSupportToken({required this.token, required this.expiresAt}): super._();
  

@override final  String token;
@override final  DateTime expiresAt;

/// Create a copy of GuestSupportToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestSupportTokenCopyWith<_GuestSupportToken> get copyWith => __$GuestSupportTokenCopyWithImpl<_GuestSupportToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestSupportToken&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,token,expiresAt);



}

/// @nodoc
abstract mixin class _$GuestSupportTokenCopyWith<$Res> implements $GuestSupportTokenCopyWith<$Res> {
  factory _$GuestSupportTokenCopyWith(_GuestSupportToken value, $Res Function(_GuestSupportToken) _then) = __$GuestSupportTokenCopyWithImpl;
@override @useResult
$Res call({
 String token, DateTime expiresAt
});




}
/// @nodoc
class __$GuestSupportTokenCopyWithImpl<$Res>
    implements _$GuestSupportTokenCopyWith<$Res> {
  __$GuestSupportTokenCopyWithImpl(this._self, this._then);

  final _GuestSupportToken _self;
  final $Res Function(_GuestSupportToken) _then;

/// Create a copy of GuestSupportToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? expiresAt = null,}) {
  return _then(_GuestSupportToken(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$GuestSupportSession {

 GuestSupportToken get token; SupportTicket get ticket;
/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestSupportSessionCopyWith<GuestSupportSession> get copyWith => _$GuestSupportSessionCopyWithImpl<GuestSupportSession>(this as GuestSupportSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestSupportSession&&(identical(other.token, token) || other.token == token)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,token,ticket);

@override
String toString() {
  return 'GuestSupportSession(token: $token, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $GuestSupportSessionCopyWith<$Res>  {
  factory $GuestSupportSessionCopyWith(GuestSupportSession value, $Res Function(GuestSupportSession) _then) = _$GuestSupportSessionCopyWithImpl;
@useResult
$Res call({
 GuestSupportToken token, SupportTicket ticket
});


$GuestSupportTokenCopyWith<$Res> get token;$SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class _$GuestSupportSessionCopyWithImpl<$Res>
    implements $GuestSupportSessionCopyWith<$Res> {
  _$GuestSupportSessionCopyWithImpl(this._self, this._then);

  final GuestSupportSession _self;
  final $Res Function(GuestSupportSession) _then;

/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? ticket = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as GuestSupportToken,ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,
  ));
}
/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportTokenCopyWith<$Res> get token {
  
  return $GuestSupportTokenCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res> get ticket {
  
  return $SupportTicketCopyWith<$Res>(_self.ticket, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuestSupportSession].
extension GuestSupportSessionPatterns on GuestSupportSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestSupportSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestSupportSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestSupportSession value)  $default,){
final _that = this;
switch (_that) {
case _GuestSupportSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestSupportSession value)?  $default,){
final _that = this;
switch (_that) {
case _GuestSupportSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GuestSupportToken token,  SupportTicket ticket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestSupportSession() when $default != null:
return $default(_that.token,_that.ticket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GuestSupportToken token,  SupportTicket ticket)  $default,) {final _that = this;
switch (_that) {
case _GuestSupportSession():
return $default(_that.token,_that.ticket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GuestSupportToken token,  SupportTicket ticket)?  $default,) {final _that = this;
switch (_that) {
case _GuestSupportSession() when $default != null:
return $default(_that.token,_that.ticket);case _:
  return null;

}
}

}

/// @nodoc


class _GuestSupportSession implements GuestSupportSession {
  const _GuestSupportSession({required this.token, required this.ticket});
  

@override final  GuestSupportToken token;
@override final  SupportTicket ticket;

/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestSupportSessionCopyWith<_GuestSupportSession> get copyWith => __$GuestSupportSessionCopyWithImpl<_GuestSupportSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestSupportSession&&(identical(other.token, token) || other.token == token)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,token,ticket);

@override
String toString() {
  return 'GuestSupportSession(token: $token, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$GuestSupportSessionCopyWith<$Res> implements $GuestSupportSessionCopyWith<$Res> {
  factory _$GuestSupportSessionCopyWith(_GuestSupportSession value, $Res Function(_GuestSupportSession) _then) = __$GuestSupportSessionCopyWithImpl;
@override @useResult
$Res call({
 GuestSupportToken token, SupportTicket ticket
});


@override $GuestSupportTokenCopyWith<$Res> get token;@override $SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class __$GuestSupportSessionCopyWithImpl<$Res>
    implements _$GuestSupportSessionCopyWith<$Res> {
  __$GuestSupportSessionCopyWithImpl(this._self, this._then);

  final _GuestSupportSession _self;
  final $Res Function(_GuestSupportSession) _then;

/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? ticket = null,}) {
  return _then(_GuestSupportSession(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as GuestSupportToken,ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,
  ));
}

/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportTokenCopyWith<$Res> get token {
  
  return $GuestSupportTokenCopyWith<$Res>(_self.token, (value) {
    return _then(_self.copyWith(token: value));
  });
}/// Create a copy of GuestSupportSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res> get ticket {
  
  return $SupportTicketCopyWith<$Res>(_self.ticket, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}

/// @nodoc
mixin _$GuestSupportSnapshot {

 DateTime get expiresAt; SupportTicket get ticket; List<ChatMessage> get messages;
/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestSupportSnapshotCopyWith<GuestSupportSnapshot> get copyWith => _$GuestSupportSnapshotCopyWithImpl<GuestSupportSnapshot>(this as GuestSupportSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestSupportSnapshot&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other.messages, messages));
}


@override
int get hashCode => Object.hash(runtimeType,expiresAt,ticket,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'GuestSupportSnapshot(expiresAt: $expiresAt, ticket: $ticket, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $GuestSupportSnapshotCopyWith<$Res>  {
  factory $GuestSupportSnapshotCopyWith(GuestSupportSnapshot value, $Res Function(GuestSupportSnapshot) _then) = _$GuestSupportSnapshotCopyWithImpl;
@useResult
$Res call({
 DateTime expiresAt, SupportTicket ticket, List<ChatMessage> messages
});


$SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class _$GuestSupportSnapshotCopyWithImpl<$Res>
    implements $GuestSupportSnapshotCopyWith<$Res> {
  _$GuestSupportSnapshotCopyWithImpl(this._self, this._then);

  final GuestSupportSnapshot _self;
  final $Res Function(GuestSupportSnapshot) _then;

/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expiresAt = null,Object? ticket = null,Object? messages = null,}) {
  return _then(_self.copyWith(
expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}
/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res> get ticket {
  
  return $SupportTicketCopyWith<$Res>(_self.ticket, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuestSupportSnapshot].
extension GuestSupportSnapshotPatterns on GuestSupportSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestSupportSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestSupportSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestSupportSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _GuestSupportSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestSupportSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _GuestSupportSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime expiresAt,  SupportTicket ticket,  List<ChatMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestSupportSnapshot() when $default != null:
return $default(_that.expiresAt,_that.ticket,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime expiresAt,  SupportTicket ticket,  List<ChatMessage> messages)  $default,) {final _that = this;
switch (_that) {
case _GuestSupportSnapshot():
return $default(_that.expiresAt,_that.ticket,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime expiresAt,  SupportTicket ticket,  List<ChatMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case _GuestSupportSnapshot() when $default != null:
return $default(_that.expiresAt,_that.ticket,_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _GuestSupportSnapshot implements GuestSupportSnapshot {
  const _GuestSupportSnapshot({required this.expiresAt, required this.ticket, final  List<ChatMessage> messages = const <ChatMessage>[]}): _messages = messages;
  

@override final  DateTime expiresAt;
@override final  SupportTicket ticket;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestSupportSnapshotCopyWith<_GuestSupportSnapshot> get copyWith => __$GuestSupportSnapshotCopyWithImpl<_GuestSupportSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestSupportSnapshot&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,expiresAt,ticket,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'GuestSupportSnapshot(expiresAt: $expiresAt, ticket: $ticket, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$GuestSupportSnapshotCopyWith<$Res> implements $GuestSupportSnapshotCopyWith<$Res> {
  factory _$GuestSupportSnapshotCopyWith(_GuestSupportSnapshot value, $Res Function(_GuestSupportSnapshot) _then) = __$GuestSupportSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DateTime expiresAt, SupportTicket ticket, List<ChatMessage> messages
});


@override $SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class __$GuestSupportSnapshotCopyWithImpl<$Res>
    implements _$GuestSupportSnapshotCopyWith<$Res> {
  __$GuestSupportSnapshotCopyWithImpl(this._self, this._then);

  final _GuestSupportSnapshot _self;
  final $Res Function(_GuestSupportSnapshot) _then;

/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expiresAt = null,Object? ticket = null,Object? messages = null,}) {
  return _then(_GuestSupportSnapshot(
expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}

/// Create a copy of GuestSupportSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res> get ticket {
  
  return $SupportTicketCopyWith<$Res>(_self.ticket, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}

// dart format on
