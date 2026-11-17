// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttachmentModel {

 String get path;@JsonKey(includeIfNull: false) String? get bucket; String? get mime;@JsonKey(includeIfNull: false) String? get name;@JsonKey(includeIfNull: false) int? get size; int? get width; int? get height;@JsonKey(includeIfNull: false) double? get duration;@JsonKey(includeIfNull: false) String? get thumbnail;
/// Create a copy of AttachmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentModelCopyWith<AttachmentModel> get copyWith => _$AttachmentModelCopyWithImpl<AttachmentModel>(this as AttachmentModel, _$identity);

  /// Serializes this AttachmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AttachmentModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentModel&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.bucket, _this.bucket) || other.bucket == _this.bucket)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.thumbnail, _this.thumbnail) || other.thumbnail == _this.thumbnail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AttachmentModel;
  return Object.hash(runtimeType,_this.path,_this.bucket,_this.mime,_this.name,_this.size,_this.width,_this.height,_this.duration,_this.thumbnail);
}

@override
String toString() {
  final _this = this as AttachmentModel;
  return 'AttachmentModel(path: ${_this.path}, bucket: ${_this.bucket}, mime: ${_this.mime}, name: ${_this.name}, size: ${_this.size}, width: ${_this.width}, height: ${_this.height}, duration: ${_this.duration}, thumbnail: ${_this.thumbnail})';
}


}

/// @nodoc
abstract mixin class $AttachmentModelCopyWith<$Res>  {
  factory $AttachmentModelCopyWith(AttachmentModel value, $Res Function(AttachmentModel) _then) = _$AttachmentModelCopyWithImpl;
@useResult
$Res call({
 String path,@JsonKey(includeIfNull: false) String? bucket, String? mime,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) int? size, int? width, int? height,@JsonKey(includeIfNull: false) double? duration,@JsonKey(includeIfNull: false) String? thumbnail
});




}
/// @nodoc
class _$AttachmentModelCopyWithImpl<$Res>
    implements $AttachmentModelCopyWith<$Res> {
  _$AttachmentModelCopyWithImpl(this._self, this._then);

  final AttachmentModel _self;
  final $Res Function(AttachmentModel) _then;

/// Create a copy of AttachmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? bucket = freezed,Object? mime = freezed,Object? name = freezed,Object? size = freezed,Object? width = freezed,Object? height = freezed,Object? duration = freezed,Object? thumbnail = freezed,}) {
  return _then(AttachmentModel(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttachmentModel].
extension AttachmentModelPatterns on AttachmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttachmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttachmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttachmentModel value)  $default,){
final _that = this;
switch (_that) {
case _AttachmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttachmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _AttachmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path, @JsonKey(includeIfNull: false)  String? bucket,  String? mime, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? size,  int? width,  int? height, @JsonKey(includeIfNull: false)  double? duration, @JsonKey(includeIfNull: false)  String? thumbnail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttachmentModel() when $default != null:
return $default(_that.path,_that.bucket,_that.mime,_that.name,_that.size,_that.width,_that.height,_that.duration,_that.thumbnail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path, @JsonKey(includeIfNull: false)  String? bucket,  String? mime, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? size,  int? width,  int? height, @JsonKey(includeIfNull: false)  double? duration, @JsonKey(includeIfNull: false)  String? thumbnail)  $default,) {final _that = this;
switch (_that) {
case _AttachmentModel():
return $default(_that.path,_that.bucket,_that.mime,_that.name,_that.size,_that.width,_that.height,_that.duration,_that.thumbnail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path, @JsonKey(includeIfNull: false)  String? bucket,  String? mime, @JsonKey(includeIfNull: false)  String? name, @JsonKey(includeIfNull: false)  int? size,  int? width,  int? height, @JsonKey(includeIfNull: false)  double? duration, @JsonKey(includeIfNull: false)  String? thumbnail)?  $default,) {final _that = this;
switch (_that) {
case _AttachmentModel() when $default != null:
return $default(_that.path,_that.bucket,_that.mime,_that.name,_that.size,_that.width,_that.height,_that.duration,_that.thumbnail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AttachmentModel extends AttachmentModel {
  const _AttachmentModel({required this.path, @JsonKey(includeIfNull: false) this.bucket, this.mime, @JsonKey(includeIfNull: false) this.name, @JsonKey(includeIfNull: false) this.size, this.width, this.height, @JsonKey(includeIfNull: false) this.duration, @JsonKey(includeIfNull: false) this.thumbnail}): super._();
  factory _AttachmentModel.fromJson(Map<String, dynamic> json) => _$AttachmentModelFromJson(json);

@override final  String path;
@override@JsonKey(includeIfNull: false) final  String? bucket;
@override final  String? mime;
@override@JsonKey(includeIfNull: false) final  String? name;
@override@JsonKey(includeIfNull: false) final  int? size;
@override final  int? width;
@override final  int? height;
@override@JsonKey(includeIfNull: false) final  double? duration;
@override@JsonKey(includeIfNull: false) final  String? thumbnail;

/// Create a copy of AttachmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentModelCopyWith<_AttachmentModel> get copyWith => __$AttachmentModelCopyWithImpl<_AttachmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttachmentModel&&(identical(other.path, path) || other.path == path)&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,bucket,mime,name,size,width,height,duration,thumbnail);
}

@override
String toString() {
    return 'AttachmentModel(path: $path, bucket: $bucket, mime: $mime, name: $name, size: $size, width: $width, height: $height, duration: $duration, thumbnail: $thumbnail)';
}


}

/// @nodoc
abstract mixin class _$AttachmentModelCopyWith<$Res> implements $AttachmentModelCopyWith<$Res> {
  factory _$AttachmentModelCopyWith(_AttachmentModel value, $Res Function(_AttachmentModel) _then) = __$AttachmentModelCopyWithImpl;
@override @useResult
$Res call({
 String path,@JsonKey(includeIfNull: false) String? bucket, String? mime,@JsonKey(includeIfNull: false) String? name,@JsonKey(includeIfNull: false) int? size, int? width, int? height,@JsonKey(includeIfNull: false) double? duration,@JsonKey(includeIfNull: false) String? thumbnail
});




}
/// @nodoc
class __$AttachmentModelCopyWithImpl<$Res>
    implements _$AttachmentModelCopyWith<$Res> {
  __$AttachmentModelCopyWithImpl(this._self, this._then);

  final _AttachmentModel _self;
  final $Res Function(_AttachmentModel) _then;

/// Create a copy of AttachmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? bucket = freezed,Object? mime = freezed,Object? name = freezed,Object? size = freezed,Object? width = freezed,Object? height = freezed,Object? duration = freezed,Object? thumbnail = freezed,}) {
  return _then(_AttachmentModel(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,bucket: freezed == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String?,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
