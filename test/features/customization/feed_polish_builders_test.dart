import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/comment_tree.dart';

import '../../support/fakes.dart';

const _rina = UserSummary(id: 'u-rina', username: 'rina', displayName: 'Rina');

class _Profiles extends Fake implements ProfileRepository {
  _Profiles(this.profile);

  final UserProfile profile;

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => profile;

  @override
  Future<Set<String>> officialAccountIds() async => const {};
}

class _EmptyFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => const Paged.empty();

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Deps extends FakeDependencies {
  _Deps(this.profileRepository) : super(feed: _EmptyFeed());

  final ProfileRepository profileRepository;

  @override
  ProfileRepository get profiles => profileRepository;
}

UserProfile _profile({bool isMe = false}) => UserProfile(
  user: _rina,
  bio: 'Analis',
  followerCount: 12400,
  followingCount: 180,
  postCount: 342,
  createdAt: DateTime.utc(2026),
  isMe: isMe,
  isFollowing: false,
  followsMe: false,
  isBlocked: false,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  CommunityBuilders builders = const CommunityBuilders(),
  CommunityDependencies? deps,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: CommunityScope(
          dependencies: deps ?? FakeDependencies(),
          child: CommunityBuildersScope(builders: builders, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _LikeToggle extends StatefulWidget {
  const _LikeToggle();

  @override
  State<_LikeToggle> createState() => _LikeToggleState();
}

class _LikeToggleState extends State<_LikeToggle> {
  bool _active = false;

  @override
  Widget build(BuildContext context) => Center(
    child: CommunityActionPill(
      icon: Icons.favorite_border_rounded,
      label: 'Suka',
      active: _active,
      onPressed: () => setState(() => _active = !_active),
    ),
  );
}

void main() {
  group('profile header', () {
    testWidgets('shows compact stats with full semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const CommunityUserProfile(userId: 'u-rina'), deps: _Deps(_Profiles(_profile())));
      expect(find.textContaining('12,4'), findsOneWidget);
      expect(find.text('Pengikut'), findsOneWidget);
      expect(find.text('342'), findsOneWidget);
      expect(find.bySemanticsLabel('12400 pengikut'), findsOneWidget);
      expect(find.text('Ikuti'), findsOneWidget);
      expect(find.text('Kirim pesan'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('messageButton builder replaces the message action', (tester) async {
      CommunityProfileDetails? seen;
      await _pump(
        tester,
        CommunityUserProfile(
          userId: 'u-rina',
          builders: CommunityProfileBuilders(
            messageButton: (context, d, fallback) {
              seen = d;
              return TextButton(onPressed: d.onMessage, child: const Text('dm custom'));
            },
          ),
        ),
        deps: _Deps(_Profiles(_profile())),
      );
      expect(find.text('dm custom'), findsOneWidget);
      expect(find.text('Kirim pesan'), findsNothing);
      expect(seen!.onMessage, isNotNull);
    });

    test('messageButton survives merge', () {
      Widget a(BuildContext context, CommunityProfileDetails d, Widget fallback) => fallback;
      expect(CommunityProfileBuilders(messageButton: a).merge(const CommunityProfileBuilders()).messageButton, a);
      expect(const CommunityProfileBuilders().merge(CommunityProfileBuilders(messageButton: a)).messageButton, a);
    });
  });

  group('compose', () {
    testWidgets('composeAuthor builder receives the current user', (tester) async {
      CommunityComposeAuthorDetails? seen;
      await _pump(
        tester,
        const Material(child: CommunityComposePost()),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            composeAuthor: (context, d, fallback) {
              seen = d;
              return Text('author ${d.user.username}');
            },
          ),
        ),
      );
      expect(find.text('author ${me.username}'), findsOneWidget);
      expect(seen!.sentiment, isNull);
      expect(find.text('Tambah gambar'), findsOneWidget);
      expect(find.text('Tambah polling'), findsOneWidget);
    });

    testWidgets('default author header shows name and username', (tester) async {
      await _pump(tester, const Material(child: CommunityComposePost()));
      expect(find.text('@${me.username}'), findsOneWidget);
    });
  });

  group('comments', () {
    testWidgets('comment builder receives the thread level', (tester) async {
      final levels = <String, int>{};
      await _pump(
        tester,
        const CommunityPostDetail(postId: 'p-1'),
        builders: CommunityBuilders(
          feed: CommunityFeedBuilders(
            comment: (context, d, fallback) {
              levels[d.comment.body ?? ''] = d.level;
              return fallback;
            },
          ),
        ),
      );
      expect(levels['Level 1'], 0);
      expect(levels['Level 2'], 1);
      expect(levels['Level 3'], 2);
    });

    testWidgets('reply indentation uses thin lines', (tester) async {
      await _pump(tester, const CommunityPostDetail(postId: 'p-1'));
      final paint = tester.widget<CustomPaint>(
        find
            .ancestor(
              of: find.text('Level 2'),
              matching: find.byWidgetPredicate((w) => w is CustomPaint && w.painter is ThreadLinesPainter),
            )
            .first,
      );
      expect((paint.painter! as ThreadLinesPainter).strokeWidth, 1);
    });
  });

  group('shared polish', () {
    testWidgets('empty view shows an optional title above the message', (tester) async {
      CommunityEmptyViewDetails? seen;
      await _pump(tester, const CommunityEmptyView(title: 'Kosong', message: 'Belum ada post.'));
      expect(find.text('Kosong'), findsOneWidget);
      expect(find.text('Belum ada post.'), findsOneWidget);
      await _pump(
        tester,
        const CommunityEmptyView(title: 'Kosong', message: 'Belum ada post.'),
        builders: CommunityBuilders(
          shared: CommunitySharedBuilders(
            emptyView: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
      );
      expect(seen!.title, 'Kosong');
    });

    testWidgets('avatar ring color reaches the builder and keeps the size', (tester) async {
      CommunityAvatarDetails? seen;
      await _pump(
        tester,
        const Center(
          child: CommunityAvatar(user: _rina, radius: 20, ringColor: Color(0xFF0000FF)),
        ),
        builders: CommunityBuilders(
          shared: CommunitySharedBuilders(
            avatar: (context, d, fallback) {
              seen = d;
              return fallback;
            },
          ),
        ),
      );
      expect(seen!.ringColor, const Color(0xFF0000FF));
      expect(tester.getSize(find.byType(CommunityAvatar)), const Size(40, 40));
    });

    testWidgets('liking bumps the icon once and settles', (tester) async {
      await _pump(tester, const _LikeToggle());
      await tester.tap(find.text('Suka'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final bump = find.descendant(of: find.byType(CommunityBump), matching: find.byType(ScaleTransition));
      final mid = tester.widget<ScaleTransition>(bump).scale.value;
      expect(mid, greaterThan(1));
      await tester.pumpAndSettle();
      expect(tester.widget<ScaleTransition>(bump).scale.value, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('liking does not animate when animations are disabled', (tester) async {
      await _pump(tester, const _LikeToggle(), disableAnimations: true);
      await tester.tap(find.text('Suka'));
      await tester.pump();
      expect(find.descendant(of: find.byType(CommunityBump), matching: find.byType(ScaleTransition)), findsNothing);
    });
  });
}
