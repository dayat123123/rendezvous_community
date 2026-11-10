import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/core/storage/local_values.dart';
import 'package:rendezvous_community/src/features/drafts/data/repositories/post_draft_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';

PostDraft _draft(String id, {String body = r'Analisis $BBCA'}) =>
    PostDraft(clientDraftId: id, body: body, updatedAt: DateTime.utc(2026, 11, 3, 9));

Future<FakeFeatureDependencies> _pump(WidgetTester tester, Widget child, {bool postDrafts = true}) async {
  final features = FakeFeatureDependencies(config: loadedConfig());
  addTearDown(features.dispose);
  await pumpFeatureApp(
    tester,
    Material(child: child),
    dependencies: FakeDependencies(callbacks: CommunityCallbacks(postDrafts: postDrafts)),
    features: features,
  );
  await tester.pumpAndSettle();
  return features;
}

Future<void> _type(WidgetTester tester) async {
  await tester.enterText(
    find.descendant(of: find.byType(CommunityComposePost), matching: find.byType(TextField)),
    r'Analisis $BBCA',
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  group('postDrafts option', () {
    testWidgets('the composer saves drafts by default', (tester) async {
      final features = await _pump(tester, const CommunityComposePost());

      await _type(tester);

      expect(features.draftRepository.saved, hasLength(1));
      expect(find.text('Draf tersimpan'), findsOneWidget);
    });

    testWidgets('postDrafts false keeps the composer away from drafts', (tester) async {
      final features = await _pump(tester, const CommunityComposePost(), postDrafts: false);

      await _type(tester);

      expect(features.draftRepository.saved, isEmpty);
      expect(features.draftRepository.listCalls, 0);
      expect(find.text('Draf tersimpan'), findsNothing);
      expect(find.text('Draf tersimpan di perangkat ini'), findsNothing);
    });

    testWidgets('postDrafts false ignores a draft handed to the composer', (tester) async {
      final features = await _pump(tester, CommunityComposePost(draft: _draft('d1')), postDrafts: false);

      expect(find.text(r'Analisis $BBCA'), findsNothing);
      expect(features.draftRepository.saved, isEmpty);
    });

    testWidgets('CommunityPostDrafts shows the empty state without asking the server', (tester) async {
      final features = FakeFeatureDependencies(config: loadedConfig());
      addTearDown(features.dispose);
      features.draftRepository.saved['d1'] = _draft('d1');
      await pumpFeatureApp(
        tester,
        const CommunityPostDrafts(),
        dependencies: FakeDependencies(callbacks: const CommunityCallbacks(postDrafts: false)),
        features: features,
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada draf.'), findsOneWidget);
      expect(find.text(r'Analisis $BBCA'), findsNothing);
      expect(features.draftRepository.listCalls, 0);
    });
  });

  test('clear removes every draft on the device and on the server', () async {
    final remote = FakePostDraftRepository();
    final local = PostDraftStoreImpl(MemoryLocalValues());
    final drafts = CommunityDrafts(remote, local);
    remote.saved['srv'] = _draft('srv');
    await local.write([_draft('mine')], {'gone'});

    await drafts.clear();

    expect(remote.deleted, unorderedEquals(['srv', 'mine', 'gone']));
    expect(remote.saved, isEmpty);
    final (left, pending) = await local.load();
    expect(left, isEmpty);
    expect(pending, isEmpty);
  });

  test('clear keeps pending deletions when the server is unreachable', () async {
    final remote = FakePostDraftRepository()..listError = const CommunityException(CommunityErrorKind.network);
    final local = PostDraftStoreImpl(MemoryLocalValues());
    final drafts = CommunityDrafts(remote, local);
    await local.write([_draft('mine')], const {});

    await expectLater(drafts.clear(), throwsA(isA<CommunityException>()));

    final (left, pending) = await local.load();
    expect(left, isEmpty);
    expect(pending, {'mine'});
  });
}
