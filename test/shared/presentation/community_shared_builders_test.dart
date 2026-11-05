import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

import '../../support/fakes.dart';

Widget _app(
  Widget child, {
  Brightness brightness = Brightness.light,
  CommunitySharedBuilders? shared,
  Locale locale = const Locale('id'),
}) => MaterialApp(
  locale: locale,
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FFF), brightness: brightness),
  ),
  localizationsDelegates: CommunityLocalizations.localizationsDelegates,
  supportedLocales: CommunityLocalizations.supportedLocales,
  builder: (context, child) => shared == null
      ? child!
      : CommunityBuildersScope(
          builders: CommunityBuilders(shared: shared),
          child: child!,
        ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

Widget _gallery({VoidCallback? onTap}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    CommunityCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityAuthorRow(user: alice, meta: '2 jam', onOpenAuthor: onTap),
          const SizedBox(height: 8),
          const Text('Isi'),
          CommunityActionBar(
            leading: [
              CommunityActionPill(icon: Icons.favorite_border_rounded, label: 'Suka', count: 12, onPressed: onTap),
            ],
            trailing: [CommunityActionButton(icon: Icons.more_horiz, tooltip: 'Lainnya', onPressed: onTap)],
          ),
        ],
      ),
    ),
    const CommunityDivider(),
    CommunitySectionHeader(title: 'Bagian', subtitle: 'Sub', actionLabel: 'Semua', onAction: onTap),
    CommunityTag(label: r'$BBCA', onTap: onTap),
    const CommunityDisclaimer(),
    const ModerationNotice(status: ModerationStatus.held),
    const SizedBox(height: 240, child: CommunityEmptyView(message: 'Kosong')),
  ],
);

void main() {
  group('default components', () {
    for (final brightness in Brightness.values) {
      testWidgets('render without builders in ${brightness.name} mode', (tester) async {
        await tester.pumpWidget(_app(_gallery(onTap: () {}), brightness: brightness));
        expect(find.byType(CommunityCard), findsOneWidget);
        expect(find.text(alice.name), findsOneWidget);
        expect(find.text('2 jam'), findsOneWidget);
        expect(find.text('Suka · 12'), findsOneWidget);
        expect(find.text('Bagian'), findsOneWidget);
        expect(find.text(r'$BBCA'), findsOneWidget);
        expect(find.text('Kosong'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('meet tap target and contrast guidelines in ${brightness.name} mode', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_app(_gallery(onTap: () {}), brightness: brightness));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('the skeleton is static', (tester) async {
      await tester.pumpWidget(_app(const SizedBox(height: 400, child: CommunitySkeleton(itemCount: 2))));
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pumpAndSettle();
      expect(find.byType(CommunitySkeletonBox), findsWidgets);
    });

    testWidgets('counts are compact and localized', (tester) async {
      await tester.pumpWidget(_app(const CommunityActionPill(icon: Icons.favorite, count: 1200)));
      expect(find.text('1,2 rb'), findsOneWidget);
      await tester.pumpWidget(
        _app(const CommunityActionPill(icon: Icons.favorite, count: 1200), locale: const Locale('en')),
      );
      expect(find.text('1.2K'), findsOneWidget);
      await tester.pumpWidget(_app(const CommunityActionPill(icon: Icons.favorite, count: 0, label: 'Suka')));
      expect(find.text('Suka'), findsOneWidget);
    });

    testWidgets('pill and card handlers fire', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(_gallery(onTap: () => taps++)));
      await tester.tap(find.text('Suka · 12'));
      await tester.tap(find.text('Isi'));
      expect(taps, 2);
    });
  });

  group('CommunitySharedBuilders', () {
    testWidgets('every slot replaces its part and receives the fallback', (tester) async {
      final seen = <String, Object>{};
      Widget mark(String name, Object details) {
        seen[name] = details;
        return Text('custom $name');
      }

      await tester.pumpWidget(
        _app(
          Column(
            children: [
              const CommunityAvatar(user: alice),
              const CommunityUserName(user: alice),
              const CommunityCard(child: Text('isi kartu')),
              const CommunityAuthorRow(user: alice, meta: 'meta'),
              const CommunityActionPill(icon: Icons.favorite, count: 3, active: true),
              const CommunityActionButton(icon: Icons.share, tooltip: 'Bagikan'),
              const CommunityActionBar(leading: [Text('a')]),
              const CommunitySectionHeader(title: 'Judul'),
              const CommunityDivider(indent: 8),
              const CommunityTag(label: 'tag', selected: true),
              const CommunityDisclaimer(),
              ModerationNotice(status: ModerationStatus.hidden, onAppeal: () {}),
              const HeldAttachmentLabel(),
              const SizedBox(height: 80, child: CommunityEmptyView(message: 'kosong')),
              SizedBox(
                height: 80,
                child: CommunityErrorView(error: Exception('x'), onRetry: () {}),
              ),
              const SizedBox(height: 80, child: CommunityLoadingView(message: 'memuat')),
              const SizedBox(height: 80, child: CommunitySkeleton(itemCount: 1)),
            ],
          ),
          shared: CommunitySharedBuilders(
            avatar: (context, d, fallback) => mark('avatar', d),
            userName: (context, d, fallback) => mark('userName', d),
            card: (context, d, fallback) => mark('card', d),
            authorRow: (context, d, fallback) => mark('authorRow', d),
            actionPill: (context, d, fallback) => mark('actionPill', d),
            actionButton: (context, d, fallback) => mark('actionButton', d),
            actionBar: (context, d, fallback) => mark('actionBar', d),
            sectionHeader: (context, d, fallback) => mark('sectionHeader', d),
            divider: (context, d, fallback) => mark('divider', d),
            tag: (context, d, fallback) => mark('tag', d),
            disclaimer: (context, d, fallback) => mark('disclaimer', d),
            moderationNotice: (context, d, fallback) => mark('moderationNotice', d),
            heldLabel: (context, d, fallback) => mark('heldLabel', d),
            emptyView: (context, d, fallback) => mark('emptyView', d),
            errorView: (context, d, fallback) => mark('errorView', d),
            loadingView: (context, d, fallback) => mark('loadingView', d),
            skeleton: (context, d, fallback) => mark('skeleton', d),
          ),
        ),
      );

      for (final name in [
        'avatar',
        'userName',
        'card',
        'authorRow',
        'actionPill',
        'actionButton',
        'actionBar',
        'sectionHeader',
        'divider',
        'tag',
        'disclaimer',
        'moderationNotice',
        'heldLabel',
        'emptyView',
        'errorView',
        'loadingView',
        'skeleton',
      ]) {
        expect(find.text('custom $name'), findsOneWidget, reason: name);
      }
      expect((seen['avatar']! as CommunityAvatarDetails).initials, 'A');
      expect((seen['card']! as CommunityCardDetails).padding, const CommunitySpacing().card);
      expect((seen['authorRow']! as CommunityAuthorRowDetails).meta, 'meta');
      final pill = seen['actionPill']! as CommunityActionPillDetails;
      expect([pill.active, pill.countLabel, pill.text], [true, '3', '3']);
      expect((seen['divider']! as CommunityDividerDetails).indent, 8);
      expect((seen['tag']! as CommunityTagDetails).selected, isTrue);
      final notice = seen['moderationNotice']! as CommunityModerationNoticeDetails;
      expect([notice.held, notice.onAppeal != null, notice.compact], [false, true, false]);
      expect((seen['errorView']! as CommunityErrorViewDetails).onRetry, isNotNull);
      expect((seen['loadingView']! as CommunityLoadingViewDetails).message, 'memuat');
      expect((seen['skeleton']! as CommunitySkeletonDetails).custom, isFalse);
    });

    testWidgets('a builder can wrap the fallback', (tester) async {
      await tester.pumpWidget(
        _app(
          const CommunityCard(child: Text('isi')),
          shared: CommunitySharedBuilders(
            card: (context, d, fallback) => KeyedSubtree(key: const ValueKey('wrapped'), child: fallback),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('wrapped')), findsOneWidget);
      expect(find.text('isi'), findsOneWidget);
    });

    testWidgets('held notices drop the appeal handler', (tester) async {
      CommunityModerationNoticeDetails? details;
      await tester.pumpWidget(
        _app(
          ModerationNotice(status: ModerationStatus.held, onAppeal: () {}, compact: true),
          shared: CommunitySharedBuilders(
            moderationNotice: (context, d, fallback) {
              details = d;
              return fallback;
            },
          ),
        ),
      );
      expect(details!.held, isTrue);
      expect(details!.onAppeal, isNull);
      expect(details!.compact, isTrue);
    });

    testWidgets('nested scopes merge per slot', (tester) async {
      await tester.pumpWidget(
        _app(
          CommunityBuildersScope(
            builders: CommunityBuilders(
              shared: CommunitySharedBuilders(tag: (context, d, fallback) => const Text('inner tag')),
            ),
            child: const Column(
              children: [
                CommunityTag(label: 'x'),
                CommunityDivider(),
              ],
            ),
          ),
          shared: CommunitySharedBuilders(
            tag: (context, d, fallback) => const Text('outer tag'),
            divider: (context, d, fallback) => const Text('outer divider'),
          ),
        ),
      );
      expect(find.text('inner tag'), findsOneWidget);
      expect(find.text('outer divider'), findsOneWidget);
    });

    test('merge keeps the other set first', () {
      Widget a(BuildContext c, CommunityTagDetails d, Widget f) => f;
      Widget b(BuildContext c, CommunityTagDetails d, Widget f) => f;
      final merged = CommunitySharedBuilders(tag: a).merge(CommunitySharedBuilders(tag: b));
      expect(merged.tag, same(b));
      expect(CommunitySharedBuilders(tag: a).merge(null).tag, same(a));
      expect(CommunitySharedBuilders(tag: a).merge(const CommunitySharedBuilders()).tag, same(a));
    });

    testWidgets('confirm and link dialogs use their builders', (tester) async {
      bool? confirmed;
      bool? opened;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () async =>
                      confirmed = await confirmCommunityAction(context, 'Hapus?', confirmLabel: 'OK'),
                  child: const Text('confirm'),
                ),
                TextButton(
                  onPressed: () async => opened = await openCommunityLink(
                    context,
                    Uri.parse('https://example.com/a'),
                    launcher: (_) async => true,
                  ),
                  child: const Text('link'),
                ),
              ],
            ),
          ),
          shared: CommunitySharedBuilders(
            confirmDialog: (context, d, fallback) => AlertDialog(
              title: Text('custom ${d.message}'),
              actions: [TextButton(onPressed: d.onConfirm, child: Text(d.confirmLabel))],
            ),
            linkDialog: (context, d, fallback) => AlertDialog(
              title: Text('custom ${d.domain}'),
              actions: [TextButton(onPressed: d.onConfirm, child: Text(d.confirmLabel))],
            ),
          ),
        ),
      );
      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();
      expect(find.text('custom Hapus?'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);

      await tester.tap(find.text('link'));
      await tester.pumpAndSettle();
      expect(find.text('custom example.com'), findsOneWidget);
      final l10n = CommunityLocalizations.of(tester.element(find.text('custom example.com')))!;
      await tester.tap(find.text(l10n.linkOpenAction));
      await tester.pumpAndSettle();
      expect(opened, isTrue);
    });
  });
}
