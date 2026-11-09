// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HelpFeedbackModel {

 bool get helpful; String? get comment;
/// Create a copy of HelpFeedbackModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpFeedbackModelCopyWith<HelpFeedbackModel> get copyWith => _$HelpFeedbackModelCopyWithImpl<HelpFeedbackModel>(this as HelpFeedbackModel, _$identity);

  /// Serializes this HelpFeedbackModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpFeedbackModel&&(identical(other.helpful, helpful) || other.helpful == helpful)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,helpful,comment);

@override
String toString() {
  return 'HelpFeedbackModel(helpful: $helpful, comment: $comment)';
}


}

/// @nodoc
abstract mixin class $HelpFeedbackModelCopyWith<$Res>  {
  factory $HelpFeedbackModelCopyWith(HelpFeedbackModel value, $Res Function(HelpFeedbackModel) _then) = _$HelpFeedbackModelCopyWithImpl;
@useResult
$Res call({
 bool helpful, String? comment
});




}
/// @nodoc
class _$HelpFeedbackModelCopyWithImpl<$Res>
    implements $HelpFeedbackModelCopyWith<$Res> {
  _$HelpFeedbackModelCopyWithImpl(this._self, this._then);

  final HelpFeedbackModel _self;
  final $Res Function(HelpFeedbackModel) _then;

/// Create a copy of HelpFeedbackModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? helpful = null,Object? comment = freezed,}) {
  return _then(_self.copyWith(
helpful: null == helpful ? _self.helpful : helpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpFeedbackModel].
extension HelpFeedbackModelPatterns on HelpFeedbackModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpFeedbackModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpFeedbackModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpFeedbackModel value)  $default,){
final _that = this;
switch (_that) {
case _HelpFeedbackModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpFeedbackModel value)?  $default,){
final _that = this;
switch (_that) {
case _HelpFeedbackModel() when $default != null:
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
case _HelpFeedbackModel() when $default != null:
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
case _HelpFeedbackModel():
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
case _HelpFeedbackModel() when $default != null:
return $default(_that.helpful,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HelpFeedbackModel extends HelpFeedbackModel {
  const _HelpFeedbackModel({required this.helpful, this.comment}): super._();
  factory _HelpFeedbackModel.fromJson(Map<String, dynamic> json) => _$HelpFeedbackModelFromJson(json);

@override final  bool helpful;
@override final  String? comment;

/// Create a copy of HelpFeedbackModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpFeedbackModelCopyWith<_HelpFeedbackModel> get copyWith => __$HelpFeedbackModelCopyWithImpl<_HelpFeedbackModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HelpFeedbackModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpFeedbackModel&&(identical(other.helpful, helpful) || other.helpful == helpful)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,helpful,comment);

@override
String toString() {
  return 'HelpFeedbackModel(helpful: $helpful, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$HelpFeedbackModelCopyWith<$Res> implements $HelpFeedbackModelCopyWith<$Res> {
  factory _$HelpFeedbackModelCopyWith(_HelpFeedbackModel value, $Res Function(_HelpFeedbackModel) _then) = __$HelpFeedbackModelCopyWithImpl;
@override @useResult
$Res call({
 bool helpful, String? comment
});




}
/// @nodoc
class __$HelpFeedbackModelCopyWithImpl<$Res>
    implements _$HelpFeedbackModelCopyWith<$Res> {
  __$HelpFeedbackModelCopyWithImpl(this._self, this._then);

  final _HelpFeedbackModel _self;
  final $Res Function(_HelpFeedbackModel) _then;

/// Create a copy of HelpFeedbackModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? helpful = null,Object? comment = freezed,}) {
  return _then(_HelpFeedbackModel(
helpful: null == helpful ? _self.helpful : helpful // ignore: cast_nullable_to_non_nullable
as bool,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HelpArticleModel {

 String get id; String get category; String get question; String get answer; String? get topic; DateTime? get updatedAt; HelpFeedbackModel? get feedback;
/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpArticleModelCopyWith<HelpArticleModel> get copyWith => _$HelpArticleModelCopyWithImpl<HelpArticleModel>(this as HelpArticleModel, _$identity);

  /// Serializes this HelpArticleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpArticleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,question,answer,topic,updatedAt,feedback);

@override
String toString() {
  return 'HelpArticleModel(id: $id, category: $category, question: $question, answer: $answer, topic: $topic, updatedAt: $updatedAt, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $HelpArticleModelCopyWith<$Res>  {
  factory $HelpArticleModelCopyWith(HelpArticleModel value, $Res Function(HelpArticleModel) _then) = _$HelpArticleModelCopyWithImpl;
@useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedbackModel? feedback
});


$HelpFeedbackModelCopyWith<$Res>? get feedback;

}
/// @nodoc
class _$HelpArticleModelCopyWithImpl<$Res>
    implements $HelpArticleModelCopyWith<$Res> {
  _$HelpArticleModelCopyWithImpl(this._self, this._then);

  final HelpArticleModel _self;
  final $Res Function(HelpArticleModel) _then;

/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedbackModel?,
  ));
}
/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpFeedbackModelCopyWith<$Res>? get feedback {
    if (_self.feedback == null) {
    return null;
  }

  return $HelpFeedbackModelCopyWith<$Res>(_self.feedback!, (value) {
    return _then(_self.copyWith(feedback: value));
  });
}
}


/// Adds pattern-matching-related methods to [HelpArticleModel].
extension HelpArticleModelPatterns on HelpArticleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpArticleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpArticleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpArticleModel value)  $default,){
final _that = this;
switch (_that) {
case _HelpArticleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpArticleModel value)?  $default,){
final _that = this;
switch (_that) {
case _HelpArticleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedbackModel? feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpArticleModel() when $default != null:
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedbackModel? feedback)  $default,) {final _that = this;
switch (_that) {
case _HelpArticleModel():
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedbackModel? feedback)?  $default,) {final _that = this;
switch (_that) {
case _HelpArticleModel() when $default != null:
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HelpArticleModel extends HelpArticleModel {
  const _HelpArticleModel({required this.id, this.category = '', this.question = '', this.answer = '', this.topic, this.updatedAt, this.feedback}): super._();
  factory _HelpArticleModel.fromJson(Map<String, dynamic> json) => _$HelpArticleModelFromJson(json);

@override final  String id;
@override@JsonKey() final  String category;
@override@JsonKey() final  String question;
@override@JsonKey() final  String answer;
@override final  String? topic;
@override final  DateTime? updatedAt;
@override final  HelpFeedbackModel? feedback;

/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpArticleModelCopyWith<_HelpArticleModel> get copyWith => __$HelpArticleModelCopyWithImpl<_HelpArticleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HelpArticleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpArticleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,question,answer,topic,updatedAt,feedback);

@override
String toString() {
  return 'HelpArticleModel(id: $id, category: $category, question: $question, answer: $answer, topic: $topic, updatedAt: $updatedAt, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$HelpArticleModelCopyWith<$Res> implements $HelpArticleModelCopyWith<$Res> {
  factory _$HelpArticleModelCopyWith(_HelpArticleModel value, $Res Function(_HelpArticleModel) _then) = __$HelpArticleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedbackModel? feedback
});


@override $HelpFeedbackModelCopyWith<$Res>? get feedback;

}
/// @nodoc
class __$HelpArticleModelCopyWithImpl<$Res>
    implements _$HelpArticleModelCopyWith<$Res> {
  __$HelpArticleModelCopyWithImpl(this._self, this._then);

  final _HelpArticleModel _self;
  final $Res Function(_HelpArticleModel) _then;

/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,}) {
  return _then(_HelpArticleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedbackModel?,
  ));
}

/// Create a copy of HelpArticleModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HelpFeedbackModelCopyWith<$Res>? get feedback {
    if (_self.feedback == null) {
    return null;
  }

  return $HelpFeedbackModelCopyWith<$Res>(_self.feedback!, (value) {
    return _then(_self.copyWith(feedback: value));
  });
}
}


/// @nodoc
mixin _$HelpCategoryModel {

 String get code; String get name; String? get icon; List<HelpArticleModel> get articles;
/// Create a copy of HelpCategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCategoryModelCopyWith<HelpCategoryModel> get copyWith => _$HelpCategoryModelCopyWithImpl<HelpCategoryModel>(this as HelpCategoryModel, _$identity);

  /// Serializes this HelpCategoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCategoryModel&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.articles, articles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,icon,const DeepCollectionEquality().hash(articles));

@override
String toString() {
  return 'HelpCategoryModel(code: $code, name: $name, icon: $icon, articles: $articles)';
}


}

/// @nodoc
abstract mixin class $HelpCategoryModelCopyWith<$Res>  {
  factory $HelpCategoryModelCopyWith(HelpCategoryModel value, $Res Function(HelpCategoryModel) _then) = _$HelpCategoryModelCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? icon, List<HelpArticleModel> articles
});




}
/// @nodoc
class _$HelpCategoryModelCopyWithImpl<$Res>
    implements $HelpCategoryModelCopyWith<$Res> {
  _$HelpCategoryModelCopyWithImpl(this._self, this._then);

  final HelpCategoryModel _self;
  final $Res Function(HelpCategoryModel) _then;

/// Create a copy of HelpCategoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? icon = freezed,Object? articles = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self.articles : articles // ignore: cast_nullable_to_non_nullable
as List<HelpArticleModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpCategoryModel].
extension HelpCategoryModelPatterns on HelpCategoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCategoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _HelpCategoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCategoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? icon,  List<HelpArticleModel> articles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCategoryModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? icon,  List<HelpArticleModel> articles)  $default,) {final _that = this;
switch (_that) {
case _HelpCategoryModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? icon,  List<HelpArticleModel> articles)?  $default,) {final _that = this;
switch (_that) {
case _HelpCategoryModel() when $default != null:
return $default(_that.code,_that.name,_that.icon,_that.articles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HelpCategoryModel extends HelpCategoryModel {
  const _HelpCategoryModel({required this.code, this.name = '', this.icon, final  List<HelpArticleModel> articles = const <HelpArticleModel>[]}): _articles = articles,super._();
  factory _HelpCategoryModel.fromJson(Map<String, dynamic> json) => _$HelpCategoryModelFromJson(json);

@override final  String code;
@override@JsonKey() final  String name;
@override final  String? icon;
 final  List<HelpArticleModel> _articles;
@override@JsonKey() List<HelpArticleModel> get articles {
  if (_articles is EqualUnmodifiableListView) return _articles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_articles);
}


/// Create a copy of HelpCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCategoryModelCopyWith<_HelpCategoryModel> get copyWith => __$HelpCategoryModelCopyWithImpl<_HelpCategoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HelpCategoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCategoryModel&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._articles, _articles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,icon,const DeepCollectionEquality().hash(_articles));

@override
String toString() {
  return 'HelpCategoryModel(code: $code, name: $name, icon: $icon, articles: $articles)';
}


}

/// @nodoc
abstract mixin class _$HelpCategoryModelCopyWith<$Res> implements $HelpCategoryModelCopyWith<$Res> {
  factory _$HelpCategoryModelCopyWith(_HelpCategoryModel value, $Res Function(_HelpCategoryModel) _then) = __$HelpCategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? icon, List<HelpArticleModel> articles
});




}
/// @nodoc
class __$HelpCategoryModelCopyWithImpl<$Res>
    implements _$HelpCategoryModelCopyWith<$Res> {
  __$HelpCategoryModelCopyWithImpl(this._self, this._then);

  final _HelpCategoryModel _self;
  final $Res Function(_HelpCategoryModel) _then;

/// Create a copy of HelpCategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? icon = freezed,Object? articles = null,}) {
  return _then(_HelpCategoryModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self._articles : articles // ignore: cast_nullable_to_non_nullable
as List<HelpArticleModel>,
  ));
}


}


/// @nodoc
mixin _$HelpCenterModel {

 List<HelpCategoryModel> get categories; DateTime? get updatedAt;
/// Create a copy of HelpCenterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpCenterModelCopyWith<HelpCenterModel> get copyWith => _$HelpCenterModelCopyWithImpl<HelpCenterModel>(this as HelpCenterModel, _$identity);

  /// Serializes this HelpCenterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCenterModel&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),updatedAt);

@override
String toString() {
  return 'HelpCenterModel(categories: $categories, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HelpCenterModelCopyWith<$Res>  {
  factory $HelpCenterModelCopyWith(HelpCenterModel value, $Res Function(HelpCenterModel) _then) = _$HelpCenterModelCopyWithImpl;
@useResult
$Res call({
 List<HelpCategoryModel> categories, DateTime? updatedAt
});




}
/// @nodoc
class _$HelpCenterModelCopyWithImpl<$Res>
    implements $HelpCenterModelCopyWith<$Res> {
  _$HelpCenterModelCopyWithImpl(this._self, this._then);

  final HelpCenterModel _self;
  final $Res Function(HelpCenterModel) _then;

/// Create a copy of HelpCenterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<HelpCategoryModel>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HelpCenterModel].
extension HelpCenterModelPatterns on HelpCenterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HelpCenterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HelpCenterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HelpCenterModel value)  $default,){
final _that = this;
switch (_that) {
case _HelpCenterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HelpCenterModel value)?  $default,){
final _that = this;
switch (_that) {
case _HelpCenterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HelpCategoryModel> categories,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpCenterModel() when $default != null:
return $default(_that.categories,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HelpCategoryModel> categories,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _HelpCenterModel():
return $default(_that.categories,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HelpCategoryModel> categories,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _HelpCenterModel() when $default != null:
return $default(_that.categories,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HelpCenterModel extends HelpCenterModel {
  const _HelpCenterModel({final  List<HelpCategoryModel> categories = const <HelpCategoryModel>[], this.updatedAt}): _categories = categories,super._();
  factory _HelpCenterModel.fromJson(Map<String, dynamic> json) => _$HelpCenterModelFromJson(json);

 final  List<HelpCategoryModel> _categories;
@override@JsonKey() List<HelpCategoryModel> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  DateTime? updatedAt;

/// Create a copy of HelpCenterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpCenterModelCopyWith<_HelpCenterModel> get copyWith => __$HelpCenterModelCopyWithImpl<_HelpCenterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HelpCenterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCenterModel&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),updatedAt);

@override
String toString() {
  return 'HelpCenterModel(categories: $categories, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HelpCenterModelCopyWith<$Res> implements $HelpCenterModelCopyWith<$Res> {
  factory _$HelpCenterModelCopyWith(_HelpCenterModel value, $Res Function(_HelpCenterModel) _then) = __$HelpCenterModelCopyWithImpl;
@override @useResult
$Res call({
 List<HelpCategoryModel> categories, DateTime? updatedAt
});




}
/// @nodoc
class __$HelpCenterModelCopyWithImpl<$Res>
    implements _$HelpCenterModelCopyWith<$Res> {
  __$HelpCenterModelCopyWithImpl(this._self, this._then);

  final _HelpCenterModel _self;
  final $Res Function(_HelpCenterModel) _then;

/// Create a copy of HelpCenterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? updatedAt = freezed,}) {
  return _then(_HelpCenterModel(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<HelpCategoryModel>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
