import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

const _photo = 'https://cdn.test/g.png';

ChatRoom _group({MemberRole role = MemberRole.owner, bool onlyAdminsEdit = true, String? photo, String? description}) =>
    ChatRoom(
      id: 'g',
      type: RoomType.group,
      name: 'Investor',
      description: description,
      avatarUrl: photo,
      createdAt: chatStart,
      lastReadAt: chatStart,
      myRole: role,
      onlyAdminsEdit: onlyAdminsEdit,
    );

RoomMember _member(UserSummary user, MemberRole role) =>
    RoomMember(user: user, role: role, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart);

class _GatedChat extends FakeChatRepository {
  _GatedChat({required super.rooms, required super.members});

  final left = <String>[];
  Completer<void>? gate;

  @override
  Future<ChatRoom?> getRoom(String roomId) async {
    await gate?.future;
    return super.getRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) async => left.add(roomId);
}

void main() {
  late FakeFeatureDependencies features;
  late _GatedChat chat;
  late CommunityGroupInfoPageDetails details;

  Future<void> pump(WidgetTester tester, ChatRoom room, CommunityChatBuilders builders) async {
    useScreen(tester, const Size(900, 1400));
    chat = _GatedChat(
      rooms: [room],
      members: [_member(me, room.myRole), _member(alice, MemberRole.admin), _member(bob, MemberRole.member)],
    );
    addTearDown(chat.dispose);
    features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    await pumpFeatureApp(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(chat: builders),
        child: const CommunityGroupInfo(roomId: 'g'),
      ),
      dependencies: FakeDependencies(chat: chat),
      features: features,
    );
    await tester.pumpAndSettle();
  }

  CommunityChatBuilders capture({Widget Function(CommunityGroupInfoPageDetails d)? page}) => CommunityChatBuilders(
    groupInfoPage: (context, d, fallback) {
      details = d;
      return page?.call(d) ?? const Text('halaman host');
    },
  );

  Widget hostColumn(CommunityGroupInfoPageDetails d) => ColoredBox(
    color: const Color(0xFFFFFFFF),
    child: SingleChildScrollView(
      child: Column(children: [Text(d.settingsTitle), ...d.settings, Text(d.membersTitle), ...d.members]),
    ),
  );

  group('delete group', () {
    testWidgets('only the owner sees Hapus grup and it asks before deleting', (tester) async {
      await pump(tester, _group(), const CommunityChatBuilders());
      await tester.scrollUntilVisible(find.text('Hapus grup'), 200);
      await tester.tap(find.text('Hapus grup'));
      await tester.pumpAndSettle();
      expect(find.text('Grup akan dihapus untuk semua anggota dan tidak bisa dikembalikan.'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus grup'));
      await tester.pumpAndSettle();
      expect(chat.deletedGroups, ['g']);
    });

    for (final role in [MemberRole.admin, MemberRole.member]) {
      testWidgets('a ${role.name} does not get Hapus grup', (tester) async {
        await pump(tester, _group(role: role), capture());
        expect(details.onDeleteGroup, isNull);
      });
    }

    testWidgets('the owner gets the delete handler in the details', (tester) async {
      await pump(tester, _group(), capture());
      expect(details.onDeleteGroup, isNotNull);
      expect(details.deleteGroupLabel, 'Hapus grup');
    });
  });

  group('details', () {
    testWidgets('replace the whole page and give an owner everything', (tester) async {
      await pump(tester, _group(photo: _photo, description: 'Diskusi saham'), capture());

      expect(find.text('halaman host'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(details.room.id, 'g');
      expect(details.title, 'Investor');
      expect(details.memberCount, 3);
      expect(details.membersLabel, '3 anggota');
      expect(details.description, 'Diskusi saham');
      expect(details.descriptionEmptyLabel, 'Belum ada deskripsi grup');
      expect(details.canEditInfo, isTrue);
      expect(details.isAdmin, isTrue);
      expect(details.hasPhoto, isTrue);
      expect(details.busy, isFalse);
      expect(details.onEditInfo, isNotNull);
      expect(details.onChangePhoto, isNotNull);
      expect(details.onRemovePhoto, isNotNull);
      expect(details.onAddMembers, isNotNull);
      expect(details.editInfoLabel, 'Ubah info grup');
      expect(details.changePhotoLabel, 'Ganti foto grup');
      expect(details.removePhotoLabel, 'Hapus foto grup');
      expect(details.settingsTitle, 'Pengaturan grup');
      expect(details.settings, hasLength(2));
      expect(details.membersTitle, '3 anggota');
      expect(details.members, hasLength(3));
      expect(details.addMembersLabel, 'Tambah anggota');
      expect(details.leaveLabel, 'Keluar dari grup');
    });

    testWidgets('a regular member gets no editing, settings or adding', (tester) async {
      await pump(tester, _group(role: MemberRole.member, photo: _photo), capture());

      expect(details.canEditInfo, isFalse);
      expect(details.isAdmin, isFalse);
      expect(details.hasPhoto, isTrue);
      expect(details.onEditInfo, isNull);
      expect(details.onChangePhoto, isNull);
      expect(details.onRemovePhoto, isNull);
      expect(details.onAddMembers, isNull);
      expect(details.settings, isEmpty);
      expect(details.members, hasLength(3));
      expect(details.description, isNull);
    });

    testWidgets('a member allowed to edit can edit but has no photo to remove', (tester) async {
      await pump(tester, _group(role: MemberRole.member, onlyAdminsEdit: false), capture());

      expect(details.canEditInfo, isTrue);
      expect(details.hasPhoto, isFalse);
      expect(details.onEditInfo, isNotNull);
      expect(details.onChangePhoto, isNotNull);
      expect(details.onRemovePhoto, isNull);
      expect(details.onAddMembers, isNull);
    });

    testWidgets('avatar uses the default size and buildAvatar takes any radius', (tester) async {
      await pump(
        tester,
        _group(),
        CommunityChatBuilders(
          roomAvatar: (context, d, fallback) => Text('avatar ${d.radius}'),
          groupInfoPage: (context, d, fallback) => Column(children: [d.avatar, d.buildAvatar(radius: 12)]),
        ),
      );

      expect(find.text('avatar 44.0'), findsOneWidget);
      expect(find.text('avatar 12.0'), findsOneWidget);
    });
  });

  group('callbacks run the library logic', () {
    testWidgets('onEditInfo opens the edit dialog', (tester) async {
      await pump(tester, _group(), capture());

      details.onEditInfo!();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AlertDialog, 'Ubah info grup'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Investor Pro');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(features.groups.calls.last, 'info g Investor Pro null');
    });

    testWidgets('onAddMembers opens the add members dialog', (tester) async {
      await pump(tester, _group(), capture());

      details.onAddMembers!();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AlertDialog, 'Tambah anggota'), findsOneWidget);
    });

    testWidgets('onChangePhoto opens the file picker for images', (tester) async {
      await pump(tester, _group(), capture());
      final calls = <MethodCall>[];
      const channel = MethodChannel('plugins.flutter.io/file_selector');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      details.onChangePhoto!();
      await tester.pumpAndSettle();

      expect(calls.single.method, 'openFile');
      expect(calls.single.arguments.toString(), contains('webp'));
      expect(features.groups.calls, isEmpty);
    });

    testWidgets('onRemovePhoto removes the photo', (tester) async {
      await pump(tester, _group(photo: _photo), capture());

      details.onRemovePhoto!();
      await tester.pumpAndSettle();

      expect(features.groups.calls.last, 'photo-remove g');
    });

    testWidgets('onLeave asks first and only leaves after confirming', (tester) async {
      await pump(tester, _group(), capture());

      details.onLeave();
      await tester.pumpAndSettle();
      expect(find.text('Keluar dari grup ini?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(chat.left, isEmpty);

      details.onLeave();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
      await tester.pumpAndSettle();
      expect(chat.left, ['g']);
    });

    testWidgets('busy is reported and the library blocks taps meanwhile', (tester) async {
      var taps = 0;
      await pump(
        tester,
        _group(photo: _photo),
        capture(
          page: (d) => TextButton(onPressed: () => taps++, child: const Text('tombol host')),
        ),
      );

      chat.gate = Completer<void>();
      details.onRemovePhoto!();
      await tester.pump();
      await tester.pump();
      expect(details.busy, isTrue);
      await tester.tap(find.text('tombol host'), warnIfMissed: false);
      expect(taps, 0);

      chat.gate!.complete();
      await tester.pumpAndSettle();
      expect(details.busy, isFalse);
      await tester.tap(find.text('tombol host'));
      expect(taps, 1);
    });
  });

  group('host layout', () {
    testWidgets('settings and members work inside a host Column on a colored background', (tester) async {
      await pump(tester, _group(), capture(page: hostColumn));

      expect(tester.takeException(), isNull);
      expect(find.byType(SwitchListTile), findsNWidgets(2));
      expect(find.text('Alice'), findsOneWidget);
      final nearest = tester.widget<Material>(
        find.ancestor(of: find.byType(SwitchListTile).first, matching: find.byType(Material)).first,
      );
      expect(nearest.type, MaterialType.transparency);
      final tile = tester.widget<Material>(
        find.ancestor(of: find.text('Alice'), matching: find.byType(Material)).first,
      );
      expect(tile.type, MaterialType.transparency);

      await tester.tap(find.text('Hanya admin yang bisa mengirim pesan'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'settings g true null');

      await tester.tap(find.text('Bob'));
      await tester.pumpAndSettle();
      expect(find.text('Jadikan admin'), findsOneWidget);
    });

    testWidgets('the groupSetting and groupMember slots still apply in a host page', (tester) async {
      await pump(
        tester,
        _group(),
        CommunityChatBuilders(
          groupInfoPage: (context, d, fallback) => Column(children: [...d.settings, ...d.members]),
          groupSetting: (context, d, fallback) => Text('atur ${d.kind.name}'),
          groupMember: (context, d, fallback) => Text('anggota ${d.title}'),
        ),
      );

      expect(find.text('atur onlyAdminsSend'), findsOneWidget);
      expect(find.text('atur onlyAdminsEdit'), findsOneWidget);
      expect(find.text('anggota Alice'), findsOneWidget);
      expect(find.text('anggota Anda'), findsOneWidget);
    });

    testWidgets('the fallback can be shown by a host wrapper', (tester) async {
      await pump(
        tester,
        _group(),
        CommunityChatBuilders(
          groupInfoPage: (context, d, fallback) => Column(
            children: [
              const Text('banner host'),
              Expanded(child: fallback),
            ],
          ),
        ),
      );

      expect(find.text('banner host'), findsOneWidget);
      expect(find.text('Tambah anggota'), findsOneWidget);
    });
  });

  group('default page', () {
    testWidgets('keeps the same sections in the same order', (tester) async {
      await pump(tester, _group(description: 'Diskusi saham'), const CommunityChatBuilders());

      double top(String text) => tester.getTopLeft(find.text(text).first).dy;
      final tops = [
        for (final text in [
          'Investor',
          'Diskusi saham',
          'Ubah info grup',
          'Pengaturan grup',
          'Hanya admin yang bisa mengirim pesan',
          'Hanya admin yang bisa mengubah info grup',
          'Tambah anggota',
          'Anda',
          'Keluar dari grup',
        ])
          top(text),
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(find.text('3 anggota'), findsNWidgets(2));
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byTooltip('Ganti foto grup'), findsOneWidget);
    });

    testWidgets('the photo menu has no removal without a photo', (tester) async {
      await pump(tester, _group(), const CommunityChatBuilders());

      await tester.tap(find.byTooltip('Ganti foto grup'));
      await tester.pumpAndSettle();

      expect(find.text('Ganti foto grup'), findsOneWidget);
      expect(find.text('Hapus foto grup'), findsNothing);
    });

    testWidgets('the photo menu removes an existing photo', (tester) async {
      await pump(tester, _group(photo: _photo), const CommunityChatBuilders());

      await tester.tap(find.byTooltip('Ganti foto grup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus foto grup'));
      await tester.pumpAndSettle();

      expect(features.groups.calls.last, 'photo-remove g');
    });

    testWidgets('members see neither the photo menu nor the edit button', (tester) async {
      await pump(tester, _group(role: MemberRole.member), const CommunityChatBuilders());

      expect(find.byTooltip('Ganti foto grup'), findsNothing);
      expect(find.text('Ubah info grup'), findsNothing);
      expect(find.text('Pengaturan grup'), findsNothing);
      expect(find.text('Keluar dari grup'), findsOneWidget);
    });
  });
}
