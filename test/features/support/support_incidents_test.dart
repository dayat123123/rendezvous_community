import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/data/repositories/support_repository_impl.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_incidents.dart';

import '../../support/help_fakes.dart';
import '../../support/mock_api.dart';
import '../../support/support_kit.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

const _outage = SupportIncident(
  id: 'i-1',
  title: 'Gangguan login',
  body: 'Sebagian nasabah gagal masuk. Tim kami sedang menangani.',
  level: SupportIncidentLevel.critical,
  faqArticleId: 'a-login',
);

const _notice = SupportIncident(id: 'i-2', title: 'Pemeliharaan malam ini', body: 'Pukul 23.00–24.00 WIB.');

void main() {
  setUp(SupportIncidentDismissals.reset);

  group('parsing', () {
    late MockApi cs;
    late SupportRepositoryImpl repo;

    setUp(() {
      cs = mockApi();
      repo = SupportRepositoryImpl(cs: cs, notifications: _MockNotifications());
    });

    test('support home carries incidents and per-language surveys', () async {
      when(() => cs.rpcValue('support_home', any())).thenAnswer(
        (_) async => {
          'support_name': 'CS OLT',
          'incidents': [
            {
              'id': 'i-1',
              'title': 'Gangguan login',
              'body': 'Sedang ditangani.',
              'level': 'warning',
              'starts_at': '2026-11-09T01:00:00Z',
              'ends_at': null,
              'faq_article_id': 'a-login',
            },
            {'id': 'i-2', 'title': 'Info', 'body': 'x', 'level': 'mystery'},
            {'title': 'no id'},
          ],
          'survey': {
            'id': {
              'question': 'Bagaimana layanan CS kami?',
              'scale': 3,
              'low_max': 2,
              'reasons': [
                {'code': 'slow', 'label': 'Terlalu lama'},
              ],
            },
            'en': {'question': 'How was our service?', 'scale': 5, 'low_max': 2, 'reasons': []},
          },
        },
      );

      final home = await repo.home();

      expect(home.incidents.map((i) => i.id), ['i-1', 'i-2']);
      expect(home.incidents.first.level, SupportIncidentLevel.warning);
      expect(home.incidents.first.faqArticleId, 'a-login');
      expect(home.incidents.last.level, SupportIncidentLevel.info);
      expect(home.survey('id')?.values, [1, 3, 5]);
      expect(home.survey('en')?.values, [1, 2, 3, 4, 5]);
      expect(home.survey('fr')?.question, 'Bagaimana layanan CS kami?');
    });

    test('an older server without incidents and survey gives empty defaults', () async {
      when(() => cs.rpcValue('support_home', any())).thenAnswer((_) async => {'support_name': 'CS OLT'});

      final home = await repo.home();

      expect(home.incidents, isEmpty);
      expect(home.survey('id'), isNull);
    });

    test('service status reads incidents and falls back to none when the RPC is missing', () async {
      when(() => cs.rpcValue('service_status', {'p_language': 'en'})).thenAnswer(
        (_) async => {
          'incidents': [
            {'id': 'i-1', 'title': 'Login outage', 'body': 'We are on it.', 'level': 'critical'},
          ],
        },
      );
      expect((await repo.serviceStatus(language: 'en')).single.title, 'Login outage');

      when(
        () => cs.rpcValue('service_status', any()),
      ).thenThrow(const CommunityException(CommunityErrorKind.notFound, code: 'PGRST202'));
      expect(await repo.serviceStatus(), isEmpty);
    });
  });

  group('banner in the support chat', () {
    late MockSupport support;
    late StreamController<void> events;

    setUp(() {
      support = MockSupport();
      events = StreamController<void>.broadcast();
      addTearDown(events.close);
      stubSupport(
        support,
        home: const SupportHome(roomId: 'r-cs', supportName: 'CS OLT', incidents: [_outage, _notice]),
      );
      when(() => support.watchTicket(any())).thenAnswer((_) => events.stream);
    });

    testWidgets('shows each incident by level, opens the related article, and can be dismissed', (tester) async {
      final help = FakeHelpRepository();
      await pumpSupportChat(tester, support, help: help);

      expect(find.text('Gangguan login'), findsOneWidget);
      expect(find.text('Pemeliharaan malam ini'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Selengkapnya'), findsOneWidget);

      await tester.tap(find.text('Selengkapnya'));
      await tester.pumpAndSettle();
      expect(help.articleReads, ['a-login']);
      expect(find.text('Tidak bisa masuk ke aplikasi'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Tutup pemberitahuan').first);
      await tester.pumpAndSettle();
      expect(find.text('Gangguan login'), findsNothing);
      expect(find.text('Pemeliharaan malam ini'), findsOneWidget);
      expect(SupportIncidentDismissals.dismissed.value, {'i-1'});
    });

    testWidgets('without the help center there is no read-more action', (tester) async {
      await pumpSupportChat(tester, support);

      expect(find.text('Gangguan login'), findsOneWidget);
      expect(find.text('Selengkapnya'), findsNothing);
    });

    testWidgets('banners disappear when the server stops returning them', (tester) async {
      await pumpSupportChat(tester, support);
      expect(find.text('Gangguan login'), findsOneWidget);

      when(() => support.home()).thenAnswer((_) async => const SupportHome(roomId: 'r-cs', supportName: 'CS OLT'));
      events.add(null);
      await tester.pumpAndSettle();

      expect(find.text('Gangguan login'), findsNothing);
      expect(find.text('Pemeliharaan malam ini'), findsNothing);
    });

    testWidgets('English users get the incidents in English from service_status', (tester) async {
      when(() => support.serviceStatus(language: 'en')).thenAnswer(
        (_) async => const [
          SupportIncident(id: 'i-1', title: 'Login outage', body: 'We are on it.', level: SupportIncidentLevel.warning),
        ],
      );
      await pumpSupportChat(tester, support, locale: const Locale('en'));

      expect(find.text('Login outage'), findsOneWidget);
      expect(find.text('Gangguan login'), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('an incident that already ended is hidden even before the next refresh', (tester) async {
      stubSupport(
        support,
        home: SupportHome(
          roomId: 'r-cs',
          supportName: 'CS OLT',
          incidents: [_notice.copyWith(endsAt: DateTime.now().subtract(const Duration(minutes: 1)))],
        ),
      );
      await pumpSupportChat(tester, support);

      expect(find.text('Pemeliharaan malam ini'), findsNothing);
    });
  });

  group('banner in the help center', () {
    testWidgets('shows active incidents and opens the linked article from the loaded content', (tester) async {
      final support = MockSupport();
      when(() => support.serviceStatus(language: any(named: 'language'))).thenAnswer((_) async => const [_outage]);
      final help = FakeHelpRepository();
      await tester.pumpWidget(
        supportApp(
          CommunityHelpScope(
            dependencies: FakeHelpDependencies(help),
            child: CommunityHelpCenter(support: support, onContactSupport: (_, _) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gangguan login'), findsOneWidget);
      await tester.tap(find.text('Selengkapnya'));
      await tester.pumpAndSettle();
      expect(find.text('Tidak bisa masuk ke aplikasi'), findsWidgets);
    });

    testWidgets('a failing status request leaves the help center as it was', (tester) async {
      final support = MockSupport();
      when(
        () => support.serviceStatus(language: any(named: 'language')),
      ).thenThrow(const CommunityException(CommunityErrorKind.network));
      await tester.pumpWidget(
        supportApp(
          CommunityHelpScope(
            dependencies: FakeHelpDependencies(FakeHelpRepository()),
            child: CommunityHelpCenter(support: support, onContactSupport: (_, _) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Akun & Keamanan'), findsOneWidget);
      expect(find.byType(SupportIncidentBanner), findsNothing);
    });
  });
}
