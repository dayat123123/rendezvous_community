# Panduan desain

[← Kembali ke README](../README.md) · [Kustomisasi](customization.md) · [Inventaris builder](builders.md)

Tampilan bawaan memakai gaya editorial: halaman abu sangat muda, kartu putih berborder tipis, tipografi lega, dan aksi berbentuk pil. Warna aksen selalu `Theme.of(context).colorScheme.primary` milik aplikasi host, jadi brand OLT tetap terbawa. Tidak ada font atau aset tambahan; huruf mengikuti `ThemeData.textTheme` host.

Semua nilai berasal dari dua `ThemeExtension`:

| Extension | Isi | Tanpa konfigurasi |
|---|---|---|
| `CommunityTheme` | warna semantik: bullish/bearish, tautan, garis thread, gelembung chat, badge belum dibaca, indikator online, centang | `CommunityTheme.fallback(theme)` |
| `CommunityStyle` (1.7.0) | token tata letak editorial: permukaan, border, teks, pil, spasi, radius, tipografi, ukuran avatar | `CommunityStyle.fallback(theme)` |

`CommunityTheme.of(context)` dan `CommunityStyle.of(context)` selalu berhasil: bila host tidak memasang extension, nilai diturunkan dari `ThemeData` aktif (terang/gelap) dan di-cache per `ThemeData`, jadi memanggilnya di setiap `build` murah.

## Token

### Warna (`CommunityStyle`)

Semua warna mengikuti tema aplikasi host (tidak ada warna latar/teks yang dipatok), sehingga layar komunitas sama dengan layar lain di aplikasi. Contoh untuk `ColorScheme.fromSeed(seedColor: Color(0xFF0B5FFF))` dengan `scaffoldBackgroundColor` bawaan Material 3 (nilai persis mengikuti tema host):

| Token | Turunan | Terang | Gelap | Dipakai untuk |
|---|---|---|---|---|
| `background` | terang: `surfaceContainerHigh`, gelap: `surfaceContainerLowest` (bila sama dengan `surface`: `onSurface` 6%/5% di atas `surface`) | dari tema | dari tema | jalur pemisah antar post, latar judul bagian |
| `surface` | `ThemeData.scaffoldBackgroundColor` | dari tema | dari tema | section post, daftar, room, kartu, panel |
| `border` | `outlineVariant` | dari tema | dari tema | garis kartu/pil 1 px |
| `divider` | `outlineVariant` 60% | dari tema | dari tema | hairline antar item/komentar |
| `textPrimary` | `onSurface` | dari tema | dari tema | judul, isi, nama |
| `textSecondary` | `onSurfaceVariant` | dari tema | dari tema | meta, waktu, keterangan (AA ≥ 4,5:1) |
| `textTertiary` | `outline` | `#767680` | `#8F909A` | ikon nonaktif, placeholder (≥ 3:1, bukan teks penting) |
| `accent` / `onAccent` | `primary` / `onPrimary` | `#4C5C92` / `#FFFFFF` | `#B5C4FF` / `#1C2D61` | tombol utama, status aktif |
| `accentMuted` | `primary` 10% (gelap 18%) di atas `surface` | `#EDEFF4` | `#393D4C` | latar pil/tag aktif, saran terpilih |
| `pill` / `onPill` | `onSurface` 4% (gelap 8%) / `textSecondary` | `#F6F6F6` / `#595963` | `#2E2F35` / `#B0B0BA` | pil aksi |
| `chip` / `onChip` | sama dengan `pill` / `textPrimary` | `#F6F6F6` / `#1A1B21` | `#2E2F35` / `#E3E1E9` | tag `$KODE`, `#hashtag` |
| `skeleton` | `onSurface` 7% (gelap 10%) | `#EFEFEF` | `#323239` | skeleton statis, placeholder gambar |

Bila `ColorScheme` host tidak punya tingkat `surfaceContainer*` (mis. `ColorScheme.light()` lama), `background`/`surface` dicampur dari `onSurface` agar halaman dan kartu tetap berbeda. Kontras diuji untuk skema bawaan, seed biru OLT, seed hijau, dan skema lama di `test/shared/presentation/community_style_test.dart`.

### Spasi (`CommunitySpacing`)

| `xxs` | `xs` | `sm` | `md` | `lg` | `xl` | `xxl` |
|---|---|---|---|---|---|---|
| 2 | 4 | 8 | 12 | 16 | 24 | 32 |

`spacing.card` = `EdgeInsets.fromLTRB(16, 12, 16, 12)` (padding kartu), `spacing.page` = horizontal 16. Gunakan hanya kelipatan ini; jarak avatar–nama memakai `sm + xxs` (10).

### Radius (`CommunityRadii`)

| `badge` | `image` | `card` | `control` | `pill` |
|---|---|---|---|---|
| 4 | 6 | 8 | 8 | 999 (stadium) |

Getter `badgeRadius`, `imageRadius`, `cardRadius`, `controlRadius`, `pillRadius` mengembalikan `BorderRadius`.

### Tipografi (`CommunityTypography`)

Diturunkan dari `textTheme` host (font host tetap dipakai), warna dari token teks:

| Token | Basis | Ukuran / tebal / tinggi baris | Warna |
|---|---|---|---|
| `title` | `titleMedium` | 18 / w700 / 1.35 | `textPrimary` |
| `body` | `bodyLarge` | 15 / w400 / 1.5 | `textPrimary` |
| `author` | `titleSmall` | 14 / w700 / 1.3 | `textPrimary` |
| `meta` | `bodySmall` | 13 / w400 / 1.35 | `textSecondary` |
| `label` | `labelLarge` | 13 / w600 / 1.2 | `textSecondary` |
| `sectionTitle` | `titleSmall` | 15 / w700 / 1.3 | `textPrimary` |
| `badge` | `labelSmall` | 11 / w600 / 1.2 | `textPrimary` (ditimpa per badge) |

### Ukuran lain

| Token | Bawaan | Catatan |
|---|---|---|
| `avatarSizes.small` / `medium` / `large` | 28 / 36 / 64 | diameter; daftar ringkas `small`, baris penulis `medium`, header `large` |
| `avatarSizes.post` / `comment` / `reply` / `profile` | 40 / 32 / 24 / 80 | header kartu post, komposer, hasil pencarian user (`post`); komentar (`comment`); balasan (`reply`); header profil (`profile`) |
| `CommunityTheme.threadIndent` | 40 | indentasi per tingkat balasan (sebelumnya 16); garis thread 1 px `threadLine` |
| `borderWidth` | 1 | border kartu & divider |
| `minTouchTarget` | 48 | target sentuh minimum |
| `danger` | `#D92D20` (`fallback`: `colorScheme.error`) | ikon dan label item berbahaya di popup menu (hapus, blokir, keluar, hapus grup, akhiri chat) |
| `menuItemHeight` | 36 | tinggi item popup menu desktop (`communityMenuItem`); bottom sheet mobile tetap ≥ `minTouchTarget` |
| `menuIconSize` | 17 | ukuran ikon item popup menu; jarak ikon ke label 10, label 12 |
| `icons` | `CommunityIcons()` | ikon aksi dan menu; bawaan ikon Material, isi dengan ikon aplikasi (misalnya FluentIcons) |

### Helper

- `style.borderSide`, `style.cardDecoration(selected:)`, `style.cardShape(selected:)` untuk permukaan berborder buatan sendiri.
- `style.sectionGap` (= `spacing.sm`, 8): tinggi jalur `background` di antara section full-bleed (feed, hasil pencarian).

**Dua gaya permukaan.** `CommunityCard` (inset: margin, border 1 px, radius `card`) tetap dipakai chat, CS, notifikasi, pengaturan, dan dialog. Feed, detail post, pencarian, trending, profil, dan header saham memakai section full-bleed seperti Quora: selebar layar, tanpa border dan radius, latar `surface`, padding konten horizontal 16, dipisah jalur `sectionGap`. Gambar post di feed tampil full-bleed (grid 2×2, celah 2, "+N" untuk lebih dari 4 gambar); link preview tetap bergaris tipis dan sejajar padding 16. Header bagian full-bleed: ikon aksen + judul + chevron, dengan hairline.

**Pola feed (ala Facebook/Instagram di atas gaya editorial).** Kartu post: avatar `post` (40, cincin aksen 2 px untuk akun resmi), nama tebal + badge, meta abu; gambar full-bleed dengan rasio dari `Attachment.width/height` (dibatasi 0,8–1,91, bawaan 4:3, maks 360) dan `BoxFit.cover`, placeholder warna `skeleton`; "+N" berupa lapisan gelap di petak terakhir. Bar aksi: pil "⇧ Suka · N" (getar `selectionClick` + `CommunityBump`), komentar dengan jumlah, kirim, simpan di kanan; tidak ada baris ringkasan jumlah terpisah karena pil sudah memuatnya. Komentar: gelembung `pill` radius 16 berisi nama + teks, baris kecil "waktu · Suka · Balas · ⋯", avatar 32/24, indentasi 40 per tingkat dengan garis 1 px. Prompt compose: avatar + pil + ikon foto; halaman compose: header penulis, field tanpa border, tombol alat berlabel, Kirim selebar konten. Profil: avatar 80 kiri + tiga statistik ringkas, nama/bio di bawah, tombol Ikuti/Pesan berdampingan. Pencarian: field pil + chip filter (menggantikan tab), baris hasil avatar/ikon 40 dengan dua baris teks. Skeleton `PostCardSkeleton`/`PostThreadSkeleton` meniru kartu post dan komentar (statis).

**Gaya chat.** Daftar room, room, chat CS, permintaan pesan, dan notifikasi mengikuti aplikasi chat umum (Instagram DM, WhatsApp/Messenger, Facebook): daftar rata di atas `surface` dengan avatar 52/44 dan hairline berindentasi, gelembung radius 18 dengan ekor 4 di pesan terakhir grup, chip tanggal, composer pil, dan ikon pengaturan dalam kotak membulat berwarna lembut (`CommunityToneIcon`). `CommunityTheme.fallback` (1.7.0) mengisi gelembung sendiri dengan aksen: terang `primary`/`onPrimary`, gelap `primaryContainer`/`onPrimaryContainer` (agar tidak menyilaukan); badge belum dibaca juga aksen (`primary`/`onPrimary`). Host yang memasang `CommunityTheme` sendiri tidak terpengaruh. Centang dibaca memakai `readReceipt` bila kontrasnya ≥ 3:1 terhadap gelembung, bila tidak memakai warna teks gelembung (terkirim/sampai 82%). Kontras teks, waktu, dan nama pengirim berwarna diuji di `test/features/chat/presentation/chat_bubble_style_test.dart`.
- `style.primaryButtonStyle()` (terisi aksen, stadium) dan `style.secondaryButtonStyle()` (outline tipis) untuk `FilledButton`/`OutlinedButton`.
- `communityCountText(context, count)`: hitungan ringkas sesuai locale (`1,2 rb`, `1.2K`).

## Komponen dasar

Semua komponen kecil, `const` bila argumennya konstan, dan masing-masing bisa diganti lewat `CommunitySharedBuilders` (lihat [inventaris](builders.md#shared-tahap-1-selesai)).

```dart
final style = CommunityStyle.of(context);

CommunityCard(
  onTap: openPost,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CommunityAuthorRow(
        user: post.author,
        meta: '${post.author.username} · $timeLabel',
        onOpenAuthor: openAuthor,
        trailing: CommunityActionButton(icon: Icons.more_horiz, tooltip: l10n.more, onPressed: showMenu),
      ),
      SizedBox(height: style.spacing.sm),
      Text(title, style: style.typography.title),
      SizedBox(height: style.spacing.sm),
      SocialText(post.body, style: style.typography.body),
      SizedBox(height: style.spacing.md),
      Wrap(spacing: style.spacing.sm, children: [
        for (final code in post.stockCodes) CommunityTag(label: '\$$code', onTap: () => openStock(code)),
      ]),
      CommunityActionBar(
        leading: [
          CommunityActionPill(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: l10n.like,
            count: post.likeCount,
            active: post.likedByMe,
            onPressed: onLike,
          ),
        ],
        trailing: [
          CommunityActionButton(icon: Icons.mode_comment_outlined, tooltip: l10n.comment, count: post.commentCount, onPressed: onComment),
          CommunityActionButton(icon: Icons.share_outlined, tooltip: l10n.share, onPressed: onShare),
        ],
      ),
    ],
  ),
);
```

| Komponen | Gunanya |
|---|---|
| `CommunityCard` | permukaan `surface` + border 1 px + radius `card`, tanpa bayangan; `onTap`/`onLongPress` memberi ripple; `selected` memberi border aksen |
| `CommunityAuthorRow` | avatar (bawaan `medium`) + nama (badge resmi/terverifikasi otomatis) + baris meta; seluruh blok identitas satu target sentuh ≥ 48 bila `onOpenAuthor` diisi |
| `CommunityActionPill` | aksi utama berbentuk pil abu dengan ikon + label/hitungan; `active` memakai `accentMuted` + teks aksen; target sentuh 48; ikon membesar sekali (1 → 1,15 → 1, 180 ms) saat menjadi aktif |
| `CommunityBump` | animasi skala sekali jalan saat `active` berubah ke `true`; mati bila `MediaQuery.disableAnimations`; dipakai pil/tombol aksi dan aksi Suka komentar |
| `CommunityActionButton` | aksi sekunder ikon (48×48), opsional hitungan di sampingnya |
| `CommunityActionBar` | `leading` (dibungkus `Wrap`, aman di layar sempit) dan `trailing` rata kanan |
| `CommunitySectionHeader` | judul bagian + subjudul + tautan aksi; ditandai `header` untuk pembaca layar |
| `CommunityDivider` | hairline `divider` 1 px dengan `indent`/`endIndent` |
| `CommunityTag` | chip stadium netral; `selected` memakai aksen; tanpa `onTap` tidak menambah target sentuh |
| `CommunityEmptyView` / `CommunityErrorView` / `CommunityLoadingView` | ikon besar (80) dalam lingkaran `accentMuted` + judul tebal; `title` opsional menjadikan `message` subjudul abu; tombol aksi bila ada; error dengan tombol outline "Coba lagi"; loading spinner kecil |
| `CommunitySkeleton`, `CommunitySkeletonBox` | skeleton statis (tanpa animasi), baris penulis + tiga garis teks |

## Aturan

**Spasi.** Hanya skala 2/4/8/12/16/24/32. Padding kartu `spacing.card`; jarak antar kartu `sm`; antar bagian `lg`/`xl`. Komentar dan item daftar dipisah `CommunityDivider`, bukan kartu bertumpuk.

**Warna.** Ambil dari `CommunityStyle`/`CommunityTheme`, jangan `Colors.*` atau hex. Aksen hanya untuk status aktif, tautan, dan tombol utama; sisanya netral. Status error memakai `colorScheme.error`, status tertahan `colorScheme.tertiary`.

**Mode gelap.** Semua token punya nilai gelap otomatis. Jangan menulis `brightness == dark ? … : …` di widget; bila butuh warna baru, tambahkan token. Cek kedua mode di harness screenshot.

**Aksesibilitas.** Teks penting memakai `textPrimary`/`textSecondary` (≥ 4,5:1). `textTertiary` hanya untuk ikon/elemen non-esensial. Target sentuh ≥ 48 (`minTouchTarget`): pakai `CommunityActionPill`/`CommunityActionButton`/`IconButton` atau `MaterialTapTargetSize.padded`. Elemen dekoratif (skeleton) dikecualikan dari semantik; tombol ikon wajib `tooltip`. Tes `meetsGuideline(androidTapTargetGuideline)` dan `textContrastGuideline` ada di `test/shared/presentation/community_shared_builders_test.dart`.

**Performa.** Tanpa animasi berulang (skeleton statis, tanpa shimmer). `CommunityStyle.of` di-cache per tema; panggil sekali di awal `build`. Pakai `const` di mana mungkin, `ListView.builder` dengan `addAutomaticKeepAlives: false`, dan jangan membuat `TextStyle`/`BoxDecoration` di dalam loop bila bisa dihitung sekali.

**Builder.** Di dalam builder sebuah slot, jangan memakai widget yang memanggil slot yang sama (mis. `CommunityCard` di builder `card`): itu memanggil builder lagi tanpa henti. Bungkus `fallback`, atau gambar sendiri dari `details`.

## Menimpa token

```dart
ThemeData theme(Brightness brightness) {
  final base = ThemeData(colorScheme: oltScheme(brightness));
  final style = CommunityStyle.fallback(base);
  return base.copyWith(
    extensions: [
      CommunityTheme.fallback(base),
      style.copyWith(
        background: brightness == Brightness.light ? const Color(0xFFF1F2F2) : null,
        radii: style.radii.copyWith(card: 6),
        spacing: style.spacing.copyWith(lg: 20),
        typography: style.typography.copyWith(
          title: style.typography.title.copyWith(fontSize: 19),
        ),
      ),
    ],
  );
}
```

`CommunityStyle` mendukung `copyWith` dan `lerp` (transisi tema animasi berjalan halus); `CommunitySpacing`, `CommunityRadii`, `CommunityAvatarSizes`, dan `CommunityTypography` masing-masing punya `copyWith`/`lerp`. Mulai dari `CommunityStyle.fallback(base)` supaya token yang tidak diubah tetap mengikuti tema host.

## Menimpa komponen

```dart
MaterialApp(
  builder: (context, child) => CommunityBuildersScope(
    builders: CommunityBuilders(
      shared: CommunitySharedBuilders(
        card: (context, d, fallback) => Card(
          margin: d.margin,
          child: InkWell(onTap: d.onTap, child: Padding(padding: d.padding, child: d.child)),
        ),
        actionPill: (context, d, fallback) => d.active ? fallback : OutlinedButton.icon(
          onPressed: d.onPressed,
          icon: Icon(d.effectiveIcon, size: 18),
          label: Text(d.text ?? ''),
        ),
        emptyView: (context, d, fallback) => OltEmptyIllustration(message: d.message, action: d.action),
      ),
    ),
    child: child!,
  ),
);
```

Builder fitur (mis. `feed.empty`) didahulukan dari builder shared, karena fallback builder fitur adalah widget shared yang baru memanggil `shared.emptyView`.

## Harness screenshot

Pemeriksaan visual tanpa perangkat: merender scene contoh (terang & gelap) ke PNG memakai font Roboto dan Material Icons dari cache Flutter SDK (`<flutter>/bin/cache/artifacts/material_fonts/`), jadi teks tampil asli, bukan kotak.

```bash
flutter test tool/screenshots/screenshots_test.dart                       # semua scene
flutter test tool/screenshots/screenshots_test.dart --plain-name components_post
```

Hasil: `build/screenshots/<scene>_<light|dark>.png` (lebar 400 dp, rasio 2×; `build/` di-gitignore). Harness tidak ikut `flutter test` biasa maupun CI karena berada di `tool/`. Overflow atau exception membuat scene gagal. Font dicari lewat `FLUTTER_ROOT` lalu naik dari lokasi `flutter_tester`; bila tidak ketemu, jalankan `flutter precache`.

Menambah scene: buat `ScreenshotScene('nama', (context) => …)` di file scene (mis. `tool/screenshots/feed_scenes.dart`) lalu tambahkan daftarnya ke `scenes` di `screenshots_test.dart`. Scene berjalan di dalam `MaterialApp` (locale `id`, delegasi lokalisasi package, seed biru OLT) tanpa `CommunityScope`; widget fitur yang butuh dependensi dibungkus `CommunityScope(dependencies: FakeDependencies(...))` dari `test/support/fakes.dart`.
