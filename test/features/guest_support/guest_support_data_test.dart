import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/network/anonymous_rpc.dart';
import 'package:rendezvous_community/src/features/guest_support/data/repositories/guest_support_repository_impl.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/guest_support_texts.dart';

http.Response _json(http.Request request, int status, Object? body) =>
    http.Response(jsonEncode(body), status, request: request, headers: {'content-type': 'application/json'});

Map<String, Object?> _ticketJson({String status = 'open'}) => {
  'id': 'gt-1',
  'ticket_number': 'CS-20261109-0042',
  'room_id': 'gr-1',
  'topic': 'account',
  'topic_name': 'Akun & Login',
  'status': status,
  'queue_ahead': 3,
  'eta_minutes': 9,
  'agent': null,
  'complaint': null,
  'created_at': '2026-11-09T02:00:00+00:00',
  'resolved_at': null,
  'closed_at': null,
  'close_reason': null,
  'reopen_until': null,
  'rating': null,
  'can_rate': false,
  'quick_replies': <Object?>[],
};

Map<String, Object?> _messageJson(String id, String role, String body) => {
  'id': id,
  'room_id': 'gr-1',
  'sender_id': role == 'agent' ? 'a-1' : 'guest-1',
  'sender_username': role == 'agent' ? 'cs_nadia' : 'tamu_0123456789ab',
  'sender_display_name': role == 'agent' ? 'Nadia' : 'Budi',
  'sender_avatar_url': null,
  'body': body,
  'is_deleted': false,
  'attachments': <Object?>[],
  'client_id': null,
  'created_at': '2026-11-09T02:0${id.length}:00+00:00',
  'kind': 'text',
  'sender_role': role,
  'session_id': 'gt-1',
  'payload': <String, Object?>{},
};

void main() {
  group('form validation matches cs_api.guest_start', () {
    Map<GuestSupportField, GuestSupportFieldIssue> check({
      String name = 'Budi Santoso',
      String? loginId,
      String? problem = 'pin',
      String description = 'Saya lupa PIN setelah ganti HP',
    }) => validateGuestSupportForm(name: name, loginId: loginId, problem: problem, description: description);

    test('a complete form has no issues and the login ID is optional', () {
      expect(check(), isEmpty);
      expect(check(loginId: '  '), isEmpty);
      expect(check(loginId: 'budi.01@x-y_z'), isEmpty);
    });

    test('name must be 2 to 60 characters after trimming', () {
      expect(check(name: '   ')[GuestSupportField.name], GuestSupportFieldIssue.required);
      expect(check(name: ' B ')[GuestSupportField.name], GuestSupportFieldIssue.tooShort);
      expect(check(name: 'Bu'), isEmpty);
      expect(check(name: 'a' * 60), isEmpty);
      expect(check(name: 'a' * 61)[GuestSupportField.name], GuestSupportFieldIssue.tooLong);
    });

    test('login ID is uppercased and limited to A-Z, digits and . _ @ -', () {
      expect(normalizeGuestLoginId('  budi01 '), 'BUDI01');
      expect(normalizeGuestLoginId('   '), isNull);
      expect(check(loginId: 'BUDI 01')[GuestSupportField.loginId], GuestSupportFieldIssue.invalid);
      expect(check(loginId: 'budi#1')[GuestSupportField.loginId], GuestSupportFieldIssue.invalid);
      expect(check(loginId: 'A' * 50), isEmpty);
      expect(check(loginId: 'A' * 51)[GuestSupportField.loginId], GuestSupportFieldIssue.tooLong);
    });

    test('problem must be one of the server codes', () {
      expect(check(problem: null)[GuestSupportField.problem], GuestSupportFieldIssue.required);
      expect(check(problem: 'otp')[GuestSupportField.problem], GuestSupportFieldIssue.invalid);
      for (final code in guestProblemCodes) {
        expect(check(problem: code), isEmpty, reason: code);
      }
    });

    test('description must be 10 to 1000 characters after trimming', () {
      expect(check(description: '')[GuestSupportField.description], GuestSupportFieldIssue.required);
      expect(check(description: ' lupa pin ')[GuestSupportField.description], GuestSupportFieldIssue.tooShort);
      expect(check(description: 'a' * 10), isEmpty);
      expect(check(description: 'a' * 1000), isEmpty);
      expect(check(description: 'a' * 1001)[GuestSupportField.description], GuestSupportFieldIssue.tooLong);
    });

    test('messages are 1 to 2000 characters', () {
      expect(isGuestMessageValid('  '), isFalse);
      expect(isGuestMessageValid('Halo'), isTrue);
      expect(isGuestMessageValid('a' * 2000), isTrue);
      expect(isGuestMessageValid('a' * 2001), isFalse);
    });
  });

  group('error mapping', () {
    test('server codes map to guest errors', () {
      final cases = {
        'guest_disabled': GuestSupportError.disabled,
        'guest_login_limit': GuestSupportError.loginLimit,
        'invalid_name': GuestSupportError.invalidName,
        'invalid_login_id': GuestSupportError.invalidLoginId,
        'invalid_problem': GuestSupportError.invalidProblem,
        'invalid_description': GuestSupportError.invalidDescription,
        'invalid_body': GuestSupportError.invalidMessage,
        'ticket_not_active': GuestSupportError.ticketNotActive,
        'guest_session_expired': GuestSupportError.sessionExpired,
      };
      for (final MapEntry(:key, :value) in cases.entries) {
        expect(guestSupportErrorOf(CommunityException(CommunityErrorKind.invalidInput, code: key)), value, reason: key);
      }
      expect(
        guestSupportErrorOf(const CommunityException(CommunityErrorKind.rateLimited, code: 'rate_limited')),
        GuestSupportError.rateLimited,
      );
      expect(guestSupportErrorOf(const CommunityException(CommunityErrorKind.network)), GuestSupportError.network);
    });

    test('texts are specific per error and per context', () async {
      final l10n = await CommunityLocalizations.delegate.load(const Locale('id'));
      const rate = CommunityException(CommunityErrorKind.rateLimited, code: 'rate_limited');
      expect(guestErrorText(l10n, rate), l10n.guestErrorRateLimited);
      expect(guestErrorText(l10n, rate, sending: true), l10n.guestErrorMessageRate);
      expect(
        guestErrorText(l10n, const CommunityException(CommunityErrorKind.rateLimited, code: 'guest_login_limit')),
        l10n.guestErrorLoginLimit,
      );
      expect(
        guestErrorText(l10n, const CommunityException(CommunityErrorKind.forbidden, code: 'guest_disabled')),
        l10n.guestSupportDisabled,
      );
      expect(
        guestErrorField(const CommunityException(CommunityErrorKind.invalidInput, code: 'invalid_login_id')),
        GuestSupportField.loginId,
      );
      expect(l10n.guestSupportSecurityNote, contains('CS tidak pernah meminta password, PIN, atau OTP'));
    });
  });

  group('repository parsing', () {
    test('config, start, poll and send parse the server JSON', () async {
      final calls = <(String, Map<String, Object?>)>[];
      final repo = GuestSupportRepositoryImpl((fn, params) async {
        calls.add((fn, params));
        return switch (fn) {
          'guest_config' => {
            'enabled': true,
            'session_hours': 24,
            'problems': [
              {'code': 'password', 'label': 'Lupa password'},
              {'code': '', 'label': 'kosong'},
              {'code': 'pin', 'label': 'Lupa PIN'},
            ],
          },
          'guest_start' => {
            'token': 'tok-abcdefghijklmnopqrstuvwxyz',
            'expires_at': '2026-11-10T02:00:00+00:00',
            'ticket': _ticketJson(),
          },
          'guest_poll' => {
            'expires_at': '2026-11-10T02:00:00+00:00',
            'ticket': _ticketJson(status: 'claimed'),
            'messages': [_messageJson('m1', 'customer', 'Lupa PIN'), _messageJson('m22', 'agent', 'Halo Pak Budi')],
          },
          'guest_send' => _messageJson('m333', 'customer', 'Terima kasih'),
          'guest_end' => {'ticket': _ticketJson(status: 'closed')},
          _ => null,
        };
      });

      final config = await repo.config(language: 'en');
      expect(config.enabled, isTrue);
      expect(config.problems.map((p) => p.code), ['password', 'pin']);

      final session = await repo.start(
        name: ' Budi ',
        loginId: ' budi01 ',
        problem: 'pin',
        description: ' Saya lupa PIN aplikasi ',
      );
      expect(session.token.token, 'tok-abcdefghijklmnopqrstuvwxyz');
      expect(session.token.expiresAt, DateTime.utc(2026, 11, 10, 2));
      expect(session.ticket.queueAhead, 3);
      expect(session.ticket.etaMinutes, 9);
      expect(session.token.toString(), isNot(contains('tok-')));

      final snapshot = await repo.poll(session.token.token);
      expect(snapshot.ticket.status, SupportStatus.claimed);
      expect(snapshot.messages.map((m) => m.senderRole), [SenderRole.customer, SenderRole.agent]);
      expect(snapshot.messages.last.sender?.displayName, 'Nadia');

      final sent = await repo.send(session.token.token, body: ' Terima kasih ', clientId: 'c-1');
      expect(sent.body, 'Terima kasih');

      final ended = await repo.end(session.token.token);
      expect(ended?.status, SupportStatus.closed);

      expect(calls.map((c) => c.$1), ['guest_config', 'guest_start', 'guest_poll', 'guest_send', 'guest_end']);
      expect(calls[0].$2, {'p_language': 'en'});
      expect(calls[1].$2, {
        'p_name': 'Budi',
        'p_login_id': 'BUDI01',
        'p_problem': 'pin',
        'p_description': 'Saya lupa PIN aplikasi',
        'p_language': 'id',
      });
      expect(calls[3].$2, {
        'p_token': 'tok-abcdefghijklmnopqrstuvwxyz',
        'p_body': 'Terima kasih',
        'p_client_id': 'c-1',
      });
    });

    test('a server without guest_config reports guest complaints as unavailable', () async {
      final repo = GuestSupportRepositoryImpl(
        (fn, params) async =>
            throw const CommunityException(CommunityErrorKind.unknown, code: 'PGRST202', message: 'not found'),
      );
      expect((await repo.config()).enabled, isFalse);
    });

    test('guest_end from an older server returns no ticket', () async {
      expect(
        await GuestSupportRepositoryImpl((fn, params) async => null).end('tok-abcdefghijklmnopqrstuvwxyz'),
        isNull,
      );
      expect(
        await GuestSupportRepositoryImpl((fn, params) async => {'ticket': null}).end('tok-abcdefghijklmnopqrstuvwxyz'),
        isNull,
      );
    });

    test('a start response without a token is rejected', () async {
      final repo = GuestSupportRepositoryImpl((fn, params) async => {'ticket': _ticketJson()});
      expect(
        () => repo.start(name: 'Budi', problem: 'pin', description: 'Saya lupa PIN aplikasi'),
        throwsA(isA<CommunityException>()),
      );
    });
  });

  group('anonymous access', () {
    test('guest RPCs use the anon key in the cs_api schema and never exchange the OLT token', () async {
      var tokenRequests = 0;
      final requests = <http.Request>[];
      final community = RendezvousCommunity.create(
        supabaseUrl: 'http://api.test/',
        anonKey: 'anon-key',
        tokenProvider: () async {
          tokenRequests++;
          return null;
        },
        trackDelivery: false,
        offlineCache: false,
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.path == '/rest/v1/rpc/guest_poll') {
            return _json(request, 401, {
              'code': 'PT401',
              'message': 'guest_session_expired',
              'details': 'Sesi pengaduan sudah berakhir.',
            });
          }
          return _json(request, 200, {'enabled': true, 'session_hours': 24, 'problems': <Object?>[]});
        }),
      );
      addTearDown(community.dispose);

      final config = await community.guestSupport.config();
      expect(config.enabled, isTrue);
      Object? caught;
      try {
        await community.guestSupport.poll('tok-abcdefghijklmnopqrstuvwxyz');
      } catch (e) {
        caught = e;
      }

      expect(guestSupportErrorOf(caught!), GuestSupportError.sessionExpired);
      expect(tokenRequests, 0);
      expect(requests.map((r) => r.url.path), ['/rest/v1/rpc/guest_config', '/rest/v1/rpc/guest_poll']);
      for (final request in requests) {
        expect(request.headers['Authorization'], 'Bearer anon-key');
        expect(request.headers['apikey'], 'anon-key');
        expect(request.headers['Content-Profile'], 'cs_api');
      }
      expect(jsonDecode(requests.last.body), {'p_token': 'tok-abcdefghijklmnopqrstuvwxyz'});
      expect(community.guestSessions.persistent, isFalse);
    });

    test('the standalone client works without initializing the library', () async {
      final requests = <http.Request>[];
      final client = CommunityGuestSupportClient.anonymous(
        supabaseUrl: 'http://api.test',
        anonKey: 'anon-key',
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json(request, 403, {'code': 'PT403', 'message': 'guest_disabled', 'details': 'Tidak tersedia'});
        }),
      );
      expect(RendezvousCommunity.isInitialized, isFalse);
      Object? caught;
      try {
        await client.guestSupport.start(name: 'Budi', problem: 'pin', description: 'Saya lupa PIN aplikasi');
      } catch (e) {
        caught = e;
      }
      expect(guestSupportErrorOf(caught!), GuestSupportError.disabled);
      expect(requests.single.url.toString(), 'http://api.test/rest/v1/rpc/guest_start');
      expect(requests.single.headers['Authorization'], 'Bearer anon-key');
    });

    test('network failures surface as network errors', () async {
      final rpc = AnonymousRpc(
        supabaseUrl: 'http://api.test',
        anonKey: 'anon-key',
        httpClient: MockClient((request) async => throw http.ClientException('offline')),
      );
      Object? caught;
      try {
        await rpc.call('guest_config', const {}, schema: 'cs_api');
      } catch (e) {
        caught = e;
      }
      expect(guestSupportErrorOf(caught!), GuestSupportError.network);
    });
  });

  test('the memory store keeps the token only in memory', () async {
    final store = MemoryGuestSessionStore();
    expect(await store.read(), isNull);
    final token = GuestSupportToken(token: 'tok', expiresAt: DateTime.utc(2026, 11, 10));
    await store.write(token);
    expect(await store.read(), token);
    await store.clear();
    expect(await store.read(), isNull);
    expect(store.persistent, isFalse);
  });
}
