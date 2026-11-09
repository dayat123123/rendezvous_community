// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupportAgent {

 String get displayName; String? get agentCode;
/// Create a copy of SupportAgent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportAgentCopyWith<SupportAgent> get copyWith => _$SupportAgentCopyWithImpl<SupportAgent>(this as SupportAgent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportAgent&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.agentCode, agentCode) || other.agentCode == agentCode));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,agentCode);

@override
String toString() {
  return 'SupportAgent(displayName: $displayName, agentCode: $agentCode)';
}


}

/// @nodoc
abstract mixin class $SupportAgentCopyWith<$Res>  {
  factory $SupportAgentCopyWith(SupportAgent value, $Res Function(SupportAgent) _then) = _$SupportAgentCopyWithImpl;
@useResult
$Res call({
 String displayName, String? agentCode
});




}
/// @nodoc
class _$SupportAgentCopyWithImpl<$Res>
    implements $SupportAgentCopyWith<$Res> {
  _$SupportAgentCopyWithImpl(this._self, this._then);

  final SupportAgent _self;
  final $Res Function(SupportAgent) _then;

/// Create a copy of SupportAgent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? agentCode = freezed,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,agentCode: freezed == agentCode ? _self.agentCode : agentCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportAgent].
extension SupportAgentPatterns on SupportAgent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportAgent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportAgent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportAgent value)  $default,){
final _that = this;
switch (_that) {
case _SupportAgent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportAgent value)?  $default,){
final _that = this;
switch (_that) {
case _SupportAgent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String? agentCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportAgent() when $default != null:
return $default(_that.displayName,_that.agentCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String? agentCode)  $default,) {final _that = this;
switch (_that) {
case _SupportAgent():
return $default(_that.displayName,_that.agentCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String? agentCode)?  $default,) {final _that = this;
switch (_that) {
case _SupportAgent() when $default != null:
return $default(_that.displayName,_that.agentCode);case _:
  return null;

}
}

}

/// @nodoc


class _SupportAgent implements SupportAgent {
  const _SupportAgent({required this.displayName, this.agentCode});
  

@override final  String displayName;
@override final  String? agentCode;

/// Create a copy of SupportAgent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportAgentCopyWith<_SupportAgent> get copyWith => __$SupportAgentCopyWithImpl<_SupportAgent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportAgent&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.agentCode, agentCode) || other.agentCode == agentCode));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,agentCode);

@override
String toString() {
  return 'SupportAgent(displayName: $displayName, agentCode: $agentCode)';
}


}

/// @nodoc
abstract mixin class _$SupportAgentCopyWith<$Res> implements $SupportAgentCopyWith<$Res> {
  factory _$SupportAgentCopyWith(_SupportAgent value, $Res Function(_SupportAgent) _then) = __$SupportAgentCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String? agentCode
});




}
/// @nodoc
class __$SupportAgentCopyWithImpl<$Res>
    implements _$SupportAgentCopyWith<$Res> {
  __$SupportAgentCopyWithImpl(this._self, this._then);

  final _SupportAgent _self;
  final $Res Function(_SupportAgent) _then;

/// Create a copy of SupportAgent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? agentCode = freezed,}) {
  return _then(_SupportAgent(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,agentCode: freezed == agentCode ? _self.agentCode : agentCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SupportTicket {

 String get id; String get ticketNumber; String get roomId; String get topic; String? get topicName; SupportStatus get status; int? get queueAhead; SupportAgent? get agent; DateTime? get complaintReceivedAt; DateTime? get complaintDueAt; DateTime get createdAt; DateTime? get resolvedAt; DateTime? get closedAt; DateTime? get reopenUntil; int? get rating; bool get canRate; int? get etaMinutes; List<String> get quickReplies;
/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<SupportTicket> get copyWith => _$SupportTicketCopyWithImpl<SupportTicket>(this as SupportTicket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.topicName, topicName) || other.topicName == topicName)&&(identical(other.status, status) || other.status == status)&&(identical(other.queueAhead, queueAhead) || other.queueAhead == queueAhead)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.complaintReceivedAt, complaintReceivedAt) || other.complaintReceivedAt == complaintReceivedAt)&&(identical(other.complaintDueAt, complaintDueAt) || other.complaintDueAt == complaintDueAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.reopenUntil, reopenUntil) || other.reopenUntil == reopenUntil)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.canRate, canRate) || other.canRate == canRate)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&const DeepCollectionEquality().equals(other.quickReplies, quickReplies));
}


@override
int get hashCode => Object.hash(runtimeType,id,ticketNumber,roomId,topic,topicName,status,queueAhead,agent,complaintReceivedAt,complaintDueAt,createdAt,resolvedAt,closedAt,reopenUntil,rating,canRate,etaMinutes,const DeepCollectionEquality().hash(quickReplies));

@override
String toString() {
  return 'SupportTicket(id: $id, ticketNumber: $ticketNumber, roomId: $roomId, topic: $topic, topicName: $topicName, status: $status, queueAhead: $queueAhead, agent: $agent, complaintReceivedAt: $complaintReceivedAt, complaintDueAt: $complaintDueAt, createdAt: $createdAt, resolvedAt: $resolvedAt, closedAt: $closedAt, reopenUntil: $reopenUntil, rating: $rating, canRate: $canRate, etaMinutes: $etaMinutes, quickReplies: $quickReplies)';
}


}

/// @nodoc
abstract mixin class $SupportTicketCopyWith<$Res>  {
  factory $SupportTicketCopyWith(SupportTicket value, $Res Function(SupportTicket) _then) = _$SupportTicketCopyWithImpl;
@useResult
$Res call({
 String id, String ticketNumber, String roomId, String topic, String? topicName, SupportStatus status, int? queueAhead, SupportAgent? agent, DateTime? complaintReceivedAt, DateTime? complaintDueAt, DateTime createdAt, DateTime? resolvedAt, DateTime? closedAt, DateTime? reopenUntil, int? rating, bool canRate, int? etaMinutes, List<String> quickReplies
});


$SupportAgentCopyWith<$Res>? get agent;

}
/// @nodoc
class _$SupportTicketCopyWithImpl<$Res>
    implements $SupportTicketCopyWith<$Res> {
  _$SupportTicketCopyWithImpl(this._self, this._then);

  final SupportTicket _self;
  final $Res Function(SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ticketNumber = null,Object? roomId = null,Object? topic = null,Object? topicName = freezed,Object? status = null,Object? queueAhead = freezed,Object? agent = freezed,Object? complaintReceivedAt = freezed,Object? complaintDueAt = freezed,Object? createdAt = null,Object? resolvedAt = freezed,Object? closedAt = freezed,Object? reopenUntil = freezed,Object? rating = freezed,Object? canRate = null,Object? etaMinutes = freezed,Object? quickReplies = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,topicName: freezed == topicName ? _self.topicName : topicName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportStatus,queueAhead: freezed == queueAhead ? _self.queueAhead : queueAhead // ignore: cast_nullable_to_non_nullable
as int?,agent: freezed == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as SupportAgent?,complaintReceivedAt: freezed == complaintReceivedAt ? _self.complaintReceivedAt : complaintReceivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,complaintDueAt: freezed == complaintDueAt ? _self.complaintDueAt : complaintDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenUntil: freezed == reopenUntil ? _self.reopenUntil : reopenUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,canRate: null == canRate ? _self.canRate : canRate // ignore: cast_nullable_to_non_nullable
as bool,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,quickReplies: null == quickReplies ? _self.quickReplies : quickReplies // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportAgentCopyWith<$Res>? get agent {
    if (_self.agent == null) {
    return null;
  }

  return $SupportAgentCopyWith<$Res>(_self.agent!, (value) {
    return _then(_self.copyWith(agent: value));
  });
}
}


/// Adds pattern-matching-related methods to [SupportTicket].
extension SupportTicketPatterns on SupportTicket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTicket value)  $default,){
final _that = this;
switch (_that) {
case _SupportTicket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTicket value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ticketNumber,  String roomId,  String topic,  String? topicName,  SupportStatus status,  int? queueAhead,  SupportAgent? agent,  DateTime? complaintReceivedAt,  DateTime? complaintDueAt,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? closedAt,  DateTime? reopenUntil,  int? rating,  bool canRate,  int? etaMinutes,  List<String> quickReplies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.ticketNumber,_that.roomId,_that.topic,_that.topicName,_that.status,_that.queueAhead,_that.agent,_that.complaintReceivedAt,_that.complaintDueAt,_that.createdAt,_that.resolvedAt,_that.closedAt,_that.reopenUntil,_that.rating,_that.canRate,_that.etaMinutes,_that.quickReplies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ticketNumber,  String roomId,  String topic,  String? topicName,  SupportStatus status,  int? queueAhead,  SupportAgent? agent,  DateTime? complaintReceivedAt,  DateTime? complaintDueAt,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? closedAt,  DateTime? reopenUntil,  int? rating,  bool canRate,  int? etaMinutes,  List<String> quickReplies)  $default,) {final _that = this;
switch (_that) {
case _SupportTicket():
return $default(_that.id,_that.ticketNumber,_that.roomId,_that.topic,_that.topicName,_that.status,_that.queueAhead,_that.agent,_that.complaintReceivedAt,_that.complaintDueAt,_that.createdAt,_that.resolvedAt,_that.closedAt,_that.reopenUntil,_that.rating,_that.canRate,_that.etaMinutes,_that.quickReplies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ticketNumber,  String roomId,  String topic,  String? topicName,  SupportStatus status,  int? queueAhead,  SupportAgent? agent,  DateTime? complaintReceivedAt,  DateTime? complaintDueAt,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? closedAt,  DateTime? reopenUntil,  int? rating,  bool canRate,  int? etaMinutes,  List<String> quickReplies)?  $default,) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.ticketNumber,_that.roomId,_that.topic,_that.topicName,_that.status,_that.queueAhead,_that.agent,_that.complaintReceivedAt,_that.complaintDueAt,_that.createdAt,_that.resolvedAt,_that.closedAt,_that.reopenUntil,_that.rating,_that.canRate,_that.etaMinutes,_that.quickReplies);case _:
  return null;

}
}

}

/// @nodoc


class _SupportTicket extends SupportTicket {
  const _SupportTicket({required this.id, required this.ticketNumber, required this.roomId, required this.topic, this.topicName, required this.status, this.queueAhead, this.agent, this.complaintReceivedAt, this.complaintDueAt, required this.createdAt, this.resolvedAt, this.closedAt, this.reopenUntil, this.rating, this.canRate = false, this.etaMinutes, final  List<String> quickReplies = const <String>[]}): _quickReplies = quickReplies,super._();
  

@override final  String id;
@override final  String ticketNumber;
@override final  String roomId;
@override final  String topic;
@override final  String? topicName;
@override final  SupportStatus status;
@override final  int? queueAhead;
@override final  SupportAgent? agent;
@override final  DateTime? complaintReceivedAt;
@override final  DateTime? complaintDueAt;
@override final  DateTime createdAt;
@override final  DateTime? resolvedAt;
@override final  DateTime? closedAt;
@override final  DateTime? reopenUntil;
@override final  int? rating;
@override@JsonKey() final  bool canRate;
@override final  int? etaMinutes;
 final  List<String> _quickReplies;
@override@JsonKey() List<String> get quickReplies {
  if (_quickReplies is EqualUnmodifiableListView) return _quickReplies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickReplies);
}


/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTicketCopyWith<_SupportTicket> get copyWith => __$SupportTicketCopyWithImpl<_SupportTicket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.topicName, topicName) || other.topicName == topicName)&&(identical(other.status, status) || other.status == status)&&(identical(other.queueAhead, queueAhead) || other.queueAhead == queueAhead)&&(identical(other.agent, agent) || other.agent == agent)&&(identical(other.complaintReceivedAt, complaintReceivedAt) || other.complaintReceivedAt == complaintReceivedAt)&&(identical(other.complaintDueAt, complaintDueAt) || other.complaintDueAt == complaintDueAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&(identical(other.reopenUntil, reopenUntil) || other.reopenUntil == reopenUntil)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.canRate, canRate) || other.canRate == canRate)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes)&&const DeepCollectionEquality().equals(other._quickReplies, _quickReplies));
}


@override
int get hashCode => Object.hash(runtimeType,id,ticketNumber,roomId,topic,topicName,status,queueAhead,agent,complaintReceivedAt,complaintDueAt,createdAt,resolvedAt,closedAt,reopenUntil,rating,canRate,etaMinutes,const DeepCollectionEquality().hash(_quickReplies));

@override
String toString() {
  return 'SupportTicket(id: $id, ticketNumber: $ticketNumber, roomId: $roomId, topic: $topic, topicName: $topicName, status: $status, queueAhead: $queueAhead, agent: $agent, complaintReceivedAt: $complaintReceivedAt, complaintDueAt: $complaintDueAt, createdAt: $createdAt, resolvedAt: $resolvedAt, closedAt: $closedAt, reopenUntil: $reopenUntil, rating: $rating, canRate: $canRate, etaMinutes: $etaMinutes, quickReplies: $quickReplies)';
}


}

/// @nodoc
abstract mixin class _$SupportTicketCopyWith<$Res> implements $SupportTicketCopyWith<$Res> {
  factory _$SupportTicketCopyWith(_SupportTicket value, $Res Function(_SupportTicket) _then) = __$SupportTicketCopyWithImpl;
@override @useResult
$Res call({
 String id, String ticketNumber, String roomId, String topic, String? topicName, SupportStatus status, int? queueAhead, SupportAgent? agent, DateTime? complaintReceivedAt, DateTime? complaintDueAt, DateTime createdAt, DateTime? resolvedAt, DateTime? closedAt, DateTime? reopenUntil, int? rating, bool canRate, int? etaMinutes, List<String> quickReplies
});


@override $SupportAgentCopyWith<$Res>? get agent;

}
/// @nodoc
class __$SupportTicketCopyWithImpl<$Res>
    implements _$SupportTicketCopyWith<$Res> {
  __$SupportTicketCopyWithImpl(this._self, this._then);

  final _SupportTicket _self;
  final $Res Function(_SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ticketNumber = null,Object? roomId = null,Object? topic = null,Object? topicName = freezed,Object? status = null,Object? queueAhead = freezed,Object? agent = freezed,Object? complaintReceivedAt = freezed,Object? complaintDueAt = freezed,Object? createdAt = null,Object? resolvedAt = freezed,Object? closedAt = freezed,Object? reopenUntil = freezed,Object? rating = freezed,Object? canRate = null,Object? etaMinutes = freezed,Object? quickReplies = null,}) {
  return _then(_SupportTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,topicName: freezed == topicName ? _self.topicName : topicName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupportStatus,queueAhead: freezed == queueAhead ? _self.queueAhead : queueAhead // ignore: cast_nullable_to_non_nullable
as int?,agent: freezed == agent ? _self.agent : agent // ignore: cast_nullable_to_non_nullable
as SupportAgent?,complaintReceivedAt: freezed == complaintReceivedAt ? _self.complaintReceivedAt : complaintReceivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,complaintDueAt: freezed == complaintDueAt ? _self.complaintDueAt : complaintDueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reopenUntil: freezed == reopenUntil ? _self.reopenUntil : reopenUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,canRate: null == canRate ? _self.canRate : canRate // ignore: cast_nullable_to_non_nullable
as bool,etaMinutes: freezed == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int?,quickReplies: null == quickReplies ? _self._quickReplies : quickReplies // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportAgentCopyWith<$Res>? get agent {
    if (_self.agent == null) {
    return null;
  }

  return $SupportAgentCopyWith<$Res>(_self.agent!, (value) {
    return _then(_self.copyWith(agent: value));
  });
}
}

/// @nodoc
mixin _$SupportHome {

 String? get roomId; String get supportName; SupportTicket? get ticket; bool get active; int get unreadCount; bool get serviceOpen; DateTime? get nextOpenAt; SupportTopicPickerTexts get topicPicker; List<SupportIncident> get incidents; Map<String, SupportSurvey> get surveys;
/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportHomeCopyWith<SupportHome> get copyWith => _$SupportHomeCopyWithImpl<SupportHome>(this as SupportHome, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportHome&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.supportName, supportName) || other.supportName == supportName)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&(identical(other.active, active) || other.active == active)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.serviceOpen, serviceOpen) || other.serviceOpen == serviceOpen)&&(identical(other.nextOpenAt, nextOpenAt) || other.nextOpenAt == nextOpenAt)&&(identical(other.topicPicker, topicPicker) || other.topicPicker == topicPicker)&&const DeepCollectionEquality().equals(other.incidents, incidents)&&const DeepCollectionEquality().equals(other.surveys, surveys));
}


@override
int get hashCode => Object.hash(runtimeType,roomId,supportName,ticket,active,unreadCount,serviceOpen,nextOpenAt,topicPicker,const DeepCollectionEquality().hash(incidents),const DeepCollectionEquality().hash(surveys));

@override
String toString() {
  return 'SupportHome(roomId: $roomId, supportName: $supportName, ticket: $ticket, active: $active, unreadCount: $unreadCount, serviceOpen: $serviceOpen, nextOpenAt: $nextOpenAt, topicPicker: $topicPicker, incidents: $incidents, surveys: $surveys)';
}


}

/// @nodoc
abstract mixin class $SupportHomeCopyWith<$Res>  {
  factory $SupportHomeCopyWith(SupportHome value, $Res Function(SupportHome) _then) = _$SupportHomeCopyWithImpl;
@useResult
$Res call({
 String? roomId, String supportName, SupportTicket? ticket, bool active, int unreadCount, bool serviceOpen, DateTime? nextOpenAt, SupportTopicPickerTexts topicPicker, List<SupportIncident> incidents, Map<String, SupportSurvey> surveys
});


$SupportTicketCopyWith<$Res>? get ticket;$SupportTopicPickerTextsCopyWith<$Res> get topicPicker;

}
/// @nodoc
class _$SupportHomeCopyWithImpl<$Res>
    implements $SupportHomeCopyWith<$Res> {
  _$SupportHomeCopyWithImpl(this._self, this._then);

  final SupportHome _self;
  final $Res Function(SupportHome) _then;

/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomId = freezed,Object? supportName = null,Object? ticket = freezed,Object? active = null,Object? unreadCount = null,Object? serviceOpen = null,Object? nextOpenAt = freezed,Object? topicPicker = null,Object? incidents = null,Object? surveys = null,}) {
  return _then(_self.copyWith(
roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,supportName: null == supportName ? _self.supportName : supportName // ignore: cast_nullable_to_non_nullable
as String,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,serviceOpen: null == serviceOpen ? _self.serviceOpen : serviceOpen // ignore: cast_nullable_to_non_nullable
as bool,nextOpenAt: freezed == nextOpenAt ? _self.nextOpenAt : nextOpenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,topicPicker: null == topicPicker ? _self.topicPicker : topicPicker // ignore: cast_nullable_to_non_nullable
as SupportTopicPickerTexts,incidents: null == incidents ? _self.incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<SupportIncident>,surveys: null == surveys ? _self.surveys : surveys // ignore: cast_nullable_to_non_nullable
as Map<String, SupportSurvey>,
  ));
}
/// Create a copy of SupportHome
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
}/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTopicPickerTextsCopyWith<$Res> get topicPicker {
  
  return $SupportTopicPickerTextsCopyWith<$Res>(_self.topicPicker, (value) {
    return _then(_self.copyWith(topicPicker: value));
  });
}
}


/// Adds pattern-matching-related methods to [SupportHome].
extension SupportHomePatterns on SupportHome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportHome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportHome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportHome value)  $default,){
final _that = this;
switch (_that) {
case _SupportHome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportHome value)?  $default,){
final _that = this;
switch (_that) {
case _SupportHome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? roomId,  String supportName,  SupportTicket? ticket,  bool active,  int unreadCount,  bool serviceOpen,  DateTime? nextOpenAt,  SupportTopicPickerTexts topicPicker,  List<SupportIncident> incidents,  Map<String, SupportSurvey> surveys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportHome() when $default != null:
return $default(_that.roomId,_that.supportName,_that.ticket,_that.active,_that.unreadCount,_that.serviceOpen,_that.nextOpenAt,_that.topicPicker,_that.incidents,_that.surveys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? roomId,  String supportName,  SupportTicket? ticket,  bool active,  int unreadCount,  bool serviceOpen,  DateTime? nextOpenAt,  SupportTopicPickerTexts topicPicker,  List<SupportIncident> incidents,  Map<String, SupportSurvey> surveys)  $default,) {final _that = this;
switch (_that) {
case _SupportHome():
return $default(_that.roomId,_that.supportName,_that.ticket,_that.active,_that.unreadCount,_that.serviceOpen,_that.nextOpenAt,_that.topicPicker,_that.incidents,_that.surveys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? roomId,  String supportName,  SupportTicket? ticket,  bool active,  int unreadCount,  bool serviceOpen,  DateTime? nextOpenAt,  SupportTopicPickerTexts topicPicker,  List<SupportIncident> incidents,  Map<String, SupportSurvey> surveys)?  $default,) {final _that = this;
switch (_that) {
case _SupportHome() when $default != null:
return $default(_that.roomId,_that.supportName,_that.ticket,_that.active,_that.unreadCount,_that.serviceOpen,_that.nextOpenAt,_that.topicPicker,_that.incidents,_that.surveys);case _:
  return null;

}
}

}

/// @nodoc


class _SupportHome extends SupportHome {
  const _SupportHome({this.roomId, required this.supportName, this.ticket, this.active = false, this.unreadCount = 0, this.serviceOpen = true, this.nextOpenAt, this.topicPicker = const SupportTopicPickerTexts(), final  List<SupportIncident> incidents = const <SupportIncident>[], final  Map<String, SupportSurvey> surveys = const <String, SupportSurvey>{}}): _incidents = incidents,_surveys = surveys,super._();
  

@override final  String? roomId;
@override final  String supportName;
@override final  SupportTicket? ticket;
@override@JsonKey() final  bool active;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool serviceOpen;
@override final  DateTime? nextOpenAt;
@override@JsonKey() final  SupportTopicPickerTexts topicPicker;
 final  List<SupportIncident> _incidents;
@override@JsonKey() List<SupportIncident> get incidents {
  if (_incidents is EqualUnmodifiableListView) return _incidents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incidents);
}

 final  Map<String, SupportSurvey> _surveys;
@override@JsonKey() Map<String, SupportSurvey> get surveys {
  if (_surveys is EqualUnmodifiableMapView) return _surveys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_surveys);
}


/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportHomeCopyWith<_SupportHome> get copyWith => __$SupportHomeCopyWithImpl<_SupportHome>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportHome&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.supportName, supportName) || other.supportName == supportName)&&(identical(other.ticket, ticket) || other.ticket == ticket)&&(identical(other.active, active) || other.active == active)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.serviceOpen, serviceOpen) || other.serviceOpen == serviceOpen)&&(identical(other.nextOpenAt, nextOpenAt) || other.nextOpenAt == nextOpenAt)&&(identical(other.topicPicker, topicPicker) || other.topicPicker == topicPicker)&&const DeepCollectionEquality().equals(other._incidents, _incidents)&&const DeepCollectionEquality().equals(other._surveys, _surveys));
}


@override
int get hashCode => Object.hash(runtimeType,roomId,supportName,ticket,active,unreadCount,serviceOpen,nextOpenAt,topicPicker,const DeepCollectionEquality().hash(_incidents),const DeepCollectionEquality().hash(_surveys));

@override
String toString() {
  return 'SupportHome(roomId: $roomId, supportName: $supportName, ticket: $ticket, active: $active, unreadCount: $unreadCount, serviceOpen: $serviceOpen, nextOpenAt: $nextOpenAt, topicPicker: $topicPicker, incidents: $incidents, surveys: $surveys)';
}


}

/// @nodoc
abstract mixin class _$SupportHomeCopyWith<$Res> implements $SupportHomeCopyWith<$Res> {
  factory _$SupportHomeCopyWith(_SupportHome value, $Res Function(_SupportHome) _then) = __$SupportHomeCopyWithImpl;
@override @useResult
$Res call({
 String? roomId, String supportName, SupportTicket? ticket, bool active, int unreadCount, bool serviceOpen, DateTime? nextOpenAt, SupportTopicPickerTexts topicPicker, List<SupportIncident> incidents, Map<String, SupportSurvey> surveys
});


@override $SupportTicketCopyWith<$Res>? get ticket;@override $SupportTopicPickerTextsCopyWith<$Res> get topicPicker;

}
/// @nodoc
class __$SupportHomeCopyWithImpl<$Res>
    implements _$SupportHomeCopyWith<$Res> {
  __$SupportHomeCopyWithImpl(this._self, this._then);

  final _SupportHome _self;
  final $Res Function(_SupportHome) _then;

/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomId = freezed,Object? supportName = null,Object? ticket = freezed,Object? active = null,Object? unreadCount = null,Object? serviceOpen = null,Object? nextOpenAt = freezed,Object? topicPicker = null,Object? incidents = null,Object? surveys = null,}) {
  return _then(_SupportHome(
roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,supportName: null == supportName ? _self.supportName : supportName // ignore: cast_nullable_to_non_nullable
as String,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as SupportTicket?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,serviceOpen: null == serviceOpen ? _self.serviceOpen : serviceOpen // ignore: cast_nullable_to_non_nullable
as bool,nextOpenAt: freezed == nextOpenAt ? _self.nextOpenAt : nextOpenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,topicPicker: null == topicPicker ? _self.topicPicker : topicPicker // ignore: cast_nullable_to_non_nullable
as SupportTopicPickerTexts,incidents: null == incidents ? _self._incidents : incidents // ignore: cast_nullable_to_non_nullable
as List<SupportIncident>,surveys: null == surveys ? _self._surveys : surveys // ignore: cast_nullable_to_non_nullable
as Map<String, SupportSurvey>,
  ));
}

/// Create a copy of SupportHome
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
}/// Create a copy of SupportHome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SupportTopicPickerTextsCopyWith<$Res> get topicPicker {
  
  return $SupportTopicPickerTextsCopyWith<$Res>(_self.topicPicker, (value) {
    return _then(_self.copyWith(topicPicker: value));
  });
}
}

/// @nodoc
mixin _$SupportTopic {

 String get code; String get name; String? get helpUrl; bool get urgent; String? get description; String? get icon; String get style; List<SupportIntakeField> get intake;
/// Create a copy of SupportTopic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTopicCopyWith<SupportTopic> get copyWith => _$SupportTopicCopyWithImpl<SupportTopic>(this as SupportTopic, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTopic&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.helpUrl, helpUrl) || other.helpUrl == helpUrl)&&(identical(other.urgent, urgent) || other.urgent == urgent)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.style, style) || other.style == style)&&const DeepCollectionEquality().equals(other.intake, intake));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,helpUrl,urgent,description,icon,style,const DeepCollectionEquality().hash(intake));

@override
String toString() {
  return 'SupportTopic(code: $code, name: $name, helpUrl: $helpUrl, urgent: $urgent, description: $description, icon: $icon, style: $style, intake: $intake)';
}


}

/// @nodoc
abstract mixin class $SupportTopicCopyWith<$Res>  {
  factory $SupportTopicCopyWith(SupportTopic value, $Res Function(SupportTopic) _then) = _$SupportTopicCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? helpUrl, bool urgent, String? description, String? icon, String style, List<SupportIntakeField> intake
});




}
/// @nodoc
class _$SupportTopicCopyWithImpl<$Res>
    implements $SupportTopicCopyWith<$Res> {
  _$SupportTopicCopyWithImpl(this._self, this._then);

  final SupportTopic _self;
  final $Res Function(SupportTopic) _then;

/// Create a copy of SupportTopic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? helpUrl = freezed,Object? urgent = null,Object? description = freezed,Object? icon = freezed,Object? style = null,Object? intake = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,helpUrl: freezed == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as String?,urgent: null == urgent ? _self.urgent : urgent // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,intake: null == intake ? _self.intake : intake // ignore: cast_nullable_to_non_nullable
as List<SupportIntakeField>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTopic].
extension SupportTopicPatterns on SupportTopic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTopic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTopic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTopic value)  $default,){
final _that = this;
switch (_that) {
case _SupportTopic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTopic value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTopic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? helpUrl,  bool urgent,  String? description,  String? icon,  String style,  List<SupportIntakeField> intake)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTopic() when $default != null:
return $default(_that.code,_that.name,_that.helpUrl,_that.urgent,_that.description,_that.icon,_that.style,_that.intake);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? helpUrl,  bool urgent,  String? description,  String? icon,  String style,  List<SupportIntakeField> intake)  $default,) {final _that = this;
switch (_that) {
case _SupportTopic():
return $default(_that.code,_that.name,_that.helpUrl,_that.urgent,_that.description,_that.icon,_that.style,_that.intake);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? helpUrl,  bool urgent,  String? description,  String? icon,  String style,  List<SupportIntakeField> intake)?  $default,) {final _that = this;
switch (_that) {
case _SupportTopic() when $default != null:
return $default(_that.code,_that.name,_that.helpUrl,_that.urgent,_that.description,_that.icon,_that.style,_that.intake);case _:
  return null;

}
}

}

/// @nodoc


class _SupportTopic extends SupportTopic {
  const _SupportTopic({required this.code, required this.name, this.helpUrl, this.urgent = false, this.description, this.icon, this.style = 'normal', final  List<SupportIntakeField> intake = const <SupportIntakeField>[]}): _intake = intake,super._();
  

@override final  String code;
@override final  String name;
@override final  String? helpUrl;
@override@JsonKey() final  bool urgent;
@override final  String? description;
@override final  String? icon;
@override@JsonKey() final  String style;
 final  List<SupportIntakeField> _intake;
@override@JsonKey() List<SupportIntakeField> get intake {
  if (_intake is EqualUnmodifiableListView) return _intake;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_intake);
}


/// Create a copy of SupportTopic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTopicCopyWith<_SupportTopic> get copyWith => __$SupportTopicCopyWithImpl<_SupportTopic>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTopic&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.helpUrl, helpUrl) || other.helpUrl == helpUrl)&&(identical(other.urgent, urgent) || other.urgent == urgent)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.style, style) || other.style == style)&&const DeepCollectionEquality().equals(other._intake, _intake));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,helpUrl,urgent,description,icon,style,const DeepCollectionEquality().hash(_intake));

@override
String toString() {
  return 'SupportTopic(code: $code, name: $name, helpUrl: $helpUrl, urgent: $urgent, description: $description, icon: $icon, style: $style, intake: $intake)';
}


}

/// @nodoc
abstract mixin class _$SupportTopicCopyWith<$Res> implements $SupportTopicCopyWith<$Res> {
  factory _$SupportTopicCopyWith(_SupportTopic value, $Res Function(_SupportTopic) _then) = __$SupportTopicCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? helpUrl, bool urgent, String? description, String? icon, String style, List<SupportIntakeField> intake
});




}
/// @nodoc
class __$SupportTopicCopyWithImpl<$Res>
    implements _$SupportTopicCopyWith<$Res> {
  __$SupportTopicCopyWithImpl(this._self, this._then);

  final _SupportTopic _self;
  final $Res Function(_SupportTopic) _then;

/// Create a copy of SupportTopic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? helpUrl = freezed,Object? urgent = null,Object? description = freezed,Object? icon = freezed,Object? style = null,Object? intake = null,}) {
  return _then(_SupportTopic(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,helpUrl: freezed == helpUrl ? _self.helpUrl : helpUrl // ignore: cast_nullable_to_non_nullable
as String?,urgent: null == urgent ? _self.urgent : urgent // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,intake: null == intake ? _self._intake : intake // ignore: cast_nullable_to_non_nullable
as List<SupportIntakeField>,
  ));
}


}

/// @nodoc
mixin _$SupportIntakeOption {

 String get value; String get label;
/// Create a copy of SupportIntakeOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportIntakeOptionCopyWith<SupportIntakeOption> get copyWith => _$SupportIntakeOptionCopyWithImpl<SupportIntakeOption>(this as SupportIntakeOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportIntakeOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'SupportIntakeOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $SupportIntakeOptionCopyWith<$Res>  {
  factory $SupportIntakeOptionCopyWith(SupportIntakeOption value, $Res Function(SupportIntakeOption) _then) = _$SupportIntakeOptionCopyWithImpl;
@useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class _$SupportIntakeOptionCopyWithImpl<$Res>
    implements $SupportIntakeOptionCopyWith<$Res> {
  _$SupportIntakeOptionCopyWithImpl(this._self, this._then);

  final SupportIntakeOption _self;
  final $Res Function(SupportIntakeOption) _then;

/// Create a copy of SupportIntakeOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportIntakeOption].
extension SupportIntakeOptionPatterns on SupportIntakeOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportIntakeOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportIntakeOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportIntakeOption value)  $default,){
final _that = this;
switch (_that) {
case _SupportIntakeOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportIntakeOption value)?  $default,){
final _that = this;
switch (_that) {
case _SupportIntakeOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportIntakeOption() when $default != null:
return $default(_that.value,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label)  $default,) {final _that = this;
switch (_that) {
case _SupportIntakeOption():
return $default(_that.value,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _SupportIntakeOption() when $default != null:
return $default(_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _SupportIntakeOption implements SupportIntakeOption {
  const _SupportIntakeOption({required this.value, required this.label});
  

@override final  String value;
@override final  String label;

/// Create a copy of SupportIntakeOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportIntakeOptionCopyWith<_SupportIntakeOption> get copyWith => __$SupportIntakeOptionCopyWithImpl<_SupportIntakeOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportIntakeOption&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'SupportIntakeOption(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SupportIntakeOptionCopyWith<$Res> implements $SupportIntakeOptionCopyWith<$Res> {
  factory _$SupportIntakeOptionCopyWith(_SupportIntakeOption value, $Res Function(_SupportIntakeOption) _then) = __$SupportIntakeOptionCopyWithImpl;
@override @useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class __$SupportIntakeOptionCopyWithImpl<$Res>
    implements _$SupportIntakeOptionCopyWith<$Res> {
  __$SupportIntakeOptionCopyWithImpl(this._self, this._then);

  final _SupportIntakeOption _self;
  final $Res Function(_SupportIntakeOption) _then;

/// Create a copy of SupportIntakeOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,}) {
  return _then(_SupportIntakeOption(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SupportIntakeField {

 String get key; SupportIntakeType get type; String get label; bool get isRequired; List<SupportIntakeOption> get options;
/// Create a copy of SupportIntakeField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportIntakeFieldCopyWith<SupportIntakeField> get copyWith => _$SupportIntakeFieldCopyWithImpl<SupportIntakeField>(this as SupportIntakeField, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportIntakeField&&(identical(other.key, key) || other.key == key)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other.options, options));
}


@override
int get hashCode => Object.hash(runtimeType,key,type,label,isRequired,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'SupportIntakeField(key: $key, type: $type, label: $label, isRequired: $isRequired, options: $options)';
}


}

/// @nodoc
abstract mixin class $SupportIntakeFieldCopyWith<$Res>  {
  factory $SupportIntakeFieldCopyWith(SupportIntakeField value, $Res Function(SupportIntakeField) _then) = _$SupportIntakeFieldCopyWithImpl;
@useResult
$Res call({
 String key, SupportIntakeType type, String label, bool isRequired, List<SupportIntakeOption> options
});




}
/// @nodoc
class _$SupportIntakeFieldCopyWithImpl<$Res>
    implements $SupportIntakeFieldCopyWith<$Res> {
  _$SupportIntakeFieldCopyWithImpl(this._self, this._then);

  final SupportIntakeField _self;
  final $Res Function(SupportIntakeField) _then;

/// Create a copy of SupportIntakeField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? type = null,Object? label = null,Object? isRequired = null,Object? options = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SupportIntakeType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<SupportIntakeOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportIntakeField].
extension SupportIntakeFieldPatterns on SupportIntakeField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportIntakeField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportIntakeField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportIntakeField value)  $default,){
final _that = this;
switch (_that) {
case _SupportIntakeField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportIntakeField value)?  $default,){
final _that = this;
switch (_that) {
case _SupportIntakeField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  SupportIntakeType type,  String label,  bool isRequired,  List<SupportIntakeOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportIntakeField() when $default != null:
return $default(_that.key,_that.type,_that.label,_that.isRequired,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  SupportIntakeType type,  String label,  bool isRequired,  List<SupportIntakeOption> options)  $default,) {final _that = this;
switch (_that) {
case _SupportIntakeField():
return $default(_that.key,_that.type,_that.label,_that.isRequired,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  SupportIntakeType type,  String label,  bool isRequired,  List<SupportIntakeOption> options)?  $default,) {final _that = this;
switch (_that) {
case _SupportIntakeField() when $default != null:
return $default(_that.key,_that.type,_that.label,_that.isRequired,_that.options);case _:
  return null;

}
}

}

/// @nodoc


class _SupportIntakeField extends SupportIntakeField {
  const _SupportIntakeField({required this.key, required this.type, required this.label, this.isRequired = false, final  List<SupportIntakeOption> options = const <SupportIntakeOption>[]}): _options = options,super._();
  

@override final  String key;
@override final  SupportIntakeType type;
@override final  String label;
@override@JsonKey() final  bool isRequired;
 final  List<SupportIntakeOption> _options;
@override@JsonKey() List<SupportIntakeOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of SupportIntakeField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportIntakeFieldCopyWith<_SupportIntakeField> get copyWith => __$SupportIntakeFieldCopyWithImpl<_SupportIntakeField>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportIntakeField&&(identical(other.key, key) || other.key == key)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other._options, _options));
}


@override
int get hashCode => Object.hash(runtimeType,key,type,label,isRequired,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'SupportIntakeField(key: $key, type: $type, label: $label, isRequired: $isRequired, options: $options)';
}


}

/// @nodoc
abstract mixin class _$SupportIntakeFieldCopyWith<$Res> implements $SupportIntakeFieldCopyWith<$Res> {
  factory _$SupportIntakeFieldCopyWith(_SupportIntakeField value, $Res Function(_SupportIntakeField) _then) = __$SupportIntakeFieldCopyWithImpl;
@override @useResult
$Res call({
 String key, SupportIntakeType type, String label, bool isRequired, List<SupportIntakeOption> options
});




}
/// @nodoc
class __$SupportIntakeFieldCopyWithImpl<$Res>
    implements _$SupportIntakeFieldCopyWith<$Res> {
  __$SupportIntakeFieldCopyWithImpl(this._self, this._then);

  final _SupportIntakeField _self;
  final $Res Function(_SupportIntakeField) _then;

/// Create a copy of SupportIntakeField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? type = null,Object? label = null,Object? isRequired = null,Object? options = null,}) {
  return _then(_SupportIntakeField(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SupportIntakeType,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<SupportIntakeOption>,
  ));
}


}

/// @nodoc
mixin _$SupportIncident {

 String get id; String get title; String get body; SupportIncidentLevel get level; DateTime? get startsAt; DateTime? get endsAt; String? get faqArticleId;
/// Create a copy of SupportIncident
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportIncidentCopyWith<SupportIncident> get copyWith => _$SupportIncidentCopyWithImpl<SupportIncident>(this as SupportIncident, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportIncident&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.level, level) || other.level == level)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.faqArticleId, faqArticleId) || other.faqArticleId == faqArticleId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,level,startsAt,endsAt,faqArticleId);

@override
String toString() {
  return 'SupportIncident(id: $id, title: $title, body: $body, level: $level, startsAt: $startsAt, endsAt: $endsAt, faqArticleId: $faqArticleId)';
}


}

/// @nodoc
abstract mixin class $SupportIncidentCopyWith<$Res>  {
  factory $SupportIncidentCopyWith(SupportIncident value, $Res Function(SupportIncident) _then) = _$SupportIncidentCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, SupportIncidentLevel level, DateTime? startsAt, DateTime? endsAt, String? faqArticleId
});




}
/// @nodoc
class _$SupportIncidentCopyWithImpl<$Res>
    implements $SupportIncidentCopyWith<$Res> {
  _$SupportIncidentCopyWithImpl(this._self, this._then);

  final SupportIncident _self;
  final $Res Function(SupportIncident) _then;

/// Create a copy of SupportIncident
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? level = null,Object? startsAt = freezed,Object? endsAt = freezed,Object? faqArticleId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as SupportIncidentLevel,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,faqArticleId: freezed == faqArticleId ? _self.faqArticleId : faqArticleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportIncident].
extension SupportIncidentPatterns on SupportIncident {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportIncident value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportIncident() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportIncident value)  $default,){
final _that = this;
switch (_that) {
case _SupportIncident():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportIncident value)?  $default,){
final _that = this;
switch (_that) {
case _SupportIncident() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  SupportIncidentLevel level,  DateTime? startsAt,  DateTime? endsAt,  String? faqArticleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportIncident() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.level,_that.startsAt,_that.endsAt,_that.faqArticleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  SupportIncidentLevel level,  DateTime? startsAt,  DateTime? endsAt,  String? faqArticleId)  $default,) {final _that = this;
switch (_that) {
case _SupportIncident():
return $default(_that.id,_that.title,_that.body,_that.level,_that.startsAt,_that.endsAt,_that.faqArticleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  SupportIncidentLevel level,  DateTime? startsAt,  DateTime? endsAt,  String? faqArticleId)?  $default,) {final _that = this;
switch (_that) {
case _SupportIncident() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.level,_that.startsAt,_that.endsAt,_that.faqArticleId);case _:
  return null;

}
}

}

/// @nodoc


class _SupportIncident extends SupportIncident {
  const _SupportIncident({required this.id, required this.title, required this.body, this.level = SupportIncidentLevel.info, this.startsAt, this.endsAt, this.faqArticleId}): super._();
  

@override final  String id;
@override final  String title;
@override final  String body;
@override@JsonKey() final  SupportIncidentLevel level;
@override final  DateTime? startsAt;
@override final  DateTime? endsAt;
@override final  String? faqArticleId;

/// Create a copy of SupportIncident
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportIncidentCopyWith<_SupportIncident> get copyWith => __$SupportIncidentCopyWithImpl<_SupportIncident>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportIncident&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.level, level) || other.level == level)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.faqArticleId, faqArticleId) || other.faqArticleId == faqArticleId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,level,startsAt,endsAt,faqArticleId);

@override
String toString() {
  return 'SupportIncident(id: $id, title: $title, body: $body, level: $level, startsAt: $startsAt, endsAt: $endsAt, faqArticleId: $faqArticleId)';
}


}

/// @nodoc
abstract mixin class _$SupportIncidentCopyWith<$Res> implements $SupportIncidentCopyWith<$Res> {
  factory _$SupportIncidentCopyWith(_SupportIncident value, $Res Function(_SupportIncident) _then) = __$SupportIncidentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, SupportIncidentLevel level, DateTime? startsAt, DateTime? endsAt, String? faqArticleId
});




}
/// @nodoc
class __$SupportIncidentCopyWithImpl<$Res>
    implements _$SupportIncidentCopyWith<$Res> {
  __$SupportIncidentCopyWithImpl(this._self, this._then);

  final _SupportIncident _self;
  final $Res Function(_SupportIncident) _then;

/// Create a copy of SupportIncident
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? level = null,Object? startsAt = freezed,Object? endsAt = freezed,Object? faqArticleId = freezed,}) {
  return _then(_SupportIncident(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as SupportIncidentLevel,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,faqArticleId: freezed == faqArticleId ? _self.faqArticleId : faqArticleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SupportSurveyReason {

 String get code; String get label;
/// Create a copy of SupportSurveyReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportSurveyReasonCopyWith<SupportSurveyReason> get copyWith => _$SupportSurveyReasonCopyWithImpl<SupportSurveyReason>(this as SupportSurveyReason, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportSurveyReason&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'SupportSurveyReason(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class $SupportSurveyReasonCopyWith<$Res>  {
  factory $SupportSurveyReasonCopyWith(SupportSurveyReason value, $Res Function(SupportSurveyReason) _then) = _$SupportSurveyReasonCopyWithImpl;
@useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class _$SupportSurveyReasonCopyWithImpl<$Res>
    implements $SupportSurveyReasonCopyWith<$Res> {
  _$SupportSurveyReasonCopyWithImpl(this._self, this._then);

  final SupportSurveyReason _self;
  final $Res Function(SupportSurveyReason) _then;

/// Create a copy of SupportSurveyReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? label = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportSurveyReason].
extension SupportSurveyReasonPatterns on SupportSurveyReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportSurveyReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportSurveyReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportSurveyReason value)  $default,){
final _that = this;
switch (_that) {
case _SupportSurveyReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportSurveyReason value)?  $default,){
final _that = this;
switch (_that) {
case _SupportSurveyReason() when $default != null:
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
case _SupportSurveyReason() when $default != null:
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
case _SupportSurveyReason():
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
case _SupportSurveyReason() when $default != null:
return $default(_that.code,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _SupportSurveyReason implements SupportSurveyReason {
  const _SupportSurveyReason({required this.code, required this.label});
  

@override final  String code;
@override final  String label;

/// Create a copy of SupportSurveyReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportSurveyReasonCopyWith<_SupportSurveyReason> get copyWith => __$SupportSurveyReasonCopyWithImpl<_SupportSurveyReason>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportSurveyReason&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'SupportSurveyReason(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class _$SupportSurveyReasonCopyWith<$Res> implements $SupportSurveyReasonCopyWith<$Res> {
  factory _$SupportSurveyReasonCopyWith(_SupportSurveyReason value, $Res Function(_SupportSurveyReason) _then) = __$SupportSurveyReasonCopyWithImpl;
@override @useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class __$SupportSurveyReasonCopyWithImpl<$Res>
    implements _$SupportSurveyReasonCopyWith<$Res> {
  __$SupportSurveyReasonCopyWithImpl(this._self, this._then);

  final _SupportSurveyReason _self;
  final $Res Function(_SupportSurveyReason) _then;

/// Create a copy of SupportSurveyReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? label = null,}) {
  return _then(_SupportSurveyReason(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SupportSurvey {

 String get question; int get scale; int get lowMax; List<SupportSurveyReason> get reasons;
/// Create a copy of SupportSurvey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportSurveyCopyWith<SupportSurvey> get copyWith => _$SupportSurveyCopyWithImpl<SupportSurvey>(this as SupportSurvey, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportSurvey&&(identical(other.question, question) || other.question == question)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.lowMax, lowMax) || other.lowMax == lowMax)&&const DeepCollectionEquality().equals(other.reasons, reasons));
}


@override
int get hashCode => Object.hash(runtimeType,question,scale,lowMax,const DeepCollectionEquality().hash(reasons));

@override
String toString() {
  return 'SupportSurvey(question: $question, scale: $scale, lowMax: $lowMax, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class $SupportSurveyCopyWith<$Res>  {
  factory $SupportSurveyCopyWith(SupportSurvey value, $Res Function(SupportSurvey) _then) = _$SupportSurveyCopyWithImpl;
@useResult
$Res call({
 String question, int scale, int lowMax, List<SupportSurveyReason> reasons
});




}
/// @nodoc
class _$SupportSurveyCopyWithImpl<$Res>
    implements $SupportSurveyCopyWith<$Res> {
  _$SupportSurveyCopyWithImpl(this._self, this._then);

  final SupportSurvey _self;
  final $Res Function(SupportSurvey) _then;

/// Create a copy of SupportSurvey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? question = null,Object? scale = null,Object? lowMax = null,Object? reasons = null,}) {
  return _then(_self.copyWith(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as int,lowMax: null == lowMax ? _self.lowMax : lowMax // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<SupportSurveyReason>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportSurvey].
extension SupportSurveyPatterns on SupportSurvey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportSurvey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportSurvey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportSurvey value)  $default,){
final _that = this;
switch (_that) {
case _SupportSurvey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportSurvey value)?  $default,){
final _that = this;
switch (_that) {
case _SupportSurvey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String question,  int scale,  int lowMax,  List<SupportSurveyReason> reasons)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportSurvey() when $default != null:
return $default(_that.question,_that.scale,_that.lowMax,_that.reasons);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String question,  int scale,  int lowMax,  List<SupportSurveyReason> reasons)  $default,) {final _that = this;
switch (_that) {
case _SupportSurvey():
return $default(_that.question,_that.scale,_that.lowMax,_that.reasons);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String question,  int scale,  int lowMax,  List<SupportSurveyReason> reasons)?  $default,) {final _that = this;
switch (_that) {
case _SupportSurvey() when $default != null:
return $default(_that.question,_that.scale,_that.lowMax,_that.reasons);case _:
  return null;

}
}

}

/// @nodoc


class _SupportSurvey extends SupportSurvey {
  const _SupportSurvey({required this.question, this.scale = 5, this.lowMax = 2, final  List<SupportSurveyReason> reasons = const <SupportSurveyReason>[]}): _reasons = reasons,super._();
  

@override final  String question;
@override@JsonKey() final  int scale;
@override@JsonKey() final  int lowMax;
 final  List<SupportSurveyReason> _reasons;
@override@JsonKey() List<SupportSurveyReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}


/// Create a copy of SupportSurvey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportSurveyCopyWith<_SupportSurvey> get copyWith => __$SupportSurveyCopyWithImpl<_SupportSurvey>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportSurvey&&(identical(other.question, question) || other.question == question)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.lowMax, lowMax) || other.lowMax == lowMax)&&const DeepCollectionEquality().equals(other._reasons, _reasons));
}


@override
int get hashCode => Object.hash(runtimeType,question,scale,lowMax,const DeepCollectionEquality().hash(_reasons));

@override
String toString() {
  return 'SupportSurvey(question: $question, scale: $scale, lowMax: $lowMax, reasons: $reasons)';
}


}

/// @nodoc
abstract mixin class _$SupportSurveyCopyWith<$Res> implements $SupportSurveyCopyWith<$Res> {
  factory _$SupportSurveyCopyWith(_SupportSurvey value, $Res Function(_SupportSurvey) _then) = __$SupportSurveyCopyWithImpl;
@override @useResult
$Res call({
 String question, int scale, int lowMax, List<SupportSurveyReason> reasons
});




}
/// @nodoc
class __$SupportSurveyCopyWithImpl<$Res>
    implements _$SupportSurveyCopyWith<$Res> {
  __$SupportSurveyCopyWithImpl(this._self, this._then);

  final _SupportSurvey _self;
  final $Res Function(_SupportSurvey) _then;

/// Create a copy of SupportSurvey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? question = null,Object? scale = null,Object? lowMax = null,Object? reasons = null,}) {
  return _then(_SupportSurvey(
question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as int,lowMax: null == lowMax ? _self.lowMax : lowMax // ignore: cast_nullable_to_non_nullable
as int,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<SupportSurveyReason>,
  ));
}


}

/// @nodoc
mixin _$SupportTopicPickerTexts {

 Map<String, String> get title; Map<String, String> get hint;
/// Create a copy of SupportTopicPickerTexts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTopicPickerTextsCopyWith<SupportTopicPickerTexts> get copyWith => _$SupportTopicPickerTextsCopyWithImpl<SupportTopicPickerTexts>(this as SupportTopicPickerTexts, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTopicPickerTexts&&const DeepCollectionEquality().equals(other.title, title)&&const DeepCollectionEquality().equals(other.hint, hint));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(title),const DeepCollectionEquality().hash(hint));

@override
String toString() {
  return 'SupportTopicPickerTexts(title: $title, hint: $hint)';
}


}

/// @nodoc
abstract mixin class $SupportTopicPickerTextsCopyWith<$Res>  {
  factory $SupportTopicPickerTextsCopyWith(SupportTopicPickerTexts value, $Res Function(SupportTopicPickerTexts) _then) = _$SupportTopicPickerTextsCopyWithImpl;
@useResult
$Res call({
 Map<String, String> title, Map<String, String> hint
});




}
/// @nodoc
class _$SupportTopicPickerTextsCopyWithImpl<$Res>
    implements $SupportTopicPickerTextsCopyWith<$Res> {
  _$SupportTopicPickerTextsCopyWithImpl(this._self, this._then);

  final SupportTopicPickerTexts _self;
  final $Res Function(SupportTopicPickerTexts) _then;

/// Create a copy of SupportTopicPickerTexts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? hint = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hint: null == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTopicPickerTexts].
extension SupportTopicPickerTextsPatterns on SupportTopicPickerTexts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTopicPickerTexts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTopicPickerTexts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTopicPickerTexts value)  $default,){
final _that = this;
switch (_that) {
case _SupportTopicPickerTexts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTopicPickerTexts value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTopicPickerTexts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, String> title,  Map<String, String> hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTopicPickerTexts() when $default != null:
return $default(_that.title,_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, String> title,  Map<String, String> hint)  $default,) {final _that = this;
switch (_that) {
case _SupportTopicPickerTexts():
return $default(_that.title,_that.hint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, String> title,  Map<String, String> hint)?  $default,) {final _that = this;
switch (_that) {
case _SupportTopicPickerTexts() when $default != null:
return $default(_that.title,_that.hint);case _:
  return null;

}
}

}

/// @nodoc


class _SupportTopicPickerTexts implements SupportTopicPickerTexts {
  const _SupportTopicPickerTexts({final  Map<String, String> title = const <String, String>{}, final  Map<String, String> hint = const <String, String>{}}): _title = title,_hint = hint;
  

 final  Map<String, String> _title;
@override@JsonKey() Map<String, String> get title {
  if (_title is EqualUnmodifiableMapView) return _title;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_title);
}

 final  Map<String, String> _hint;
@override@JsonKey() Map<String, String> get hint {
  if (_hint is EqualUnmodifiableMapView) return _hint;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hint);
}


/// Create a copy of SupportTopicPickerTexts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTopicPickerTextsCopyWith<_SupportTopicPickerTexts> get copyWith => __$SupportTopicPickerTextsCopyWithImpl<_SupportTopicPickerTexts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTopicPickerTexts&&const DeepCollectionEquality().equals(other._title, _title)&&const DeepCollectionEquality().equals(other._hint, _hint));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_title),const DeepCollectionEquality().hash(_hint));

@override
String toString() {
  return 'SupportTopicPickerTexts(title: $title, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$SupportTopicPickerTextsCopyWith<$Res> implements $SupportTopicPickerTextsCopyWith<$Res> {
  factory _$SupportTopicPickerTextsCopyWith(_SupportTopicPickerTexts value, $Res Function(_SupportTopicPickerTexts) _then) = __$SupportTopicPickerTextsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, String> title, Map<String, String> hint
});




}
/// @nodoc
class __$SupportTopicPickerTextsCopyWithImpl<$Res>
    implements _$SupportTopicPickerTextsCopyWith<$Res> {
  __$SupportTopicPickerTextsCopyWithImpl(this._self, this._then);

  final _SupportTopicPickerTexts _self;
  final $Res Function(_SupportTopicPickerTexts) _then;

/// Create a copy of SupportTopicPickerTexts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? hint = null,}) {
  return _then(_SupportTopicPickerTexts(
title: null == title ? _self._title : title // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hint: null == hint ? _self._hint : hint // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$SensitiveCheck {

 bool get masked; List<String> get kinds;
/// Create a copy of SensitiveCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensitiveCheckCopyWith<SensitiveCheck> get copyWith => _$SensitiveCheckCopyWithImpl<SensitiveCheck>(this as SensitiveCheck, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensitiveCheck&&(identical(other.masked, masked) || other.masked == masked)&&const DeepCollectionEquality().equals(other.kinds, kinds));
}


@override
int get hashCode => Object.hash(runtimeType,masked,const DeepCollectionEquality().hash(kinds));

@override
String toString() {
  return 'SensitiveCheck(masked: $masked, kinds: $kinds)';
}


}

/// @nodoc
abstract mixin class $SensitiveCheckCopyWith<$Res>  {
  factory $SensitiveCheckCopyWith(SensitiveCheck value, $Res Function(SensitiveCheck) _then) = _$SensitiveCheckCopyWithImpl;
@useResult
$Res call({
 bool masked, List<String> kinds
});




}
/// @nodoc
class _$SensitiveCheckCopyWithImpl<$Res>
    implements $SensitiveCheckCopyWith<$Res> {
  _$SensitiveCheckCopyWithImpl(this._self, this._then);

  final SensitiveCheck _self;
  final $Res Function(SensitiveCheck) _then;

/// Create a copy of SensitiveCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? masked = null,Object? kinds = null,}) {
  return _then(_self.copyWith(
masked: null == masked ? _self.masked : masked // ignore: cast_nullable_to_non_nullable
as bool,kinds: null == kinds ? _self.kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SensitiveCheck].
extension SensitiveCheckPatterns on SensitiveCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensitiveCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensitiveCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensitiveCheck value)  $default,){
final _that = this;
switch (_that) {
case _SensitiveCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensitiveCheck value)?  $default,){
final _that = this;
switch (_that) {
case _SensitiveCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool masked,  List<String> kinds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensitiveCheck() when $default != null:
return $default(_that.masked,_that.kinds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool masked,  List<String> kinds)  $default,) {final _that = this;
switch (_that) {
case _SensitiveCheck():
return $default(_that.masked,_that.kinds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool masked,  List<String> kinds)?  $default,) {final _that = this;
switch (_that) {
case _SensitiveCheck() when $default != null:
return $default(_that.masked,_that.kinds);case _:
  return null;

}
}

}

/// @nodoc


class _SensitiveCheck implements SensitiveCheck {
  const _SensitiveCheck({this.masked = false, final  List<String> kinds = const <String>[]}): _kinds = kinds;
  

@override@JsonKey() final  bool masked;
 final  List<String> _kinds;
@override@JsonKey() List<String> get kinds {
  if (_kinds is EqualUnmodifiableListView) return _kinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_kinds);
}


/// Create a copy of SensitiveCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensitiveCheckCopyWith<_SensitiveCheck> get copyWith => __$SensitiveCheckCopyWithImpl<_SensitiveCheck>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensitiveCheck&&(identical(other.masked, masked) || other.masked == masked)&&const DeepCollectionEquality().equals(other._kinds, _kinds));
}


@override
int get hashCode => Object.hash(runtimeType,masked,const DeepCollectionEquality().hash(_kinds));

@override
String toString() {
  return 'SensitiveCheck(masked: $masked, kinds: $kinds)';
}


}

/// @nodoc
abstract mixin class _$SensitiveCheckCopyWith<$Res> implements $SensitiveCheckCopyWith<$Res> {
  factory _$SensitiveCheckCopyWith(_SensitiveCheck value, $Res Function(_SensitiveCheck) _then) = __$SensitiveCheckCopyWithImpl;
@override @useResult
$Res call({
 bool masked, List<String> kinds
});




}
/// @nodoc
class __$SensitiveCheckCopyWithImpl<$Res>
    implements _$SensitiveCheckCopyWith<$Res> {
  __$SensitiveCheckCopyWithImpl(this._self, this._then);

  final _SensitiveCheck _self;
  final $Res Function(_SensitiveCheck) _then;

/// Create a copy of SensitiveCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? masked = null,Object? kinds = null,}) {
  return _then(_SensitiveCheck(
masked: null == masked ? _self.masked : masked // ignore: cast_nullable_to_non_nullable
as bool,kinds: null == kinds ? _self._kinds : kinds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$SupportNotice {

 String get id; String get title; String get body; String? get ticketId; String? get roomId;
/// Create a copy of SupportNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportNoticeCopyWith<SupportNotice> get copyWith => _$SupportNoticeCopyWithImpl<SupportNotice>(this as SupportNotice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,ticketId,roomId);

@override
String toString() {
  return 'SupportNotice(id: $id, title: $title, body: $body, ticketId: $ticketId, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class $SupportNoticeCopyWith<$Res>  {
  factory $SupportNoticeCopyWith(SupportNotice value, $Res Function(SupportNotice) _then) = _$SupportNoticeCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, String? ticketId, String? roomId
});




}
/// @nodoc
class _$SupportNoticeCopyWithImpl<$Res>
    implements $SupportNoticeCopyWith<$Res> {
  _$SupportNoticeCopyWithImpl(this._self, this._then);

  final SupportNotice _self;
  final $Res Function(SupportNotice) _then;

/// Create a copy of SupportNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? ticketId = freezed,Object? roomId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportNotice].
extension SupportNoticePatterns on SupportNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportNotice value)  $default,){
final _that = this;
switch (_that) {
case _SupportNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportNotice value)?  $default,){
final _that = this;
switch (_that) {
case _SupportNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String? ticketId,  String? roomId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportNotice() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.ticketId,_that.roomId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  String? ticketId,  String? roomId)  $default,) {final _that = this;
switch (_that) {
case _SupportNotice():
return $default(_that.id,_that.title,_that.body,_that.ticketId,_that.roomId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  String? ticketId,  String? roomId)?  $default,) {final _that = this;
switch (_that) {
case _SupportNotice() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.ticketId,_that.roomId);case _:
  return null;

}
}

}

/// @nodoc


class _SupportNotice implements SupportNotice {
  const _SupportNotice({required this.id, required this.title, required this.body, this.ticketId, this.roomId});
  

@override final  String id;
@override final  String title;
@override final  String body;
@override final  String? ticketId;
@override final  String? roomId;

/// Create a copy of SupportNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportNoticeCopyWith<_SupportNotice> get copyWith => __$SupportNoticeCopyWithImpl<_SupportNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,body,ticketId,roomId);

@override
String toString() {
  return 'SupportNotice(id: $id, title: $title, body: $body, ticketId: $ticketId, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class _$SupportNoticeCopyWith<$Res> implements $SupportNoticeCopyWith<$Res> {
  factory _$SupportNoticeCopyWith(_SupportNotice value, $Res Function(_SupportNotice) _then) = __$SupportNoticeCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, String? ticketId, String? roomId
});




}
/// @nodoc
class __$SupportNoticeCopyWithImpl<$Res>
    implements _$SupportNoticeCopyWith<$Res> {
  __$SupportNoticeCopyWithImpl(this._self, this._then);

  final _SupportNotice _self;
  final $Res Function(_SupportNotice) _then;

/// Create a copy of SupportNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? ticketId = freezed,Object? roomId = freezed,}) {
  return _then(_SupportNotice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
