import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';

import '../../support/fakes.dart';

Post _post({
  int likeCount = 0,
  bool likedByMe = false,
  String? myReaction,
  List<PostReactionCount> summary = const [],
}) => Post(
  id: 'p-1',
  author: alice,
  body: 'Analisis hari ini',
  likeCount: likeCount,
  likedByMe: likedByMe,
  myReaction: myReaction,
  reactionSummary: summary,
  createdAt: now,
  cursor: 'c',
);

PostReactor _reactor(String id, String emoji, {bool isMe = false, bool verified = false}) => PostReactor(
  user: UserSummary(id: id, username: 'user_$id', displayName: 'Nama $id', isVerified: verified),
  emoji: emoji,
  isMe: isMe,
  reactedAt: now,
  cursor: 'cur-$id',
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  FakeFeedRepository? feed,
  Locale locale = const Locale('id'),
  CommunityCallbacks callbacks = const CommunityCallbacks(),
}) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(feed: feed, callbacks: callbacks),
          child: Center(child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _ReactingCard extends StatefulWidget {
  const _ReactingCard({required this.initial, required this.reacted, this.liked});

  final Post initial;
  final List<String?> reacted;
  final List<bool>? liked;

  @override
  State<_ReactingCard> createState() => _ReactingCardState();
}

class _ReactingCardState extends State<_ReactingCard> {
  late Post _post = widget.initial;

  @override
  Widget build(BuildContext context) => PostCard(
    post: _post,
    onLike: () {
      widget.liked?.add(true);
      setState(() => _post = applyPostReaction(_post, _post.effectiveReaction == null ? '👍' : null));
    },
    onReact: (emoji) {
      widget.reacted.add(emoji);
      setState(() => _post = applyPostReaction(_post, emoji));
    },
  );
}

void main() {
  group('summary text', () {
    testWidgets('names me first, otherwise shows the total', (tester) async {
      late CommunityLocalizations id;
      late CommunityLocalizations en;
      await _pump(
        tester,
        Builder(
          builder: (context) {
            id = context.communityL10n;
            return const SizedBox();
          },
        ),
      );
      await _pump(
        tester,
        Builder(
          builder: (context) {
            en = context.communityL10n;
            return const SizedBox();
          },
        ),
        locale: const Locale('en'),
      );
      expect(communityReactionSummaryText(id, count: 1, reactedByMe: true), 'Kamu');
      expect(communityReactionSummaryText(id, count: 4, reactedByMe: true), 'Kamu dan 3 lainnya');
      expect(communityReactionSummaryText(id, count: 4, reactedByMe: false), '4');
      expect(communityReactionSummaryText(en, count: 1, reactedByMe: true), 'You');
      expect(communityReactionSummaryText(en, count: 2, reactedByMe: true), 'You and 1 other');
      expect(communityReactionSummaryText(en, count: 6, reactedByMe: true), 'You and 5 others');
    });

    testWidgets('shows the top three emojis and hides itself without reactions', (tester) async {
      await _pump(
        tester,
        CommunityPostReactionSummary(
          post: _post(
            likeCount: 7,
            likedByMe: true,
            myReaction: '🔥',
            summary: const [
              PostReactionCount(emoji: '🔥', count: 3),
              PostReactionCount(emoji: '👍', count: 2),
              PostReactionCount(emoji: '😂', count: 1),
              PostReactionCount(emoji: '😢', count: 1),
            ],
          ),
          onTap: () {},
        ),
      );
      expect(find.text('Kamu dan 6 lainnya'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('😂'), findsOneWidget);
      expect(find.text('😢'), findsNothing);

      await _pump(tester, CommunityPostReactionSummary(post: _post(), onTap: () {}));
      expect(find.byType(Text), findsNothing);
    });
  });

  group('picker', () {
    testWidgets('reports the chosen emoji and marks my reaction', (tester) async {
      final picked = <String>[];
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        CommunityReactionPicker(choices: defaultPostReactions, selected: '😂', onSelected: picked.add),
      );
      for (final emoji in defaultPostReactions) {
        expect(find.text(emoji), findsOneWidget);
      }
      expect(tester.getSemantics(find.text('😂')), isSemantics(isSelected: true));
      await tester.tap(find.text('❤️'));
      expect(picked, ['❤️']);
      handle.dispose();
    });
  });

  group('like button', () {
    testWidgets('tap likes, long-press opens the picker and the same emoji removes it', (tester) async {
      final reacted = <String?>[];
      final liked = <bool>[];
      await _pump(tester, _ReactingCard(initial: _post(), reacted: reacted, liked: liked));

      await tester.tap(find.text('Suka'));
      await tester.pumpAndSettle();
      expect(liked, [true]);
      expect(find.text('👍'), findsWidgets);

      await tester.longPress(find.text('Suka · 1'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityReactionPicker), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(CommunityReactionPicker), matching: find.text('🔥')));
      await tester.pumpAndSettle();
      expect(reacted, ['🔥']);
      expect(find.byType(CommunityReactionPicker), findsNothing);

      await tester.tap(find.text('Suka · 1'), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      expect(find.byType(CommunityReactionPicker), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(CommunityReactionPicker), matching: find.text('🔥')));
      await tester.pumpAndSettle();
      expect(reacted, ['🔥', null]);
      expect(find.text('Suka'), findsOneWidget);
    });

    testWidgets('hovering with a mouse opens the picker and leaving closes it', (tester) async {
      await _pump(tester, _ReactingCard(initial: _post(), reacted: <String?>[]));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Suka')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CommunityReactionPicker), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CommunityReactionPicker), findsOneWidget);

      await mouse.moveTo(const Offset(5, 1500));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityReactionPicker), findsNothing);
    });

    testWidgets('the action bar builder receives the reaction details', (tester) async {
      CommunityPostDetails? seen;
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final reacted = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: communityLocalizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Scaffold(
            body: CommunityScope(
              dependencies: FakeDependencies(),
              child: CommunityBuildersScope(
                builders: CommunityBuilders(
                  feed: CommunityFeedBuilders(
                    actionBar: (context, d, fallback) {
                      seen = d;
                      return const SizedBox();
                    },
                  ),
                ),
                child: PostCard(
                  post: _post(
                    likeCount: 2,
                    likedByMe: true,
                    myReaction: '😮',
                    summary: const [PostReactionCount(emoji: '😮', count: 2)],
                  ),
                  onLike: () {},
                  onReact: reacted.add,
                ),
              ),
            ),
          ),
        ),
      );
      final d = seen!;
      expect(d.myReaction, '😮');
      expect(d.reactionSummary, const [PostReactionCount(emoji: '😮', count: 2)]);
      expect(d.reactionChoices, defaultPostReactions);
      expect(d.onShowReactors, isNotNull);
      d.onReact!('🔥');
      expect(reacted, ['🔥']);
    });
  });

  group('reactors sheet', () {
    final post = _post(
      likeCount: 3,
      likedByMe: true,
      myReaction: '🔥',
      summary: const [
        PostReactionCount(emoji: '🔥', count: 2),
        PostReactionCount(emoji: '👍', count: 1),
      ],
    );

    testWidgets('lists everyone with tabs per emoji and pages by cursor', (tester) async {
      final feed = FakeReactionFeedRepository()
        ..onReactors = (emoji, cursor) => switch ((emoji, cursor)) {
          (null, null) => PostReactorsPage([
            _reactor('u-1', '🔥', isMe: true),
            _reactor('u-2', '👍', verified: true),
          ], nextCursor: 'cur-u-2'),
          (null, 'cur-u-2') => PostReactorsPage([_reactor('u-3', '🔥')]),
          ('🔥', null) => PostReactorsPage([_reactor('u-1', '🔥', isMe: true), _reactor('u-3', '🔥')]),
          _ => const PostReactorsPage([]),
        };
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka')),
        ),
        feed: feed,
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      expect(find.text('Semua (3)'), findsOneWidget);
      expect(find.text('🔥 2'), findsOneWidget);
      expect(find.text('👍 1'), findsOneWidget);
      expect(find.text('Nama u-1'), findsOneWidget);
      expect(find.text('Nama u-2'), findsOneWidget);
      expect(find.text('Nama u-3'), findsOneWidget);
      expect(find.text('Kamu'), findsOneWidget);
      expect(feed.reactorRequests.map((r) => r.cursor), [null, 'cur-u-2']);

      await tester.tap(find.text('🔥 2'));
      await tester.pumpAndSettle();
      expect(feed.reactorRequests.last.emoji, '🔥');
      expect(feed.reactorRequests.last.cursor, isNull);
    });

    testWidgets('unselected tabs keep the same text size, only lighter', (tester) async {
      final feed = FakeReactionFeedRepository()..onReactors = (emoji, cursor) => const PostReactorsPage([]);
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka')),
        ),
        feed: feed,
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      final bar = tester.widget<TabBar>(find.byType(TabBar));
      expect(bar.unselectedLabelStyle, isNotNull);
      expect(bar.unselectedLabelStyle!.fontSize, bar.labelStyle!.fontSize);
      expect(bar.unselectedLabelStyle!.fontWeight!.value, lessThan(bar.labelStyle!.fontWeight!.value));
    });

    testWidgets('the title sits clear of the sheet edge and the close button', (tester) async {
      final feed = FakeReactionFeedRepository()..onReactors = (emoji, cursor) => const PostReactorsPage([]);
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka')),
        ),
        feed: feed,
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      final view = tester.getRect(find.byKey(const ValueKey('post-reactors')));
      final title = tester.getRect(find.text('Reaksi'));
      expect(title.top - view.top, greaterThanOrEqualTo(16));
      expect(title.left - view.left, greaterThanOrEqualTo(16));
    });

    testWidgets('opening a reactor closes the sheet and opens the profile from the post', (tester) async {
      final feed = FakeReactionFeedRepository()
        ..onReactors = (emoji, cursor) => PostReactorsPage([_reactor('u-2', '👍')]);
      BuildContext? caller;
      BuildContext? opened;
      UserSummary? user;
      await _pump(
        tester,
        Builder(
          builder: (context) {
            caller = context;
            return TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka'));
          },
        ),
        feed: feed,
        callbacks: CommunityCallbacks(
          onUserTap: (context, tapped) {
            opened = context;
            user = tapped;
          },
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nama u-2'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('post-reactors')), findsNothing);
      expect(user?.id, 'u-2');
      expect(identical(opened, caller), isTrue);
    });

    testWidgets('shows an empty state and a friendly error', (tester) async {
      final feed = FakeReactionFeedRepository();
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka')),
        ),
        feed: feed,
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada reaksi'), findsOneWidget);
    });

    testWidgets('an older server without the RPC shows the unavailable message', (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityPostReactors(context, post), child: const Text('buka')),
        ),
      );
      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Reaksi belum tersedia'), findsOneWidget);
    });

    testWidgets('tapping the summary on a card opens the sheet', (tester) async {
      final feed = FakeReactionFeedRepository()
        ..onReactors = (emoji, cursor) => PostReactorsPage([_reactor('u-1', '🔥', isMe: true)]);
      await _pump(
        tester,
        PostCard(post: post, onLike: () {}, onReact: (_) {}),
        feed: feed,
      );
      await tester.tap(find.text('Kamu dan 2 lainnya'));
      await tester.pumpAndSettle();
      expect(find.text('Semua (3)'), findsOneWidget);
    });
  });
}
