[← Kembali ke README](../README.md)

# Integrasi `rendezvous_community` ke Aplikasi OLT

Langkah memasang fitur sosial ke proyek Flutter OLT yang sudah ada (Windows + Android). Package memakai **flutter_bloc 9**, `supabase_flutter` 2.x, dan Material 3, serta mengikuti `ThemeData` aplikasi.

**Batas integrasi:** server sosial hanya memverifikasi *token sosial* yang ditandatangani OLT, secara lokal tanpa memanggil OLT. Order, daftar dan nama saham, harga, portofolio, dan data nasabah tetap di app OLT; package hanya menerima perintah dan kode saham sebagai label. Rinciannya di [olt-integration.md](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/olt-integration.md).

## 1. Tambahkan dependency

```yaml
# pubspec.yaml aplikasi OLT
dependencies:
  rendezvous_community:
    git:
      url: https://github.com/dayat123123/rendezvous_community.git
      ref: v1.25.2            # pin tag rilis; server dengan migrasi 0098 butuh >= 1.5.0
  flutter_localizations:
    sdk: flutter
```

Repo ini private dan setiap rilis diberi tag (`v1.5.0`, `v1.6.0`, ...); selalu pin `ref` ke tag rilis. Komputer yang menjalankan `flutter pub get` butuh akses baca: login lewat Git Credential Manager di laptop, atau URL SSH + deploy key read-only di CI. Jangan menaruh token GitHub di URL `pubspec.yaml`.

Untuk pengembangan lokal bisa memakai `path: ../rendezvous_community` (clone repo library di sebelah repo backend).

> Package ini sebelumnya bernama `olt_social` (sampai 0.3.0). Bila app OLT masih memakai nama lama, ikuti [panduan migrasi 1.0](migration-1.0.md).

Kompatibilitas:
- **Flutter:** ≥ 3.44, Dart ≥ 3.12.
- **flutter_bloc:** OLT boleh memakai `flutter_bloc` 9.x yang sama. Bloc milik package tersimpan di subtree widget-nya sendiri dan tidak bentrok dengan Bloc OLT.

### Kompatibilitas server dan versi minimum

> **Perubahan yang memutus (breaking): server dengan migrasi `0098` butuh `rendezvous_community` ≥ 1.5.0.**
> Sejak `0098_realtime_broadcast_delivery`, pesan chat dikirim lewat Broadcast dari server ke topik privat `room:<id>` dan `user:<id>`; tabel `messages` keluar dari `postgres_changes`. Klien 1.4.x tetap login dan tersambung, tetapi **tidak menerima pesan baru secara realtime** (hanya terlihat saat room dimuat ulang) dan typing-nya tidak sampai. Tidak ada perubahan API publik di 1.5.0, jadi host cukup menaikkan versi (`ref: v1.5.0`).

Langkah rilis (rinciannya di [PRODUCTION.md](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/PRODUCTION.md#4-update-versi)):

1. OLT merilis app dengan `rendezvous_community` 1.5.0 untuk semua platform, dan app mengisi `appVersion` + `platform` + `onUpdateRequired` saat `initialize(...)` (bagian 3, [Konfigurasi klien](#konfigurasi-klien-130)).
2. Backend dengan `0098` di-deploy.
3. Super Admin atau staf berperan Fitur & Kampanye membuka Rendezvous Hub **Fitur & Kampanye → Fitur & versi → Versi minimum aplikasi** dan mengisi versi app OLT pertama yang membawa 1.5.0 untuk tiap platform (`android`, `windows`, dan seterusnya). Perubahan tercatat di jejak audit. `get_client_config` lalu menjawab `update_required: true` untuk app yang lebih lama, dan `onUpdateRequired` mengarahkan nasabah ke update OLT.

Yang dibandingkan adalah versi **app OLT** (`appVersion`), bukan versi package. App lama yang tidak mengisi `appVersion` tidak bisa dipaksa update lewat mekanisme ini; pastikan semua build yang beredar sudah mengirimnya.

## 2. Konfigurasi platform

**Android:**
- `android/app/src/main/AndroidManifest.xml` wajib berisi:

  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```

- Produksi memakai HTTPS. Bila staging masih HTTP, izinkan cleartext **hanya** di `src/debug/AndroidManifest.xml`. Contohnya ada di [`example/android`](../example/android).
- Pemilihan gambar, dokumen, dan video memakai `file_selector`, yang membuka pemilih dokumen sistem; **tidak perlu izin storage atau `READ_MEDIA_*`**.
- Video chat CS diputar dengan `video_player` (ExoPlayer) dari signed URL HTTPS; cukup izin `INTERNET`. Dokumen dibuka dengan meneruskan signed URL ke aplikasi atau browser sistem lewat `url_launcher`, jadi tidak perlu `FileProvider` (tidak ada `file://` yang dibagikan ke aplikasi lain).
- Bila memakai notifikasi lokal untuk balasan CS (`flutter_local_notifications`):
  - tambahkan izin `android.permission.POST_NOTIFICATIONS` (Android 13+);
  - aktifkan core library desugaring di `android/app/build.gradle.kts`: `isCoreLibraryDesugaringEnabled = true` dan `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.

**iOS:** tidak ada kunci `Info.plist` baru. `file_selector` memakai pemilih dokumen sistem (Files), `video_player` (AVPlayer) memutar signed URL HTTPS. Bila server staging masih HTTP, izinkan lewat `NSAppTransportSecurity` hanya di build debug. Foto HEIC dari Files diubah ke JPEG di perangkat bila dekoder sistem tersedia; bila tidak, nasabah diminta menyimpan foto sebagai JPEG.

**macOS:** aktifkan `com.apple.security.network.client` (sudah wajib untuk Supabase) dan `com.apple.security.files.user-selected.read-only` untuk pemilih file. Video diputar di aplikasi (`video_player`); dokumen diunduh ke folder sementara lalu dibuka aplikasi bawaan.

**Windows:** tidak ada konfigurasi tambahan. `video_player` belum mendukung Windows, jadi video chat CS diunduh ke folder sementara lalu dibuka di pemutar bawaan Windows; dokumen juga diunduh lalu dibuka aplikasi bawaan (Word, Excel, dan sebagainya). Paket berat seperti `media_kit` sengaja tidak dipakai.

**Web:** video diputar dengan elemen `<video>` browser (`video_player_web`); MOV hanya jalan di browser yang mendukungnya (Safari). Dokumen dibuka di tab baru.

## 3. Inisialisasi setelah login OLT

Panggil `RendezvousCommunity.initialize` **setelah** user berhasil login ke OLT, dengan cara apa pun: username/email + password atau token. Package tidak pernah melihat password; ia hanya meminta **token sosial** lewat `tokenProvider`.

Token sosial adalah JWT berumur pendek (≤ 15 menit) yang diterbitkan backend OLT saat login dan saat app memintanya lagi. Formatnya ada di [olt-integration.md](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/olt-integration.md#3-format-token-sosial). `tokenProvider` harus mengembalikan token sosial yang **masih berlaku**: bila hampir kedaluwarsa, minta yang baru ke OLT dulu. Jangan mengembalikan token sesi OLT, karena token itu ditolak.

```dart
import 'package:rendezvous_community/rendezvous_community.dart';

Future<void> onOltLoggedIn() async {
  await RendezvousCommunity.initialize(
    supabaseUrl: Env.socialApiUrl,          // https://social-api.domain.com
    anonKey: Env.socialAnonKey,             // ANON_KEY (aman di aplikasi)
    // authBridgeUrl default: '<supabaseUrl>/bridge/v1'
    tokenProvider: () => oltSession.freshSocialToken(),   // token sosial yang masih berlaku; null bila sudah logout
    onStockTap: (context, code) => OltRouter.openStock(context, code),  // halaman saham OLT
    stockSearch: (query) => OltStockDirectory.search(query),             // saran $KODE dari daftar saham OLT
    onUserTap: null,      // null = pakai halaman profil bawaan rendezvous_community
    onPostTap: null,      // null = buka CommunityPostDetail
    onRoomTap: null,      // null = buka CommunityChatRoom; boleh async, daftar chat menunggu lalu refresh (1.25.1)
    onBannerLink: (context, uri, banner) => OltRouter.tryOpenDeepLink(context, uri), // opsional, true = ditangani OLT (bagian 5)
    chatStockCards: true, // false = sembunyikan tombol "Kirim kartu saham" di kolom chat (1.15.1)
    postDrafts: true,     // false = composer tidak menyimpan/memuat draf post (1.15.2)
    onOfficialContact: (context, user) => openCommunitySupport(context), // opsional, tombol "Hubungi CS" untuk akun resmi (1.16.0)
    logHandler: (record) => oltLog.write(record.level.name, record.loggerName, record.message),  // opsional
  );
}

Future<void> onOltLoggedOut() async {
  await RendezvousCommunity.instance.signOut();       // tutup sesi sosial & koneksi realtime
}
```

Yang terjadi di belakang layar:
- **Penerbitan JWT:** auth-bridge memeriksa tanda tangan token sosial dengan kunci publik OLT, lalu menukarnya menjadi JWT Supabase berumur 15 menit. Server sosial tidak menghubungi OLT.
- **Refresh otomatis:** JWT diperbarui sebelum kedaluwarsa, termasuk untuk koneksi realtime yang sedang berjalan. Saat refresh, `tokenProvider` dipanggil lagi.
- **Token sosial ditolak** (kedaluwarsa, salah tanda tangan, atau OLT berhenti menerbitkannya karena akun disuspend/logout): semua API melempar `CommunityException(kind: unauthenticated)`, dan UI menampilkan *"Sesi berakhir. Silakan login ulang di OLT."*. OLT sebaiknya mengarahkan user ke login ulang.
- **Log:** library tidak mencetak ke konsol. Tanpa `logHandler`, log hanya muncul di mode debug. Log berbahasa Inggris, field terstruktur, dan data sensitif disamarkan ([logging.md](logging.md)).
- **Memastikan sesi sejak awal:** `await RendezvousCommunity.instance.ensureSignedIn()` melempar error lebih awal, misalnya bila backend tidak terjangkau.

**Data saham dari OLT.** Server tidak menyimpan daftar saham:
- `stockSearch` mengembalikan `List<StockSuggestion>` (kode + nama) dari daftar saham milik OLT untuk saran saat nasabah mengetik `$`. Tanpa callback ini, `$KODE` tetap bisa diketik, hanya tanpa saran.
- Kode apa pun yang berformat `$KODE` (huruf di depan, 2–12 huruf/angka) diterima sebagai label untuk feed, pantau, dan room saham. Validasi kode yang benar-benar ada adalah tugas app OLT.
- Nama saham di header `CommunityStockFeed` datang dari parameter `stockName`. Harga dan grafik tetap di halaman saham OLT.

### Klaim `accounts` dan notifikasi transaksi

Server OLT menambahkan klaim `accounts` (cust id rekening **milik** login: LoginType 1 → `TAccountLinked`; sales/cabang/pusat → `[]`) ke token sosial. Aplikasi tidak perlu mengirim daftar rekening; cukup `registerPushToken(...)` seperti biasa. notifEngine lalu mengirim notifikasi per cust id ke `/integration/v1/notify/messages`. Push transaksi (`kind` berawalan `olt.`) tidak dibuka paket: `openCommunityPush` mengembalikan `false` (`isOltPush(data)`), jadi aplikasi OLT memakai `data.screen`/`data.custId` untuk membuka layarnya sendiri. Spesifikasi lengkap: [docs/integration](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/integration/README.md).

### Konfigurasi klien (1.3.0)

Isi `appVersion` dan `platform` saat `initialize(...)` (termasuk `windows`), plus `onUpdateRequired` untuk mengarahkan ke mekanisme update OLT. Saat kill switch aktif, widget sosial menampilkan placeholder (bisa diganti lewat `CommunityAvailabilityScope`), chat CS tetap jalan. Panggil `RendezvousCommunity.instance.trackOrderTap()` saat nasabah berpindah dari fitur komunitas ke layar order. Fitur 1.3.0 lengkap: [docs/rendezvous-community](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/rendezvous-community/README.md).

## 4. Lokalisasi & tema

```dart
MaterialApp(
  localizationsDelegates: const [
    CommunityLocalizations.delegate,
    AppLocalizations.delegate,                 // milik OLT
    GlobalMaterialLocalizations.delegate,      // package:flutter_localizations
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('id'), Locale('en')],
  theme: oltTheme,          // rendezvous_community mengikuti ColorScheme ini (terang & gelap)
  darkTheme: oltDarkTheme,
);
```

- **Lokalisasi:** tanpa delegate pun package tetap tampil dalam bahasa Indonesia.
- **Warna bullish/bearish dan indentasi thread:** sesuaikan lewat `CommunityTheme` (ThemeExtension). Lihat README package.
- **Tampilan versi OLT (1.4.0):** pasang satu `CommunityBuildersScope` di `MaterialApp.builder` lalu isi builder untuk bagian yang ingin diganti: `chat` (gelembung pesan, composer, header room, tile daftar chat, kartu saham, status kosong/error), `feed` (kartu post utuh atau per bagian: avatar, header, isi, lampiran, link preview, tag saham, tombol aksi, polling, penanda sematan, komentar, status kosong/loading/error), `notifications` (item, header, kosong/loading/error), `profile` (header, statistik, tombol ikuti), dan `badges` (bentuk semua badge sekaligus: resmi, CS resmi, bot, moderator, sentimen, terverifikasi, jumlah belum dibaca). Builder menerima data siap tampil, handler yang sudah tersambung, dan `fallback` (tampilan bawaan). Scope bersarang hanya menimpa bagian yang diisi. Tanpa builder tampilan tetap sama persis. Contoh lengkap ada di README package, bagian "Kustomisasi UI (builder)".

```dart
MaterialApp(
  builder: (context, child) => CommunityBuildersScope(
    builders: const CommunityBuilders(
      chat: oltChatBuilders,
      feed: CommunityFeedBuilders(actionBar: oltPostActions),
      badges: CommunityBadgeBuilders(label: oltPillBadge, count: oltCountBadge),
    ),
    child: child!,
  ),
);
```

- **Cache gambar (1.4.0):** gambar diunduh sekali, didekode seukuran tampilan, dan disimpan di disk per user (bawaan 200 MB, 30 hari). Atur lewat `RendezvousCommunity.initialize(imageCache: CommunityImageCacheConfig(maxBytes: ..., maxAge: ...))`; `CommunityImageCacheConfig.disabled()` mematikan cache disk. Cache ikut terhapus bersama cache offline saat `signOut()`, `deleteMyAccount()`, `clearLocalCache()`, dan ganti user. Lampiran chat CS tidak pernah disimpan ke disk.

## 5. Tempatkan widget

Semua widget adalah konten tanpa `Scaffold`, sehingga OLT tetap memegang AppBar, navigasi, dan layout halaman.

| Lokasi di OLT | Widget |
|---|---|
| Tab/menu "Stream" | `const CommunityStreamFeed()`. Komentar inline seperti Facebook/Instagram: `CommunityStreamFeed(postOpenMode: CommunityPostOpenMode.inlineComments)` (1.13.0). Tombol "kembali ke atas" milik OLT: berikan `ScrollController` sendiri lewat `CommunityStreamFeed(scrollController: controller)` (1.23.0, juga di `CommunityFeedList` dan `CommunityBookmarks`), lalu panggil `controller.animateTo(0, ...)` |
| Halaman detail saham (tab "Diskusi") | `CommunityStockFeed(stockCode: code, showHeader: false)` (header disembunyikan karena OLT sudah menampilkan info saham). Bila header dipakai, isi `stockName` dari data OLT |
| Tombol tulis post | `showCommunityComposer(context, initialStock: code)` atau `CommunityComposePost(...)`. Sejak 1.14.0 bisa langsung ke mode tertentu: `initialSentiment: Sentiment.bullish`, `initialAction: CommunityComposerAction.image` / `.poll` / `.cashtag`, dan `hintText` |
| Kartu "Apa pendapat Anda…" di atas feed buatan sendiri | `CommunityComposePromptCard(initialStock: code)` (1.14.0, dengan tombol Bullish/Bearish/Gambar/Polling/Saham) |
| Panel samping Stream | `CommunityMarketSentiment()` (mood pasar), `CommunitySuggestedUsers()` (akun untuk diikuti), `CommunityStockStatsBuilder(codes: watchlist, builder: ...)` ("14 post hari ini") (1.14.0) |
| Menu "Chat" | `const CommunityChatList()` (otomatis multi-panel di Windows) |
| Ikon menu/tab "Chat" | `CommunityChatBadge(child: Icon(Icons.chat_bubble_outline))` (jumlah chat yang punya pesan belum dibaca) |
| Ikon lonceng | `CommunityNotificationBadge(child: Icon(Icons.notifications))` → `CommunityNotificationList()` |
| Halaman profil sosial | `CommunityUserProfile(userId: id)` |
| Halaman room milik OLT (1.25.1) | Bila OLT membuka room sendiri lewat `onRoomTap`, buat callback-nya async dan selesai saat halaman room ditutup, lalu isi `CommunityChatRoom(onClosed: ...)` untuk menutup halaman itu. `onClosed` dipanggil saat pengguna keluar, menghapus chat, grupnya dihapus, atau ternyata bukan anggota lagi. Tanpa `onClosed`, room menampilkan pesan dan tombol kembali bila halaman tidak punya `AppBar`. `CommunityNavigator.pushRoom(context, roomId)` membuka halaman room bawaan yang menutup dirinya sendiri |
| Menu "Indeks" (1.24.0, server `0150`) | `CommunityIndexList()` (daftar indeks, ketuk membuka stream) dan `CommunityIndexFeed(indexCode: code)` (stream satu indeks bergaya `CommunityStockFeed`, header dengan label Indeks, alias, Pantau, dan Diskusi). Ketukan `$KODE` indeks memanggil `onIndexTap` (fallback `onStockTap`). Daftar indeks dikelola dari Hub, jadi `stockSearch` OLT tidak perlu memuat indeks. Data mentah: `CommunityInstruments.of(context)` (`instruments`, `isIndex`, `canonical`) |
| Tab filter Stream (1.24.0, server `0149`) | `CommunityFeedFilters.load(context)` → `List<FeedFilter>` untuk bar tab milik OLT, lalu `CommunityFeedList(scope: ..., filter: filter.key)` atau `CommunityStreamFeed(filter: key)`. Siap pakai: `CommunityStreamFeed(showFilterTabs: true)` atau `CommunityFeedFilterTabs(selected: key, onSelected: ...)`. Label: `filter.label(Localizations.localeOf(context))` |
| Daftar pengikut / yang diikuti (1.21.0, server `0148`) | `CommunityFollowList(userId: id, initialKind: FollowListKind.following)` (`kinds: [FollowListKind.followers]` untuk hanya daftar pengikut tanpa tab, 1.22.0) atau `CommunityNavigator.openFollowList(context, user, kind)`; data mentah lewat `(profiles as FollowListRepository).followList(id, kind, cursor: ...)` → `Paged<FollowListEntry>`. Angka Pengikut/Mengikuti di profil membukanya otomatis |
| Deep link post | `CommunityPostDetail(postId: id)` |
| Menu "Bantuan / Chat CS" | Windows: `CommunitySupportChat(onClose: ...)` sebagai panel samping (lebar ±420). Android: `openCommunitySupport(context)` (layar penuh dengan tombol kembali) |
| Ikon menu "Bantuan" | `CommunitySupportBadge(child: Icon(Icons.support_agent_outlined))` (balasan CS yang belum dibaca) |
| Tombol bantuan di layar order / dana / portofolio | `openCommunitySupport(context, topic: 'orders', screen: 'order_detail')` atau `CommunitySupportChat(topic: ..., screen: ...)` di panel samping. Topik dan asal layar ikut tercatat di tiket; detail order tidak dikirim ke server |
| Riwayat tiket | `CommunitySupportTickets()` (juga ada di menu "⋯" room CS) |
| Halaman login OLT ("Tidak bisa masuk? Hubungi CS") | `openCommunityGuestSupport(context)` atau `CommunityGuestSupport()`: pengaduan tamu tanpa login, lihat [Pengaduan tamu dari halaman login](#pengaduan-tamu-dari-halaman-login) |
| Menu "Pengaturan → Privasi & akun komunitas" | `openCommunityAccountSettings(context, onAccountDeleted: ...)` atau `CommunityAccountSettings(...)`: baca S&K/Pedoman/Kebijakan Privasi, unduh data saya, hapus akun komunitas (akun trading tidak terpengaruh) |

Contoh tab Diskusi di halaman saham OLT:

```dart
TabBarView(children: [
  StockChartTab(code: code),          // milik OLT
  OrderBookTab(code: code),           // milik OLT
  CommunityStockFeed(stockCode: code, showHeader: false),
]);
```

**Komentar inline (1.13.0).** Bawaannya mengetuk post atau tombol komentar membuka halaman `CommunityPostDetail`. Agar komentar terbuka di bawah kartu tanpa pindah halaman, isi `postOpenMode` di widget feed yang dipakai:

```dart
CommunityStreamFeed(postOpenMode: CommunityPostOpenMode.inlineComments);
CommunityStockFeed(stockCode: code, showHeader: false, postOpenMode: CommunityPostOpenMode.inlineComments);
CommunityUserProfile(userId: id, postOpenMode: CommunityPostOpenMode.inlineComments);
```

Deep link post dan notifikasi tetap membuka `CommunityPostDetail`. Pilihan urutan "Disarankan/Terbaru" butuh server migrasi `0142`; di server lama komentar inline tetap jalan dengan urutan dari yang terlama. Rinciannya di [customization.md](customization.md#komentar-inline-1130).

**Halaman Stream lengkap (1.14.0, server migrasi `0143`).** OLT bisa menyusun halaman Stream sendiri dari bagian-bagian berikut. Contoh tiga kolomnya ada di `example/lib/stream_page.dart`.

| Bagian | API |
|---|---|
| Sumber feed | `FeedScope.forYou()` (rekomendasi; di server tanpa peringkat kembali ke Terbaru), `FeedScope.global()`, `FeedScope.following()`, `FeedScope.official()` (akun resmi/riset), `FeedScope.stocks(watchlistCodes)` (gabungan watchlist, maks 50 kode), `FeedScope.stock(code)` |
| Tab "Terbaru / Teratas / Grafik & media" | `CommunityFeedList(scope: ..., sort: CommunityFeedSort.latest` atau `.top, mediaOnly: true)`. Teratas = suka + 2 × komentar dalam 30 hari terakhir (profil: sepanjang waktu). Post yang disematkan dan pil "N post baru" hanya muncul di urutan Terbaru tanpa filter |
| Kartu composer | `CommunityComposePromptCard()`; bila dipasang sebagai `header` `CommunityFeedList`, post baru langsung masuk ke feed |
| Mood pasar | `CommunityMarketSentiment()` atau `insights.marketSentiment(window: TrendWindow.day)` → `SentimentBreakdown` (`posts`, `bullishPct`, `bearishPct`, `neutralPct`) |
| Akun untuk diikuti | `CommunitySuggestedUsers(limit: 5)` atau `profiles.suggestedUsers(limit: 5)` → `SuggestedUser` (`user`, `mutualCount`, `followerCount`, `isOfficial`) |
| Label watchlist "14 post hari ini" | `CommunityStockStatsBuilder(codes: [...], builder: (context, stats) => ...)` (memuat ulang tiap 5 menit) atau `insights.stockStats(codes)` → `Map<String, StockStats>` (`postsToday` sejak 00.00 WIB, `bullishPct` hari ini). Teks siap pakai: `l10n.postsToday(n)`, `l10n.bullishShare(pct)` |
| Pratinjau komentar di kartu | otomatis dari `Post.topComment`; ganti tampilannya lewat builder `topComment` |

```dart
CommunityFeedList(
  scope: FeedScope.stocks(watchlist),
  sort: CommunityFeedSort.top,
  emptyMessage: context.communityL10n.feedWatchlistEmpty,
  postOpenMode: CommunityPostOpenMode.inlineComments,
  header: const CommunityComposePromptCard(),
);
```

Di server tanpa `0143`: `FeedScope.forYou()` tampil seperti Terbaru, urutan Teratas diabaikan, dan "Grafik & media" disaring di aplikasi; `FeedScope.stocks` dan `FeedScope.official` menampilkan pesan error. `CommunityMarketSentiment` dan `CommunitySuggestedUsers` tidak tampil bila repository buatan OLT tidak mengimplementasikan `TrendingInsightsRepository` / `SuggestedUsersRepository`.

**Scroll di desktop (1.15.0).** Agar daftar bisa digeser dengan mouse dan tarik-untuk-muat-ulang (beserta indikatornya) dimatikan di Windows, isi `scroll` saat `initialize(...)`:

```dart
scroll: CommunityScrollSettings(
  behavior: const CommunityMouseDragScrollBehavior(),
  pullToRefresh: defaultTargetPlatform == TargetPlatform.android,
),
```

Untuk sebagian layar saja pakai `CommunityScrollScope`. Rinciannya di [customization.md](customization.md#scroll--tarik-untuk-muat-ulang-1150).

**Persetujuan dokumen hukum.** Dokumen diterbitkan staf Kepatuhan dari web CS. Paket menanganinya sendiri:
- Feed menampilkan `CommunityConsentBanner` bila ada dokumen wajib yang belum disetujui.
- Membuat postingan, komentar, atau pesan sebelum menyetujui memunculkan `showCommunityConsent`, lalu aksinya diulang otomatis. Chat CS tidak butuh persetujuan.
- OLT juga bisa memanggil `showCommunityConsent(context)` sendiri, misalnya saat pertama membuka menu komunitas.

**Upload foto dan PDF** dikirim paket ke `/media/v1` (layanan `media` di server memeriksa isi file dan membuang EXIF/GPS). Server lama tanpa layanan ini menolak upload ("upload belum tersedia").

**Akun resmi tidak menerima DM (1.16.0, server migrasi `0144`).** Server menolak DM dari user biasa ke akun resmi dengan kode `official_no_dm`; akun yang hanya terverifikasi tetap bisa di-DM. Library mengikutinya:
- Profil akun resmi tidak punya tombol "Kirim pesan". Bila `onOfficialContact` diisi, tombolnya menjadi "Hubungi CS" yang memanggil callback itu (misalnya membuka `openCommunitySupport`); bila tidak, tombol pesan disembunyikan.
- Room DM lama dengan akun resmi tetap menampilkan riwayat, tetapi kolom ketik diganti pemberitahuan "Akun resmi tidak menerima pesan. Hubungi CS untuk bantuan." dengan tombol "Hubungi CS" bila callback diisi. Akun resmi itu sendiri tetap bisa mengetik.
- Dialog "Grup baru" tidak menampilkan akun resmi, dan "Kirim ke chat" tidak menawarkan DM dengan akun resmi.
- Status resmi dibaca dari `is_official` di data profil server; untuk data yang belum membawanya (server lama, daftar room) dipakai daftar akun resmi (`OfficialAccounts`). Di server tanpa `0144`, DM ke akun resmi tetap dikirim seperti sebelumnya tetapi tombol di aplikasi sudah tersembunyi.

**Kelola grup ala WhatsApp (1.17.0, server migrasi `0146`).** Mengetuk header room grup membuka halaman **Info grup** (`CommunityGroupInfo(roomId: ...)`, juga lewat `CommunityNavigator.openGroupInfo(context, roomId)`). Pembuat grup adalah pemilik (owner):
- Owner dan admin bisa menambah anggota, menjadikan anggota admin, dan mengeluarkan anggota biasa. Hanya owner yang bisa mencabut status admin, mengeluarkan admin, dan memindahkan kepemilikan (owner lama menjadi admin). Owner yang keluar digantikan admin paling lama, atau anggota paling lama bila tidak ada admin.
- Info grup: nama, deskripsi (maks. 500 karakter), dan foto grup (JPG/PNG/WebP, diunggah ke folder avatar milik pengunggah). Bawaannya hanya admin yang bisa mengubahnya; admin bisa mengizinkan semua anggota.
- Pengaturan admin: "Hanya admin yang bisa mengirim pesan" (kolom ketik anggota biasa diganti pemberitahuan, server menolak dengan `group_admins_only`) dan "Hanya admin yang bisa mengubah info grup" (`group_admins_only_edit`).
- Setiap perubahan muncul di chat sebagai pesan sistem di tengah ("Alice menjadikan Bob admin", "Anda dikeluarkan" tampil sebagai "Alice mengeluarkan Anda") dalam bahasa aplikasi, tanpa push notification. Room dan anggota dimuat ulang otomatis; anggota yang dikeluarkan melihat "Anda bukan lagi anggota grup ini." menggantikan kolom ketik.
- Untuk UI sendiri: `RendezvousCommunity.instance.groups` (`GroupRepository`: `addMembers`, `removeMember`, `setMemberRole`, `transferOwnership`, `updateInfo`, `uploadPhoto`, `removePhoto`, `updateSettings`), `ChatRoom.description`/`avatarUrl`/`onlyAdminsSend`/`onlyAdminsEdit`/`canSend`/`canEditGroupInfo`, serta `GroupEvent.fromMessage(message)` dan `groupEventText(l10n, message, meId: ...)` untuk pesan `MessageKind.groupEvent`.
- Server tanpa `0146` tidak mengenal RPC ini; halaman Info grup tetap terbuka, tetapi aksinya gagal dengan pesan error umum.

**Draf post (1.15.2).** Bawaannya composer menyimpan draf otomatis ke perangkat dan server. Dengan `initialize(postDrafts: false)` composer tidak membuat, menyimpan, menyinkronkan, atau memuat draf (tanpa label "Draf tersimpan" dan tanpa panggilan RPC draf), dan `CommunityPostDrafts` tampil kosong. Draf lama tidak dihapus otomatis; hapus semua draf milik user (perangkat dan server) dengan `await RendezvousCommunity.instance.clearPostDrafts()`.

**Gambar post (1.15.2).** Mengetuk gambar di kartu post membuka penampil layar penuh (`showCommunityImageViewer`, juga diekspor untuk UI host).

Navigasi dari dalam widget sosial memakai callback dari langkah 3. Contohnya, mengetuk `$TLKM` di sebuah post memanggil `onStockTap(context, 'TLKM')`, sehingga OLT bisa membuka halaman sahamnya sendiri.

### Banner & popup promo (1.7.0)

Banner yang diterbitkan staf dari Hub datang lewat `get_client_config`. Banner strip tampil di `CommunityBannerHost` (feed sudah memasangnya sendiri); banner `display: "popup"` tampil sebagai kartu di tengah layar bila OLT memasang `CommunityPromoPopupHost` **sekali** di halaman utama, di bawah `Navigator`:

```dart
MaterialApp(
  // ...
  home: CommunityPromoPopupHost(
    enabled: !oltSession.mustChangePassword,   // false: tunda popup selama layar wajib OLT tampil
    child: const OltHomePage(),
  ),
);
```

Popup tampil maksimal sekali per sesi aplikasi setelah konfigurasi termuat dan user komunitas masuk, menunggu bila ada dialog/route lain di atas halaman itu, dan tidak tampil saat `update_required`. Aturan frekuensi (`once`/`daily`/`every_open`) dan tabel perilaku tombol ada di [features.md](features.md#popup-promo-170).

**Tautan promo ke halaman OLT.** `link_url` boleh `https://…` atau deep link aplikasi (mis. `olt://promo/akhir-tahun`). Pasang `onBannerLink` sekali di `initialize(...)` (berlaku untuk popup dan banner strip) atau per widget (`CommunityPromoPopupHost(onBannerLink:)`, `CommunityBannerHost(onBannerLink:)`, yang per widget didahulukan). Kembalikan `true` bila OLT sudah menanganinya; `false` membiarkan paket membuka tautan `https`/`http` lewat dialog konfirmasi, sedangkan skema lain diabaikan.

```dart
await RendezvousCommunity.initialize(
  // ...
  onBannerLink: (context, uri, banner) {
    if (uri.scheme != 'olt') return false;                        // https → dialog konfirmasi bawaan
    switch (uri.pathSegments) {
      case [final slug] when uri.host == 'promo':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => OltPromoPage(slug: slug, title: banner.title)));
        return true;
      case [final code] when uri.host == 'stock':
        OltRouter.openStock(context, code);
        return true;
    }
    return false;                                                 // skema olt yang tidak dikenal: diabaikan
  },
);
```

Popup ditutup dan event `click` dicatat sebelum callback dipanggil, jadi `context` adalah halaman host (aman untuk `Navigator.push`). Tampilan kartu bisa diganti lewat slot `system.popup` ([customization.md](customization.md#popup-promo)).

### Chat CS (modul `support`)

Room CS selalu disematkan paling atas di `CommunityChatList` dengan badge **CS Resmi**. Mengetuknya membuka tampilan CS, bukan chat biasa.

**Alur nasabah:**
1. **Buka chat CS.** Bila sudah ada tiket aktif, `CommunitySupportChat` langsung membuka tiket itu.
2. **Pilih topik.** Bila belum ada tiket aktif, nasabah memilih topik di satu layar. Tiket langsung dibuat dan nasabah bisa mengetik atau mengirim gambar (mis. tangkapan layar order).
3. **Selama tiket berjalan**, nasabah melihat:
   - header dengan nomor, topik, dan status ("Menunggu CS", "Ditangani oleh [nama] – CS Resmi", "Menunggu balasan Anda", "Selesai");
   - pesan sistem yang ringkas;
   - pilihan jawaban cepat dari CS;
   - peringatan saat mengetik OTP/PIN/nomor kartu.
4. **Setelah tiket diselesaikan**, nasabah memberi rating langsung di chat.

Menu "⋯" berisi:
- Ajukan pengaduan
- Laporkan CS palsu
- Buat tiket baru
- Tiket saya
- Akhiri chat

Pesan yang gagal karena offline otomatis dikirim ulang saat koneksi kembali. Pengiriman ulang ini aman karena memakai `client_id` yang idempoten.

**Notifikasi saat CS mengambil, membalas, atau menyelesaikan tiket.** `RendezvousCommunity.instance.support.notices()` mengalirkan `SupportNotice` (judul = nama CS, isi = cuplikan pesan) selama aplikasi berjalan. Tampilkan sebagai notifikasi lokal bila room CS sedang tidak terbuka. Contohnya ada di `example/lib/support_notifications.dart` (`flutter_local_notifications`, BSD-3: Windows toast dan Android). Push saat aplikasi tertutup dikirim layanan notifier lewat FCM: daftarkan token dengan `RendezvousCommunity.instance.registerPushToken(...)` dan buka push yang diketuk dengan `openCommunityPush(context, message.data)`. Langkahnya ada di [docs/push](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/push/README.md#aplikasi-olt-pengembang).

### Pengaduan tamu dari halaman login

Nasabah yang lupa password/PIN atau akunnya terkunci tidak punya sesi, jadi chat CS biasa tidak bisa dipakai. Pasang tombol di **halaman login OLT** yang membuka pengaduan tamu (butuh server migrasi `0140`):

```dart
TextButton.icon(
  onPressed: () => openCommunityGuestSupport(context),
  icon: const Icon(Icons.support_agent),
  label: const Text('Tidak bisa masuk? Hubungi CS'),
)
```

`openCommunityGuestSupport` membuka `CommunityGuestSupportPage` (layar penuh dengan AppBar). Untuk panel sendiri, tanam `const CommunityGuestSupport()` (tanpa `Scaffold`).

Halaman ini bekerja **tanpa login**: semua RPC `cs_api.guest_*` dikirim dengan anon key, bukan token sosial, dan `tokenProvider` tidak dipanggil. Ada dua cara menyediakan dependensinya:

1. **Library belum diinisialisasi saat halaman login tampil** (alur bagian 3). Pasang klien anonim di atas navigator, misalnya di `MaterialApp.builder`:

   ```dart
   final guestSupport = CommunityGuestSupportClient.anonymous(
     supabaseUrl: Env.socialApiUrl,
     anonKey: Env.socialAnonKey,
   );

   MaterialApp(
     builder: (context, child) => CommunityGuestSupportScope(dependencies: guestSupport, child: child!),
     home: const OltLoginPage(),
   );
   ```

   Buat klien sekali (variabel global atau milik state aplikasi) agar token pengaduan tetap tersimpan saat halaman ditutup lalu dibuka lagi.

2. **Library sudah diinisialisasi sebelum login** (`RendezvousCommunity.initialize(..., signInEagerly: false)` dengan `tokenProvider` yang mengembalikan `null` sebelum login). Tanpa `CommunityGuestSupportScope`, `openCommunityGuestSupport` memakai `RendezvousCommunity.instance`, yang juga memanggil RPC tamu dengan anon key.

**Menyimpan sesi pengaduan.** Bawaannya token hanya di memori (`MemoryGuestSessionStore`): pengaduan bisa dibuka lagi selama aplikasi berjalan, tetapi hilang bila aplikasi ditutup. Cache lokal paket terikat ke akun yang login sehingga tidak dipakai di sini. Agar nasabah bisa kembali sampai sesi berakhir (bawaan 24 jam), implementasikan `CommunityGuestSessionStore` dengan penyimpanan aman milik OLT dan kembalikan `persistent: true`:

```dart
class OltGuestSessionStore implements CommunityGuestSessionStore {
  @override
  bool get persistent => true;

  @override
  Future<GuestSupportToken?> read() async {
    final raw = await oltSecureStorage.read('guest_support');
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GuestSupportToken(token: json['token'] as String, expiresAt: DateTime.parse(json['expires_at'] as String));
  }

  @override
  Future<void> write(GuestSupportToken token) => oltSecureStorage.write(
    'guest_support',
    jsonEncode({'token': token.token, 'expires_at': token.expiresAt.toIso8601String()}),
  );

  @override
  Future<void> clear() => oltSecureStorage.delete('guest_support');
}

CommunityGuestSupportClient.anonymous(supabaseUrl: ..., anonKey: ..., sessions: OltGuestSessionStore());
// atau RendezvousCommunity.initialize(..., guestSessionStore: OltGuestSessionStore());
```

Token adalah kunci akses ke percakapan itu, jadi simpan di penyimpanan aman (Keychain/Keystore), bukan preferensi biasa. Library menghapusnya sendiri saat pengaduan selesai, ditutup, diakhiri, atau kedaluwarsa, dan token yang sudah lewat `expires_at` tidak dipakai lagi.

Perilaku lengkap (validasi, polling, galat) ada di [features.md](features.md#pengaduan-tamu-sebelum-login-server-migrasi-0140); builder `guestForm`, `guestSecurityNote`, dan `guestHeader` di [customization.md](customization.md#pengaduan-tamu).

## 6. Penanganan error

Semua method repository melempar `CommunityException`. Widget bawaan sudah menampilkan pesan terlokalisasi. Bila OLT memanggil repository langsung:

```dart
try {
  await RendezvousCommunity.instance.chat.sendMessage(roomId, body: text, clientId: uuid);
} on CommunityException catch (e) {
  final message = context.communityL10n.errorMessage(e);   // pesan ramah pengguna
  if (e.kind == CommunityErrorKind.unauthenticated) oltSession.requireLogin();
}
```

Jenis error (`kind`) yang tersedia: `network`, `unauthenticated`, `rateLimited`, `contentBlocked`, `invalidInput`, `forbidden`, `notFound`, `unavailable`, `unknown`.

## 7. Memakai API tanpa UI bawaan

Bila hanya tampilan yang ingin diganti, pakai builder (langkah 4) supaya logika chat tetap dari package. Bila OLT ingin membuat UI sendiri sepenuhnya, semua repository tersedia di `RendezvousCommunity.instance`:
- `feed.getFeed(FeedScope.stock('BBCA'), cursor: ..., limit: 20)` mengembalikan `Paged<Post>`.
- `chat.getRooms(cursor: ..., limit: 30)` mengembalikan `Paged<ChatRoom>`; room CS selalu di halaman pertama. `chat.getRoom(roomId)` memuat satu room.
- `chat.getMessages(roomId, cursor: ..., limit: 30)` memuat pesan dari yang terbaru per halaman. `chat.getMessagesAfter(roomId, cursor)` menyusulkan pesan baru; selama `nextCursor` tidak `null`, masih ada pesan berikutnya.
- `comments.getThread(postId, maxDepth: 3)`.
- `(feed as FeedQueryRepository).queryFeed(FeedScope.stocks(codes), sort: CommunityFeedSort.top, mediaOnly: true)`, `(trending as TrendingInsightsRepository).marketSentiment()` / `.stockStats(codes)`, dan `(profiles as SuggestedUsersRepository).suggestedUsers()` (1.14.0; implementasi bawaan mengimplementasikan semuanya).
- `chat.connectRoom(roomId, me: user).events` adalah stream realtime room (pesan, mengetik, tanda terima, presence). Sejak 1.5.0 pesan datang sebagai Broadcast dari server di topik privat `room:<id>` (backend `0098`), dan room mengisi celah sendiri lewat `get_messages` saat tersambung, tiap 45 detik, dan saat aplikasi kembali ke depan.
- `chat.watchRoomSignals({roomId, ...}, me: user)` memantau mengetik, tanda terima, dan presence banyak room sekaligus (untuk daftar chat buatan sendiri).
- `polls.vote(postId, optionId)` memberi suara; data polling ada di `Post.poll`.
- `stocks.getStock(code)` mengembalikan kode, jumlah pemantau, dan status pantau user; `stocks.watch(code)` / `unwatch(code)` mengubahnya.

Kontrak lengkapnya ada di `lib/src/features/<fitur>/domain/repositories/` (mis. `features/chat/domain/repositories/chat_repository.dart`).

## 8. Test di proyek OLT

Bungkus widget sosial dengan `CommunityScope` dan berikan implementasi palsu `CommunityDependencies`. Dengan begitu widget test berjalan tanpa backend. Contohnya ada di [`test/support/fakes.dart`](../test/support/fakes.dart).

## 9. Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| Emulator Android tidak bisa terhubung | Gunakan `http://10.0.2.2:8000`, bukan `localhost`. Untuk HP fisik: `EDGE_HTTP_BIND=0.0.0.0` + IP PC |
| `Cleartext HTTP traffic not permitted` | Build debug: tambahkan `usesCleartextTraffic` di manifest debug. Produksi: gunakan HTTPS |
| Selalu "Sesi berakhir" | `tokenProvider` mengembalikan null, token sesi OLT (bukan token sosial), atau token sosial kedaluwarsa. Alasan pastinya ada di `docker compose logs auth-bridge` (`exchange rejected`, field `reason`) |
| Log auth-bridge: `unknown kid` / `invalid signature` | `docker/secrets/olt_jwks` belum berisi kunci publik OLT yang dipakai menandatangani. Tambahkan JWKS dari OLT, lalu restart auth-bridge |
| Log auth-bridge: `token lifetime exceeds the limit` / `token expired` | OLT menerbitkan token lebih dari `OLT_JWT_MAX_TTL` (15 menit), atau jam server OLT/sosial selisih lebih dari 30 detik (cek NTP) |
| Log auth-bridge: `audience` / `issuer` | Klaim `aud` harus memuat `olt-social` dan `iss` harus `olt` (atau sesuai `OLT_JWT_AUDIENCE` / `OLT_JWT_ISSUER`) |
| Realtime tidak masuk | Pastikan port 443/8000 meneruskan WebSocket (Traefik sudah). Cek `docker compose logs realtime` |
| Upload foto gagal "Jenis file tidak didukung" | Server memeriksa isi file, bukan ekstensinya. Foto HEIC diubah library ke JPEG di perangkat (Android 9+, iOS/macOS, Safari); di Windows/Linux nasabah perlu menyimpan foto sebagai JPEG dulu |
| "Upload belum tersedia" | Server belum menjalankan layanan `media` (`/media/v1` 404). Update server ke versi yang memuat `services/media` |
| "Terlalu cepat" | Rate limit server (post 5/menit, komentar 20/menit, pesan 30/menit). Ubah lewat `private.rate_limits` |
