import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/poll_editor.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_feed_list.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_skeletons.dart';

import '../../test/support/fakes.dart';
import '../../test/support/feature_fakes.dart';
import 'screenshot_harness.dart';

const _rina = UserSummary(id: 'u-rina', username: 'rina.invest', displayName: 'Rina Wulandari', isVerified: true);
const _olt = UserSummary(id: 'u-olt', username: 'olt_resmi', displayName: 'OLT Resmi');

final _now = DateTime.now().toUtc();

Post _analysis() => Post(
  id: 'p-1',
  author: _rina,
  body:
      'Apakah \$BBCA masih menarik setelah rilis laporan kuartal III?\n'
      r'Laba bersih $BBCA tumbuh dua digit dan rasio kredit macet turun. Valuasi sudah premium, '
      'jadi saya akumulasi bertahap sambil memantau arah suku bunga, inflasi, dan kebijakan bank sentral. '
      'Rasio NIM masih stabil di kisaran lima persen dan biaya dana turun karena dana murah tumbuh. #perbankan',
  sentiment: Sentiment.bullish,
  stockCodes: const ['BBCA', 'BMRI'],
  hashtags: const ['perbankan'],
  likeCount: 1240,
  commentCount: 38,
  likedByMe: true,
  isBookmarked: true,
  createdAt: _now.subtract(const Duration(hours: 2)),
  cursor: 'p-1',
);

Post _pollPost({bool voted = true}) => Post(
  id: 'p-2',
  author: me,
  body: r'Menurut Anda ke mana arah $TLKM bulan ini?',
  stockCodes: const ['TLKM'],
  likeCount: 12,
  commentCount: 4,
  editedAt: _now.subtract(const Duration(minutes: 20)),
  createdAt: _now.subtract(const Duration(minutes: 45)),
  cursor: 'p-2',
  poll: Poll(
    endsAt: _now.add(const Duration(hours: 20)),
    closed: false,
    totalVotes: voted ? 128 : 0,
    myOptionId: voted ? 'a' : null,
    resultsVisible: voted,
    options: [
      PollOption(id: 'a', label: 'Naik', votes: voted ? 81 : null),
      PollOption(id: 'b', label: 'Turun', votes: voted ? 30 : null),
      PollOption(id: 'c', label: 'Datar', votes: voted ? 17 : null),
    ],
  ),
);

Post _announcement() => Post(
  id: 'p-9',
  author: _olt,
  authorIsOfficial: true,
  body: 'Bursa libur pada 25 Desember. Perdagangan dibuka kembali 26 Desember pukul 09.00 WIB.',
  likeCount: 320,
  commentCount: 12,
  createdAt: _now.subtract(const Duration(days: 1)),
  cursor: 'p-9',
);

Post _linkPost() => Post(
  id: 'p-3',
  author: _rina,
  body: 'Ringkasan rilis kinerja kuartal III, lengkap dengan tabel: https://www.example.co.id/riset/q3',
  likeCount: 54,
  commentCount: 6,
  createdAt: _now.subtract(const Duration(hours: 5)),
  cursor: 'p-3',
);

Post _galleryPost() => Post(
  id: 'p-4',
  author: _olt,
  authorIsOfficial: true,
  body: 'Suasana pembukaan perdagangan hari ini di Gedung Bursa.',
  attachments: [for (var i = 0; i < 6; i++) Attachment(path: 'olt/galeri-$i.jpg', mime: 'image/jpeg')],
  likeCount: 2400,
  commentCount: 132,
  createdAt: _now.subtract(const Duration(hours: 3)),
  cursor: 'p-4',
);

class _PendingMedia extends Fake implements MediaRepository {
  @override
  Future<AuthorizedImage> attachmentImage(Attachment attachment) => Completer<AuthorizedImage>().future;
}

class _ScreenFeed extends FakeFeedRepository {
  _ScreenFeed(this.posts, {this.pinned = const []});

  final List<Post> posts;
  final List<PinnedPost> pinned;

  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => Paged(posts);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => pinned;
}

class _SortedComments extends FakeCommentRepository implements SortedCommentRepository {
  @override
  Future<List<ThreadComment>> getSortedThread(
    String postId, {
    required CommunityCommentSort sort,
    String? cursor,
    int maxDepth = 3,
    int limit = 20,
    int repliesLimit = 3,
  }) => getThread(postId, maxDepth: maxDepth, cursor: cursor, limit: limit, repliesLimit: repliesLimit);
}

class _ScreenProfiles extends Fake implements ProfileRepository {
  _ScreenProfiles(this.profile);

  final UserProfile profile;

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => profile;

  @override
  Future<Set<String>> officialAccountIds() async => const {};
}

class _SuggestProfiles extends Fake implements ProfileRepository, SuggestedUsersRepository {
  @override
  Future<List<SuggestedUser>> suggestedUsers({int limit = 5}) async => const [
    SuggestedUser(
      user: UserSummary(id: 'u-res', username: 'rendezvous', displayName: 'Rendezvous Research'),
      isOfficial: true,
      followerCount: 12400,
    ),
    SuggestedUser(user: _rina, mutualCount: 3, followerCount: 860),
    SuggestedUser(
      user: UserSummary(id: 'u-ardi', username: 'ardiw', displayName: 'Ardi Wibowo'),
      followerCount: 214,
    ),
  ];

  @override
  Future<void> follow(String userId) async {}

  @override
  Future<Set<String>> officialAccountIds() async => const {};
}

class _ScreenDeps extends FakeDependencies {
  _ScreenDeps({super.feed, this.profileRepository});

  final ProfileRepository? profileRepository;

  @override
  ProfileRepository get profiles => profileRepository ?? super.profiles;
}

class _Features extends StatefulWidget {
  const _Features({required this.child, this.setup});

  final Widget child;
  final void Function(FakeFeatureDependencies features)? setup;

  @override
  State<_Features> createState() => _FeaturesState();
}

class _FeaturesState extends State<_Features> {
  late final _features = FakeFeatureDependencies(config: loadedConfig());

  @override
  void initState() {
    super.initState();
    widget.setup?.call(_features);
  }

  @override
  void dispose() {
    _features.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CommunityFeatureScope(dependencies: _features, child: widget.child);
}

Widget _scoped(Widget child, {CommunityDependencies? deps, void Function(FakeFeatureDependencies)? setup}) =>
    CommunityScope(
      dependencies: deps ?? FakeDependencies(),
      child: _Features(setup: setup, child: child),
    );

Widget _sized(double height, Widget child) => SizedBox(height: height, child: child);

final feedScenes = <ScreenshotScene>[
  ScreenshotScene(
    'feed_stream',
    (context) => _sized(
      1900,
      _scoped(
        const CommunityStreamFeed(),
        deps: FakeDependencies(
          feed: _ScreenFeed(
            [_analysis(), _galleryPost(), _pollPost()],
            pinned: [PinnedPost(post: _announcement(), announcement: true, title: 'Libur bursa')],
          ),
          mediaRepository: _PendingMedia(),
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'feed_post_card',
    (context) => _scoped(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostCard(post: _analysis(), onLike: () {}, onOpen: () {}, onToggleBookmark: () {}, onShare: () {}),
          SizedBox(height: CommunityStyle.of(context).sectionGap),
          PostCard(post: _galleryPost(), onLike: () {}, onOpen: () {}),
          SizedBox(height: CommunityStyle.of(context).sectionGap),
          PostCard(
            post: _pollPost(voted: false).copyWith(author: _rina),
            onLike: () {},
            onOpen: () {},
          ),
          SizedBox(height: CommunityStyle.of(context).sectionGap),
          PostCard(
            post: _pollPost().copyWith(isBot: true, author: _olt),
            onLike: () {},
            onOpen: () {},
          ),
        ],
      ),
      deps: FakeDependencies(mediaRepository: _PendingMedia()),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'feed_link_preview',
    (context) => _scoped(
      PostCard(post: _linkPost(), onLike: () {}, onOpen: () {}),
      setup: (features) => features.linkPreviewRepository.answer = (url) => LinkPreview(
        url: url,
        status: LinkPreviewStatus.ok,
        siteName: 'Riset Pasar',
        title: 'Kinerja emiten perbankan kuartal III: laba naik, kredit macet turun',
        description: 'Tabel lengkap pertumbuhan kredit, NIM, dan rasio NPL untuk sepuluh bank terbesar.',
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene('feed_inline_comments', (context) {
    final deps = FakeDependencies(feed: _ScreenFeed([_analysis()]), comments: _SortedComments());
    return _sized(
      1150,
      _scoped(
        BlocProvider(
          create: (_) => FeedCubit(feed: deps.feed, scope: const FeedScope.user('u-rina'))
            ..load()
            ..toggleComments('p-1')
            ..commentsFocused('p-1'),
          child: const FeedPostList(emptyMessage: '', postOpenMode: CommunityPostOpenMode.inlineComments),
        ),
        deps: deps,
      ),
    );
  }, padding: EdgeInsets.zero),
  ScreenshotScene(
    'post_thread',
    (context) => _sized(1100, _scoped(const CommunityPostDetail(postId: 'p-1'))),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'compose_post',
    (context) => _sized(620, _scoped(const Material(child: CommunityComposePost()))),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'compose_poll_editor',
    (context) => _scoped(
      BlocProvider(
        create: (_) => ComposeCubit(feed: FakeFeedRepository(), media: FakeDependencies().media),
        child: const Material(
          child: PollEditor(
            poll: PollDraft(options: ['Naik', 'Turun', ''], duration: PollDuration.threeDays),
            enabled: true,
          ),
        ),
      ),
    ),
  ),
  ScreenshotScene(
    'profile_header',
    (context) => _sized(
      760,
      _scoped(
        const CommunityUserProfile(userId: 'u-rina'),
        deps: _ScreenDeps(
          feed: _ScreenFeed([_analysis()]),
          profileRepository: _ScreenProfiles(
            UserProfile(
              user: _rina,
              bio: r'Analis ritel. Fokus pada $BBCA dan sektor perbankan. Bukan rekomendasi.',
              followerCount: 12400,
              followingCount: 180,
              postCount: 342,
              createdAt: _now,
              isMe: false,
              isFollowing: false,
              followsMe: true,
              isBlocked: false,
            ),
          ),
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'search_results',
    (context) => _sized(
      900,
      _scoped(
        const CommunitySearch(initialQuery: 'bank'),
        setup: (features) => features.search.answer = (query, type, cursor) => SearchResults(
          query: query,
          type: type,
          posts: [_analysis()],
          users: const [
            UserSearchResult(user: _rina, followerCount: 12400),
            UserSearchResult(user: _olt, followerCount: 98000, isOfficial: true),
          ],
          stocks: const [StockSearchResult(code: 'BBCA', posts7d: 42, watcherCount: 1200, isWatching: true)],
          hashtags: const [HashtagSummary(tag: 'perbankan', postCount: 18)],
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'search_trending_hashtags',
    (context) => _sized(
      260,
      _scoped(
        const CommunitySearch(),
        setup: (features) => features.search.trending = const [
          HashtagSummary(tag: 'perbankan', postCount: 18),
          HashtagSummary(tag: 'ipo', postCount: 12),
          HashtagSummary(tag: 'dividen', postCount: 9),
          HashtagSummary(tag: 'nikel', postCount: 7),
          HashtagSummary(tag: 'teknologi', postCount: 5),
        ],
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'trending_stocks',
    (context) => _sized(
      520,
      _scoped(
        const CommunityTrending(),
        setup: (features) => features.trending.snapshot = (window) => TrendingSnapshot(
          window: window,
          stocks: const [
            TrendingStock(code: 'BBCA', posts: 128, bullishPct: 64, bearishPct: 18, growthPct: 35),
            TrendingStock(code: 'GOTO', posts: 96, bullishPct: 30, bearishPct: 52, growthPct: 12.5),
            TrendingStock(code: 'TLKM', posts: 41),
          ],
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'trending_rising',
    (context) => _sized(
      400,
      _scoped(
        const CommunityTrending(initialTab: CommunityTrendingTab.rising),
        setup: (features) => features.trending.snapshot = (window) => TrendingSnapshot(
          window: window,
          rising: const [
            RisingStock(code: 'GOTO', posts: 45, prevPosts: 10, growthPct: 350),
            RisingStock(code: 'ANTM', posts: 20, prevPosts: 8, growthPct: 150),
          ],
        ),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
  ScreenshotScene(
    'stock_sentiment',
    (context) => _scoped(
      const Material(child: CommunityStockSentiment(stockCode: 'BBCA')),
      setup: (features) => features.trending.sentiment = const StockSentiment(
        code: 'BBCA',
        day: SentimentBreakdown(posts: 42, bullish: 28, bearish: 9, neutral: 5, bullishPct: 67, bearishPct: 21),
      ),
    ),
  ),
  ScreenshotScene('stream_sidebar', (context) {
    final style = CommunityStyle.of(context);
    final l10n = context.communityL10n;
    Widget panel(Widget child) => Material(
      color: style.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: style.border),
      ),
      child: child,
    );
    return _scoped(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          panel(const CommunityMarketSentiment()),
          const SizedBox(height: 12),
          panel(const CommunitySuggestedUsers()),
          const SizedBox(height: 12),
          panel(
            CommunityStockStatsBuilder(
              codes: const ['BBCA', 'TLKM', 'GOTO'],
              builder: (context, stats) => Column(
                children: [
                  for (final s in stats.values)
                    ListTile(
                      dense: true,
                      title: Text('\$${s.code}', style: style.typography.label),
                      trailing: Text(
                        [
                          l10n.postsToday(s.postsToday),
                          if (s.bullishPct != null) l10n.bullishShare(s.bullishPct!),
                        ].join(' · '),
                        style: style.typography.badge.copyWith(color: style.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      deps: FakeDependencies(profiles: _SuggestProfiles()),
      setup: (features) => features.trending
        ..market = const {
          TrendWindow.day: SentimentBreakdown(posts: 1284, bullishPct: 62, bearishPct: 27, neutralPct: 11),
        }
        ..stats = const {
          'BBCA': StockStats(code: 'BBCA', postsToday: 24, bullishPct: 70),
          'TLKM': StockStats(code: 'TLKM', postsToday: 9, bullishPct: 34),
          'GOTO': StockStats(code: 'GOTO', postsToday: 3),
        },
    );
  }, width: 340),
  ScreenshotScene(
    'stream_compose_top_comment',
    (context) => _scoped(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CommunityComposePromptCard(),
          SizedBox(height: CommunityStyle.of(context).sectionGap),
          PostCard(
            post: _analysis().copyWith(
              topComment: ThreadComment(
                id: 'k-1',
                postId: 'p-1',
                author: const UserSummary(id: 'u-ardi', username: 'ardiw', displayName: 'Ardi Wibowo'),
                body: r'Setuju, support kuat di 9.800. Saya tambah sedikit kalau $BBCA tutup di atas MA20.',
                depth: 0,
                path: '000000000001',
                likeCount: 86,
                createdAt: _now.subtract(const Duration(minutes: 40)),
                cursor: '1',
              ),
            ),
            onLike: () {},
            onOpen: () {},
            onToggleBookmark: () {},
            onShare: () {},
          ),
        ],
      ),
      deps: FakeDependencies(mediaRepository: _PendingMedia()),
    ),
    width: 600,
    padding: EdgeInsets.zero,
  ),
];

class _ScreenStocks implements StockRepository {
  @override
  Future<Stock?> getStock(String code) async => Stock(code: code.toUpperCase(), watcherCount: 1280);

  @override
  Future<void> watch(String code) async {}

  @override
  Future<void> unwatch(String code) async {}
}

final stockScenes = <ScreenshotScene>[
  ScreenshotScene(
    'stock_feed_header',
    (context) => _sized(
      720,
      _scoped(
        const CommunityStockFeed(stockCode: 'bbca', stockName: 'Bank Central Asia Tbk'),
        deps: FakeDependencies(feed: _ScreenFeed([_analysis()]), stocks: _ScreenStocks()),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
];

class _DetailFeed extends FakeFeedRepository {
  @override
  Future<Post?> getPost(String postId) async => _analysis().copyWith(
    attachments: [for (var i = 0; i < 2; i++) Attachment(path: 'olt/detail-$i.jpg', mime: 'image/jpeg')],
    hashtags: const ['perbankan', 'dividen', 'kuartal3'],
  );
}

final detailScenes = <ScreenshotScene>[
  ScreenshotScene(
    'post_detail',
    (context) => _sized(
      1300,
      _scoped(
        const CommunityPostDetail(postId: 'p-1'),
        deps: FakeDependencies(feed: _DetailFeed(), mediaRepository: _PendingMedia()),
      ),
    ),
    padding: EdgeInsets.zero,
  ),
];

final stateScenes = <ScreenshotScene>[
  ScreenshotScene(
    'feed_loading_states',
    (context) => _sized(
      1300,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PostCardSkeleton(media: true),
          const PostThreadSkeleton(),
          SizedBox(
            height: 260,
            child: ColoredBox(
              color: CommunityStyle.of(context).background,
              child: const CommunityEmptyView(
                title: 'Belum ada komentar',
                message: 'Mulai diskusi!',
                icon: Icons.chat_bubble_outline,
              ),
            ),
          ),
        ],
      ),
    ),
    padding: EdgeInsets.zero,
  ),
];
