import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

const _carol = UserSummary(id: 'u-c', username: 'carol', displayName: 'Carol');
final _official = _carol.copyWith(id: 'u-o', username: 'resmi', displayName: 'Resmi', isOfficial: true);

ChatRoom _group({MemberRole role = MemberRole.owner}) => ChatRoom(
  id: 'g',
  type: RoomType.group,
  name: 'Investor',
  description: 'Diskusi saham',
  createdAt: chatStart,
  lastReadAt: chatStart,
  myRole: role,
);

RoomMember _member(UserSummary user, MemberRole role) =>
    RoomMember(user: user, role: role, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart);

class _Profiles extends Fake implements ProfileRepository {
  _Profiles(this.found);

  final List<UserSummary> found;

  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async => found;
}

void main() {
  late FakeDependencies deps;
  late FakeFeatureDependencies features;

  Future<void> pump(
    WidgetTester tester,
    CommunityChatBuilders builders, {
    MemberRole role = MemberRole.owner,
    List<UserSummary> found = const [],
  }) async {
    useScreen(tester, const Size(900, 1200));
    final chat = FakeChatRepository(
      rooms: [_group(role: role)],
      members: [_member(me, role), _member(alice, MemberRole.admin), _member(bob, MemberRole.member)],
    );
    addTearDown(chat.dispose);
    features = FakeFeatureDependencies(config: loadedConfig());
    addTearDown(features.dispose);
    deps = FakeDependencies(chat: chat, profiles: _Profiles(found));
    await pumpFeatureApp(
      tester,
      CommunityBuildersScope(
        builders: CommunityBuilders(chat: builders),
        child: const CommunityGroupInfo(roomId: 'g'),
      ),
      dependencies: deps,
      features: features,
    );
    await tester.pumpAndSettle();
  }

  group('groupSetting', () {
    testWidgets('replaces both switches and reports the setting that changed', (tester) async {
      final seen = <GroupSetting, CommunityGroupSettingDetails>{};
      await pump(
        tester,
        CommunityChatBuilders(
          groupSetting: (context, d, fallback) {
            seen[d.kind] = d;
            return TextButton(onPressed: () => d.onChanged(!d.value), child: Text('atur ${d.kind.name} ${d.value}'));
          },
        ),
      );

      expect(find.byType(SwitchListTile), findsNothing);
      expect(seen[GroupSetting.onlyAdminsSend]!.title, 'Hanya admin yang bisa mengirim pesan');
      expect(seen[GroupSetting.onlyAdminsEdit]!.title, 'Hanya admin yang bisa mengubah info grup');

      await tester.tap(find.text('atur onlyAdminsSend false'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'settings g true null');

      await tester.tap(find.text('atur onlyAdminsEdit true'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'settings g null false');
    });
  });

  group('groupEditDialog', () {
    late CommunityGroupEditDetails details;
    late CommunityDependencies dialogScope;

    CommunityChatBuilders builders() => CommunityChatBuilders(
      groupEditDialog: (context, d, fallback) {
        details = d;
        dialogScope = CommunityScope.of(context);
        return AlertDialog(
          content: Text('edit ${d.canSave}'),
          actions: [
            TextButton(onPressed: d.onCancel, child: const Text('batal host')),
            TextButton(onPressed: d.onSave, child: const Text('simpan host')),
          ],
        );
      },
    );

    Future<void> open(WidgetTester tester) async {
      await pump(tester, builders());
      await tester.tap(find.text('Ubah info grup'));
      await tester.pumpAndSettle();
    }

    testWidgets('is carried into the dialog with display-ready details', (tester) async {
      await open(tester);

      expect(find.byType(TextField), findsNothing);
      expect(identical(dialogScope, deps), isTrue);
      expect(details.nameController.text, 'Investor');
      expect(details.descriptionController.text, 'Diskusi saham');
      expect(details.nameMaxLength, 80);
      expect(details.descriptionMaxLength, 500);
      expect(details.title, 'Ubah info grup');
      expect(details.nameLabel, 'Nama grup');
      expect(details.descriptionLabel, 'Deskripsi');
      expect(details.saveLabel, 'Simpan');
      expect(details.cancelLabel, 'Batal');
    });

    testWidgets('canSave follows the name controller without any host callback', (tester) async {
      await open(tester);
      expect(find.text('edit true'), findsOneWidget);

      details.nameController.text = '   ';
      await tester.pump();
      expect(details.canSave, isFalse);
      expect(find.text('edit false'), findsOneWidget);

      details.nameController.text = 'Investor Pro';
      await tester.pump();
      expect(details.canSave, isTrue);
    });

    testWidgets('onSave sends the trimmed fields and closes the dialog', (tester) async {
      await open(tester);
      details.nameController.text = '  Investor Pro ';
      details.descriptionController.text = ' Baru ';
      await tester.pump();

      await tester.tap(find.text('simpan host'));
      await tester.pumpAndSettle();

      expect(features.groups.calls.last, 'info g Investor Pro Baru');
      expect(find.text('simpan host'), findsNothing);
    });

    testWidgets('onCancel closes without saving', (tester) async {
      await open(tester);
      details.nameController.text = 'Investor Pro';

      await tester.tap(find.text('batal host'));
      await tester.pumpAndSettle();

      expect(features.groups.calls, isEmpty);
      expect(find.text('batal host'), findsNothing);
    });
  });

  group('groupAddMembersDialog', () {
    late CommunityGroupAddMembersDetails details;
    late CommunityDependencies dialogScope;

    Future<void> open(WidgetTester tester) async {
      await pump(
        tester,
        CommunityChatBuilders(
          groupAddMembersDialog: (context, d, fallback) {
            details = d;
            dialogScope = CommunityScope.of(context);
            return AlertDialog(
              content: Text('hasil ${d.results.map((u) => u.username).join(',')}'),
              actions: [
                TextButton(onPressed: d.onCancel, child: const Text('batal host')),
                TextButton(onPressed: d.onAdd, child: const Text('tambah host')),
              ],
            );
          },
        ),
        found: [alice, bob, _carol, _official],
      );
      await tester.tap(find.text('Tambah anggota'));
      await tester.pumpAndSettle();
    }

    Future<void> search(WidgetTester tester) async {
      details.onQueryChanged('c');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    testWidgets('is carried into the dialog and keeps filtering existing and official accounts', (tester) async {
      await open(tester);
      expect(identical(dialogScope, deps), isTrue);
      expect(details.title, 'Tambah anggota');
      expect(details.addLabel, 'Tambah');
      expect(details.cancelLabel, 'Batal');
      expect(details.canAdd, isFalse);

      await search(tester);

      expect(details.results, [_carol]);
      expect(find.text('hasil carol'), findsOneWidget);
    });

    testWidgets('onToggle updates the selection and onAdd adds it', (tester) async {
      await open(tester);
      await search(tester);

      details.onToggle(_carol, true);
      await tester.pump();
      expect(details.selected, [_carol]);
      expect(details.isSelected(_carol), isTrue);
      expect(details.isSelected(bob), isFalse);
      expect(details.canAdd, isTrue);

      await tester.tap(find.text('tambah host'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'add g u-c');
    });

    testWidgets('onCancel closes without adding', (tester) async {
      await open(tester);

      await tester.tap(find.text('batal host'));
      await tester.pumpAndSettle();

      expect(features.groups.calls, isEmpty);
      expect(find.text('batal host'), findsNothing);
    });
  });

  group('groupMemberActions', () {
    late CommunityGroupMemberActionsDetails details;
    late CommunityDependencies sheetScope;

    CommunityChatBuilders builders() => CommunityChatBuilders(
      groupMemberActions: (context, d, fallback) {
        details = d;
        sheetScope = CommunityScope.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in d.actions)
              TextButton(onPressed: action.onSelected, child: Text('aksi ${action.kind.name}')),
            TextButton(onPressed: d.onDismiss, child: const Text('tutup host')),
          ],
        );
      },
    );

    Future<void> open(WidgetTester tester, String name, {MemberRole role = MemberRole.owner}) async {
      await pump(tester, builders(), role: role);
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    testWidgets('is carried into the sheet and lists the actions for an owner', (tester) async {
      await open(tester, 'Bob');

      expect(identical(sheetScope, deps), isTrue);
      expect(details.member.user, bob);
      expect(details.actions.map((a) => a.kind), [
        CommunityGroupMemberActionKind.viewProfile,
        CommunityGroupMemberActionKind.makeAdmin,
        CommunityGroupMemberActionKind.makeOwner,
        CommunityGroupMemberActionKind.remove,
      ]);
      expect(details.actions.map((a) => a.label), [
        'Lihat profil',
        'Jadikan admin',
        'Jadikan pemilik grup',
        'Keluarkan dari grup',
      ]);
      expect(details.actions.map((a) => a.destructive), [false, false, true, true]);
    });

    testWidgets('the list follows the role of the viewer', (tester) async {
      await open(tester, 'Alice', role: MemberRole.admin);

      expect(details.actions.map((a) => a.kind), [CommunityGroupMemberActionKind.viewProfile]);
    });

    testWidgets('a simple action runs at once and closes the sheet', (tester) async {
      await open(tester, 'Bob');

      await tester.tap(find.text('aksi makeAdmin'));
      await tester.pumpAndSettle();

      expect(features.groups.calls.last, 'role g u-b admin');
      expect(find.text('tutup host'), findsNothing);
    });

    testWidgets('removing still asks the library confirmation', (tester) async {
      await open(tester, 'Bob');

      await tester.tap(find.text('aksi remove'));
      await tester.pumpAndSettle();
      expect(find.text('Keluarkan Bob dari grup?'), findsOneWidget);
      expect(features.groups.calls, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Keluarkan dari grup'));
      await tester.pumpAndSettle();
      expect(features.groups.calls.last, 'remove g u-b');
    });

    testWidgets('handing over the group can be declined at the confirmation', (tester) async {
      await open(tester, 'Bob');

      await tester.tap(find.text('aksi makeOwner'));
      await tester.pumpAndSettle();
      expect(find.text('Jadikan Bob pemilik grup? Anda akan menjadi admin.'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(features.groups.calls, isEmpty);
    });

    testWidgets('onDismiss closes the sheet without running anything', (tester) async {
      await open(tester, 'Bob');

      await tester.tap(find.text('tutup host'));
      await tester.pumpAndSettle();

      expect(features.groups.calls, isEmpty);
      expect(find.text('tutup host'), findsNothing);
    });
  });

  testWidgets('without builders the default switches, dialogs and sheet still appear', (tester) async {
    await pump(tester, const CommunityChatBuilders());
    expect(find.byType(SwitchListTile), findsNWidgets(2));

    await tester.tap(find.text('Ubah info grup'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), findsNWidgets(2));
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah anggota'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_remove_outlined), findsOneWidget);
    expect(find.text('@bob_user'), findsNWidgets(2));
  });
}
