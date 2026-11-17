import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

import '../../support/trade_share_fakes.dart';

Future<FakeTradeShareDependencies> _pump(WidgetTester tester, TradeShareStatus status) async {
  final trade = FakeTradeShareDependencies(FakeTradeShareRepository(status: status));
  addTearDown(trade.dispose);
  await pumpTradeApp(tester, const CommunityTradeShareSettings(), trade: trade, size: const Size(900, 3000));
  await tester.pumpAndSettle();
  return trade;
}

Finder _primary() => find.byKey(const ValueKey('trade-primary-action'));

bool _enabled(WidgetTester tester, Finder finder) => tester.widget<FilledButton>(finder).onPressed != null;

void main() {
  testWidgets('an eligible customer picks accounts, sees the live preview, accepts the terms and applies', (
    tester,
  ) async {
    final trade = await _pump(tester, tradeStatus());
    final repo = trade.repository;

    expect(find.text('Belum mengajukan'), findsOneWidget);
    expect(find.text('Syarat pengajuan'), findsOneWidget);
    expect(find.text('Punya rekening tertaut yang aktif'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outlined), findsNWidgets(eligibleChecks.length));

    final active = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('trade-account-W137')));
    final expired = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('trade-account-W200')));
    expect(active.value, isTrue);
    expect(active.onChanged, isNotNull);
    expect(expired.value, isFalse);
    expect(expired.onChanged, isNull);
    expect(find.text('Kedaluwarsa'), findsOneWidget);

    expect(find.text(r'Budi Santoso membeli $BBCA'), findsOneWidget);
    expect(find.text('25 lot @ 9.150'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trade-show-price')));
    await tester.pumpAndSettle();
    expect(find.text('25 lot'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trade-show-lot')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('trade-preview-body')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('trade-show-lot')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('trade-delay')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('60 menit').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perlu persetujuan'));
    await tester.pumpAndSettle();
    expect(find.text('Anda menyetujui atau menolak setiap permintaan langganan.'), findsOneWidget);

    expect(_enabled(tester, _primary()), isFalse);
    await tester.tap(find.text('Baca S&K'));
    await tester.pumpAndSettle();
    expect(find.text('Isi syarat dan ketentuan berbagi trade.'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    repo.nextStatus = tradeStatus(
      status: TradeSharerStatus.pending,
      accounts: const [TradeShareAccount(custId: 'W137')],
    );
    await tester.tap(find.byKey(const ValueKey('trade-accept-terms')));
    await tester.pumpAndSettle();
    expect(_enabled(tester, _primary()), isTrue);
    await tester.tap(_primary());
    await tester.pumpAndSettle();

    final (application, termsId) = repo.applications.single;
    expect(termsId, 'doc-terms');
    expect(application.accounts, ['W137']);
    expect(application.showPrice, isFalse);
    expect(application.showLot, isTrue);
    expect(application.delayMinutes, 60);
    expect(application.subscribeMode, TradeSubscribeMode.approval);
    expect(find.text('Pengajuan terkirim. Menunggu peninjauan.'), findsOneWidget);
    expect(find.text('Menunggu peninjauan'), findsOneWidget);
    expect(find.text('Simpan perubahan'), findsOneWidget);
  });

  testWidgets('failed requirements show their reason and block the application', (tester) async {
    await _pump(
      tester,
      tradeStatus(
        eligible: false,
        checks: const [
          TradeShareCheck(code: TradeShareCheckCode.featureEnabled, ok: true),
          TradeShareCheck(code: TradeShareCheckCode.accountAge, ok: false),
          TradeShareCheck(code: TradeShareCheckCode.pilotInvited, ok: false),
        ],
      ),
    );

    expect(find.byIcon(Icons.cancel_outlined), findsNWidgets(2));
    expect(find.text('Profil komunitas Anda belum cukup lama.'), findsOneWidget);
    expect(find.text('Saat ini pengajuan hanya untuk nasabah undangan.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trade-accept-terms')));
    await tester.pumpAndSettle();
    expect(_enabled(tester, _primary()), isFalse);
  });

  testWidgets('values hidden by Compliance cannot be switched on and stay out of the preview', (tester) async {
    await _pump(tester, tradeStatus(limits: const TradeShareLimits(forceHidePrice: true)));

    final price = tester.widget<SwitchListTile>(find.byKey(const ValueKey('trade-show-price')));
    expect(price.value, isFalse);
    expect(price.onChanged, isNull);
    expect(find.text('Disembunyikan oleh Kepatuhan'), findsOneWidget);
    expect(find.text('25 lot'), findsOneWidget);
  });

  testWidgets('a rejected application shows the reason and the waiting period', (tester) async {
    final until = DateTime.now().add(const Duration(days: 10));
    await _pump(
      tester,
      tradeStatus(
        status: TradeSharerStatus.rejected,
        decisionReason: 'Data belum lengkap',
        cooldownUntil: until,
        eligible: false,
        checks: const [TradeShareCheck(code: TradeShareCheckCode.cooldown, ok: false)],
      ),
    );

    expect(find.text('Ditolak'), findsOneWidget);
    expect(find.text('Pengajuan Anda ditolak.'), findsOneWidget);
    expect(find.text('Alasan: Data belum lengkap'), findsOneWidget);
    expect(find.textContaining('Anda bisa mengajukan lagi mulai'), findsNWidgets(2));
    expect(find.text('Ajukan'), findsOneWidget);
  });

  testWidgets('a suspended trader sees the end date and can only stop sharing', (tester) async {
    await _pump(
      tester,
      tradeStatus(
        status: TradeSharerStatus.suspended,
        decisionReason: 'Dalam pemeriksaan',
        suspendedUntil: DateTime.utc(2026, 12, 1),
      ),
    );

    expect(find.text('Ditangguhkan'), findsOneWidget);
    expect(find.text('Alasan: Dalam pemeriksaan'), findsOneWidget);
    expect(find.textContaining('Ditangguhkan sampai'), findsOneWidget);
    expect(find.text('Jeda'), findsNothing);
    expect(find.text('Lanjutkan'), findsNothing);
    expect(find.text('Berhenti membagikan'), findsOneWidget);
    expect(_primary(), findsNothing);
  });

  testWidgets('an active trader pauses, resumes and stops after confirming', (tester) async {
    final trade = await _pump(
      tester,
      tradeStatus(
        status: TradeSharerStatus.active,
        delayMinutes: 30,
        accounts: const [TradeShareAccount(custId: 'W137')],
        activeSubscribers: 4,
        pendingSubscribers: 1,
      ),
    );
    final repo = trade.repository;

    expect(find.text('Trade Anda dibagikan ke pelanggan 30 menit setelah match.'), findsOneWidget);
    expect(find.text('4 aktif · 1 menunggu'), findsOneWidget);

    repo.nextStatus = tradeStatus(status: TradeSharerStatus.paused, pauseSource: TradePauseSource.user);
    await tester.tap(find.text('Jeda'));
    await tester.pumpAndSettle();
    expect(find.text('Dijeda'), findsOneWidget);

    repo.nextStatus = tradeStatus(status: TradeSharerStatus.active, delayMinutes: 30);
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    expect(find.text('Aktif'), findsWidgets);

    await tester.tap(find.text('Berhenti membagikan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Semua langganan berakhir'), findsOneWidget);
    repo.nextStatus = tradeStatus(status: TradeSharerStatus.withdrawn);
    await tester.tap(find.widgetWithText(FilledButton, 'Berhenti membagikan'));
    await tester.pumpAndSettle();

    expect(repo.calls, containsAllInOrder(['pause', 'resume', 'withdraw']));
    expect(find.text('Dihentikan'), findsOneWidget);
    expect(trade.tradeShare.current?.status, TradeSharerStatus.withdrawn);
  });

  testWidgets('changing what is shared asks for confirmation before saving', (tester) async {
    final trade = await _pump(
      tester,
      tradeStatus(
        status: TradeSharerStatus.active,
        delayMinutes: 15,
        accounts: const [TradeShareAccount(custId: 'W137')],
      ),
    );
    final repo = trade.repository..errorFor = (call) => call == 'update' ? tradeError('confirmation_required') : null;

    await tester.tap(find.byKey(const ValueKey('trade-show-lot')));
    await tester.pumpAndSettle();
    await tester.tap(_primary());
    await tester.pumpAndSettle();

    expect(find.textContaining('Ubah cakupan data?'), findsOneWidget);
    repo.nextStatus = tradeStatus(status: TradeSharerStatus.active, showLot: false, delayMinutes: 15);
    await tester.tap(find.text('Ya, ubah'));
    await tester.pumpAndSettle();

    expect(repo.updates.map((u) => (u.$1.showLot, u.$2)), [(false, false), (false, true)]);
    expect(find.text('Pengaturan disimpan.'), findsOneWidget);
  });

  testWidgets('declining the confirmation keeps the old settings', (tester) async {
    final trade = await _pump(
      tester,
      tradeStatus(status: TradeSharerStatus.paused, pauseSource: TradePauseSource.system, delayMinutes: 15),
    );
    final repo = trade.repository..errorFor = (call) => call == 'update' ? tradeError('confirmation_required') : null;

    expect(find.text('Dijeda otomatis karena tidak ada rekening yang bisa dibagikan.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trade-account-W137')));
    await tester.pumpAndSettle();
    await tester.tap(_primary());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(repo.updates.single.$2, isFalse);
    expect(find.text('Pengaturan disimpan.'), findsNothing);
  });

  testWidgets('the page is hidden behind a notice when the feature is switched off', (tester) async {
    await _pump(tester, tradeStatus(enabled: false));

    expect(find.text('Fitur berbagi trade sedang tidak tersedia.'), findsOneWidget);
    expect(find.text('Syarat pengajuan'), findsNothing);
  });

  testWidgets('without trade share dependencies the page shows the notice', (tester) async {
    await pumpTradeApp(tester, const CommunityTradeShareSettings());
    await tester.pumpAndSettle();

    expect(find.text('Fitur berbagi trade sedang tidak tersedia.'), findsOneWidget);
  });

  testWidgets('English texts are used for the English locale', (tester) async {
    final trade = FakeTradeShareDependencies(FakeTradeShareRepository(status: tradeStatus()));
    addTearDown(trade.dispose);
    await pumpTradeApp(
      tester,
      const CommunityTradeShareSettings(),
      trade: trade,
      locale: const Locale('en'),
      size: const Size(900, 3000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not applied'), findsOneWidget);
    expect(find.text(r'Budi Santoso bought $BBCA'), findsOneWidget);
    expect(find.text('25 lots @ 9,150'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });
}
