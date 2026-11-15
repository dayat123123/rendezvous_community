import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

void main() {
  test('CommunityIcons carries the trade icons through copyWith and equality', () {
    const icons = CommunityIcons();
    expect(icons.tradeShare, Icons.candlestick_chart_outlined);
    expect(icons.tradeBell, Icons.notifications_none_outlined);
    expect(icons.tradeBellActive, Icons.notifications_active_outlined);
    expect(icons.tradeBellMuted, Icons.notifications_off_outlined);
    expect(icons.tradePending, Icons.hourglass_top_outlined);

    final custom = icons.copyWith(tradeBell: Icons.alarm, tradeShare: Icons.show_chart);
    expect(custom.tradeBell, Icons.alarm);
    expect(custom.tradeShare, Icons.show_chart);
    expect(custom.tradeBellMuted, icons.tradeBellMuted);
    expect(custom == icons, isFalse);
    expect(custom, icons.copyWith(tradeBell: Icons.alarm, tradeShare: Icons.show_chart));
    expect(icons.lerp(custom, 0.7), custom);
  });

  test(
    'RendezvousCommunity serves trade share status from get_trade_share_status and forgets it on sign out',
    () async {
      final requests = <String>[];
      final expiresAt = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': 'u-1', 'exp': expiresAt}))).replaceAll('=', '');
      final community = RendezvousCommunity.create(
        supabaseUrl: 'http://api.test',
        anonKey: 'anon',
        tokenProvider: () async => 'olt-session',
        trackDelivery: false,
        offlineCache: false,
        httpClient: MockClient((request) async {
          requests.add(request.url.path);
          return switch (request.url.path) {
            '/bridge/v1/exchange' => http.Response(
              jsonEncode({
                'access_token': 'eyJhbGciOiJIUzI1NiJ9.$payload.c2lnbmF0dXJl',
                'expires_at': expiresAt,
                'user': {'id': 'u-1', 'username': 'budi_santoso'},
              }),
              200,
              request: request,
            ),
            '/rest/v1/rpc/get_trade_share_status' => http.Response(
              jsonEncode({
                'enabled': true,
                'status': 'active',
                'limits': {'min_delay_minutes': 15},
              }),
              200,
              request: request,
              headers: {'content-type': 'application/json'},
            ),
            '/rest/v1/rpc/get_legal_documents' => http.Response('[]', 200, request: request),
            _ => http.Response('{}', 404, request: request),
          };
        }),
      );
      addTearDown(community.dispose);

      expect(community, isA<CommunityTradeShareDependencies>());
      await community.ensureSignedIn();
      final status = await community.tradeShare.status();

      expect(status.enabled, isTrue);
      expect(status.status, TradeSharerStatus.active);
      expect(community.tradeShare.enabled, isTrue);
      expect(requests, contains('/rest/v1/rpc/get_trade_share_status'));

      await community.signOut();
      await pumpEventQueue();
      expect(community.tradeShare.current, isNull);
    },
  );
}
