// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComposeState {

 Sentiment? get sentiment; List<Attachment> get attachments; PollDraft? get poll; bool get uploading; bool get submitting; Object? get error; int get errorId; DraftSyncStatus? get draftStatus; int get draftNoticeId; String? get restoredBody; CommentAudience? get commentAudience; CommentAudience? get defaultCommentAudience; bool get commentsAllOff;
/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposeStateCopyWith<ComposeState> get copyWith => _$ComposeStateCopyWithImpl<ComposeState>(this as ComposeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposeState&&(identical(other.sentiment, _this.sentiment) || other.sentiment == _this.sentiment)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments)&&(identical(other.poll, _this.poll) || other.poll == _this.poll)&&(identical(other.uploading, _this.uploading) || other.uploading == _this.uploading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&const DeepCollectionEquality().equals(other.error, _this.error)&&(identical(other.errorId, _this.errorId) || other.errorId == _this.errorId)&&(identical(other.draftStatus, _this.draftStatus) || other.draftStatus == _this.draftStatus)&&(identical(other.draftNoticeId, _this.draftNoticeId) || other.draftNoticeId == _this.draftNoticeId)&&(identical(other.restoredBody, _this.restoredBody) || other.restoredBody == _this.restoredBody)&&(identical(other.commentAudience, _this.commentAudience) || other.commentAudience == _this.commentAudience)&&(identical(other.defaultCommentAudience, _this.defaultCommentAudience) || other.defaultCommentAudience == _this.defaultCommentAudience)&&(identical(other.commentsAllOff, _this.commentsAllOff) || other.commentsAllOff == _this.commentsAllOff));
}


@override
int get hashCode {
  final _this = this as ComposeState;
  return Object.hash(runtimeType,_this.sentiment,const DeepCollectionEquality().hash(_this.attachments),_this.poll,_this.uploading,_this.submitting,const DeepCollectionEquality().hash(_this.error),_this.errorId,_this.draftStatus,_this.draftNoticeId,_this.restoredBody,_this.commentAudience,_this.defaultCommentAudience,_this.commentsAllOff);
}

@override
String toString() {
  final _this = this as ComposeState;
  return 'ComposeState(sentiment: ${_this.sentiment}, attachments: ${_this.attachments}, poll: ${_this.poll}, uploading: ${_this.uploading}, submitting: ${_this.submitting}, error: ${_this.error}, errorId: ${_this.errorId}, draftStatus: ${_this.draftStatus}, draftNoticeId: ${_this.draftNoticeId}, restoredBody: ${_this.restoredBody}, commentAudience: ${_this.commentAudience}, defaultCommentAudience: ${_this.defaultCommentAudience}, commentsAllOff: ${_this.commentsAllOff})';
}


}

/// @nodoc
abstract mixin class $ComposeStateCopyWith<$Res>  {
  factory $ComposeStateCopyWith(ComposeState value, $Res Function(ComposeState) _then) = _$ComposeStateCopyWithImpl;
@useResult
$Res call({
 Sentiment? sentiment, List<Attachment> attachments, PollDraft? poll, bool uploading, bool submitting, Object? error, int errorId, DraftSyncStatus? draftStatus, int draftNoticeId, String? restoredBody, CommentAudience? commentAudience, CommentAudience? defaultCommentAudience, bool commentsAllOff
});


$PollDraftCopyWith<$Res>? get poll;

}
/// @nodoc
class _$ComposeStateCopyWithImpl<$Res>
    implements $ComposeStateCopyWith<$Res> {
  _$ComposeStateCopyWithImpl(this._self, this._then);

  final ComposeState _self;
  final $Res Function(ComposeState) _then;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sentiment = freezed,Object? attachments = null,Object? poll = freezed,Object? uploading = null,Object? submitting = null,Object? error = freezed,Object? errorId = null,Object? draftStatus = freezed,Object? draftNoticeId = null,Object? restoredBody = freezed,Object? commentAudience = freezed,Object? defaultCommentAudience = freezed,Object? commentsAllOff = null,}) {
  return _then(ComposeState(
sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as PollDraft?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,errorId: null == errorId ? _self.errorId : errorId // ignore: cast_nullable_to_non_nullable
as int,draftStatus: freezed == draftStatus ? _self.draftStatus : draftStatus // ignore: cast_nullable_to_non_nullable
as DraftSyncStatus?,draftNoticeId: null == draftNoticeId ? _self.draftNoticeId : draftNoticeId // ignore: cast_nullable_to_non_nullable
as int,restoredBody: freezed == restoredBody ? _self.restoredBody : restoredBody // ignore: cast_nullable_to_non_nullable
as String?,commentAudience: freezed == commentAudience ? _self.commentAudience : commentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,defaultCommentAudience: freezed == defaultCommentAudience ? _self.defaultCommentAudience : defaultCommentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentsAllOff: null == commentsAllOff ? _self.commentsAllOff : commentsAllOff // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollDraftCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollDraftCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}
}


/// Adds pattern-matching-related methods to [ComposeState].
extension ComposeStatePatterns on ComposeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposeState value)  $default,){
final _that = this;
switch (_that) {
case _ComposeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposeState value)?  $default,){
final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Sentiment? sentiment,  List<Attachment> attachments,  PollDraft? poll,  bool uploading,  bool submitting,  Object? error,  int errorId,  DraftSyncStatus? draftStatus,  int draftNoticeId,  String? restoredBody,  CommentAudience? commentAudience,  CommentAudience? defaultCommentAudience,  bool commentsAllOff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that.sentiment,_that.attachments,_that.poll,_that.uploading,_that.submitting,_that.error,_that.errorId,_that.draftStatus,_that.draftNoticeId,_that.restoredBody,_that.commentAudience,_that.defaultCommentAudience,_that.commentsAllOff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Sentiment? sentiment,  List<Attachment> attachments,  PollDraft? poll,  bool uploading,  bool submitting,  Object? error,  int errorId,  DraftSyncStatus? draftStatus,  int draftNoticeId,  String? restoredBody,  CommentAudience? commentAudience,  CommentAudience? defaultCommentAudience,  bool commentsAllOff)  $default,) {final _that = this;
switch (_that) {
case _ComposeState():
return $default(_that.sentiment,_that.attachments,_that.poll,_that.uploading,_that.submitting,_that.error,_that.errorId,_that.draftStatus,_that.draftNoticeId,_that.restoredBody,_that.commentAudience,_that.defaultCommentAudience,_that.commentsAllOff);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Sentiment? sentiment,  List<Attachment> attachments,  PollDraft? poll,  bool uploading,  bool submitting,  Object? error,  int errorId,  DraftSyncStatus? draftStatus,  int draftNoticeId,  String? restoredBody,  CommentAudience? commentAudience,  CommentAudience? defaultCommentAudience,  bool commentsAllOff)?  $default,) {final _that = this;
switch (_that) {
case _ComposeState() when $default != null:
return $default(_that.sentiment,_that.attachments,_that.poll,_that.uploading,_that.submitting,_that.error,_that.errorId,_that.draftStatus,_that.draftNoticeId,_that.restoredBody,_that.commentAudience,_that.defaultCommentAudience,_that.commentsAllOff);case _:
  return null;

}
}

}

/// @nodoc


class _ComposeState extends ComposeState {
  const _ComposeState({this.sentiment,  List<Attachment> attachments = const <Attachment>[], this.poll, this.uploading = false, this.submitting = false, this.error, this.errorId = 0, this.draftStatus, this.draftNoticeId = 0, this.restoredBody, this.commentAudience, this.defaultCommentAudience, this.commentsAllOff = false}): _attachments = attachments,super._();
  

@override final  Sentiment? sentiment;
 final  List<Attachment> _attachments;
@override@JsonKey() List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  PollDraft? poll;
@override@JsonKey() final  bool uploading;
@override@JsonKey() final  bool submitting;
@override final  Object? error;
@override@JsonKey() final  int errorId;
@override final  DraftSyncStatus? draftStatus;
@override@JsonKey() final  int draftNoticeId;
@override final  String? restoredBody;
@override final  CommentAudience? commentAudience;
@override final  CommentAudience? defaultCommentAudience;
@override@JsonKey() final  bool commentsAllOff;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposeStateCopyWith<_ComposeState> get copyWith => __$ComposeStateCopyWithImpl<_ComposeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposeState&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment)&&const DeepCollectionEquality().equals(other.attachments, _attachments)&&(identical(other.poll, poll) || other.poll == poll)&&(identical(other.uploading, uploading) || other.uploading == uploading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.errorId, errorId) || other.errorId == errorId)&&(identical(other.draftStatus, draftStatus) || other.draftStatus == draftStatus)&&(identical(other.draftNoticeId, draftNoticeId) || other.draftNoticeId == draftNoticeId)&&(identical(other.restoredBody, restoredBody) || other.restoredBody == restoredBody)&&(identical(other.commentAudience, commentAudience) || other.commentAudience == commentAudience)&&(identical(other.defaultCommentAudience, defaultCommentAudience) || other.defaultCommentAudience == defaultCommentAudience)&&(identical(other.commentsAllOff, commentsAllOff) || other.commentsAllOff == commentsAllOff));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sentiment,const DeepCollectionEquality().hash(_attachments),poll,uploading,submitting,const DeepCollectionEquality().hash(error),errorId,draftStatus,draftNoticeId,restoredBody,commentAudience,defaultCommentAudience,commentsAllOff);
}

@override
String toString() {
    return 'ComposeState(sentiment: $sentiment, attachments: $attachments, poll: $poll, uploading: $uploading, submitting: $submitting, error: $error, errorId: $errorId, draftStatus: $draftStatus, draftNoticeId: $draftNoticeId, restoredBody: $restoredBody, commentAudience: $commentAudience, defaultCommentAudience: $defaultCommentAudience, commentsAllOff: $commentsAllOff)';
}


}

/// @nodoc
abstract mixin class _$ComposeStateCopyWith<$Res> implements $ComposeStateCopyWith<$Res> {
  factory _$ComposeStateCopyWith(_ComposeState value, $Res Function(_ComposeState) _then) = __$ComposeStateCopyWithImpl;
@override @useResult
$Res call({
 Sentiment? sentiment, List<Attachment> attachments, PollDraft? poll, bool uploading, bool submitting, Object? error, int errorId, DraftSyncStatus? draftStatus, int draftNoticeId, String? restoredBody, CommentAudience? commentAudience, CommentAudience? defaultCommentAudience, bool commentsAllOff
});


@override $PollDraftCopyWith<$Res>? get poll;

}
/// @nodoc
class __$ComposeStateCopyWithImpl<$Res>
    implements _$ComposeStateCopyWith<$Res> {
  __$ComposeStateCopyWithImpl(this._self, this._then);

  final _ComposeState _self;
  final $Res Function(_ComposeState) _then;

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentiment = freezed,Object? attachments = null,Object? poll = freezed,Object? uploading = null,Object? submitting = null,Object? error = freezed,Object? errorId = null,Object? draftStatus = freezed,Object? draftNoticeId = null,Object? restoredBody = freezed,Object? commentAudience = freezed,Object? defaultCommentAudience = freezed,Object? commentsAllOff = null,}) {
  return _then(_ComposeState(
sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as Sentiment?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as PollDraft?,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,errorId: null == errorId ? _self.errorId : errorId // ignore: cast_nullable_to_non_nullable
as int,draftStatus: freezed == draftStatus ? _self.draftStatus : draftStatus // ignore: cast_nullable_to_non_nullable
as DraftSyncStatus?,draftNoticeId: null == draftNoticeId ? _self.draftNoticeId : draftNoticeId // ignore: cast_nullable_to_non_nullable
as int,restoredBody: freezed == restoredBody ? _self.restoredBody : restoredBody // ignore: cast_nullable_to_non_nullable
as String?,commentAudience: freezed == commentAudience ? _self.commentAudience : commentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,defaultCommentAudience: freezed == defaultCommentAudience ? _self.defaultCommentAudience : defaultCommentAudience // ignore: cast_nullable_to_non_nullable
as CommentAudience?,commentsAllOff: null == commentsAllOff ? _self.commentsAllOff : commentsAllOff // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ComposeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PollDraftCopyWith<$Res>? get poll {
    if (_self.poll == null) {
    return null;
  }

  return $PollDraftCopyWith<$Res>(_self.poll!, (value) {
    return _then(_self.copyWith(poll: value));
  });
}
}

// dart format on
