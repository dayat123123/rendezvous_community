// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatRoom {

 String get id; RoomType get type; String? get name; String? get stockCode; DateTime? get lastMessageAt; String? get lastMessagePreview; String? get lastMessageSenderId; ReceiptStatus? get lastMessageStatus; DateTime get createdAt; MemberRole get myRole; bool get muted; DateTime get lastReadAt; int get unreadCount; int get memberCount; UserSummary? get otherUser; String? get description; String? get avatarUrl; bool get onlyAdminsSend; bool get onlyAdminsEdit; DateTime? get pinnedAt;
/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<ChatRoom> get copyWith => _$ChatRoomCopyWithImpl<ChatRoom>(this as ChatRoom, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatRoom;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoom&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.stockCode, _this.stockCode) || other.stockCode == _this.stockCode)&&(identical(other.lastMessageAt, _this.lastMessageAt) || other.lastMessageAt == _this.lastMessageAt)&&(identical(other.lastMessagePreview, _this.lastMessagePreview) || other.lastMessagePreview == _this.lastMessagePreview)&&(identical(other.lastMessageSenderId, _this.lastMessageSenderId) || other.lastMessageSenderId == _this.lastMessageSenderId)&&(identical(other.lastMessageStatus, _this.lastMessageStatus) || other.lastMessageStatus == _this.lastMessageStatus)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.myRole, _this.myRole) || other.myRole == _this.myRole)&&(identical(other.muted, _this.muted) || other.muted == _this.muted)&&(identical(other.lastReadAt, _this.lastReadAt) || other.lastReadAt == _this.lastReadAt)&&(identical(other.unreadCount, _this.unreadCount) || other.unreadCount == _this.unreadCount)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount)&&(identical(other.otherUser, _this.otherUser) || other.otherUser == _this.otherUser)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.onlyAdminsSend, _this.onlyAdminsSend) || other.onlyAdminsSend == _this.onlyAdminsSend)&&(identical(other.onlyAdminsEdit, _this.onlyAdminsEdit) || other.onlyAdminsEdit == _this.onlyAdminsEdit)&&(identical(other.pinnedAt, _this.pinnedAt) || other.pinnedAt == _this.pinnedAt));
}


@override
int get hashCode {
  final _this = this as ChatRoom;
  return Object.hashAll([runtimeType,_this.id,_this.type,_this.name,_this.stockCode,_this.lastMessageAt,_this.lastMessagePreview,_this.lastMessageSenderId,_this.lastMessageStatus,_this.createdAt,_this.myRole,_this.muted,_this.lastReadAt,_this.unreadCount,_this.memberCount,_this.otherUser,_this.description,_this.avatarUrl,_this.onlyAdminsSend,_this.onlyAdminsEdit,_this.pinnedAt]);
}

@override
String toString() {
  final _this = this as ChatRoom;
  return 'ChatRoom(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, stockCode: ${_this.stockCode}, lastMessageAt: ${_this.lastMessageAt}, lastMessagePreview: ${_this.lastMessagePreview}, lastMessageSenderId: ${_this.lastMessageSenderId}, lastMessageStatus: ${_this.lastMessageStatus}, createdAt: ${_this.createdAt}, myRole: ${_this.myRole}, muted: ${_this.muted}, lastReadAt: ${_this.lastReadAt}, unreadCount: ${_this.unreadCount}, memberCount: ${_this.memberCount}, otherUser: ${_this.otherUser}, description: ${_this.description}, avatarUrl: ${_this.avatarUrl}, onlyAdminsSend: ${_this.onlyAdminsSend}, onlyAdminsEdit: ${_this.onlyAdminsEdit}, pinnedAt: ${_this.pinnedAt})';
}


}

/// @nodoc
abstract mixin class $ChatRoomCopyWith<$Res>  {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) _then) = _$ChatRoomCopyWithImpl;
@useResult
$Res call({
 String id, RoomType type, String? name, String? stockCode, DateTime? lastMessageAt, String? lastMessagePreview, String? lastMessageSenderId, ReceiptStatus? lastMessageStatus, DateTime createdAt, MemberRole myRole, bool muted, DateTime lastReadAt, int unreadCount, int memberCount, UserSummary? otherUser, String? description, String? avatarUrl, bool onlyAdminsSend, bool onlyAdminsEdit, DateTime? pinnedAt
});


$UserSummaryCopyWith<$Res>? get otherUser;

}
/// @nodoc
class _$ChatRoomCopyWithImpl<$Res>
    implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._self, this._then);

  final ChatRoom _self;
  final $Res Function(ChatRoom) _then;

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = freezed,Object? stockCode = freezed,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageStatus = freezed,Object? createdAt = null,Object? myRole = null,Object? muted = null,Object? lastReadAt = null,Object? unreadCount = null,Object? memberCount = null,Object? otherUser = freezed,Object? description = freezed,Object? avatarUrl = freezed,Object? onlyAdminsSend = null,Object? onlyAdminsEdit = null,Object? pinnedAt = freezed,}) {
  return _then(ChatRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RoomType,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,stockCode: freezed == stockCode ? _self.stockCode : stockCode // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageStatus: freezed == lastMessageStatus ? _self.lastMessageStatus : lastMessageStatus // ignore: cast_nullable_to_non_nullable
as ReceiptStatus?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as UserSummary?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,onlyAdminsSend: null == onlyAdminsSend ? _self.onlyAdminsSend : onlyAdminsSend // ignore: cast_nullable_to_non_nullable
as bool,onlyAdminsEdit: null == onlyAdminsEdit ? _self.onlyAdminsEdit : onlyAdminsEdit // ignore: cast_nullable_to_non_nullable
as bool,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatRoom].
extension ChatRoomPatterns on ChatRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatRoom value)  $default,){
final _that = this;
switch (_that) {
case _ChatRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatRoom value)?  $default,){
final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  RoomType type,  String? name,  String? stockCode,  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  ReceiptStatus? lastMessageStatus,  DateTime createdAt,  MemberRole myRole,  bool muted,  DateTime lastReadAt,  int unreadCount,  int memberCount,  UserSummary? otherUser,  String? description,  String? avatarUrl,  bool onlyAdminsSend,  bool onlyAdminsEdit,  DateTime? pinnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.stockCode,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.lastMessageStatus,_that.createdAt,_that.myRole,_that.muted,_that.lastReadAt,_that.unreadCount,_that.memberCount,_that.otherUser,_that.description,_that.avatarUrl,_that.onlyAdminsSend,_that.onlyAdminsEdit,_that.pinnedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  RoomType type,  String? name,  String? stockCode,  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  ReceiptStatus? lastMessageStatus,  DateTime createdAt,  MemberRole myRole,  bool muted,  DateTime lastReadAt,  int unreadCount,  int memberCount,  UserSummary? otherUser,  String? description,  String? avatarUrl,  bool onlyAdminsSend,  bool onlyAdminsEdit,  DateTime? pinnedAt)  $default,) {final _that = this;
switch (_that) {
case _ChatRoom():
return $default(_that.id,_that.type,_that.name,_that.stockCode,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.lastMessageStatus,_that.createdAt,_that.myRole,_that.muted,_that.lastReadAt,_that.unreadCount,_that.memberCount,_that.otherUser,_that.description,_that.avatarUrl,_that.onlyAdminsSend,_that.onlyAdminsEdit,_that.pinnedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  RoomType type,  String? name,  String? stockCode,  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  ReceiptStatus? lastMessageStatus,  DateTime createdAt,  MemberRole myRole,  bool muted,  DateTime lastReadAt,  int unreadCount,  int memberCount,  UserSummary? otherUser,  String? description,  String? avatarUrl,  bool onlyAdminsSend,  bool onlyAdminsEdit,  DateTime? pinnedAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatRoom() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.stockCode,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.lastMessageStatus,_that.createdAt,_that.myRole,_that.muted,_that.lastReadAt,_that.unreadCount,_that.memberCount,_that.otherUser,_that.description,_that.avatarUrl,_that.onlyAdminsSend,_that.onlyAdminsEdit,_that.pinnedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ChatRoom extends ChatRoom {
  const _ChatRoom({required this.id, required this.type, this.name, this.stockCode, this.lastMessageAt, this.lastMessagePreview, this.lastMessageSenderId, this.lastMessageStatus, required this.createdAt, this.myRole = MemberRole.member, this.muted = false, required this.lastReadAt, this.unreadCount = 0, this.memberCount = 0, this.otherUser, this.description, this.avatarUrl, this.onlyAdminsSend = false, this.onlyAdminsEdit = true, this.pinnedAt}): super._();
  

@override final  String id;
@override final  RoomType type;
@override final  String? name;
@override final  String? stockCode;
@override final  DateTime? lastMessageAt;
@override final  String? lastMessagePreview;
@override final  String? lastMessageSenderId;
@override final  ReceiptStatus? lastMessageStatus;
@override final  DateTime createdAt;
@override@JsonKey() final  MemberRole myRole;
@override@JsonKey() final  bool muted;
@override final  DateTime lastReadAt;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  int memberCount;
@override final  UserSummary? otherUser;
@override final  String? description;
@override final  String? avatarUrl;
@override@JsonKey() final  bool onlyAdminsSend;
@override@JsonKey() final  bool onlyAdminsEdit;
@override final  DateTime? pinnedAt;

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRoomCopyWith<_ChatRoom> get copyWith => __$ChatRoomCopyWithImpl<_ChatRoom>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.stockCode, stockCode) || other.stockCode == stockCode)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageStatus, lastMessageStatus) || other.lastMessageStatus == lastMessageStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.description, description) || other.description == description)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.onlyAdminsSend, onlyAdminsSend) || other.onlyAdminsSend == onlyAdminsSend)&&(identical(other.onlyAdminsEdit, onlyAdminsEdit) || other.onlyAdminsEdit == onlyAdminsEdit)&&(identical(other.pinnedAt, pinnedAt) || other.pinnedAt == pinnedAt));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,type,name,stockCode,lastMessageAt,lastMessagePreview,lastMessageSenderId,lastMessageStatus,createdAt,myRole,muted,lastReadAt,unreadCount,memberCount,otherUser,description,avatarUrl,onlyAdminsSend,onlyAdminsEdit,pinnedAt]);
}

@override
String toString() {
    return 'ChatRoom(id: $id, type: $type, name: $name, stockCode: $stockCode, lastMessageAt: $lastMessageAt, lastMessagePreview: $lastMessagePreview, lastMessageSenderId: $lastMessageSenderId, lastMessageStatus: $lastMessageStatus, createdAt: $createdAt, myRole: $myRole, muted: $muted, lastReadAt: $lastReadAt, unreadCount: $unreadCount, memberCount: $memberCount, otherUser: $otherUser, description: $description, avatarUrl: $avatarUrl, onlyAdminsSend: $onlyAdminsSend, onlyAdminsEdit: $onlyAdminsEdit, pinnedAt: $pinnedAt)';
}


}

/// @nodoc
abstract mixin class _$ChatRoomCopyWith<$Res> implements $ChatRoomCopyWith<$Res> {
  factory _$ChatRoomCopyWith(_ChatRoom value, $Res Function(_ChatRoom) _then) = __$ChatRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, RoomType type, String? name, String? stockCode, DateTime? lastMessageAt, String? lastMessagePreview, String? lastMessageSenderId, ReceiptStatus? lastMessageStatus, DateTime createdAt, MemberRole myRole, bool muted, DateTime lastReadAt, int unreadCount, int memberCount, UserSummary? otherUser, String? description, String? avatarUrl, bool onlyAdminsSend, bool onlyAdminsEdit, DateTime? pinnedAt
});


@override $UserSummaryCopyWith<$Res>? get otherUser;

}
/// @nodoc
class __$ChatRoomCopyWithImpl<$Res>
    implements _$ChatRoomCopyWith<$Res> {
  __$ChatRoomCopyWithImpl(this._self, this._then);

  final _ChatRoom _self;
  final $Res Function(_ChatRoom) _then;

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = freezed,Object? stockCode = freezed,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? lastMessageSenderId = freezed,Object? lastMessageStatus = freezed,Object? createdAt = null,Object? myRole = null,Object? muted = null,Object? lastReadAt = null,Object? unreadCount = null,Object? memberCount = null,Object? otherUser = freezed,Object? description = freezed,Object? avatarUrl = freezed,Object? onlyAdminsSend = null,Object? onlyAdminsEdit = null,Object? pinnedAt = freezed,}) {
  return _then(_ChatRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RoomType,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,stockCode: freezed == stockCode ? _self.stockCode : stockCode // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageStatus: freezed == lastMessageStatus ? _self.lastMessageStatus : lastMessageStatus // ignore: cast_nullable_to_non_nullable
as ReceiptStatus?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as UserSummary?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,onlyAdminsSend: null == onlyAdminsSend ? _self.onlyAdminsSend : onlyAdminsSend // ignore: cast_nullable_to_non_nullable
as bool,onlyAdminsEdit: null == onlyAdminsEdit ? _self.onlyAdminsEdit : onlyAdminsEdit // ignore: cast_nullable_to_non_nullable
as bool,pinnedAt: freezed == pinnedAt ? _self.pinnedAt : pinnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}

/// @nodoc
mixin _$RoomMember {

 UserSummary get user; MemberRole get role; DateTime get lastReadAt; DateTime get lastDeliveredAt; DateTime get joinedAt;
/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomMemberCopyWith<RoomMember> get copyWith => _$RoomMemberCopyWithImpl<RoomMember>(this as RoomMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoomMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomMember&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.lastReadAt, _this.lastReadAt) || other.lastReadAt == _this.lastReadAt)&&(identical(other.lastDeliveredAt, _this.lastDeliveredAt) || other.lastDeliveredAt == _this.lastDeliveredAt)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt));
}


@override
int get hashCode {
  final _this = this as RoomMember;
  return Object.hash(runtimeType,_this.user,_this.role,_this.lastReadAt,_this.lastDeliveredAt,_this.joinedAt);
}

@override
String toString() {
  final _this = this as RoomMember;
  return 'RoomMember(user: ${_this.user}, role: ${_this.role}, lastReadAt: ${_this.lastReadAt}, lastDeliveredAt: ${_this.lastDeliveredAt}, joinedAt: ${_this.joinedAt})';
}


}

/// @nodoc
abstract mixin class $RoomMemberCopyWith<$Res>  {
  factory $RoomMemberCopyWith(RoomMember value, $Res Function(RoomMember) _then) = _$RoomMemberCopyWithImpl;
@useResult
$Res call({
 UserSummary user, MemberRole role, DateTime lastReadAt, DateTime lastDeliveredAt, DateTime joinedAt
});


$UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$RoomMemberCopyWithImpl<$Res>
    implements $RoomMemberCopyWith<$Res> {
  _$RoomMemberCopyWithImpl(this._self, this._then);

  final RoomMember _self;
  final $Res Function(RoomMember) _then;

/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? role = null,Object? lastReadAt = null,Object? lastDeliveredAt = null,Object? joinedAt = null,}) {
  return _then(RoomMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastDeliveredAt: null == lastDeliveredAt ? _self.lastDeliveredAt : lastDeliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoomMember].
extension RoomMemberPatterns on RoomMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoomMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoomMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoomMember value)  $default,){
final _that = this;
switch (_that) {
case _RoomMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoomMember value)?  $default,){
final _that = this;
switch (_that) {
case _RoomMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSummary user,  MemberRole role,  DateTime lastReadAt,  DateTime lastDeliveredAt,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoomMember() when $default != null:
return $default(_that.user,_that.role,_that.lastReadAt,_that.lastDeliveredAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSummary user,  MemberRole role,  DateTime lastReadAt,  DateTime lastDeliveredAt,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _RoomMember():
return $default(_that.user,_that.role,_that.lastReadAt,_that.lastDeliveredAt,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSummary user,  MemberRole role,  DateTime lastReadAt,  DateTime lastDeliveredAt,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoomMember() when $default != null:
return $default(_that.user,_that.role,_that.lastReadAt,_that.lastDeliveredAt,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RoomMember extends RoomMember {
  const _RoomMember({required this.user, this.role = MemberRole.member, required this.lastReadAt, required this.lastDeliveredAt, required this.joinedAt}): super._();
  

@override final  UserSummary user;
@override@JsonKey() final  MemberRole role;
@override final  DateTime lastReadAt;
@override final  DateTime lastDeliveredAt;
@override final  DateTime joinedAt;

/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomMemberCopyWith<_RoomMember> get copyWith => __$RoomMemberCopyWithImpl<_RoomMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoomMember&&(identical(other.user, user) || other.user == user)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.lastDeliveredAt, lastDeliveredAt) || other.lastDeliveredAt == lastDeliveredAt)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,role,lastReadAt,lastDeliveredAt,joinedAt);
}

@override
String toString() {
    return 'RoomMember(user: $user, role: $role, lastReadAt: $lastReadAt, lastDeliveredAt: $lastDeliveredAt, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$RoomMemberCopyWith<$Res> implements $RoomMemberCopyWith<$Res> {
  factory _$RoomMemberCopyWith(_RoomMember value, $Res Function(_RoomMember) _then) = __$RoomMemberCopyWithImpl;
@override @useResult
$Res call({
 UserSummary user, MemberRole role, DateTime lastReadAt, DateTime lastDeliveredAt, DateTime joinedAt
});


@override $UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$RoomMemberCopyWithImpl<$Res>
    implements _$RoomMemberCopyWith<$Res> {
  __$RoomMemberCopyWithImpl(this._self, this._then);

  final _RoomMember _self;
  final $Res Function(_RoomMember) _then;

/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? role = null,Object? lastReadAt = null,Object? lastDeliveredAt = null,Object? joinedAt = null,}) {
  return _then(_RoomMember(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastDeliveredAt: null == lastDeliveredAt ? _self.lastDeliveredAt : lastDeliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of RoomMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
