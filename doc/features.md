# Fitur & perilaku

[← Kembali ke README](../README.md)

Rincian perilaku setiap fitur bawaan paket. Contoh pemasangan ada di [README](../README.md#mulai-cepat), kustomisasi tampilan di [customization.md](customization.md).

## Fitur UI

| Fitur | Perilaku |
|---|---|
| Layout responsif | Kolom konten maksimal 720 px. `CommunityChatList` tampil multi-panel di lebar ≥ 840 px |
| Keyboard desktop | Di composer post, komentar, dan chat: Enter mengirim, Shift+Enter membuat baris baru. Autocomplete bisa dipilih dengan ↑/↓ dan Enter/Tab |
| Hover | Sorotan komentar. Aksi pesan muncul saat kursor di atas gelembung (reaksi, balas, dan menu ⋮ berisi Balas, Salin, Info pesan, Laporkan, Hapus), tanpa mengubah lebar gelembung. Di layar sentuh, menu yang sama muncul dengan tekan lama, dan pesan bisa digeser untuk membalas ala WhatsApp (ikon balas muncul, getar halus saat ambang tercapai; ambang, arah, dan getar bisa diatur host lewat `CommunitySwipeToReplyScope`) |
| `$KODE` & `@user` | Bisa diketuk lewat `onStockTap` / `onUserTap`. Bila callback tidak diisi, halaman bawaan yang dibuka |
| Data saham | Server tidak menyimpan daftar saham. Kode apa pun yang berformat `$KODE` (huruf di depan, 2–12 huruf/angka) dipakai sebagai label untuk feed, pantau, dan room saham. Saran saat mengetik `$` datang dari `stockSearch` milik app (tanpa callback: tidak ada saran). Nama saham di header `CommunityStockFeed` datang dari `stockName`; server hanya memberi jumlah pemantau |
| Thread komentar | Garis indentasi per level. Mulai level 4, indentasi berhenti dan muncul "Lanjutkan thread". Tersedia "Lihat N balasan lainnya" dan collapse/expand per cabang |
| Optimistic update | Like post/komentar, follow, watch, dan kirim pesan. Bila server gagal, perubahan dibatalkan dan SnackBar ditampilkan |
| Chat | Centang ala WhatsApp: jam (mengirim), ✓ (sampai server), ✓✓ abu-abu (sudah diterima perangkat penerima yang online), ✓✓ biru (sudah dibaca). Di grup, centang naik setelah **semua** anggota menerima/membaca; room saham hanya ✓. Badge belum dibaca per room, balas pesan ala WhatsApp (kartu "sedang membalas" di dalam kolom input berisi nama tampilan dan cuplikan; kutipan di gelembung menampilkan nama tampilan, "Anda" untuk pesan sendiri; mengetuk kutipan menggulir ke pesan asli dan menyorotnya, memuat halaman lama bila perlu), reconnect otomatis dengan pengisian celah pesan dan tanda terima |
| Info pesan | Untuk pesan sendiri di DM, grup, dan chat CS (server dengan migrasi `0122`): kapan **terkirim** dan **dibaca** per penerima, seperti WhatsApp. DM menampilkan dua baris (Dibaca, Terkirim); grup dan CS menampilkan "Dibaca oleh", "Terkirim ke", dan jumlah yang belum menerima. Tampil sebagai dialog di layar lebar (≥ 600 px) dan bottom sheet di ponsel, diperbarui otomatis saat tanda terima berubah. Waktu disimpan server 30 hari; setelahnya status tetap tampil dengan "Waktu tidak tercatat". Bisa diganti lewat slot `chat.messageInfo` |
| Lazy load chat | Pesan dimuat 30 per halaman memakai cursor (bukan offset). Halaman lebih lama diambil saat scroll mendekati pesan tertua, dan otomatis bila halaman pertama belum memenuhi layar. Daftar room juga dimuat 30 per halaman dengan aturan yang sama. Pesan yang terlewat (koneksi putus atau event Realtime dibuang) disusulkan dari horizon terakhir yang dikonfirmasi server, termasuk lubang di tengah aliran: saat room tersambung, setelah sambung ulang (jeda acak 0–5 dtk, lalu sekali lagi 5–10 dtk kemudian), tiap ±45 dtk, dan saat aplikasi kembali ke depan. Room saham/DM/grup hanya membandingkan id (`get_message_ids`) lalu mengambil yang belum ada; bila lebih dari 5 halaman, room dimuat ulang dari pesan terbaru dan pesan lama tetap bisa dimuat dengan scroll |
| Badge tab chat | `CommunityChatBadge` menampilkan jumlah **chat** (DM & grup yang tidak dibisukan) yang punya pesan belum dibaca, seperti tab Chat WhatsApp; `99+` bila lebih. Room saham tidak dihitung. Diperbarui saat pesan masuk dan saat room dibuka |
| Mengetik & online | "mengetik…" (DM) atau "Budi sedang mengetik…" (grup) tampil di daftar chat dan di room. Room besar (room saham dan grup mulai 50 anggota, diatur server) hanya menampilkan "Seseorang sedang mengetik…" atau "Beberapa orang sedang mengetik…" tanpa nama, dari ringkasan server paling sering tiap 3 dtk. Titik hijau dan teks "Online" untuk lawan bicara DM; presence hanya dipakai di DM (1.6.0) |
| Daftar room saham | Pratinjau dan jumlah belum dibaca room saham di daftar chat diperbarui lewat polling ringan `get_room_previews` selama daftar terlihat (`TickerMode` aktif, aplikasi di depan, online): tiap ±15 dtk ± 25% (diatur server), langsung saat aplikasi kembali ke depan. DM, grup, dan CS tetap realtime (1.6.0) |
| Lampiran | Chat global (DM, grup, room saham) hanya gambar (JPEG, PNG, WebP, GIF). Chat CS (`CommunitySupportChat`) juga menerima dokumen dan video sesuai daftar format dari server (lihat [Lampiran chat CS](#lampiran-chat-cs-dokumen-dan-video)); server lama tetap gambar + PDF maksimal 10 MB. Foto HEIC/HEIF diubah ke JPEG di perangkat sebelum dikirim. Semua unggahan lewat media gateway (lihat di bawah). Gambar bisa ditempel ke kolom chat dengan Ctrl+V (⌘V di macOS) di desktop, atau dari keyboard Android; gambar clipboard Windows (BMP) diubah ke PNG dan diperkecil bila melebihi 5 MB. Bila clipboard tidak berisi gambar, Ctrl+V menempel teks seperti biasa. Lampiran (pilih beberapa file, tempel, atau keyboard) masuk antrean di atas kolom input dan baru dikirim bersama teks saat Enter/tombol kirim, maksimal 4 per pesan; tiap lampiran bisa dihapus dari antrean |
| Penampil gambar | Ketuk foto di chat atau Info pesan untuk melihat layar penuh: zoom, geser antar foto (atau ←/→), Esc/✕ menutup, dan **Unduh** (desktop: Simpan sebagai; ponsel: lembar berbagi; web: unduhan browser). Bisa diganti lewat slot `shared.imageViewer` |
| Seleksi teks | Di desktop dan web, teks pesan, nama, kutipan, pesan sistem, header chat CS, dan Info pesan bisa diseleksi dengan mouse lalu disalin (Ctrl+C), termasuk lintas beberapa gelembung. Di ponsel, tekan lama membuka menu aksi dengan Salin |
| Polling | Tombol polling di composer: 2–4 pilihan (maks 40 karakter, tidak boleh sama), durasi 1 jam–7 hari. Satu suara per user dan tidak bisa diubah; pembuat tidak ikut memilih. Hasil (persentase, pilihan Anda, pilihan teratas) tampil setelah memilih, saat polling selesai, atau bagi pembuat |
| State | Skeleton saat memuat, tampilan kosong, error dengan tombol coba lagi, pull-to-refresh, infinite scroll, banner "N post baru" |
| Disclaimer | *"Konten ini opini pengguna, bukan rekomendasi investasi."* di composer dan detail post |
| Tautan & hashtag | `#hashtag` membuka `CommunityHashtagFeed` (atau `onHashtagTap`). Tautan `http(s)` dibuka di browser setelah dialog yang menampilkan domain asli; skema lain (`javascript:`, `tel:`, `www.` tanpa skema) tetap teks biasa |
| Link preview | Kartu di bawah post, komentar, dan pesan untuk URL pertama: judul, deskripsi, situs, gambar, domain akhir setelah redirect. Satu `get_link_previews` per batch layar, `pending` diulang paling banyak dua kali |
| Edit | Menu "Edit" di post/komentar sendiri hanya selama `edit_minutes` (15 menit, waktu server); post polling tidak bisa diedit. Label "(diedit)" |
| Bookmark | Ikon simpan di kartu post dan menu; `CommunityBookmarks` menampilkan daftar, post yang dibatalkan langsung hilang dari daftar |
| Reaksi pesan | Tekan lama (atau tombol saat hover) → 👍 ❤️ 😂 😮 😢 🔥; chip jumlah di bawah gelembung, sorot bila milik sendiri, realtime. Tidak ada di chat CS |
| Bagikan post | "Kirim ke chat" di menu post → pilih room → kartu post di pesan ("Post tidak tersedia" bila dihapus/ditahan/blokir) |
| Label | "Bot" untuk post dari API bot integrasi, "Resmi" untuk akun resmi |
| Konten ditahan | Post/komentar/pesan sendiri berstatus `held`: "Menunggu tinjauan"; `hidden`: "Disembunyikan moderator" + "Ajukan banding". Gambar yang diunggah dengan `"held": true` juga berlabel |
| Room saham | Banner slow mode ("1 pesan tiap 10 detik"), hitung mundur di tombol kirim, dan pesan yang disematkan (realtime `room_state`) |

## Dokumen hukum & persetujuan

Server menolak post, komentar, dan pesan chat (kecuali chat CS) dengan kode `consent_required` bila ada dokumen wajib (Syarat & Ketentuan, Pedoman Komunitas) versi terbaru yang belum disetujui. Paket menanganinya sendiri:

| Bagian | Perilaku |
|---|---|
| Gerbang otomatis | Post, komentar, atau pesan chat yang ditolak `consent_required` membuka alur persetujuan. Setelah "Setuju", aksi yang sama diulang **satu kali** dengan draf yang sama. Bila ditunda ("Nanti"), draf tetap ada (teks composer tidak dihapus, pesan chat menjadi "Gagal terkirim" dan bisa diketuk untuk kirim ulang) dan SnackBar singkat muncul. Chat CS tidak pernah memicu alur ini |
| Alur persetujuan | Dialog di layar lebar, layar penuh di ponsel. Daftar dokumen wajib yang belum disetujui; tiap dokumen bisa dibaca lengkap (judul, versi, tanggal berlaku, kotak "Yang berubah", teks dengan baris baru apa adanya). Satu kotak centang "Saya telah membaca dan menyetujui …" lalu "Setuju" menyetujui semuanya |
| Banner | `CommunityConsentBanner` tampil di atas feed, misalnya *"Pedoman Komunitas diperbarui — tinjau dan setujui."* "Tinjau" membuka alur persetujuan; ikon tutup menyembunyikannya sampai ada dokumen wajib baru |
| Cache | Daftar dokumen (`get_legal_documents`) dimuat sekali per sesi saat login, dimuat ulang setelah menyetujui. Rebuild widget tidak memanggil server |

```dart
final community = RendezvousCommunity.instance;
final all = await community.legalDocuments();                 // versi berlaku terbaru per jenis
final pending = await community.pendingLegalDocuments();     // wajib & belum disetujui
await community.acceptLegalDocuments([for (final d in pending) d.id]);

final accepted = await showCommunityConsent(context);         // true bila semua sudah disetujui
await showCommunityLegalDocument(context, all.first);         // pembaca dokumen
CommunityLegalDocumentReader(document: all.first);            // pembaca sebagai widget
```

`communityConsentGate(context)` mengembalikan `ConsentGate` yang sama dengan yang dipakai paket, untuk aksi host yang juga bisa ditolak `consent_required`: `await gate.run(() => aksi())`.

## Privasi & akun

`CommunityAccountSettings` (tanpa Scaffold) atau `openCommunityAccountSettings(context)` (halaman dengan AppBar "Privasi & akun") berisi:

- **Dokumen hukum:** tautan ke setiap dokumen yang berlaku, plus banner bila ada yang belum disetujui.
- **Unduh data saya:** memanggil `export_my_data` dan menyimpan JSON rapi bernama `data-komunitas-<username>-<yyyyMMdd>.json`. Windows/macOS/Linux memakai dialog simpan; Android/iOS/web membagikan file (web mengunduh bila Web Share API tidak ada). Server membatasi 3 kali sehari; batas ini ditampilkan sebagai pesan yang jelas.
- **Hapus akun komunitas:** menjelaskan dampaknya (post, komentar, dan chat hilang dari tampilan; salinan diarsipkan untuk regulator; pengikut/blokir/bisukan dihapus; riwayat CS tetap; akun trading tidak tersentuh; profil baru yang kosong dibuat saat masuk lagi), meminta mengetik `HAPUS`, menampilkan proses, lalu memanggil `onAccountDeleted`.

```dart
await openCommunityAccountSettings(
  context,
  onAccountDeleted: () => oltRouter.goHome(),    // halaman pengaturan sudah ditutup paket
);

CommunityAccountSettings(
  onAccountDeleted: () => Navigator.of(context).pop(),   // tanpa callback: Navigator.maybePop
  exportSaver: (context, export) async => oltFiles.save(export.fileName, export.bytes),
);

final export = await RendezvousCommunity.instance.exportMyData();   // CommunityDataExport: bytes + fileName
await RendezvousCommunity.instance.deleteMyAccount();
```

`deleteMyAccount()` membersihkan sesi komunitas di perangkat (realtime, pelacak centang, cache dokumen, cache offline dan outbox) tanpa login ulang otomatis. Panggilan API komunitas berikutnya menukar token OLT lagi dan server membuat profil komunitas baru yang kosong. Token push dilepas server; token yang terdaftar dipasang lagi otomatis di sesi berikutnya. Karena itu, arahkan pengguna keluar dari layar komunitas di `onAccountDeleted`.

## Lampiran chat CS: dokumen dan video

Server dengan migrasi `0131` menyimpan daftar format lampiran chat CS yang diatur Super Admin dari Hub. Library membacanya lewat `cs_api.attachment_policy()` saat chat CS dibuka (`SupportRepository.attachmentPolicy()`, hasilnya `CommunityAttachmentPolicy` di `SupportState.attachmentPolicy`) dan meneruskannya ke `MessageComposer(attachmentPolicy: ...)`. Server lama tanpa RPC ini memakai `CommunityAttachmentPolicy.legacy` (gambar + PDF 10 MB), jadi perilakunya sama seperti sebelumnya. Chat lain (DM, grup, room saham) tetap hanya gambar (`CommunityAttachmentPolicy.imagesOnly`).

| Jenis | Format (bawaan server) | Batas bawaan | Tampilan |
|---|---|---|---|
| Dokumen | PDF, Word `.docx`, Excel `.xlsx`, PowerPoint `.pptx`, teks `.txt`, `.csv` | 10 MB | Kartu per jenis (ikon, nama asli, "Word · 23 KB"). Diketuk: di Windows/macOS/Linux file diunduh ke folder sementara lalu dibuka aplikasi bawaan; di Android/iOS signed URL 5 menit dibuka aplikasi/browser sistem; di web dibuka di tab baru |
| Gambar | JPEG, PNG, WebP, GIF; HEIC/HEIF diubah ke JPEG di perangkat | 5 MB | Sama seperti sebelumnya |
| Video | MP4 (H.264/AAC), MOV, WebM | 25 MB, 2 menit | Thumbnail dari server + durasi + ukuran. Android, iOS, macOS, dan web memutar di aplikasi (`video_player`, layar penuh dengan jeda/geser). Windows dan Linux mengunduh video lalu membukanya di pemutar bawaan sistem |

- **Pemilih file** (`file_selector`) menampilkan grup **Foto**, **Video**, **Dokumen** hanya untuk jenis yang aktif, lengkap dengan ekstensi, MIME, dan UTI (iOS butuh UTI). Jenis yang dimatikan Super Admin tidak muncul.
- **Sebelum unggah**, file dicocokkan ke daftar format (ekstensi dulu, lalu MIME dari sistem) dan ukurannya dicek terhadap `max_bytes` jenisnya. File yang ditolak tidak dikirim dan nasabah melihat pesan, misalnya "makro.docm tidak bisa dikirim. Format yang diterima: JPG, PNG, …" atau "rekaman.mp4 terlalu besar. Batasnya 25 MB." Durasi video dicek server.
- **HEIC/HEIF** dikenali dari isi file (`ftyp` brand `heic`, `heix`, `hevc`, `mif1`, `msf1`, dan sejenisnya), nama, atau MIME. Foto didekode dengan dekoder platform lewat `dart:ui` (Android 9+, iOS/macOS bila dekoder sistem tersedia, web di browser yang bisa membaca HEIC seperti Safari), diperkecil ke sisi terpanjang 3072 px, lalu di-encode JPEG kualitas 85 dengan paket `image` (Dart murni, MIT) di isolate terpisah. Metadata (termasuk lokasi) ikut terbuang. Di perangkat yang tidak bisa mendekode HEIC (Windows, Linux, Android lama, browser lain) muncul pesan "Foto HEIC belum bisa diubah ke JPEG di perangkat ini. Simpan foto sebagai JPEG, lalu kirim lagi."
- **Saat mengirim**, composer menampilkan "Memeriksa file…" selama layanan `media` memindai antivirus dan memproses video (bisa beberapa detik).
- **Format JSON lampiran** sesuai server: dokumen `{"bucket":"cs-documents","path":"rooms/<room>/<uid>/<acak>.<ext>","mime","name","size"}`, video `{"bucket":"cs-videos",...,"duration","width","height","thumbnail"}`. Nama asli dipotong 200 karakter.

## Unggahan lewat media gateway

Mulai 1.2.0 semua unggahan nasabah lewat layanan `media`, bukan langsung ke Storage:

```
POST {supabaseUrl}/media/v1/object/{bucket}/{path}
apikey: <anon key>
Authorization: Bearer <JWT sosial>
Content-Type: <tebakan dari nama file>
x-upsert: true            # hanya foto profil
```

| Unggahan | Bucket | Path yang diminta | Jenis |
|---|---|---|---|
| Gambar post | `attachments` | `posts/<user>/<uuid>.<ext>` | JPEG, PNG, WebP, GIF, maks 5 MB |
| Gambar chat (termasuk chat CS) | `attachments` | `rooms/<room>/<user>/<uuid>.<ext>` | JPEG, PNG, WebP, GIF, maks 5 MB |
| Dokumen chat CS | `cs-documents` | `rooms/<room>/<user>/<uuid>.<ext>` | Sesuai daftar server (bawaan PDF, DOCX, XLSX, PPTX, TXT, CSV), maks 10 MB; server lama hanya PDF |
| Video chat CS | `cs-videos` | `rooms/<room>/<user>/<uuid>.<ext>` | MP4, MOV, WebM, maks 25 MB dan 2 menit; respons menambah `duration`, `width`, `height`, `thumbnail` |
| Foto profil | `avatars` | `<user>/avatar-<ms>.<ext>` | JPEG, PNG, WebP (GIF ditolak), maks 2 MB |

Server membaca jenis file dari isinya, membuang metadata (EXIF/GPS dan sejenisnya), dan bisa mengganti ekstensi. Paket memakai `path` dan `mime` dari respons, juga `width`/`height` untuk gambar. Respons 401 memicu refresh sesi lalu satu kali percobaan ulang. Error dipetakan ke `CommunityException` (`kind` + `code` dari server) dan pesan terlokalisasi lewat `context.communityL10n.errorMessage(e)`:

| Kode | Pesan (id) |
|---|---|
| `unsupported_type` | Jenis file tidak didukung … |
| `file_too_large` | File terlalu besar. Batasnya 5 MB untuk gambar dan 2 MB untuk foto profil; batas dokumen dan video di chat CS diatur server. |
| `invalid_image` / `image_too_large` | Gambar rusak … / Resolusi gambar terlalu besar … |
| `invalid_pdf` / `pdf_encrypted` / `pdf_active_content` | PDF rusak … / PDF yang dikunci kata sandi … / PDF berisi skrip … |
| `office_macro` / `office_unsafe` / `archive_bomb` | Dokumen berisi makro … / objek tertanam yang tidak aman … / isi dokumen tidak wajar … |
| `invalid_text` | File teks atau CSV harus memakai UTF-8 … |
| `invalid_video` / `video_too_long` | Video rusak atau formatnya tidak didukung … / Video terlalu panjang … |
| `malware_detected` / `scanner_unavailable` | File ditolak karena pemindai antivirus … / Pemeriksaan file sedang tidak tersedia … |
| `kind_disabled` / `policy_unavailable` | Jenis lampiran ini sedang tidak diterima di chat CS. / Daftar format lampiran belum bisa dimuat … |
| `attachment_not_allowed` / `attachment_too_large` / `attachment_too_long` (dari database saat pesan dikirim) | Format lampiran ini tidak diterima di chat ini … / Lampiran melebihi batas ukuran … / Video melebihi batas durasi … |
| `upload_forbidden` | Anda tidak diizinkan mengunggah file ke sini. |
| `too_many_uploads` | Batas unggahan hari ini sudah tercapai … |
| `busy` | Server unggahan sedang sibuk … |
| `storage_unavailable`, `storage_error`, 404 tanpa kode (backend lama) | Unggahan file sedang tidak tersedia … |
| `image_blocked` | Gambar ini tidak bisa diunggah karena melanggar Pedoman Komunitas. |
| `classifier_unavailable`, `moderation_unavailable` | Pemeriksaan gambar sedang tidak tersedia … (`retryAfter` dari `Retry-After`) |

Gambar yang perlu ditinjau tetap tersimpan dan respons memuat `"held": true`; paket menandainya `Attachment.held` dan menampilkan label "Menunggu tinjauan" di composer dan gelembung chat pengunggah.

Kong harus mengizinkan header `x-upsert` di CORS untuk app web.

## Konfigurasi klien & kill switch (1.3.0)

`get_client_config` dipanggil saat `initialize`, saat login/ganti akun, saat aplikasi kembali ke foreground, dan tiap 5 menit. Sebelum login dipanggil dengan anon key (hanya flag 100%). `platform` (`CommunityPlatform`: `android`, `ios`, `web`, `windows`, `macos`, `linux`) default dari platform yang berjalan, dan ikut dikirim ke `track_events`.

```dart
final config = RendezvousCommunity.instance.clientConfig;          // ClientConfig
RendezvousCommunity.instance.clientConfigChanges.listen((c) { ... });
await RendezvousCommunity.instance.refreshClientConfig();
config.feature(CommunityFlags.search);                               // social_enabled && flag
```

| Bagian | Perilaku |
|---|---|
| Kill switch | `social_enabled = false` atau error `social_disabled` → feed, composer, detail post, pencarian, trending, bookmark, room non-CS menampilkan `CommunityUnavailableView`; daftar chat hanya menampilkan room CS. Chat CS tetap jalan. `social_disabled` dikenali dari kodenya, bukan status HTTP: backend `0109` ke atas mengirim `403` (`PT403`), backend lama `503` (`PT503`); keduanya ditangani sejak 1.3.0. Dengan `403`, pesan chat yang ditolak langsung gagal (tidak dicoba ulang otomatis oleh outbox) |
| Placeholder kustom | `CommunityAvailabilityScope(builder: (context, reason, fallback) => ...)` di `MaterialApp.builder`, atau `CommunitySocialGate(unavailableBuilder: ...)` per widget. `reason`: `socialDisabled` / `featureDisabled` |
| Versi minimum | `update_required` → `initialize(onUpdateRequired:)` dan `CommunityUpdateListener(onUpdateRequired: (context, config) => ...)` dipanggil sekali per transisi |
| Flag yang dibaca | `search` (pencarian, hashtag), `trending` (trending, sentimen), `bookmarks`, `post_edit`, `message_reactions`, `share_post_to_chat`, `notification_prefs`, `analytics`. Sebelum konfigurasi termuat semua flag dianggap aktif; setelah termuat, flag yang tidak dikenal server dianggap mati |
| Nilai lain | `edit_minutes`, `message_reactions`, `search_min_length`, `notification_types`, selisih jam server (`clockSkew`) untuk jendela edit |

Detail lengkap fitur 1.3.0: [docs/rendezvous-community/features-1.3.md](https://github.com/dayat123123/chat_service_supabase/blob/main/docs/rendezvous-community/features-1.3.md) (repo backend).

## Pesan langsung, banding, notifikasi (1.3.0)

```dart
await openCommunityMessageRequests(context);                    // daftar permintaan pesan
await openCommunityAppeals(context);                            // "Banding saya"
await showCommunityAppealDialog(context, targetType: AppealTargetType.post, targetId: postId);
await openCommunityNotificationSettings(context);
```

- **Permintaan pesan:** DM dari orang yang tidak Anda ikuti masuk ke "Permintaan pesan" di atas daftar chat (jumlah dari `get_message_request_count`). Room permintaan memburamkan gambar sampai diterima; aksi Terima / Tolak / Blokir & laporkan. Saat DM dibuka, `get_dm_request_state` dibaca: pengirim melihat "Pesan Anda masih berupa permintaan (n/3)" lalu pemberitahuan batas, penerima bisa menekan "Terima" langsung dari room.
- **Privasi & akun** kini juga berisi "Pesan langsung" (semua orang / hanya yang saya ikuti / tidak ada), "Notifikasi" (di aplikasi & push per jenis, jam tenang WIB; bagian "Notifikasi OLT" untuk Transaksi, Dana, Pasar, Info, dan Promo; pesan CS resmi dan pesan OLT kategori `important` selalu dikirim), dan "Banding & sanksi".
- **Banding saya:** sanksi aktif, "Konten yang dimoderasi" (post/komentar/pesan yang disembunyikan atau dihapus moderator dalam 90 hari, dari `get_my_moderated_content`) dengan tombol "Ajukan banding" bila belum dibanding, dan riwayat banding.
- **Notifikasi gabungan:** "Budi dan 4 lainnya menyukai konten Anda" memakai `actor_count`, bukan `event_count`. Notifikasi `appeal` membuka "Banding saya".

## Analitik (1.3.0)

Paket mencatat `feed_open`, `post_create`, `comment_create`, `message_send`, `stock_tap`, `search`, dan `share_chart` lalu mengirimnya ke `track_events` per batch (maks 50, tiap 60 detik, saat 20 event terkumpul, atau saat aplikasi ke latar belakang). Batch yang gagal dibuang; bila server menjawab `disabled` atau flag `analytics` mati, pencatatan berhenti. Hanya properti whitelist (kode saham, UUID, enum, angka, boolean) yang dikirim; teks post, pesan, dan kata kunci pencarian tidak pernah dikirim.

```dart
RendezvousCommunity.instance.trackOrderTap(stockCode: 'BBCA', side: 'buy', source: 'stock'); // dari sosial ke layar order
```

## Banner, draf, kartu saham, statistik notifikasi (1.3.0, migrasi `0087`–`0090`)

```dart
await RendezvousCommunity.initialize(
  // ...
  stockInfo: (code) => CommunityStockInfo(name: oltStocks.name(code), price: oltQuotes.last(code)), // kartu saham
  onOltNotificationTap: (context, data) => oltRouter.openNotification(data),
);

const CommunityBannerHost();                 // banner dari get_client_config, mis. di atas halaman host
await openCommunityPostDrafts(context);      // daftar draf postingan
await showCommunityComposer(context, draft: draft);
await RendezvousCommunity.instance.reportNotificationTapped(pushData); // bila host membuka tujuan push sendiri
```

- **Banner:** maksimal 3 tampil (atur `maxVisible`), urut `priority`. Gaya per level `info`/`warning`/`critical`, tautan dibuka setelah dialog konfirmasi. Banner yang bisa ditutup dan sudah ditutup disimpan per user di perangkat (ikut terhapus saat logout); banner yang tidak bisa ditutup selalu tampil. Feed Terbaru/Mengikuti menampilkannya otomatis di atas daftar. Banner `display: "popup"` tidak tampil sebagai strip (lihat [Popup promo](#popup-promo-170)).
- **Statistik notifikasi:** membuka item kotak notifikasi atau push melapor `opened`, mengikuti tujuannya melapor `tapped` (`report_notification_event`; `notification_id`, lalu `campaign_id`/`broadcast_id`). Tidak pernah menahan UI; gagal karena jaringan diantrekan di memori sampai online. Push OLT yang diteruskan ke `onOltNotificationTap` dihitung `tapped`.
- **Notifikasi baru:** `followed_post` → postingan, `watchlist_digest` → feed saham teratas (`onStockTap`), `moderation` → "Banding saya" dengan keterangan bisa/tidaknya banding, mention di room saham → room. Sakelar in-app jenis yang dikunci server (`moderation`) nonaktif. Keterangan `watchlist_digest` memakai jam kirim dari server (`NotificationPreferences.watchlistDigestTime`, diatur Super Admin di Hub; server tanpa migrasi `0147` = 17.05 WIB).
- **Draf:** composer menyimpan otomatis ke perangkat dan server (`save_post_draft`). Bila draf diubah di perangkat lain dan lebih baru, versi itu dimuat dan pengguna diberi tahu; batas 20 draf atau offline → draf hanya di perangkat. Saat terbit, `client_draft_id` dipakai sebagai `client_id` sehingga server menghapus drafnya. `initialize(postDrafts: false)` mematikan draf; `clearPostDrafts()` menghapus semua draf user (1.15.2).
- **Kartu saham:** tombol "Kirim kartu saham" di composer chat (DM, grup, room saham; tidak di chat CS), maksimal 3 kode. Harga tidak dikirim ke server; nama/harga di kartu berasal dari `stockInfo` host atau builder `CommunityChatBuilders(stockCard:)`. `initialize(chatStockCards: false)` menyembunyikan tombolnya; kartu yang sudah diterima tetap tampil (1.15.1).

## Popup promo (1.7.0)

Banner dari `get_client_config` dengan `display: "popup"` tampil sebagai kartu di tengah layar, bukan strip. Pasang `CommunityPromoPopupHost` sekali di halaman utama host (di bawah `Navigator`, mis. pembungkus `home`); `CommunityBannerHost` tidak pernah menampilkan banner popup.

```dart
MaterialApp(
  home: CommunityPromoPopupHost(
    onBannerLink: (context, uri, banner) => oltRouter.tryOpen(context, uri), // opsional, true = sudah ditangani
    child: const OltHomePage(),
  ),
);
```

- **Kapan tampil:** setelah konfigurasi klien termuat dan frame pertama selesai, maksimal **satu popup per sesi aplikasi** (per user; sesi baru dimulai saat cold start atau ganti akun). Dipilih banner popup aktif (jadwal, platform, dan versi disaring server; `starts_at`/`ends_at` diperiksa lagi dengan jam server) dengan `priority` tertinggi yang lolos aturan frekuensi; prioritas sama → `starts_at` terbaru. Bila konfigurasi baru datang di tengah sesi dan belum ada popup yang tampil, popup bisa muncul saat itu.
- **Tidak tampil** bila belum ada user yang masuk (frekuensi dicatat per user), saat `update_required`, saat `CommunityPromoPopupHost(enabled: false)`, atau selama ada route/dialog lain di atas route host (mis. persetujuan dokumen wajib, dialog update dari `CommunityUpdateListener`, halaman yang dibuka di atasnya); popup ditunda sampai route host kembali teratas. Kill switch tidak berpengaruh, sama seperti banner strip.
- **Frekuensi** (`frequency`, tak dikenal → `once`):

| Nilai | Tampil bila |
|---|---|
| `once` (bawaan) | belum pernah ditampilkan ke user ini di perangkat ini |
| `daily` | belum ditampilkan hari ini (tanggal lokal perangkat) |
| `every_open` | setiap sesi/cold start (bukan setiap rebuild atau pindah halaman) |

  Waktu tampil disimpan per user + banner di penyimpanan lokal paket yang sama dengan banner yang ditutup (database offline milik user, kunci `promo_popups:<user>`, maks 100 banner terakhir); ikut terhapus saat logout/ganti akun. Dengan `initialize(offlineCache: false)` catatan hanya di memori, jadi `once`/`daily` bisa muncul lagi setelah aplikasi dibuka ulang.
- **Tampilan bawaan:** overlay hitam 60%, kartu lebar maks 360 radius 16 mengikuti `CommunityStyle` (terang/gelap, aksen host), gambar `image_url` di atas (rasio dari gambar, dibatasi 4:5–16:9, placeholder skeleton saat memuat), judul tebal, isi, tombol utama aksen penuh lebar (`cta_label`, bawaan "Lihat") bila ada `link_url`, tombol "Nanti", ikon ✕ bila `dismissible`. Animasi masuk fade + scale 200 ms sekali jalan, mati bila animasi dinonaktifkan sistem. Semantik dialog berlabel "Promo", fokus terkunci di popup, target sentuh ≥ 48. Ganti tampilannya lewat slot `system.popup` ([customization.md](customization.md#banner-kill-switch-dan-offline-170)).
- **Perilaku:**

| Aksi pengguna | Hasil | Event |
|---|---|---|
| Popup tampil | – | `impression` (sekali) |
| Tombol utama atau ketuk gambar | tutup popup, lalu buka tautan | `click` |
| ✕ (hanya bila `dismissible`) | tutup | `dismiss` |
| "Nanti" (selalu ada; tanpa `link_url` berlabel "Tutup") | tutup; frekuensi tetap berlaku, juga untuk popup yang tidak `dismissible` | `dismiss` |
| Ketuk overlay di luar kartu / tombol kembali Android | tutup bila `dismissible`; diabaikan bila tidak | `dismiss` bila tertutup |

- **Tautan** (`link_url`, berlaku juga untuk tombol "Selengkapnya" di banner strip): `onBannerLink` milik `CommunityPromoPopupHost`/`CommunityBannerHost` dipanggil lebih dulu, kalau tidak ada dipakai `initialize(onBannerLink:)`; nilai `true` berarti host sudah menanganinya (mis. deep link `olt://promo/akhir-tahun`). Bila tidak ditangani: `https`/`http` dibuka lewat dialog konfirmasi tautan luar seperti tautan lain, skema lain diabaikan dengan aman. Tanpa callback perilaku strip sama seperti sebelumnya.
- **Event** dikirim lewat RPC `record_banner_event(p_banner_id, p_event)` (`impression`/`click`/`dismiss`, idempoten di server) tanpa menunggu; gagal jaringan diabaikan diam-diam (log level `FINE` di `RendezvousCommunity.Config`).
- **Kontrak server:** objek di `banners` mendapat `display` (`strip`/`popup`, tak ada → `strip`), `image_url` (URL `http(s)` publik atau null; selain itu diabaikan), `cta_label` (null/kosong → label bawaan), `frequency` (`once`/`daily`/`every_open`). Backend tanpa field ini: semua banner tetap strip seperti sebelumnya; tanpa RPC `record_banner_event`: popup tetap jalan, event tidak tercatat.
- **Manual:** `showCommunityPromoPopup(context, banner)` menampilkan satu banner sebagai popup (tanpa aturan frekuensi), mis. untuk pratinjau di aplikasi admin; hasilnya `CommunityBannerEvent.click` atau `dismiss`.

## Pusat Bantuan / FAQ (server migrasi `0129`, gambar `0130`)

Artikel bantuan dua bahasa yang diatur tim Konten Layanan dari Hub (menu **Bantuan / FAQ**). Nasabah membukanya dari menu aplikasi host:

```dart
await openCommunityHelpCenter(context);   // halaman Pusat Bantuan (kategori, cari, artikel)

// atau ditanam di layar host
const CommunityHelpCenter();
CommunityHelpCenter(onContactSupport: (context, topic) => bukaPanelCs(topic));

// buka satu artikel langsung (misalnya dari notifikasi)
await openCommunityHelpArticle(context, article);
```

| Bagian | Perilaku |
|---|---|
| Kategori | Hanya kategori aktif yang punya artikel terbit, urut sesuai Hub, dengan ikon dari server (`account`, `wallet`, `shield`, dan seterusnya; sama dengan ikon topik chat CS) dan jumlah artikel. Ketuk kategori membuka daftar pertanyaannya |
| Pencarian | Mulai dari 2 huruf (maks. 100), dikirim 350 ms setelah berhenti mengetik ke `cs_api.faq_search` (maks. 20 hasil, urut kecocokan judul dan nilai membantu). Pencarian tanpa hasil dicatat server tanpa data pribadi sebagai bahan artikel baru. Batas laju server 30 per menit; bila terlampaui tampil pesan galat biasa |
| Artikel | Jawaban memakai Markdown terbatas: paragraf, **tebal**, *miring*, daftar berbutir dan bernomor, judul `#`, tautan `[teks](https://...)`, dan gambar `![alt](URL)` di baris sendiri. Tautan selain `https` tampil sebagai teks biasa; tautan dibuka lewat dialog konfirmasi domain yang sama dengan tautan di chat. Gambar hanya dimuat dari bucket publik `faq-images` (`/storage/v1/object/public/faq-images/<uuid>.jpg/png/webp`), tampil dengan sudut membulat (tinggi maks. 360 px), label aksesibilitas = teks alt, tidak bisa diketuk, dan diganti ikon gambar rusak bila gagal dimuat. HTML tidak pernah ditafsirkan. Membuka artikel memanggil `cs_api.faq_article`, yang mencatat jumlah dibaca untuk statistik Hub |
| "Apakah ini membantu?" | Tombol **Ya**/**Tidak** langsung tersimpan (satu suara per nasabah per artikel, bisa diganti). Setelah memilih, muncul kolom komentar opsional (maks. 500 huruf). Pilihan sebelumnya tampil lagi saat artikel dibuka. Batas laju server 20 per jam |
| "Masih butuh bantuan? Chat CS" | Ada di bawah setiap artikel, daftar kategori, dan hasil pencarian. Bawaannya membuka `openCommunitySupport(topic: <topik artikel>, screen: 'help_center')`, jadi tiket langsung dibuat dengan topik terkait (tanpa topik: halaman pilih topik). Host dengan panel CS sendiri mengisi `onContactSupport` |
| Saran sebelum chat | Di halaman pilih topik chat CS, setelah nasabah memilih topik, paket mengambil maks. 3 artikel teratas topik itu (`cs_api.faq_for_topic`, urut nilai membantu lalu jumlah dibaca) dan menampilkannya di bawah judul **"Mungkin ini membantu"** dengan tombol **Lanjut chat dengan CS** dan **Pilih topik lain**. Bila topik belum punya artikel, permintaan gagal, atau server tidak menjawab dalam 4 detik, tiket langsung dibuat seperti sebelumnya. Topik yang dikirim host lewat `openCommunitySupport(topic: ...)` tidak melewati langkah ini |
| Offline | Respons `cs_api.faq` terakhir yang berhasil disimpan per bahasa di cache lokal milik user (lihat [Offline](#offline-cache--outbox-130)). Saat dibuka, isi tersimpan tampil seketika lalu diganti data server. Bila server tidak terjangkau, isi tersimpan tetap dipakai dengan pemberitahuan kecil "Anda sedang offline…" dan tombol **Coba lagi**; pencarian dan artikel memakai isi tersimpan (tanpa umpan balik baru sampai online) |

Teks ID/EN mengikuti locale aplikasi; isi artikel mengikuti bahasa itu (`p_language`). Semua bagian bisa diganti lewat `CommunityHelpBuilders` (lihat [customization.md](customization.md#pusat-bantuan)).

## Bantuan lanjutan di chat CS (server migrasi `0134`–`0136`)

Semua isi diatur dari Hub (pertanyaan awal dan saran balasan per topik, pengumuman gangguan, survei kepuasan) dan dibaca dari server; library tidak menulis teks bisnis sendiri.

| Bagian | Perilaku |
|---|---|
| Pertanyaan awal per topik | `cs_api.topics` mengirim `intake` per topik (`text`, `number`, `date`, `choice`; wajib/opsional; maks. 8). Setelah nasabah memilih topik (dan setelah langkah saran artikel), form singkat **"Sebelum mulai chat"** tampil. Validasi sama dengan server: wajib diisi, maks. 200 karakter, angka `-?` 1–15 digit dengan maks. 4 desimal (titik atau koma), tanggal lewat pemilih tanggal (disimpan `YYYY-MM-DD`), pilihan harus salah satu opsi. Jawaban dikirim sebagai objek `p_intake` (`{key: nilai}`) ke `cs_api.open_ticket`; galat server `intake_required` dan `invalid_intake_answers` tampil sebagai pesan yang jelas dan form tetap terbuka. Topik tanpa isian langsung membuat tiket seperti sebelumnya. Topik dari `openCommunitySupport(topic: ...)` yang punya isian juga membuka form ini dulu |
| Status layanan / gangguan | `cs_api.support_home.incidents` (dan `cs_api.service_status(p_language)` untuk Pusat Bantuan dan untuk bahasa Inggris) tampil sebagai banner di chat CS dan halaman pilih topik (di bawah header) serta di atas Pusat Bantuan. Warna mengikuti tingkat: `info` biru, `warning` jingga, `critical` merah. Bila ada `faq_article_id`, tombol **Selengkapnya** membuka artikel itu di tampilan artikel Pusat Bantuan (hanya bila `HelpRepository` tersedia). Tombol tutup menyembunyikan banner selama sesi aplikasi (berlaku juga di Pusat Bantuan). Banner hilang saat server tidak lagi mengirimnya (dimuat ulang di titik refresh `support_home` yang sudah ada: event tiket realtime dan setelah aksi), dan langsung disembunyikan bila `ends_at` sudah lewat |
| Di luar jam layanan | Bila `service_open == false`, setelah nasabah memilih topik tampil langkah **"CS sedang di luar jam layanan"** berisi jam buka berikutnya, maks. 3 artikel FAQ topik itu (`cs_api.faq_for_topic`, widget saran 1.9.0) dan tombol **Tinggalkan pesan** yang tetap membuat tiket (lewat form pertanyaan awal bila topiknya punya isian) |
| Survei kepuasan | `support_home.survey` (`{"id": {...}, "en": {...}}`) mengatur dialog rating: pertanyaan, skala 3 (tiga wajah yang mengirim 1, 3, 5) atau 5 (bintang 1–5). Bila nilai ≤ `low_max`, pilihan alasan tampil sebagai chip (boleh lebih dari satu) dan dikirim sebagai `p_reasons` ke `cs_api.rate_ticket`. Tanpa `survey` dialog bintang lama tetap dipakai |
| Saran balasan nasabah | Selama tiket aktif, `quick_replies` dari tampilan tiket tampil sebagai chip di atas kolom ketik. Mengetuk chip mengirim teks itu lewat jalur kirim composer biasa (pesan optimistis, cooldown, dan unggahan yang sedang berjalan dihormati) |
| Perkiraan waktu tunggu | Tiket `open` menampilkan **"Perkiraan menunggu ± N menit"** dari `eta_minutes` di samping posisi antrean (header chat dan **Tiket saya**). Bila server belum tahu (`null`), hanya posisi antrean yang tampil |
| Unduh transkrip | Di **Tiket saya** (menu ••• chat CS, juga sebelum ada tiket) → buka tiket yang sudah selesai/ditutup → ikon **Unduh transkrip**. Library memanggil `cs_api.ticket_transcript` dan membuat file TXT UTF-8 (`transkrip-<nomor>.txt` / `transcript-<nomor>.txt`) berisi nomor tiket, topik, waktu dibuat/selesai/ditutup dalam zona waktu perangkat, label pengirim (Anda, nama CS, Sistem), pesan terhapus, dan nama lampiran. Windows/macOS/Linux memakai dialog simpan `file_selector`; Android/iOS memakai lembar bagikan `share_plus`; web mengunduh file. Host bisa mengganti penyimpanan lewat `CommunitySupportTickets(transcriptSaver: ...)` |

Server lama: tanpa `intake` tidak ada form; tanpa `incidents`/`service_status` tidak ada banner (RPC yang belum ada dianggap tanpa gangguan); tanpa `survey` dialog rating lama; tanpa `quick_replies`/`eta_minutes` tidak ada chip dan perkiraan. `p_intake` dan `p_reasons` hanya dikirim bila berisi, jadi pemanggilan ke server lama tetap cocok dengan tanda tangan RPC lama. Transkrip butuh `0136`.

## Pengaduan tamu sebelum login (server migrasi `0140`)

Nasabah yang tidak bisa masuk (lupa password/PIN, akun terkunci) bisa membuat pengaduan dari halaman login aplikasi host, **tanpa sesi dan tanpa OTP**. Pasang tombol **"Tidak bisa masuk? Hubungi CS"** yang memanggil `openCommunityGuestSupport(context)` (cara pemasangan ada di [integration.md](integration.md#pengaduan-tamu-dari-halaman-login)).

| Bagian | Perilaku |
|---|---|
| Form | Nama (2–60 karakter), Login ID opsional (otomatis huruf besar, hanya `A–Z`, angka, `.`, `_`, `@`, `-`, maks. 50), chip jenis masalah dari `cs_api.guest_config` (`password`, `pin`, `locked`, `other`; label sesuai bahasa), dan cerita masalah (10–1.000 karakter). Validasi sama dengan `cs_api.guest_start`; galat server (`invalid_*`, `rate_limited` 3/jam dan 10/hari per perangkat, `guest_login_limit` 5/hari per Login ID, `guest_disabled`) tampil sebagai pesan yang jelas |
| Catatan keamanan | Selalu tampil di form dan di awal percakapan: *"CS tidak pernah meminta password, PIN, atau OTP. Reset password/PIN hanya dikirim ke email yang terdaftar di akun Anda."* CS memang hanya bisa mengirim reset ke email akun, jadi nasabah tahu apa yang akan terjadi |
| Chat | Header berisi nomor pengaduan, topik, status, posisi antrean dan perkiraan waktu tunggu (sama dengan chat CS), serta tombol **Akhiri** (`cs_api.guest_end`, dengan konfirmasi). Pesan CS tampil dengan penanda **CS Resmi**, pesan sistem memakai tampilan pesan sistem chat CS. Nasabah hanya bisa mengirim teks (1–2.000 karakter); lampiran dari CS ditampilkan sebagai keterangan karena tamu tidak punya akses berkas |
| Pembaruan | `cs_api.guest_poll` setiap 4 detik selama halaman terlihat dan aplikasi aktif (berhenti saat aplikasi di latar belakang). Bila gagal, jeda naik 8, 16, 32 sampai maks. 60 detik dan banner **"Koneksi terputus. Mencoba lagi…"** tampil; kembali ke 4 detik setelah berhasil |
| Akhir | Tiket `resolved`/`closed`, sesi kedaluwarsa (`guest_session_expired`), atau nasabah menekan **Akhiri** → kolom ketik diganti panel akhir dengan tombol **Buat pengaduan baru**. Polling berhenti dan token dihapus |
| Token | Token sesi (berlaku `session_hours`, bawaan 24 jam) disimpan di memori lewat `CommunityGuestSessionStore`. Bawaannya `MemoryGuestSessionStore`: nasabah bisa menutup dan membuka lagi halaman selama aplikasi berjalan, tetapi percakapan hilang bila aplikasi ditutup (teks di header memberi tahu ini). Cache lokal paket terikat ke akun yang login, jadi tidak dipakai sebelum login. Host yang ingin nasabah bisa kembali dalam 24 jam memasang store sendiri, misalnya di penyimpanan aman (lihat [integration.md](integration.md#pengaduan-tamu-dari-halaman-login)) |

Semua panggilan memakai **anon key** (`Authorization: Bearer <ANON_KEY>`, skema `cs_api`), tidak pernah token sosial, dan tidak memicu penukaran token OLT, meskipun `RendezvousCommunity` sudah diinisialisasi. Token tamu tidak pernah ditulis ke log. Di server lama tanpa `0140` (`cs_api.guest_config` belum ada) halaman menampilkan *"Pengaduan tanpa login sedang tidak tersedia…"*, sama seperti saat Super Admin mematikan `guest.enabled` dari Hub.

## Kelola grup (1.17.0, server migrasi `0146`)

Grup memakai peran `owner` (pembuat), `admin`, dan `member`. Header room grup membuka **Info grup**: foto, nama, deskripsi, pengaturan (khusus admin), daftar anggota dengan label peran, tambah anggota, dan keluar grup. Menu tiap anggota menyesuaikan peran:

| Aksi | Owner | Admin | Member |
|---|---|---|---|
| Tambah anggota, jadikan admin | ya | ya | tidak |
| Keluarkan anggota biasa | ya | ya | tidak |
| Keluarkan admin, cabut status admin | ya | tidak | tidak |
| Pindahkan kepemilikan | ya | tidak | tidak |
| Ubah nama/deskripsi/foto | ya | ya | bila "Hanya admin yang bisa mengubah info grup" dimatikan |
| Pengaturan grup | ya | ya | tidak |
| Kirim pesan | ya | ya | bila "Hanya admin yang bisa mengirim pesan" dimatikan |

Setiap perubahan tercatat sebagai pesan sistem (`MessageKind.groupEvent`) yang tampil di tengah chat dalam bahasa aplikasi dan tidak mengirim push notification. Anggota yang dikeluarkan langsung kehilangan akses ke riwayat grup.

## Offline: cache & outbox (1.3.0)

Bawaannya aktif. Paket menyimpan data terakhir di database lokal milik user komunitas yang sedang masuk, lalu menampilkannya seketika saat layar dibuka; data server dimuat di latar belakang dan menggantikannya (server tetap sumber kebenaran).

```dart
await RendezvousCommunity.initialize(
  // ...
  offlineCache: true,          // false: perilaku lama, tanpa database lokal dan tanpa outbox
  offlineMessageLimit: 200,    // pesan terakhir yang disimpan per room
);

await RendezvousCommunity.instance.clearLocalCache();   // hapus cache & antrean user ini (sesi tetap)
RendezvousCommunity.instance.connectivity.online;       // ValueListenable<bool> untuk UI host
const CommunityOfflineBanner();                          // banner "Anda sedang offline" untuk layar host
```

| Data | Yang disimpan | Batas |
|---|---|---|
| Daftar chat | halaman pertama `get_my_rooms` (tanpa room CS) | 30 room |
| Pesan | baris `get_messages` yang pernah dimuat, pesan terkirim | `offlineMessageLimit` per room, yang terlama dipangkas |
| Feed | halaman pertama Terbaru, Mengikuti, dan feed saham | 20 feed saham terakhir; profil, hashtag, bookmark tidak |
| Outbox | pesan teks yang belum terkirim (`client_id`, isi, balasan) | sampai terkirim, dihapus user, atau logout |
| Pusat Bantuan | respons `cs_api.faq` terakhir per bahasa (kategori dan artikel terbit, tanpa umpan balik) | satu salinan per bahasa, ditimpa tiap kali berhasil dimuat |

- **Sinkron:** baris server menimpa baris cache (edit, hapus, reaksi, `moderation_status`). Pesan yang tidak lagi dikembalikan server dalam rentang halaman yang sama dihapus dari cache. Saat koneksi kembali, layar yang masih menampilkan data tersimpan memuat ulang sendiri.
- **Outbox:** pesan teks yang dikirim saat offline atau gagal karena jaringan tampil "Menunggu dikirim" lalu dikirim ulang otomatis (backoff 2 detik sampai 1 menit, langsung saat koneksi kembali, aplikasi kembali ke foreground, atau realtime tersambung). Urutan per room dijaga; `client_id` membuat server menolak duplikat. Penolakan server (`content_blocked`, `dm_request_limit`, persetujuan dokumen, `slow_mode` setelah 3 percobaan, dll.) membuat pesan "Gagal terkirim" dengan alasannya dan tombol **Coba lagi** / **Hapus**.
- **Lampiran:** gambar, dokumen, dan video butuh media gateway, jadi tidak masuk antrean. Saat offline paket menolak dengan pesan "Gambar dan dokumen hanya bisa dikirim saat online."
- **Status koneksi:** dinilai dari hasil request ke server dan status realtime (tanpa plugin konektivitas). Saat offline, paket memeriksa ulang lewat `get_client_config` (5 detik, naik sampai 1 menit). Banner offline tampil di daftar chat, room chat (builder `connectionBanner`, `CommunityConnectionDetails.offline`), dan feed.
- **Buka aplikasi tanpa jaringan:** database dibuka bila token OLT dari `tokenProvider` milik user OLT yang sama dengan sesi terakhir (dicocokkan lewat hash SHA-256 `iss`+`sub`, tanpa jaringan). Token yang tidak bisa dibaca berarti tidak ada cache sampai online.
- **Web:** cache dan outbox hanya di memori (hilang saat halaman dimuat ulang), sehingga host web tidak perlu menyediakan `sqlite3.wasm`.

**Privasi.** Satu database per user komunitas (`<application support>/rendezvous_community/<user id>.sqlite`). Database dihapus saat `signOut()`, `deleteMyAccount()`, `clearLocalCache()`, saat sesi komunitas berganti ke user lain, dan saat aplikasi dibuka offline oleh user OLT lain. Token sosial maupun token OLT tidak pernah disimpan. **Chat CS tidak di-cache**: riwayatnya berisi verifikasi identitas dan data akun, dan aksesnya sudah lewat jalur `cs_api` sendiri, jadi selalu dimuat dari server. Panggil `signOut()` saat user keluar dari OLT supaya data komunitasnya hilang dari perangkat.

## Push transaksi OLT

Push dari backend OLT (`/integration/v1/notify/messages`) berisi `source: "olt"`, `kind` berawalan `olt.` (`olt.trade`, `olt.funds`, `olt.market`, `olt.info`, `olt.promo`), `category`, `message_id`, `cust_id`, `notification_id`, dan isi `data` dari OLT (mis. `screen`, `order_id`). Pesan yang sama juga masuk ke kotak notifikasi. Daftarkan `onOltNotificationTap` di `initialize` supaya ketukan di kotak notifikasi (payload lengkap: `kind`, `category`, `message_id`, `title`, `body`, `data`, `notification_id`) dan `openCommunityPush` untuk push OLT diteruskan ke router OLT; notifikasinya ditandai terbaca otomatis:

```dart
await RendezvousCommunity.initialize(
  // ...
  onOltNotificationTap: (context, data) => oltRouter.openOltMessage(data),
);
```

Tanpa callback itu, `openCommunityPush` mengembalikan `false` untuk push OLT supaya app OLT yang membuka layarnya sendiri:

```dart
if (isOltPush(message.data)) return oltRouter.openTradePush(message.data);
if (isCommunityPush(message.data)) openCommunityPush(context, message.data);
```

