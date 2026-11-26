import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/chat_extras_repository_impl.dart';

import '../../support/mock_api.dart';

void main() {
  group('share limits', () {
    test('reads max targets and the hourly quota', () async {
      final api = mockApi();
      when(() => api.rpcValue('get_share_limits', any())).thenAnswer((_) async => {'max_targets': 10, 'per_hour': 60});

      final limits = await ChatExtrasRepositoryImpl(api).shareLimits();

      expect(limits.maxTargets, 10);
      expect(limits.perHour, 60);
    });
  });

  group('search', () {
    test('blank queries never reach the server', () async {
      final api = mockApi();

      expect(await ChatExtrasRepositoryImpl(api).searchShareTargets('  '), isEmpty);
      verifyNever(() => api.rpcRows(any(), any()));
    });

    test('maps users, groups and stocks with their send state', () async {
      final api = mockApi();
      when(() => api.rpcRows('search_share_targets', any())).thenAnswer(
        (_) async => [
          {
            'kind': 'user',
            'room_id': null,
            'user_id': 'u-2',
            'username': 'hendi',
            'display_name': 'Hendi',
            'avatar_url': null,
            'is_verified': true,
            'is_official': false,
            'group_name': null,
            'stock_code': null,
            'can_send': true,
            'reason': 'message_request',
          },
          {
            'kind': 'user',
            'room_id': 'r-9',
            'user_id': 'u-3',
            'username': 'leni',
            'display_name': null,
            'avatar_url': null,
            'is_verified': false,
            'is_official': false,
            'group_name': null,
            'stock_code': null,
            'can_send': false,
            'reason': 'dm_not_allowed',
          },
          {
            'kind': 'group',
            'room_id': 'r-g',
            'user_id': null,
            'username': null,
            'display_name': null,
            'avatar_url': null,
            'is_verified': false,
            'is_official': false,
            'group_name': 'Swing club',
            'stock_code': null,
            'can_send': true,
            'reason': null,
          },
          {
            'kind': 'stock',
            'room_id': null,
            'user_id': null,
            'username': null,
            'display_name': null,
            'avatar_url': null,
            'is_verified': false,
            'is_official': false,
            'group_name': null,
            'stock_code': 'AADI',
            'can_send': true,
            'reason': null,
          },
          {'kind': 'mystery', 'can_send': true},
        ],
      );

      final results = await ChatExtrasRepositoryImpl(api).searchShareTargets(r' $aad ', limit: 15);

      verify(() => api.rpcRows('search_share_targets', {'p_query': r'$aad', 'p_limit': 15})).called(1);
      expect(results.map((t) => t.kind), [
        ShareTargetKind.user,
        ShareTargetKind.user,
        ShareTargetKind.group,
        ShareTargetKind.stock,
      ]);
      final hendi = results[0];
      expect(hendi.user?.username, 'hendi');
      expect(hendi.user?.isVerified, isTrue);
      expect(hendi.canSend, isTrue);
      expect(hendi.reason, ShareTargetReason.messageRequest);
      expect(hendi.ref.userId, 'u-2');
      expect(hendi.ref.key, 'user:u-2');
      final leni = results[1];
      expect(leni.canSend, isFalse);
      expect(leni.reason, ShareTargetReason.dmNotAllowed);
      expect(leni.ref.roomId, 'r-9');
      expect(leni.ref.key, 'room:r-9');
      expect(results[2].groupName, 'Swing club');
      expect(results[2].ref.key, 'room:r-g');
      expect(results[3].stockCode, 'AADI');
      expect(results[3].ref.key, 'stock:AADI');
    });
  });

  group('send', () {
    test('sends every target with its client id and reports each result', () async {
      final api = mockApi();
      when(() => api.rpcRows('share_post_to_targets', any())).thenAnswer(
        (_) async => [
          {
            'target_index': 0,
            'kind': 'room',
            'target': 'r-1',
            'room_id': 'r-1',
            'status': 'sent',
            'error_code': null,
            'message_id': 'm-1',
          },
          {
            'target_index': 1,
            'kind': 'user',
            'target': 'u-2',
            'room_id': null,
            'status': 'failed',
            'error_code': 'dm_not_allowed',
            'message_id': null,
          },
          {
            'target_index': 2,
            'kind': 'stock',
            'target': 'AADI',
            'room_id': null,
            'status': 'failed',
            'error_code': 'rate_limited',
            'message_id': null,
          },
        ],
      );

      final results = await ChatExtrasRepositoryImpl(api).sharePostToTargets('p-1', const [
        ShareTargetRequest(ShareTargetRef.room('r-1'), clientId: 'c-1'),
        ShareTargetRequest(ShareTargetRef.user('u-2'), clientId: 'c-2'),
        ShareTargetRequest(ShareTargetRef.stock('aadi'), clientId: 'c-3'),
      ], body: '  Lihat @Budi  ');

      final params =
          verify(() => api.rpcRows('share_post_to_targets', captureAny())).captured.single as Map<String, Object?>;
      expect(params['p_post_id'], 'p-1');
      expect(params['p_body'], 'Lihat @budi');
      expect(params['p_targets'], [
        {'room_id': 'r-1', 'client_id': 'c-1'},
        {'user_id': 'u-2', 'client_id': 'c-2'},
        {'stock_code': 'AADI', 'client_id': 'c-3'},
      ]);
      expect(results, hasLength(3));
      expect(results[0].sent, isTrue);
      expect(results[0].roomId, 'r-1');
      expect(results[0].messageId, 'm-1');
      expect(results[0].request.ref.key, 'room:r-1');
      expect(results[1].sent, isFalse);
      expect(results[1].error?.code, 'dm_not_allowed');
      expect(results[1].error?.kind, CommunityErrorKind.forbidden);
      expect(results[2].error?.kind, CommunityErrorKind.rateLimited);
      expect(results[2].request.ref.key, 'stock:AADI');
    });

    test('an empty body is sent as null', () async {
      final api = mockApi();
      when(() => api.rpcRows('share_post_to_targets', any())).thenAnswer((_) async => const []);

      await ChatExtrasRepositoryImpl(
        api,
      ).sharePostToTargets('p-1', const [ShareTargetRequest(ShareTargetRef.room('r-1'), clientId: 'c-1')], body: '  ');

      final params =
          verify(() => api.rpcRows('share_post_to_targets', captureAny())).captured.single as Map<String, Object?>;
      expect(params['p_body'], isNull);
    });
  });

  group('messages', () {
    testWidgets('new share error codes and reasons have readable text', (tester) async {
      late CommunityLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: communityLocalizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = context.communityL10n;
              return const SizedBox();
            },
          ),
        ),
      );

      String message(String code) => l10n.errorMessage(CommunityException(CommunityErrorKind.invalidInput, code: code));
      expect(message('too_many_targets'), l10n.errorTooManyTargets);
      expect(message('duplicate_target'), l10n.errorDuplicateTarget);
      expect(message('blocked'), l10n.errorBlockedTarget);
      expect(message('not_member'), l10n.errorNotMember);
      expect(message('user_not_found'), l10n.errorUserNotFound);
      expect(message('invalid_target'), l10n.errorInvalidTarget);
      expect(l10n.shareTargetReason(ShareTargetReason.dmNotAllowed), 'Tidak menerima pesan');
      expect(l10n.shareTargetReason(ShareTargetReason.messageRequest), 'Dikirim sebagai permintaan pesan');
      expect(l10n.shareTargetReason(ShareTargetReason.groupAdminsOnly), 'Hanya admin yang bisa mengirim');
      expect(l10n.shareTargetReason(ShareTargetReason.roomDisabled), 'Room sedang ditutup');
      expect(l10n.shareTargetReason(ShareTargetReason.cannotSend), 'Tidak bisa dikirimi');
    });
  });
}
