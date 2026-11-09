## 1.10.0

Server: lampiran dokumen/video butuh migrasi `0131`–`0132` (layanan media 0.3.0 + ClamAV); fitur bantuan lanjutan butuh `0133`–`0136`. Di server lama fitur baru tidak tampil dan perilaku tetap seperti 1.9.0. **Perubahan antarmuka:** host yang mengimplementasikan sendiri `SupportRepository` atau `MediaRepository` perlu menambah metode baru (`attachmentPolicy`, `uploadSupportFile`, `serviceStatus`, `transcript`); `Fake`/`Mock` bawaan sudah diperbarui.

Server: fitur bantuan lanjutan butuh migrasi `0134`–`0136`. Di server lama semuanya mundur ke perilaku 1.9.0 (tanpa form, banner, survei, saran balasan, dan perkiraan waktu tunggu); transkrip butuh `0136`.

* **Bantuan lanjutan di chat CS** (diatur dari Hub, lihat [doc/features.md](doc/features.md#bantuan-lanjutan-di-chat-cs-server-migrasi-01340136)).
  * **Pertanyaan awal per topik**: setelah memilih topik (dan setelah saran artikel), topik yang punya isian
    menampilkan form singkat (teks, angka, tanggal lewat pemilih tanggal, pilihan; wajib/opsional) dengan validasi
    sama seperti server. Jawaban dikirim sebagai `p_intake` ke `cs_api.open_ticket`; galat `intake_required` dan
    `invalid_intake_answers` tampil dengan pesan yang jelas. Topik tanpa isian tetap langsung membuat tiket.
  * **Banner gangguan layanan** di chat CS, halaman pilih topik, dan Pusat Bantuan: warna per tingkat (`info`,
    `warning`, `critical`), tombol **Selengkapnya** ke artikel FAQ terkait, bisa ditutup per sesi, dan hilang saat
    server tidak lagi mengirimnya.
  * **Di luar jam layanan**: setelah memilih topik tampil jam buka berikutnya, saran artikel FAQ topik itu, dan tombol
    **Tinggalkan pesan** yang tetap membuat tiket.
  * **Survei kepuasan dari server**: pertanyaan, skala 3 (tiga wajah = 1, 3, 5) atau 5 (bintang), dan chip alasan
    untuk nilai rendah yang dikirim sebagai `p_reasons` ke `cs_api.rate_ticket`. Tanpa survei, dialog lama.
  * **Saran balasan nasabah**: chip di atas kolom ketik selama tiket aktif; diketuk = dikirim lewat composer biasa.
  * **Perkiraan waktu tunggu**: "Perkiraan menunggu ± N menit" di samping posisi antrean.
  * **Unduh transkrip** (TXT) untuk tiket selesai/ditutup dari **Tiket saya** (`cs_api.ticket_transcript`): nomor
    tiket, topik, waktu lokal, label pengirim, dan nama lampiran. Dialog simpan di desktop, lembar bagikan di
    Android/iOS, unduhan di web. **Tiket saya** tetap ada di menu ••• chat CS, juga sebelum ada tiket.
  * Builder baru di `CommunitySupportBuilders`: `incidentBanner` (`CommunitySupportIncidentDetails`), `intakeForm`
    (`CommunitySupportIntakeDetails`), `intakeField` (`CommunitySupportIntakeFieldDetails`), `surveyReasons`
    (`CommunitySupportSurveyReasonsDetails`), `replySuggestions` (`CommunitySupportReplySuggestionsDetails`).
    `CommunitySupportRatingDetails` mendapat `survey`, `values`, `faces`, `ratingLabels`, `asksReasons`,
    `selectedReasons`, `onToggleReason`, `reasons`; `CommunitySupportPageHeaderDetails` mendapat `downloadLabel`,
    `onDownload`, `downloading`, `canDownload`; `CommunityHelpSuggestionsDetails` mendapat `notice` dan `outOfHours`.
  * API: `SupportIntakeField`, `SupportIntakeOption`, `SupportIntakeType`, `SupportTopic.intake`/`hasIntake`,
    `SupportIncident`, `SupportIncidentLevel`, `SupportSurvey`, `SupportSurveyReason`, `SupportHome.incidents`,
    `SupportHome.surveys` + `survey(bahasa)`, `SupportTicket.etaMinutes` dan `quickReplies`, `SupportTranscript`,
    `SupportTranscriptMessage`, `SupportTranscriptSender`, validasi `validateSupportIntake`,
    `checkSupportIntakeAnswer`, `supportIntakePayload`, `SupportIntakeProblem`, format `formatSupportTranscript`,
    `SupportTranscriptLabels`, `SupportTranscriptFile`, `CommunityTranscriptSaver`, `saveSupportTranscript`,
    `supportTranscriptFile`, `CommunitySupportTickets(transcriptSaver:)`, `CommunityHelpCenter(support:)`.
  * Antarmuka yang berubah (implementasi host perlu ikut menyesuaikan, `Fake`/`Mock` tidak terpengaruh):
    `SupportRepository.openTicket(..., intake)`, `rateTicket(..., reasons)`, metode baru `serviceStatus()` dan
    `transcript()`.

Server: daftar format lampiran butuh migrasi `0131` dan layanan `media` yang sudah memeriksa dokumen Office dan video. Di server lama (tanpa `cs_api.attachment_policy`) chat CS tetap menerima gambar dan PDF seperti 1.9.0.

* **Lampiran dokumen lain dan video di chat CS** (format dan batas diatur Super Admin dari Hub, dibaca dari server).
  * Pemilih file chat CS menampilkan grup **Foto**, **Video**, dan **Dokumen** hanya untuk jenis yang aktif. Bawaan
    server: PDF, Word `.docx`, Excel `.xlsx`, PowerPoint `.pptx`, `.txt`, `.csv` (10 MB); MP4, MOV, WebM (25 MB,
    2 menit). Format dan ukuran dicek sebelum unggah dengan pesan yang jelas, misalnya "makro.docm tidak bisa dikirim.
    Format yang diterima: …". Grup pemilih kini selalu membawa UTI, sehingga pemilih file iOS tidak lagi gagal.
  * Selama layanan `media` memindai antivirus dan memproses video, composer menampilkan **"Memeriksa file…"**.
  * Kartu dokumen per jenis (ikon dan label PDF, Word, Excel, PowerPoint, CSV, Teks) dengan nama asli dan ukuran.
    Diketuk: di Windows, macOS, dan Linux file diunduh ke folder sementara lalu dibuka aplikasi bawaan (juga untuk
    PDF); di Android, iOS, dan web signed URL dibuka seperti sebelumnya.
  * Gelembung video dengan thumbnail dari server, durasi, dan ukuran. Android, iOS, macOS, dan web memutar di aplikasi
    (`CommunityVideoPlayerPage`, layar penuh, jeda dan geser); Windows dan Linux mengunduh video lalu membukanya di
    pemutar bawaan sistem. Tidak memakai `media_kit`.
  * Foto **HEIC/HEIF** diubah ke JPEG di perangkat sebelum dikirim (juga di chat biasa): didekode dekoder platform,
    diperkecil ke 3072 px, di-encode JPEG 85 di isolate. Di perangkat yang tidak bisa mendekode HEIC (Windows, Linux,
    Android < 9, sebagian browser) muncul pesan agar foto disimpan sebagai JPEG dulu.
  * Pesan galat baru (ID/EN) untuk `kind_disabled`, `policy_unavailable`, `office_macro`, `office_unsafe`,
    `archive_bomb`, `invalid_text`, `invalid_video`, `video_too_long`, `malware_detected`, `scanner_unavailable`,
    `attachment_too_large`, `attachment_too_long`; teks `unsupported_type`, `file_too_large`, dan
    `attachment_not_allowed` diperbarui.
  * Builder: slot baru `CommunityChatBuilders.video` (`CommunityVideoDetails`). `CommunityDocumentDetails` (slot
    `feed.document`) mendapat `type` (`CommunityDocumentType`) dan `typeLabel`. `CommunityComposerDetails` mendapat
    `attachmentPolicy`, `attachLabel`, dan `uploadingLabel`.
  * API: `CommunityAttachmentPolicy` (`legacy`, `imagesOnly`, `fromJson`, `match`), `CommunityAttachmentRule`,
    `CommunityAttachmentFormat`, `CommunityAttachmentKind`, `CommunityDocumentType` + `documentTypeOf`,
    `CommunityFileOpener`, `communityVideoPlaysInApp`, `communityOpensDownloadedFiles`, `CommunityVideoPlayerPage` +
    `showCommunityVideoPlayer`. `Attachment` punya `duration`, `thumbnail`, `isVideo`, dan `isImage`; `isDocument`
    kini `false` untuk video. `ChatOutgoingFile` punya `kind`, `format`, dan `video`.
  * Antarmuka yang bertambah metode (implementasi host perlu ikut menambah, `Fake`/`Mock` tidak terpengaruh):
    `SupportRepository.attachmentPolicy()` dan `MediaRepository.uploadSupportFile(...)`. `SupportState` punya
    `attachmentPolicy`; `MessageComposer` punya `attachmentPolicy` dan `openFilesPicker`.
  * Dependensi baru: `video_player` (BSD-3) dan `image` (MIT, Dart murni; membawa `archive` MIT). Android tidak butuh
    izin storage; catatan platform ada di [doc/integration.md](doc/integration.md#2-konfigurasi-platform).

## 1.9.0

Server: semua fitur baru butuh migrasi sampai `0130`. Library ini tetap jalan di server lama: topik memakai pemetaan bawaan dan saran FAQ di halaman pilih topik dilewati bila RPC belum ada.

* **Pusat Bantuan / FAQ** (server migrasi `0129`, gambar jawaban `0130`): `CommunityHelpCenter` dan
  `openCommunityHelpCenter(context)` menampilkan kategori, pencarian, dan artikel bantuan dua bahasa yang diatur dari
  Hub (**Konten Layanan → Pusat Bantuan**). Jawaban memakai Markdown terbatas (tebal, miring, daftar, judul, tautan hanya `https`, gambar
  hanya dari bucket `faq-images`) lewat `CommunityHelpMarkdown`, tanpa paket tambahan dan tanpa HTML.
  * "Apakah ini membantu?" **Ya**/**Tidak** dengan komentar opsional (maks. 500 huruf); pilihan sebelumnya tampil
    lagi saat artikel dibuka.
  * Tombol "Masih butuh bantuan? **Chat CS**" membuka chat CS dengan topik artikel (`openCommunitySupport(topic: ...,
    screen: 'help_center')`), atau `onContactSupport` milik host. `openCommunityHelpArticle(context, article)` membuka
    satu artikel langsung.
  * Di halaman pilih topik chat CS, setelah topik dipilih, maks. 3 artikel teratas topik itu tampil di bawah
    **"Mungkin ini membantu"** dengan pilihan **Lanjut chat dengan CS** atau **Pilih topik lain**. Bila tidak ada
    artikel, permintaan gagal, atau lebih dari 4 detik, tiket langsung dibuat seperti sebelumnya.
  * Offline: respons FAQ terakhir disimpan per bahasa di cache lokal user, jadi Pusat Bantuan tetap terbuka (dengan
    pemberitahuan kecil dan tombol **Coba lagi**); pencarian memakai isi tersimpan.
  * Builder baru `CommunityBuilders.help` (`CommunityHelpBuilders`: `searchField`, `categoryTile`, `articleTile`,
    `articleDetail`, `feedback`, `contact`, `offlineNotice`, `topicSuggestions`, `loading`, `empty`, `error`).
  * API: `HelpRepository` (`RendezvousCommunity.instance.help`), entitas `HelpCenterContent`, `HelpCategory`,
    `HelpArticle`, `HelpFeedback`, serta `CommunityHelpScope`/`CommunityHelpDependencies` untuk host dan tes.
    `CommunitySupportScope.maybeOf` ditambahkan.

* **Pengaturan geser untuk membalas oleh host:** `CommunitySwipeToReplyScope` dengan `CommunitySwipeToReplySettings`
  (`enabled`, `threshold` dalam px, arah `mine`/`others` berupa `CommunitySwipeDirection.right`/`left`, `haptic`).
  Bawaan tetap: aktif, 56 px, kanan untuk semua pesan, dengan getar. Contoh gaya WhatsApp iOS:
  `CommunitySwipeToReplySettings(mine: CommunitySwipeDirection.left)`. Pasang sekali, misalnya di `MaterialApp.builder`.

* **Tanggal mengambang saat menggulir chat** ala WhatsApp: saat daftar pesan digulir ke pesan lama, label hari pesan
  teratas yang terlihat ("Hari ini", "Kemarin", nama hari, atau tanggal) menempel di tengah atas daftar, lalu memudar
  sendiri 1,5 detik setelah guliran berhenti (muncul 150 ms, hilang 300 ms). Tidak muncul di posisi pesan terbaru dan
  disembunyikan saat pemisah tanggal asli sedang tepat di atas. Slot builder `CommunityChatBuilders.floatingDate`
  (`CommunityDayDetails`, sama dengan `dayDivider`).

* **Topik chat CS sepenuhnya dari server** (server migrasi `0127`): deskripsi, ikon, dan gaya setiap topik, serta judul
  dan petunjuk halaman pilih topik, diatur dari Hub (Konten Layanan → Topik chat CS). Tampilan bawaan menampilkan
  deskripsi di bawah nama, ikon dari server, dan nama merah untuk gaya `danger`. Host tidak perlu lagi menulis
  deskripsi atau ikon sendiri di builder `topicTile`.
  * `SupportTopic`: `description`, `icon` (kunci, misalnya `account`, `wallet`, `shield`), `style` (`normal`/`danger`),
    getter `danger`. `CommunitySupportTopicDetails.danger`. `supportTopicIconFor(topic)` memetakan kunci ke `IconData`;
    tanpa kunci (server lama) tetap memakai pemetaan per kode.
  * `SupportHome.topicPicker` (`SupportTopicPickerTexts` dengan `title`/`hint` per bahasa), `topicTitle(bahasa)`,
    `topicHint(bahasa)`. Kosong = teks bawaan library.

* **Email, nomor telepon, dan alamat `www.` di teks bisa diketuk** (postingan, komentar, chat, dan chat CS).
  * Email menjadi `mailto:`, nomor telepon Indonesia (`08…`, `+62…`, `021-…`, minimal 10 digit, boleh dipisah
    spasi atau `-`) menjadi `tel:`. Saat diketuk muncul pilihan **Kirim email**/**Telepon** atau **Salin**
    (`showCommunityContactActions`, slot `CommunitySharedBuilders.contactActions` dengan
    `CommunityContactActionsDetails`). Tanggal, nomor tiket, dan nomor rekening yang tidak diawali `0` tidak ikut.
  * `www.contoh.co.id` tanpa `https://` dibuka sebagai `https://`, tetap lewat dialog konfirmasi tautan.
  * Chat CS kini memakai `SocialText` (tanpa mention, cashtag, dan hashtag), sehingga tautan, email, dan telepon di
    pesan CS ikut bisa diketuk. Salin teks tetap lewat menu pesan.
  * `parseSocialText` punya parameter opsional `contacts` (bawaan `false`; email/telepon muncul sebagai
    `LinkSegment` dengan skema `mailto:`/`tel:`), `cashtags`, dan `mentions` (bawaan `true`). `SocialText` punya
    `contacts`, `cashtags`, dan `mentions` (bawaan `true`). Tidak ada jenis segmen baru, jadi `switch` lama tetap jalan.

* **Geser untuk membalas ala WhatsApp.** Di layar sentuh, gelembung pesan (milik sendiri maupun orang lain) bisa
  digeser ke kanan: ikon balas muncul perlahan, getar halus saat melewati ambang 56 px, dan saat dilepas pesan itu
  dibalas lalu kolom input langsung fokus. Geser pendek, geser ke kiri, atau drag mouse tidak memicu balasan, jadi
  memilih teks dengan mouse di desktop tetap bisa. Berlaku juga untuk gelembung dari builder `chat.message`.

## 1.8.0

* **Header halaman turunan chat CS bisa diganti.** Slot builder baru `CommunitySupportBuilders.pageHeader`
  (`CommunitySupportPageHeaderDetails`: `title`, `subtitle`, `ticket`, `onBack`, `onClose`) dipakai halaman
  **Tiket saya** dan transkrip tiket, sehingga host yang menampilkan `CommunitySupportChat` di panel samping bisa
  menyamakan gaya header dan menambah tombol tutup panel. Tanpa builder, header tetap `AppBar` bawaan, kini dengan
  tombol tutup bila `CommunitySupportChat.onClose` diisi.
  * `onClose` milik `CommunitySupportChat` diteruskan ke kedua halaman itu (`CommunitySupportPageHeaderDetails.onClose`).
  * Transkrip memisahkan judul dan nomor tiket: judul = nama topik, `subtitle` = `#nomor` (sebelumnya digabung
    `nomor · topik` di judul), dan `ticket` berisi tiket yang dibuka.
  * Halaman tetap dibuka di navigator terdekat (`Navigator.of(context)`), jadi navigasi tetap di dalam panel host.
  * Halaman **Tiket saya** kini ikut membawa `CommunitySupportScope` dari chat CS yang membukanya.

## 1.7.0

* **Tombol ke pesan terbaru** ala WhatsApp: lingkaran ⌄ di kanan bawah daftar pesan muncul saat posisi menjauh
  dari pesan terbaru, dengan badge jumlah pesan masuk selama itu (`99+`); sekali tekan langsung ke bawah. Slot builder
  `CommunityChatBuilders.jumpToLatest` (`CommunityJumpToLatestDetails`).

* **Info pesan ala WhatsApp.** Desktop/tablet (≥ 600 px): panel kecil di samping gelembung (bukan dialog), bagian
  **DIBACA**/**TERKIRIM** (grup: **DIBACA OLEH**/**TERKIRIM KE**) dalam kotak membulat, `•••` selama memuat atau bila
  belum ada, tutup dengan klik di luar atau Esc. Ponsel: halaman **Info pesan** penuh (tombol kembali) dengan gelembung
  pesan di atas dan kartu Dibaca/Terkirim beserta waktu, atau daftar pembaca grup dengan avatar.
  `CommunityMessageInfoDetails.anchored`, `showCommunityMessageInfo(context, message, anchor:)`.

* **Kolom input tetap rapi di desktop:** `CommunityComposerField` memakai kepadatan visual standar, sehingga kolom
  input chat/postingan/komentar tetap setinggi 48 px dengan teks di tengah walau aplikasi memakai `VisualDensity.compact`
  (bawaan Flutter di Windows, macOS, dan Linux). Sebelumnya teks turun sekitar 5 px.

* **Pesan sistem chat CS mengikuti bahasa aplikasi** (server migrasi `0123`): server menyimpan teks setiap pesan
  sistem tiket dalam Bahasa Indonesia dan Inggris (`payload.texts`, templat dari Pengaturan → Pesan otomatis, tanggal
  diformat per bahasa); `SupportSystemNotice` memilih sesuai `Localizations.localeOf(context)` dan ikut berganti saat
  bahasa diganti. Pesan lama tanpa terjemahan tetap memakai `body`. `supportNoticeText(message, languageCode)`.

* **Chat: balas pesan dan tempel gambar ala WhatsApp** (tanpa naik versi; API lama tidak berubah, semua tambahan
  opsional).
  * Composer: kolom input dan tombol kirim sama tinggi (48 px) dan sejajar; kartu "sedang membalas" di dalam kolom input
    dengan garis warna pengirim, nama tampilan, cuplikan (ikon untuk foto/dokumen), dan tombol tutup.
  * Kutipan di gelembung menampilkan nama tampilan pengirim (bukan `@username`, termasuk nama CS) dan "Anda" untuk pesan
    sendiri. Mengetuk kutipan menggulir ke pesan asli lalu menyorotnya sebentar; halaman lama dimuat bila perlu.
  * Hover tidak lagi melebarkan atau menyempitkan gelembung: ruang aksi selalu tetap.
  * Tempel gambar dengan Ctrl+V/⌘V (paket `pasteboard`, Apache-2.0) atau dari keyboard Android; BMP dari clipboard
    Windows diubah ke PNG dan diperkecil bila > 5 MB. Tanpa gambar di clipboard, teks ditempel seperti biasa.
  * Lampiran tidak langsung terkirim, seperti di web Hub: gambar/PDF dari pemilih file (bisa beberapa sekaligus),
    tempel, atau keyboard masuk antrean di atas kolom input (thumbnail 56 px atau kartu PDF dengan nama dan ukuran,
    masing-masing bisa dihapus), maksimal 4 per pesan, lalu dikirim bersama teks dalam satu pesan saat Enter/tombol
    kirim. Antrean tetap ada bila unggahan gagal. `ChatRoomCubit.sendWithFiles`, `ChatOutgoingFile`,
    `CommunityComposerDetails.files`/`onRemoveFile`.
  * Ikon tombol lampiran: klip kertas bila PDF diizinkan (chat CS), ikon gambar bila hanya gambar.
  * Setelah mengirim pesan, daftar chat menggulir sekali ke pesan terbaru (juga saat sedang membaca pesan lama).
  * Penampil gambar bergaya Google Chat: bar atas berisi avatar, nama pengirim, dan waktu kirim; tombol Perkecil,
    Perbesar, Balas, Beri reaksi, Salin gambar (ke clipboard), Unduh, menu ⋮ (Putar, Ukuran pas layar), dan Tutup
    dengan ikon outline yang seragam; panah bulat di tepi layar; toast "Gambar disimpan/disalin" di dalam penampil;
    pintasan ←/→, +/−, 0, Esc. Penampil gambar layar penuh: ketuk foto di gelembung chat atau di Info pesan untuk membuka; zoom (cubit/scroll),
    geser atau ←/→ antar foto, Esc/✕ menutup, tombol **Unduh** (desktop: dialog Simpan sebagai; ponsel: lembar
    berbagi untuk menyimpan; web: unduhan browser) memakai cache gambar yang sama. Info pesan kini menampilkan foto
    dan PDF pesan. `showCommunityImageViewer`, slot `CommunitySharedBuilders.imageViewer`
    (`CommunityImageViewerDetails`), `AttachmentGrid(onOpen:)`.
  * Teks chat bisa diseleksi dengan mouse dan disalin di desktop dan web (`SelectionArea` meliputi header room,
    pesan, kutipan, pesan sistem, header chat CS, dan Info pesan; kolom input tidak). Di ponsel tekan lama tetap
    membuka menu aksi berisi Salin.
  * Detail builder baru: `CommunityMessageDetails.replyToName`/`onReplyTap`, `CommunityComposerDetails.replyToName`/
    `onPaste`/`onContentInserted`. Aplikasi host perlu build ulang penuh (plugin native baru), bukan hot reload.
  * **Info pesan** ala WhatsApp (server migrasi `0122`, RPC `get_message_info`): waktu terkirim dan dibaca per penerima
    untuk pesan sendiri di DM, grup, dan chat CS; dialog di desktop, bottom sheet di ponsel, ikut diperbarui saat tanda
    terima berubah. Slot builder `CommunityChatBuilders.messageInfo` (`CommunityMessageInfoDetails`), entitas
    `MessageInfo`/`MessageRecipientInfo`, dan antarmuka `MessageInfoRepository` (terpisah dari `ChatRepository`, jadi
    implementasi host tidak rusak).
  * Menu ⋮ saat hover (Balas, Salin, Info pesan, Laporkan, Hapus) dan entri Salin/Info pesan di menu tekan lama.
    `CommunityMessageDetails.onCopy`/`onInfo`.

* **Tampilan bawaan baru: editorial + pola feed/chat umum.** Hanya tampilan; fungsi, perilaku, navigasi, dan API lama
  tidak berubah (semua tambahan opsional). Warna aksen tetap dari `ColorScheme.primary` aplikasi host. Rincian:
  [doc/design.md](doc/design.md).
  * **Token desain** `CommunityStyle` (`ThemeExtension`, diturunkan dari `ThemeData` host bila tidak dipasang):
    latar, permukaan, border, divider, teks primer/sekunder/tersier, pil, chip, skeleton, `sectionGap` — semuanya
    mengikuti tema host (`scaffoldBackgroundColor`, `ColorScheme`), tanpa warna yang dipatok, plus
    `CommunitySpacing`, `CommunityRadii`, `CommunityTypography`, `CommunityAvatarSizes` (tambahan `post`, `comment`,
    `reply`, `profile`). Mode terang dan gelap, kontras teks AA diuji. `CommunityTheme.of` kini di-cache per tema.
  * **Komponen dasar** (diekspor, masing-masing punya slot builder): `CommunityCard`, `CommunityAuthorRow`,
    `CommunityActionPill`/`CommunityActionButton`/`CommunityActionBar`, `CommunitySectionHeader`, `CommunityDivider`,
    `CommunityTag`, `CommunityLoadingView`, `CommunitySkeletonBox`, `CommunityBump`, `EditorialSection`.
  * **Feed & post**: post selebar layar (tanpa margin/border/radius) dipisah jalur `sectionGap`; baris pertama pendek
    tampil sebagai judul; isi dipotong 4 baris dengan "Baca lebih lanjut"; gambar full-bleed dengan rasio terjaga dan
    grid 2×2 "+N" (`AttachmentGrid(edgeToEdge: true)`); pil "Suka · N" dengan animasi sekali jalan dan haptic; detail
    dengan chip topik di atas judul dan bar aksi menempel; chip `$KODE`/`#hashtag` tidak lagi dobel di feed.
  * **Komentar** bergelembung dengan baris "waktu · Suka · Balas", indentasi balasan dengan garis tipis
    (`CommunityTheme.threadIndent` bawaan 16 → 40).
  * **Profil**: avatar besar, statistik ringkas (post, pengikut, mengikuti), bio, tombol Ikuti dan Kirim pesan sama
    lebar. **Pencarian**: chip filter, hasil berikon. **Compose**: header penulis, field lega, alat berlabel.
  * **Chat**: gelembung sendiri terisi aksen (gelap: `primaryContainer`), pengelompokan pesan berurutan, avatar dan nama
    pengirim per grup, waktu + centang di dalam gelembung, reaksi menumpang di sudut gelembung, pemisah tanggal berupa
    pil, indikator mengetik tiga titik (berhenti sendiri, mati bila animasi dinonaktifkan), composer berbentuk pil dengan
    tombol kirim bulat. Daftar room: avatar 52, belum dibaca ditebalkan, badge aksen.
  * **Chat CS**: pesan sistem sebagai kartu kecil, quick reply berupa pil, kartu rating baru.
  * **Notifikasi**: avatar dengan ikon jenis di pojok, nama pelaku tebal, bagian "Baru"/"Sebelumnya" berdasarkan status
    baca, latar lembut untuk yang belum dibaca.
  * **State kosong/error/loading**: ikon besar berlatar aksen lembut, judul opsional (`CommunityEmptyView(title:)`),
    skeleton statis berbentuk post/komentar (tanpa animasi berulang).
  * Halaman pengaturan, akun, banding, legal, dan banner sistem/persetujuan/offline mengikuti gaya yang sama;
    `CommunityConsentBanner` bawaan kini selebar penuh (`margin: EdgeInsets.zero`).
* **Builder untuk semua bagian visual.** Pola tetap `CommunityPartBuilder<T>` = `(context, details, fallback)`.
  * Set baru: `CommunitySharedBuilders` (komponen dan widget bersama), `CommunityDiscoveryBuilders` (pencarian, hashtag,
    trending), `CommunitySupportBuilders` (chat CS dan tiket), `CommunitySettingsBuilders` (akun, privasi DM, banding,
    legal), `CommunitySystemBuilders` (banner, kill switch, offline, persetujuan); semuanya lewat
    `CommunityBuilders(shared:, discovery:, support:, settings:, system:)`.
  * Slot baru di set lama: `CommunityFeedBuilders` (+18, mis. `postMenu`, `feedTabs`, `composeToolbar`,
    `attachmentImage`, `replyComposer`, `composeAuthor`), `CommunityChatBuilders` (+18, mis. `messageActions`,
    `reactions`, `receipt`, `roomNotice`, `shareTarget`, `requestTile`), `CommunityProfileBuilders` (`menu`,
    `messageButton`), `CommunityNotificationBuilders` (`icon`, `section`).
  * Inventaris lengkap per widget: [doc/builders.md](doc/builders.md); contoh: [doc/customization.md](doc/customization.md).
* **Perlu diperhatikan host:** warna gelembung dan badge belum dibaca bawaan berubah (pasang `CommunityTheme` sendiri
  untuk mempertahankan warna lama); ikon suka kini hati (`favorite_border`/`favorite`) dengan warna aktif baru
  `CommunityTheme.like` (bawaan `#E0245E`, gelap `#FF5C8A`) dan `CommunityActionPill(activeColor:)`; `CommunityTheme.threadIndent` bawaan 40; teks
  "sedang mengetik…" di dalam room kini hanya label pembaca layar (header tetap menampilkannya). String baru:
  `readMore`, `notifGroupNew`, `notifGroupEarlier`, `profileStatPosts`, `profileStatFollowers`.
* **Popup promo di tengah layar (backend: field banner `display`, `image_url`, `cta_label`, `frequency` + RPC
  `record_banner_event`).** Banner `display: "popup"` tidak lagi tampil sebagai strip; pasang
  `CommunityPromoPopupHost(child:, enabled:, onBannerLink:)` sekali di halaman utama host. Maksimal satu popup per sesi
  aplikasi (per user), prioritas tertinggi yang lolos frekuensi `once`/`daily`/`every_open` (catatan per user + banner di
  penyimpanan lokal paket), ditunda selama ada route/dialog lain di atas halaman host, tidak tampil saat
  `update_required` atau sebelum login. Tampilan bawaan: overlay 60%, kartu ≤ 360 radius 16, gambar 4:5–16:9, tombol
  utama aksen, "Nanti", ✕ bila `dismissible`, animasi fade + scale 200 ms. Event `impression`/`click`/`dismiss` dikirim
  tanpa menunggu dan gagal diam-diam. Rincian dan tabel perilaku: [doc/features.md](doc/features.md#popup-promo-170).
  * Baru: `CommunityPromoPopupHost`, `CommunityPromoPopupCard`, `showCommunityPromoPopup`, slot
    `CommunitySystemBuilders.popup` (`CommunityPromoPopupDetails`), `CommunityPromoPopups`,
    `CommunityPromoPopupDependencies` (interface opsional; `RendezvousCommunity` mengimplementasikannya, dependensi
    fitur buatan host tanpa interface ini tidak menampilkan popup), `BannerEventRepository`,
    `PromoPopupHistoryRepository`, field `CommunityBanner.display`/`imageUrl`/`ctaLabel`/`frequency` + `isPopup`/`link`,
    enum `CommunityBannerDisplay`, `CommunityBannerFrequency`, `CommunityBannerEvent`, `CommunityScope.maybeOf`, string
    `promoPopupCta`, `promoPopupLater`, `promoPopupClose`, `promoPopupLabel`.
  * **Tautan banner ke host:** `onBannerLink(context, uri, banner)` (`FutureOr<bool>`, `true` = sudah ditangani) di
    `initialize`/`create`, `CommunityCallbacks`, `CommunityBannerHost`, dan `CommunityPromoPopupHost` (per widget
    didahulukan). Tidak ditangani: `https`/`http` lewat dialog konfirmasi seperti sebelumnya, skema lain (mis.
    `olt://…`) diabaikan. Tanpa callback perilaku banner strip tidak berubah.
  * App contoh memasang popup host (matikan: `--dart-define=OLT_PROMO_POPUP=false`); `example/integration_test/*`
    memakai `ExampleApp(promoPopups: false)`. Scene screenshot baru `system_promo_popup`, `system_promo_popup_text`.
* **Alat pengembang:** harness screenshot `flutter test tool/screenshots/screenshots_test.dart` (font Roboto dari SDK,
  output `build/screenshots/`, tidak ikut CI).
* **Kill switch `social_disabled` kini `403` (backend `0109`, T24).** Backend tidak lagi menjawab `503` (`PT503`) untuk
  penolakan kill switch karena PostgREST menganggap setiap `503` sebagai database putus. Klien 1.3.0 ke atas mengenali
  `social_disabled` dari kodenya; bedanya hanya `CommunityException.kind`: `forbidden` (sebelumnya `unavailable`),
  sehingga pesan chat yang ditolak langsung gagal alih-alih dicoba ulang otomatis oleh outbox.
* Tes integrasi membaca anon key cadangan dari `../chat_service_supabase/docker/secrets/anon_key` (repo backend di folder
  sebelah); `OLT_SOCIAL_ANON_KEY` tetap diutamakan. E2E: `support_test` mencakup tiket aktif yang dilanjutkan;
  `app_test` menggulir ke komentar di detail post.

## 1.6.0

* **Typing di room besar (backend `0106`).** Room saham dan grup dengan anggota ≥ `rooms.typing_aggregate_members`
  (bawaan 50) tidak lagi menyiarkan typing per orang. Server mengirim event `typing_summary` (`count`, `ttl_ms`, tanpa
  identitas) paling sering sekali per `rooms.typing_summary_seconds` (3 dtk) per room. Mulai
  `rooms.typing_off_members` (2.000) typing mati. Room tampil "Seseorang sedang mengetik…" atau
  "Beberapa orang sedang mengetik…" dan hilang sendiri setelah `ttl_ms`. DM, grup kecil, dan chat CS tidak berubah.
  * Baru: `RoomTypingSummary` (subtipe `RoomSignal`), `TypingSummaryChanged` (subtipe `ChatRoomEvent`),
    `ChatRoomState.typingOthers`/`anyoneTyping`, `CommunityTypingDetails.count`, string `typingSomeone`.
    `switch` exhaustif milik host atas `RoomSignal`/`ChatRoomEvent` perlu cabang baru.
* **Presence hanya di DM.** Channel `room:<id>` room saham dan grup bergabung tanpa presence (tidak `track`, tidak
  `onPresenceSync`). Presence memang hanya dipakai untuk titik online DM. Server menolak `track` di room saham dan room
  non-CS dengan anggota ≥ `rooms.presence_max_members` (50; room saham: `rooms.presence_stock_members`, bawaan selalu); channel tetap tersambung. Chat CS tetap memakai presence.
* **Daftar chat: room saham ikut terbarui (backend `0107`).** Selama `CommunityChatList` terlihat (`TickerMode` aktif,
  aplikasi di depan, online), pratinjau, waktu, dan jumlah belum dibaca room saham diambil lewat RPC ringan
  `get_room_previews` (≤ 50 room per panggilan, tanpa hitungan anggota) tiap `rooms.preview_poll_seconds`
  (bawaan 15 dtk, dijepit 5 dtk–5 mnt) × 0,75–1,25 acak, dan langsung saat aplikasi kembali ke depan bila poll terakhir
  > 5 dtk. Room yang lebih baru naik ke atas; pratinjau tidak pernah mundur. Tanpa room saham di daftar tidak ada poll.
  * Baru: `RoomPreviewRepository` (opsional, seperti `MessageIndexRepository`), `RoomPreview`, `RoomPreviewPage`.
    Repository buatan host tanpa interface ini tidak memoll.
  * Backend tanpa `0107` (`PGRST202`): polling berhenti untuk sesi itu, perilaku sama dengan 1.5.0.
* Klien 1.5.0 pada backend `0106`/`0107`: indikator typing tidak muncul di room besar, `track` presence di room saham
  ditolak tanpa error yang terlihat (channel dan pesan tetap jalan), daftar room saham tetap terbarui saat dimuat ulang.

## 1.5.0

* **Realtime pesan lewat Broadcast dari server (backend `0098`).** Pesan baru, diubah, dihapus, dan disembunyikan
  (room saham, DM, grup, dan chat CS) datang sebagai event `message`/`message_hidden` di topik privat `room:<id>`,
  bukan lagi `postgres_changes` tabel `messages`. Daftar chat dan `DeliveryTracker` mendengarkan `room_activity`
  di topik privat `user:<id>` milik sendiri. Tidak ada perubahan API publik; host tidak perlu mengubah kode.
* **Keamanan:** klien tidak lagi mengirim broadcast. Typing dikirim lewat RPC `send_typing` (identitas dari JWT).
  Server menolak broadcast klien ke topik room, dan event dengan `room_id` room lain diabaikan.
* **Mengisi celah berbasis horizon (backend `0103`, temuan T18/T19):** `ChatRoomCubit` menambal pesan yang
  dibuang Realtime saat channel room tersambung, berkala selama room terbuka, dan saat aplikasi kembali ke depan.
  * Titik awal adalah **horizon** per room: `(created_at, id)` terbaru yang sudah dikonfirmasi server (halaman
    pertama, muat ulang, atau gap-fill sebelumnya), dikurangi `gapOverlap`. Pesan yang hanya datang lewat
    Realtime tidak memajukan horizon, sehingga lubang di tengah aliran (event dibuang batas tenant, atau pesan
    yang commit saat Realtime membuat ulang slot replikasi) ikut tertambal, bukan hanya ekornya.
  * Room saham, DM, dan grup memakai `get_message_ids` (hanya id) lalu `get_messages_by_ids` untuk pesan yang
    belum ada. Chat CS memakai `get_messages(p_after)`. Maksimal 5 halaman; lebih dari itu room dimuat ulang
    dari pesan terbaru. Duplikat digabung lewat `id`/`client_id`.
  * Setelah sambung ulang, gap-fill menunggu jeda acak 0–5 dtk (ratusan klien yang sambung ulang serentak tidak
    lagi memanggil RPC bersamaan), lalu berjalan sekali lagi 5–10 dtk kemudian. Gap-fill berkala diacak
    45 dtk ± 25% per putaran. Join pertama dan resume tetap langsung.
  * Parameter opsional `ChatRoomCubit(gapFillInterval: 45 dtk, gapOverlap: 10 dtk, reconnectJitter: 5 dtk,
    gapRecheckDelay: 5 dtk, random:)`; `Duration.zero` mematikan masing-masing.
  * Baru: `MessageIndexRepository` + `MessageIdPage` (diekspor). Repository chat buatan host yang
    mengimplementasikannya ikut memakai jalur id; yang tidak tetap memakai `getMessagesAfter`.
  * Pesan dari pengirim yang terlibat blokir datang sebagai referensi dan diambil lewat `get_messages` (RLS tetap
    menyaring). Cache offline tidak berubah.
  * Baru: `CommunityConnectivity.resumes` dan `notifyResumed()`; `RendezvousCommunity` memanggilnya saat
    `onResume`.
* Butuh backend dengan migrasi `0098` dan `0103`. Klien 1.4.x tetap tersambung, tetapi tidak menerima pesan baru secara
  realtime (hanya saat memuat ulang) dan typing-nya tidak sampai.

## 1.4.0

* **Perbaikan:** `CommunityChatBuilders.merge()` kini menyertakan `stockCard`, sehingga scope bersarang
  (`CommunityChatRoom(builders: ...)`, `withChatBuilders`, scope di halaman yang dibuka package) tidak lagi
  membuang builder kartu saham milik host. Tes regresi + tes analyzer
  (`test/tool/merge_completeness_test.dart`) yang memastikan setiap `merge`/`copyWith`/`lerp` di package
  meneruskan semua field.
* **Perbaikan:** di desktop/web, scroll cepat saat kursor berada di atas tombol bertooltip tidak lagi membekukan
  input mouse. Semua list lazy package memakai `addAutomaticKeepAlives: false`, sehingga baris yang sedang di-hover
  tidak ditahan di luar layar (bug Flutter flutter/flutter#193566). Dijaga oleh `test/tool/list_keep_alive_test.dart`.
* Baru: builder UI untuk feed, notifikasi, profil, dan badge dengan pola yang sama seperti chat
  (`CommunityPartBuilder<T>(context, details, fallback)` + scope + `merge`):
  * `CommunityFeedBuilders`: `postCard`, `postAvatar`, `postHeader`, `postBody`, `attachments`, `linkPreview`,
    `stockTags`, `actionBar`, `poll`, `pinnedMarker`, `loading`, `empty`, `error`, `comment`
    (`CommunityPostDetails`, `CommunityLinkPreviewDetails`, `CommunityPollDetails`,
    `CommunityPinnedMarkerDetails`, `CommunityCommentDetails`) dengan handler like/komentar/bagikan/bookmark/
    edit/hapus/laporkan/blokir/banding/buka profil/buka saham/buka hashtag/vote.
  * `CommunityNotificationBuilders`: `item`, `header`, `loading`, `empty`, `error`.
  * `CommunityProfileBuilders`: `header`, `stats`, `followButton`.
  * `CommunityBadgeBuilders`: `label` (semua badge label sekaligus), `official`, `supportOfficial`, `bot`,
    `roomModerator`, `sentiment`, `verified`, `count`, `countOverlay`; dipakai di badge akun resmi, CS resmi,
    bot, moderator room, sentimen, centang terverifikasi, jumlah belum dibaca room/permintaan pesan, dan badge
    chat/CS/notifikasi. Widget baru `CommunityCountOverlay`.
  * `CommunityBuilders` + `CommunityBuildersScope` memasang kelima set sekaligus (bersarang = digabung), dan
    ikut terbawa ke halaman yang dibuka package. Parameter `builders:` baru di `CommunityFeedList`,
    `CommunityStreamFeed`, `CommunityNotificationList`, `CommunityUserProfile`.
  * Detail status daftar bersama: `CommunityListLoadingDetails`, `CommunityListEmptyDetails`,
    `CommunityListErrorDetails`. `CommunityPartBuilder` kini diekspor dari `shared`.
  * Tanpa builder, tampilan bawaan tidak berubah.
* Baru: gambar didekode seukuran tampilan (layout × `devicePixelRatio`, kelipatan 64 px, cover, maks 2048 px)
  untuk avatar, lampiran (post, chat, post yang dibagikan, permintaan pesan), dan link preview, dengan kunci
  cache stabil (`storage:<bucket>/<path>`, parameter tanda tangan URL dibuang) lewat `CommunityImageProvider`,
  `CommunityNetworkImage`, `CommunityImageLoader`, `CommunityImageScope`.
* Baru: cache gambar di disk per user (`<application support>/rendezvous_community/images/<user id>/`), LRU
  berdasarkan byte dan kedaluwarsa: `RendezvousCommunity.initialize(imageCache: CommunityImageCacheConfig(
  maxBytes: 200 MB, maxAge: 30 hari))`, `CommunityImageCacheConfig.disabled()`. Hanya aktif bila
  `offlineCache: true`. Dihapus bersama cache offline saat `signOut()`, `deleteMyAccount()`,
  `clearLocalCache()`, dan ganti user. Lampiran chat CS (`cs-documents`, `CommunitySupportChat`, riwayat tiket)
  tidak pernah disimpan ke disk; host bisa menandai layar lain dengan `CommunityImagePersistence`. Web tanpa
  cache disk. Tanpa dependensi baru (memakai `http`, `path_provider`, `crypto` yang sudah ada).
* Baru: tes performa scroll (`example/integration_test/perf_scroll_test.dart` +
  `example/test_driver/perf_driver.dart`, target `make perf-flutter`) dengan 200 post dan 500 pesan palsu,
  budget p90 build < 8 ms, p90 raster < 16 ms, tidak ada frame > 32 ms kecuali frame pertama; penjaga murah
  di `flutter test` untuk daftar lazy dan ukuran dekode gambar.
* Daftar feed memberi `ValueKey` per post, daftar notifikasi per item.
* Contoh app: tombol untuk kartu post kustom dan bentuk badge kustom (`example/lib/custom_feed_style.dart`).

## 1.3.0

* **Butuh backend dengan migrasi `0068`–`0086`** (keamanan konten, permintaan DM, banding,
  integritas pasar, pencarian, trending, edit/bookmark/reaksi/bagikan, preferensi notifikasi,
  konfigurasi klien, analitik, link preview, `moderation_status`) serta layanan `link-preview`
  dan `classifier`. Fitur baru dibaca lewat `get_client_config`; backend lama tanpa RPC ini
  membuat fitur baru tetap tampil tetapi gagal dengan pesan umum.
* Baru: konfigurasi klien & kill switch. `RendezvousCommunity.initialize(appVersion: ...,
  platform: CommunityPlatform..., onUpdateRequired: ...)` (`android`, `ios`, `web`, `windows`,
  `macos`, `linux`; default dari platform yang berjalan) memanggil `get_client_config` saat start, saat login,
  saat aplikasi kembali ke foreground, dan tiap 5 menit (sebelum login lewat anon key).
  `clientConfig`, `clientConfigChanges`, `refreshClientConfig()`. Saat `social_enabled = false`
  feed, composer, detail post, pencarian, trending, bookmark, room non-CS, dan daftar chat (kecuali
  room CS) menampilkan `CommunityUnavailableView`; host bisa menggantinya lewat
  `CommunityAvailabilityScope(builder: ...)` atau `CommunitySocialGate(unavailableBuilder: ...)`.
  Error `social_disabled` dari server langsung mematikan UI sosial. `CommunityUpdateListener`
  dan `onUpdateRequired` dipanggil sekali saat `update_required` menjadi `true`. Flag yang dibaca:
  `search`, `trending`, `bookmarks`, `post_edit`, `message_reactions`, `share_post_to_chat`,
  `notification_prefs`, `analytics` (`CommunityFlags`).
* Baru: pesan error terlokalisasi untuk `new_account_restricted` (gambar/tautan),
  `link_blocked`, `contact_blocked`, `content_blocked`, `slow_mode` (dengan hitung mundur dari
  `details`/`Retry-After`, `CommunityException.retryAfter`), `dm_not_allowed`,
  `dm_request_limit`, `social_disabled`, `edit_window_expired`, `poll_not_editable`,
  `image_blocked`, `classifier_unavailable`, `moderation_unavailable`, `appeal_exists`,
  `appeal_window_closed`, `appeal_not_allowed`, `query_too_short`/`query_too_long`,
  `share_not_allowed`. Pesan tidak menyebut kategori atau kata yang cocok.
  `appeal_reviewer_conflict` (khusus staf) tidak diberi pesan khusus.
* Baru: label "Menunggu tinjauan" untuk post, komentar, dan pesan milik sendiri yang
  `moderation_status = held`, label "Disembunyikan moderator" + "Ajukan banding" untuk yang
  `hidden`, serta label pada gambar yang diunggah dengan respons `"held": true`
  (`Attachment.held`, `UploadedObject.held`).
* Baru: permintaan pesan DM. Entri "Permintaan pesan" dengan jumlah di atas `CommunityChatList`
  (`MessageRequestsEntry`), `CommunityMessageRequests` / `openCommunityMessageRequests`,
  room permintaan dengan gambar diburamkan sampai diterima, aksi Terima / Tolak /
  Blokir & laporkan. Saat DM dibuka, `get_dm_request_state` menentukan status: pengirim melihat
  "Pesan Anda masih berupa permintaan (n/3)" lalu pemberitahuan batas, penerima bisa langsung
  "Terima" dari room (`DmRequestState`, `MessageRequestRepository.requestState`).
  Pengaturan "Siapa yang bisa mengirim pesan langsung" (`CommunityDmPolicySettings`) di
  Privasi & akun.
* Baru: banding. `showCommunityAppealDialog`, `CommunityAppeals` / `openCommunityAppeals`
  ("Banding saya": sanksi aktif, "Konten yang dimoderasi" dari `get_my_moderated_content`
  (post/komentar/pesan yang disembunyikan atau dihapus moderator 90 hari terakhir, dengan banding
  terakhirnya), dan status banding), notifikasi dan push tipe `appeal`
  (`NotificationType.appeal`).
* Baru: room saham menampilkan slow mode, hitung mundur di composer, dan pesan yang disematkan
  (`get_stock_room_state` + event realtime `room_state`).
* Baru: preferensi notifikasi per jenis (di aplikasi / push), jam tenang WIB
  (`CommunityNotificationSettings`, bagian "Notifikasi" di Privasi & akun), dan teks notifikasi
  gabungan ("Budi dan 4 lainnya menyukai konten Anda") dari `actor_count`/`actors`.
* Baru (`0086`): lima jenis notifikasi OLT di pengaturan notifikasi, dalam bagian "Notifikasi OLT"
  dengan keterangan singkat: `olt.trade` (Transaksi), `olt.funds` (Dana), `olt.market` (Pasar),
  `olt.info` (Info), `olt.promo` (Promo; push default mati). Semua jenis OLT kini punya sakelar
  di aplikasi dan push; sakelar di aplikasi hanya disembunyikan bila server mengirim
  `in_app: null`. Jenis yang belum dikenal ditampilkan dengan namanya. Konstanta baru
  `notificationFundsType`, `notificationMarketType`, `notificationOltInfoType`,
  `notificationPromoType`, `isOltNotificationType()`, dan `NotificationTypePreference.isOlt`.
* Baru: pesan OLT di kotak notifikasi (`type = announcement`, `payload.source = "olt"`) tampil
  dengan judul/isi sesuai bahasa aplikasi (`id`/`en`, cadangan `id` lalu `en`, atau teks biasa)
  dan ikon netral per jenis (ikon khusus untuk kategori `important` dan `promo`), tanpa avatar.
  `AppNotification.isOlt`, `oltKind`, `oltCategory`, `localizedTitle()`, `localizedBody()`.
  `AppNotification.title`/`body` kini `null` (bukan error) bila nilainya bukan teks.
* Baru: callback `onOltNotificationTap` di `RendezvousCommunity.initialize`/`create` dan
  `CommunityCallbacks` (`CommunityOltNotificationTapCallback`). Mengetuk pesan OLT di kotak
  notifikasi menandainya terbaca lalu memanggil callback dengan seluruh payload (`kind`,
  `category`, `message_id`, `cust_id`, `title`, `body`, `data`) plus `notification_id`.
  `openCommunityPush` meneruskan push OLT (`source: "olt"`) ke callback yang sama, menandai
  `notification_id` terbaca, dan mengembalikan `true`; tanpa callback tetap `false`.
* Baru: pencarian (`CommunitySearch` / `openCommunitySearch`: tab Semua/Post/Pengguna/Saham/
  Hashtag, debounce 300 ms, paginasi), feed hashtag (`CommunityHashtagFeed`), hashtag trending.
  `SocialText` kini membuat `#hashtag` dan tautan `http(s)` bisa diketuk; tautan dibuka setelah
  dialog konfirmasi yang menampilkan domain asli (`openCommunityLink`). Skema lain tidak bisa
  diketuk. Callback baru `onHashtagTap`.
* Baru: link preview (`LinkPreviewCard`, `LinkPreviewLoader`) untuk URL pertama di post,
  komentar, dan pesan: judul, deskripsi, situs, gambar dari bucket `link-previews`, domain akhir.
  `get_link_previews` dipanggil sekali per batch layar; status `pending` diulang paling banyak
  dua kali (3 dan 10 detik).
* Baru: `CommunityTrending` (saham, naik daun, populer, hashtag; jendela 24 jam/7 hari) dan
  `CommunityStockSentiment(stockCode:)` untuk halaman saham host.
* Baru: edit post dan komentar dalam jendela edit (menu "Edit" hanya 15 menit pertama, bukan post
  polling), label "(diedit)".
* Baru: bookmark (menu dan tombol di kartu post) dan `CommunityBookmarks`.
* Baru: reaksi pesan chat (tekan lama atau tombol hover → 6 emoji, chip jumlah, realtime
  `reaction`), tidak tersedia di chat CS.
* Baru: "Kirim ke chat" di menu post (`showSharePostToChat`) dan kartu post di pesan
  (`SharedPostCard`, termasuk "Post tidak tersedia").
* Baru: `showCommunityComposer(context, initialStock:, initialImage: CommunityComposerImage(...))`
  untuk membagikan chart dari OLT; gambar diunggah lewat media gateway.
* Baru: label Bot (`Post.isBot`) dan Resmi (`Post.authorIsOfficial`).
* Baru: analitik ringan (`CommunityAnalytics`): `feed_open`, `post_create`, `comment_create`,
  `message_send`, `stock_tap`, `search`, `share_chart`, dan `trackOrderTap()` untuk host.
  Batch maks 50, dikirim tiap 60 detik, saat 20 event terkumpul, atau saat aplikasi ke latar
  belakang; batch gagal dibuang; berhenti bila server menjawab `disabled`. Hanya properti
  whitelist yang dikirim, tidak pernah teks konten atau kata kunci.
* Baru: `isCommunityPush(data)` dan `isOltPush(data)`. Tanpa `onOltNotificationTap`,
  `openCommunityPush` mengembalikan `false` untuk push `olt.*` (`source: "olt"`, `cust_id`,
  `message_id`, plus `data` dari OLT seperti `screen`) supaya host yang menanganinya.
* **Butuh migrasi `0087`–`0090`** untuk fitur berikut (backend lama: banner kosong, laporan
  notifikasi/draf/kartu saham gagal tanpa mengganggu UI lain).
* Baru (`0089`): banner aplikasi dari `get_client_config` (`ClientConfig.banners`, `CommunityBanner`,
  level `info`/`warning`/`critical`). `CommunityBannerHost(maxVisible: 3, builder:)` untuk dipasang
  host; tampil otomatis di atas feed Terbaru/Mengikuti. Urut `priority` lalu `starts_at`, banner yang
  sudah berakhir disembunyikan, tautan dibuka lewat dialog konfirmasi `openCommunityLink`. Banner
  `dismissible` yang ditutup disimpan lokal per user (`BannerDismissals`, maks 100 id); yang tidak
  bisa ditutup selalu tampil.
* Baru (`0088`): laporan dibuka/diketuk notifikasi (`report_notification_event`). Membuka item kotak
  notifikasi atau push melapor `opened`; mengikuti tujuannya melapor `tapped` (`notification_id`
  lebih dulu, lalu `campaign_id`/`broadcast_id` dari data push). Kirim lalu lupakan, tiap event
  sekali per sumber, diantrekan di memori saat offline dan dikirim ulang saat koneksi kembali
  (`NotificationReporter`, `RendezvousCommunity.reportNotificationOpened/Tapped(data)` untuk host).
* Baru (`0087`): jenis notifikasi `followed_post` (buka postingan), `watchlist_digest` (buka feed saham
  teratas lewat `onStockTap`), `moderation` (buka "Banding saya", menampilkan bisa/tidaknya banding),
  dan `mention` dari room saham (buka room). Nilai enum baru `NotificationType.followedPost`,
  `watchlistDigest`, `moderation`, `notificationTypeFromKey()`, `openCommunityNotification()`.
  Pengaturan notifikasi menampilkan jenis baru; sakelar in-app nonaktif bila `in_app_locked`
  (`NotificationTypePreference.inAppLocked`).
* Baru (`0090`): draf postingan. Composer menyimpan otomatis (jeda 1,5 detik) ke perangkat lalu
  `save_post_draft` dengan `p_base_updated_at`; `draft_conflict` → versi yang lebih baru dipakai dan
  pengguna diberi tahu; `draft_limit` / offline → draf tetap di perangkat. Terbit memakai
  `client_draft_id` sebagai `client_id` sehingga server menghapus drafnya. `CommunityPostDrafts` /
  `openCommunityPostDrafts` untuk melanjutkan atau menghapus draf, `showCommunityComposer(draft:)`,
  `CommunityDrafts`, `PostDraft`.
* Baru (`0090`): kartu saham di chat. Tombol "Kirim kartu saham" di composer (bukan chat CS), maksimal
  3 kode; lampiran `{"type": "stock", "code"}` tampil sebagai kartu (`ChatMessage.stockCodes`,
  `StockCards`, builder `CommunityChatBuilders.stockCard`). Nama/harga dari host lewat callback baru
  `stockInfo` (`CommunityStockInfo`); ketuk → `onStockTap`. `ChatExtrasRepository.sendStockCards`,
  `ChatRoomCubit.sendStockCards`.
* `CommunityFeatureDependencies` bertambah `notificationReporter`, `bannerDismissals`, `drafts`.
* Baru: cache offline (bawaan aktif, `initialize(offlineCache: false)` untuk mematikan). Database
  lokal per user komunitas (drift + SQLite di Android/iOS/Windows/macOS/Linux, memori di web)
  menyimpan halaman pertama daftar room (tanpa room CS), pesan terakhir per room (bawaan 200,
  `initialize(offlineMessageLimit:)`, dipangkas otomatis), dan halaman pertama feed
  Terbaru/Mengikuti/saham (20 saham terakhir). Saat dibuka, data tersimpan langsung tampil lalu
  diganti data server di latar belakang; server tetap sumber kebenaran (edit, hapus, reaksi, dan
  `moderation_status` di baris ikut tersimpan, pesan yang tidak lagi dikembalikan server dalam
  rentang halaman yang sama dihapus dari cache). Saat koneksi kembali, layar yang masih
  menampilkan data tersimpan memuat ulang sendiri. Skema bernomor versi (`CommunityDatabase.version`).
* Baru: outbox pesan teks. Pesan yang dikirim saat offline atau gagal karena jaringan disimpan
  bersama `client_id`, tampil "Menunggu dikirim" (`MessageStatus.pending`), lalu dikirim ulang
  dengan backoff (2 detik, maks 1 menit) dan segera saat koneksi kembali, aplikasi kembali ke
  foreground, atau realtime tersambung lagi. Urutan per room dijaga; server menolak duplikat lewat
  `client_id`. Error permanen (`content_blocked`, `dm_request_limit`, `consent_required`,
  `slow_mode` setelah 3 percobaan di latar belakang, dll.) menandai pesan gagal beserta alasannya
  (`ChatMessage.sendError`) dengan tombol "Coba lagi" dan "Hapus" (`CommunityMessageDetails.onDiscard`,
  `ChatRoomCubit.discard`, `MessageDeliveryNotice`). Lampiran gambar/PDF tidak masuk antrean:
  saat offline ditolak dengan pesan jelas (kode `attachment_offline`).
* Baru: indikator offline. `CommunityConnectivity` menilai koneksi dari hasil request ke server dan
  status realtime (tanpa plugin konektivitas); saat offline memeriksa ulang lewat
  `get_client_config` (5 detik, naik sampai 1 menit). `CommunityOfflineBanner` tampil di atas
  daftar chat dan feed; room chat memakai builder `connectionBanner` dengan
  `CommunityConnectionDetails.offline`.
* Privasi: database lokal dihapus saat `signOut()`, `deleteMyAccount()`, `clearLocalCache()`, saat
  sesi komunitas berganti user, dan saat aplikasi dibuka offline oleh user OLT lain. Token tidak
  pernah disimpan; pemilik database dicocokkan lewat hash SHA-256 dari `iss`+`sub` token OLT.
  Chat CS tidak di-cache.
* API baru: `RendezvousCommunity.instance.clearLocalCache()`, `connectivity`, `offlineCacheEnabled`,
  `chatCache`, `feedCache`, `outbox`, `CommunityOfflineScope` + `CommunityOfflineDependencies`,
  `ChatCacheRepository`, `FeedCacheRepository`, `MessageOutbox`, `OutboxMessage`. Parameter cubit
  baru (opsional): `ChatRoomCubit(cache:, outbox:, connectivity:)`, `ChatListCubit(cache:,
  connectivity:)`, `FeedCubit(cache:, connectivity:)`; state baru `stale`.
* Dependensi baru: `drift` (MIT), `sqlite3` (MIT; SQLite dibundel lewat build hooks, tanpa
  `sqlite3_flutter_libs`), `path_provider` (BSD), `path` (BSD), `crypto` (BSD); dev: `drift_dev` (MIT).
* Logger baru `RendezvousCommunity.Config`, `RendezvousCommunity.Analytics`, dan
  `RendezvousCommunity.Offline`.
* Kompatibilitas: `CommunityDependencies` tidak berubah; fitur baru lewat antarmuka baru
  `CommunityFeatureDependencies` dan `CommunityFeatureScope` (bawaannya
  `RendezvousCommunity.instance`; tanpa keduanya fitur baru tersembunyi). Parameter baru semua
  opsional. **Perlu perhatian:** subclass baru pada sealed class `RoomSignal` (`RoomReaction`,
  `RoomStateSignal`), `ChatRoomEvent` (`ReactionChanged`, `StockRoomStateChanged`), dan
  `SocialTextSegment` (`HashtagSegment`, `LinkSegment`), serta nilai enum
  `NotificationType.appeal`, `followedPost`, `watchlistDigest`, `moderation`, dan `MessageStatus.pending`:
  `switch` lengkap di kode host perlu
  cabang baru.
  `parseSocialText` hanya menghasilkan segmen baru bila `hashtags: true` / `links: true`.
* Perbaikan: lampiran `{"type": "post"}` dari pesan bagikan post tidak lagi membuat
  `get_messages` gagal di-parse (versi ≤ 1.2.0 gagal membaca room yang berisi post yang dibagikan).

## 1.2.0

* **Wajib backend baru: unggahan lewat media gateway.** Gambar post, gambar chat,
  PDF chat CS, dan foto profil kini dikirim ke
  `POST {supabaseUrl}/media/v1/object/{bucket}/{path}` (header `apikey`,
  `Authorization: Bearer <JWT sosial>`, `Content-Type`), bukan langsung ke Storage.
  Backend harus menjalankan layanan `media` (route Kong `/media/v1`, migrasi
  `0063_media_uploads`). Backend lama tanpa `/media/v1` membuat unggahan gagal
  dengan pesan "Unggahan file sedang tidak tersedia" (kode `media_unavailable`).
  Paket memakai `path` dan `mime` dari respons, karena server bisa mengganti
  ekstensi sesuai isi file; `width`/`height` ikut tersimpan di lampiran gambar.
  Hanya foto profil yang mengirim `x-upsert: true`. GIF tetap boleh untuk gambar
  post dan chat; foto profil GIF ditolak sebelum diunggah. Sesi kedaluwarsa (401)
  diperbarui sekali lalu unggahan diulang.
* Baru: pesan error terlokalisasi (id/en) untuk kode media gateway:
  `unsupported_type`, `file_too_large`, `empty_file`, `invalid_image`,
  `image_too_large`, `invalid_pdf`, `pdf_encrypted`, `pdf_active_content`,
  `upload_forbidden`, `too_many_uploads`, `busy`, `storage_unavailable`,
  `storage_error`. Kode lokal composer untuk gambar di atas 5 MB berganti dari
  `image_too_large` menjadi `file_too_large` (sama dengan server); `image_too_large`
  kini berarti resolusi gambar terlalu besar.
* Baru: Syarat & Ketentuan, Pedoman Komunitas, dan Kebijakan Privasi.
  `RendezvousCommunity.instance.legalDocuments()`, `pendingLegalDocuments()`, dan
  `acceptLegalDocuments(ids)` (RPC `get_legal_documents`, `accept_legal_document`).
  Daftar dokumen dicache per sesi di `CommunityConsent`: dimuat sekali saat login,
  dimuat ulang setelah setuju, tidak dipanggil ulang tiap rebuild.
* Baru: `showCommunityConsent(context)` membuka alur persetujuan (dialog di layar
  lebar, layar penuh di ponsel) berisi dokumen wajib yang belum disetujui, pembaca
  teks lengkap (judul, versi, tanggal berlaku, "Yang berubah"), satu kotak centang
  "Saya telah membaca dan menyetujui …", dan tombol "Setuju" untuk semuanya.
  Hasilnya `true` bila semua disetujui. Komponen lepas: `CommunityConsentView`,
  `CommunityLegalDocumentReader`, `showCommunityLegalDocument`.
* Baru: gerbang persetujuan otomatis. Bila membuat post, komentar, atau mengirim
  pesan chat ditolak server dengan `consent_required`, alur persetujuan terbuka;
  setelah setuju, aksi yang sama diulang satu kali (draf dan `client_id` sama).
  Bila ditunda, draf tetap ada (teks composer tidak dihapus, pesan chat menjadi
  "Gagal terkirim" dan bisa dikirim ulang) dan muncul pesan singkat. Chat CS tidak
  pernah memicu alur ini. Kirim ulang otomatis setelah koneksi pulih tidak membuka
  dialog. Gerbang yang sama bisa dipakai host lewat `communityConsentGate(context)`.
* Baru: `CommunityConsentBanner` tampil di atas feed (stream, saham, profil) bila
  ada dokumen wajib yang belum disetujui, misalnya "Pedoman Komunitas diperbarui —
  tinjau dan setujui." Bisa ditutup untuk sesi ini; muncul lagi bila ada dokumen
  wajib baru.
* Baru: privasi & akun (UU PDP). `exportMyData()` mengembalikan
  `CommunityDataExport` (JSON UTF-8 rapi + nama file
  `data-komunitas-<username>-<yyyyMMdd>.json`); dibatasi server 3 kali sehari.
  `deleteMyAccount()` menghapus akun komunitas lalu membersihkan sesi komunitas di
  perangkat tanpa login ulang otomatis; login berikutnya membuat profil komunitas
  baru yang kosong. Akun trading tidak tersentuh.
* Baru: `CommunityAccountSettings` / `openCommunityAccountSettings(context,
  onAccountDeleted: ...)` ("Privasi & akun"): tautan dokumen hukum, "Unduh data saya"
  (desktop: dialog simpan `file_selector`; Android/iOS/web: bagikan file, web
  mengunduh bila Web Share API tidak tersedia), dan "Hapus akun komunitas" dengan
  penjelasan dampak, konfirmasi mengetik `HAPUS` (`DELETE` di bahasa Inggris), dan
  indikator proses. Cara menyimpan file bisa diganti lewat `exportSaver`.
* Dependensi baru: `share_plus` (BSD-3-Clause). Dibutuhkan karena `file_selector`
  tidak punya dialog simpan di Android, iOS, dan web. Dependensi transitif barunya
  (`share_plus_platform_interface`, `path_provider*`, `jni_flutter`, `objective_c`,
  `hooks`, `code_assets`, `record_use`, `pub_semver`, `yaml`) berlisensi BSD/MIT;
  `tool/license_audit.dart` lulus.
* Logger baru `RendezvousCommunity.Account`. Isi ekspor dan token tidak pernah
  masuk log.
* Tidak ada perubahan yang memecah API Dart: `CommunityDependencies` tidak berubah.
  Fitur dokumen hukum dan akun lewat antarmuka baru `CommunityAccountDependencies`
  dan `CommunityAccountScope` (bawaannya `RendezvousCommunity.instance`).
  `ChatRoomCubit` menerima parameter opsional `consent`.
* Membutuhkan migrasi `0062_legal_documents` dan `0063_media_uploads` serta
  layanan `media`.

## 1.1.0

* Baru: push notification. `RendezvousCommunity.instance.registerPushToken(token,
  platform: CommunityPushPlatform.android, locale: ..., appVersion: ...)` mendaftarkan
  token FCM milik app ke akun yang sedang login; token otomatis pindah ke akun baru
  bila akun berganti, dan dilepas saat `signOut()`. `unregisterPushToken()` mematikan
  push untuk perangkat ini. `openCommunityPush(context, message.data)` membuka
  postingan, chat, chat CS, profil, atau tautan pengumuman dari push yang diketuk dan
  menandai notifikasinya terbaca; nilainya `false` untuk push yang bukan milik paket.
  Paket tidak bergantung pada Firebase (panduan: `docs/push/README.md`).
* Baru: postingan tersemat dan pengumuman resmi tampil di atas stream umum dan stream
  saham (`FeedRepository.getPinned`, `PinnedPost`), tanpa diulang di daftar biasa.
* Baru: badge **Resmi** untuk akun resmi perusahaan sekuritas di semua nama pengguna
  (`OfficialAccounts`, `CommunityOfficialScope`).
* Baru: notifikasi jenis `announcement` (judul dan isi dari kampanye; diketuk membuka
  postingan atau tautan `https`).
* Logger baru `RendezvousCommunity.Push`.
* Tidak ada perubahan yang memecah API: `CommunityDependencies` tidak berubah.

## 1.0.0

* Breaking: package `olt_social` berganti nama menjadi `rendezvous_community`.
  Import `package:olt_social/olt_social.dart` menjadi
  `package:rendezvous_community/rendezvous_community.dart`.
* Breaking: prefix `Olt` dihapus dari API publik. `OltSocial` menjadi
  `RendezvousCommunity`, `OltSocialException`/`OltSocialErrorKind` menjadi
  `CommunityException`/`CommunityErrorKind`, `OltSocialLocalizations` menjadi
  `CommunityLocalizations`, `context.oltL10n` menjadi `context.communityL10n`,
  dan widget `Olt*` menjadi `Community*`. Parameter `oltTokenProvider` menjadi
  `tokenProvider`. Tabel lengkap ada di
  `doc/migration-1.0.md`.
* Baru: logger terpusat berbasis `package:logging` (BSD-3) dengan logger per
  komponen `RendezvousCommunity.Auth/Chat/Feed/Realtime/Support`.
  Host memasang handler lewat `RendezvousCommunity.initialize(logHandler: ...,
  logLevel: ...)`. Field log terstruktur (`CommunityLogEvent`) dan data
  sensitif (token, JWT, password, OTP, isi pesan/post, nomor rekening, NIK)
  disamarkan otomatis.
* Pesan exception internal, `assert`, dan deskripsi tes kini berbahasa Inggris.
  Teks yang dilihat user tidak berubah.
* Tidak ada perubahan API backend, skema database, nama topik Realtime, atau
  data di perangkat. Library tidak menyimpan apa pun di perangkat, jadi update
  tidak membuat user logout.

## 0.3.0

* Prinsip integrasi: server hanya memvalidasi token login ke OLT. Order, daftar
  dan nama saham, harga, serta data nasabah tetap milik app OLT.
* Baru: `OltSocial.initialize(stockSearch: ...)` (`OltStockSearch`,
  `StockSuggestion`) untuk saran `$KODE` dari daftar saham milik app, dan
  `OltStockFeed(stockName: ...)` untuk nama saham di header.
* Breaking: `Stock` kini hanya `code`, `watcherCount`, dan `watching`
  (`StockType`, `name`, `sector` dihapus). `StockRepository.searchStocks` dan
  `isWatching` dihapus; `getStock` memakai RPC `get_stock`.
* Breaking: chat CS tanpa kartu order/transaksi dana. `SupportCard`,
  `SupportCardKind`, `SupportOrder`, parameter `card` di `OltSupportChat`,
  `OltSupportPage`, dan `openOltSupport`, `SupportRepository.sendCard` dan
  `recentOrders`, `OltSupportMessageActions.onOpenCard`, serta
  `MessageKind.card` dihapus. Pesan kartu lama tampil sebagai teks.
* Breaking: `OltSupportStaff` dihapus karena web CS kini hanya versi React.
* Membutuhkan migrasi `0037_client_owned_business_data`.

## 0.2.0

* Builder untuk kustomisasi UI chat: `OltChatBuilders` (pesan, composer, header
  room, mengetik, banner koneksi, pemisah hari, tile room, header daftar chat,
  loading, kosong, error) lewat `OltChatBuildersScope` atau parameter `builders`
  di `OltChatList`/`OltChatRoom`. Setiap builder menerima data siap tampil,
  handler yang sudah tersambung ke logika package, dan tampilan bawaan.
* Komponen siap pakai ikut diekspor: `OltComposerField`, `AttachmentGrid`,
  `ReceiptIcon`, `OltRoomAvatar`.
* Lazy load: pesan lama dan daftar room tetap dimuat walau halaman pertama
  belum memenuhi layar. Daftar room kini dimuat per halaman (30, cursor).
* Setelah tersambung ulang, pesan yang terlewat disusulkan per 100 sampai habis;
  bila lebih dari 500, room dimuat ulang dari pesan terbaru.
* Breaking: `ChatRepository.getRooms({cursor, limit})` mengembalikan
  `Paged<ChatRoom>`, ada `getRoom(roomId)` baru, dan `getMessagesAfter`
  mengembalikan `Paged<ChatMessage>`. Membutuhkan migrasi `0036_chat_room_paging`.

## 0.1.0

* Rilis awal: feed & feed saham, compose dengan autocomplete `$KODE`/`@user`,
  thread komentar berantai, reaksi, follow/block/watch, chat realtime
  (DM, grup, room saham) dengan typing indicator & read receipt,
  notifikasi, laporan konten, lokalisasi Indonesia & Inggris.
