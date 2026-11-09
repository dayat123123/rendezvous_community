import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_incidents.dart';

import '../../../support/fakes.dart';
import '../../../support/help_fakes.dart';
import '../../../support/support_kit.dart';

const _survey = SupportSurvey(
  question: 'Bagaimana layanan CS kami?',
  scale: 3,
  reasons: [SupportSurveyReason(code: 'slow', label: 'Terlalu lama')],
);

void main() {
  setUp(SupportIncidentDismissals.reset);

  test('the new slots merge like the others', () {
    Widget a(BuildContext context, Object details, Widget fallback) => const Text('a');
    Widget b(BuildContext context, Object details, Widget fallback) => const Text('b');
    final base = CommunitySupportBuilders(
      incidentBanner: a,
      intakeForm: a,
      intakeField: a,
      surveyReasons: a,
      replySuggestions: a,
    );
    final merged = base.merge(CommunitySupportBuilders(intakeField: b, replySuggestions: b));
    expect(merged.incidentBanner, equals(a));
    expect(merged.intakeForm, equals(a));
    expect(merged.surveyReasons, equals(a));
    expect(merged.intakeField, equals(b));
    expect(merged.replySuggestions, equals(b));
  });

  testWidgets('incident banner, intake form and field can be replaced', (tester) async {
    final support = MockSupport();
    stubSupport(
      support,
      home: const SupportHome(
        supportName: 'CS OLT',
        incidents: [
          SupportIncident(id: 'i-1', title: 'Gangguan login', body: 'x', level: SupportIncidentLevel.warning),
        ],
      ),
    );
    stubOpenTicket(support, supportTicket(status: SupportStatus.open));
    final fieldTypes = <SupportIntakeType>[];
    await pumpSupportChat(
      tester,
      support,
      builders: CommunityBuilders(
        support: CommunitySupportBuilders(
          incidentBanner: (context, d, fallback) =>
              ListTile(title: Text('custom ${d.title} ${d.level.name}'), onTap: d.onDismiss),
          intakeField: (context, d, fallback) {
            fieldTypes.add(d.type);
            return fallback;
          },
          intakeForm: (context, d, fallback) => Column(
            children: [
              Text('custom form ${d.topic.code} ${d.fields.length}'),
              ...d.fieldViews,
              TextButton(onPressed: d.onBack, child: Text(d.backLabel)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('custom Gangguan login warning'), findsOneWidget);
    await tester.tap(find.text('custom Gangguan login warning'));
    await tester.pumpAndSettle();
    expect(find.text('custom Gangguan login warning'), findsNothing);

    await tester.tap(find.text('Order & Transaksi'));
    await tester.pumpAndSettle();
    expect(find.text('custom form orders 4'), findsOneWidget);
    expect(fieldTypes.toSet(), SupportIntakeType.values.toSet());
  });

  testWidgets('survey reasons and the rating dialog get the survey details', (tester) async {
    CommunitySupportRatingDetails? rating;
    await tester.pumpWidget(
      supportApp(
        const SupportRatingDialog(survey: _survey, initialRating: 1),
        builders: CommunityBuilders(
          support: CommunitySupportBuilders(
            ratingDialog: (context, d, fallback) {
              rating = d;
              return fallback;
            },
            surveyReasons: (context, d, fallback) => Text('reasons ${d.reasons.single.code} ${d.selected.length}'),
          ),
        ),
      ),
    );

    expect(find.text('reasons slow 0'), findsOneWidget);
    expect(rating?.faces, isTrue);
    expect(rating?.values, [1, 3, 5]);
    expect(rating?.asksReasons, isTrue);
    expect(rating?.ratingLabels[3], 'Biasa saja');
    rating?.onToggleReason?.call('slow');
    await tester.pump();
    expect(find.text('reasons slow 1'), findsOneWidget);
  });

  testWidgets('reply suggestions can be replaced and still send', (tester) async {
    final support = MockSupport();
    stubSupport(
      support,
      home: SupportHome(
        roomId: 'r-cs',
        supportName: 'CS OLT',
        ticket: supportTicket(quickReplies: const ['Sudah']),
        active: true,
      ),
    );
    final chat = RecordingChatRepository(
      rooms: [ChatRoom(id: 'r-cs', type: RoomType.support, createdAt: DateTime.now(), lastReadAt: DateTime.now())],
    );
    await pumpSupportChat(
      tester,
      support,
      chat: chat,
      builders: CommunityBuilders(
        support: CommunitySupportBuilders(
          replySuggestions: (context, d, fallback) => Wrap(
            children: [
              for (final reply in d.replies)
                OutlinedButton(onPressed: () => d.onSelect?.call(reply), child: Text('[$reply]')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('[Sudah]'));
    await tester.pumpAndSettle();
    expect(chat.sentBodies, ['Sudah']);
  });

  testWidgets('the transcript page header carries the download action', (tester) async {
    final support = MockSupport();
    stubSupport(support);
    when(() => support.myTickets()).thenAnswer((_) async => [supportTicket(status: SupportStatus.closed)]);
    when(() => support.ticketMessages(any())).thenAnswer((_) async => const []);
    CommunitySupportPageHeaderDetails? header;
    final chat = FakeChatRepository();
    await tester.pumpWidget(
      supportApp(
        CommunityScope(
          dependencies: FakeDependencies(chat: chat),
          child: CommunitySupportScope(
            dependencies: SupportDeps(support, chat),
            child: const CommunitySupportTickets(),
          ),
        ),
        builders: CommunityBuilders(
          support: CommunitySupportBuilders(
            pageHeader: (context, d, fallback) {
              header = d;
              return fallback;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('CS-20261109-0001'));
    await tester.pumpAndSettle();

    expect(header?.downloadLabel, 'Unduh transkrip');
    expect(header?.canDownload, isTrue);
    expect(header?.downloading, isFalse);
  });

  testWidgets('the help suggestions step tells builders when it is a leave-a-message step', (tester) async {
    final support = MockSupport();
    stubSupport(support, home: const SupportHome(supportName: 'CS OLT', serviceOpen: false));
    CommunityHelpSuggestionsDetails? details;
    await pumpSupportChat(
      tester,
      support,
      help: FakeHelpRepository(),
      builders: CommunityBuilders(
        help: CommunityHelpBuilders(
          topicSuggestions: (context, d, fallback) {
            details = d;
            return fallback;
          },
        ),
      ),
    );

    await tester.tap(find.text('Deposit/Tarik Dana'));
    await tester.pumpAndSettle();

    expect(details?.outOfHours, isTrue);
    expect(details?.continueLabel, 'Tinggalkan pesan');
    expect(details?.notice, 'CS sedang di luar jam layanan');
    expect(details?.articles, isEmpty);
  });
}
