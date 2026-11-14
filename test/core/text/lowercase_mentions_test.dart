import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/chat_extras_repository_impl.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:rendezvous_community/src/features/drafts/data/repositories/post_draft_repository_impl.dart';
import 'package:rendezvous_community/src/features/edit/data/repositories/content_edit_repository_impl.dart';
import 'package:rendezvous_community/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:rendezvous_community/src/features/guest_support/data/repositories/guest_support_repository_impl.dart';
import 'package:rendezvous_community/src/features/post/data/repositories/comment_repository_impl.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_chat_repository.dart';

import '../../support/mock_api.dart';

const _typed = r'Halo @HIDAYAT2 dan @Sari_Invest, cek $BBCA #Dividen https://olt.co.id/@Promo email CS@OLT.CO.ID';
const _sent = r'Halo @hidayat2 dan @sari_invest, cek $BBCA #Dividen https://olt.co.id/@Promo email CS@OLT.CO.ID';

Map<String, Object?> _ticketJson() => {
  'id': 'gt-1',
  'ticket_number': 'CS-20261109-0042',
  'room_id': 'gr-1',
  'topic': 'account',
  'status': 'open',
  'created_at': '2026-11-09T02:00:00+00:00',
};

Map<String, Object?> _guestMessage() => {
  'id': 'm-1',
  'room_id': 'gr-1',
  'sender_id': 'guest-1',
  'sender_username': 'tamu_0123456789ab',
  'body': _sent,
  'is_deleted': false,
  'attachments': <Object?>[],
  'created_at': '2026-11-09T02:01:00+00:00',
  'kind': 'text',
  'sender_role': 'customer',
  'session_id': 'gt-1',
};

Object? _body(MockApi api, String fn, {bool rows = true}) {
  final captured = rows
      ? verify(() => api.rpcRows(fn, captureAny())).captured
      : verify(() => api.rpcValue(fn, captureAny())).captured;
  return (captured.single as Map<String, Object?>)['p_body'];
}

void main() {
  group('lowercaseMentions', () {
    test('lowercases mention tokens only', () {
      expect(lowercaseMentions('@HIDAYAT2'), '@hidayat2');
      expect(lowercaseMentions(_typed), _sent);
    });

    test('leaves cashtags, hashtags, links, emails and plain text alone', () {
      for (final text in [
        r'$BBCA naik',
        '#Dividen besar',
        'https://olt.co.id/@Promo',
        'www.OLT.co.id/@Promo',
        'Kirim ke CS@OLT.CO.ID',
        'Teks BIASA tanpa mention',
        '@AB terlalu pendek',
      ]) {
        expect(lowercaseMentions(text), text, reason: text);
      }
    });

    test('mention extraction ignores case', () {
      expect(extractMentions('@HIDAYAT2 @hidayat2 @Sari'), ['hidayat2', 'sari']);
    });
  });

  group('repositories send mentions in lowercase', () {
    late MockApi api;

    setUp(() {
      api = mockApi();
      when(() => api.rpcRows(any(), any())).thenAnswer((invocation) async {
        final fn = invocation.positionalArguments.first as String;
        return [
          switch (fn) {
            'create_post' || 'edit_post' => feedRow('p-1'),
            'create_comment' || 'edit_comment' => commentRow('c-1'),
            _ => messageRow('m-1'),
          },
        ];
      });
    });

    test('create post and edit post', () async {
      await FeedRepositoryImpl(api).createPost(body: _typed);
      expect(_body(api, 'create_post'), _sent);

      await ContentEditRepositoryImpl(api).editPost('p-1', _typed);
      expect(_body(api, 'edit_post'), _sent);
    });

    test('save post draft', () async {
      when(
        () => api.rpcValue('save_post_draft', any()),
      ).thenAnswer((_) async => {'client_draft_id': 'd1', 'body': _sent, 'updated_at': '2026-11-03T09:00:00+00:00'});
      await PostDraftRepositoryImpl(
        api,
      ).save(PostDraft(clientDraftId: 'd1', body: _typed, updatedAt: DateTime.utc(2026, 11, 3, 9)));
      expect(_body(api, 'save_post_draft', rows: false), _sent);
    });

    test('create comment, reply and edit comment', () async {
      final comments = CommentRepositoryImpl(api);
      await comments.createComment(postId: 'p-1', body: _typed);
      expect(_body(api, 'create_comment'), _sent);
      await comments.createComment(postId: 'p-1', parentId: 'c-0', body: '@BUDI setuju');
      expect(_body(api, 'create_comment'), '@budi setuju');

      await ContentEditRepositoryImpl(api).editComment('c-1', _typed);
      expect(_body(api, 'edit_comment'), _sent);
    });

    test('send, reply to and edit chat messages', () async {
      final chat = ChatRepositoryImpl(api);
      addTearDown(chat.dispose);
      await chat.sendMessage('r-1', body: _typed, clientId: 'c-1');
      expect(_body(api, 'send_message'), _sent);
      await chat.sendMessage('r-1', body: '@SARI_INVEST ini balasannya', clientId: 'c-2', replyToId: 'm-0');
      expect(_body(api, 'send_message'), '@sari_invest ini balasannya');

      await chat.editMessage('m-1', _typed);
      expect(_body(api, 'edit_message'), _sent);
    });

    test('share a post to chat and send stock cards with a message', () async {
      final extras = ChatExtrasRepositoryImpl(api);
      await extras.sharePost('r-1', 'p-1', body: ' $_typed ', clientId: 'c-1');
      expect(_body(api, 'share_post_to_chat'), _sent);

      await extras.sendStockCards('r-1', const ['BBCA'], clientId: 'c-2', body: _typed);
      expect(_body(api, 'send_message'), _sent);
    });

    test('CS chat messages', () async {
      await SupportChatRepository(api, rooms: () async => const []).sendMessage('r-1', body: _typed, clientId: 'c-1');
      expect(_body(api, 'send_message'), _sent);
    });
  });

  test('guest complaints send the description and messages in lowercase', () async {
    final calls = <String, Map<String, Object?>>{};
    final guest = GuestSupportRepositoryImpl((fn, params) async {
      calls[fn] = params;
      return switch (fn) {
        'guest_start' => {
          'token': 'tok-abcdefghijklmnopqrstuvwxyz',
          'expires_at': '2026-11-10T02:00:00+00:00',
          'ticket': _ticketJson(),
        },
        _ => _guestMessage(),
      };
    });

    await guest.start(name: 'Budi', problem: 'pin', description: _typed);
    expect(calls['guest_start']?['p_description'], _sent);

    await guest.send('tok-abcdefghijklmnopqrstuvwxyz', body: _typed, clientId: 'c-1');
    expect(calls['guest_send']?['p_body'], _sent);
  });
}
