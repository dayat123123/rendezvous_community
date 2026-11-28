// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quoted_post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuotedPost {

 String get id; bool get available; UserSummary? get author; bool get authorIsOfficial; String get body; Sentiment? get sentiment; List<Attachment> get attachments; List<String> get stockCodes; DateTime? get createdAt;
/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotedPostCopyWith<QuotedPost> get copyWith => _$QuotedPostCopyWithImpl<QuotedPost>(this as QuotedPost, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuotedPost;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotedPost&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.authorIsOfficial, _this.authorIsOfficial) || other.authorIsOfficial == _this.authorIsOfficial)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.sentiment, _this.sentiment) || other.sentiment == _this.sentiment)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&const DeepCollectionEquality().equals(other.stockCodes, _this.stockCodes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as QuotedPost;
  return Object.hash(runtimeType,_this.id,_this.available,_this.author,_this.authorIsOfficial,_this.body,_this.sentiment,const DeepCollectionEquality().hash(_this.attachments),const DeepCollectionEquality().hash(_this.stockCodes),_this.createdAt);
}

@override
String toString() {
  final _this = this as QuotedPost;
  return 'QuotedPost(id: ${_this.id}, available: ${_this.available}, author: ${_this.author}, authorIsOfficial: ${_this.authorIsOfficial}, body: ${_this.body}, sentiment: ${_this.sentiment}, attachments: ${_this.attachments}, stockCodes: ${_this.stockCodes}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $QuotedPostCopyWith<$Res>  {
  factory $QuotedPostCopyWith(QuotedPost value, $Res Function(QuotedPost) _then) = _$QuotedPostCopyWithImpl;
@useResult
$Res call({
 String id, bool available, UserSummary? author, bool authorIsOfficial, String body, Sentiment? sentiment, List<Attachment> attachments, List<String> stockCodes, DateTime? createdAt
});


$UserSummaryCopyWith<$Res>? get author;

}
/// @nodoc
class _$QuotedPostCopyWithImpl<$Res>
    implements $QuotedPostCopyWith<$Res> {
  _$QuotedPostCopyWithImpl(this._self, this._then);

  final QuotedPost _self;
  final $Res Function(QuotedPost) _then;

/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? available = null,Object? author = freezed,Object? authorIsOfficial = null,Object? body = null,Object? sentiment = freezed,Object? attachments = null,Object? stockCodes = null,Object? createdAt = freezed,}) {
  return _then(QuotedPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary?,authorIsOfficial: null == authorIsOfficial ? _self.authorIsOfficial : authorIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,stockCodes: null == stockCodes ? _self.stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuotedPost].
extension QuotedPostPatterns on QuotedPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotedPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotedPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotedPost value)  $default,){
final _that = this;
switch (_that) {
case _QuotedPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotedPost value)?  $default,){
final _that = this;
switch (_that) {
case _QuotedPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool available,  UserSummary? author,  bool authorIsOfficial,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  List<String> stockCodes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotedPost() when $default != null:
return $default(_that.id,_that.available,_that.author,_that.authorIsOfficial,_that.body,_that.sentiment,_that.attachments,_that.stockCodes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool available,  UserSummary? author,  bool authorIsOfficial,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  List<String> stockCodes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _QuotedPost():
return $default(_that.id,_that.available,_that.author,_that.authorIsOfficial,_that.body,_that.sentiment,_that.attachments,_that.stockCodes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool available,  UserSummary? author,  bool authorIsOfficial,  String body,  Sentiment? sentiment,  List<Attachment> attachments,  List<String> stockCodes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _QuotedPost() when $default != null:
return $default(_that.id,_that.available,_that.author,_that.authorIsOfficial,_that.body,_that.sentiment,_that.attachments,_that.stockCodes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _QuotedPost extends QuotedPost {
  const _QuotedPost({required this.id, this.available = true, this.author, this.authorIsOfficial = false, this.body = '', this.sentiment,  List<Attachment> attachments = const <Attachment>[],  List<String> stockCodes = const <String>[], this.createdAt}): _attachments = attachments,_stockCodes = stockCodes,super._();
  

@override final  String id;
@override@JsonKey() final  bool available;
@override final  UserSummary? author;
@override@JsonKey() final  bool authorIsOfficial;
@override@JsonKey() final  String body;
@override final  Sentiment? sentiment;
 final  List<Attachment> _attachments;
@override@JsonKey() List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<String> _stockCodes;
@override@JsonKey() List<String> get stockCodes {
  if (_stockCodes is EqualUnmodifiableListView) return _stockCodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stockCodes);
}

@override final  DateTime? createdAt;

/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotedPostCopyWith<_QuotedPost> get copyWith => __$QuotedPostCopyWithImpl<_QuotedPost>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotedPost&&(identical(other.id, id) || other.id == id)&&(identical(other.available, available) || other.available == available)&&(identical(other.author, author) || other.author == author)&&(identical(other.authorIsOfficial, authorIsOfficial) || other.authorIsOfficial == authorIsOfficial)&&(identical(other.body, body) || other.body == body)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&const DeepCollectionEquality().equals(other.stockCodes, _stockCodes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,available,author,authorIsOfficial,body,sentiment,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_stockCodes),createdAt);
}

@override
String toString() {
    return 'QuotedPost(id: $id, available: $available, author: $author, authorIsOfficial: $authorIsOfficial, body: $body, sentiment: $sentiment, attachments: $attachments, stockCodes: $stockCodes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$QuotedPostCopyWith<$Res> implements $QuotedPostCopyWith<$Res> {
  factory _$QuotedPostCopyWith(_QuotedPost value, $Res Function(_QuotedPost) _then) = __$QuotedPostCopyWithImpl;
@override @useResult
$Res call({
 String id, bool available, UserSummary? author, bool authorIsOfficial, String body, Sentiment? sentiment, List<Attachment> attachments, List<String> stockCodes, DateTime? createdAt
});


@override $UserSummaryCopyWith<$Res>? get author;

}
/// @nodoc
class __$QuotedPostCopyWithImpl<$Res>
    implements _$QuotedPostCopyWith<$Res> {
  __$QuotedPostCopyWithImpl(this._self, this._then);

  final _QuotedPost _self;
  final $Res Function(_QuotedPost) _then;

/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? available = null,Object? author = freezed,Object? authorIsOfficial = null,Object? body = null,Object? sentiment = freezed,Object? attachments = null,Object? stockCodes = null,Object? createdAt = freezed,}) {
  return _then(_QuotedPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as UserSummary?,authorIsOfficial: null == authorIsOfficial ? _self.authorIsOfficial : authorIsOfficial // ignore: cast_nullable_to_non_nullable
as bool,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,stockCodes: null == stockCodes ? _self._stockCodes : stockCodes // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of QuotedPost
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserSummaryCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $UserSummaryCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on
