# Kustomisasi tampilan

[← Kembali ke README](../README.md)

Tema, builder per bagian UI, dan cache gambar.

## Tema

Semua warna diturunkan dari `ThemeData` aplikasi host, termasuk dark mode. Untuk menyesuaikan:

```dart
final base = ThemeData(colorScheme: oltColorScheme);
ThemeData(
  colorScheme: oltColorScheme,
  extensions: [
    CommunityTheme.fallback(base).copyWith(
      bullish: oltGreen, bearish: oltRed,
      maxThreadIndentLevels: 4,   // level komentar yang diindentasi
    ),
  ],
);
```

## Kustomisasi UI (builder)

Chat, feed, kartu post, komentar, notifikasi, profil, dan badge bisa diganti per bagian tanpa menulis ulang logikanya (feed/notifikasi/profil/badge sejak 1.4.0). Setiap builder menerima tiga hal:
- `details`: data siap tampil dan handler yang sudah tersambung ke logika package (kirim, balas, hapus, kirim ulang, bisukan, buka room, dan lain-lain);
- `fallback`: tampilan bawaan bagian itu;
- `context`.

Lazy load, kirim ulang otomatis, indikator mengetik, dan tanda terima tetap diurus package. Tanpa builder, tampilan bawaan tidak berubah sedikit pun.

### Pasang semua sekaligus

`CommunityBuilders` menggabungkan lima set builder (`chat`, `feed`, `notifications`, `profile`, `badges`). Pasang sekali di `MaterialApp.builder` supaya berlaku di semua halaman, termasuk halaman yang dibuka package:

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

`CommunityBuildersScope` boleh bersarang: scope di dalam hanya menimpa bagian yang diisinya, sisanya diwarisi dari scope di atasnya (`merge` mencakup semua field; dijaga oleh `test/tool/merge_completeness_test.dart`). Builder per widget (`CommunityFeedList(builders: ...)`, `CommunityStreamFeed(builders: ...)`, `CommunityNotificationList(builders: ...)`, `CommunityUserProfile(builders: ...)`, `CommunityChatList/CommunityChatRoom(builders: ...)`) juga digabung dengan cara yang sama. Scope per set (`CommunityChatBuildersScope`, `CommunityFeedBuildersScope`, `CommunityNotificationBuildersScope`, `CommunityProfileBuildersScope`, `CommunityBadgeBuildersScope`) mengganti set itu seluruhnya.

### Chat

Pasang sekali untuk seluruh aplikasi:

```dart
MaterialApp(
  builder: (context, child) => CommunityChatBuildersScope(
    builders: CommunityChatBuilders(
      message: (context, d, fallback) {
        final m = d.message;
        if (m.kind != MessageKind.text || m.isDeleted || m.senderRole != null) return fallback;
        final scheme = Theme.of(context).colorScheme;
        return Align(
          alignment: d.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: d.onRetry,
            onLongPress: d.onShowActions,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: d.isMine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                SocialText(m.body ?? ''),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(d.timeLabel),
                  if (d.isMine) ReceiptIcon(receipt: d.receipt, sendStatus: m.status, color: scheme.outline),
                ]),
              ]),
            ),
          ),
        );
      },
      composer: (context, d, fallback) => Row(children: [
        ...d.extraActions,
        IconButton(onPressed: d.onPickImage, icon: const Icon(Icons.image_outlined)),
        Expanded(
          child: CommunityComposerField(
            controller: d.controller,
            focusNode: d.focusNode,
            hintText: d.hintText,
            maxLength: d.maxLength,
            onSubmit: d.onSend,
          ),
        ),
        IconButton(onPressed: d.onSend, icon: const Icon(Icons.send)),
      ]),
    ),
    child: child!,
  ),
);
```

Builder juga bisa dipasang per widget: `CommunityChatList(builders: ...)` atau `CommunityChatRoom(roomId: id, builders: ...)`. Builder per widget menimpa builder global untuk bagian yang sama.

| Builder | `details` | Data dan handler |
|---|---|---|
| `message` | `CommunityMessageDetails` | `message`, `isMine`, `receipt`, `showSender`, `startsGroup`, `timeLabel`; `onReply`, `onDelete` (dengan konfirmasi bawaan), `onReport`, `onRetry`, `onSenderTap`, `onShowActions` (menu aksi bawaan) |
| `composer` | `CommunityComposerDetails` | `controller`, `focusNode`, `hintText`, `maxLength`, `uploading`, `replyTo`, `replyPreview`, `allowsDocuments`, `extraActions`; `onSend`, `onPickImage` (di chat CS juga memilih PDF), `onCancelReply` |
| `roomHeader` | `CommunityRoomHeaderDetails` | `room`, `title`, `subtitle`, `highlightSubtitle`, `online`, `typing`, `memberCount`; `onTap`, `onToggleMute`, `onLeave` |
| `typingIndicator` | `CommunityTypingDetails` | `users`, `text`, `count` (jumlah yang mengetik dari ringkasan room besar; `users` kosong) — dipanggil hanya saat ada yang mengetik |
| `connectionBanner` | `CommunityConnectionDetails` | `status`, `label` (dipanggil hanya saat menyambung ulang) |
| `dayDivider` | `CommunityDayDetails` | `day`, `label` |
| `roomTile` | `CommunityRoomTileDetails` | `room`, `title`, `preview`, `typingText`, `timeLabel`, `online`, `selected`, `lastMessageReceipt`; `onTap` |
| `listHeader` | `CommunityChatListHeaderDetails` | `title`; `onNewGroup`, `onRefresh` |
| `loading` | `CommunityLoadingDetails` | `kind`: `rooms`, `moreRooms`, `messages`, `olderMessages` |
| `empty` | `CommunityEmptyDetails` | `kind`: `rooms`, `messages`, `noRoomSelected`; `message` |
| `error` | `CommunityErrorDetails` | `error`, `message` (terlokalisasi); `onRetry` |
| `stockCard` | `CommunityStockCardDetails` | `code`, `isMine`, `info` (dari `stockInfo` host); `onTap` (buka halaman saham) |

Aturan pakai:
- **Handler `null` berarti aksinya tidak berlaku.** Contohnya `onDelete` untuk pesan orang lain, atau `onRetry` untuk pesan yang sudah terkirim. Pasang langsung ke `onPressed` supaya tombol otomatis nonaktif.
- **Teks sudah terlokalisasi:** waktu, teks mengetik, pratinjau "Anda: …", subjudul header, pesan kosong, dan pesan error.
- **Kembalikan `fallback` untuk yang tidak ingin digambar sendiri**, misalnya pesan sistem, tautan bantuan, dan pilihan cepat dari CS.
- **Composer kustom sebaiknya menampilkan `extraActions`.** Tombol tambahan dari `leading` milik pemanggil (`MessageComposer`) masuk lewat sini.
- **Tile kustom wajib menampilkan `OfficialBadge` untuk room CS** (`room.pinned` bernilai `true`) supaya nasabah tetap bisa membedakan CS resmi dari akun palsu. Room CS selalu ada di urutan teratas daftar.
- **Pesan dari CS wajib tetap memperlihatkan penanda resmi.** Cara paling aman: kembalikan `fallback` bila `message.senderRole != null`, karena tampilan bawaan sudah memuat label CS Resmi, tautan bantuan, pilihan cepat, dan rating.
- **Widget `header:` dan `composer:` di `CommunityChatRoom` tetap didukung** dan didahulukan dari builder.
- **Builder ikut terbawa ke halaman yang dibuka package:** room di layar sempit, chat CS, dan riwayat tiket.
- **Komponen siap pakai untuk UI sendiri:** `CommunityComposerField` (Enter mengirim, autocomplete `$KODE`/`@user`), `SocialText`, `AttachmentGrid`, `ReceiptIcon`, `CommunityAvatar`, `CommunityRoomAvatar`, `CommunityCountBadge`, `CommunityNetworkImage`.

### Feed, kartu post, dan komentar (1.4.0)

```dart
CommunityFeedBuilders(
  postCard: (context, d, fallback) {
    if (d.pinned != null) return fallback;          // post tersemat tetap tampilan bawaan
    final post = d.post;
    return Card(
      child: InkWell(
        onTap: d.onOpen,
        child: Column(children: [
          ListTile(
            leading: CommunityAvatar(user: post.author, onTap: d.onOpenAuthor),
            title: Text(post.author.name),
            subtitle: Text(d.timeLabel),
          ),
          SocialText(post.body, validStockCodes: post.stockCodes.toSet()),
          if (post.attachments.isNotEmpty) AttachmentGrid(attachments: post.attachments),
          if (post.poll != null) CommunityPollView(postId: post.id, poll: post.poll!, canVote: d.canVote),
          Row(children: [
            IconButton(onPressed: d.onLike, icon: Icon(post.likedByMe ? Icons.favorite : Icons.favorite_border)),
            IconButton(onPressed: d.onComment, icon: const Icon(Icons.forum_outlined)),
            IconButton(onPressed: d.onShare, icon: const Icon(Icons.send_outlined)),          // null: fitur mati
            IconButton(onPressed: d.onToggleBookmark, icon: const Icon(Icons.bookmark_border)),
            IconButton(onPressed: d.onReport, icon: const Icon(Icons.flag_outlined)),         // null untuk post sendiri
          ]),
        ]),
      ),
    );
  },
  stockTags: (context, d, fallback) => Wrap(spacing: 6, children: [
    for (final code in d.post.stockCodes)
      ActionChip(label: Text('\$$code'), onPressed: () => d.onOpenStock(code)),
  ]),
  comment: (context, d, fallback) => d.comment.isDeleted ? fallback : ListTile(
    title: Text(d.comment.body ?? ''),
    subtitle: Text(d.timeLabel),
    trailing: IconButton(onPressed: d.onReply, icon: const Icon(Icons.reply)),
  ),
)
```

| Builder | `details` | Isi |
|---|---|---|
| `postCard`, `postAvatar`, `postHeader`, `postBody`, `attachments`, `stockTags`, `actionBar` | `CommunityPostDetails` | `post`, `isMine`, `timeLabel`, `edited`, `expanded`, `source`, `pinned`, `canVote`; `onLike`, `onOpen`, `onComment`, `onShare`, `onToggleBookmark`, `onEdit`, `onDelete` (dengan konfirmasi), `onReport`, `onBlock` (dengan konfirmasi), `onAppeal`, `onOpenAuthor`, `onOpenStock(code)`, `onOpenHashtag(tag)` |
| `linkPreview` | `CommunityLinkPreviewDetails` | `preview` (`title`, `description`, `siteName`, `imageUrl`, `domain`); `onOpen` (dengan dialog tautan bawaan). Berlaku di feed, komentar, dan chat |
| `poll` | `CommunityPollDetails` | `poll`, `canVote`, `closed`, `showResults`, `summary` (teks suara & sisa waktu), `pendingOptionId`; `onVote(option)` (null bila tidak bisa memilih) |
| `pinnedMarker` | `CommunityPinnedMarkerDetails` | `pinned`, `announcement`, `title`, `label` ("Pengumuman"/"Disematkan") |
| `comment` | `CommunityCommentDetails` | `comment`, `isMine`, `collapsed`, `timeLabel`, `edited`; `onLike`, `onReply`, `onToggleCollapse`, `onOpenAuthor`, `onEdit`, `onDelete`, `onReport`, `onBlock`, `onAppeal` |
| `loading` / `empty` / `error` | `CommunityListLoadingDetails` (`more`) / `CommunityListEmptyDetails` (`message`) / `CommunityListErrorDetails` (`error`, `message`, `onRetry`) | status daftar feed |

`postCard` menerima `fallback` berupa kartu bawaan yang sudah memakai builder bagian (`postHeader`, `postBody`, dan seterusnya), jadi host bisa mengganti kartu utuh untuk sebagian post saja. `stockTags` tidak menggambar apa pun secara bawaan (kode saham sudah tampil di isi post). Label moderasi milik sendiri ("Menunggu tinjauan", "Ajukan banding") tetap digambar package di kartu bawaan; kartu kustom bisa memakai `ModerationNotice(status: d.post.moderationStatus, onAppeal: d.onAppeal)`.

### Notifikasi (1.4.0)

```dart
CommunityNotificationList(
  builders: CommunityNotificationBuilders(
    header: (context, d, fallback) => ListTile(
      title: Text(d.title),
      trailing: TextButton(onPressed: d.onMarkAllRead, child: Text('Tandai ${d.unread} dibaca')),
    ),
    item: (context, d, fallback) => ListTile(
      leading: Icon(d.icon, color: d.important ? Colors.red : null),
      title: Text(d.title, style: TextStyle(fontWeight: d.isRead ? null : FontWeight.w700)),
      subtitle: d.snippet == null ? null : Text(d.snippet!),
      trailing: Text(d.timeLabel),
      onTap: d.onTap,                         // tandai dibaca, statistik, lalu buka tujuan
    ),
  ),
)
```

`item` (`CommunityNotificationDetails`: `notification`, `title`, `snippet`, `icon`, `timeLabel`, `important`, `isRead`, `isOlt`; `onTap`), `header` (`CommunityNotificationHeaderDetails`: `title`, `unread`, `onMarkAllRead`), `loading`/`empty`/`error` (detail daftar yang sama dengan feed). Daftar notifikasi tidak punya pengelompokan per tanggal; `header` adalah judul daftar.

### Profil (1.4.0)

```dart
CommunityUserProfile(
  userId: id,
  builders: CommunityProfileBuilders(
    stats: (context, d, fallback) => Row(children: [Text(d.followersLabel), Text(d.followingLabel), Text(d.postsLabel)]),
    followButton: (context, d, fallback) =>
        OutlinedButton(onPressed: d.onToggleFollow, child: Text(d.isFollowing ? 'Mengikuti' : 'Ikuti')),
  ),
)
```

`header`, `stats`, dan `followButton` menerima `CommunityProfileDetails`: `profile`, `busy`, `isMe`, `isFollowing`, label statistik terlokalisasi; `onToggleFollow`, `onMessage`, `onEdit` (dialog edit bawaan), `onReport`, `onBlock`, `onUnblock`.

### Badge (1.4.0)

Satu set builder untuk semua badge di package, jadi bentuk badge cukup diganti sekali:

```dart
CommunityBadgeBuilders(
  label: (context, d, fallback) => Container(          // resmi, CS resmi, bot, moderator, sentimen
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: ShapeDecoration(
      shape: StadiumBorder(side: BorderSide(color: d.background ?? d.border ?? d.foreground)),
    ),
    child: Text(d.label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
  ),
  count: (context, d, fallback) => CircleAvatar(radius: 10, child: Text(d.label)),   // "99+" sudah dihitung
  countOverlay: (context, d, fallback) => Badge.count(count: d.count, isLabelVisible: d.count > 0, child: d.child),
)
```

| Builder | `details` | Dipakai di |
|---|---|---|
| `label` | `CommunityLabelBadgeDetails` (`kind`, `label`, `icon`, `foreground`, `background`, `border`) | semua badge label bila builder khususnya kosong |
| `official` / `supportOfficial` / `bot` / `roomModerator` / `sentiment` | sama | akun resmi (`CommunityUserName`), CS resmi (`OfficialBadge`: tile room CS, pesan & header chat CS), post bot, moderator room saham, sentimen post (`kind`: `sentimentBullish`/`Bearish`/`Neutral`) |
| `verified` | `CommunityVerifiedBadgeDetails` (`user`, `color`, `size`) | centang terverifikasi di nama user |
| `count` | `CommunityCountBadgeDetails` (`kind`, `count`, `label`, `muted`) | jumlah belum dibaca per room (`roomUnread`), permintaan pesan (`messageRequests`) |
| `countOverlay` | `CommunityCountOverlayDetails` (`kind`, `count`, `label`, `child`) | `CommunityChatBadge` (`chatUnread`), `CommunitySupportBadge` (`supportUnread`), `CommunityNotificationBadge` (`notificationUnread`) |

Badge CS resmi wajib tetap terlihat jelas: builder `supportOfficial`/`label` boleh mengganti bentuk, jangan menyembunyikannya.

Contoh app (`example/`): tombol palet mengganti gaya chat, tombol `style` mengganti kartu post dan bentuk badge (`example/lib/custom_feed_style.dart`).

## Gambar & cache disk (1.4.0)

Avatar, lampiran gambar (post, chat, kartu post yang dibagikan), dan gambar link preview dimuat lewat `CommunityImageProvider`:

- **Didekode seukuran tampilan.** Ukuran target = ukuran layout × `devicePixelRatio`, dibulatkan ke kelipatan 64 px (supaya cache memori tidak terpecah), mempertahankan rasio (cover) dan dibatasi 2048 px. Gambar 1600×1200 di tile 300 px pada layar 2× didekode 640×480, bukan ukuran penuh.
- **Kunci cache stabil.** Lampiran memakai `storage:<bucket>/<path>`; URL storage Supabase (`/object/sign|public|authenticated/...`) dipetakan ke kunci yang sama, dan parameter tanda tangan (`token`, `X-Amz-*`, `Expires`, dll.) dibuang. URL bertanda tangan yang berganti tidak memicu unduhan ulang. Lampiran tetap diambil lewat `MediaRepository.attachmentImage` (header `Authorization` sesi) hanya saat cache tidak punya salinan.
- **Cache disk per user.** `<application support>/rendezvous_community/images/<user id>/`, satu file per gambar (nama = SHA-256 kunci). LRU berdasarkan total byte dan kedaluwarsa per gambar:

```dart
await RendezvousCommunity.initialize(
  // ...
  imageCache: const CommunityImageCacheConfig(
    maxBytes: 200 * 1024 * 1024,     // bawaan 200 MB
    maxAge: Duration(days: 30),      // bawaan 30 hari sejak diunduh
  ),
  // imageCache: const CommunityImageCacheConfig.disabled(),   // hanya cache memori
);
```

- **Privasi.** Cache gambar hanya aktif bila `offlineCache: true`, dan dihapus bersama database offline: `signOut()`, `deleteMyAccount()`, `clearLocalCache()`, saat sesi berganti ke user lain (folder user lain dihapus saat dibuka), dan cache memori gambar milik package ikut dibuang. **Lampiran chat CS tidak pernah ditulis ke disk** (bucket `cs-documents` dan semua gambar di `CommunitySupportChat` serta riwayat tiket), sama seperti riwayat chat CS yang tidak di-cache. Host bisa menandai layar lain dengan `CommunityImagePersistence(persist: false, child: ...)`.
- **Web:** tanpa cache disk (cache HTTP browser yang berlaku); kunci stabil dan dekode seukuran tampilan tetap aktif.
- **Untuk UI sendiri:** `CommunityNetworkImage(cacheKey: ..., source: ...)` atau `CommunityNetworkImage.url(url)`. Tes/host bisa memasang loader sendiri lewat `CommunityImageScope(loader: CommunityImageLoader(client: ...))`.

