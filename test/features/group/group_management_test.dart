import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/network/media_gateway.dart';
import 'package:rendezvous_community/src/features/chat/data/models/chat_models.dart';
import 'package:rendezvous_community/src/features/group/data/repositories/group_repository_impl.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/gen/community_localizations.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

ChatRoom _group({
  MemberRole role = MemberRole.owner,
  bool onlyAdminsSend = false,
  bool onlyAdminsEdit = true,
  String? description,
}) => ChatRoom(
  id: 'g',
  type: RoomType.group,
  name: 'Investor',
  createdAt: chatStart,
  lastReadAt: chatStart,
  myRole: role,
  memberCount: 3,
  onlyAdminsSend: onlyAdminsSend,
  onlyAdminsEdit: onlyAdminsEdit,
  description: description,
);

RoomMember _member(UserSummary user, MemberRole role) =>
    RoomMember(user: user, role: role, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart);

ChatMessage _event(String id, Map<String, Object?> payload, {int minute = 1, String body = 'fallback'}) => ChatMessage(
  id: id,
  roomId: 'g',
  body: body,
  kind: MessageKind.groupEvent,
  payload: payload,
  createdAt: chatStart.add(Duration(minutes: minute)),
);

class _GroupChat extends FakeChatRepository {
  _GroupChat({required ChatRoom room, required super.members, super.messages}) : super(rooms: [room]);

  final left = <String>[];
  int roomLoads = 0;

  @override
  Future<ChatRoom?> getRoom(String roomId) {
    roomLoads++;
    return super.getRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    left.add(roomId);
    rooms = [];
  }
}

Future<FakeFeatureDependencies> _pump(WidgetTester tester, ChatRepository chat, Widget child) async {
  useScreen(tester, const Size(900, 1200));
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  await pumpFeatureApp(
    tester,
    child,
    dependencies: FakeDependencies(chat: chat),
    features: features,
  );
  await tester.pumpAndSettle();
  return features;
}

void main() {
  group('group events', () {
    final id = lookupCommunityLocalizations(const Locale('id'));
    final en = lookupCommunityLocalizations(const Locale('en'));

    test('every event reads in Indonesian and English', () {
      final actor = {'actor_id': alice.id, 'actor_name': 'Alice'};
      final target = {'target_id': bob.id, 'target_name': 'Bob'};
      final cases = <Map<String, Object?>, (String, String)>{
        {'event': 'removed', ...actor, ...target}: ('Alice mengeluarkan Bob', 'Alice removed Bob'),
        {'event': 'promoted', ...actor, ...target}: ('Alice menjadikan Bob admin', 'Alice made Bob an admin'),
        {'event': 'demoted', ...actor, ...target}: ('Alice mencabut status admin Bob', 'Alice dismissed Bob as admin'),
        {'event': 'owner_changed', ...actor, ...target}: (
          'Alice menjadikan Bob pemilik grup',
          'Alice made Bob the group owner',
        ),
        {'event': 'left', ...actor}: ('Alice keluar', 'Alice left'),
        {'event': 'left', ...actor, 'new_owner_id': bob.id, 'new_owner_name': 'Bob'}: (
          'Alice keluar. Bob sekarang pemilik grup',
          'Alice left. Bob is now the group owner',
        ),
        {'event': 'renamed', ...actor, 'name': 'Investor Pro'}: (
          'Alice mengubah nama grup menjadi "Investor Pro"',
          'Alice renamed the group to "Investor Pro"',
        ),
        {'event': 'description_changed', ...actor, 'removed': true}: (
          'Alice menghapus deskripsi grup',
          'Alice removed the group description',
        ),
        {'event': 'photo_changed', ...actor, 'removed': false}: (
          'Alice mengubah foto grup',
          'Alice changed the group photo',
        ),
        {'event': 'settings_changed', ...actor, 'setting': 'only_admins_send', 'value': true}: (
          'Alice mengizinkan hanya admin mengirim pesan',
          'Alice allowed only admins to send messages',
        ),
        {'event': 'settings_changed', ...actor, 'setting': 'only_admins_edit', 'value': false}: (
          'Alice mengizinkan semua anggota mengubah info grup',
          'Alice allowed all members to edit group info',
        ),
      };
      for (final MapEntry(key: payload, value: (indonesian, english)) in cases.entries) {
        final message = _event('e', payload);
        expect(groupEventText(id, message), indonesian);
        expect(groupEventText(en, message), english);
      }
    });

    test('added lists up to three names and counts the rest', () {
      final message = _event('e', {
        'event': 'added',
        'actor_id': me.id,
        'actor_name': 'Budi',
        'targets': [
          for (final (i, name) in ['Alice', 'Bob', 'Cici', 'Dodi'].indexed) {'id': 'u-$i', 'name': name},
        ],
        'count': 5,
      });
      expect(groupEventText(id, message, meId: me.id), 'Anda menambahkan Alice, Bob, Cici dan 2 lainnya');
      expect(groupEventText(en, message, meId: me.id), 'You added Alice, Bob, Cici and 2 others');
    });

    test('the current user reads as Anda / you and unknown events fall back to the server text', () {
      final removedMe = _event('e', {
        'event': 'removed',
        'actor_id': alice.id,
        'actor_name': 'Alice',
        'target_id': me.id,
        'target_name': 'Budi',
      });
      expect(groupEventText(id, removedMe, meId: me.id), 'Alice mengeluarkan Anda');
      expect(groupEventText(en, removedMe, meId: me.id), 'Alice removed you');
      expect(GroupEvent.fromMessage(removedMe).removes(me.id), isTrue);
      expect(
        groupEventText(id, _event('e', {'event': 'pinned', 'actor_id': alice.id}, body: 'Teks server')),
        'Teks server',
      );
    });
  });

  group('data', () {
    test('room summaries read the group info and settings', () {
      final room = RoomSummaryModel.fromJson({
        'id': 'g',
        'type': 'group',
        'name': 'Investor',
        'created_at': '2026-11-11T00:00:00Z',
        'last_read_at': '2026-11-11T00:00:00Z',
        'my_role': 'member',
        'description': 'Diskusi saham',
        'avatar_url': 'https://cdn.test/g.png',
        'only_admins_send': true,
        'only_admins_edit': false,
      }).toEntity();
      expect(room.description, 'Diskusi saham');
      expect(room.avatarUrl, 'https://cdn.test/g.png');
      expect(room.canSend, isFalse);
      expect(room.canEditGroupInfo, isTrue);
      expect(room.isGroupAdmin, isFalse);
      expect(parseMessageKind('group_event'), MessageKind.groupEvent);
    });

    test('older servers without the columns keep the defaults', () {
      final room = RoomSummaryModel.fromJson({
        'id': 'g',
        'type': 'group',
        'created_at': '2026-11-11T00:00:00Z',
        'last_read_at': '2026-11-11T00:00:00Z',
        'my_role': 'admin',
      }).toEntity();
      expect(room.onlyAdminsSend, isFalse);
      expect(room.onlyAdminsEdit, isTrue);
      expect(room.canSend, isTrue);
      expect(room.canEditGroupInfo, isTrue);
    });

    group('GroupRepositoryImpl', () {
      late MockApi api;
      late GroupRepositoryImpl groups;

      setUpAll(() => registerFallbackValue(Uint8List(0)));

      setUp(() {
        api = mockApi();
        groups = GroupRepositoryImpl(api);
        when(() => api.rpcValue(any(), any())).thenAnswer((_) async => null);
      });

      test('calls the group RPCs with only the given fields', () async {
        when(() => api.rpcValue('add_room_members', any())).thenAnswer((_) async => 2);

        expect(await groups.addMembers('g', ['u-a', 'u-b']), 2);
        await groups.removeMember('g', 'u-a');
        await groups.setMemberRole('g', 'u-a', MemberRole.admin);
        await groups.setMemberRole('g', 'u-a', MemberRole.member);
        await groups.transferOwnership('g', 'u-b');
        await groups.updateInfo('g', description: '');
        await groups.removePhoto('g');
        await groups.updateSettings('g', onlyAdminsSend: true);

        final calls = verify(() => api.rpcValue(captureAny(), captureAny())).captured;
        expect(calls, [
          'add_room_members',
          {
            'p_room_id': 'g',
            'p_user_ids': ['u-a', 'u-b'],
          },
          'remove_room_member',
          {'p_room_id': 'g', 'p_user_id': 'u-a'},
          'set_room_member_role',
          {'p_room_id': 'g', 'p_user_id': 'u-a', 'p_role': 'admin'},
          'set_room_member_role',
          {'p_room_id': 'g', 'p_user_id': 'u-a', 'p_role': 'member'},
          'transfer_room_ownership',
          {'p_room_id': 'g', 'p_user_id': 'u-b'},
          'update_group_info',
          {'p_room_id': 'g', 'p_description': ''},
          'update_group_info',
          {'p_room_id': 'g', 'p_avatar_url': ''},
          'update_group_settings',
          {'p_room_id': 'g', 'p_only_admins_send': true},
        ]);
      });

      test('the group photo goes to the uploader avatar folder and rejects GIF', () async {
        when(
          () => api.upload(
            any(),
            any(),
            any(),
            contentType: any(named: 'contentType'),
            upsert: any(named: 'upsert'),
          ),
        ).thenAnswer(
          (invocation) async => UploadedObject(
            bucket: 'avatars',
            path: invocation.positionalArguments[1] as String,
            mime: 'image/png',
            size: 4,
          ),
        );
        when(() => api.publicUrl(any(), any())).thenAnswer((i) => 'https://cdn.test/${i.positionalArguments[1]}');

        final url = await groups.uploadPhoto('g', Uint8List(4), mimeType: 'image/png');

        expect(url, matches(RegExp(r'^https://cdn\.test/u-1/group-g-\d+\.png$')));
        verify(() => api.rpcValue('update_group_info', {'p_room_id': 'g', 'p_avatar_url': url})).called(1);
        await expectLater(
          groups.uploadPhoto('g', Uint8List(4), mimeType: 'image/gif'),
          throwsA(isA<CommunityException>()),
        );
      });
    });
  });

  group('chat room', () {
    testWidgets('group events render as centered notices', (tester) async {
      final chat = _GroupChat(
        room: _group(),
        members: [_member(me, MemberRole.owner), _member(alice, MemberRole.member)],
        messages: [
          _event('e-1', {
            'event': 'promoted',
            'actor_id': me.id,
            'actor_name': 'Budi',
            'target_id': alice.id,
            'target_name': 'Alice',
          }),
        ],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityChatRoom(roomId: 'g'));

      expect(find.text('Anda menjadikan Alice admin'), findsOneWidget);
      expect(find.byType(GroupEventNotice), findsOneWidget);
    });

    testWidgets('members of an admins-only group get a notice instead of the composer', (tester) async {
      final chat = _GroupChat(
        room: _group(role: MemberRole.member, onlyAdminsSend: true),
        members: [_member(me, MemberRole.member), _member(alice, MemberRole.owner)],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityChatRoom(roomId: 'g'));

      expect(find.text('Hanya admin yang bisa mengirim pesan di grup ini.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('admins keep the composer in an admins-only group', (tester) async {
      final chat = _GroupChat(
        room: _group(role: MemberRole.admin, onlyAdminsSend: true),
        members: [_member(me, MemberRole.admin), _member(alice, MemberRole.owner)],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityChatRoom(roomId: 'g'));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a live group event reloads the room and a removal locks the composer', (tester) async {
      final chat = _GroupChat(
        room: _group(role: MemberRole.member),
        members: [_member(me, MemberRole.member), _member(alice, MemberRole.owner)],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityChatRoom(roomId: 'g'));
      final loads = chat.roomLoads;

      chat.rooms = [_group(role: MemberRole.member, onlyAdminsSend: true)];
      chat.roomEvents.add(
        MessageUpserted(
          _event('e-1', {
            'event': 'settings_changed',
            'actor_id': alice.id,
            'actor_name': 'Alice',
            'setting': 'only_admins_send',
            'value': true,
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(chat.roomLoads, loads + 1);
      expect(find.text('Hanya admin yang bisa mengirim pesan di grup ini.'), findsOneWidget);

      chat.roomEvents.add(
        MessageUpserted(
          _event('e-2', {
            'event': 'removed',
            'actor_id': alice.id,
            'actor_name': 'Alice',
            'target_id': me.id,
            'target_name': 'Budi',
          }, minute: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alice mengeluarkan Anda'), findsOneWidget);
      expect(find.text('Anda bukan lagi anggota grup ini.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('group info', () {
    testWidgets('the owner manages members, info and settings', (tester) async {
      final chat = _GroupChat(
        room: _group(description: 'Diskusi saham'),
        members: [_member(me, MemberRole.owner), _member(alice, MemberRole.admin), _member(bob, MemberRole.member)],
      );
      addTearDown(chat.dispose);
      final features = await _pump(tester, chat, const CommunityGroupInfo(roomId: 'g'));
      final groups = features.groups;

      expect(find.text('Diskusi saham'), findsOneWidget);
      expect(find.text('Anda'), findsOneWidget);
      expect(find.text('Pemilik grup'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Tambah anggota'), findsOneWidget);

      await tester.tap(find.text('Hanya admin yang bisa mengirim pesan'));
      await tester.pumpAndSettle();
      expect(groups.calls.last, 'settings g true null');

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(find.text('Jadikan admin'), findsOneWidget);
      expect(find.text('Cabut status admin'), findsNothing);
      await tester.tap(find.text('Jadikan admin'));
      await tester.pumpAndSettle();
      expect(groups.calls.last, 'role g u-b admin');

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cabut status admin'));
      await tester.pumpAndSettle();
      expect(groups.calls.last, 'role g u-a member');

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluarkan dari grup'));
      await tester.pumpAndSettle();
      expect(find.text('Keluarkan Bob dari grup?'), findsOneWidget);
      await tester.tap(find.text('Keluarkan dari grup').last);
      await tester.pumpAndSettle();
      expect(groups.calls.last, 'remove g u-b');

      await tester.tap(find.text('Ubah info grup'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)).first,
        'Investor Pro',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(groups.calls.last, 'info g Investor Pro null');
    });

    testWidgets('an admin cannot dismiss admins, remove the owner, or transfer ownership', (tester) async {
      final chat = _GroupChat(
        room: _group(role: MemberRole.admin),
        members: [_member(me, MemberRole.admin), _member(alice, MemberRole.owner), _member(bob, MemberRole.admin)],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityGroupInfo(roomId: 'g'));

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(find.text('Lihat profil'), findsOneWidget);
      expect(find.text('Keluarkan dari grup'), findsNothing);
      expect(find.text('Jadikan pemilik grup'), findsNothing);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(find.text('Cabut status admin'), findsNothing);
      expect(find.text('Keluarkan dari grup'), findsNothing);
    });

    testWidgets('members see no settings or management, and edit info only when allowed', (tester) async {
      final chat = _GroupChat(
        room: _group(role: MemberRole.member, onlyAdminsEdit: false),
        members: [_member(me, MemberRole.member), _member(alice, MemberRole.owner)],
      );
      addTearDown(chat.dispose);
      await _pump(tester, chat, const CommunityGroupInfo(roomId: 'g'));

      expect(find.text('Pengaturan grup'), findsNothing);
      expect(find.text('Tambah anggota'), findsNothing);
      expect(find.text('Ubah info grup'), findsOneWidget);
      expect(find.text('Belum ada deskripsi grup'), findsOneWidget);
    });

    testWidgets('the owner can hand over the group and leaving pops with true', (tester) async {
      final chat = _GroupChat(
        room: _group(),
        members: [_member(me, MemberRole.owner), _member(alice, MemberRole.member)],
      );
      addTearDown(chat.dispose);
      bool? popped;
      final features = await _pump(
        tester,
        chat,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => popped = await CommunityNavigator.openGroupInfo(context, 'g'),
            child: const Text('info'),
          ),
        ),
      );
      await tester.tap(find.text('info'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jadikan pemilik grup'));
      await tester.pumpAndSettle();
      expect(find.text('Jadikan Alice pemilik grup? Anda akan menjadi admin.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Jadikan pemilik grup'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'owner g u-a');

      await tester.tap(find.text('Keluar dari grup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar').last);
      await tester.pumpAndSettle();
      expect(chat.left, ['g']);
      expect(popped, isTrue);
    });

    testWidgets('action errors show the group message', (tester) async {
      final chat = _GroupChat(
        room: _group(),
        members: [_member(me, MemberRole.owner), _member(alice, MemberRole.member)],
      );
      addTearDown(chat.dispose);
      final features = await _pump(tester, chat, const CommunityGroupInfo(roomId: 'g'));
      features.groups.error = const CommunityException(CommunityErrorKind.forbidden, code: 'group_admins_only_edit');

      await tester.tap(find.text('Hanya admin yang bisa mengubah info grup'));
      await tester.pumpAndSettle();
      expect(find.text('Hanya admin yang bisa mengubah info grup.'), findsOneWidget);
    });
  });
}
