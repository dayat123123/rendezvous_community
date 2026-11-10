import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/share_post_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/new_group_dialog.dart';
import 'package:rendezvous_community/src/features/profile/data/models/profile_model.dart';
import 'package:rendezvous_community/src/shared/data/models/user_summary_model.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/gen/community_localizations.dart';

import '../../support/chat_app.dart';
import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

final _official = alice.copyWith(isOfficial: true);
final _verified = bob.copyWith(isVerified: true);

class _EmptyFeed extends FakeFeedRepository {
  @override
  Future<Paged<Post>> getFeed(FeedScope scope, {String? cursor, int limit = 20}) async => const Paged([]);

  @override
  Future<List<PinnedPost>> getPinned(FeedScope scope) async => const [];
}

class _Profiles extends Fake implements ProfileRepository {
  _Profiles({this.user = alice, this.found = const []});

  final UserSummary user;
  final List<UserSummary> found;

  @override
  Future<UserProfile?> getProfile({String? userId, String? username}) async => UserProfile(
    user: user,
    followerCount: 1,
    followingCount: 0,
    postCount: 0,
    createdAt: now,
    isMe: false,
    isFollowing: false,
    followsMe: false,
    isBlocked: false,
  );

  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async => found;
}

class _Extras extends FakeChatExtrasRepository {}

Future<void> _pumpProfile(
  WidgetTester tester,
  UserSummary user, {
  CommunityCallbacks callbacks = const CommunityCallbacks(),
  OfficialAccounts? accounts,
}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget child = CommunityUserProfile(userId: user.id);
  if (accounts != null) child = CommunityOfficialScope(accounts: accounts, child: child);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(
            feed: _EmptyFeed(),
            profiles: _Profiles(user: user),
            callbacks: callbacks,
          ),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRoom(
  WidgetTester tester,
  UserSummary other, {
  CommunityCallbacks callbacks = const CommunityCallbacks(),
  OfficialAccounts? accounts,
}) async {
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  final chat = FakeChatRepository(
    rooms: [ChatRoom(id: 'dm', type: RoomType.direct, createdAt: chatStart, lastReadAt: chatStart, otherUser: other)],
    members: [
      RoomMember(user: me, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
      RoomMember(user: other, lastReadAt: chatStart, lastDeliveredAt: chatStart, joinedAt: chatStart),
    ],
    messages: [
      ChatMessage(
        id: 'm-1',
        roomId: 'dm',
        senderId: other.id,
        sender: other,
        body: 'Pengumuman lama',
        createdAt: chatStart.add(const Duration(minutes: 1)),
      ),
    ],
  );
  addTearDown(chat.dispose);
  const room = CommunityChatRoom(roomId: 'dm');
  await pumpFeatureApp(
    tester,
    accounts == null ? room : CommunityOfficialScope(accounts: accounts, child: room),
    dependencies: FakeDependencies(chat: chat, callbacks: callbacks),
    features: features,
  );
  await tester.pumpAndSettle();
}

Finder get _composerField => find.descendant(of: find.byType(CommunityChatRoom), matching: find.byType(TextField));

void main() {
  group('server data', () {
    test('profiles and user rows read is_official', () {
      final profile = ProfileModel.fromJson({
        'id': 'u-a',
        'username': 'alice',
        'is_verified': false,
        'is_official': true,
        'created_at': '2026-11-03T09:00:00Z',
      }).toEntity();
      expect(profile.user.isOfficial, isTrue);
      expect(
        UserSummaryModel.fromJson({'id': 'u-b', 'username': 'bob', 'is_official': true}).toEntity().isOfficial,
        isTrue,
      );
      expect(UserSummaryModel.fromJson({'id': 'u-b', 'username': 'bob'}).toEntity().isOfficial, isFalse);
    });

    testWidgets('official_no_dm has its own message in both languages', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: CommunityLocalizations.localizationsDelegates,
          supportedLocales: CommunityLocalizations.supportedLocales,
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      const error = CommunityException(CommunityErrorKind.forbidden, code: 'official_no_dm');
      expect(
        context.communityL10n.errorMessage(error),
        'Official accounts do not accept direct messages. Contact support for help.',
      );
      final id = lookupCommunityLocalizations(const Locale('id'));
      expect(id.errorMessage(error), 'Akun resmi tidak menerima pesan langsung. Hubungi CS untuk bantuan.');
    });
  });

  group('profile', () {
    testWidgets('an official account has no message button without onOfficialContact', (tester) async {
      await _pumpProfile(tester, _official);

      expect(find.text('Kirim pesan'), findsNothing);
      expect(find.text('Hubungi CS'), findsNothing);
    });

    testWidgets('onOfficialContact replaces the message button with Hubungi CS', (tester) async {
      final contacted = <String>[];
      await _pumpProfile(
        tester,
        _official,
        callbacks: CommunityCallbacks(onOfficialContact: (_, user) => contacted.add(user.id)),
      );

      expect(find.text('Kirim pesan'), findsNothing);
      await tester.tap(find.text('Hubungi CS'));
      expect(contacted, [alice.id]);
    });

    testWidgets('the official list is the fallback when the server does not send is_official', (tester) async {
      final accounts = OfficialAccounts(() async => {alice.id});
      await accounts.reload();
      await _pumpProfile(tester, alice, accounts: accounts);

      expect(find.text('Kirim pesan'), findsNothing);
    });

    testWidgets('a verified account can still be messaged', (tester) async {
      await _pumpProfile(tester, _verified);

      expect(find.text('Kirim pesan'), findsOneWidget);
    });

    testWidgets('host builders get isOfficial and onOfficialContact', (tester) async {
      CommunityProfileDetails? seen;
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityScope(
              dependencies: FakeDependencies(
                feed: _EmptyFeed(),
                profiles: _Profiles(user: _official),
                callbacks: CommunityCallbacks(onOfficialContact: (_, _) {}),
              ),
              child: CommunityUserProfile(
                userId: alice.id,
                builders: CommunityProfileBuilders(
                  header: (context, d, fallback) {
                    seen = d;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(seen!.isOfficial, isTrue);
      expect(seen!.onMessage, isNull);
      expect(seen!.onOfficialContact, isNotNull);
    });
  });

  group('chat', () {
    testWidgets('a DM with an official account shows a notice instead of the composer', (tester) async {
      final contacted = <String>[];
      await _pumpRoom(
        tester,
        _official,
        callbacks: CommunityCallbacks(onOfficialContact: (_, user) => contacted.add(user.id)),
      );

      expect(find.text('Pengumuman lama'), findsOneWidget);
      expect(_composerField, findsNothing);
      expect(find.text('Akun resmi tidak menerima pesan. Hubungi CS untuk bantuan.'), findsOneWidget);
      await tester.tap(find.text('Hubungi CS'));
      expect(contacted, [alice.id]);
    });

    testWidgets('the notice has no button without onOfficialContact', (tester) async {
      await _pumpRoom(tester, _official);

      expect(find.text('Akun resmi tidak menerima pesan. Hubungi CS untuk bantuan.'), findsOneWidget);
      expect(find.text('Hubungi CS'), findsNothing);
    });

    testWidgets('a DM with a verified account keeps the composer', (tester) async {
      await _pumpRoom(tester, _verified);

      expect(_composerField, findsOneWidget);
      expect(find.text('Akun resmi tidak menerima pesan. Hubungi CS untuk bantuan.'), findsNothing);
    });

    testWidgets('the official account itself keeps the composer', (tester) async {
      final accounts = OfficialAccounts(() async => {me.id, alice.id});
      await accounts.reload();
      await _pumpRoom(tester, alice, accounts: accounts);

      expect(_composerField, findsOneWidget);
    });

    testWidgets('the new group dialog hides official accounts', (tester) async {
      await pumpFeatureApp(
        tester,
        Builder(
          builder: (context) => TextButton(onPressed: () => showNewGroupDialog(context), child: const Text('grup')),
        ),
        dependencies: FakeDependencies(profiles: _Profiles(found: [_official, _verified])),
      );
      await tester.tap(find.text('grup'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'a');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text(_verified.name), findsOneWidget);
      expect(find.text(_official.name), findsNothing);
    });

    test('Kirim ke chat skips DMs with official accounts', () async {
      final chat = FakeChatRepository(
        rooms: [
          ChatRoom(
            id: 'dm-o',
            type: RoomType.direct,
            createdAt: chatStart,
            lastReadAt: chatStart,
            otherUser: _official,
          ),
          ChatRoom(
            id: 'dm-v',
            type: RoomType.direct,
            createdAt: chatStart,
            lastReadAt: chatStart,
            otherUser: _verified,
          ),
          ChatRoom(id: 'grp', type: RoomType.group, name: 'Grup', createdAt: chatStart, lastReadAt: chatStart),
        ],
      );
      addTearDown(chat.dispose);
      final cubit = SharePostCubit(chat: chat, extras: _Extras(), postId: 'p-1', isOfficial: (u) => u.isOfficial);
      addTearDown(cubit.close);
      await cubit.load();

      expect([for (final r in cubit.state.rooms) r.id], unorderedEquals(['dm-v', 'grp']));
    });
  });
}
