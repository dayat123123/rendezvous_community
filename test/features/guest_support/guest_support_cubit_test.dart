import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';

import '../../support/guest_fakes.dart';

const _network = CommunityException(CommunityErrorKind.network, message: 'offline');
final _expired = guestApiError('guest_session_expired', CommunityErrorKind.unauthenticated);

Future<GuestSupportCubit> _started(FakeGuestSupportRepository repo, CommunityGuestSessionStore store) async {
  final cubit = GuestSupportCubit(repository: repo, store: store);
  await cubit.load();
  await cubit.start(name: 'Budi', loginId: 'budi01', problem: 'pin', description: 'Saya lupa PIN aplikasi');
  return cubit;
}

void main() {
  test('load shows the form with the server problems, or the disabled state', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = GuestSupportCubit(repository: repo, store: MemoryGuestSessionStore());
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.phase, GuestSupportPhase.form);
    expect(cubit.state.problems, guestProblems);

    repo.configValue = const GuestSupportConfig();
    await cubit.load();
    expect(cubit.state.phase, GuestSupportPhase.disabled);
  });

  test('start validates locally before calling the server', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = GuestSupportCubit(repository: repo, store: MemoryGuestSessionStore());
    addTearDown(cubit.close);
    await cubit.load();
    expect(await cubit.start(name: 'B', problem: 'pin', description: 'Saya lupa PIN aplikasi'), isFalse);
    expect(await cubit.start(name: 'Budi', problem: null, description: 'Saya lupa PIN aplikasi'), isFalse);
    expect(repo.starts, isEmpty);
  });

  test('start saves the token, opens the chat and loads the first messages', () async {
    final repo = FakeGuestSupportRepository();
    final store = RecordingGuestSessionStore();
    final cubit = await _started(repo, store);
    addTearDown(cubit.close);
    expect(cubit.state.phase, GuestSupportPhase.chat);
    expect(cubit.state.ticket?.queueAhead, 2);
    expect(cubit.state.messages.single.body, 'Saya lupa PIN aplikasi');
    expect(store.token?.token, 'token-abcdefghijklmnopqrstuvwxyz');
    expect(repo.starts.single['loginId'], 'BUDI01');
  });

  test('start errors are reported and the disabled error switches the view', () async {
    final repo = FakeGuestSupportRepository()
      ..startError = guestApiError('guest_login_limit', CommunityErrorKind.rateLimited);
    final cubit = GuestSupportCubit(repository: repo, store: MemoryGuestSessionStore());
    addTearDown(cubit.close);
    await cubit.load();
    expect(await cubit.start(name: 'Budi', problem: 'pin', description: 'Saya lupa PIN aplikasi'), isFalse);
    expect(cubit.state.phase, GuestSupportPhase.form);
    expect(cubit.state.actionErrorId, 1);

    repo.startError = guestApiError('guest_disabled', CommunityErrorKind.forbidden);
    await cubit.start(name: 'Budi', problem: 'pin', description: 'Saya lupa PIN aplikasi');
    expect(cubit.state.phase, GuestSupportPhase.disabled);
  });

  test('failed polls back off from 4 seconds up to one minute and recover after a success', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = await _started(repo, MemoryGuestSessionStore());
    addTearDown(cubit.close);
    expect(cubit.nextPollDelay, const Duration(seconds: 4));

    repo.pollError = _network;
    final delays = <Duration>[];
    for (var i = 0; i < 6; i++) {
      await cubit.poll();
      delays.add(cubit.nextPollDelay);
    }
    expect(delays.map((d) => d.inSeconds), [8, 16, 32, 60, 60, 60]);
    expect(cubit.state.reconnecting, isTrue);

    repo
      ..pollError = null
      ..agentReply('Halo, saya Nadia dari CS');
    await cubit.poll();
    expect(cubit.state.reconnecting, isFalse);
    expect(cubit.state.messages.last.body, 'Halo, saya Nadia dari CS');
    expect(cubit.nextPollDelay, const Duration(seconds: 4));
  });

  test('the timer polls on the interval only while visible', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = GuestSupportCubit(
      repository: repo,
      store: MemoryGuestSessionStore(),
      pollInterval: const Duration(milliseconds: 20),
    );
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.start(name: 'Budi', problem: 'pin', description: 'Saya lupa PIN aplikasi');
    final base = repo.pollCalls;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(repo.pollCalls, greaterThan(base + 2));

    cubit.setVisible(false);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final hidden = repo.pollCalls;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(repo.pollCalls, hidden);

    cubit.setVisible(true);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(repo.pollCalls, greaterThan(hidden));
  });

  test('a resolved ticket ends the session and clears the store', () async {
    final repo = FakeGuestSupportRepository();
    final store = RecordingGuestSessionStore();
    final cubit = await _started(repo, store);
    addTearDown(cubit.close);
    repo.ticket = guestTicket(status: SupportStatus.resolved);
    await cubit.poll();
    expect(cubit.state.phase, GuestSupportPhase.ended);
    expect(cubit.state.endReason, GuestSupportEndReason.resolved);
    expect(store.token, isNull);
    expect(cubit.state.canSend, isFalse);

    await cubit.restart();
    expect(cubit.state.phase, GuestSupportPhase.form);
    expect(cubit.state.messages, isEmpty);
    expect(cubit.state.ticket, isNull);
  });

  test('an expired session ends with the expired reason', () async {
    final repo = FakeGuestSupportRepository();
    final store = RecordingGuestSessionStore();
    final cubit = await _started(repo, store);
    addTearDown(cubit.close);
    repo.pollError = _expired;
    await cubit.poll();
    expect(cubit.state.phase, GuestSupportPhase.ended);
    expect(cubit.state.endReason, GuestSupportEndReason.expired);
    expect(store.token, isNull);
  });

  test('send adds the message, and a failed send can be retried', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = await _started(repo, MemoryGuestSessionStore());
    addTearDown(cubit.close);
    expect(await cubit.send('  Nomor HP saya sudah ganti  '), isTrue);
    expect(cubit.state.messages.last.body, 'Nomor HP saya sudah ganti');
    expect(cubit.state.messages.last.isLocal, isFalse);

    repo.sendError = _network;
    expect(await cubit.send('Halo?'), isFalse);
    final failed = cubit.state.messages.last;
    expect(failed.status, MessageStatus.failed);

    repo.sendError = null;
    expect(await cubit.retry(failed.clientId!), isTrue);
    expect(cubit.state.messages.where((m) => m.body == 'Halo?').single.status, MessageStatus.sent);
  });

  test('sending to a finished ticket refreshes and ends the chat', () async {
    final repo = FakeGuestSupportRepository();
    final cubit = await _started(repo, MemoryGuestSessionStore());
    addTearDown(cubit.close);
    repo
      ..sendError = guestApiError('ticket_not_active', CommunityErrorKind.invalidInput)
      ..ticket = guestTicket(status: SupportStatus.closed);
    expect(await cubit.send('Halo'), isFalse);
    expect(cubit.state.phase, GuestSupportPhase.ended);
    expect(cubit.state.endReason, GuestSupportEndReason.closed);
  });

  test('end calls guest_end and clears the store', () async {
    final repo = FakeGuestSupportRepository();
    final store = RecordingGuestSessionStore();
    final cubit = await _started(repo, store);
    addTearDown(cubit.close);
    await cubit.end();
    expect(repo.endCalls, 1);
    expect(cubit.state.endReason, GuestSupportEndReason.ended);
    expect(store.token, isNull);
  });

  test('a saved token resumes the chat, an expired one falls back to the form', () async {
    final repo = FakeGuestSupportRepository()..agentReply('Sudah kami kirim ke email terdaftar');
    final saved = GuestSupportToken(
      token: 'saved-token-abcdefghijklmnop',
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    );
    final store = RecordingGuestSessionStore(token: saved);
    final cubit = GuestSupportCubit(repository: repo, store: store);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.phase, GuestSupportPhase.chat);
    expect(repo.tokens.first, 'saved-token-abcdefghijklmnop');
    expect(cubit.state.messages.single.body, 'Sudah kami kirim ke email terdaftar');

    final stale = RecordingGuestSessionStore(token: saved);
    repo.pollError = _expired;
    final again = GuestSupportCubit(repository: repo, store: stale);
    addTearDown(again.close);
    await again.load();
    expect(again.state.phase, GuestSupportPhase.form);
    expect(stale.token, isNull);

    final old = RecordingGuestSessionStore(
      token: GuestSupportToken(token: 'old', expiresAt: DateTime.now().subtract(const Duration(minutes: 1))),
    );
    final calls = repo.pollCalls;
    final third = GuestSupportCubit(repository: repo, store: old);
    addTearDown(third.close);
    await third.load();
    expect(repo.pollCalls, calls);
    expect(third.state.phase, GuestSupportPhase.form);
    expect(old.token, isNull);
  });
}
