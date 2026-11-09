// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpFeedback&&(identical(other.helpful, helpful) || other.helpful == helpful)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode => Object.hash(runtimeType,helpful,comment);

@override
String toString() {
  return 'HelpFeedback(helpful: $helpful, comment: $comment)';
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
  return _then(_self.copyWith(
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
int get hashCode => Object.hash(runtimeType,helpful,comment);

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
mixin _$HelpArticle {

 String get id; String get category; String get question; String get answer; String? get topic; DateTime? get updatedAt; HelpFeedback? get feedback;
/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HelpArticleCopyWith<HelpArticle> get copyWith => _$HelpArticleCopyWithImpl<HelpArticle>(this as HelpArticle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,question,answer,topic,updatedAt,feedback);

@override
String toString() {
  return 'HelpArticle(id: $id, category: $category, question: $question, answer: $answer, topic: $topic, updatedAt: $updatedAt, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $HelpArticleCopyWith<$Res>  {
  factory $HelpArticleCopyWith(HelpArticle value, $Res Function(HelpArticle) _then) = _$HelpArticleCopyWithImpl;
@useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedback? feedback
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedback?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback)  $default,) {final _that = this;
switch (_that) {
case _HelpArticle():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String question,  String answer,  String? topic,  DateTime? updatedAt,  HelpFeedback? feedback)?  $default,) {final _that = this;
switch (_that) {
case _HelpArticle() when $default != null:
return $default(_that.id,_that.category,_that.question,_that.answer,_that.topic,_that.updatedAt,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc


class _HelpArticle implements HelpArticle {
  const _HelpArticle({required this.id, required this.category, required this.question, required this.answer, this.topic, this.updatedAt, this.feedback});
  

@override final  String id;
@override final  String category;
@override final  String question;
@override final  String answer;
@override final  String? topic;
@override final  DateTime? updatedAt;
@override final  HelpFeedback? feedback;

/// Create a copy of HelpArticle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HelpArticleCopyWith<_HelpArticle> get copyWith => __$HelpArticleCopyWithImpl<_HelpArticle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpArticle&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}


@override
int get hashCode => Object.hash(runtimeType,id,category,question,answer,topic,updatedAt,feedback);

@override
String toString() {
  return 'HelpArticle(id: $id, category: $category, question: $question, answer: $answer, topic: $topic, updatedAt: $updatedAt, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$HelpArticleCopyWith<$Res> implements $HelpArticleCopyWith<$Res> {
  factory _$HelpArticleCopyWith(_HelpArticle value, $Res Function(_HelpArticle) _then) = __$HelpArticleCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String question, String answer, String? topic, DateTime? updatedAt, HelpFeedback? feedback
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? question = null,Object? answer = null,Object? topic = freezed,Object? updatedAt = freezed,Object? feedback = freezed,}) {
  return _then(_HelpArticle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as HelpFeedback?,
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCategory&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.articles, articles));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,icon,const DeepCollectionEquality().hash(articles));

@override
String toString() {
  return 'HelpCategory(code: $code, name: $name, icon: $icon, articles: $articles)';
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
  return _then(_self.copyWith(
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
  const _HelpCategory({required this.code, required this.name, this.icon, final  List<HelpArticle> articles = const <HelpArticle>[]}): _articles = articles;
  

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCategory&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._articles, _articles));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,icon,const DeepCollectionEquality().hash(_articles));

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HelpCenterContent&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),updatedAt,savedAt);

@override
String toString() {
  return 'HelpCenterContent(categories: $categories, updatedAt: $updatedAt, savedAt: $savedAt)';
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
  return _then(_self.copyWith(
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
  const _HelpCenterContent({final  List<HelpCategory> categories = const <HelpCategory>[], this.updatedAt, this.savedAt}): _categories = categories,super._();
  

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HelpCenterContent&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),updatedAt,savedAt);

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
