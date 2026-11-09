// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_transcript.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupportTranscriptMessage {

 DateTime get createdAt; SupportTranscriptSender get sender; String? get senderName; String? get body; bool get deleted; List<String> get attachments;
/// Create a copy of SupportTranscriptMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTranscriptMessageCopyWith<SupportTranscriptMessage> get copyWith => _$SupportTranscriptMessageCopyWithImpl<SupportTranscriptMessage>(this as SupportTranscriptMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTranscriptMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.body, body) || other.body == body)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,createdAt,sender,senderName,body,deleted,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'SupportTranscriptMessage(createdAt: $createdAt, sender: $sender, senderName: $senderName, body: $body, deleted: $deleted, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $SupportTranscriptMessageCopyWith<$Res>  {
  factory $SupportTranscriptMessageCopyWith(SupportTranscriptMessage value, $Res Function(SupportTranscriptMessage) _then) = _$SupportTranscriptMessageCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, SupportTranscriptSender sender, String? senderName, String? body, bool deleted, List<String> attachments
});




}
/// @nodoc
class _$SupportTranscriptMessageCopyWithImpl<$Res>
    implements $SupportTranscriptMessageCopyWith<$Res> {
  _$SupportTranscriptMessageCopyWithImpl(this._self, this._then);

  final SupportTranscriptMessage _self;
  final $Res Function(SupportTranscriptMessage) _then;

/// Create a copy of SupportTranscriptMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? sender = null,Object? senderName = freezed,Object? body = freezed,Object? deleted = null,Object? attachments = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SupportTranscriptSender,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTranscriptMessage].
extension SupportTranscriptMessagePatterns on SupportTranscriptMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTranscriptMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTranscriptMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTranscriptMessage value)  $default,){
final _that = this;
switch (_that) {
case _SupportTranscriptMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTranscriptMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTranscriptMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  SupportTranscriptSender sender,  String? senderName,  String? body,  bool deleted,  List<String> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTranscriptMessage() when $default != null:
return $default(_that.createdAt,_that.sender,_that.senderName,_that.body,_that.deleted,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  SupportTranscriptSender sender,  String? senderName,  String? body,  bool deleted,  List<String> attachments)  $default,) {final _that = this;
switch (_that) {
case _SupportTranscriptMessage():
return $default(_that.createdAt,_that.sender,_that.senderName,_that.body,_that.deleted,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  SupportTranscriptSender sender,  String? senderName,  String? body,  bool deleted,  List<String> attachments)?  $default,) {final _that = this;
switch (_that) {
case _SupportTranscriptMessage() when $default != null:
return $default(_that.createdAt,_that.sender,_that.senderName,_that.body,_that.deleted,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _SupportTranscriptMessage implements SupportTranscriptMessage {
  const _SupportTranscriptMessage({required this.createdAt, required this.sender, this.senderName, this.body, this.deleted = false, final  List<String> attachments = const <String>[]}): _attachments = attachments;
  

@override final  DateTime createdAt;
@override final  SupportTranscriptSender sender;
@override final  String? senderName;
@override final  String? body;
@override@JsonKey() final  bool deleted;
 final  List<String> _attachments;
@override@JsonKey() List<String> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of SupportTranscriptMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTranscriptMessageCopyWith<_SupportTranscriptMessage> get copyWith => __$SupportTranscriptMessageCopyWithImpl<_SupportTranscriptMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTranscriptMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.body, body) || other.body == body)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,createdAt,sender,senderName,body,deleted,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'SupportTranscriptMessage(createdAt: $createdAt, sender: $sender, senderName: $senderName, body: $body, deleted: $deleted, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$SupportTranscriptMessageCopyWith<$Res> implements $SupportTranscriptMessageCopyWith<$Res> {
  factory _$SupportTranscriptMessageCopyWith(_SupportTranscriptMessage value, $Res Function(_SupportTranscriptMessage) _then) = __$SupportTranscriptMessageCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, SupportTranscriptSender sender, String? senderName, String? body, bool deleted, List<String> attachments
});




}
/// @nodoc
class __$SupportTranscriptMessageCopyWithImpl<$Res>
    implements _$SupportTranscriptMessageCopyWith<$Res> {
  __$SupportTranscriptMessageCopyWithImpl(this._self, this._then);

  final _SupportTranscriptMessage _self;
  final $Res Function(_SupportTranscriptMessage) _then;

/// Create a copy of SupportTranscriptMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? sender = null,Object? senderName = freezed,Object? body = freezed,Object? deleted = null,Object? attachments = null,}) {
  return _then(_SupportTranscriptMessage(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SupportTranscriptSender,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$SupportTranscript {

 SupportTicket get ticket; List<SupportTranscriptMessage> get messages;
/// Create a copy of SupportTranscript
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTranscriptCopyWith<SupportTranscript> get copyWith => _$SupportTranscriptCopyWithImpl<SupportTranscript>(this as SupportTranscript, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTranscript&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other.messages, messages));
}


@override
int get hashCode => Object.hash(runtimeType,ticket,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'SupportTranscript(ticket: $ticket, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $SupportTranscriptCopyWith<$Res>  {
  factory $SupportTranscriptCopyWith(SupportTranscript value, $Res Function(SupportTranscript) _then) = _$SupportTranscriptCopyWithImpl;
@useResult
$Res call({
 SupportTicket ticket, List<SupportTranscriptMessage> messages
});


$SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class _$SupportTranscriptCopyWithImpl<$Res>
    implements $SupportTranscriptCopyWith<$Res> {
  _$SupportTranscriptCopyWithImpl(this._self, this._then);

  final SupportTranscript _self;
  final $Res Function(SupportTranscript) _then;

/// Create a copy of SupportTranscript
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticket = null,Object? messages = null,}) {
  return _then(_self.copyWith(
ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SupportTranscriptMessage>,
  ));
}
/// Create a copy of SupportTranscript
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<$Res> get ticket {
  
  return $SupportTicketCopyWith<$Res>(_self.ticket, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}


/// Adds pattern-matching-related methods to [SupportTranscript].
extension SupportTranscriptPatterns on SupportTranscript {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTranscript value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTranscript() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTranscript value)  $default,){
final _that = this;
switch (_that) {
case _SupportTranscript():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTranscript value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTranscript() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SupportTicket ticket,  List<SupportTranscriptMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTranscript() when $default != null:
return $default(_that.ticket,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SupportTicket ticket,  List<SupportTranscriptMessage> messages)  $default,) {final _that = this;
switch (_that) {
case _SupportTranscript():
return $default(_that.ticket,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SupportTicket ticket,  List<SupportTranscriptMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case _SupportTranscript() when $default != null:
return $default(_that.ticket,_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class _SupportTranscript implements SupportTranscript {
  const _SupportTranscript({required this.ticket, final  List<SupportTranscriptMessage> messages = const <SupportTranscriptMessage>[]}): _messages = messages;
  

@override final  SupportTicket ticket;
 final  List<SupportTranscriptMessage> _messages;
@override@JsonKey() List<SupportTranscriptMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of SupportTranscript
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTranscriptCopyWith<_SupportTranscript> get copyWith => __$SupportTranscriptCopyWithImpl<_SupportTranscript>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTranscript&&(identical(other.ticket, ticket) || other.ticket == ticket)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,ticket,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'SupportTranscript(ticket: $ticket, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$SupportTranscriptCopyWith<$Res> implements $SupportTranscriptCopyWith<$Res> {
  factory _$SupportTranscriptCopyWith(_SupportTranscript value, $Res Function(_SupportTranscript) _then) = __$SupportTranscriptCopyWithImpl;
@override @useResult
$Res call({
 SupportTicket ticket, List<SupportTranscriptMessage> messages
});


@override $SupportTicketCopyWith<$Res> get ticket;

}
/// @nodoc
class __$SupportTranscriptCopyWithImpl<$Res>
    implements _$SupportTranscriptCopyWith<$Res> {
  __$SupportTranscriptCopyWithImpl(this._self, this._then);

  final _SupportTranscript _self;
  final $Res Function(_SupportTranscript) _then;

/// Create a copy of SupportTranscript
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticket = null,Object? messages = null,}) {
  return _then(_SupportTranscript(
ticket: null == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SupportTranscriptMessage>,
  ));
}

/// Create a copy of SupportTranscript
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
