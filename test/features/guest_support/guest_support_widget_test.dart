import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/guest_fakes.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeGuestSupportRepository repo, {
  CommunityGuestSessionStore? store,
  Locale locale = const Locale('id'),
  CommunityBuilders? builders,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: CommunityLocalizations.localizationsDelegates,
      supportedLocales: CommunityLocalizations.supportedLocales,
      home: CommunityBuildersScope(
        builders: builders ?? const CommunityBuilders(),
        child: CommunityGuestSupportScope(
          dependencies: CommunityGuestSupportClient(guestSupport: repo, sessions: store),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => openCommunityGuestSupport(context),
                  child: Text(context.communityL10n.guestSupportEntry),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(TextButton));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, {String name = 'Budi Santoso', String description = 'Saya lupa PIN'}) async {
  await tester.enterText(find.byKey(const ValueKey('guest-name')), name);
  await tester.enterText(find.byKey(const ValueKey('guest-login-id')), 'budi01');
  await tester.tap(find.byKey(const ValueKey('guest-problem-pin')));
  await tester.enterText(find.byKey(const ValueKey('guest-description')), description);
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('guest-submit')));
  await tester.tap(find.byKey(const ValueKey('guest-submit')));
  await tester.pump();
  await tester.pump();
}

Future<void> _startChat(WidgetTester tester, FakeGuestSupportRepository repo) async {
  await _fill(tester, description: 'Saya lupa PIN setelah ganti HP');
  await _submit(tester);
  await tester.pump();
}

Future<void> _leave(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  testWidgets('the form shows the security note, uppercases the login ID and validates like the server', (
    tester,
  ) async {
    final repo = FakeGuestSupportRepository();
    await _pump(tester, repo);

    expect(
      find.text(
        'CS tidak pernah meminta password, PIN, atau OTP. Reset password/PIN hanya dikirim ke email yang terdaftar '
        'di akun Anda.',
      ),
      findsOneWidget,
    );
    for (final problem in guestProblems) {
      expect(find.text(problem.label), findsOneWidget);
    }

    await _submit(tester);
    expect(find.text('Isi nama Anda.'), findsOneWidget);
    expect(find.text('Pilih jenis masalah.'), findsOneWidget);
    expect(find.text('Ceritakan masalahnya.'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('guest-login-id')), 'budi 01');
    await _fill(tester, name: 'B', description: 'lupa');
    await tester.enterText(find.byKey(const ValueKey('guest-login-id')), 'budi 01');
    await tester.pump();
    final loginField = tester.widget<TextField>(find.byKey(const ValueKey('guest-login-id')));
    expect(loginField.controller!.text, 'BUDI 01');
    expect(find.text('Nama 2–60 karakter.'), findsOneWidget);
    expect(find.textContaining('Login ID hanya boleh huruf A–Z'), findsOneWidget);
    expect(find.text('Ceritakan masalahnya (10–1000 karakter).'), findsOneWidget);
    expect(repo.starts, isEmpty);
    await _leave(tester);
  });

  testWidgets('starting opens the chat with the queue position, and polling shows a new agent reply', (tester) async {
    final repo = FakeGuestSupportRepository();
    await _pump(tester, repo);
    await _startChat(tester, repo);

    expect(repo.starts.single, {
      'name': 'Budi Santoso',
      'loginId': 'BUDI01',
      'problem': 'pin',
      'description': 'Saya lupa PIN setelah ganti HP',
      'language': 'id',
    });
    expect(find.text('Pengaduan #CS-20261109-0042'), findsOneWidget);
    expect(find.textContaining('2 tiket di depan Anda'), findsOneWidget);
    expect(find.textContaining('Perkiraan menunggu ± 6 menit'), findsOneWidget);
    expect(find.text('Saya lupa PIN setelah ganti HP'), findsOneWidget);
    expect(find.textContaining('CS tidak pernah meminta password'), findsOneWidget);
    expect(find.textContaining('percakapan ini hilang bila aplikasi ditutup'), findsOneWidget);

    repo
      ..ticket = guestTicket(status: SupportStatus.claimed)
      ..agentReply('Halo Pak Budi, link reset PIN sudah kami kirim ke email terdaftar.');
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.text('Halo Pak Budi, link reset PIN sudah kami kirim ke email terdaftar.'), findsOneWidget);
    expect(find.text('Nadia'), findsWidgets);
    expect(find.textContaining('Ditangani oleh Nadia'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('guest-composer')), 'Terima kasih, sudah masuk');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('guest-send')));
    await tester.pump();
    await tester.pump();
    expect(repo.sent, ['Terima kasih, sudah masuk']);
    expect(find.text('Terima kasih, sudah masuk'), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('a resolved ticket shows the final state and a new complaint can be started', (tester) async {
    final repo = FakeGuestSupportRepository();
    final store = RecordingGuestSessionStore();
    await _pump(tester, repo, store: store);
    await _startChat(tester, repo);
    expect(store.token, isNotNull);

    repo.ticket = guestTicket(status: SupportStatus.resolved);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(
      find.text('Pengaduan #CS-20261109-0042 sudah selesai. Bila masih perlu bantuan, buat pengaduan baru.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('guest-composer')), findsNothing);
    expect(find.byKey(const ValueKey('guest-end')), findsNothing);
    expect(store.token, isNull);

    final polls = repo.pollCalls;
    await tester.pump(const Duration(seconds: 12));
    expect(repo.pollCalls, polls);

    await tester.tap(find.byKey(const ValueKey('guest-new')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('guest-submit')), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('an expired session shows the expired state', (tester) async {
    final repo = FakeGuestSupportRepository();
    await _pump(tester, repo);
    await _startChat(tester, repo);

    repo.pollError = guestApiError('guest_session_expired', CommunityErrorKind.unauthenticated);
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.text('Sesi pengaduan sudah berakhir. Silakan buat pengaduan baru.'), findsOneWidget);
    expect(find.byKey(const ValueKey('guest-new')), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('ending asks for confirmation and calls guest_end', (tester) async {
    final repo = FakeGuestSupportRepository();
    await _pump(tester, repo);
    await _startChat(tester, repo);

    await tester.tap(find.byKey(const ValueKey('guest-end')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Akhiri').last);
    await tester.pump();
    await tester.pump();
    expect(repo.endCalls, 1);
    expect(find.text('Anda sudah mengakhiri pengaduan #CS-20261109-0042.'), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('server errors from start are shown as messages', (tester) async {
    final repo = FakeGuestSupportRepository()
      ..startError = guestApiError('rate_limited', CommunityErrorKind.rateLimited);
    await _pump(tester, repo);
    await _fill(tester, description: 'Saya lupa PIN setelah ganti HP');
    await _submit(tester);
    await tester.pump();
    expect(find.text('Terlalu banyak pengaduan dari perangkat ini. Coba lagi nanti.'), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('the disabled state is shown when the server turns guest complaints off', (tester) async {
    final repo = FakeGuestSupportRepository(configValue: const GuestSupportConfig());
    await _pump(tester, repo, locale: const Locale('en'));
    expect(
      find.text(
        'Complaints without signing in are not available right now. Please try again later or contact a branch office.',
      ),
      findsOneWidget,
    );
    await _leave(tester);
  });

  testWidgets('builders replace the form, security note and chat header', (tester) async {
    final repo = FakeGuestSupportRepository();
    await _pump(
      tester,
      repo,
      builders: CommunityBuilders(
        support: CommunitySupportBuilders(
          guestSecurityNote: (context, d, fallback) => Text('NOTE ${d.message.length > 20}'),
          guestHeader: (context, d, fallback) => Text('HEADER ${d.ticketNumber} ${d.onEnd != null}'),
          guestForm: (context, d, fallback) => Column(
            children: [
              d.securityNote,
              TextButton(
                onPressed: () {
                  d.nameController.text = 'Budi';
                  d.descriptionController.text = 'Saya lupa password';
                  d.onSelectProblem('password');
                  WidgetsBinding.instance.addPostFrameCallback((_) => d.onSubmit());
                },
                child: Text('CUSTOM ${d.problems.length}'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('NOTE true'), findsOneWidget);
    await tester.tap(find.text('CUSTOM 4'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(repo.starts.single['problem'], 'password');
    expect(find.text('HEADER CS-20261109-0042 true'), findsOneWidget);
    await _leave(tester);
  });
}
