// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_support_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GuestSupportState {

 GuestSupportPhase get phase; GuestSupportConfig? get config; GuestSupportToken? get token; SupportTicket? get ticket; List<ChatMessage> get messages; bool get starting; bool get sending; bool get ending; bool get reconnecting; GuestSupportEndReason? get endReason; Object? get error; Object? get actionError; int get actionErrorId;
/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestSupportStateCopyWith<GuestSupportState> get copyWith => _$GuestSupportStateCopyWithImpl<GuestSupportState>(this as GuestSupportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestSupportState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.token, token) || other.token == token)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.starting, starting) || other.starting == starting)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.ending, ending) || other.ending == ending)&&(identical(other.reconnecting, reconnecting) || other.reconnecting == reconnecting)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,token,ticket,const DeepCollectionEquality().hash(messages),starting,sending,ending,reconnecting,endReason,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'GuestSupportState(phase: $phase, config: $config, token: $token, ticket: $ticket, messages: $messages, starting: $starting, sending: $sending, ending: $ending, reconnecting: $reconnecting, endReason: $endReason, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class $GuestSupportStateCopyWith<$Res>  {
  factory $GuestSupportStateCopyWith(GuestSupportState value, $Res Function(GuestSupportState) _then) = _$GuestSupportStateCopyWithImpl;
@useResult
$Res call({
 GuestSupportPhase phase, GuestSupportConfig? config, GuestSupportToken? token, SupportTicket? ticket, List<ChatMessage> messages, bool starting, bool sending, bool ending, bool reconnecting, GuestSupportEndReason? endReason, Object? error, Object? actionError, int actionErrorId
});


$GuestSupportConfigCopyWith<$Res>? get config;$GuestSupportTokenCopyWith<$Res>? get token;$SupportTicketCopyWith<$Res>? get ticket;

}
/// @nodoc
class _$GuestSupportStateCopyWithImpl<$Res>
    implements $GuestSupportStateCopyWith<$Res> {
  _$GuestSupportStateCopyWithImpl(this._self, this._then);

  final GuestSupportState _self;
  final $Res Function(GuestSupportState) _then;

/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? config = freezed,Object? token = freezed,Object? ticket = freezed,Object? messages = null,Object? starting = null,Object? sending = null,Object? ending = null,Object? reconnecting = null,Object? endReason = freezed,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GuestSupportPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as GuestSupportConfig?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as GuestSupportToken?,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,starting: null == starting ? _self.starting : starting // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,ending: null == ending ? _self.ending : ending // ignore: cast_nullable_to_non_nullable
as bool,reconnecting: null == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as bool,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as GuestSupportEndReason?,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $GuestSupportConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportTokenCopyWith<$Res>? get token {
    if (_self.token == null) {
    return null;
  }

  return $GuestSupportTokenCopyWith<$Res>(_self.token!, (value) {
    return _then(_self.copyWith(token: value));
  });
}/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
    return null;
  }

  return $SupportTicketCopyWith<$Res>(_self.ticket!, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuestSupportState].
extension GuestSupportStatePatterns on GuestSupportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestSupportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestSupportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestSupportState value)  $default,){
final _that = this;
switch (_that) {
case _GuestSupportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestSupportState value)?  $default,){
final _that = this;
switch (_that) {
case _GuestSupportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GuestSupportPhase phase,  GuestSupportConfig? config,  GuestSupportToken? token,  SupportTicket? ticket,  List<ChatMessage> messages,  bool starting,  bool sending,  bool ending,  bool reconnecting,  GuestSupportEndReason? endReason,  Object? error,  Object? actionError,  int actionErrorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestSupportState() when $default != null:
return $default(_that.phase,_that.config,_that.token,_that.ticket,_that.messages,_that.starting,_that.sending,_that.ending,_that.reconnecting,_that.endReason,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GuestSupportPhase phase,  GuestSupportConfig? config,  GuestSupportToken? token,  SupportTicket? ticket,  List<ChatMessage> messages,  bool starting,  bool sending,  bool ending,  bool reconnecting,  GuestSupportEndReason? endReason,  Object? error,  Object? actionError,  int actionErrorId)  $default,) {final _that = this;
switch (_that) {
case _GuestSupportState():
return $default(_that.phase,_that.config,_that.token,_that.ticket,_that.messages,_that.starting,_that.sending,_that.ending,_that.reconnecting,_that.endReason,_that.error,_that.actionError,_that.actionErrorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GuestSupportPhase phase,  GuestSupportConfig? config,  GuestSupportToken? token,  SupportTicket? ticket,  List<ChatMessage> messages,  bool starting,  bool sending,  bool ending,  bool reconnecting,  GuestSupportEndReason? endReason,  Object? error,  Object? actionError,  int actionErrorId)?  $default,) {final _that = this;
switch (_that) {
case _GuestSupportState() when $default != null:
return $default(_that.phase,_that.config,_that.token,_that.ticket,_that.messages,_that.starting,_that.sending,_that.ending,_that.reconnecting,_that.endReason,_that.error,_that.actionError,_that.actionErrorId);case _:
  return null;

}
}

}

/// @nodoc


class _GuestSupportState extends GuestSupportState {
  const _GuestSupportState({this.phase = GuestSupportPhase.loading, this.config, this.token, this.ticket, final  List<ChatMessage> messages = const <ChatMessage>[], this.starting = false, this.sending = false, this.ending = false, this.reconnecting = false, this.endReason, this.error, this.actionError, this.actionErrorId = 0}): _messages = messages,super._();
  

@override@JsonKey() final  GuestSupportPhase phase;
@override final  GuestSupportConfig? config;
@override final  GuestSupportToken? token;
@override final  SupportTicket? ticket;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool starting;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool ending;
@override@JsonKey() final  bool reconnecting;
@override final  GuestSupportEndReason? endReason;
@override final  Object? error;
@override final  Object? actionError;
@override@JsonKey() final  int actionErrorId;

/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestSupportStateCopyWith<_GuestSupportState> get copyWith => __$GuestSupportStateCopyWithImpl<_GuestSupportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestSupportState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.config, config) || other.config == config)&&(identical(other.token, token) || other.token == token)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.starting, starting) || other.starting == starting)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.ending, ending) || other.ending == ending)&&(identical(other.reconnecting, reconnecting) || other.reconnecting == reconnecting)&&(identical(other.endReason, endReason) || other.endReason == endReason)&&const DeepCollectionEquality().equals(other.error, error)&&const DeepCollectionEquality().equals(other.actionError, actionError)&&(identical(other.actionErrorId, actionErrorId) || other.actionErrorId == actionErrorId));
}


@override
int get hashCode => Object.hash(runtimeType,phase,config,token,ticket,const DeepCollectionEquality().hash(_messages),starting,sending,ending,reconnecting,endReason,const DeepCollectionEquality().hash(error),const DeepCollectionEquality().hash(actionError),actionErrorId);

@override
String toString() {
  return 'GuestSupportState(phase: $phase, config: $config, token: $token, ticket: $ticket, messages: $messages, starting: $starting, sending: $sending, ending: $ending, reconnecting: $reconnecting, endReason: $endReason, error: $error, actionError: $actionError, actionErrorId: $actionErrorId)';
}


}

/// @nodoc
abstract mixin class _$GuestSupportStateCopyWith<$Res> implements $GuestSupportStateCopyWith<$Res> {
  factory _$GuestSupportStateCopyWith(_GuestSupportState value, $Res Function(_GuestSupportState) _then) = __$GuestSupportStateCopyWithImpl;
@override @useResult
$Res call({
 GuestSupportPhase phase, GuestSupportConfig? config, GuestSupportToken? token, SupportTicket? ticket, List<ChatMessage> messages, bool starting, bool sending, bool ending, bool reconnecting, GuestSupportEndReason? endReason, Object? error, Object? actionError, int actionErrorId
});


@override $GuestSupportConfigCopyWith<$Res>? get config;@override $GuestSupportTokenCopyWith<$Res>? get token;@override $SupportTicketCopyWith<$Res>? get ticket;

}
/// @nodoc
class __$GuestSupportStateCopyWithImpl<$Res>
    implements _$GuestSupportStateCopyWith<$Res> {
  __$GuestSupportStateCopyWithImpl(this._self, this._then);

  final _GuestSupportState _self;
  final $Res Function(_GuestSupportState) _then;

/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? config = freezed,Object? token = freezed,Object? ticket = freezed,Object? messages = null,Object? starting = null,Object? sending = null,Object? ending = null,Object? reconnecting = null,Object? endReason = freezed,Object? error = freezed,Object? actionError = freezed,Object? actionErrorId = null,}) {
  return _then(_GuestSupportState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GuestSupportPhase,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as GuestSupportConfig?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as GuestSupportToken?,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,starting: null == starting ? _self.starting : starting // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,ending: null == ending ? _self.ending : ending // ignore: cast_nullable_to_non_nullable
as bool,reconnecting: null == reconnecting ? _self.reconnecting : reconnecting // ignore: cast_nullable_to_non_nullable
as bool,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as GuestSupportEndReason?,error: freezed == error ? _self.error : error ,actionError: freezed == actionError ? _self.actionError : actionError ,actionErrorId: null == actionErrorId ? _self.actionErrorId : actionErrorId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $GuestSupportConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestSupportTokenCopyWith<$Res>? get token {
    if (_self.token == null) {
    return null;
  }

  return $GuestSupportTokenCopyWith<$Res>(_self.token!, (value) {
    return _then(_self.copyWith(token: value));
  });
}/// Create a copy of GuestSupportState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
    return null;
  }

  return $SupportTicketCopyWith<$Res>(_self.ticket!, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}

// dart format on
