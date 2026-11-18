import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/config/data/models/client_config_model.dart';
import 'package:rendezvous_community/src/features/config/data/repositories/banner_dismissal_repository_impl.dart';
import 'package:rendezvous_community/src/features/config/data/repositories/promo_popup_history_repository_impl.dart';
import 'package:rendezvous_community/src/features/config/presentation/cubit/community_banners_cubit.dart';

import '../../support/feature_fakes.dart';

final _now = DateTime.utc(2026, 11, 3, 12);

CommunityBanner _banner(
  String id, {
  int priority = 0,
  bool dismissible = true,
  CommunityBannerLevel level = CommunityBannerLevel.info,
  DateTime? endsAt,
  String? link,
}) => CommunityBanner(
  id: id,
  title: 'Banner $id',
  body: 'Isi $id',
  level: level,
  dismissible: dismissible,
  priority: priority,
  linkUrl: link,
  endsAt: endsAt,
);

void main() {
  test('get_client_config banners are parsed with defaults', () {
    final config = ClientConfigModel.fromJson({
      'social_enabled': true,
      'banners': [
        {
          'id': 'b1',
          'title': 'Pemeliharaan sistem',
          'body': 'Chat dipelihara pukul 22.00 WIB',
          'link_url': 'https://olt.example/status',
          'level': 'warning',
          'dismissible': false,
          'priority': 10,
          'starts_at': '2026-11-03T10:00:00+00:00',
          'ends_at': null,
        },
        {'id': 'b2', 'title': 'Info', 'level': 'unknown'},
        {'title': 'tanpa id'},
      ],
    }).toEntity();

    expect(config.banners, hasLength(2));
    final first = config.banners.first;
    expect(first.level, CommunityBannerLevel.warning);
    expect(first.dismissible, isFalse);
    expect(first.linkUrl, 'https://olt.example/status');
    expect(config.banners.last.level, CommunityBannerLevel.info);
    expect(config.banners.last.dismissible, isTrue);
  });

  test('visible banners respect priority, dismissal, end time and the maximum', () {
    final banners = visibleBanners(
      [
        _banner('low'),
        _banner('ended', priority: 50, endsAt: _now.subtract(const Duration(minutes: 1))),
        _banner('pinned', priority: 9, dismissible: false),
        _banner('high', priority: 10),
        _banner('closed', priority: 20),
      ],
      dismissed: {'closed', 'pinned'},
      now: _now,
      max: 2,
    );
    expect([for (final b in banners) b.id], ['high', 'pinned']);
  });

  test('dismissed ids are stored locally and survive a reload', () async {
    final values = MemoryLocalValues();
    final first = BannerDismissals(BannerDismissalRepositoryImpl(values));
    await first.dismiss('b1');
    final second = BannerDismissals(BannerDismissalRepositoryImpl(values));
    expect(await second.load(), {'b1'});
  });

  testWidgets('CommunityBannerHost shows banners and hides dismissible ones after closing', (tester) async {
    final features = FakeFeatureDependencies(
      config: loadedConfig().copyWith(
        banners: [
          _banner('maint', priority: 5, dismissible: false, level: CommunityBannerLevel.critical),
          _banner('promo', link: 'https://olt.example/promo'),
        ],
      ),
    );
    addTearDown(features.dispose);
    await pumpFeatureApp(tester, const CommunityBannerHost(), features: features);
    await tester.pumpAndSettle();

    expect(find.text('Banner maint'), findsOneWidget);
    expect(find.text('Banner promo'), findsOneWidget);
    expect(find.text('Selengkapnya'), findsOneWidget);
    expect(find.byTooltip('Tutup'), findsOneWidget);

    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Banner promo'), findsNothing);
    expect(find.text('Banner maint'), findsOneWidget);
    expect(await features.bannerDismissals.load(), {'promo'});
  });

  testWidgets('strip banners use the cta label set in the Hub for their link button', (tester) async {
    final features = FakeFeatureDependencies(
      config: loadedConfig().copyWith(
        banners: const [
          CommunityBanner(id: 'promo', title: 'Promo', linkUrl: 'https://olt.example/promo', ctaLabel: 'Ikut sekarang'),
          CommunityBanner(id: 'info', title: 'Info', linkUrl: 'https://olt.example/info'),
        ],
      ),
    );
    addTearDown(features.dispose);
    await pumpFeatureApp(tester, const CommunityBannerHost(), features: features);
    await tester.pumpAndSettle();

    expect(find.text('Ikut sekarang'), findsOneWidget);
    expect(find.text('Selengkapnya'), findsOneWidget);
  });

  test('visible banners can be limited to some levels before the maximum applies', () {
    final banners = visibleBanners(
      [
        _banner('info', priority: 30),
        _banner('warn', priority: 20, level: CommunityBannerLevel.warning),
        _banner('crit', priority: 10, level: CommunityBannerLevel.critical),
        _banner('info2', priority: 40),
      ],
      dismissed: const {},
      now: _now,
      max: 2,
      levels: const {CommunityBannerLevel.warning, CommunityBannerLevel.critical},
    );
    expect([for (final b in banners) b.id], ['warn', 'crit']);
  });

  group('banner levels', () {
    FakeFeatureDependencies mixed() => FakeFeatureDependencies(
      config: loadedConfig().copyWith(
        banners: [
          _banner('info'),
          _banner('warn', level: CommunityBannerLevel.warning),
          _banner('crit', level: CommunityBannerLevel.critical),
        ],
      ),
    );

    testWidgets('CommunityBannerHost levels shows only those levels', (tester) async {
      final features = mixed();
      addTearDown(features.dispose);
      await pumpFeatureApp(
        tester,
        const CommunityBannerHost(levels: {CommunityBannerLevel.warning, CommunityBannerLevel.critical}),
        features: features,
      );
      await tester.pumpAndSettle();

      expect(find.text('Banner info'), findsNothing);
      expect(find.text('Banner warn'), findsOneWidget);
      expect(find.text('Banner crit'), findsOneWidget);
    });

    testWidgets('CommunityBannerScope sets the levels for hosts inside it, such as the feed', (tester) async {
      final features = mixed();
      addTearDown(features.dispose);
      await pumpFeatureApp(
        tester,
        const CommunityBannerScope(
          levels: {CommunityBannerLevel.info},
          child: Column(
            children: [
              CommunityBannerHost(),
              CommunityBannerHost(key: ValueKey('explicit'), levels: {CommunityBannerLevel.critical}),
            ],
          ),
        ),
        features: features,
      );
      await tester.pumpAndSettle();

      expect(find.text('Banner info'), findsOneWidget);
      expect(find.text('Banner warn'), findsNothing);
      expect(
        find.descendant(of: find.byKey(const ValueKey('explicit')), matching: find.text('Banner crit')),
        findsOneWidget,
      );
      expect(find.text('Banner crit'), findsOneWidget);
    });

    testWidgets('a banner closed in one host disappears from the other', (tester) async {
      final features = FakeFeatureDependencies(
        config: loadedConfig().copyWith(banners: [_banner('crit', level: CommunityBannerLevel.critical)]),
      );
      addTearDown(features.dispose);
      await pumpFeatureApp(
        tester,
        const Column(
          children: [
            CommunityBannerHost(key: ValueKey('global'), levels: {CommunityBannerLevel.critical}),
            CommunityBannerHost(key: ValueKey('feed')),
          ],
        ),
        features: features,
      );
      await tester.pumpAndSettle();
      expect(find.text('Banner crit'), findsNWidgets(2));

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('global')), matching: find.byTooltip('Tutup')));
      await tester.pumpAndSettle();

      expect(find.text('Banner crit'), findsNothing);
    });
  });

  group('strip frequency and stats', () {
    CommunityStripViews views(
      MemoryLocalValues values,
      FakeBannerEventRepository events, {
      required DateTime Function() clock,
      String? user = 'u-1',
    }) => CommunityStripViews(
      events,
      PromoPopupHistoryRepositoryImpl(values, prefix: 'banner_strips:'),
      currentUserId: () => user,
      clock: clock,
    );

    Future<List<String>> admitted(CommunityStripViews views, List<CommunityBanner> banners) async {
      if (!views.ready) {
        views.admit(banners, max: 3);
        await Future<void>.delayed(Duration.zero);
      }
      return [for (final banner in views.admit(banners, max: 3)) banner.id];
    }

    test('once shows a strip for the first session only, daily again the next day, every open always', () async {
      final values = MemoryLocalValues();
      final events = FakeBannerEventRepository();
      var now = DateTime(2026, 11, 18, 9);
      final banners = [
        const CommunityBanner(id: 'once', title: 'Sekali'),
        const CommunityBanner(id: 'daily', title: 'Harian', frequency: CommunityBannerFrequency.daily),
        const CommunityBanner(id: 'open', title: 'Selalu', frequency: CommunityBannerFrequency.everyOpen),
      ];

      final first = views(values, events, clock: () => now);
      expect(await admitted(first, banners), ['once', 'daily', 'open']);
      now = now.add(const Duration(hours: 3));
      expect(await admitted(first, banners), ['once', 'daily', 'open']);

      final sameDay = views(values, events, clock: () => now);
      expect(await admitted(sameDay, banners), ['open']);

      now = DateTime(2026, 11, 19, 8);
      final nextDay = views(values, events, clock: () => now);
      expect(await admitted(nextDay, banners), ['daily', 'open']);
    });

    test('hidden strips do not take a slot from the ones still due', () async {
      final values = MemoryLocalValues();
      final events = FakeBannerEventRepository();
      final now = DateTime(2026, 11, 18, 9);
      final banners = [
        for (final id in ['a', 'b', 'c', 'd']) CommunityBanner(id: id, title: id),
      ];
      final first = views(values, events, clock: () => now);
      expect(await admitted(first, banners.take(3).toList()), ['a', 'b', 'c']);
      final second = views(values, events, clock: () => now);
      expect(await admitted(second, banners), ['d']);
    });

    testWidgets('a strip counts one impression per session across hosts, plus clicks and closes', (tester) async {
      final features = FakeFeatureDependencies(
        config: loadedConfig().copyWith(
          banners: [_banner('crit', level: CommunityBannerLevel.critical, link: 'https://olt.example/status')],
        ),
      );
      addTearDown(features.dispose);
      await pumpFeatureApp(
        tester,
        Column(
          children: [
            CommunityBannerHost(
              key: const ValueKey('global'),
              levels: const {CommunityBannerLevel.critical},
              onBannerLink: (context, uri, banner) async => true,
            ),
            const CommunityBannerHost(key: ValueKey('feed')),
          ],
        ),
        features: features,
      );
      await tester.pumpAndSettle();
      expect(find.text('Banner crit'), findsNWidgets(2));
      expect(features.bannerEvents.events, [('crit', CommunityBannerEvent.impression)]);

      await tester.tap(find.descendant(of: find.byKey(const ValueKey('global')), matching: find.text('Selengkapnya')));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byKey(const ValueKey('feed')), matching: find.byTooltip('Tutup')));
      await tester.pumpAndSettle();

      expect(features.bannerEvents.events, [
        ('crit', CommunityBannerEvent.impression),
        ('crit', CommunityBannerEvent.click),
        ('crit', CommunityBannerEvent.dismiss),
      ]);
      expect(find.text('Banner crit'), findsNothing);
    });

    test('guests see strips by frequency but send no stats', () async {
      final events = FakeBannerEventRepository();
      final guest = views(MemoryLocalValues(), events, clock: DateTime.now, user: null);
      const banner = CommunityBanner(id: 'g', title: 'Tamu');
      expect(await admitted(guest, [banner]), ['g']);
      guest
        ..viewed([banner])
        ..record(banner, CommunityBannerEvent.click);
      await Future<void>.delayed(Duration.zero);
      expect(events.events, isEmpty);
    });
  });
}
