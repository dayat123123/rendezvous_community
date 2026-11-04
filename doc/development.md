# Pengembangan

[← Kembali ke README](../README.md)

Perintah ini dijalankan dari root repo paket. Tes integrasi (`test/integration`, `example/integration_test`) dan `make perf-flutter` butuh stack backend dari repo [chat_service_supabase](https://github.com/dayat123123/chat_service_supabase/blob/main/README.md).

```bash
flutter pub get
dart run build_runner build      # setelah mengubah model/state freezed
flutter gen-l10n                 # setelah mengubah file .arb
flutter analyze                  # wajib: tanpa issue
flutter test                     # unit + widget test (integration dilewati)
OLT_SOCIAL_IT=1 flutter test test/integration   # butuh stack Docker + seed + auth-bridge mode mock
dart run tool/license_audit.dart # tolak GPL/AGPL/LGPL/MPL
dart run tool/check_comments.dart # gagal bila ada komentar di kode Dart (kecuali // ignore & file generate)
dart run tool/check_logging.dart  # gagal bila library memakai print/debugPrint langsung
```

| Test | Isi |
|---|---|
| `test/core` | Parser `$KODE`/`@mention` (identik dengan regex di DB), pemetaan error, TokenManager (single-flight, refresh, login gagal), media gateway (URL, header, `x-upsert`, refresh 401, pemetaan kode error) |
| `test/features/*/data` | Repository dengan data source mock: parameter RPC, pemetaan baris, pagination, idempotensi, polling, status centang |
| `test/features/*/domain` | Perhitungan centang (DM & grup), DeliveryTracker, aturan draf polling |
| `test/features/*/presentation` | Cubit daftar chat (mengetik, centang, online, sinkron ulang setelah reconnect), cubit room, cubit & widget badge chat, tile room, widget polling, composer polling, thread komentar |
| `test/features/legal`, `test/features/account` | Pemetaan `get_legal_documents`, cache per sesi, gerbang persetujuan (tertunda → setuju → ulang sekali, ditunda, chat CS), alur & pembaca dokumen, banner feed, ekspor data (isi + nama file, batas harian), hapus akun (ketik `HAPUS`, callback, sesi dibersihkan) |
| `test/integration` | Ke backend nyata: login, feed keyset, thread, komentar & chat realtime, presence per room, centang terkirim → dibaca, badge chat belum dibaca, polling, rate limit, dokumen hukum, unggah lewat media gateway, konfigurasi klien (anon & login), pencarian/hashtag/trending, bookmark, jendela edit, permintaan DM (akun baru → budi, batas 3, terima), kebijakan DM, slow mode (`slow_mode` + detik), link preview, analitik, reaksi realtime & bagikan post, broadcast pesan dari server dan penolakan event palsu dari anggota room (1.5.0), banner di konfigurasi, `report_notification_event`, draf (simpan, ubah, hapus, terbit menghapus draf), kartu saham |
| `test/features/{config,search,trending,bookmarks,chat,message_requests,appeals,link_preview}` | 1.3.0: pemetaan RPC dengan mock, cubit (debounce pencarian, bookmark/edit optimistis, reaksi, slow mode, permintaan pesan, preferensi notifikasi), widget (gate kill switch, sentimen, menu post, chip reaksi, room permintaan, dialog tautan, banding) |
| `test/core/logging` | Logger: field terstruktur, level, sanitasi data sensitif, `initialize(logHandler:)` |
| `test/features/{config,notifications,drafts,chat}` (0087–0090) | Banner (parsing, prioritas, tutup tersimpan, widget), laporan dibuka/diketuk (dedupe, antrean offline, push & kotak notifikasi), tipe notifikasi baru & sakelar terkunci, draf (simpan, offline/batas, konflik, gabung daftar, autosave composer, `client_id`), kartu saham (parsing, normalisasi, cubit, kartu & pemilih) |
| `test/core/storage`, `test/features/{chat,feed,offline}` (offline) | Store drift in-memory & memori (kontrak sama), rekonsiliasi & pemangkasan, database per user, hapus saat logout/ganti user/hapus akun, buka offline lewat identitas OLT, outbox (tertunda → terkirim/gagal, backoff, urutan, dedupe), cubit cache → server, widget pesan tertunda/gagal & banner offline |
| `test/tool` | Pemeriksa komentar dan pemeriksa `print` untuk CI, kelengkapan `merge`/`copyWith`/`lerp` (setiap field ikut digabung) |
| `test/features/customization`, `test/features/chat/presentation/chat_builders_merge_test.dart` (1.4.0) | Builder feed/kartu post/polling/sematan/notifikasi/profil/badge, scope bersarang, regresi `stockCard` hilang saat `merge` |
| `test/core/storage/image_cache_test.dart`, `test/features/offline/image_cache_lifecycle_test.dart`, `test/features/media` (1.4.0) | Kunci cache stabil, LRU byte, kedaluwarsa, folder per user, hapus saat logout/hapus akun/`clearLocalCache`/ganti user, lampiran CS tidak disimpan, ukuran dekode, daftar panjang lazy |
| `test/support` | Fake dependensi & mock data source bersama |
| `example/integration_test` | E2E app di Windows: login → feed → thread → komentar (Enter) → chat (Enter) → notifikasi |

### Mode auth-bridge per tes backend

Mode auth-bridge menentukan token yang diterima: `mock` menerima `mock:<id>:<username>`, `jwt` hanya menerima token sosial bertanda tangan dari OLT dummy. Cek dengan `GET /bridge/v1/health` (header `apikey`), field `olt_mode`. Anon key ada di `docker/secrets/anon_key` repo backend dan diteruskan lewat `OLT_SOCIAL_ANON_KEY`.

| Tes | Mode | Cara menjalankan |
|---|---|---|
| `test/integration/backend_integration_test.dart` | `mock` | `OLT_SOCIAL_IT=1 OLT_SOCIAL_ANON_KEY=<anon> flutter test test/integration` |
| `test/integration/dummy_olt_integration_test.dart` | `jwt` + OLT dummy | `OLT_SOCIAL_IT_DUMMY=1 OLT_SOCIAL_ANON_KEY=<anon> flutter test test/integration` |
| `example/integration_test/app_test.dart`, `support_test.dart` | `jwt` + OLT dummy | dari `example/`: `flutter test integration_test/<file> -d windows --dart-define=OLT_SOCIAL_ANON_KEY=<anon>` |
| `example/integration_test/dummy_olt_login_test.dart` | `jwt` + OLT dummy | seperti di atas, tambah `--dart-define=OLT_DUMMY_E2E=true` |

Dari repo backend, mode `mock`: `docker compose -f docker/compose.yml -f docker/compose.dev.yml --profile cs up -d --no-deps auth-bridge`. Kembali ke `jwt`: tambahkan `-f docker/compose.dummy-olt.yml` ke perintah yang sama. Di Git Bash, awali dengan `MSYS_NO_PATHCONV=1`. Tutup dulu app example Windows yang sedang berjalan dari clone ini sebelum menjalankan E2E, karena app itu mengunci folder `build`.

Tes ini tidak bergantung pada sisa data dev:

- Tes integrasi yang membuat postingan memakai akun baru per tes (`withFreshAuthor`, token `mock:it<waktu>:it_<tag>_<angka>`), lalu menghapusnya lewat `deleteMyAccount`. Batas 50 post/24 jam juga menghitung postingan yang sudah dihapus, jadi akun seed seperti `budi_santoso` tidak dipakai untuk membuat postingan.
- `support_test` membuat tiket baru bila tiket terakhir `rina_saham` sudah selesai atau ditutup (menu **Buat tiket baru** → pilih topik), memakai tiket aktif bila ada, dan mengakhiri tiket yang dibuatnya sendiri di akhir tes.
- `dummy_olt_login_test` menggulir daftar login sampai form OLT dummy terlihat sebelum mengisi dan menekan tombol.

### Tes performa scroll (1.4.0)

Tes di `example/integration_test/perf_scroll_test.dart` memakai repository palsu (tanpa backend): 200 post (gambar 1600×1200, link preview, polling, sentimen) dan 500 pesan grup (gambar, kartu saham, reaksi, pembatas hari). Feed dan chat di-scroll dari atas sampai item terakhir lalu kembali, dengan `traceAction`; driver (`example/test_driver/perf_driver.dart`) menghitung rata-rata/p90/p99/terburuk waktu build dan raster, frame yang melewati budget, serta RSS proses, lalu menulis `example/build/perf_scroll_report.json` dan timeline `example/build/{feed,chat}_scroll.timeline*.json`.

```bash
make perf-flutter                       # atau: .\make.ps1 perf-flutter  (Windows desktop, mode profile)
cd example && flutter drive --profile -d windows \
  --driver=test_driver/perf_driver.dart --target=integration_test/perf_scroll_test.dart
# Android nyata (USB debugging aktif; lihat id dengan `flutter devices`):
make perf-flutter PERF_DEVICE=<device-id>   # PowerShell: $env:PERF_DEVICE='<device-id>'; .\make.ps1 perf-flutter
cd example && flutter drive --profile -d <device-id> \
  --driver=test_driver/perf_driver.dart --target=integration_test/perf_scroll_test.dart
```

Budget (gagal bila terlewati): p90 build < 8 ms, p90 raster < 16 ms, tidak ada frame > 32 ms kecuali frame pertama. Ubah lewat env `PERF_P90_BUILD_MS`, `PERF_P90_RASTER_MS`, `PERF_MAX_FRAME_MS` (mis. untuk perangkat Android kelas bawah). Jangan memakai mode debug untuk angka performa. Di Android, angka memori dari `ProcessInfo` berupa RSS proses aplikasi; untuk detail heap pakai DevTools.

Penjaga murah di CI (`flutter test`): `test/features/media/network_image_test.dart` memastikan feed 200 post dan room 500 pesan hanya membangun item yang terlihat, dan gambar meminta dekode seukuran tampilan dengan kunci cache stabil.

