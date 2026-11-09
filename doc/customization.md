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

Sejak 1.7.0 ada extension kedua, `CommunityStyle`, untuk token tata letak editorial: latar halaman, permukaan kartu, border, divider, teks primer/sekunder/tersier, pil aksi, chip, skeleton, skala spasi, radius, tipografi, dan ukuran avatar. Sama seperti `CommunityTheme`, nilainya diturunkan dari `ThemeData` host bila extension tidak dipasang; aksen tetap `colorScheme.primary`. Menimpa sebagian token:

```dart
final base = ThemeData(colorScheme: oltColorScheme);
final style = CommunityStyle.fallback(base);
ThemeData(
  colorScheme: oltColorScheme,
  extensions: [
    CommunityTheme.fallback(base),
    style.copyWith(radii: style.radii.copyWith(card: 6), spacing: style.spacing.copyWith(lg: 20)),
  ],
);
```

Daftar token, nilai bawaan terang/gelap, komponen dasar, dan aturan desain ada di [design.md](design.md).

## Kustomisasi UI (builder)

Chat, feed, kartu post, komentar, notifikasi, profil, dan badge bisa diganti per bagian tanpa menulis ulang logikanya (feed/notifikasi/profil/badge sejak 1.4.0). Setiap builder menerima tiga hal:
- `details`: data siap tampil dan handler yang sudah tersambung ke logika package (kirim, balas, hapus, kirim ulang, bisukan, buka room, dan lain-lain);
- `fallback`: tampilan bawaan bagian itu;
- `context`.

Lazy load, kirim ulang otomatis, indikator mengetik, dan tanda terima tetap diurus package. Tanpa builder, tampilan bawaan tidak berubah sedikit pun.

### Pasang semua sekaligus

`CommunityBuilders` menggabungkan semua set builder: `chat`, `feed`, `notifications`, `profile`, `badges`, dan sejak 1.7.0 `shared` (komponen bersama, lihat [di bawah](#komponen-bersama-170)), `discovery` (pencarian & trending), `support` (chat CS), `settings` (pengaturan, hukum, banding, laporan), `system` (banner, kill switch, offline), dan `help` (Pusat Bantuan/FAQ). Pasang sekali di `MaterialApp.builder` supaya berlaku di semua halaman, termasuk halaman yang dibuka package:

```dart
MaterialApp(
  builder: (context, child) => CommunityBuildersScope(
    builders: const CommunityBuilders(
      chat: CommunityChatBuilders(message: oltBubble),
      feed: CommunityFeedBuilders(actionBar: oltPostActions),
      badges: CommunityBadgeBuilders(label: oltPillBadge),
      shared: CommunitySharedBuilders(card: oltCard, emptyView: oltEmpty),
    ),
    child: child!,
  ),
);
```

Slot `discovery`, `support`, `settings`, dan `system` diisi bertahap (lihat [builders.md](builders.md)); set yang belum punya slot boleh dibiarkan bawaan.

`CommunityBuildersScope` boleh bersarang: scope di dalam hanya menimpa bagian yang diisinya, sisanya diwarisi dari scope di atasnya (`merge` mencakup semua field; dijaga oleh `test/tool/merge_completeness_test.dart`). Builder per widget (`CommunityFeedList(builders: ...)`, `CommunityStreamFeed(builders: ...)`, `CommunityNotificationList(builders: ...)`, `CommunityUserProfile(builders: ...)`, `CommunityChatList/CommunityChatRoom(builders: ...)`) juga digabung dengan cara yang sama. Scope per set (`CommunityChatBuildersScope`, `CommunityFeedBuildersScope`, `CommunityNotificationBuildersScope`, `CommunityProfileBuildersScope`, `CommunityBadgeBuildersScope`, `CommunitySharedBuildersScope`, `CommunityDiscoveryBuildersScope`, `CommunitySupportBuildersScope`, `CommunitySettingsBuildersScope`, `CommunitySystemBuildersScope`, `CommunityHelpBuildersScope`) mengganti set itu seluruhnya.

### Komponen bersama (1.7.0)

`CommunitySharedBuilders` mengganti komponen dasar dan widget bersama yang dipakai semua fitur. Builder fitur (mis. `feed.empty`) tetap didahulukan, karena fallback-nya adalah komponen bersama yang baru memanggil slot ini.

| Builder | `details` | Komponen |
|---|---|---|
| `avatar` | `CommunityAvatarDetails` (`user`, `name`, `initials`, `radius`, `size`, `image`, `online`; `onTap`) | `CommunityAvatar` di semua fitur |
| `userName` | `CommunityUserNameDetails` (`user`, `official`, `verified`, `showUsername`, `usernameLabel`, `style`) | nama + badge resmi/terverifikasi + `@username` |
| `card` | `CommunityCardDetails` (`child`, `padding`, `margin`, `selected`; `onTap`, `onLongPress`) | `CommunityCard` |
| `authorRow` | `CommunityAuthorRowDetails` (`user`, `avatar`, `name`, `meta`, `official`, `trailing`; `onOpenAuthor`) | `CommunityAuthorRow` |
| `actionPill` / `actionButton` / `actionBar` | `CommunityActionPillDetails` / `CommunityActionButtonDetails` / `CommunityActionBarDetails` | `CommunityActionPill`, `CommunityActionButton`, `CommunityActionBar` (hitungan sudah diringkas sesuai locale di `countLabel`) |
| `sectionHeader` | `CommunitySectionHeaderDetails` (`title`, `subtitle`, `actionLabel`, `trailing`; `onAction`) | `CommunitySectionHeader` |
| `divider` | `CommunityDividerDetails` (`indent`, `endIndent`, `height`) | `CommunityDivider` |
| `tag` | `CommunityTagDetails` (`label`, `icon`, `selected`; `onTap`) | `CommunityTag` |
| `skeleton` | `CommunitySkeletonDetails` (`index`, `itemCount`, `custom`) | tiap baris `CommunitySkeleton` |
| `loadingView` / `emptyView` / `errorView` | `CommunityLoadingViewDetails` / `CommunityEmptyViewDetails` / `CommunityErrorViewDetails` | state view bawaan semua daftar |
| `disclaimer` | `CommunityDisclaimerDetails` (`text`, `padding`) | `CommunityDisclaimer` |
| `moderationNotice` / `heldLabel` | `CommunityModerationNoticeDetails` (`status`, `held`, `label`, `hint`, `icon`, `color`, `compact`; `onAppeal`) / `CommunityHeldLabelDetails` | `ModerationNotice`, `HeldAttachmentLabel` |
| `composerSuggestion` | `CommunityComposerSuggestionDetails` (`kind`, `title`, `subtitle`, `leading`, `highlighted`; `onSelect`) | baris saran `$KODE`/`@user` di `CommunityComposerField` |
| `confirmDialog` | `CommunityConfirmDetails` (`message`, `confirmLabel`, `cancelLabel`; `onConfirm`, `onCancel`) | dialog konfirmasi hapus/blokir |
| `linkDialog` | `CommunityLinkConfirmDetails` (`uri`, `domain`, `title`, `body`, `confirmLabel`, `cancelLabel`; `onConfirm`, `onCancel`) | dialog sebelum membuka tautan |
| `contactActions` | `CommunityContactActionsDetails` (`uri` `mailto:`/`tel:`, `value`, `phone`, `openLabel`, `copyLabel`, `cancelLabel`; `onOpen`, `onCopy`, `onCancel`) | pilihan saat email atau nomor telepon di teks diketuk: kirim email/telepon atau salin |
| `imagePlaceholder` | `CommunityImagePlaceholderDetails` (`failed`) | placeholder & gagal muat `CommunityNetworkImage` |

Builder dialog mengembalikan widget dialog (mis. `AlertDialog`); `onConfirm`/`onCancel` sudah menutup dialog dengan hasilnya. Di dalam builder sebuah slot jangan memakai komponen yang memanggil slot yang sama (mis. `CommunityCard` di builder `card`); bungkus `fallback` atau gambar sendiri.

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
| `message` | `CommunityMessageDetails` | `message`, `isMine`, `receipt`, `showSender`, `startsGroup`, `endsGroup` (pesan terakhir grup berurutan: sudut ekor, avatar), `showAvatar` (room grup/saham, pesan lawan), `timeLabel`; `onReply`, `onDelete` (dengan konfirmasi bawaan), `onReport`, `onRetry`, `onSenderTap`, `onShowActions` (menu aksi bawaan) |
| `composer` | `CommunityComposerDetails` | `controller`, `focusNode`, `hintText`, `maxLength`, `uploading`, `uploadingLabel` ("Memeriksa file…" selama unggah, null bila tidak), `replyTo`, `replyPreview`, `allowsDocuments`, `attachmentPolicy` (`CommunityAttachmentPolicy` dari server), `attachLabel` (tooltip tombol lampiran), `files` (antrean `ChatOutgoingFile` dengan `kind`: `image`/`document`/`video`), `extraActions`; `onSend`, `onPickImage` (di chat CS memilih foto, video, dan dokumen sesuai daftar server), `onRemoveFile`, `onCancelReply` |
| `video` | `CommunityVideoDetails` | gelembung video chat CS: `attachment`, `name`, `durationLabel` ("0:42"), `duration`, `sizeLabel`, `color` (warna teks gelembung), `thumbnail` (widget gambar dari signed URL, null bila server tidak membuat thumbnail), `playsInApp` (false di Windows/Linux: video diunduh lalu dibuka pemutar sistem), `opening`, `semanticLabel`; `onPlay` (null saat sedang membuka) |
| `roomHeader` | `CommunityRoomHeaderDetails` | `room`, `title`, `subtitle`, `highlightSubtitle`, `online`, `typing`, `memberCount`; `onTap`, `onToggleMute`, `onLeave` |
| `typingIndicator` | `CommunityTypingDetails` | `users`, `text`, `count` (jumlah yang mengetik dari ringkasan room besar; `users` kosong) — dipanggil hanya saat ada yang mengetik |
| `connectionBanner` | `CommunityConnectionDetails` | `status`, `label` (dipanggil hanya saat menyambung ulang) |
| `dayDivider` | `CommunityDayDetails` | `day`, `label` |
| `floatingDate` | `CommunityDayDetails` | `day`, `label`; pil tanggal yang menempel di atas daftar saat menggulir pesan lama (muncul dan memudar diatur library) |
| `roomTile` | `CommunityRoomTileDetails` | `room`, `title`, `preview`, `typingText`, `timeLabel`, `online`, `selected`, `lastMessageReceipt`; `onTap` |
| `listHeader` | `CommunityChatListHeaderDetails` | `title`; `onNewGroup`, `onRefresh` |
| `loading` | `CommunityLoadingDetails` | `kind`: `rooms`, `moreRooms`, `messages`, `olderMessages` |
| `empty` | `CommunityEmptyDetails` | `kind`: `rooms`, `messages`, `noRoomSelected`; `message` |
| `error` | `CommunityErrorDetails` | `error`, `message` (terlokalisasi); `onRetry` |
| `stockCard` | `CommunityStockCardDetails` | `code`, `isMine`, `info` (dari `stockInfo` host); `onTap` (buka halaman saham) |
| `messageActions` (1.7.0) | `CommunityMessageActionsDetails` | sheet tekan lama: `message` (details pesan), `actions`, `moderationActions` (`CommunityMessageAction`: `icon`, `label`, `onSelected` menutup sheet lalu menjalankan aksi), `moderationLabel`, `moderationNote`; `onReact` |
| `deliveryNotice` (1.7.0) | `CommunityDeliveryNoticeDetails` | status di bawah pesan tertunda/gagal: `message`, `isMine`, `failed`, `label`, `errorLabel`; `onRetry`, `onDiscard` |
| `reactions` / `reactionPicker` (1.7.0) | `CommunityReactionsDetails` / `CommunityReactionPickerDetails` | chip reaksi (`reactions`, `isMine`; `onReact`) / pilihan emoji (`choices`, `selected`; `onSelected`) |
| `receipt` (1.7.0) | `CommunityReceiptDetails` | centang: `receipt`, `sendStatus`, `color`, `size`, `semanticLabel`, `read`, `readColor` (warna centang dibaca; gelembung sendiri memakai warna teks bila `readReceipt` kurang kontras); dipakai di gelembung dan tile |
| `roomAvatar` (1.7.0) | `CommunityRoomAvatarDetails` | `room`, `radius`, `online`; avatar room di tile, header, dan sheet bagikan |
| `roomNotice` (1.7.0) | `CommunityRoomNoticeDetails` | strip di atas pesan: `kind` (`pinned`, `slowMode`, `dmRequestReceived`, `dmRequestLimit`, `dmRequestSent`, `dmRequestInfo`), `icon`, `title`, `message`, `strong`, `pinned`, `actionLabel`; `onAction` (terima permintaan DM) |
| `moderationBanner` / `moderationDialog` (1.7.0) | `CommunityRoomModerationDetails` / `CommunityRoomModerationDialogDetails` | strip moderator/dibisukan (`kind`, `icon`, `message`, `mutedUntil`) / dialog sembunyikan-bisukan-eskalasi (`reasons`, `durations` sebagai `CommunitySettingsOption`, `reason`, `duration`, `noteController`, label; `onReasonChanged`, `onDurationChanged`, `onSubmit`, `onCancel`) |
| `sharedPost` (1.7.0) | `CommunitySharedPostDetails` | `postId`, `loading`, `available`, `post`, `color` (warna teks gelembung); `onOpen` |
| `stockCardPicker` (1.7.0) | `CommunityStockCardPickerDetails` | `controller`, `codes`, `max`, `error`; `onAdd`, `onRemove(code)`, `onSend`, `onCancel` |
| `newGroupDialog` (1.7.0) | `CommunityNewGroupDetails` | `nameController`, `queryController`, `results`, `selected`, `creating`, `canCreate`; `onNameChanged`, `onQueryChanged`, `onToggle(user, selected)`, `onCancel`, `onCreate` (null sampai nama terisi) |
| `shareTarget` (1.7.0) | `CommunityShareTargetDetails` | satu baris di sheet "Bagikan ke chat": `room`, `title`, `sending`; `onShare` (null saat kiriman lain berjalan) |
| `requestsEntry` / `requestTile` (1.7.0) | `CommunityRequestsEntryDetails` / `CommunityMessageRequestDetails` | baris "Permintaan pesan" di daftar chat (`count`, `label`; `onOpen`) / satu permintaan (`request`, `preview`, `timeLabel`, `countLabel`; `onOpen`) |
| `requestIntro` / `requestBubble` / `requestActions` (1.7.0) | `CommunityRequestIntroDetails` / `CommunityMessageDetails` / `CommunityRequestActionsDetails` | halaman permintaan: pengantar (`message`, `imageNotice`), gelembung pesan (tanpa handler, gambar tetap diburamkan di bawaan), tombol (`busy`, `responding`; `onAccept`, `onDecline`, `onBlock`) |

Contoh slot 1.7.0: chip reaksi datar, strip room bernada brand, dan sheet aksi ringkas.

```dart
CommunityChatBuilders(
  reactions: (context, d, fallback) => Wrap(
    spacing: 4,
    children: [
      for (final r in d.reactions)
        ActionChip(
          label: Text('${r.emoji} ${r.count}'),
          onPressed: d.onReact == null ? null : () => d.onReact!(r.emoji),
        ),
    ],
  ),
  roomNotice: (context, d, fallback) => d.kind == CommunityRoomNoticeKind.pinned
      ? ListTile(leading: Icon(d.icon), title: Text(d.title ?? ''), subtitle: Text(d.message, maxLines: 2))
      : fallback,
  messageActions: (context, d, fallback) => SafeArea(
    child: Wrap(
      children: [
        for (final a in [...d.actions, ...d.moderationActions])
          ListTile(leading: Icon(a.icon), title: Text(a.label), onTap: a.onSelected),
      ],
    ),
  ),
)
```

Status sheet bagikan dan halaman permintaan pesan memakai komponen bersama (`shared.skeleton`, `shared.emptyView`, `shared.errorView`), bukan nilai baru di `CommunityChatLoad`/`CommunityChatEmpty`, supaya `switch` lengkap di aplikasi host tidak rusak.

Aturan pakai:
- **Handler `null` berarti aksinya tidak berlaku.** Contohnya `onDelete` untuk pesan orang lain, atau `onRetry` untuk pesan yang sudah terkirim. Pasang langsung ke `onPressed` supaya tombol otomatis nonaktif.
- **Teks sudah terlokalisasi:** waktu, teks mengetik, pratinjau "Anda: …", subjudul header, pesan kosong, dan pesan error.
- **Kembalikan `fallback` untuk yang tidak ingin digambar sendiri**, misalnya pesan sistem, tautan bantuan, dan pilihan cepat dari CS.
- **Composer kustom sebaiknya menampilkan `extraActions`.** Tombol tambahan dari `leading` milik pemanggil (`MessageComposer`) masuk lewat sini.
- **Tile kustom wajib menampilkan `OfficialBadge` untuk room CS** (`room.pinned` bernilai `true`) supaya nasabah tetap bisa membedakan CS resmi dari akun palsu. Room CS selalu ada di urutan teratas daftar.
- **Pesan dari CS wajib tetap memperlihatkan penanda resmi.** Cara paling aman: kembalikan `fallback` bila `message.senderRole != null`, karena tampilan bawaan sudah memuat label CS Resmi, tautan bantuan, pilihan cepat, dan rating.
- **Widget `header:` dan `composer:` di `CommunityChatRoom` tetap didukung** dan didahulukan dari builder.
- **Builder ikut terbawa ke halaman yang dibuka package:** room di layar sempit, chat CS, riwayat tiket, dan (1.7.0) sheet aksi pesan, dialog moderasi room, pemilih kartu saham, dialog grup baru, sheet bagikan, serta halaman permintaan pesan.
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
| `comment` | `CommunityCommentDetails` | `comment`, `isMine`, `collapsed`, `timeLabel`, `edited`; `onLike`, `onReply`, `onToggleCollapse`, `onOpenAuthor`, `onEdit`, `onDelete`, `onReport`, `onBlock`, `onAppeal`; `level` (0 = tingkat atas, 1.7.0) |
| `loading` / `empty` / `error` | `CommunityListLoadingDetails` (`more`) / `CommunityListEmptyDetails` (`message`) / `CommunityListErrorDetails` (`error`, `message`, `onRetry`) | status daftar feed |

`postCard` menerima `fallback` berupa kartu bawaan yang sudah memakai builder bagian (`postHeader`, `postBody`, dan seterusnya), jadi host bisa mengganti kartu utuh untuk sebagian post saja. Sejak 1.7.0 `stockTags` bawaan kosong di feed (kode saham sudah tampil di isi) dan di detail post menjadi baris chip topik di atas judul (`$KODE`, `#hashtag` bila pencarian aktif, "+N" setelah tiga chip). Label moderasi milik sendiri ("Menunggu tinjauan", "Ajukan banding") tetap digambar package di kartu bawaan; kartu kustom bisa memakai `ModerationNotice(status: d.post.moderationStatus, onAppeal: d.onAppeal)`.

Tampilan bawaan 1.7.0 bergaya editorial ala Quora (lihat [design.md](design.md)): post full-bleed selebar layar di atas `surface`, dipisah jalur `style.sectionGap`; baris identitas (avatar + nama + meta) satu target sentuh; baris pertama yang pendek (≤ 100 karakter, diikuti teks lain) tampil sebagai judul tebal kecuali `postBody` diganti; isi di feed dipotong 4 baris dengan "Baca lebih lanjut" (membuka detail seperti ketukan kartu); gambar full-bleed; pil "Suka" berikon panah naik dengan hitungan ringkas, komentar, kirim ke chat, simpan. Di detail post, bar aksi menempel di atas kolom komentar (`actionBar` tetap dipakai; bila `postCard` diganti host, bar menempel tidak digambar). `postHeader` tetap hanya bagian di kanan avatar (nama, meta, sentimen, menu), `postAvatar` tetap avatarnya.

### Feed, thread, compose, media (1.7.0)

```dart
CommunityFeedBuilders(
  feedTabs: (context, d, fallback) => SegmentedButton<CommunityFeedTab>(
    segments: [for (final (i, tab) in d.tabs.indexed) ButtonSegment(value: tab, label: Text(d.labels[i]))],
    selected: {d.selected},
    onSelectionChanged: (s) => d.onSelect(s.first),
  ),
  postMenu: (context, d, fallback) => d.isMine ? fallback : IconButton(
    tooltip: 'Laporkan',
    onPressed: d.onReport,
    icon: const Icon(Icons.flag_outlined),
  ),
  threadMore: (context, d, fallback) => d.kind == CommunityThreadMoreKind.moreComments
      ? FilledButton.tonal(onPressed: d.onTap, child: Text(d.label))
      : fallback,
  replyComposer: (context, d, fallback) => Padding(
    padding: const EdgeInsets.all(8),
    child: Row(children: [
      Expanded(child: d.field),                       // TextField bawaan: Enter kirim, saran $KODE/@user
      IconButton(tooltip: d.sendLabel, onPressed: d.onSend, icon: const Icon(Icons.arrow_upward)),
    ]),
  ),
  composeToolbar: (context, d, fallback) => Row(children: [
    IconButton(tooltip: d.addImageLabel, onPressed: d.onPickImage, icon: const Icon(Icons.image_outlined)),
    const Spacer(),
    FilledButton(onPressed: d.onPost, child: Text(d.submitLabel)),
  ]),
  pollOption: (context, d, fallback) => d.showResults
      ? ListTile(title: Text(d.option.label), trailing: Text(d.percentLabel ?? ''))
      : fallback,
  attachmentImage: (context, d, fallback) => GestureDetector(
    onTap: () => openOltViewer(d.attachment),          // penampil milik host
    child: fallback,
  ),
)
```

| Builder | `details` | Isi |
|---|---|---|
| `postMenu` | `CommunityPostDetails` | menu "lainnya" di kanan header post |
| `feedTabs` | `CommunityFeedTabsDetails` | `tabs`, `labels`, `selected`; `onSelect(tab)` (tab Terbaru/Mengikuti di `CommunityStreamFeed`) |
| `newPosts` | `CommunityNewPostsDetails` | `count`, `label`; `onTap` (muat ulang dan gulir ke atas) |
| `composePrompt` | `CommunityComposePromptDetails` | `user`, `hintText`; `onCompose` (buka composer, post baru masuk ke feed) |
| `threadHeader` | `CommunityThreadHeaderDetails` | `post`, `commentCount`, `label` ("Komentar (7)") |
| `threadContext` | `CommunityThreadContextDetails` | `root`, `label`, `actionLabel`, `comment` (tile komentar akar bawaan); `onOpenPost` |
| `threadMore` | `CommunityThreadMoreDetails` | `kind` (`moreReplies`/`continueThread`/`moreComments`), `label`, `level`, `remaining`, `loading`; `onTap` (null saat memuat). Indentasi & garis thread tetap digambar package |
| `replyComposer` | `CommunityReplyComposerDetails` | `controller`, `focusNode`, `field`, `hintText`, `replyTo`, `replyingLabel`, `sending`, `sendLabel`, `cancelLabel`; `onSend` (null saat mengirim), `onCancelReply` |
| `composeToolbar` | `CommunityComposeDetails` | `controller`, `posting`, `uploading`, `hasPoll`, `imageCount`, `canPost`, label; `onPost`, `onPickImage`, `onAddPoll` (null bila tidak bisa) |
| `composeSentiment` | `CommunityComposeSentimentDetails` | `title`, `selected`, `options` (`bullish`, `bearish`, `neutral`, `null`), `labels`; `onChanged` |
| `composeAuthor` | `CommunityComposeAuthorDetails` | `user` (user masuk), `sentiment` terpilih; header avatar + nama di atas field compose |
| `composeImage` | `CommunityComposeImageDetails` | `attachment`, `name`, `held`, `removeLabel`; `onRemove` (null saat sibuk) |
| `pollEditor` | `CommunityPollEditorDetails` | `poll`, `options`, `duration`, `durationLabels`, `controllers` (satu per pilihan, milik package), `enabled`; `onAddOption`, `onRemoveOption(i)`, `onOptionChanged(i, teks)`, `onDurationChanged`, `onRemovePoll` |
| `pollOption` | `CommunityPollOptionDetails` | `option`, `index`, `share`, `percentLabel`, `showResults`, `resultsVisible`, `mine`, `leading`, `pending`; `onVote` |
| `attachmentImage` | `CommunityAttachmentImageDetails` | `attachment`, `index`, `count`, `held`, `blurred`, `image` (gambar bawaan tanpa overlay). Berlaku di semua `AttachmentGrid` (post, chat, pratinjau post) |
| `document` | `CommunityDocumentDetails` | kartu dokumen (juga di chat CS): `attachment`, `name`, `type` (`CommunityDocumentType`: `pdf`, `word`, `excel`, `powerPoint`, `csv`, `text`, `other`), `typeLabel` ("Word"), `sizeLabel` ("Word · 23 KB"), `color`, `opening`, `semanticLabel`; `onOpen` (null saat membuka; mengunduh lalu membuka di desktop, membuka signed URL di Android/iOS/web) |
| `draftTile` | `CommunityDraftDetails` | `draft`, `preview`, `timeLabel`, `subtitle`, `synced`, `deleteLabel`; `onOpen`, `onDelete` |
| `stockHeader` | `CommunityStockHeaderDetails` | `code`, `name`, `subtitle`, `found`, `loaded`, `watching`, `joining`, `watchLabel`, `discussionLabel`; `onToggleWatch`, `onOpenDiscussion` |
| `editDialog` | `CommunityEditDialogDetails` | `title`, `controller`, `field`, `maxLength`, `saveLabel`, `cancelLabel`; `onSave`, `onCancel`. Builder diambil dari context yang membuka dialog |

### Pencarian, hashtag, dan trending (1.7.0)

```dart
CommunityBuilders(
  discovery: CommunityDiscoveryBuilders(
    searchField: (context, d, fallback) => SearchBar(
      controller: d.controller,
      hintText: d.hintText,
      onChanged: d.onChanged,
      onSubmitted: (_) => d.onSubmitted(),
    ),
    hashtag: (context, d, fallback) => d.placement == CommunityHashtagPlacement.suggestion
        ? ActionChip(label: Text('#${d.tag}'), onPressed: d.onOpen)
        : fallback,
    trendingStock: (context, d, fallback) => ListTile(
      leading: Text('${d.rank}'),
      title: Text('\$${d.code}'),
      subtitle: Text(d.postsLabel),
      trailing: d.growthLabel == null ? null : Text(d.growthLabel!),
      onTap: d.onOpen,
    ),
  ),
)
```

`CommunitySearch(builders: ...)` dan `CommunityTrending(builders: ...)` menerima set ini secara lokal.

| Builder | `details` | Isi |
|---|---|---|
| `searchField` | `CommunitySearchFieldDetails` | `controller`, `hintText`, `clearLabel`, `autofocus`; `onChanged`, `onSubmitted`, `onClear` |
| `searchTabs` | `CommunitySearchTabsDetails` | `types`, `labels`, `selected`; `onSelect(type)` |
| `loading` / `empty` / `error` | `CommunityList*Details` | status pencarian dan trending |
| `userResult` | `CommunityUserResultDetails` | `result`, `user`, `subtitle`; `onOpen` |
| `stockResult` | `CommunityStockResultDetails` | `result`, `code`, `subtitle`, `watching`; `onOpen` |
| `hashtag` | `CommunityHashtagDetails` | `hashtag`, `tag`, `placement` (`searchResult`/`trending`/`suggestion`), `countLabel`, `rank`; `onOpen` |
| `hashtagHeader` | `CommunityHashtagHeaderDetails` | `tag`, `header` (header dari pemanggil `CommunityHashtagFeed`; bawaan tanpa header) |
| `trendingTabs` | `CommunityTrendingTabsDetails` | `tabs`, `labels`, `selected`, `window`, `windows`, `windowLabels`; `onSelect` (null bila hanya satu tab), `onWindowChanged` |
| `trendingStock` | `CommunityTrendingStockDetails` | `kind` (`trending`/`rising`), `rank`, `code`, `postsLabel`, `growthLabel`, `bullishPct`, `bearishPct`, `hasSentiment`; `onOpen` |
| `sentimentBar` | `CommunitySentimentBarDetails` | `bullishPct`, `bearishPct`, `neutralPct`, `height` |
| `stockSentiment` | `CommunityStockSentimentDetails` | `code`, `title`, `window`, `windows`, `windowLabels`, `loading`, `breakdown`, `hasData`, `error`, `errorMessage`, label; `onWindowChanged`, `onRetry` |

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

`item` (`CommunityNotificationDetails`: `notification`, `title`, `snippet`, `icon`, `timeLabel`, `important`, `isRead`, `isOlt`; `onTap`), `header` (`CommunityNotificationHeaderDetails`: `title`, `unread`, `onMarkAllRead`), `loading`/`empty`/`error` (detail daftar yang sama dengan feed). `header` adalah judul daftar. Daftar dibagi dua bagian berdasarkan status baca tanpa mengubah urutan: "Baru" (dari atas sampai notifikasi belum dibaca terakhir) dan "Sebelumnya" (sisanya); tanpa notifikasi belum dibaca tidak ada judul bagian. Judul bagian bisa diganti lewat `section` (`CommunityNotificationSectionDetails`: `section` = `CommunityNotificationSection.newer`/`earlier`, `title`).

Tampilan bawaan (1.7.0) bergaya Facebook/Instagram di atas `style.surface` dengan hairline `CommunityDivider`: avatar pelaku 44 + lencana jenis bulat di pojok (notifikasi sosial) atau lingkaran ikon 44 (notifikasi OLT, merah lembut bila penting), nama pelaku tebal di dalam kalimat ("**Rina** membalas Anda"), waktu abu kecil di bawah, latar `accentMuted` tipis + titik aksen selama belum dibaca. Untuk mengganti penanda jenisnya saja tanpa menulis ulang baris, pakai slot `icon`:

```dart
CommunityNotificationBuilders(
  icon: (context, d, fallback) => d.isOlt
      ? CircleAvatar(radius: d.size / 2, child: Icon(d.icon, size: d.size / 2))
      : fallback,                              // d.size < 32 = lencana di pojok avatar
)
```

`icon` (`CommunityNotificationIconDetails`: `notification`, `icon`, `important`, `size`, `isOlt`, `isRead`). Builder `item` tetap didahulukan; bila `item` diisi, `icon` tidak dipanggil kecuali `fallback` dipakai.

### Chat CS (1.7.0)

Semua bagian chat CS bisa diganti lewat `CommunityBuilders(support: CommunitySupportBuilders(...))`. Gelembung pesan tetap memakai `chat.message`; set `support` mengurus bagian khusus CS.

```dart
CommunityBuildersScope(
  builders: CommunityBuilders(
    support: CommunitySupportBuilders(
      header: (context, d, fallback) => ListTile(
        leading: const Icon(Icons.support_agent),
        title: Row(children: [Text(d.title), const SizedBox(width: 6), OfficialBadge(color: Colors.indigo)]),
        subtitle: Text([d.subtitle, ?d.statusLabel].join('\n')),
        trailing: IconButton(tooltip: d.menuTooltip, onPressed: d.onShowTickets, icon: const Icon(Icons.history)),
      ),
      closedBar: (context, d, fallback) => ListTile(
        title: Text(d.message),
        trailing: FilledButton(onPressed: d.onNewTicket, child: Text(d.newTicketLabel)),
      ),
      ratingDialog: (context, d, fallback) => AlertDialog(
        title: Text(d.title),
        content: Slider(
          min: 0,
          max: d.maxRating.toDouble(),
          divisions: d.maxRating,
          value: d.rating.toDouble(),
          onChanged: (v) => d.onRate(v.round()),
        ),
        actions: [
          TextButton(onPressed: d.onCancel, child: Text(d.cancelLabel)),
          FilledButton(onPressed: d.onSubmit, child: Text(d.submitLabel)),   // null sampai bintang dipilih
        ],
      ),
      ticketTile: (context, d, fallback) => ListTile(
        title: Text(d.title),
        subtitle: Text('${d.statusLabel} · ${d.meta}'),
        onTap: d.onOpen,
      ),
    ),
  ),
  child: const CommunitySupportChat(),
)
```

| Slot | Details | Isi |
|---|---|---|
| `header` | `CommunitySupportHeaderDetails` | `title` (nama CS), `subtitle` (`#nomor · topik` atau "Layanan resmi"), `ticket`, `ticketNumber`, `status`, `statusLabel`, `menuTooltip`, `busy`; `onComplaint`, `onReportFake`, `onEndChat`, `onNewTicket`, `onShowTickets`, `onClose` (null bila aksi tidak berlaku untuk tiket saat ini) |
| `banner` | `CommunitySupportBannerDetails` | `message`, `tone` (`neutral`/`info`/`warning`/`danger`), `icon`; bawaan: di luar jam layanan |
| `topicPicker` / `topicTile` | `CommunitySupportTopicPickerDetails` / `CommunitySupportTopicDetails` | daftar topik (`topics`, `title` dan `hint` dari server bila diatur di Hub, selain itu teks bawaan; `busy`, `historyLabel`; `onSelect(code)`, `onShowHistory`) / satu kartu topik (`topic` berisi `name`, `description`, kunci `icon`, `style` dari server; `icon` sebagai `IconData`, `urgent`, `danger`, `busy`; `onSelect`). Semua isi topik diatur dari Hub (Konten Layanan → Topik chat CS), jadi host tidak perlu menulis deskripsi atau ikon sendiri |
| `systemNotice` | `CommunitySupportNoticeDetails` | pesan sistem tiket: `message`, `text`, `icon`, `code`, `kind`, `timeLabel`, `rateLabel`; `onRate` hanya untuk CSAT yang masih bisa dinilai |
| `officialSender` | `CommunityOfficialSenderDetails` | `sender`, `name`, `color`; wajib tetap menampilkan penanda resmi agar nasabah bisa membedakan CS asli |
| `quickReplies` / `helpLink` | `CommunityQuickRepliesDetails` / `CommunityHelpLinkDetails` | pilihan cepat (`options`, `mine`, `enabled`; `onSelect`) / tautan panduan `https` (`uri`, `label`; `onOpen`) |
| `sensitiveWarning` | `CommunitySensitiveWarningDetails` | `kinds` (mis. `otp`, `card`), `message` yang sudah terlokalisasi |
| `closedBar` | `CommunitySupportClosedDetails` | `ticketNumber`, `message`, `newTicketLabel`; `onNewTicket` |
| `ratingDialog` | `CommunitySupportRatingDetails` | `rating`, `maxRating`, `controller` (komentar), label; `onRate(n)`, `onSubmit` (null sampai memilih), `onCancel` |
| `fakeCsWarning` | `CommunityFakeCsDetails` | dialog lapor CS palsu: `controller`, `title`, `hintText`, label; `onSubmit` (null bila < 5 huruf), `onCancel` |
| `ticketTile` | `CommunitySupportTicketDetails` | `ticket`, `number`, `title`, `statusLabel`, `meta` (tanggal · nilai), `timeLabel`, `icon`, `closed`; `onOpen` (buka transkrip) |
| `pageHeader` (1.8.0) | `CommunitySupportPageHeaderDetails` | header halaman **Tiket saya** dan transkrip tiket: `title` ("Tiket saya" / nama topik), `subtitle` (`#nomor` di transkrip), `ticket` (transkrip); `onBack` (null bila tidak bisa kembali), `onClose` (dari `CommunitySupportChat.onClose`, untuk menutup panel host). Bawaan: `AppBar` dengan tombol kembali dan tombol tutup |
| `loading` / `empty` / `error` | `CommunityListLoadingDetails` / `CommunityListEmptyDetails` / `CommunityListErrorDetails` | status awal chat CS dan daftar "Tiket saya" |

Dialog konfirmasi (akhiri chat, keluhan) memakai `shared.confirmDialog`. Dialog dibuka di rute baru, jadi builder `support` yang dipasang di bawah `MaterialApp` ikut terbawa ke `ratingDialog` dan `fakeCsWarning`.

### Pusat Bantuan

Semua bagian Pusat Bantuan (`CommunityHelpCenter`, `openCommunityHelpCenter`, `openCommunityHelpArticle`) dan langkah saran artikel di halaman pilih topik chat CS bisa diganti lewat `CommunityBuilders(help: CommunityHelpBuilders(...))`. Warna, huruf, dan mode gelap mengikuti `CommunityStyle` seperti bagian lain.

```dart
CommunityBuildersScope(
  builders: CommunityBuilders(
    help: CommunityHelpBuilders(
      categoryTile: (context, d, fallback) => ListTile(
        leading: Icon(d.icon),
        title: Text(d.title),
        subtitle: Text(d.countLabel),
        onTap: d.onOpen,
      ),
      contact: (context, d, fallback) => FilledButton.icon(
        onPressed: d.onContact,
        icon: const Icon(Icons.support_agent),
        label: Text('${d.title} ${d.actionLabel}'),
      ),
      articleDetail: (context, d, fallback) => ListView(
        padding: const EdgeInsets.all(16),
        children: [Text(d.title, style: const TextStyle(fontSize: 20)), d.body, d.feedback, d.contact],
      ),
    ),
  ),
  child: const CommunityHelpCenter(),
)
```

| Slot | Details | Isi |
|---|---|---|
| `searchField` | `CommunityHelpSearchDetails` | `controller`, `hintText`, `clearLabel`, `searching`; `onChanged(teks)`, `onClear` |
| `categoryTile` | `CommunityHelpCategoryDetails` | `category` (`HelpCategory`: `code`, `name`, kunci `icon`, `articles`), `icon` sebagai `IconData`, `title`, `countLabel` ("2 artikel"), `code`, `articleCount`; `onOpen` |
| `articleTile` | `CommunityHelpArticleTileDetails` | `article` (`HelpArticle`), `title` (pertanyaan), `subtitle` (nama kategori di hasil pencarian); `onOpen` |
| `articleDetail` | `CommunityHelpArticleDetails` | `article`, `title`, `answer`, `topic`, `categoryName`, `updatedLabel` ("Diperbarui 3 November 2026"), `loading`, `offline`, dan widget siap pakai `body` (jawaban yang sudah dirender), `feedback`, `contact` |
| `feedback` | `CommunityHelpFeedbackDetails` | `question`, `yesLabel`, `noLabel`, `thanksLabel`, `commentLabel`, `submitLabel`, `commentSentLabel`, `controller` (komentar), `maxCommentLength` (500), `feedback`/`helpful`/`voted` (pilihan tersimpan), `busy`, `commentSent`; `onVote(bool)` (null saat mengirim), `onSubmitComment` (null sebelum memilih) |
| `contact` | `CommunityHelpContactDetails` | `title` ("Masih butuh bantuan?"), `actionLabel` ("Chat CS"), `topic` (topik chat CS artikel, bisa null); `onContact` |
| `offlineNotice` | `CommunityHelpOfflineDetails` | `message`, `retryLabel`, `savedAt` (waktu isi tersimpan); `onRetry` |
| `topicSuggestions` | `CommunityHelpSuggestionsDetails` | langkah "Mungkin ini membantu" di chat CS: `topicCode`, `topic` (`SupportTopic`), `title`, `hint`, `articles` (maks. 3), `continueLabel`, `backLabel`, `busy`; `onOpenArticle(article)`, `onContinue` (buat tiket), `onBack` (kembali ke daftar topik) |
| `loading` / `empty` / `error` | `CommunityListLoadingDetails` / `CommunityListEmptyDetails` / `CommunityListErrorDetails` | status awal, FAQ atau hasil pencarian kosong, dan galat (termasuk artikel yang sudah tidak terbit) |

Untuk merender jawaban di tampilan sendiri, pakai `CommunityHelpMarkdown(article.answer)`: aturan Markdown dan keamanan tautan/gambar sama dengan bawaan (`onLinkTap` dan `imageBuilder` opsional untuk mengganti cara membuka tautan dan menampilkan gambar). Host yang tidak memakai `RendezvousCommunity.initialize` (misalnya tes) memasang `CommunityHelpScope(dependencies: ...)` dengan `HelpRepository` sendiri; tanpa scope dan tanpa inisialisasi, halaman pilih topik CS tetap berjalan seperti sebelumnya tanpa saran artikel.

### Pengaturan, moderasi, dan dokumen hukum (1.7.0)

Halaman pengaturan akun, kebijakan DM, preferensi notifikasi, dialog laporan/banding, daftar banding, alur persetujuan, dan pembaca dokumen hukum diganti lewat `CommunityBuilders(settings: CommunitySettingsBuilders(...))`. Dialog dan halaman yang dibuka library (laporan, banding, hapus akun, persetujuan, dokumen, "Banding saya", "Pengaturan notifikasi") membawa builder dari konteks pemanggil, jadi cukup memasang scope sekali di atas widget komunitas.

```dart
CommunityBuildersScope(
  builders: CommunityBuilders(
    settings: CommunitySettingsBuilders(
      accountTile: (context, d, fallback) => ListTile(
        leading: Icon(d.icon, color: d.destructive ? Colors.red : null),
        title: Text(d.title),
        subtitle: Text(d.subtitle),
        trailing: d.busy ? const CircularProgressIndicator() : null,
        onTap: d.onTap,                                   // null saat sibuk
      ),
      notificationType: (context, d, fallback) => SwitchListTile(
        title: Text(d.label),
        subtitle: d.description == null ? null : Text(d.description!),
        value: d.push,
        onChanged: d.onPushChanged,                       // d.onInAppChanged null bila terkunci
      ),
      reportDialog: (context, d, fallback) => AlertDialog(
        title: Text(d.title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final option in d.options)
            ChoiceChip(
              label: Text(option.label),
              selected: option.value == d.selected,
              onSelected: (_) => d.onSelect?.call(option.value),
            ),
          TextField(controller: d.controller, maxLength: d.maxLength, decoration: InputDecoration(hintText: d.hintText)),
        ]),
        actions: [
          TextButton(onPressed: d.onCancel, child: Text(d.cancelLabel)),
          FilledButton(onPressed: d.onSubmit, child: Text(d.submitLabel)),
        ],
      ),
      appealTile: (context, d, fallback) => d.kind == CommunityAppealTileKind.appeal ? fallback : ListTile(
        leading: Icon(d.icon, color: d.color),
        title: Text(d.title),
        subtitle: Text(d.subtitle),
        trailing: d.onAppeal == null ? null : TextButton(onPressed: d.onAppeal, child: Text(d.appealLabel)),
      ),
      error: (context, d, fallback) => d.area == CommunitySettingsArea.consent
          ? fallback
          : ListTile(title: Text(d.message), trailing: TextButton(onPressed: d.onRetry, child: Text(d.retryLabel))),
    ),
  ),
  child: const CommunityAccountSettings(),
)
```

| Slot | Details | Isi |
|---|---|---|
| `dmPolicy` | `CommunityDmPolicyDetails` | `policy`, `title`, `options` (`CommunitySettingsOption`: `value`, `label`, `hint`), `saving`; `onChanged` (null saat menyimpan) |
| `notificationType` | `CommunityNotificationTypeDetails` | satu baris jenis notifikasi: `preference`, `label`, `description`, `supportsInApp`, `inApp`, `push`, `locked`, `isOlt`; `onInAppChanged` (null bila tidak didukung/terkunci), `onPushChanged` |
| `reportDialog` | `CommunityReportDetails` | `target`, `options`, `selected`, `controller`, `hintText`, `maxLength`, `submitting`, `errorMessage`; `onSelect`, `onSubmit`, `onCancel` |
| `appealDialog` | `CommunityAppealDialogDetails` | `targetType`, `title`, `hint`, `controller`, `maxLength`, `canSubmit`, `submitting`, `errorMessage`; `onSubmit` (null bila alasan belum valid), `onCancel` |
| `appealTile` | `CommunityAppealTileDetails` | baris sanksi / konten dimoderasi / banding: `kind`, `icon`, `color`, `title`, `subtitle`, `appealLabel`, data mentah (`sanction`, `moderated`, `appeal`, `status`); `onAppeal` |
| `consent` | `CommunityConsentDetails` | isi alur persetujuan: `documents`, `title`, `intro`, `agreeLabel`, `agreed`, `canAccept`, `submitting`, `errorMessage`; `onAgreedChanged`, `onAccept`, `onLater`, `onOpenDocument` |
| `legalDocumentTile` | `CommunityLegalDocumentTileDetails` | satu dokumen hukum di alur persetujuan atau pengaturan akun (`placement`): `document`, `icon`, `meta`, `changes`, `actionLabel`; `onOpen` |
| `legalReader` | `CommunityLegalReaderDetails` | pembaca dokumen: `document`, `title` (null bila judul di app bar), `meta`, `changes`, `body`, `padding` |
| `accountTile` | `CommunityAccountTileDetails` | baris aksi akun: `kind` (`appeals`/`exportData`/`deleteAccount`), `icon`, `title`, `subtitle`, `destructive`, `busy`; `onTap` |
| `deleteAccountDialog` | `CommunityDeleteAccountDetails` | `consequences`, `controller`, `confirmWord`, `fieldLabel`, `canConfirm`, `deleting`, `errorMessage`, label; `onConfirm` (null sampai kata konfirmasi cocok), `onCancel` |
| `loading` / `empty` / `error` | `CommunitySettingsLoadingDetails` / `CommunitySettingsEmptyDetails` / `CommunitySettingsErrorDetails` | status per bagian; `area` menyebut bagiannya (`appeals`, `sanctions`, `moderatedContent`, `myAppeals`, `legalDocuments`, `consent`, `dmPolicy`, `notificationPreferences`) |

Builder dialog mengembalikan isi dialog (mis. `AlertDialog`); library yang membuka dan menutup rutenya. Kunci `community-delete-confirmation` hanya ada di tampilan bawaan.

### Banner, kill switch, dan offline (1.7.0)

Bagian sistem diganti lewat `CommunityBuilders(system: CommunitySystemBuilders(...))`. Parameter lama tetap didahulukan: `CommunityBannerHost(builder:)`, `CommunitySocialGate(unavailableBuilder:)`/`CommunityAvailabilityScope`, `CommunityOfflineBanner(builder:)`, dan `chat.connectionBanner` di room chat; slot `system` dipakai di tampilan bawaan masing-masing.

```dart
CommunityBuildersScope(
  builders: CommunityBuilders(
    system: CommunitySystemBuilders(
      banner: (context, d, fallback) => MaterialBanner(
        leading: Icon(d.icon),
        content: Text('${d.title}\n${d.message}'),
        actions: [
          if (d.onOpen != null) TextButton(onPressed: d.onOpen, child: Text(d.openLabel)),
          if (d.onDismiss != null) TextButton(onPressed: d.onDismiss, child: Text(d.dismissLabel)),
        ],
      ),
      unavailable: (context, d, fallback) => d.socialDisabled
          ? OltMaintenanceIllustration(title: d.title!, message: d.message)
          : fallback,
      offlineBanner: (context, d, fallback) => OltOfflineStrip(text: d.message),
      consentBanner: (context, d, fallback) => Card(
        child: ListTile(
          title: Text(d.message),
          trailing: TextButton(onPressed: d.onReview, child: Text(d.reviewLabel)),
        ),
      ),
    ),
  ),
  child: child,
)
```

| Slot | Details | Isi |
|---|---|---|
| `banner` | `CommunityBannerDetails` | `banner`, `title`, `message`, `level` (`info`/`warning`/`critical`), `icon`, `openLabel`, `dismissLabel`; `onOpen` (null tanpa tautan), `onDismiss` (null bila tidak bisa ditutup) |
| `unavailable` | `CommunityUnavailableDetails` | `reason` (`socialDisabled` = kill switch, `featureDisabled` = fitur dimatikan), `icon`, `title` (null untuk fitur mati), `message` |
| `offlineBanner` | `CommunityOfflineDetails` | `message`; dipakai `CommunityOfflineNotice`, termasuk strip offline di daftar chat dan room |
| `consentBanner` | `CommunityConsentBannerDetails` | `documents`, `message`, `updated`, `reviewLabel`, `dismissLabel`, `margin`; `onReview` (membuka alur persetujuan), `onDismiss` |
| `popup` | `CommunityPromoPopupDetails` | isi kartu popup promo (overlay 60%, animasi, tombol kembali tetap milik paket): `banner`, `imageUrl`, `title`, `body`, `dismissible`, `ctaLabel` (`cta_label` atau "Lihat"), `laterLabel` ("Nanti", atau "Tutup" tanpa tautan), `closeLabel` (label ✕), `semanticLabel`; `onCta` (null tanpa tautan; menutup, mencatat `click`, lalu membuka tautan), `onClose` (menutup dan mencatat `dismiss`), `hasLink` |

"Perlu update" tidak punya tampilan bawaan; tangani lewat `CommunityUpdateListener(onUpdateRequired:)`.

#### Popup promo

Popup promo (banner `display: "popup"`, lihat [features.md](features.md#popup-promo-170)) baru tampil bila host memasang `CommunityPromoPopupHost` sekali, di halaman utama di bawah `Navigator` (bukan di `MaterialApp.builder`, karena popup menunggu route host berada paling atas):

```dart
MaterialApp(
  builder: (context, child) => CommunityBuildersScope(builders: oltBuilders, child: child!),
  home: CommunityPromoPopupHost(
    enabled: !onboardingVisible,                                // false: tunda popup
    onBannerLink: (context, uri, banner) => oltRouter.tryOpen(context, uri), // true = sudah ditangani
    child: const OltHomePage(),
  ),
);
```

Isi kartunya diganti lewat slot `system.popup`; overlay, animasi masuk, tombol kembali, dan pencatatan event tetap dari paket. Builder wajib memberi jalan keluar: panggil `d.onClose` dari salah satu tombol, terutama bila `d.dismissible` false.

```dart
system: CommunitySystemBuilders(
  popup: (context, d, fallback) => Center(
    child: OltPromoCard(
      image: d.imageUrl,
      title: d.title,
      body: d.body,
      primary: d.hasLink ? OltButton(label: d.ctaLabel, onTap: d.onCta) : null,
      secondary: OltTextButton(label: d.laterLabel, onTap: d.onClose),
      showClose: d.dismissible,
    ),
  ),
),
```

`CommunityPromoPopupCard(banner:, onCta:, onClose:)` merender kartu bawaan (beserta slot) tanpa dialog, mis. untuk pratinjau; `showCommunityPromoPopup(context, banner)` menampilkan satu banner sebagai popup tanpa aturan frekuensi.

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

`header`, `stats`, `followButton`, `messageButton` (1.7.0, tombol Kirim pesan), dan `menu` (1.7.0, menu laporkan/blokir di header) menerima `CommunityProfileDetails`: `profile`, `busy`, `isMe`, `isFollowing`, label statistik terlokalisasi; `onToggleFollow`, `onMessage`, `onEdit` (dialog edit bawaan), `onReport`, `onBlock`, `onUnblock`.

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

