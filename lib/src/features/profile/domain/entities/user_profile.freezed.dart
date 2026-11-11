// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfile {

 UserSummary get user; String? get bio; int get followerCount; int get followingCount; int get postCount; DateTime get createdAt; bool get isMe; bool get isFollowing; bool get followsMe; bool get isBlocked;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.followsMe, followsMe) || other.followsMe == followsMe)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked));
}


@override
int get hashCode => Object.hash(runtimeType,user,bio,followerCount,followingCount,postCount,createdAt,isMe,isFollowing,followsMe,isBlocked);

@override
String toString() {
  return 'UserProfile(user: $user, bio: $bio, followerCount: $followerCount, followingCount: $followingCount, postCount: $postCount, createdAt: $createdAt, isMe: $isMe, isFollowing: $isFollowing, followsMe: $followsMe, isBlocked: $isBlocked)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 UserSummary user, String? bio, int followerCount, int followingCount, int postCount, DateTime createdAt, bool isMe, bool isFollowing, bool followsMe, bool isBlocked
});


$UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? bio = freezed,Object? followerCount = null,Object? followingCount = null,Object? postCount = null,Object? createdAt = null,Object? isMe = null,Object? isFollowing = null,Object? followsMe = null,Object? isBlocked = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,followsMe: null == followsMe ? _self.followsMe : followsMe // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSummary user,  String? bio,  int followerCount,  int followingCount,  int postCount,  DateTime createdAt,  bool isMe,  bool isFollowing,  bool followsMe,  bool isBlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.bio,_that.followerCount,_that.followingCount,_that.postCount,_that.createdAt,_that.isMe,_that.isFollowing,_that.followsMe,_that.isBlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSummary user,  String? bio,  int followerCount,  int followingCount,  int postCount,  DateTime createdAt,  bool isMe,  bool isFollowing,  bool followsMe,  bool isBlocked)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.user,_that.bio,_that.followerCount,_that.followingCount,_that.postCount,_that.createdAt,_that.isMe,_that.isFollowing,_that.followsMe,_that.isBlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSummary user,  String? bio,  int followerCount,  int followingCount,  int postCount,  DateTime createdAt,  bool isMe,  bool isFollowing,  bool followsMe,  bool isBlocked)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.user,_that.bio,_that.followerCount,_that.followingCount,_that.postCount,_that.createdAt,_that.isMe,_that.isFollowing,_that.followsMe,_that.isBlocked);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile implements UserProfile {
  const _UserProfile({required this.user, this.bio, required this.followerCount, required this.followingCount, required this.postCount, required this.createdAt, required this.isMe, required this.isFollowing, required this.followsMe, required this.isBlocked});
  

@override final  UserSummary user;
@override final  String? bio;
@override final  int followerCount;
@override final  int followingCount;
@override final  int postCount;
@override final  DateTime createdAt;
@override final  bool isMe;
@override final  bool isFollowing;
@override final  bool followsMe;
@override final  bool isBlocked;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.user, user) || other.user == user)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.followsMe, followsMe) || other.followsMe == followsMe)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked));
}


@override
int get hashCode => Object.hash(runtimeType,user,bio,followerCount,followingCount,postCount,createdAt,isMe,isFollowing,followsMe,isBlocked);

@override
String toString() {
  return 'UserProfile(user: $user, bio: $bio, followerCount: $followerCount, followingCount: $followingCount, postCount: $postCount, createdAt: $createdAt, isMe: $isMe, isFollowing: $isFollowing, followsMe: $followsMe, isBlocked: $isBlocked)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 UserSummary user, String? bio, int followerCount, int followingCount, int postCount, DateTime createdAt, bool isMe, bool isFollowing, bool followsMe, bool isBlocked
});


@override $UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? bio = freezed,Object? followerCount = null,Object? followingCount = null,Object? postCount = null,Object? createdAt = null,Object? isMe = null,Object? isFollowing = null,Object? followsMe = null,Object? isBlocked = null,}) {
  return _then(_UserProfile(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,followsMe: null == followsMe ? _self.followsMe : followsMe // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc
mixin _$SuggestedUser {

 UserSummary get user; int get followerCount; int get mutualCount; bool get isOfficial;
/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedUserCopyWith<SuggestedUser> get copyWith => _$SuggestedUserCopyWithImpl<SuggestedUser>(this as SuggestedUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedUser&&(identical(other.user, user) || other.user == user)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.mutualCount, mutualCount) || other.mutualCount == mutualCount)&&(identical(other.isOfficial, isOfficial) || other.isOfficial == isOfficial));
}


@override
int get hashCode => Object.hash(runtimeType,user,followerCount,mutualCount,isOfficial);

@override
String toString() {
  return 'SuggestedUser(user: $user, followerCount: $followerCount, mutualCount: $mutualCount, isOfficial: $isOfficial)';
}


}

/// @nodoc
abstract mixin class $SuggestedUserCopyWith<$Res>  {
  factory $SuggestedUserCopyWith(SuggestedUser value, $Res Function(SuggestedUser) _then) = _$SuggestedUserCopyWithImpl;
@useResult
$Res call({
 UserSummary user, int followerCount, int mutualCount, bool isOfficial
});


$UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$SuggestedUserCopyWithImpl<$Res>
    implements $SuggestedUserCopyWith<$Res> {
  _$SuggestedUserCopyWithImpl(this._self, this._then);

  final SuggestedUser _self;
  final $Res Function(SuggestedUser) _then;

/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? followerCount = null,Object? mutualCount = null,Object? isOfficial = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,mutualCount: null == mutualCount ? _self.mutualCount : mutualCount // ignore: cast_nullable_to_non_nullable
as int,isOfficial: null == isOfficial ? _self.isOfficial : isOfficial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [SuggestedUser].
extension SuggestedUserPatterns on SuggestedUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedUser value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedUser value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSummary user,  int followerCount,  int mutualCount,  bool isOfficial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedUser() when $default != null:
return $default(_that.user,_that.followerCount,_that.mutualCount,_that.isOfficial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSummary user,  int followerCount,  int mutualCount,  bool isOfficial)  $default,) {final _that = this;
switch (_that) {
case _SuggestedUser():
return $default(_that.user,_that.followerCount,_that.mutualCount,_that.isOfficial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSummary user,  int followerCount,  int mutualCount,  bool isOfficial)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedUser() when $default != null:
return $default(_that.user,_that.followerCount,_that.mutualCount,_that.isOfficial);case _:
  return null;

}
}

}

/// @nodoc


class _SuggestedUser implements SuggestedUser {
  const _SuggestedUser({required this.user, this.followerCount = 0, this.mutualCount = 0, this.isOfficial = false});
  

@override final  UserSummary user;
@override@JsonKey() final  int followerCount;
@override@JsonKey() final  int mutualCount;
@override@JsonKey() final  bool isOfficial;

/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedUserCopyWith<_SuggestedUser> get copyWith => __$SuggestedUserCopyWithImpl<_SuggestedUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedUser&&(identical(other.user, user) || other.user == user)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.mutualCount, mutualCount) || other.mutualCount == mutualCount)&&(identical(other.isOfficial, isOfficial) || other.isOfficial == isOfficial));
}


@override
int get hashCode => Object.hash(runtimeType,user,followerCount,mutualCount,isOfficial);

@override
String toString() {
  return 'SuggestedUser(user: $user, followerCount: $followerCount, mutualCount: $mutualCount, isOfficial: $isOfficial)';
}


}

/// @nodoc
abstract mixin class _$SuggestedUserCopyWith<$Res> implements $SuggestedUserCopyWith<$Res> {
  factory _$SuggestedUserCopyWith(_SuggestedUser value, $Res Function(_SuggestedUser) _then) = __$SuggestedUserCopyWithImpl;
@override @useResult
$Res call({
 UserSummary user, int followerCount, int mutualCount, bool isOfficial
});


@override $UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$SuggestedUserCopyWithImpl<$Res>
    implements _$SuggestedUserCopyWith<$Res> {
  __$SuggestedUserCopyWithImpl(this._self, this._then);

  final _SuggestedUser _self;
  final $Res Function(_SuggestedUser) _then;

/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? followerCount = null,Object? mutualCount = null,Object? isOfficial = null,}) {
  return _then(_SuggestedUser(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,mutualCount: null == mutualCount ? _self.mutualCount : mutualCount // ignore: cast_nullable_to_non_nullable
as int,isOfficial: null == isOfficial ? _self.isOfficial : isOfficial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SuggestedUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc
mixin _$FollowListEntry {

 UserSummary get user; bool get isMe; bool get isFollowing; bool get followsMe; DateTime? get followedAt; String? get cursor;
/// Create a copy of FollowListEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowListEntryCopyWith<FollowListEntry> get copyWith => _$FollowListEntryCopyWithImpl<FollowListEntry>(this as FollowListEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowListEntry&&(identical(other.user, user) || other.user == user)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.followsMe, followsMe) || other.followsMe == followsMe)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,user,isMe,isFollowing,followsMe,followedAt,cursor);

@override
String toString() {
  return 'FollowListEntry(user: $user, isMe: $isMe, isFollowing: $isFollowing, followsMe: $followsMe, followedAt: $followedAt, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $FollowListEntryCopyWith<$Res>  {
  factory $FollowListEntryCopyWith(FollowListEntry value, $Res Function(FollowListEntry) _then) = _$FollowListEntryCopyWithImpl;
@useResult
$Res call({
 UserSummary user, bool isMe, bool isFollowing, bool followsMe, DateTime? followedAt, String? cursor
});


$UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class _$FollowListEntryCopyWithImpl<$Res>
    implements $FollowListEntryCopyWith<$Res> {
  _$FollowListEntryCopyWithImpl(this._self, this._then);

  final FollowListEntry _self;
  final $Res Function(FollowListEntry) _then;

/// Create a copy of FollowListEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? isMe = null,Object? isFollowing = null,Object? followsMe = null,Object? followedAt = freezed,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,followsMe: null == followsMe ? _self.followsMe : followsMe // ignore: cast_nullable_to_non_nullable
as bool,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FollowListEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res> get user {
  
  return $UserSummaryCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [FollowListEntry].
extension FollowListEntryPatterns on FollowListEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowListEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowListEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowListEntry value)  $default,){
final _that = this;
switch (_that) {
case _FollowListEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowListEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FollowListEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserSummary user,  bool isMe,  bool isFollowing,  bool followsMe,  DateTime? followedAt,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowListEntry() when $default != null:
return $default(_that.user,_that.isMe,_that.isFollowing,_that.followsMe,_that.followedAt,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserSummary user,  bool isMe,  bool isFollowing,  bool followsMe,  DateTime? followedAt,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _FollowListEntry():
return $default(_that.user,_that.isMe,_that.isFollowing,_that.followsMe,_that.followedAt,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserSummary user,  bool isMe,  bool isFollowing,  bool followsMe,  DateTime? followedAt,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _FollowListEntry() when $default != null:
return $default(_that.user,_that.isMe,_that.isFollowing,_that.followsMe,_that.followedAt,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _FollowListEntry implements FollowListEntry {
  const _FollowListEntry({required this.user, this.isMe = false, this.isFollowing = false, this.followsMe = false, this.followedAt, this.cursor});
  

@override final  UserSummary user;
@override@JsonKey() final  bool isMe;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool followsMe;
@override final  DateTime? followedAt;
@override final  String? cursor;

/// Create a copy of FollowListEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowListEntryCopyWith<_FollowListEntry> get copyWith => __$FollowListEntryCopyWithImpl<_FollowListEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowListEntry&&(identical(other.user, user) || other.user == user)&&(identical(other.isMe, isMe) || other.isMe == isMe)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.followsMe, followsMe) || other.followsMe == followsMe)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,user,isMe,isFollowing,followsMe,followedAt,cursor);

@override
String toString() {
  return 'FollowListEntry(user: $user, isMe: $isMe, isFollowing: $isFollowing, followsMe: $followsMe, followedAt: $followedAt, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$FollowListEntryCopyWith<$Res> implements $FollowListEntryCopyWith<$Res> {
  factory _$FollowListEntryCopyWith(_FollowListEntry value, $Res Function(_FollowListEntry) _then) = __$FollowListEntryCopyWithImpl;
@override @useResult
$Res call({
 UserSummary user, bool isMe, bool isFollowing, bool followsMe, DateTime? followedAt, String? cursor
});


@override $UserSummaryCopyWith<$Res> get user;

}
/// @nodoc
class __$FollowListEntryCopyWithImpl<$Res>
    implements _$FollowListEntryCopyWith<$Res> {
  __$FollowListEntryCopyWithImpl(this._self, this._then);

  final _FollowListEntry _self;
  final $Res Function(_FollowListEntry) _then;

/// Create a copy of FollowListEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? isMe = null,Object? isFollowing = null,Object? followsMe = null,Object? followedAt = freezed,Object? cursor = freezed,}) {
  return _then(_FollowListEntry(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserSummary,isMe: null == isMe ? _self.isMe : isMe // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,followsMe: null == followsMe ? _self.followsMe : followsMe // ignore: cast_nullable_to_non_nullable
as bool,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FollowListEntry
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
