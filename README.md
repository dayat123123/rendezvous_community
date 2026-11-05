<div align="center">

# rendezvous_community

**Fitur komunitas & chat untuk aplikasi Rendezvous Online Trading**

Feed saham · komentar berantai · chat realtime · chat CS · notifikasi · moderasi

![Versi](https://img.shields.io/badge/versi-1.7.0-0f766e)
![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A5%203.44-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%E2%89%A5%203.12-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Android-555)
![Lisensi](https://img.shields.io/badge/lisensi-proprietary-lightgrey)

</div>

---

`rendezvous_community` adalah package Flutter siap pakai yang menambahkan fitur sosial ke aplikasi OLT. Widget-nya tanpa `Scaffold`, mengikuti `ThemeData` aplikasi host, dan bisa diganti tampilannya per bagian tanpa menulis ulang logikanya.

> **Batas tanggung jawab.** Package ini tidak pernah memanggil sistem OLT dan tidak menyimpan data bisnis. Order, daftar dan harga saham, portofolio, dan data nasabah tetap milik aplikasi OLT. Package hanya menerima **token sosial** bertanda tangan dari OLT dan **kode saham** sebagai label.

## Daftar isi

- [Fitur](#fitur)
- [Persyaratan](#persyaratan)
- [Instalasi](#instalasi)
- [Mulai cepat](#mulai-cepat)
- [Menempatkan widget](#menempatkan-widget)
- [Kustomisasi tampilan](#kustomisasi-tampilan)
- [Hal penting untuk host](#hal-penting-untuk-host)
- [Dokumentasi](#dokumentasi)
- [Pengembangan](#pengembangan)

## Fitur

| | Fitur |
|---|---|
| 📰 **Feed** | Stream umum (Terbaru / Mengikuti), feed per saham, hashtag, trending, sentimen bullish/bearish, polling, bookmark, link preview, edit 15 menit, bagikan post ke chat |
| 💬 **Komentar** | Thread berantai dengan indentasi per level, "Lanjutkan thread", collapse per cabang, mention `@user` dan `$KODE` |
| 🗨️ **Chat** | DM, grup, dan room saham realtime; centang ala WhatsApp; balas, reaksi, kartu saham; indikator mengetik; lazy load per 30 pesan; isi celah otomatis setelah koneksi putus |
| 🎧 **Chat CS** | Room CS resmi disematkan paling atas, lampiran gambar + PDF, riwayat tiket, rating |
| 🔔 **Notifikasi** | Kotak notifikasi + badge, push komunitas dan push transaksi OLT, preferensi per jenis dan jam tenang |
| 🛡️ **Keamanan & moderasi** | Konten ditahan/disembunyikan dengan banding, permintaan DM dari orang asing, slow mode room saham, persetujuan dokumen hukum |
| 📴 **Offline** | Cache lokal per user (feed, daftar chat, pesan) dan outbox pesan teks yang dikirim ulang otomatis |
| 🎨 **Kustomisasi** | Tema dari `ThemeData`, `CommunityTheme`, dan builder untuk chat, kartu post, notifikasi, profil, badge |
| 🖥️ **Desktop** | Daftar chat multi-panel di layar lebar, Enter untuk kirim, aksi saat hover, navigasi keyboard di autocomplete |

Rincian perilaku setiap fitur ada di [doc/features.md](doc/features.md).

## Persyaratan

| Komponen | Versi |
|---|---|
| Flutter | ≥ 3.44 |
| Dart | ≥ 3.12 |
| `flutter_bloc` | 9.x (boleh sama dengan milik host; Bloc package tersimpan di subtree-nya sendiri) |
| `intl` | ^0.20.2 |
| Backend | Server sosial Rendezvous (Supabase self-hosted + auth-bridge + layanan `media`) |

**Kompatibilitas dengan server:**

| Package | Server minimal | Catatan |
|---|---|---|
| **1.6.x** | migrasi `0107` | Ringkasan mengetik di room besar, presence hanya DM, pratinjau room saham live. Di server lama otomatis kembali ke perilaku 1.5 |
| **1.5.x** | migrasi `0098` | Pesan realtime lewat Broadcast. **Wajib** untuk server dengan `0098`: klien 1.4.x tidak lagi menerima pesan realtime |
| 1.2 – 1.4 | — | Butuh layanan `media` untuk unggahan |

## Instalasi

Repo ini private, jadi pasang lewat dependency git. Komputer yang menjalankan `flutter pub get` harus punya akses baca ke repo.

```yaml
# pubspec.yaml aplikasi OLT
dependencies:
  flutter_localizations:
    sdk: flutter
  rendezvous_community:
    git:
      url: https://github.com/dayat123123/rendezvous_community.git
      ref: v1.7.0          # selalu pin ke tag rilis
```

- **Laptop developer:** login GitHub sekali lewat Git Credential Manager (ikut terpasang bersama Git for Windows).
- **CI / build server:** pakai URL SSH `git@github.com:dayat123123/rendezvous_community.git` dengan *deploy key* read-only yang disimpan sebagai secret CI.
- **Jangan** menaruh token GitHub di URL `pubspec.yaml`, karena akan ikut ter-commit.

Panduan lengkap memasang library ke aplikasi OLT (konfigurasi platform, versi minimum, push, chat CS, error, test di proyek host) ada di [doc/integration.md](doc/integration.md).

## Mulai cepat

### 1. Inisialisasi setelah login OLT

```dart
import 'package:rendezvous_community/rendezvous_community.dart';

Future<void> onOltLoggedIn() async {
  await RendezvousCommunity.initialize(
    supabaseUrl: Env.socialApiUrl,                         // https://social-api.domain.com
    anonKey: Env.socialAnonKey,                            // anon key, aman di aplikasi
    tokenProvider: () => oltSession.freshSocialToken(),    // token sosial yang masih berlaku; null bila logout
    onStockTap: (context, code) => oltRouter.openStock(context, code),
    stockSearch: (query) => oltStocks.search(query),       // saran $KODE dari daftar saham OLT
    appVersion: packageInfo.version,                       // wajib agar versi minimum bisa dipaksa dari web
    onUpdateRequired: (config) => oltRouter.showForceUpdate(),
  );
}

Future<void> onOltLoggedOut() => RendezvousCommunity.instance.signOut();
```

`tokenProvider` harus mengembalikan **token sosial** (JWT EdDSA/ES256 berumur ≤ 15 menit yang diterbitkan backend OLT), bukan token sesi OLT. Package menukarnya ke auth-bridge dan memperbaruinya sendiri sebelum kedaluwarsa, termasuk untuk koneksi realtime.

### 2. Lokalisasi

```dart
MaterialApp(
  localizationsDelegates: const [
    CommunityLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('id'), Locale('en')],
  theme: oltTheme,
  darkTheme: oltDarkTheme,
);
```

Bahasa bawaan Indonesia, tersedia juga Inggris. Warna, termasuk dark mode, diturunkan dari `ThemeData` host.

## Menempatkan widget

Semua widget berupa konten tanpa `Scaffold`, jadi AppBar, navigasi, dan layout tetap milik OLT.

| Lokasi di OLT | Widget |
|---|---|
| Menu "Stream" | `const CommunityStreamFeed()` |
| Tab "Diskusi" di halaman saham | `CommunityStockFeed(stockCode: code, showHeader: false)` |
| Tombol tulis post | `showCommunityComposer(context, initialStock: code)` |
| Menu "Chat" | `const CommunityChatList()` (multi-panel di layar ≥ 840 px) |
| Ikon tab "Chat" | `CommunityChatBadge(child: Icon(Icons.chat_bubble_outline))` |
| Ikon lonceng | `CommunityNotificationBadge(child: ...)` → `const CommunityNotificationList()` |
| Bantuan / Chat CS | Windows: `CommunitySupportChat(onClose: ...)` sebagai panel samping ±420 px. Android: `openCommunitySupport(context)` |
| Ikon "Bantuan" | `CommunitySupportBadge(child: Icon(Icons.support_agent_outlined))` |
| Pengaturan → Privasi & akun komunitas | `openCommunityAccountSettings(context, onAccountDeleted: ...)` |
| Profil sosial / deep link post | `CommunityUserProfile(userId: id)` / `CommunityPostDetail(postId: id)` |
| Pencarian, trending, bookmark | `CommunitySearch()`, `CommunityTrending()`, `CommunityBookmarks()` |

```dart
TabBarView(children: [
  StockChartTab(code: code),                               // milik OLT
  OrderBookTab(code: code),                                // milik OLT
  CommunityStockFeed(stockCode: code, showHeader: false),  // diskusi saham
]);
```

## Kustomisasi tampilan

Ganti bagian mana saja, misalnya gelembung chat, kartu post, atau bentuk badge, cukup dengan satu scope di `MaterialApp.builder`. Logika (lazy load, kirim ulang, tanda terima, mengetik) tetap diurus package, dan bagian yang tidak diisi memakai tampilan bawaan.

```dart
MaterialApp(
  builder: (context, child) => CommunityBuildersScope(
    builders: const CommunityBuilders(
      chat: CommunityChatBuilders(message: oltBubble),
      feed: CommunityFeedBuilders(actionBar: oltPostActions),
      badges: CommunityBadgeBuilders(label: oltPillBadge),
    ),
    child: child!,
  ),
);
```

Setiap builder menerima `details` (data siap tampil + handler yang sudah tersambung) dan `fallback` (tampilan bawaan). Daftar lengkap builder, tema `CommunityTheme`, dan cache gambar ada di [doc/customization.md](doc/customization.md).

## Hal penting untuk host

- **Data saham milik OLT.** `stockSearch` memberi saran `$KODE`, `stockInfo` mengisi nama/harga di kartu saham, `stockName` mengisi header feed saham. Server hanya menyimpan kode sebagai label.
- **Push.** Daftarkan token FCM dengan `registerPushToken(token, platform: CommunityPushPlatform.android)`. Push transaksi (`olt.*`) dibuka layar OLT sendiri lewat `isOltPush(data)` / `onOltNotificationTap`; push komunitas lewat `openCommunityPush(context, data)`. [Detail](doc/features.md#push-transaksi-olt)
- **Offline & privasi.** Cache lokal satu database per user dan dihapus saat `signOut()`, `deleteMyAccount()`, `clearLocalCache()`, atau ganti user. Chat CS tidak pernah di-cache. [Detail](doc/features.md#offline-cache--outbox-130)
- **Kill switch & versi minimum.** Server bisa mematikan fitur sosial atau memaksa update. Widget lalu menampilkan placeholder, sedangkan chat CS tetap jalan. [Detail](doc/features.md#konfigurasi-klien--kill-switch-130)
- **Dokumen hukum.** Post/komentar/pesan sebelum menyetujui S&K memunculkan dialog persetujuan, lalu aksinya diulang otomatis. [Detail](doc/features.md#dokumen-hukum--persetujuan)
- **Exhaustive `switch` atas event chat** perlu cabang `TypingSummaryChanged` sejak 1.6.0 (lihat [CHANGELOG](CHANGELOG.md)).
- **Log.** Library tidak mencetak ke konsol; teruskan ke logger OLT lewat `initialize(logHandler: ...)`. Data sensitif disamarkan. [Detail](doc/logging.md)

## Dokumentasi

| Dokumen | Isi |
|---|---|
| [doc/integration.md](doc/integration.md) | Langkah lengkap memasang library ke aplikasi OLT |
| [doc/features.md](doc/features.md) | Perilaku fitur: chat, feed, dokumen hukum, privasi & akun, unggahan, kill switch, DM, analitik, offline, push |
| [doc/customization.md](doc/customization.md) | Tema, builder chat/feed/notifikasi/profil/badge/komponen bersama, cache gambar |
| [doc/design.md](doc/design.md) | Token desain (`CommunityStyle`), komponen dasar, aturan spasi/warna/mode gelap/aksesibilitas, harness screenshot |
| [doc/builders.md](doc/builders.md) | Inventaris semua widget visual dan builder-nya |
| [doc/architecture.md](doc/architecture.md) | Struktur folder, aturan dependensi, alur auth, realtime, centang, error |
| [doc/logging.md](doc/logging.md) | Logger, level, format, penyamaran data sensitif |
| [doc/migration-1.0.md](doc/migration-1.0.md) | Pindah dari `olt_social` 0.3.0 |
| [doc/development.md](doc/development.md) | Perintah pengembangan, daftar tes, tes performa scroll |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat rilis |
| [example/](example/) | Aplikasi contoh (Windows, Android, web) dengan login dummy dan gaya kustom |

## Pengembangan

```bash
flutter pub get
flutter analyze
flutter test
dart run tool/check_comments.dart     # kode Dart tanpa komentar
dart run tool/check_logging.dart      # tanpa print/debugPrint
dart run tool/license_audit.dart      # hanya lisensi permisif
```

Aturan kode, tes integrasi ke backend, dan tes performa ada di [doc/development.md](doc/development.md).

## Lisensi

Proprietary, lihat [LICENSE](LICENSE). Semua dependensi runtime berlisensi permisif (MIT, BSD, Apache-2.0), diverifikasi `tool/license_audit.dart`.
