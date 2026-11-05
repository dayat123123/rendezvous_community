import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/config/data/models/client_config_model.dart';
import 'package:rendezvous_community/src/features/config/data/repositories/banner_event_repository_impl.dart';
import 'package:rendezvous_community/src/features/config/data/repositories/promo_popup_history_repository_impl.dart';
import 'package:rendezvous_community/src/features/config/domain/services/community_promo_popups.dart';
import 'package:rendezvous_community/src/features/config/presentation/cubit/community_banners_cubit.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

final _now = DateTime.utc(2026, 11, 5, 3);
final _today = DateTime(2026, 11, 5, 10);

CommunityBanner _popup(
  String id, {
  int priority = 0,
  CommunityBannerFrequency frequency = CommunityBannerFrequency.once,
  bool dismissible = true,
  String? link = 'https://olt.example/promo',
  String? image,
  String? cta,
  DateTime? startsAt,
  DateTime? endsAt,
}) => CommunityBanner(
  id: id,
  title: 'Promo $id',
  body: 'Isi promo $id',
  linkUrl: link,
  dismissible: dismissible,
  priority: priority,
  display: CommunityBannerDisplay.popup,
  frequency: frequency,
  imageUrl: image,
  ctaLabel: cta,
  startsAt: startsAt,
  endsAt: endsAt,
);

class _FailingHistory implements PromoPopupHistoryRepository {
  @override
  Future<Map<String, DateTime>> load(String userId) async => throw StateError('disk');

  @override
  Future<void> save(String userId, Map<String, DateTime> shown) async => throw StateError('disk');
}

class _Clock {
  DateTime value = _today;

  DateTime call() => value;
}

Future<void> _pumpHost(
  WidgetTester tester,
  FakeFeatureDependencies features, {
  CommunityBannerLinkCallback? onBannerLink,
  CommunityCallbacks callbacks = const CommunityCallbacks(),
  CommunityBuilders? builders,
  bool enabled = true,
  CommunityImageLoader? loader,
}) async {
  Widget home = CommunityPromoPopupHost(
    enabled: enabled,
    onBannerLink: onBannerLink,
    child: const Scaffold(body: Text('Beranda host')),
  );
  if (loader != null) home = CommunityImageScope(loader: loader, child: home);
  home = CommunityScope(
    dependencies: FakeDependencies(callbacks: callbacks),
    child: CommunityFeatureScope(dependencies: features, child: home),
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      builder: builders == null ? null : (context, child) => CommunityBuildersScope(builders: builders, child: child!),
      home: home,
    ),
  );
}

FakeFeatureDependencies _features(List<CommunityBanner> banners, {bool signedIn = true}) {
  final features = FakeFeatureDependencies(
    config: loadedConfig().copyWith(banners: banners),
    signedIn: signedIn,
  );
  features.clock = () => _today;
  return features;
}

List<CommunityBannerEvent> _events(FakeFeatureDependencies features) => [
  for (final (_, event) in features.bannerEvents.events) event,
];

void main() {
  group('parsing', () {
    test('popup fields are parsed and unknown values fall back to defaults', () {
      final config = ClientConfigModel.fromJson({
        'banners': [
          {
            'id': 'p1',
            'title': 'Promo akhir tahun',
            'display': 'popup',
            'image_url': 'https://cdn.olt.example/promo.png',
            'cta_label': '  Ikut sekarang ',
            'frequency': 'every_open',
            'link_url': 'olt://promo/akhir-tahun',
          },
          {
            'id': 'p2',
            'title': 'Aneh',
            'display': 'fullscreen',
            'image_url': 'javascript:alert(1)',
            'cta_label': '   ',
            'frequency': 'hourly',
          },
          {'id': 'p3', 'title': 'Lama', 'image_url': 42, 'cta_label': 7, 'frequency': null},
          {'id': 'p4', 'title': 'Harian', 'display': 'popup', 'frequency': 'daily', 'image_url': '/relatif.png'},
        ],
      }).toEntity();

      final [p1, p2, p3, p4] = config.banners;
      expect(p1.display, CommunityBannerDisplay.popup);
      expect(p1.isPopup, isTrue);
      expect(p1.imageUrl, 'https://cdn.olt.example/promo.png');
      expect(p1.ctaLabel, 'Ikut sekarang');
      expect(p1.frequency, CommunityBannerFrequency.everyOpen);
      expect(p1.link, Uri.parse('olt://promo/akhir-tahun'));
      for (final banner in [p2, p3]) {
        expect(banner.display, CommunityBannerDisplay.strip);
        expect(banner.imageUrl, isNull);
        expect(banner.ctaLabel, isNull);
        expect(banner.frequency, CommunityBannerFrequency.once);
      }
      expect(p4.frequency, CommunityBannerFrequency.daily);
      expect(p4.imageUrl, isNull);
    });

    test('popup banners never show as strips', () {
      final banners = visibleBanners(
        [const CommunityBanner(id: 'strip', title: 'Strip'), _popup('popup', priority: 99)],
        dismissed: const {},
        now: _now,
      );
      expect([for (final b in banners) b.id], ['strip']);
    });
  });

  group('frequency rules', () {
    test('the highest priority popup that is due and scheduled wins', () {
      final picked = selectPromoPopup(
        [
          const CommunityBanner(id: 'strip', title: 'Strip', priority: 100),
          _popup('low', priority: 1),
          _popup('seen', priority: 50),
          _popup('ended', priority: 60, endsAt: _now.subtract(const Duration(minutes: 1))),
          _popup('later', priority: 70, startsAt: _now.add(const Duration(hours: 1))),
          _popup('high', priority: 10),
        ],
        shown: {'seen': _today.subtract(const Duration(days: 30))},
        now: _now,
        today: _today,
      );
      expect(picked?.id, 'high');
    });

    test('equal priorities prefer the newest start', () {
      final picked = selectPromoPopup(
        [
          _popup('old', startsAt: _now.subtract(const Duration(days: 2))),
          _popup('new', startsAt: _now.subtract(const Duration(hours: 1))),
        ],
        shown: const {},
        now: _now,
        today: _today,
      );
      expect(picked?.id, 'new');
    });

    test('once, daily and every_open follow the last time they were shown', () {
      final once = _popup('once');
      final daily = _popup('daily', frequency: CommunityBannerFrequency.daily);
      final always = _popup('always', frequency: CommunityBannerFrequency.everyOpen);
      final earlierToday = DateTime(2026, 11, 5, 0, 5);
      final yesterday = DateTime(2026, 11, 4, 23, 55);

      expect(promoPopupDue(once, null, _today), isTrue);
      expect(promoPopupDue(once, DateTime(2025), _today), isFalse);
      expect(promoPopupDue(daily, null, _today), isTrue);
      expect(promoPopupDue(daily, earlierToday, _today), isFalse);
      expect(promoPopupDue(daily, yesterday, _today), isTrue);
      expect(promoPopupDue(always, earlierToday, _today), isTrue);
    });
  });

  group('CommunityPromoPopups', () {
    late MemoryLocalValues values;
    late FakeBannerEventRepository events;
    late _Clock clock;
    String? user;

    CommunityPromoPopups popups() => CommunityPromoPopups(
      events,
      PromoPopupHistoryRepositoryImpl(values),
      currentUserId: () => user,
      clock: clock.call,
    );

    ClientConfig config(List<CommunityBanner> banners) =>
        ClientConfig(fetchedAt: DateTime.now().toUtc(), banners: banners);

    setUp(() {
      values = MemoryLocalValues();
      events = FakeBannerEventRepository();
      clock = _Clock();
      user = 'u-me';
    });

    test('shows at most one popup per session and records the impression', () async {
      final service = popups();
      final cfg = config([_popup('a', priority: 2), _popup('b', frequency: CommunityBannerFrequency.everyOpen)]);
      final first = await service.candidate(cfg);
      expect(first?.id, 'a');
      expect(service.claim(first!), isTrue);
      expect(service.shownThisSession, isTrue);
      expect(await service.candidate(cfg), isNull);
      expect(service.claim(cfg.banners.last), isFalse);
      await pumpEventQueue();
      expect(events.events, [('a', CommunityBannerEvent.impression)]);
    });

    test('once survives a restart, daily returns the next day, every_open returns each start', () async {
      final cfg = config([
        _popup('once', priority: 3),
        _popup('daily', priority: 2, frequency: CommunityBannerFrequency.daily),
        _popup('always', priority: 1, frequency: CommunityBannerFrequency.everyOpen),
      ]);
      final shown = <String>[];
      Future<void> session() async {
        final service = popups();
        final banner = await service.candidate(cfg);
        if (banner != null && service.claim(banner)) shown.add(banner.id);
        await pumpEventQueue();
      }

      await session();
      await session();
      await session();
      clock.value = _today.add(const Duration(days: 1));
      await session();
      await session();
      expect(shown, ['once', 'daily', 'always', 'daily', 'always']);
    });

    test('history is kept per user and a new user starts a new session', () async {
      final service = popups();
      final cfg = config([_popup('a')]);
      expect(service.claim((await service.candidate(cfg))!), isTrue);
      await pumpEventQueue();

      user = 'u-other';
      service.onUserChanged(user);
      expect(service.shownThisSession, isFalse);
      expect((await service.candidate(cfg))?.id, 'a');

      user = 'u-me';
      expect(await popups().candidate(cfg), isNull);
    });

    test('nothing is shown without a user, a loaded config, or while an update is required', () async {
      final service = popups();
      expect(await service.candidate(const ClientConfig(banners: [])), isNull);
      expect(await service.candidate(ClientConfig(banners: [_popup('a')])), isNull);
      expect(await service.candidate(config([_popup('a')]).copyWith(updateRequired: true)), isNull);
      user = null;
      expect(await service.candidate(config([_popup('a')])), isNull);
    });

    test('storage and network failures are ignored', () async {
      events.error = StateError('offline');
      final service = CommunityPromoPopups(events, _FailingHistory(), currentUserId: () => user, clock: clock.call);
      final banner = await service.candidate(config([_popup('a')]));
      expect(banner?.id, 'a');
      expect(service.claim(banner!), isTrue);
      service.record(banner, CommunityBannerEvent.dismiss);
      await pumpEventQueue();
      expect(events.events, [('a', CommunityBannerEvent.impression), ('a', CommunityBannerEvent.dismiss)]);
    });

    test('history repository keeps the most recent entries', () async {
      final repository = PromoPopupHistoryRepositoryImpl(values, maxEntries: 2);
      await repository.save('u-me', {
        'a': DateTime.utc(2026, 11, 1),
        'b': DateTime.utc(2026, 11, 3),
        'c': DateTime.utc(2026, 11, 2),
      });
      expect(await repository.load('u-me'), {'b': DateTime.utc(2026, 11, 3), 'c': DateTime.utc(2026, 11, 2)});
      expect(await repository.load('u-other'), isEmpty);
    });

    test('record_banner_event receives the banner id and event name', () async {
      final api = mockApi();
      when(() => api.rpcValue('record_banner_event', any())).thenAnswer((_) async => null);
      await BannerEventRepositoryImpl(api).record('b-1', CommunityBannerEvent.click);
      verify(() => api.rpcValue('record_banner_event', {'p_banner_id': 'b-1', 'p_event': 'click'})).called(1);
    });
  });

  group('CommunityPromoPopupHost', () {
    testWidgets('shows the popup once after the first frame and records dismiss', (tester) async {
      final features = _features([_popup('a', cta: 'Ikut promo')]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();

      expect(find.text('Promo a'), findsOneWidget);
      expect(find.text('Isi promo a'), findsOneWidget);
      expect(find.text('Ikut promo'), findsOneWidget);
      expect(find.text('Nanti'), findsOneWidget);
      expect(find.byTooltip('Tutup promo'), findsOneWidget);
      expect(find.bySemanticsLabel('Promo'), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      expect(tester.getSize(find.widgetWithText(FilledButton, 'Ikut promo')).height, greaterThanOrEqualTo(48));
      expect(_events(features), [CommunityBannerEvent.impression]);

      await tester.tap(find.byTooltip('Tutup promo'));
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.dismiss]);

      await tester.pumpWidget(const SizedBox());
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
    });

    testWidgets('the card is at most 360 wide', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      final card = find.ancestor(of: find.text('Promo a'), matching: find.byType(Material)).first;
      expect(tester.getSize(card).width, 360);
    });

    testWidgets('the primary button closes, records click and lets the host handle the link', (tester) async {
      final features = _features([_popup('a', link: 'olt://promo/akhir-tahun')]);
      addTearDown(features.dispose);
      final handled = <(Uri, String, String)>[];
      await _pumpHost(
        tester,
        features,
        onBannerLink: (context, uri, banner) {
          handled.add((uri, banner.id, _events(features).map((event) => event.name).join(',')));
          return true;
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('Lihat'), findsOneWidget);

      await tester.tap(find.text('Lihat'));
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(handled, [(Uri.parse('olt://promo/akhir-tahun'), 'a', 'impression,click')]);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.click]);
    });

    testWidgets('an unhandled https link asks for confirmation; other schemes are ignored', (tester) async {
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      await _pumpHost(
        tester,
        features,
        callbacks: CommunityCallbacks(onBannerLink: (context, uri, banner) async => false),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat'));
      await tester.pumpAndSettle();
      expect(find.text('Buka tautan?'), findsOneWidget);
      expect(find.textContaining('olt.example', findRichText: true), findsWidgets);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      final other = _features([_popup('b', link: 'olt://promo/b')]);
      addTearDown(other.dispose);
      await tester.pumpWidget(const SizedBox());
      await _pumpHost(tester, other);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Promo b'), findsNothing);
      expect(_events(other), [CommunityBannerEvent.impression, CommunityBannerEvent.click]);
    });

    testWidgets('tapping the image is the same as the primary button', (tester) async {
      final features = _features([_popup('a', image: 'https://cdn.olt.example/a.png', link: 'olt://a')]);
      addTearDown(features.dispose);
      final opened = <Uri>[];
      await _pumpHost(
        tester,
        features,
        loader: CommunityImageLoader(client: MockClient((_) async => http.Response('', 404))),
        onBannerLink: (context, uri, banner) {
          opened.add(uri);
          return true;
        },
      );
      await tester.pumpAndSettle();
      final image = find.byType(Image);
      expect(image, findsOneWidget);
      expect(tester.getSize(image).width / tester.getSize(image).height, closeTo(16 / 9, 0.01));
      await tester.tap(image);
      await tester.pumpAndSettle();
      expect(opened, [Uri.parse('olt://a')]);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.click]);
    });

    testWidgets('the overlay and back button close only dismissible popups', (tester) async {
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.dismiss]);

      final locked = _features([_popup('b', dismissible: false)]);
      addTearDown(locked.dispose);
      await tester.pumpWidget(const SizedBox());
      await _pumpHost(tester, locked);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Tutup promo'), findsNothing);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Promo b'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Promo b'), findsOneWidget);

      await tester.tap(find.text('Nanti'));
      await tester.pumpAndSettle();
      expect(find.text('Promo b'), findsNothing);
      expect(_events(locked), [CommunityBannerEvent.impression, CommunityBannerEvent.dismiss]);
    });

    testWidgets('back closes a dismissible popup', (tester) async {
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.dismiss]);
    });

    testWidgets('a popup without link and not dismissible still has a way out', (tester) async {
      final features = _features([_popup('a', link: null, dismissible: false)]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      expect(find.text('Lihat'), findsNothing);
      expect(find.text('Nanti'), findsNothing);
      expect(find.byTooltip('Tutup promo'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.dismiss]);
    });

    testWidgets('waits until another route on top is closed', (tester) async {
      final features = FakeFeatureDependencies(
        configRepository: FakeConfigRepository(ClientConfig(banners: [_popup('a')])),
      );
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      final context = tester.element(find.text('Beranda host'));
      final consent = showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(title: Text('Dokumen wajib')),
      );
      await tester.pumpAndSettle();
      await features.configService.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      expect(features.bannerEvents.events, isEmpty);

      Navigator.of(tester.element(find.text('Dokumen wajib'))).pop();
      await consent;
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsOneWidget);
    });

    testWidgets('does nothing while disabled, signed out, or with only strips', (tester) async {
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      await _pumpHost(tester, features, enabled: false);
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);

      final anonymous = _features([_popup('a')], signedIn: false);
      addTearDown(anonymous.dispose);
      await tester.pumpWidget(const SizedBox());
      await _pumpHost(tester, anonymous);
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);

      final strips = _features([const CommunityBanner(id: 's', title: 'Strip saja')]);
      addTearDown(strips.dispose);
      await tester.pumpWidget(const SizedBox());
      await _pumpHost(tester, strips);
      await tester.pumpAndSettle();
      expect(find.text('Strip saja'), findsNothing);
      expect(strips.bannerEvents.events, isEmpty);
    });

    testWidgets('shows once the client config arrives', (tester) async {
      final features = FakeFeatureDependencies(
        configRepository: FakeConfigRepository(ClientConfig(banners: [_popup('a')])),
      );
      addTearDown(features.dispose);
      await _pumpHost(tester, features);
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsNothing);
      await features.configService.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Promo a'), findsOneWidget);
    });

    test('system.popup is kept and overridden by merge', () {
      Widget first(BuildContext context, CommunityPromoPopupDetails d, Widget fallback) => fallback;
      Widget second(BuildContext context, CommunityPromoPopupDetails d, Widget fallback) => const SizedBox();
      final base = CommunitySystemBuilders(popup: first);
      expect(base.merge(const CommunitySystemBuilders()).popup, same(first));
      expect(base.merge(CommunitySystemBuilders(popup: second)).popup, same(second));
    });

    testWidgets('system.popup builder replaces the card and receives the actions', (tester) async {
      final features = _features([_popup('a', cta: 'Ambil')]);
      addTearDown(features.dispose);
      CommunityPromoPopupDetails? seen;
      await _pumpHost(
        tester,
        features,
        onBannerLink: (context, uri, banner) => true,
        builders: CommunityBuilders(
          system: CommunitySystemBuilders(
            popup: (context, d, fallback) {
              seen = d;
              return Center(
                child: Material(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(onPressed: d.onCta, child: Text('OLT ${d.ctaLabel}')),
                      TextButton(onPressed: d.onClose, child: Text(d.laterLabel)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final details = seen!;
      expect(details.banner.id, 'a');
      expect(details.title, 'Promo a');
      expect(details.body, 'Isi promo a');
      expect(details.imageUrl, isNull);
      expect(details.dismissible, isTrue);
      expect(details.hasLink, isTrue);
      expect(details.closeLabel, 'Tutup promo');
      await tester.tap(find.text('OLT Ambil'));
      await tester.pumpAndSettle();
      expect(find.text('OLT Ambil'), findsNothing);
      expect(_events(features), [CommunityBannerEvent.impression, CommunityBannerEvent.click]);
    });

    testWidgets('animations are skipped when the platform disables them', (tester) async {
      final features = _features([_popup('a')]);
      addTearDown(features.dispose);
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await _pumpHost(tester, features);
      await tester.pump();
      await tester.pump();
      expect(find.text('Promo a'), findsOneWidget);
      final fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('Promo a'), matching: find.byType(FadeTransition)).first,
      );
      expect(fade.opacity.value, 1);
    });
  });

  group('strip banner links', () {
    testWidgets('the strip uses the same onBannerLink callback', (tester) async {
      final opened = <String>[];
      final features = FakeFeatureDependencies(
        config: loadedConfig().copyWith(
          banners: [const CommunityBanner(id: 's', title: 'Strip', linkUrl: 'olt://s')],
        ),
      );
      addTearDown(features.dispose);
      await pumpFeatureApp(
        tester,
        const CommunityBannerHost(),
        features: features,
        dependencies: FakeDependencies(
          callbacks: CommunityCallbacks(
            onBannerLink: (context, uri, banner) {
              opened.add('$uri ${banner.id}');
              return true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selengkapnya'));
      await tester.pumpAndSettle();
      expect(opened, ['olt://s s']);
    });
  });
}
