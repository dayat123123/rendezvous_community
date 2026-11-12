import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/realtime_gateway.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/feed/data/local/feed_local_cache.dart';
import 'package:rendezvous_community/src/features/feed/data/models/feed_post_model.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_filter.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_sort.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/pinned_post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/shared/data/models/attachment_model.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class FeedRepositoryImpl implements FeedRepository, FeedQueryRepository, FeedFilterRepository {
  FeedRepositoryImpl(this._api, [this._realtime, this._cache, DateTime Function()? clock])
    : _clock = clock ?? DateTime.now;

  static const _filtersMaxAge = Duration(minutes: 5);

  final SocialRemoteDataSource _api;
  final RealtimeGateway? _realtime;
  final FeedLocalCache? _cache;
  final DateTime Function() _clock;
  List<FeedFilter>? _filters;
  DateTime? _filtersAt;
  Future<List<FeedFilter>>? _filtersLoading;

  @override
  Future<List<FeedFilter>> getFeedFilters({bool refresh = false}) {
    final cached = _filters;
    final at = _filtersAt;
    if (!refresh && cached != null && at != null && _clock().difference(at) < _filtersMaxAge) {
      return Future.value(cached);
    }
    return _filtersLoading ??= _loadFilters().whenComplete(() => _filtersLoading = null);
  }

  Future<List<FeedFilter>> _loadFilters() async {
    List<FeedFilter> filters;
    try {
      final rows = await _api.rpcRows('get_feed_filters', const {});
      filters = [for (final row in rows) ?_filterFromRow(row)];
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202') rethrow;
      CommunityLoggers.feed.event(
        Level.INFO,
        'Server has no feed filter tabs yet, using the built-in tabs',
        fields: {'code': e.code},
      );
      filters = [
        for (final f in builtInFeedFilters)
          if (f.content != FeedFilterContent.poll) f,
      ];
    }
    _filters = filters;
    _filtersAt = _clock();
    return filters;
  }

  static FeedFilter? _filterFromRow(Map<String, dynamic> row) {
    final key = row['key'];
    if (key is! String || key.isEmpty) return null;
    return FeedFilter(
      key: key,
      labelEn: row['label_en'] as String? ?? key,
      labelId: row['label_id'] as String? ?? row['label_en'] as String? ?? key,
      sort: row['sort'] == CommunityFeedSort.top.wire ? CommunityFeedSort.top : CommunityFeedSort.latest,
      content: row['content'] as String?,
      icon: row['icon'] as String?,
      position: (row['position'] as num?)?.toInt() ?? 0,
    );
  }

  FeedFilter? _knownFilter(String key) {
    for (final f in [...?_filters, ...builtInFeedFilters]) {
      if (f.key == key) return f;
    }
    return null;
  }

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) =>
      queryFeed(scope, cursor: cursor, limit: limit);

  @override
  Future<Paged<Post>> queryFeed(
    FeedScope scope, {
    CommunityFeedSort sort = CommunityFeedSort.latest,
    bool mediaOnly = false,
    String? filter,
    String? cursor,
    int limit = 20,
  }) async {
    if (filter != null) return _queryFiltered(scope, filter, cursor: cursor, limit: limit);
    List<Map<String, dynamic>> rows;
    try {
      rows = await _api.rpcRows(
        'get_feed',
        _feedParams(scope, sort: sort, mediaOnly: mediaOnly, cursor: cursor, limit: limit),
      );
    } on CommunityException catch (e) {
      final legacy = _legacyScope(scope);
      if (legacy == null || (e.code != 'PGRST202' && e.code != 'invalid_scope')) rethrow;
      CommunityLoggers.feed.event(
        Level.INFO,
        'Server does not support feed filters, using the legacy feed',
        fields: {'scope': _scopeWire(scope), 'sort': sort.wire, 'media_only': mediaOnly, 'code': e.code},
      );
      rows = await _api.rpcRows('get_feed', _feedParams(legacy, cursor: cursor, limit: limit));
      if (mediaOnly) rows = rows.where(_hasMedia).toList();
    }
    final posts = [for (final row in rows) FeedPostModel.fromJson(row).toEntity()];
    if (cursor == null && sort == CommunityFeedSort.latest && !mediaOnly) await _cache?.saveFirstPage(scope, rows);
    return Paged(posts, nextCursor: posts.length < limit ? null : posts.last.cursor);
  }

  Future<Paged<Post>> _queryFiltered(FeedScope scope, String filter, {String? cursor, required int limit}) async {
    try {
      final rows = await _api.rpcRows('get_feed', {
        ..._feedParams(scope, cursor: cursor, limit: limit),
        'p_filter': filter,
      });
      final posts = [for (final row in rows) FeedPostModel.fromJson(row).toEntity()];
      return Paged(posts, nextCursor: posts.length < limit ? null : posts.last.cursor);
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202') rethrow;
      final known = _knownFilter(filter);
      final derivable = known != null && (known.content == null || known.content == FeedFilterContent.media);
      CommunityLoggers.feed.event(
        Level.INFO,
        derivable
            ? 'Server does not support feed filter tabs, deriving sort and media from the filter'
            : 'Server does not support this feed filter, using the latest feed',
        fields: {'scope': _scopeWire(scope), 'filter': filter, 'code': e.code},
      );
      if (!derivable) return queryFeed(scope, cursor: cursor?.startsWith('o:') ?? false ? null : cursor, limit: limit);
      return queryFeed(
        scope,
        sort: known.sort,
        mediaOnly: known.content == FeedFilterContent.media,
        cursor: cursor,
        limit: limit,
      );
    }
  }

  static Map<String, Object?> _feedParams(
    FeedScope scope, {
    CommunityFeedSort sort = CommunityFeedSort.latest,
    bool mediaOnly = false,
    String? cursor,
    required int limit,
  }) => {
    'p_scope': _scopeWire(scope),
    'p_stock_code': scope is StockFeedScope ? scope.code : null,
    'p_cursor': cursor,
    'p_limit': limit,
    'p_author_id': scope is UserFeedScope ? scope.userId : null,
    if (sort != CommunityFeedSort.latest) 'p_sort': sort.wire,
    if (mediaOnly) 'p_media_only': true,
    if (scope is StocksFeedScope) 'p_stock_codes': [for (final code in scope.codes) code.toUpperCase()],
  };

  static String _scopeWire(FeedScope scope) => switch (scope) {
    GlobalFeedScope() => 'global',
    FollowingFeedScope() => 'following',
    StockFeedScope() => 'stock',
    UserFeedScope() => 'user',
    StocksFeedScope() => 'stocks',
    OfficialFeedScope() => 'official',
    ForYouFeedScope() => 'for_you',
  };

  static FeedScope? _legacyScope(FeedScope scope) => switch (scope) {
    ForYouFeedScope() => const FeedScope.global(),
    StocksFeedScope() || OfficialFeedScope() => null,
    _ => scope,
  };

  static bool _hasMedia(Map<String, dynamic> row) => switch (row['attachments']) {
    final List<dynamic> items => items.any((a) => a is Map && a['path'] is String),
    _ => false,
  };

  @override
  Future<Post?> getPost(String postId) async {
    final rows = await _api.rpcRows('get_post', {'p_post_id': postId});
    return rows.isEmpty ? null : FeedPostModel.fromJson(rows.first).toEntity();
  }

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async {
    final params = switch (scope) {
      GlobalFeedScope() || ForYouFeedScope() => <String, Object?>{'p_scope': 'global'},
      StockFeedScope(:final code) => <String, Object?>{'p_scope': 'stock', 'p_stock_code': code},
      _ => null,
    };
    if (params == null) return const [];
    final rows = await _api.rpcRows('get_pinned_posts', params);
    return [
      for (final row in rows)
        if (row['post'] is Map<String, dynamic>)
          PinnedPost(
            post: FeedPostModel.fromJson(row['post'] as Map<String, dynamic>).toEntity(),
            announcement: row['kind'] == 'announcement',
            title: row['title'] as String?,
            pinnedUntil: DateTime.tryParse(row['pinned_until'] as String? ?? ''),
          ),
    ];
  }

  @override
  Future<Post> createPost({
    required String body,
    Sentiment? sentiment,
    List<Attachment> attachments = const [],
    PollDraft? poll,
    String? clientId,
  }) async {
    final rows = await _api.rpcRows('create_post', {
      'p_body': body,
      'p_sentiment': sentiment?.name,
      'p_attachments': [for (final a in attachments) AttachmentModel.fromEntity(a).toJson()],
      'p_client_id': clientId ?? _uuid.v4(),
      'p_poll': poll == null ? null : {'options': poll.cleanOptions, 'duration_minutes': poll.duration.minutes},
    });
    if (rows.isEmpty) throw const CommunityException(CommunityErrorKind.notFound);
    return FeedPostModel.fromJson(rows.first).toEntity();
  }

  @override
  Future<void> deletePost(String postId) => _api.rpcValue('delete_post', {'p_post_id': postId});

  @override
  Future<void> likePost(String postId) async {
    final userId = await _api.requireUserId();
    await _api.insertIgnoringDuplicate('reactions', {
      'user_id': userId,
      'target_type': 'post',
      'target_id': postId,
      'type': 'like',
    });
  }

  @override
  Future<void> unlikePost(String postId) async {
    final userId = await _api.requireUserId();
    await _api.delete('reactions', {'user_id': userId, 'target_type': 'post', 'target_id': postId});
  }

  @override
  Stream<PostChange> watchPosts({String? postId}) {
    final realtime = _realtime;
    if (realtime == null) return const Stream.empty();
    return realtime
        .tableChanges(
          table: 'posts',
          filter: postId == null
              ? null
              : PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: postId),
        )
        .map(_toPostChange)
        .where((c) => c != null)
        .cast<PostChange>();
  }

  PostChange? _toPostChange(PostgresChangePayload payload) {
    switch (payload.eventType) {
      case PostgresChangeEvent.insert:
        final row = PostRowModel.fromJson(payload.newRecord);
        if (row.deletedAt != null) return null;
        return PostInserted(
          row.id,
          authorId: row.authorId,
          body: row.body,
          createdAt: row.createdAt,
          hasMedia: row.attachments.any((a) => a is Map && a['path'] is String),
        );
      case PostgresChangeEvent.update:
        final row = PostRowModel.fromJson(payload.newRecord);
        return PostUpdated(
          row.id,
          likeCount: row.likeCount,
          commentCount: row.commentCount,
          deleted: row.deletedAt != null,
        );
      case PostgresChangeEvent.delete:
        final id = payload.oldRecord['id'] as String?;
        return id == null ? null : PostUpdated(id, likeCount: 0, commentCount: 0, deleted: true);
      case PostgresChangeEvent.all:
        return null;
    }
  }
}
