import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/chat/domain/services/message_outbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

http.Response _json(http.Request request, int status, Object body) =>
    http.Response(jsonEncode(body), status, request: request, headers: {'content-type': 'application/json'});

const _disabledBody = {
  'message': 'social_disabled',
  'details': 'Fitur komunitas sedang dinonaktifkan sementara',
  'hint': null,
};

void main() {
  late CommunityLocalizations id;
  late CommunityLocalizations en;

  setUpAll(() async {
    id = await CommunityLocalizations.delegate.load(const Locale('id'));
    en = await CommunityLocalizations.delegate.load(const Locale('en'));
  });

  group('social_disabled is recognized by its code, not by the HTTP status', () {
    for (final (status, sqlState) in [(403, 'PT403'), (503, 'PT503')]) {
      test('$status $sqlState hides community features and shows the kill switch message', () async {
        final expiresAt = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
        final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': 'u-1', 'exp': expiresAt}))).replaceAll('=', '');
        var configCalls = 0;
        final community = RendezvousCommunity.create(
          supabaseUrl: 'http://api.test',
          anonKey: 'anon',
          tokenProvider: () async => 'olt-session',
          trackDelivery: false,
          offlineCache: false,
          httpClient: MockClient((request) async {
            final path = request.url.path;
            if (path == '/bridge/v1/exchange') {
              return _json(request, 200, {
                'access_token': 'eyJhbGciOiJIUzI1NiJ9.$payload.c2ln',
                'expires_at': expiresAt,
                'user': {'id': 'u-1', 'username': 'budi_santoso'},
              });
            }
            if (path == '/rest/v1/rpc/get_client_config') {
              configCalls++;
              return _json(request, 200, {
                'social_enabled': false,
                'flags': <String, bool>{},
                'config': <String, Object?>{},
              });
            }
            if (path == '/rest/v1/rpc/create_comment') {
              return _json(request, status, {..._disabledBody, 'code': sqlState});
            }
            return _json(request, 200, <Object?>[]);
          }),
        );
        addTearDown(community.dispose);
        await community.ensureSignedIn();
        expect(community.clientConfig.socialEnabled, isTrue);

        Object? caught;
        try {
          await community.comments.createComment(postId: 'p-1', body: 'Halo');
        } catch (error) {
          caught = error;
        }

        expect(caught, isA<CommunityException>().having((e) => e.code, 'code', 'social_disabled'));
        final error = caught! as CommunityException;
        expect(id.errorMessage(error), id.errorSocialDisabled);
        expect(en.errorMessage(error), en.errorSocialDisabled);
        expect(community.clientConfig.socialEnabled, isFalse);
        await pumpEventQueue();
        expect(configCalls, greaterThanOrEqualTo(1));
        expect(community.clientConfig.socialEnabled, isFalse);
      });
    }
  });

  test('403 social_disabled is forbidden and is not retried by the outbox; legacy 503 stays unavailable', () {
    final current = mapError(const PostgrestException(message: 'social_disabled', code: 'PT403', details: 'x'));
    expect(current.kind, CommunityErrorKind.forbidden);
    expect(current.code, 'social_disabled');
    expect(isTransientSendError(current), isFalse);

    final legacy = mapError(const PostgrestException(message: 'social_disabled', code: 'PT503', details: 'x'));
    expect(legacy.kind, CommunityErrorKind.unavailable);
    expect(legacy.code, 'social_disabled');
  });
}
