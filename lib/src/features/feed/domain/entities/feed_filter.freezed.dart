// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedFilter {

 String get key; String get labelEn; String get labelId; CommunityFeedSort get sort; String? get content; String? get icon; int get position;
/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedFilterCopyWith<FeedFilter> get copyWith => _$FeedFilterCopyWithImpl<FeedFilter>(this as FeedFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedFilter&&(identical(other.key, key) || other.key == key)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.content, content) || other.content == content)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,key,labelEn,labelId,sort,content,icon,position);

@override
String toString() {
  return 'FeedFilter(key: $key, labelEn: $labelEn, labelId: $labelId, sort: $sort, content: $content, icon: $icon, position: $position)';
}


}

/// @nodoc
abstract mixin class $FeedFilterCopyWith<$Res>  {
  factory $FeedFilterCopyWith(FeedFilter value, $Res Function(FeedFilter) _then) = _$FeedFilterCopyWithImpl;
@useResult
$Res call({
 String key, String labelEn, String labelId, CommunityFeedSort sort, String? content, String? icon, int position
});




}
/// @nodoc
class _$FeedFilterCopyWithImpl<$Res>
    implements $FeedFilterCopyWith<$Res> {
  _$FeedFilterCopyWithImpl(this._self, this._then);

  final FeedFilter _self;
  final $Res Function(FeedFilter) _then;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? labelEn = null,Object? labelId = null,Object? sort = null,Object? content = freezed,Object? icon = freezed,Object? position = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommunityFeedSort,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedFilter].
extension FeedFilterPatterns on FeedFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedFilter value)  $default,){
final _that = this;
switch (_that) {
case _FeedFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String labelEn,  String labelId,  CommunityFeedSort sort,  String? content,  String? icon,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
return $default(_that.key,_that.labelEn,_that.labelId,_that.sort,_that.content,_that.icon,_that.position);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String labelEn,  String labelId,  CommunityFeedSort sort,  String? content,  String? icon,  int position)  $default,) {final _that = this;
switch (_that) {
case _FeedFilter():
return $default(_that.key,_that.labelEn,_that.labelId,_that.sort,_that.content,_that.icon,_that.position);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String labelEn,  String labelId,  CommunityFeedSort sort,  String? content,  String? icon,  int position)?  $default,) {final _that = this;
switch (_that) {
case _FeedFilter() when $default != null:
return $default(_that.key,_that.labelEn,_that.labelId,_that.sort,_that.content,_that.icon,_that.position);case _:
  return null;

}
}

}

/// @nodoc


class _FeedFilter extends FeedFilter {
  const _FeedFilter({required this.key, required this.labelEn, required this.labelId, this.sort = CommunityFeedSort.latest, this.content, this.icon, this.position = 0}): super._();
  

@override final  String key;
@override final  String labelEn;
@override final  String labelId;
@override@JsonKey() final  CommunityFeedSort sort;
@override final  String? content;
@override final  String? icon;
@override@JsonKey() final  int position;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedFilterCopyWith<_FeedFilter> get copyWith => __$FeedFilterCopyWithImpl<_FeedFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedFilter&&(identical(other.key, key) || other.key == key)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.content, content) || other.content == content)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,key,labelEn,labelId,sort,content,icon,position);

@override
String toString() {
  return 'FeedFilter(key: $key, labelEn: $labelEn, labelId: $labelId, sort: $sort, content: $content, icon: $icon, position: $position)';
}


}

/// @nodoc
abstract mixin class _$FeedFilterCopyWith<$Res> implements $FeedFilterCopyWith<$Res> {
  factory _$FeedFilterCopyWith(_FeedFilter value, $Res Function(_FeedFilter) _then) = __$FeedFilterCopyWithImpl;
@override @useResult
$Res call({
 String key, String labelEn, String labelId, CommunityFeedSort sort, String? content, String? icon, int position
});




}
/// @nodoc
class __$FeedFilterCopyWithImpl<$Res>
    implements _$FeedFilterCopyWith<$Res> {
  __$FeedFilterCopyWithImpl(this._self, this._then);

  final _FeedFilter _self;
  final $Res Function(_FeedFilter) _then;

/// Create a copy of FeedFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? labelEn = null,Object? labelId = null,Object? sort = null,Object? content = freezed,Object? icon = freezed,Object? position = null,}) {
  return _then(_FeedFilter(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as CommunityFeedSort,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
