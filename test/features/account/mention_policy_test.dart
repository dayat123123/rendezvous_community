import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/mention_policy_cubit.dart';
import 'package:rendezvous_community/src/features/profile/data/repositories/profile_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/mock_api.dart';

const _budi = UserSummary(id: 'u-budi', username: 'budi', displayName: 'Budi Santoso');
const _cici = UserSummary(id: 'u-cici', username: 'cici', displayName: 'Cici Lestari');

class _Profiles extends Fake implements ProfileRepository {
  @override
  Future<List<UserSummary>> searchUsers(String query, {int limit = 8}) async => const [_budi, _cici];
}

class _MentionProfiles extends _Profiles implements MentionPolicyRepository {
  MentionPolicy policy = MentionPolicy.everyone;
  Object? loadError;
  Object? saveError;
  final saved = <MentionPolicy>[];

  @override
  Future<MentionPolicy> getMentionPolicy() async {
    if (loadError != null) throw loadError!;
    return policy;
  }

  @override
  Future<MentionPolicy> setMentionPolicy(MentionPolicy value) async {
    if (saveError != null) throw saveError!;
    saved.add(value);
    return policy = value;
  }

  @override
  Future<List<UserSummary>> searchMentionableUsers(String query, {int limit = 8}) async => const [_cici];
}

Future<void> _pump(WidgetTester tester, ProfileRepository profiles, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: communityLocalizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: Scaffold(
        body: CommunityScope(
          dependencies: FakeDependencies(profiles: profiles),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('repository reads and saves the mention policy and hides users who cannot be mentioned', () async {
    final api = mockApi();
    when(() => api.rpcValue('get_mention_policy')).thenAnswer((_) async => {'policy': 'following'});
    when(() => api.rpcValue('set_mention_policy', any())).thenAnswer((_) async => {'policy': 'none'});
    when(() => api.rpcRows('search_profiles', any())).thenAnswer(
      (_) async => [
        {'id': 'u-budi', 'username': 'budi', 'can_mention': false},
        {'id': 'u-cici', 'username': 'cici', 'can_mention': true},
        {'id': 'u-dedi', 'username': 'dedi'},
      ],
    );
    final repository = ProfileRepositoryImpl(api);

    expect(await repository.getMentionPolicy(), MentionPolicy.following);
    expect(await repository.setMentionPolicy(MentionPolicy.none), MentionPolicy.none);
    verify(() => api.rpcValue('set_mention_policy', {'p_policy': 'none'})).called(1);
    expect((await repository.searchMentionableUsers('b', limit: 6)).map((u) => u.username), ['cici', 'dedi']);
    verify(() => api.rpcRows('search_profiles', {'p_query': 'b', 'p_limit': 6})).called(1);
    expect((await repository.searchUsers('b')).map((u) => u.username), ['budi', 'cici', 'dedi']);
    expect(await repository.searchMentionableUsers('  '), isEmpty);
  });

  test('unknown policy values fall back to everyone', () async {
    final api = mockApi();
    when(() => api.rpcValue('get_mention_policy')).thenAnswer((_) async => {'policy': 'followers'});
    expect(await ProfileRepositoryImpl(api).getMentionPolicy(), MentionPolicy.everyone);
  });

  test('cubit saves the choice and rolls back when saving fails', () async {
    final profiles = _MentionProfiles();
    final cubit = MentionPolicyCubit(profiles);
    await cubit.load();
    await cubit.setPolicy(MentionPolicy.following);
    expect(cubit.state.policy, MentionPolicy.following);
    expect(cubit.state.savedId, 1);

    profiles.saveError = const CommunityException(CommunityErrorKind.network);
    await cubit.setPolicy(MentionPolicy.none);
    expect(cubit.state.policy, MentionPolicy.following);
    expect(cubit.state.actionErrorId, 1);
    expect(cubit.state.saving, isFalse);
    await cubit.close();
  });

  testWidgets('settings show three choices and save the selected one', (tester) async {
    final profiles = _MentionProfiles();
    await _pump(tester, profiles, const CommunityMentionPolicySettings());

    expect(find.text('Siapa yang bisa menyebut saya'), findsOneWidget);
    expect(find.byType(RadioListTile<MentionPolicy>), findsNWidgets(3));
    await tester.tap(find.byKey(const ValueKey('account-mention-policy-none')));
    await tester.pumpAndSettle();

    expect(profiles.saved, [MentionPolicy.none]);
    expect(find.text('Pengaturan mention disimpan.'), findsOneWidget);
  });

  testWidgets('settings stay hidden when the server or repository does not support them', (tester) async {
    await _pump(tester, _Profiles(), const CommunityMentionPolicySettings());
    expect(find.byType(RadioListTile<MentionPolicy>), findsNothing);

    final old = _MentionProfiles()..loadError = const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202');
    await _pump(tester, old, const CommunityMentionPolicySettings());
    expect(find.byType(RadioListTile<MentionPolicy>), findsNothing);
    expect(find.text('Siapa yang bisa menyebut saya'), findsNothing);
  });

  testWidgets('the builder slot receives the policy and options', (tester) async {
    CommunityMentionPolicyDetails? seen;
    await _pump(
      tester,
      _MentionProfiles()..policy = MentionPolicy.following,
      CommunityBuildersScope(
        builders: CommunityBuilders(
          settings: CommunitySettingsBuilders(
            mentionPolicy: (context, details, fallback) {
              seen = details;
              return const SizedBox.shrink();
            },
          ),
        ),
        child: const CommunityMentionPolicySettings(),
      ),
    );

    expect(seen?.policy, MentionPolicy.following);
    expect(seen?.options.map((o) => o.value), MentionPolicy.values);
    expect(find.byType(RadioListTile<MentionPolicy>), findsNothing);
  });

  testWidgets('@ suggestions skip users who do not allow mentions', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, _MentionProfiles(), CommunityComposerField(controller: controller, hintText: 'Tulis'));

    await tester.enterText(find.byType(TextField), 'Halo @b');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Cici Lestari'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsNothing);
  });

  testWidgets('@ suggestions fall back to plain search for repositories without mention support', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, _Profiles(), CommunityComposerField(controller: controller, hintText: 'Tulis'));

    await tester.enterText(find.byType(TextField), 'Halo @b');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Cici Lestari'), findsOneWidget);
  });
}
