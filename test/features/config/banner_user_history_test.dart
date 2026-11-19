import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/config/data/models/client_config_model.dart';
import 'package:rendezvous_community/src/features/config/data/repositories/promo_popup_history_repository_impl.dart';
import 'package:rendezvous_community/src/features/config/domain/services/community_promo_popups.dart';
import 'package:rendezvous_community/src/features/config/presentation/cubit/community_banners_cubit.dart';

import '../../support/feature_fakes.dart';

class _QueuedConfigRepository implements ClientConfigRepository {
  final pending = <Completer<ClientConfig>>[];

  @override
  Future<ClientConfig> fetch({String? platform, String? appVersion}) {
    final completer = Completer<ClientConfig>();
    pending.add(completer);
    return completer.future;
  }
}

ClientConfig _configFor(String? viewer, List<CommunityBanner> banners) =>
    loadedConfig().copyWith(viewerKnown: true, viewerId: viewer, banners: banners);

CommunityStripViews _views(LocalValues values, {required String? Function() user, DateTime Function()? clock}) =>
    CommunityStripViews(
      FakeBannerEventRepository(),
      PromoPopupHistoryRepositoryImpl(values, prefix: 'banner_strips:'),
      currentUserId: user,
      clock: clock,
    );

Future<List<String>> _admitted(CommunityStripViews views, List<CommunityBanner> banners) async {
  if (!views.ready) {
    views.admit(banners, max: 3);
    await Future<void>.delayed(Duration.zero);
  }
  return [for (final banner in views.admit(banners, max: 3)) banner.id];
}

void main() {
  test('the config carries the viewer and each banner keeps when this user last saw or closed it', () {
    final config = ClientConfigModel.fromJson({
      'banners': [
        {'id': 'b-1', 'title': 'Info', 'seen_at': '2026-11-18T01:00:00Z', 'dismissed_at': '2026-11-18T01:05:00+07:00'},
        {'id': 'b-2', 'title': 'Baru', 'seen_at': 'bukan tanggal'},
      ],
      'config': {'viewer_id': 'u-1'},
    }).toEntity();
    expect(config.viewerKnown, isTrue);
    expect(config.viewerId, 'u-1');
    expect(config.banners.first.seenAt, DateTime.utc(2026, 11, 18, 1));
    expect(config.banners.first.dismissedAt, DateTime.utc(2026, 11, 17, 18, 5));
    expect(config.banners.last.seenAt, isNull);
    expect(config.isFor('u-1'), isTrue);
    expect(config.isFor('u-2'), isFalse);

    final guest = ClientConfigModel.fromJson({
      'config': {'viewer_id': null},
    }).toEntity();
    expect(guest.viewerKnown, isTrue);
    expect(guest.isFor(null), isTrue);
    expect(guest.isFor('u-1'), isFalse);

    final olderServer = ClientConfigModel.fromJson({'config': <String, Object?>{}}).toEntity();
    expect(olderServer.viewerKnown, isFalse);
    expect(olderServer.isFor('u-1'), isTrue);
  });

  test('a strip seen on the server follows its frequency even when this device has no history', () async {
    final now = DateTime(2026, 11, 19, 9);
    final seenToday = DateTime(2026, 11, 19, 7).toUtc();
    final seenYesterday = DateTime(2026, 11, 18, 20).toUtc();
    final banners = [
      CommunityBanner(id: 'once', title: 'Sekali', seenAt: seenYesterday),
      CommunityBanner(
        id: 'daily-today',
        title: 'Hari ini',
        frequency: CommunityBannerFrequency.daily,
        seenAt: seenToday,
      ),
      CommunityBanner(
        id: 'daily-yesterday',
        title: 'Kemarin',
        frequency: CommunityBannerFrequency.daily,
        seenAt: seenYesterday,
      ),
      CommunityBanner(id: 'open', title: 'Selalu', frequency: CommunityBannerFrequency.everyOpen, seenAt: seenToday),
    ];
    final views = _views(MemoryLocalValues(), user: () => 'u-1', clock: () => now);
    expect(await _admitted(views, banners), ['daily-yesterday', 'open']);
  });

  test('the newer of the device and server history wins', () {
    final today = DateTime(2026, 11, 19, 9);
    final banner = CommunityBanner(
      id: 'd',
      title: 'Harian',
      frequency: CommunityBannerFrequency.daily,
      seenAt: DateTime(2026, 11, 18, 9).toUtc(),
    );
    expect(promoPopupDue(banner, null, today), isTrue);
    expect(promoPopupDue(banner, DateTime(2026, 11, 19, 8), today), isFalse);
    expect(
      promoPopupDue(banner.copyWith(seenAt: DateTime(2026, 11, 19, 8).toUtc()), DateTime(2026, 11, 17), today),
      isFalse,
    );
    expect(
      selectPromoPopup(
        [banner.copyWith(display: CommunityBannerDisplay.popup, frequency: CommunityBannerFrequency.once)],
        shown: const {},
        now: today.toUtc(),
        today: today,
      ),
      isNull,
    );
  });

  test('a strip this user closed stays hidden on any device, unless the Hub made it non-closable', () {
    final closed = DateTime.utc(2026, 11, 18);
    final banners = [
      CommunityBanner(id: 'closed', title: 'Ditutup', dismissedAt: closed),
      CommunityBanner(id: 'pinned', title: 'Wajib', dismissible: false, dismissedAt: closed),
      const CommunityBanner(id: 'open', title: 'Baru'),
    ];
    expect(
      [for (final banner in visibleBanners(banners, dismissed: const {}, now: DateTime.utc(2026, 11, 19))) banner.id],
      ['pinned', 'open'],
    );
  });

  test('strips wait for the signed-in user config and skip what that user already saw', () async {
    final repository = FakeConfigRepository(_configFor(null, [const CommunityBanner(id: 'once', title: 'Sekali')]));
    String? user;
    final service = ClientConfigService(repository, currentUserId: () => user);
    addTearDown(service.dispose);
    await service.refresh();
    final views = _views(MemoryLocalValues(), user: () => user);
    addTearDown(views.dispose);
    final cubit = CommunityBannersCubit(service, null, views: views);
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect([for (final banner in cubit.state) banner.id], ['once']);

    user = 'u-1';
    views.onUserChanged(user);
    await pumpEventQueue();
    expect(cubit.state, isEmpty);

    repository.config = _configFor('u-1', [
      CommunityBanner(id: 'once', title: 'Sekali', seenAt: DateTime.utc(2026, 11, 18)),
      const CommunityBanner(id: 'fresh', title: 'Baru'),
    ]);
    await service.refresh();
    await pumpEventQueue();
    expect([for (final banner in cubit.state) banner.id], ['fresh']);
  });

  test('a popup is not chosen from a config fetched for someone else', () async {
    final popups = CommunityPromoPopups(
      FakeBannerEventRepository(),
      PromoPopupHistoryRepositoryImpl(MemoryLocalValues()),
      currentUserId: () => 'u-1',
    );
    addTearDown(popups.dispose);
    const popup = CommunityBanner(id: 'p', title: 'Promo', display: CommunityBannerDisplay.popup);
    expect(await popups.candidate(_configFor(null, const [popup])), isNull);
    expect(await popups.candidate(_configFor('u-2', const [popup])), isNull);
    expect((await popups.candidate(_configFor('u-1', const [popup])))?.id, 'p');
  });

  test('a refresh after sign-in does not reuse the guest request still in flight', () async {
    final repository = _QueuedConfigRepository();
    String? user;
    final service = ClientConfigService(repository, currentUserId: () => user);
    addTearDown(service.dispose);

    final guest = service.refresh();
    expect(identical(service.refresh(), guest), isTrue);
    user = 'u-1';
    final signedIn = service.refresh();
    expect(repository.pending, hasLength(1));

    repository.pending.single.complete(_configFor(null, const []));
    await guest;
    expect(service.current.loaded, isFalse);
    await pumpEventQueue();
    expect(repository.pending, hasLength(2));

    repository.pending.last.complete(_configFor('u-1', const []));
    await signedIn;
    expect(service.current.viewerId, 'u-1');
  });
}
