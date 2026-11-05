import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import 'screenshot_harness.dart';

final _pendingImages = CommunityImageLoader(client: MockClient((_) => Completer<http.Response>().future));

Widget _behind(BuildContext context) {
  final spacing = CommunityStyle.of(context).spacing;
  return Padding(
    padding: EdgeInsets.all(spacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 6; i++) ...[
          Row(
            children: [
              const CommunitySkeletonBox(height: 40, circle: true),
              SizedBox(width: spacing.md),
              const Expanded(child: CommunitySkeletonBox(height: 12)),
            ],
          ),
          SizedBox(height: spacing.md),
          const CommunitySkeletonBox(height: 12),
          SizedBox(height: spacing.sm),
          const CommunitySkeletonBox(width: 220, height: 12),
          SizedBox(height: spacing.xl),
        ],
      ],
    ),
  );
}

Widget _popupScene(BuildContext context, CommunityBanner banner) => SizedBox(
  height: 760,
  child: CommunityImageScope(
    loader: _pendingImages,
    child: Stack(
      fit: StackFit.expand,
      children: [
        _behind(context),
        ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
        CommunityPromoPopupCard(banner: banner, onCta: banner.link == null ? null : () {}, onClose: () {}),
      ],
    ),
  ),
);

final systemScenes = <ScreenshotScene>[
  ScreenshotScene(
    'system_promo_popup',
    padding: EdgeInsets.zero,
    (context) => _popupScene(
      context,
      const CommunityBanner(
        id: 'promo-1',
        title: 'Promo akhir tahun: gratis biaya transaksi',
        body: 'Beli saham pilihan tanpa biaya broker sampai 31 Desember. Syarat dan ketentuan berlaku.',
        linkUrl: 'olt://promo/akhir-tahun',
        imageUrl: 'https://cdn.olt.example/promo/akhir-tahun.png',
        ctaLabel: 'Ikut promo',
        display: CommunityBannerDisplay.popup,
      ),
    ),
  ),
  ScreenshotScene(
    'system_promo_popup_text',
    padding: EdgeInsets.zero,
    (context) => _popupScene(
      context,
      const CommunityBanner(
        id: 'promo-2',
        title: 'Kelas investasi gratis minggu ini',
        body: 'Belajar membaca laporan keuangan bersama analis OLT, Sabtu pukul 10.00 WIB.',
        dismissible: false,
        display: CommunityBannerDisplay.popup,
      ),
    ),
  ),
];
