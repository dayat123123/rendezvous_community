import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/legal_fakes.dart';

const _rina = UserSummary(id: 'u-rina', username: 'rinatrades', displayName: 'Rina Kusuma');
const _research = UserSummary(id: 'u-res', username: 'rendezvous', displayName: 'Rendezvous Research');
const _ardi = UserSummary(id: 'u-ardi', username: 'ardiw', displayName: 'Ardi Wibowo');

class _Profiles extends Fake implements ProfileRepository, SuggestedUsersRepository {
  _Profiles({this.failFollow = false});

  final bool failFollow;
  final followed = <String>[];
  final unfollowed = <String>[];
  int? requestedLimit;

  @override
  Future<List<SuggestedUser>> suggestedUsers({int limit = 5}) async {
    requestedLimit = limit;
    return const [
      SuggestedUser(user: _rina, mutualCount: 2, followerCount: 340),
      SuggestedUser(user: _research, isOfficial: true, followerCount: 12000),
      SuggestedUser(user: _ardi, followerCount: 87),
    ];
  }

  @override
  Future<void> follow(String userId) async {
    if (failFollow) throw const CommunityException(CommunityErrorKind.network);
    followed.add(userId);
  }

  @override
  Future<void> unfollow(String userId) async => unfollowed.add(userId);

  @override
  Future<Set<String>> officialAccountIds() async => const {};
}

class _PlainProfiles extends Fake implements ProfileRepository {}

Future<void> _pumpSuggestions(WidgetTester tester, ProfileRepository profiles, {Widget? child}) => pumpCommunity(
  tester,
  child ?? const SingleChildScrollView(child: CommunitySuggestedUsers(limit: 3)),
  dependencies: FakeDependencies(profiles: profiles),
);

Future<FakeFeatureDependencies> _pumpInsights(WidgetTester tester, Widget child) async {
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  features.trending.market = const {
    TrendWindow.day: SentimentBreakdown(posts: 120, bullishPct: 62, bearishPct: 30, neutralPct: 8),
    TrendWindow.week: SentimentBreakdown(posts: 640, bullishPct: 35, bearishPct: 55, neutralPct: 10),
  };
  features.trending.stats = const {
    'BBCA': StockStats(code: 'BBCA', postsToday: 14, bullishPct: 70),
    'TLKM': StockStats(code: 'TLKM', postsToday: 3),
  };
  await pumpFeatureApp(tester, child, features: features);
  await tester.pumpAndSettle();
  return features;
}

void main() {
  group('CommunitySuggestedUsers', () {
    testWidgets('lists suggestions with why each one is suggested', (tester) async {
      final profiles = _Profiles();
      await _pumpSuggestions(tester, profiles);

      expect(profiles.requestedLimit, 3);
      expect(find.text('Akun untuk diikuti'), findsOneWidget);
      expect(find.text('Rina Kusuma'), findsOneWidget);
      expect(find.text('Diikuti 2 akun yang Anda ikuti'), findsOneWidget);
      expect(find.text('Akun resmi'), findsOneWidget);
      expect(find.text('87 pengikut'), findsOneWidget);
    });

    testWidgets('follow toggles to Following and back', (tester) async {
      final profiles = _Profiles();
      await _pumpSuggestions(tester, profiles);

      await tester.tap(find.bySemanticsLabel('Ikuti Rina Kusuma'));
      await tester.pumpAndSettle();
      expect(profiles.followed, ['u-rina']);
      expect(find.bySemanticsLabel('Mengikuti Rina Kusuma'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Mengikuti Rina Kusuma'));
      await tester.pumpAndSettle();
      expect(profiles.unfollowed, ['u-rina']);
      expect(find.bySemanticsLabel('Ikuti Rina Kusuma'), findsOneWidget);
    });

    testWidgets('a failed follow is rolled back', (tester) async {
      await _pumpSuggestions(tester, _Profiles(failFollow: true));

      await tester.tap(find.bySemanticsLabel('Ikuti Ardi Wibowo'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Ikuti Ardi Wibowo'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('row and followButton builders can replace the defaults', (tester) async {
      final rows = <String>[];
      await _pumpSuggestions(
        tester,
        _Profiles(),
        child: CommunitySuggestedUsers(
          builders: CommunityDiscoveryBuilders(
            suggestedUser: (context, d, fallback) {
              rows.add('${d.user.username}:${d.subtitle}');
              return fallback;
            },
            suggestedFollowButton: (context, d, fallback) =>
                TextButton(onPressed: d.onToggleFollow, child: Text(d.following ? 'ok' : '+ ${d.user.username}')),
          ),
        ),
      );

      expect(rows, contains('rinatrades:Diikuti 2 akun yang Anda ikuti'));
      expect(find.text('+ rinatrades'), findsOneWidget);
      await tester.tap(find.text('+ rinatrades'));
      await tester.pumpAndSettle();
      expect(find.text('ok'), findsOneWidget);
    });

    testWidgets('renders nothing when the profile repository has no suggestions', (tester) async {
      await _pumpSuggestions(tester, _PlainProfiles());

      expect(find.text('Akun untuk diikuti'), findsNothing);
    });
  });

  group('CommunityMarketSentiment', () {
    testWidgets('shows the leaning, the share and the post count', (tester) async {
      await _pumpInsights(tester, const CommunityMarketSentiment());

      expect(find.text('Mood pasar'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);
      expect(find.text('Cenderung bullish'), findsOneWidget);
      expect(find.text('Dari 120 post'), findsOneWidget);
      expect(find.text('Netral 8%'), findsOneWidget);
      expect(find.byType(SentimentBar), findsOneWidget);
    });

    testWidgets('switching to 7 days loads that window once', (tester) async {
      final features = await _pumpInsights(tester, const CommunityMarketSentiment());

      await tester.tap(find.text('7 hari'));
      await tester.pumpAndSettle();
      expect(find.text('Cenderung bearish'), findsOneWidget);
      expect(find.text('55%'), findsOneWidget);

      await tester.tap(find.text('24 jam'));
      await tester.pumpAndSettle();
      expect(features.trending.marketRequests, [TrendWindow.day, TrendWindow.week]);
    });

    testWidgets('the marketSentiment builder receives the breakdown', (tester) async {
      CommunityMarketSentimentDetails? seen;
      await _pumpInsights(
        tester,
        CommunityMarketSentiment(
          builders: CommunityDiscoveryBuilders(
            marketSentiment: (context, d, fallback) {
              seen = d;
              return Text('mood ${d.mood?.name}');
            },
          ),
        ),
      );

      expect(find.text('mood bullish'), findsOneWidget);
      expect(seen!.breakdown!.posts, 120);
      expect(seen!.windows, TrendWindow.values);
    });

    test('marketMood needs a clear lead before leaning', () {
      expect(marketMood(const SentimentBreakdown(bullishPct: 55, bearishPct: 45)), Sentiment.bullish);
      expect(marketMood(const SentimentBreakdown(bullishPct: 50, bearishPct: 45)), Sentiment.neutral);
      expect(marketMood(const SentimentBreakdown(bullishPct: 20, bearishPct: 70)), Sentiment.bearish);
      expect(marketMood(const SentimentBreakdown()), isNull);
    });
  });

  testWidgets('CommunityStockStatsBuilder loads stats for the watchlist codes', (tester) async {
    final features = await _pumpInsights(
      tester,
      CommunityStockStatsBuilder(
        codes: const ['bbca', 'TLKM'],
        builder: (context, stats) {
          final l10n = context.communityL10n;
          return Column(
            children: [
              for (final s in stats.values)
                Text(
                  '${s.code} ${l10n.postsToday(s.postsToday)}${s.bullishPct == null ? '' : ' · ${l10n.bullishShare(s.bullishPct!)}'}',
                ),
            ],
          );
        },
      ),
    );

    expect(features.trending.statsRequests.single, ['BBCA', 'TLKM']);
    expect(find.text('BBCA 14 post hari ini · 70% bullish'), findsOneWidget);
    expect(find.text('TLKM 3 post hari ini'), findsOneWidget);
  });
}
