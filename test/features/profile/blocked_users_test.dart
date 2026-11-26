import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';
import 'package:rendezvous_community/src/features/profile/data/repositories/profile_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';

const _cici = UserSummary(id: 'u-c', username: 'cici', displayName: 'Cici');
const _dodi = UserSummary(id: 'u-d', username: 'dodi', displayName: 'Dodi');

class _Profiles extends Fake implements ProfileRepository, BlockListRepository {
  _Profiles(this.list);

  List<BlockedUser> list;
  final unblocked = <String>[];
  final blockedIds = <String>[];
  Object? listError;
  int loads = 0;

  @override
  Future<List<BlockedUser>> blockedUsers() async {
    loads++;
    final error = listError;
    if (error != null) throw error;
    return list;
  }

  @override
  Future<void> unblock(String userId) async {
    unblocked.add(userId);
    list = [
      for (final b in list)
        if (b.user.id != userId) b,
    ];
  }

  @override
  Future<void> block(String userId) async {
    blockedIds.add(userId);
    list = [BlockedUser(user: _cici, blockedAt: DateTime.utc(2026, 11, 26)), ...list];
  }
}

Future<void> _pump(WidgetTester tester, Widget child, {required ProfileRepository profiles}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: CommunityScope(
        dependencies: FakeDependencies(profiles: profiles),
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _BlockHost extends StatefulWidget {
  const _BlockHost();

  @override
  State<_BlockHost> createState() => _BlockHostState();
}

class _BlockHostState extends State<_BlockHost> {
  bool _shown = true;

  @override
  Widget build(BuildContext context) {
    if (!_shown) return const Text('hidden');
    return TextButton(
      onPressed: () async {
        if (await blockUserWithConfirm(context, _cici)) setState(() => _shown = false);
      },
      child: const Text('block-cici'),
    );
  }
}

void main() {
  group('repository', () {
    test('reads my blocks with the blocked profile, newest first, skipping missing profiles', () async {
      final api = mockApi();
      when(
        () => api.select(
          'blocks',
          columns: any(named: 'columns'),
          match: any(named: 'match'),
        ),
      ).thenAnswer(
        (_) async => [
          {
            'created_at': '2026-11-10T02:00:00Z',
            'blocked': {
              'id': 'u-d',
              'username': 'dodi',
              'display_name': 'Dodi',
              'avatar_url': null,
              'is_verified': false,
            },
          },
          {'created_at': '2026-11-12T02:00:00Z', 'blocked': null},
          {
            'created_at': '2026-11-20T02:00:00Z',
            'blocked': {
              'id': 'u-c',
              'username': 'cici',
              'display_name': 'Cici',
              'avatar_url': 'https://x/a.png',
              'is_verified': true,
            },
          },
        ],
      );

      final result = await ProfileRepositoryImpl(api).blockedUsers();

      expect(result.map((b) => b.user.username), ['cici', 'dodi']);
      expect(result.first.user.isVerified, isTrue);
      expect(result.first.blockedAt, DateTime.utc(2026, 11, 20, 2));
      final captured = verify(
        () => api.select(
          'blocks',
          columns: captureAny(named: 'columns'),
          match: captureAny(named: 'match'),
        ),
      ).captured;
      expect(captured[0], contains('blocked:profiles!blocked_id('));
      expect(captured[1], {'blocker_id': 'u-1'});
    });
  });

  group('list', () {
    testWidgets('shows blocked accounts and unblocks one after confirming', (tester) async {
      final profiles = _Profiles([
        BlockedUser(user: _cici, blockedAt: DateTime.utc(2026, 11, 20)),
        BlockedUser(user: _dodi, blockedAt: DateTime.utc(2026, 11, 10)),
      ]);
      await _pump(tester, const CommunityBlockedUsers(), profiles: profiles);

      expect(find.text('Cici'), findsOneWidget);
      expect(find.text('Dodi'), findsOneWidget);
      expect(find.text('Buka blokir'), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('unblock-u-c')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Buka blokir Cici?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Buka blokir'));
      await tester.pumpAndSettle();

      expect(profiles.unblocked, ['u-c']);
      expect(find.text('Cici'), findsNothing);
      expect(find.text('Dodi'), findsOneWidget);
      expect(find.text('Cici tidak lagi diblokir'), findsOneWidget);
    });

    testWidgets('cancelling the confirmation keeps the account blocked', (tester) async {
      final profiles = _Profiles([BlockedUser(user: _cici)]);
      await _pump(tester, const CommunityBlockedUsers(), profiles: profiles);

      await tester.tap(find.byKey(const ValueKey('unblock-u-c')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(profiles.unblocked, isEmpty);
      expect(find.text('Cici'), findsOneWidget);
    });

    testWidgets('shows the empty message when nobody is blocked', (tester) async {
      await _pump(tester, const CommunityBlockedUsers(), profiles: _Profiles([]));

      expect(find.text('Belum ada akun yang Anda blokir.'), findsOneWidget);
    });

    testWidgets('shows a retry when loading fails', (tester) async {
      final profiles = _Profiles([BlockedUser(user: _dodi)])..listError = Exception('down');
      await _pump(tester, const CommunityBlockedUsers(), profiles: profiles);

      expect(find.text('Dodi'), findsNothing);
      profiles.listError = null;
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Dodi'), findsOneWidget);
      expect(profiles.loads, 2);
    });
  });

  group('manage action', () {
    testWidgets('the blocked message offers Kelola, which opens the list even after the source is gone', (
      tester,
    ) async {
      final profiles = _Profiles([BlockedUser(user: _dodi)]);
      await _pump(tester, const _BlockHost(), profiles: profiles);

      await tester.tap(find.text('block-cici'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Blokir'));
      await tester.pumpAndSettle();

      expect(profiles.blockedIds, ['u-c']);
      expect(find.text('hidden'), findsOneWidget);
      expect(find.text('Cici diblokir'), findsOneWidget);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Kelola'));
      await tester.pumpAndSettle();

      expect(find.text('Akun yang diblokir'), findsOneWidget);
      expect(find.text('Cici'), findsOneWidget);
      expect(find.text('Dodi'), findsOneWidget);
    });

    testWidgets('no Kelola action when the repository cannot list blocks', (tester) async {
      await _pump(tester, const _BlockHost(), profiles: _PlainProfiles());

      await tester.tap(find.text('block-cici'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Blokir'));
      await tester.pumpAndSettle();

      expect(find.text('Cici diblokir'), findsOneWidget);
      expect(find.widgetWithText(SnackBarAction, 'Kelola'), findsNothing);
    });

    testWidgets('showCommunityBlockedUsers opens the dialog with a close button', (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (context) =>
              TextButton(onPressed: () => showCommunityBlockedUsers(context), child: const Text('open')),
        ),
        profiles: _Profiles([BlockedUser(user: _dodi)]),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Akun yang diblokir'), findsOneWidget);
      expect(find.text('Dodi'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Akun yang diblokir'), findsNothing);
    });

    testWidgets('communityBlockedUsersAvailable follows the repository', (tester) async {
      bool? withList;
      bool? without;
      await _pump(
        tester,
        Builder(
          builder: (context) {
            withList = communityBlockedUsersAvailable(context);
            return const SizedBox();
          },
        ),
        profiles: _Profiles([]),
      );
      await _pump(
        tester,
        Builder(
          builder: (context) {
            without = communityBlockedUsersAvailable(context);
            return const SizedBox();
          },
        ),
        profiles: _PlainProfiles(),
      );
      expect(withList, isTrue);
      expect(without, isFalse);
    });
  });
}

class _PlainProfiles extends Fake implements ProfileRepository {
  @override
  Future<void> block(String userId) async {}
}
