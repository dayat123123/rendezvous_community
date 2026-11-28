import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/chat/data/repositories/chat_extras_repository_impl.dart';

import '../../support/fakes.dart';
import '../../support/feature_fakes.dart';
import '../../support/mock_api.dart';

const _code = 'Ab12Cd34Ef';

FakeFeatureDependencies _features({bool links = true, bool chat = false}) => FakeFeatureDependencies(
  config: loadedConfig(
    flags: {
      for (final flag in CommunityFlags.all) flag: true,
      CommunityFlags.postLinks: links,
      CommunityFlags.sharePostToChat: chat,
    },
  ),
);

Future<void> _pumpButton(
  WidgetTester tester,
  FakeFeatureDependencies features,
  String label,
  Future<void> Function(BuildContext context) onTap, {
  List<String>? opened,
}) async {
  addTearDown(features.dispose);
  await pumpFeatureApp(
    tester,
    Builder(
      builder: (context) => TextButton(onPressed: () => onTap(context), child: Text(label)),
    ),
    dependencies: FakeDependencies(
      callbacks: CommunityCallbacks(onPostTap: opened == null ? null : (_, id) => opened.add(id)),
    ),
    features: features,
  );
}

void main() {
  group('link parsing', () {
    test('reads the code from https and app links only', () {
      expect(communityPostLinkCode(Uri.parse('https://share.olt.test/p/$_code')), _code);
      expect(communityPostLinkCode(Uri.parse('http://192.168.0.235:8000/p/$_code')), _code);
      expect(communityPostLinkCode(Uri.parse('olt://p/$_code')), _code);
      expect(communityPostLinkCode(Uri.parse('olt:/p/$_code')), _code);
      for (final bad in [
        'https://share.olt.test/p/short',
        'https://share.olt.test/x/$_code',
        'https://share.olt.test/p/$_code/image',
        'file://p/$_code',
        'olt://post/$_code',
        'https://share.olt.test/p/Ab12Cd34E!',
      ]) {
        expect(communityPostLinkCode(Uri.parse(bad)), isNull, reason: bad);
      }
    });
  });

  group('repository', () {
    test('creates a link and resolves a code through the RPCs', () async {
      final api = mockApi();
      when(
        () => api.rpcValue('post_share_link', any()),
      ).thenAnswer((_) async => {'code': _code, 'url': 'https://share.olt.test/p/$_code', 'app_url': 'olt://p/$_code'});
      when(() => api.rpcValue('resolve_post_share', any())).thenAnswer((_) async => 'p-1');
      final repo = ChatExtrasRepositoryImpl(api);

      final link = await repo.postLink('p-1');
      expect(link.code, _code);
      expect(link.url.toString(), 'https://share.olt.test/p/$_code');
      expect(link.appUrl.toString(), 'olt://p/$_code');
      verify(() => api.rpcValue('post_share_link', {'p_post_id': 'p-1'})).called(1);

      expect(await repo.resolvePostLink(_code), 'p-1');
      verify(() => api.rpcValue('resolve_post_share', {'p_code': _code})).called(1);
    });

    test('an unknown code resolves to null and a missing url is an error', () async {
      final api = mockApi();
      when(() => api.rpcValue('resolve_post_share', any())).thenAnswer((_) async => null);
      when(() => api.rpcValue('post_share_link', any())).thenAnswer((_) async => {'code': _code, 'url': null});
      final repo = ChatExtrasRepositoryImpl(api);

      expect(await repo.resolvePostLink(_code), isNull);
      await expectLater(repo.postLink('p-1'), throwsA(isA<CommunityException>()));
    });
  });

  group('share sheet', () {
    testWidgets('links only: copy puts the link on the clipboard and closes the sheet', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      final features = _features();
      await _pumpButton(tester, features, 'bagikan', (context) => showSharePostToChat(context, samplePost()));

      await tester.tap(find.text('bagikan'));
      await tester.pumpAndSettle();
      expect(find.text('Kirim ke…'), findsNothing);
      await tester.tap(find.text('Salin tautan'));
      await tester.pumpAndSettle();

      expect(copied, 'https://share.olt.test/p/$_code');
      expect(features.chatExtras.linkRequests, ['p-1']);
      expect(find.text('Tautan disalin.'), findsOneWidget);
      expect(find.text('Salin tautan'), findsNothing);
    });

    testWidgets('chat and links: the link actions sit above the chat list', (tester) async {
      final features = _features(chat: true);
      await _pumpButton(tester, features, 'bagikan', (context) => showSharePostToChat(context, samplePost()));

      await tester.tap(find.text('bagikan'));
      await tester.pumpAndSettle();

      expect(find.text('Salin tautan'), findsOneWidget);
      expect(find.text('Kirim ke…'), findsOneWidget);
    });

    testWidgets('links off: only the chat list is shown', (tester) async {
      final features = _features(links: false, chat: true);
      await _pumpButton(tester, features, 'bagikan', (context) => showSharePostToChat(context, samplePost()));

      await tester.tap(find.text('bagikan'));
      await tester.pumpAndSettle();

      expect(find.text('Salin tautan'), findsNothing);
      expect(find.text('Kirim ke…'), findsOneWidget);
    });

    testWidgets('a disabled server shows the share links error', (tester) async {
      final features = _features();
      features.chatExtras.linkError = const CommunityException(
        CommunityErrorKind.forbidden,
        code: 'share_links_disabled',
      );
      await _pumpButton(tester, features, 'bagikan', (context) => showSharePostToChat(context, samplePost()));

      await tester.tap(find.text('bagikan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salin tautan'));
      await tester.pumpAndSettle();

      expect(find.text('Tautan berbagi belum diaktifkan.'), findsOneWidget);
      expect(find.text('Salin tautan'), findsOneWidget);
    });

    testWidgets('neither chat nor links: no share sheet', (tester) async {
      final features = _features(links: false);
      bool? shown;
      await _pumpButton(
        tester,
        features,
        'bagikan',
        (context) async => shown = await showSharePostToChat(context, samplePost()),
      );

      await tester.tap(find.text('bagikan'));
      await tester.pumpAndSettle();

      expect(shown, isFalse);
      expect(find.text('Salin tautan'), findsNothing);
    });
  });

  group('opening links', () {
    testWidgets('openCommunityPostLink opens the post or says it is unavailable', (tester) async {
      final opened = <String>[];
      final features = _features();
      features.chatExtras.resolvedLinks[_code] = 'p-9';
      await _pumpButton(tester, features, 'buka', (context) async {
        await openCommunityPostLink(context, Uri.parse('olt://p/$_code'));
        if (context.mounted) await openCommunityPostLink(context, Uri.parse('https://share.olt.test/p/ZZZZZZZZZZ'));
      }, opened: opened);

      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      expect(opened, ['p-9']);
      expect(find.text('Postingan dari tautan ini tidak tersedia.'), findsOneWidget);
    });

    testWidgets('a share link tapped in the app opens the post without the external link dialog', (tester) async {
      final opened = <String>[];
      final features = _features();
      features.chatExtras.resolvedLinks[_code] = 'p-9';
      await _pumpButton(
        tester,
        features,
        'tautan',
        (context) => openCommunityLink(context, Uri.parse('https://share.olt.test/p/$_code')),
        opened: opened,
      );

      await tester.tap(find.text('tautan'));
      await tester.pumpAndSettle();

      expect(opened, ['p-9']);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('an unknown /p/ link from another site still asks before opening', (tester) async {
      final features = _features();
      await _pumpButton(
        tester,
        features,
        'tautan',
        (context) => openCommunityLink(context, Uri.parse('https://other.example/p/ZZZZZZZZZZ')),
        opened: <String>[],
      );

      await tester.tap(find.text('tautan'));
      await tester.pumpAndSettle();

      expect(features.chatExtras.resolveRequests, ['ZZZZZZZZZZ']);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
