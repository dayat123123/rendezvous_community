import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/features/bookmarks/domain/repositories/bookmark_repository.dart';
import 'package:rendezvous_community/src/features/edit/domain/repositories/content_edit_repository.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/legal/domain/services/consent_gate.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/comment_sort.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';
import 'package:rendezvous_community/src/features/post/domain/repositories/comment_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';

part 'comment_thread_cubit.freezed.dart';

const topLevelKey = '';

@freezed
abstract class ThreadState with _$ThreadState {
  const factory ThreadState({
    @Default(LoadStatus.initial) LoadStatus status,
    Post? post,
    ThreadComment? root,
    @Default(<String, ThreadComment>{}) Map<String, ThreadComment> comments,
    @Default(<String, List<String>>{}) Map<String, List<String>> children,
    String? topCursor,
    @Default(false) bool hasMoreTop,
    @Default(<String>{}) Set<String> collapsed,
    @Default(<String>{}) Set<String> loadingBranches,
    ThreadComment? replyTo,
    @Default(false) bool sending,
    Object? error,
    Object? actionError,
    @Default(0) int actionErrorId,
    @Default(CommunityCommentSort.oldest) CommunityCommentSort sort,
    @Default(true) bool sortSupported,
    @Default(0) int topOffset,
  }) = _ThreadState;

  const ThreadState._();

  String get rootKey => root?.id ?? topLevelKey;

  int get baseDepth => root == null ? 0 : root!.depth + 1;

  int levelOf(ThreadComment c) => c.depth - baseDepth;
}

class CommentThreadCubit extends Cubit<ThreadState> {
  CommentThreadCubit({
    required this._feed,
    required this._comments,
    required this.postId,
    this.rootCommentId,
    this.maxLevels = 4,
    this.pageSize = 20,
    this.repliesPerBranch = 3,
    this._consent,
    this._bookmarks,
    this._edits,
    CommunityCommentSort sort = CommunityCommentSort.oldest,
    this.firstPageSize,
    this.fetchPost = true,
    this.onCommentCountChanged,
  }) : super(ThreadState(sort: sort));

  final FeedRepository _feed;
  final CommentRepository _comments;
  final ConsentGate? _consent;
  final BookmarkRepository? _bookmarks;
  final ContentEditRepository? _edits;

  bool get canBookmark => _bookmarks != null;

  bool get canEdit => _edits != null;
  final String postId;
  final String? rootCommentId;

  final int maxLevels;
  final int pageSize;
  final int repliesPerBranch;
  final int? firstPageSize;
  final bool fetchPost;
  final ValueChanged<int>? onCommentCountChanged;

  bool _sortMissing = false;

  bool _ordered(ThreadState s) => !_sortMissing && rootCommentId == null && s.sort != CommunityCommentSort.oldest;

  StreamSubscription<String>? _commentEvents;
  StreamSubscription<PostChange>? _postEvents;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    final limit = firstPageSize ?? pageSize;
    try {
      final results = await Future.wait([
        if (fetchPost) _feed.getPost(postId) else Future<Post?>.value(state.post),
        _fetchPage(limit: limit, includeRoot: rootCommentId != null),
      ]);
      if (isClosed) return;
      final post = results[0] as Post?;
      final list = results[1]! as List<ThreadComment>;
      final root = rootCommentId == null ? null : list.where((c) => c.id == rootCommentId).firstOrNull;
      var next = ThreadState(
        status: LoadStatus.ready,
        post: post,
        root: root,
        sort: state.sort,
        sortSupported: !_sortMissing,
      );
      next = _merge(next, list);
      final top = _topLevelOf(next, list);
      emit(next.copyWith(topCursor: top.lastOrNull?.cursor, topOffset: top.length, hasMoreTop: top.length >= limit));
      _listen();
    } catch (e) {
      if (!isClosed) emit(state.copyWith(status: LoadStatus.failure, error: e));
    }
  }

  Future<void> setSort(CommunityCommentSort sort) async {
    if (sort == state.sort || rootCommentId != null) return;
    emit(
      state.copyWith(
        sort: sort,
        comments: const {},
        children: const {},
        collapsed: const {},
        loadingBranches: const {},
        topCursor: null,
        topOffset: 0,
        hasMoreTop: false,
        replyTo: null,
      ),
    );
    await load();
  }

  Future<List<ThreadComment>> _fetchPage({String? cursor, required int limit, bool includeRoot = false}) async {
    if (_comments case final SortedCommentRepository repository when _ordered(state)) {
      try {
        return await repository.getSortedThread(
          postId,
          sort: state.sort,
          cursor: cursor,
          maxDepth: maxLevels - 1,
          limit: limit,
          repliesLimit: repliesPerBranch,
        );
      } on CommunityException catch (e) {
        if (e.code != 'PGRST202' || cursor != null) rethrow;
        _sortMissing = true;
        if (!isClosed) emit(state.copyWith(sortSupported: false));
      }
    }
    return _comments.getThread(
      postId,
      rootCommentId: state.root?.id ?? rootCommentId,
      cursor: cursor,
      maxDepth: maxLevels - 1,
      limit: limit,
      repliesLimit: repliesPerBranch,
      includeRoot: includeRoot,
    );
  }

  Future<void> loadMoreTop() async {
    if (!state.hasMoreTop || state.loadingBranches.contains(topLevelKey)) return;
    _setLoading(topLevelKey, true);
    try {
      final byOffset = _ordered(state) && state.sort == CommunityCommentSort.top;
      final list = await _fetchPage(cursor: byOffset ? '${state.topOffset}' : state.topCursor, limit: pageSize);
      if (isClosed) return;
      final next = _merge(state, list);
      final top = _topLevelOf(next, list);
      emit(
        next.copyWith(
          topCursor: top.lastOrNull?.cursor ?? state.topCursor,
          topOffset: state.topOffset + top.length,
          hasMoreTop: top.length >= pageSize,
        ),
      );
    } catch (e) {
      _fail(e);
    } finally {
      _setLoading(topLevelKey, false);
    }
  }

  Future<void> loadMoreReplies(String parentId) async {
    final parent = state.comments[parentId];
    if (parent == null || state.loadingBranches.contains(parentId)) return;
    final loaded = state.children[parentId] ?? const [];
    final cursor = loaded.isEmpty ? null : state.comments[loaded.last]?.cursor;
    final depthBelow = math.max(0, (maxLevels - 1) - (state.levelOf(parent) + 1));
    _setLoading(parentId, true);
    try {
      final list = await _comments.getThread(
        postId,
        rootCommentId: parentId,
        cursor: cursor,
        maxDepth: depthBelow,
        limit: 10,
        repliesLimit: repliesPerBranch,
      );
      if (!isClosed) emit(_merge(state, list));
    } catch (e) {
      _fail(e);
    } finally {
      _setLoading(parentId, false);
    }
  }

  void toggleCollapse(String commentId) {
    final collapsed = {...state.collapsed};
    if (!collapsed.remove(commentId)) collapsed.add(commentId);
    emit(state.copyWith(collapsed: collapsed));
  }

  void setReplyTo(ThreadComment? comment) => emit(state.copyWith(replyTo: comment));

  Future<bool> send(String body) async {
    final text = body.trim();
    if (text.isEmpty || state.sending) return false;
    final parentId = state.replyTo?.id ?? state.root?.id;
    emit(state.copyWith(sending: true));
    try {
      final created = await _consent.guard(
        () => _comments.createComment(postId: postId, parentId: parentId, body: text),
      );
      onCommentCountChanged?.call(1);
      if (isClosed) return true;
      var next = _merge(state, [created], prepend: true);
      next = _bumpReplyCount(next, parentId, 1);
      final post = next.post;
      final collapsed = {...next.collapsed}..remove(parentId);
      emit(
        next.copyWith(
          sending: false,
          replyTo: null,
          collapsed: collapsed,
          post: post?.copyWith(commentCount: post.commentCount + 1),
        ),
      );
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(sending: false));
      _fail(e);
      return false;
    }
  }

  Future<void> toggleLike(ThreadComment comment) async {
    final current = state.comments[comment.id] ?? comment;
    final liked = !current.likedByMe;
    _replace(current.copyWith(likedByMe: liked, likeCount: current.likeCount + (liked ? 1 : -1)));
    try {
      liked ? await _comments.likeComment(comment.id) : await _comments.unlikeComment(comment.id);
    } catch (e) {
      _replace(current);
      _fail(e);
    }
  }

  Future<void> deleteComment(ThreadComment comment) async {
    final before = state;
    if (!before.comments.containsKey(comment.id) && before.root?.id != comment.id) return;
    final post = before.post;
    emit(
      _liftDeletedComment(
        before,
        comment.id,
      ).copyWith(post: post?.copyWith(commentCount: math.max(0, post.commentCount - 1))),
    );
    onCommentCountChanged?.call(-1);
    try {
      await _comments.deleteComment(comment.id);
    } catch (e) {
      onCommentCountChanged?.call(1);
      if (!isClosed) {
        emit(
          state.copyWith(
            comments: before.comments,
            children: before.children,
            root: before.root,
            collapsed: before.collapsed,
            post: before.post,
          ),
        );
      }
      _fail(e);
    }
  }

  Future<void> togglePostLike() async {
    final post = state.post;
    if (post == null) return;
    final liked = !post.likedByMe;
    emit(
      state.copyWith(
        post: post.copyWith(likedByMe: liked, likeCount: post.likeCount + (liked ? 1 : -1)),
      ),
    );
    try {
      liked ? await _feed.likePost(post.id) : await _feed.unlikePost(post.id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(post: post));
      _fail(e);
    }
  }

  Future<void> togglePostBookmark() async {
    final post = state.post;
    final bookmarks = _bookmarks;
    if (post == null || bookmarks == null) return;
    final next = !post.isBookmarked;
    emit(state.copyWith(post: post.copyWith(isBookmarked: next)));
    try {
      final saved = await bookmarks.setBookmarked(post.id, bookmarked: next);
      final current = state.post;
      if (saved != next && current != null && !isClosed) {
        emit(state.copyWith(post: current.copyWith(isBookmarked: saved)));
      }
    } catch (e) {
      final current = state.post;
      if (current != null && !isClosed) emit(state.copyWith(post: current.copyWith(isBookmarked: post.isBookmarked)));
      _fail(e);
    }
  }

  Future<bool> editPost(Post post, String body) async {
    final edits = _edits;
    final text = body.trim();
    if (edits == null || text.isEmpty) return false;
    try {
      final updated = await edits.editPost(post.id, text);
      if (!isClosed) emit(state.copyWith(post: updated));
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> editComment(ThreadComment comment, String body) async {
    final edits = _edits;
    final text = body.trim();
    if (edits == null || text.isEmpty) return false;
    try {
      final updated = await edits.editComment(comment.id, text);
      final known = state.comments[comment.id] ?? comment;
      _replace(
        known.copyWith(
          body: updated.body,
          editedAt: updated.editedAt ?? DateTime.now().toUtc(),
          moderationStatus: updated.moderationStatus,
        ),
      );
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> deletePost() async {
    try {
      await _feed.deletePost(postId);
      return true;
    } catch (e) {
      _fail(e);
      return false;
    }
  }

  void _listen() {
    _commentEvents ??= _comments.watchComments(postId).listen(_onCommentEvent, onError: (Object _) {});
    _postEvents ??= _feed.watchPosts(postId: postId).listen((change) {
      final post = state.post;
      if (isClosed || post == null || change is! PostUpdated) return;
      emit(
        state.copyWith(
          post: post.copyWith(likeCount: change.likeCount, commentCount: change.commentCount),
        ),
      );
    }, onError: (Object _) {});
  }

  Future<void> _onCommentEvent(String commentId) async {
    try {
      final rows = await _comments.getThread(
        postId,
        rootCommentId: commentId,
        maxDepth: 0,
        limit: 1,
        repliesLimit: 0,
        includeRoot: true,
      );
      final comment = rows.where((c) => c.id == commentId).firstOrNull;
      if (comment == null || isClosed) return;
      if (comment.isDeleted) {
        if (state.comments.containsKey(commentId)) emit(_liftDeletedComment(state, commentId));
        return;
      }

      final known = state.comments[commentId];
      if (known != null) {
        _replace(comment.copyWith(likedByMe: known.likedByMe));
        return;
      }

      final parentKey = comment.parentId ?? topLevelKey;
      if (parentKey == topLevelKey || parentKey == state.rootKey) {
        if (state.root != null && parentKey != state.rootKey) return;
        final newest = _ordered(state) && state.sort == CommunityCommentSort.latest;
        if (newest || !state.hasMoreTop) emit(_merge(state, [comment], prepend: newest));
        return;
      }
      final parent = state.comments[parentKey];
      if (parent == null) return;
      final loadedAll = (state.children[parentKey]?.length ?? 0) >= parent.replyCount;
      final withCount = _bumpReplyCount(state, parentKey, 1);
      emit(loadedAll && state.levelOf(comment) < maxLevels ? _merge(withCount, [comment]) : withCount);
    } on CommunityException catch (e) {
      if (!isClosed && e.code == 'comment_not_found' && state.comments.containsKey(commentId)) {
        emit(_liftDeletedComment(state, commentId));
      }
    } catch (_) {}
  }

  ThreadState _merge(ThreadState base, List<ThreadComment> list, {bool prepend = false}) {
    final comments = {...base.comments};
    final children = {
      for (final e in base.children.entries) e.key: [...e.value],
    };
    final rootId = base.root?.id;
    final ordered = _ordered(base);
    for (final c in list) {
      comments[c.id] = c;
      if (c.id == rootId) continue;
      final key = c.parentId ?? topLevelKey;
      final siblings = children.putIfAbsent(key, () => []);
      if (siblings.contains(c.id)) continue;
      if (ordered && prepend && key == base.rootKey) {
        siblings.insert(0, c.id);
      } else {
        siblings.add(c.id);
      }
    }
    for (final entry in children.entries) {
      if (ordered && entry.key == base.rootKey) continue;
      entry.value.sort((a, b) => comments[a]!.path.compareTo(comments[b]!.path));
    }
    var merged = base.copyWith(comments: comments, children: children);
    final deleted = [
      for (final c in list)
        if (c.isDeleted) c,
    ]..sort((a, b) => b.depth.compareTo(a.depth));
    for (final c in deleted) {
      merged = _liftDeletedComment(merged, c.id, adjustCounts: false);
    }
    return merged;
  }

  List<ThreadComment> _topLevelOf(ThreadState s, List<ThreadComment> list) => [
    for (final c in list)
      if ((c.parentId ?? topLevelKey) == s.rootKey && c.id != s.root?.id) c,
  ];

  ThreadState _bumpReplyCount(ThreadState s, String? parentId, int delta) {
    if (parentId == null) return s;
    final parent = s.comments[parentId];
    if (parent == null) return s;
    final updated = parent.copyWith(replyCount: math.max(0, parent.replyCount + delta));
    return s.copyWith(comments: {...s.comments, parentId: updated}, root: s.root?.id == parentId ? updated : s.root);
  }

  void _replace(ThreadComment c) {
    if (isClosed) return;
    emit(state.copyWith(comments: {...state.comments, c.id: c}, root: state.root?.id == c.id ? c : state.root));
  }

  void _setLoading(String key, bool loading) {
    if (isClosed) return;
    final set = {...state.loadingBranches};
    loading ? set.add(key) : set.remove(key);
    emit(state.copyWith(loadingBranches: set));
  }

  void _fail(Object error) {
    if (!isClosed) emit(state.copyWith(actionError: error, actionErrorId: state.actionErrorId + 1));
  }

  @override
  Future<void> close() async {
    await _commentEvents?.cancel();
    await _postEvents?.cancel();
    return super.close();
  }
}

ThreadState _liftDeletedComment(ThreadState s, String commentId, {bool adjustCounts = true}) {
  final gone = s.comments[commentId] ?? (s.root?.id == commentId ? s.root : null);
  if (gone == null) return s;
  final prefix = '${gone.path}.';
  final cut = gone.path.lastIndexOf('.');
  final parentPath = cut < 0 ? null : gone.path.substring(0, cut);
  final isRoot = s.root?.id == commentId;
  final comments = <String, ThreadComment>{};
  for (final entry in s.comments.entries) {
    final c = entry.value;
    if (c.id == commentId) continue;
    if (!c.path.startsWith(prefix)) {
      comments[entry.key] = c;
      continue;
    }
    final rest = c.path.substring(prefix.length);
    comments[entry.key] = c.copyWith(
      parentId: c.parentId == commentId ? gone.parentId : c.parentId,
      path: parentPath == null ? rest : '$parentPath.$rest',
      depth: math.max(0, c.depth - 1),
    );
  }
  final parentKey = isRoot ? topLevelKey : gone.parentId ?? topLevelKey;
  final kids = s.children[commentId] ?? const <String>[];
  final children = <String, List<String>>{
    for (final e in s.children.entries)
      if (e.key != commentId) e.key: [...e.value],
  };
  final siblings = children.putIfAbsent(isRoot ? topLevelKey : parentKey, () => []);
  final at = siblings.indexOf(commentId);
  if (at >= 0) {
    siblings
      ..removeAt(at)
      ..insertAll(at, kids.where((k) => !siblings.contains(k)));
  } else {
    siblings.addAll(kids.where((k) => !siblings.contains(k)));
  }
  final sortSiblings = s.sort == CommunityCommentSort.oldest || parentKey != s.rootKey;
  if (sortSiblings) siblings.sort((a, b) => (comments[a]?.path ?? '').compareTo(comments[b]?.path ?? ''));
  final parent = comments[gone.parentId];
  if (adjustCounts && parent != null) {
    comments[parent.id] = parent.copyWith(replyCount: math.max(0, parent.replyCount - 1 + gone.replyCount));
  }
  final root = isRoot ? null : (s.root == null ? null : comments[s.root!.id] ?? s.root);
  return s.copyWith(
    comments: comments,
    children: children,
    root: root,
    collapsed: {...s.collapsed}..remove(commentId),
    loadingBranches: {...s.loadingBranches}..remove(commentId),
    replyTo: s.replyTo?.id == commentId ? null : s.replyTo,
  );
}

sealed class ThreadRow {
  const ThreadRow(this.level);

  final int level;
}

class CommentRow extends ThreadRow {
  const CommentRow(
    this.comment,
    super.level, {
    required this.collapsed,
    this.hasVisibleReplies = false,
    this.isLastSibling = false,
  });
  final ThreadComment comment;
  final bool collapsed;
  final bool hasVisibleReplies;
  final bool isLastSibling;
}

class MoreRepliesRow extends ThreadRow {
  const MoreRepliesRow(this.parentId, super.level, {required this.remaining, required this.loading});
  final String parentId;
  final int remaining;
  final bool loading;
}

class ContinueThreadRow extends ThreadRow {
  const ContinueThreadRow(this.comment, super.level);
  final ThreadComment comment;
}

class MoreTopLevelRow extends ThreadRow {
  const MoreTopLevelRow({required this.loading}) : super(0);
  final bool loading;
}

List<ThreadRow> buildThreadRows(ThreadState state, {required int maxLevels}) {
  final rows = <ThreadRow>[];

  void visit(String id, int level, {required bool last}) {
    final c = state.comments[id];
    if (c == null) return;
    final collapsed = state.collapsed.contains(id);
    final kids = state.children[id] ?? const [];
    final deep = level + 1 >= maxLevels;
    final remaining = c.replyCount - kids.length;
    final visibleReplies = !collapsed && (deep ? c.replyCount > 0 : kids.isNotEmpty || remaining > 0);
    rows.add(CommentRow(c, level, collapsed: collapsed, hasVisibleReplies: visibleReplies, isLastSibling: last));
    if (collapsed) return;

    if (deep) {
      if (c.replyCount > 0) rows.add(ContinueThreadRow(c, level + 1));
      return;
    }
    for (final (index, k) in kids.indexed) {
      visit(k, level + 1, last: index == kids.length - 1 && remaining <= 0);
    }
    if (remaining > 0) {
      rows.add(MoreRepliesRow(id, level + 1, remaining: remaining, loading: state.loadingBranches.contains(id)));
    }
  }

  final top = state.children[state.rootKey] ?? const <String>[];
  for (final (index, id) in top.indexed) {
    visit(id, 0, last: index == top.length - 1 && !state.hasMoreTop);
  }
  if (state.hasMoreTop) rows.add(MoreTopLevelRow(loading: state.loadingBranches.contains(topLevelKey)));
  return rows;
}
