// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HelpFeedback {

 bool get helpful; String? get comment;
/// Create a copy of HelpFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpFeedbackCopyWith<HelpFeedback> get copyWith => _$HelpFeedbackCopyWithImpl<HelpFeedback>(this as HelpFeedback, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HelpFeedback;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpFeedback&&(identical(other.helpful, _this.helpful) || other.helpful == _this.helpful)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as HelpFeedback;
  return Object.hash(runtimeType,_this.helpful,_this.comment);
}

@override
String toString() {
  final _this = this as HelpFeedback;
  return 'HelpFeedback(helpful: ${_this.helpful}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $HelpFeedbackCopyWith<$Res>  {
  factory $HelpFeedbackCopyWith(HelpFeedback value, $Res Function(HelpFeedback) _then) = _$HelpFeedbackCopyWithImpl;
@useResult
$Res call({
 bool helpful, String? comment
});




}
/// @nodoc
class _$HelpFeedbackCopyWithImpl<$Res>
    implements $HelpFeedbackCopyWith<$Res> {
  _$HelpFeedbackCopyWithImpl(this._self, this._then);

  final HelpFeedback _self;
  final $Res Function(HelpFeedback) _then;

/// Create a copy of HelpFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? helpful = null,Object? comment = freezed,}) {
  return _then(HelpFeedback(
helpful: null == helpful ? _self.helpful : helpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpFeedback].
extension HelpFeedbackPatterns on HelpFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpFeedback value)  $default,){
final _that = this;
switch (_that) {
case _HelpFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _HelpFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool helpful,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpFeedback() when $default != null:
return $default(_that.helpful,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool helpful,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _HelpFeedback():
return $default(_that.helpful,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool helpful,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _HelpFeedback() when $default != null:
return $default(_that.helpful,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _HelpFeedback implements HelpFeedback {
  const _HelpFeedback({required this.helpful, this.comment});
  

@override final  bool helpful;
@override final  String? comment;

/// Create a copy of HelpFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpFeedbackCopyWith<_HelpFeedback> get copyWith => __$HelpFeedbackCopyWithImpl<_HelpFeedback>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpFeedback&&(identical(other.helpful, helpful) || other.helpful == helpful)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,helpful,comment);
}

@override
String toString() {
    return 'HelpFeedback(helpful: $helpful, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$HelpFeedbackCopyWith<$Res> implements $HelpFeedbackCopyWith<$Res> {
  factory _$HelpFeedbackCopyWith(_HelpFeedback value, $Res Function(_HelpFeedback) _then) = __$HelpFeedbackCopyWithImpl;
@override @useResult
$Res call({
 bool helpful, String? comment
});




}
/// @nodoc
class __$HelpFeedbackCopyWithImpl<$Res>
    implements _$HelpFeedbackCopyWith<$Res> {
  __$HelpFeedbackCopyWithImpl(this._self, this._then);

  final _HelpFeedback _self;
  final $Res Function(_HelpFeedback) _then;

/// Create a copy of HelpFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? helpful = null,Object? comment = freezed,}) {
  return _then(_HelpFeedback(
helpful: null == helpful ? _self.helpful : helpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HelpAttachment {

 String get path; Uri get url; String get name; HelpAttachmentKind get kind; String? get mime; int? get size;
/// Create a copy of HelpAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpAttachmentCopyWith<HelpAttachment> get copyWith => _$HelpAttachmentCopyWithImpl<HelpAttachment>(this as HelpAttachment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HelpAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpAttachment&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.mime, _this.mime) || other.mime == _this.mime)&&(identical(other.size, _this.size) || other.size == _this.size));
}


@override
int get hashCode {
  final _this = this as HelpAttachment;
  return Object.hash(runtimeType,_this.path,_this.url,_this.name,_this.kind,_this.mime,_this.size);
}

@override
String toString() {
  final _this = this as HelpAttachment;
  return 'HelpAttachment(path: ${_this.path}, url: ${_this.url}, name: ${_this.name}, kind: ${_this.kind}, mime: ${_this.mime}, size: ${_this.size})';
}


}

/// @nodoc
abstract mixin class $HelpAttachmentCopyWith<$Res>  {
  factory $HelpAttachmentCopyWith(HelpAttachment value, $Res Function(HelpAttachment) _then) = _$HelpAttachmentCopyWithImpl;
@useResult
$Res call({
 String path, Uri url, String name, HelpAttachmentKind kind, String? mime, int? size
});




}
/// @nodoc
class _$HelpAttachmentCopyWithImpl<$Res>
    implements $HelpAttachmentCopyWith<$Res> {
  _$HelpAttachmentCopyWithImpl(this._self, this._then);

  final HelpAttachment _self;
  final $Res Function(HelpAttachment) _then;

/// Create a copy of HelpAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? url = null,Object? name = null,Object? kind = null,Object? mime = freezed,Object? size = freezed,}) {
  return _then(HelpAttachment(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HelpAttachmentKind,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpAttachment].
extension HelpAttachmentPatterns on HelpAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpAttachment value)  $default,){
final _that = this;
switch (_that) {
case _HelpAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _HelpAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  Uri url,  String name,  HelpAttachmentKind kind,  String? mime,  int? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpAttachment() when $default != null:
return $default(_that.path,_that.url,_that.name,_that.kind,_that.mime,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  Uri url,  String name,  HelpAttachmentKind kind,  String? mime,  int? size)  $default,) {final _that = this;
switch (_that) {
case _HelpAttachment():
return $default(_that.path,_that.url,_that.name,_that.kind,_that.mime,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  Uri url,  String name,  HelpAttachmentKind kind,  String? mime,  int? size)?  $default,) {final _that = this;
switch (_that) {
case _HelpAttachment() when $default != null:
return $default(_that.path,_that.url,_that.name,_that.kind,_that.mime,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _HelpAttachment implements HelpAttachment {
  const _HelpAttachment({required this.path, required this.url, required this.name, required this.kind, this.mime, this.size});
  

@override final  String path;
@override final  Uri url;
@override final  String name;
@override final  HelpAttachmentKind kind;
@override final  String? mime;
@override final  int? size;

/// Create a copy of HelpAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpAttachmentCopyWith<_HelpAttachment> get copyWith => __$HelpAttachmentCopyWithImpl<_HelpAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpAttachment&&(identical(other.path, path) || other.path == path)&&(identical(other.url, url) || other.url == url)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.mime, mime) || other.mime == mime)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,url,name,kind,mime,size);
}

@override
String toString() {
    return 'HelpAttachment(path: $path, url: $url, name: $name, kind: $kind, mime: $mime, size: $size)';
}


}

/// @nodoc
abstract mixin class _$HelpAttachmentCopyWith<$Res> implements $HelpAttachmentCopyWith<$Res> {
  factory _$HelpAttachmentCopyWith(_HelpAttachment value, $Res Function(_HelpAttachment) _then) = __$HelpAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String path, Uri url, String name, HelpAttachmentKind kind, String? mime, int? size
});




}
/// @nodoc
class __$HelpAttachmentCopyWithImpl<$Res>
    implements _$HelpAttachmentCopyWith<$Res> {
  __$HelpAttachmentCopyWithImpl(this._self, this._then);

  final _HelpAttachment _self;
  final $Res Function(_HelpAttachment) _then;

/// Create a copy of HelpAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? url = null,Object? name = null,Object? kind = null,Object? mime = freezed,Object? size = freezed,}) {
  return _then(_HelpAttachment(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HelpAttachmentKind,mime: freezed == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$HelpArticle {

 String get id; String get category; String get question; String get answer; String? get topic; DateTime? get updatedAt; HelpFeedback? get feedback; List<HelpAttachment> get attachments;
/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpArticleCopyWith<HelpArticle> get copyWith => _$HelpArticleCopyWithImpl<HelpArticle>(this as HelpArticle, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HelpArticle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpArticle&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.question, _this.question) || other.question == _this.question)&&(identical(other.answer, _this.answer) || other.answer == _this.answer)&&(identical(other.topic, _this.topic) || other.topic == _this.topic)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.feedback, _this.feedback) || other.feedback == _this.feedback)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments));
}


@override
int get hashCode {
  final _this = this as HelpArticle;
  return Object.hash(runtimeType,_this.id,_this.category,_this.question,_this.answer,_this.topic,_this.updatedAt,_this.feedback,const DeepCollectionEquality().hash(_this.attachments));
}

@override
String toString() {
  final _this = this as HelpArticle;
  return 'HelpArticle(id: ${_this.id}, category: ${_this.category}, question: ${_this.question}, answer: ${_this.answer}, topic: ${_this.topic}, updatedAt: ${_this.updatedAt}, feedback: ${_this.feedback}, attachments: ${_this.attachments})';
}


}

/// @nodoc
abstract mixin class $HelpArticleCopyWith<$Res>  {
  factory $HelpArticleCopyWith(HelpArticle value, $Res Function(HelpArticle) _then) = _$HelpArticleCopyWithImpl;
@useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedback? feedback, List<HelpAttachment> attachments
});


$HelpFeedbackCopyWith<$Res>? get feedback;

}
/// @nodoc
class _$HelpArticleCopyWithImpl<$Res>
    implements $HelpArticleCopyWith<$Res> {
  _$HelpArticleCopyWithImpl(this._self, this._then);

  final HelpArticle _self;
  final $Res Function(HelpArticle) _then;

/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,Object? attachments = null,}) {
  return _then(HelpArticle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedback?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<HelpAttachment>,
  ));
}
/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpFeedbackCopyWith<$Res>? get feedback {
    if (_self.feedback == null) {
    return null;
  }

  return $HelpFeedbackCopyWith<$Res>(_self.feedback!, (value) {
    return _then(_self.copyWith(feedback: value));
  });
}
}


/// Adds pattern-matching-related methods to [HelpArticle].
extension HelpArticlePatterns on HelpArticle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpArticle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpArticle value)  $default,){
final _that = this;
switch (_that) {
case _HelpArticle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpArticle value)?  $default,){
final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback,  List<HelpAttachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback,  List<HelpAttachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _HelpArticle():
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback,  List<HelpAttachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _HelpArticle implements HelpArticle {
  const _HelpArticle({required this.id, required this.category, required this.question, required this.answer, this.topic, this.updatedAt, this.feedback,  List<HelpAttachment> attachments = const <HelpAttachment>[]}): _attachments = attachments;
  

@override final  String id;
@override final  String category;
@override final  String question;
@override final  String answer;
@override final  String? topic;
@override final  DateTime? updatedAt;
@override final  HelpFeedback? feedback;
 final  List<HelpAttachment> _attachments;
@override@JsonKey() List<HelpAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpArticleCopyWith<_HelpArticle> get copyWith => __$HelpArticleCopyWithImpl<_HelpArticle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&const DeepCollectionEquality().equals(other.attachments, _attachments));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,category,question,answer,topic,updatedAt,feedback,const DeepCollectionEquality().hash(_attachments));
}

@override
String toString() {
    return 'HelpArticle(id: $id, category: $category, question: $question, answer: $answer, topic: $topic, updatedAt: $updatedAt, feedback: $feedback, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$HelpArticleCopyWith<$Res> implements $HelpArticleCopyWith<$Res> {
  factory _$HelpArticleCopyWith(_HelpArticle value, $Res Function(_HelpArticle) _then) = __$HelpArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedback? feedback, List<HelpAttachment> attachments
});


@override $HelpFeedbackCopyWith<$Res>? get feedback;

}
/// @nodoc
class __$HelpArticleCopyWithImpl<$Res>
    implements _$HelpArticleCopyWith<$Res> {
  __$HelpArticleCopyWithImpl(this._self, this._then);

  final _HelpArticle _self;
  final $Res Function(_HelpArticle) _then;

/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,Object? attachments = null,}) {
  return _then(_HelpArticle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedback?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<HelpAttachment>,
  ));
}

/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpFeedbackCopyWith<$Res>? get feedback {
    if (_self.feedback == null) {
    return null;
  }

  return $HelpFeedbackCopyWith<$Res>(_self.feedback!, (value) {
    return _then(_self.copyWith(feedback: value));
  });
}
}

/// @nodoc
mixin _$HelpCategory {

 String get code; String get name; String? get icon; List<HelpArticle> get articles;
/// Create a copy of HelpCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCategoryCopyWith<HelpCategory> get copyWith => _$HelpCategoryCopyWithImpl<HelpCategory>(this as HelpCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HelpCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCategory&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&const DeepCollectionEquality().equals(other.articles, _this.articles));
}


@override
int get hashCode {
  final _this = this as HelpCategory;
  return Object.hash(runtimeType,_this.code,_this.name,_this.icon,const DeepCollectionEquality().hash(_this.articles));
}

@override
String toString() {
  final _this = this as HelpCategory;
  return 'HelpCategory(code: ${_this.code}, name: ${_this.name}, icon: ${_this.icon}, articles: ${_this.articles})';
}


}

/// @nodoc
abstract mixin class $HelpCategoryCopyWith<$Res>  {
  factory $HelpCategoryCopyWith(HelpCategory value, $Res Function(HelpCategory) _then) = _$HelpCategoryCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? icon, List<HelpArticle> articles
});




}
/// @nodoc
class _$HelpCategoryCopyWithImpl<$Res>
    implements $HelpCategoryCopyWith<$Res> {
  _$HelpCategoryCopyWithImpl(this._self, this._then);

  final HelpCategory _self;
  final $Res Function(HelpCategory) _then;

/// Create a copy of HelpCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? icon = freezed,Object? articles = null,}) {
  return _then(HelpCategory(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self.articles : articles // ignore: cast_nullable_to_non_nullable
as List<HelpArticle>,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpCategory].
extension HelpCategoryPatterns on HelpCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCategory value)  $default,){
final _that = this;
switch (_that) {
case _HelpCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCategory value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? icon,  List<HelpArticle> articles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCategory() when $default != null:
return $default(_that.code,_that.name,_that.icon,_that.articles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? icon,  List<HelpArticle> articles)  $default,) {final _that = this;
switch (_that) {
case _HelpCategory():
return $default(_that.code,_that.name,_that.icon,_that.articles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? icon,  List<HelpArticle> articles)?  $default,) {final _that = this;
switch (_that) {
case _HelpCategory() when $default != null:
return $default(_that.code,_that.name,_that.icon,_that.articles);case _:
  return null;

}
}

}

/// @nodoc


class _HelpCategory implements HelpCategory {
  const _HelpCategory({required this.code, required this.name, this.icon,  List<HelpArticle> articles = const <HelpArticle>[]}): _articles = articles;
  

@override final  String code;
@override final  String name;
@override final  String? icon;
 final  List<HelpArticle> _articles;
@override@JsonKey() List<HelpArticle> get articles {
  if (_articles is EqualUnmodifiableListView) return _articles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_articles);
}


/// Create a copy of HelpCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCategoryCopyWith<_HelpCategory> get copyWith => __$HelpCategoryCopyWithImpl<_HelpCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCategory&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.articles, _articles));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,name,icon,const DeepCollectionEquality().hash(_articles));
}

@override
String toString() {
    return 'HelpCategory(code: $code, name: $name, icon: $icon, articles: $articles)';
}


}

/// @nodoc
abstract mixin class _$HelpCategoryCopyWith<$Res> implements $HelpCategoryCopyWith<$Res> {
  factory _$HelpCategoryCopyWith(_HelpCategory value, $Res Function(_HelpCategory) _then) = __$HelpCategoryCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? icon, List<HelpArticle> articles
});




}
/// @nodoc
class __$HelpCategoryCopyWithImpl<$Res>
    implements _$HelpCategoryCopyWith<$Res> {
  __$HelpCategoryCopyWithImpl(this._self, this._then);

  final _HelpCategory _self;
  final $Res Function(_HelpCategory) _then;

/// Create a copy of HelpCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? icon = freezed,Object? articles = null,}) {
  return _then(_HelpCategory(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self._articles : articles // ignore: cast_nullable_to_non_nullable
as List<HelpArticle>,
  ));
}


}

/// @nodoc
mixin _$HelpCenterContent {

 List<HelpCategory> get categories; DateTime? get updatedAt; DateTime? get savedAt;
/// Create a copy of HelpCenterContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCenterContentCopyWith<HelpCenterContent> get copyWith => _$HelpCenterContentCopyWithImpl<HelpCenterContent>(this as HelpCenterContent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HelpCenterContent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCenterContent&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.savedAt, _this.savedAt) || other.savedAt == _this.savedAt));
}


@override
int get hashCode {
  final _this = this as HelpCenterContent;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),_this.updatedAt,_this.savedAt);
}

@override
String toString() {
  final _this = this as HelpCenterContent;
  return 'HelpCenterContent(categories: ${_this.categories}, updatedAt: ${_this.updatedAt}, savedAt: ${_this.savedAt})';
}


}

/// @nodoc
abstract mixin class $HelpCenterContentCopyWith<$Res>  {
  factory $HelpCenterContentCopyWith(HelpCenterContent value, $Res Function(HelpCenterContent) _then) = _$HelpCenterContentCopyWithImpl;
@useResult
$Res call({
 List<HelpCategory> categories, DateTime? updatedAt, DateTime? savedAt
});




}
/// @nodoc
class _$HelpCenterContentCopyWithImpl<$Res>
    implements $HelpCenterContentCopyWith<$Res> {
  _$HelpCenterContentCopyWithImpl(this._self, this._then);

  final HelpCenterContent _self;
  final $Res Function(HelpCenterContent) _then;

/// Create a copy of HelpCenterContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? updatedAt = freezed,Object? savedAt = freezed,}) {
  return _then(HelpCenterContent(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<HelpCategory>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,savedAt: freezed == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpCenterContent].
extension HelpCenterContentPatterns on HelpCenterContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCenterContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCenterContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCenterContent value)  $default,){
final _that = this;
switch (_that) {
case _HelpCenterContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCenterContent value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCenterContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HelpCategory> categories,  DateTime? updatedAt,  DateTime? savedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCenterContent() when $default != null:
return $default(_that.categories,_that.updatedAt,_that.savedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HelpCategory> categories,  DateTime? updatedAt,  DateTime? savedAt)  $default,) {final _that = this;
switch (_that) {
case _HelpCenterContent():
return $default(_that.categories,_that.updatedAt,_that.savedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HelpCategory> categories,  DateTime? updatedAt,  DateTime? savedAt)?  $default,) {final _that = this;
switch (_that) {
case _HelpCenterContent() when $default != null:
return $default(_that.categories,_that.updatedAt,_that.savedAt);case _:
  return null;

}
}

}

/// @nodoc


class _HelpCenterContent extends HelpCenterContent {
  const _HelpCenterContent({ List<HelpCategory> categories = const <HelpCategory>[], this.updatedAt, this.savedAt}): _categories = categories,super._();
  

 final  List<HelpCategory> _categories;
@override@JsonKey() List<HelpCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  DateTime? updatedAt;
@override final  DateTime? savedAt;

/// Create a copy of HelpCenterContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCenterContentCopyWith<_HelpCenterContent> get copyWith => __$HelpCenterContentCopyWithImpl<_HelpCenterContent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCenterContent&&const DeepCollectionEquality().equals(other.categories, _categories)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),updatedAt,savedAt);
}

@override
String toString() {
    return 'HelpCenterContent(categories: $categories, updatedAt: $updatedAt, savedAt: $savedAt)';
}


}

/// @nodoc
abstract mixin class _$HelpCenterContentCopyWith<$Res> implements $HelpCenterContentCopyWith<$Res> {
  factory _$HelpCenterContentCopyWith(_HelpCenterContent value, $Res Function(_HelpCenterContent) _then) = __$HelpCenterContentCopyWithImpl;
@override @useResult
$Res call({
 List<HelpCategory> categories, DateTime? updatedAt, DateTime? savedAt
});




}
/// @nodoc
class __$HelpCenterContentCopyWithImpl<$Res>
    implements _$HelpCenterContentCopyWith<$Res> {
  __$HelpCenterContentCopyWithImpl(this._self, this._then);

  final _HelpCenterContent _self;
  final $Res Function(_HelpCenterContent) _then;

/// Create a copy of HelpCenterContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? updatedAt = freezed,Object? savedAt = freezed,}) {
  return _then(_HelpCenterContent(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<HelpCategory>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,savedAt: freezed == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
