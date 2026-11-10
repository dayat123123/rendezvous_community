# Inventaris builder (acuan tahap 2)

[← Kembali ke README](../README.md) · [Panduan desain](design.md) · [Kustomisasi](customization.md)

Daftar semua widget visual di `lib/src/shared/presentation/widgets` dan `lib/src/features/**/presentation/widgets`, status builder-nya, dan usulan slot untuk yang belum punya. Dipakai dua agen tahap 2 saat menerapkan gaya editorial ke semua fitur.

## Cara membaca tabel

- **Builder**: `ya (set.slot)` berarti bagian itu sudah bisa diganti lewat `CommunityPartBuilder`; `fallback` berarti widget ini adalah tampilan bawaan builder lain (bukan bagian tersendiri); `n/a` untuk widget non-visual (scope, listener, layout).
- **Usulan**: nama `*Details` + slot di set builder yang disebut. Semua mengikuti pola yang sama: `CommunityPartBuilder<T> = (context, details, fallback)`, handler `null` berarti aksi tidak berlaku, teks sudah terlokalisasi.
- Kolom **Pub** = diekspor dari `package:rendezvous_community/rendezvous_community.dart`.

## Set builder dan pemiliknya

| Set | Scope | Pemilik tahap 2 | Isi |
|---|---|---|---|
| `CommunitySharedBuilders` (`shared`) | `CommunitySharedBuildersScope` | tahap 1 (selesai) | komponen dasar & widget bersama, lihat di bawah |
| `CommunityBadgeBuilders` (`badges`) | `CommunityBadgeBuildersScope` | tetap | semua badge label & hitungan |
| `CommunityFeedBuilders` (`feed`) | `CommunityFeedBuildersScope` | **A** | feed, kartu post, komentar, thread, compose, polling, link preview, media, bookmark, draf, feed saham, dialog edit |
| `CommunityProfileBuilders` (`profile`) | `CommunityProfileBuildersScope` | **A** | profil user |
| `CommunityDiscoveryBuilders` (`discovery`) | `CommunityDiscoveryBuildersScope` | **A** | pencarian, hashtag, trending, sentimen saham (13 slot, tahap 2 sudah) |
| `CommunityChatBuilders` (`chat`) | `CommunityChatBuildersScope` | **B** | chat, room, pesan, permintaan pesan (30 slot, 18 baru di tahap 2) |
| `CommunityNotificationBuilders` (`notifications`) | `CommunityNotificationBuildersScope` | **B** | daftar notifikasi (6 slot, `icon` baru di tahap 2) |
| `CommunitySupportBuilders` (`support`) | `CommunitySupportBuildersScope` | **B** | chat CS, tiket, rating, gangguan, pertanyaan awal, survei, saran balasan (22 slot) |
| `CommunitySettingsBuilders` (`settings`) | `CommunitySettingsBuildersScope` | **B** | pengaturan akun & notifikasi, kebijakan DM, dokumen hukum, banding, laporan (13 slot, tahap 2 sudah) |
| `CommunitySystemBuilders` (`system`) | `CommunitySystemBuildersScope` | **B** | banner konfigurasi, kill switch, offline, banner persetujuan, popup promo (5 slot, tahap 2 sudah) |
| `CommunityHelpBuilders` (`help`) | `CommunityHelpBuildersScope` | – | Pusat Bantuan/FAQ dan saran artikel di pilih topik CS (11 slot, lihat [customization.md](customization.md#pusat-bantuan)) |

Keempat set baru sudah tersambung ke `CommunityBuilders` (`discovery`, `support`, `settings`, `system`: field, `of`, `merge`, `wrap`, `_same`) dan diekspor. Tahap 2 cukup menambah field slot ke file set miliknya sendiri, lengkap dengan `merge` per field (diawasi `test/tool/merge_completeness_test.dart`; tambahkan `'<Set>.merge'` ke daftar tes begitu set punya field). File `*_details.dart` dibuat di folder `builders/` fitur yang sama. Agen A tidak menyentuh set milik B dan sebaliknya; `community_builders.dart` dan `rendezvous_community.dart` tidak perlu diubah lagi kecuali untuk ekspor file details baru (tambahkan satu baris, urut abjad).

## Shared (tahap 1, selesai)

| Widget | Pub | Builder | Details |
|---|---|---|---|
| `CommunityAvatar` | ya | ya (`shared.avatar`) | `CommunityAvatarDetails` (`user`, `name`, `initials`, `radius`, `size`, `image`, `online`; `onTap`) |
| `CommunityUserName` | tidak | ya (`shared.userName`) | `CommunityUserNameDetails` (`user`, `official`, `verified`, `showUsername`, `usernameLabel`, `style`) |
| `CommunityOfficialBadge` | tidak | ya (`badges.official`) | `CommunityLabelBadgeDetails` |
| `_VerifiedBadge` | tidak | ya (`badges.verified`) | `CommunityVerifiedBadgeDetails` |
| `CommunityCountBadge`, `CommunityCountOverlay` | ya | ya (`badges.count`, `badges.countOverlay`) | `CommunityCountBadgeDetails`, `CommunityCountOverlayDetails` |
| `CommunityBotBadge` | ya | ya (`badges.bot`) | `CommunityLabelBadgeDetails` |
| `CommunityCard` (baru) | ya | ya (`shared.card`) | `CommunityCardDetails` (`child`, `padding`, `margin`, `selected`; `onTap`, `onLongPress`) |
| `CommunityAuthorRow` (baru) | ya | ya (`shared.authorRow`) | `CommunityAuthorRowDetails` (`user`, `avatar`, `name`, `meta`, `official`, `trailing`; `onOpenAuthor`) |
| `CommunityActionPill` (baru) | ya | ya (`shared.actionPill`) | `CommunityActionPillDetails` (`icon`, `activeIcon`, `effectiveIcon`, `label`, `count`, `countLabel`, `text`, `active`, `tooltip`; `onPressed`) |
| `CommunityActionButton` (baru) | ya | ya (`shared.actionButton`) | `CommunityActionButtonDetails` (`icon`, `activeIcon`, `tooltip`, `count`, `countLabel`, `active`; `onPressed`) |
| `CommunityActionBar` (baru) | ya | ya (`shared.actionBar`) | `CommunityActionBarDetails` (`leading`, `trailing`) |
| `CommunitySectionHeader` (baru) | ya | ya (`shared.sectionHeader`) | `CommunitySectionHeaderDetails` (`title`, `subtitle`, `actionLabel`, `trailing`; `onAction`) |
| `CommunityDivider` (baru) | ya | ya (`shared.divider`) | `CommunityDividerDetails` (`indent`, `endIndent`, `height`) |
| `CommunityTag` (baru) | ya | ya (`shared.tag`) | `CommunityTagDetails` (`label`, `icon`, `selected`; `onTap`) |
| `CommunitySkeleton` (statis), `CommunitySkeletonBox` (baru) | ya | ya (`shared.skeleton`, per item) | `CommunitySkeletonDetails` (`index`, `itemCount`, `custom`) |
| `CommunityLoadingView` (baru) | ya | ya (`shared.loadingView`) | `CommunityLoadingViewDetails` (`message`) |
| `CommunityEmptyView` | ya | ya (`shared.emptyView`) | `CommunityEmptyViewDetails` (`message`, `icon`, `action`, `title` opsional) |
| `CommunityErrorView` | ya | ya (`shared.errorView`) | `CommunityErrorViewDetails` (`error`, `message`; `onRetry`) |
| `CommunityDisclaimer` | ya | ya (`shared.disclaimer`) | `CommunityDisclaimerDetails` (`text`, `padding`) |
| `ModerationNotice` (penuh & ringkas) | ya | ya (`shared.moderationNotice`) | `CommunityModerationNoticeDetails` (`status`, `held`, `label`, `hint`, `icon`, `color`, `compact`; `onAppeal`, null bila ditahan) |
| `HeldAttachmentLabel` | ya | ya (`shared.heldLabel`) | `CommunityHeldLabelDetails` (`label`, `icon`, `foreground`, `background`) |
| `CommunityComposerField` (saran `$KODE`/`@user`) | ya | ya (`shared.composerSuggestion`, per baris) | `CommunityComposerSuggestionDetails` (`kind`, `title`, `subtitle`, `leading`, `highlighted`; `onSelect`) |
| `CommunityNetworkImage` (placeholder/gagal) | ya | ya (`shared.imagePlaceholder`) | `CommunityImagePlaceholderDetails` (`failed`) |
| `confirmCommunityAction` (dialog) | tidak | ya (`shared.confirmDialog`) | `CommunityConfirmDetails` (`message`, `confirmLabel`, `cancelLabel`; `onConfirm`, `onCancel`) |
| `openCommunityLink` (dialog tautan) | ya | ya (`shared.linkDialog`) | `CommunityLinkConfirmDetails` (`uri`, `domain`, `title`, `body`, `confirmLabel`, `cancelLabel`; `onConfirm`, `onCancel`) |
| `showCommunityContactActions` (email/telepon di teks) | ya | ya (`shared.contactActions`) | `CommunityContactActionsDetails` (`uri`, `value`, `phone`, `openLabel`, `copyLabel`, `cancelLabel`; `onOpen`, `onCopy`, `onCancel`) |
| `SocialText` | ya | token saja | warna tautan `CommunityTheme.link`; gaya teks dari pemanggil (`style: CommunityStyle.of(context).typography.body`) |
| `showCommunityError`, `showCommunityMessage` (SnackBar) | tidak | tema host | ikut `SnackBarTheme` host; tidak perlu builder |

## Kelompok A

Status tahap 2: **sudah** untuk semua baris di bawah. Revisi gaya Quora: feed, detail, pencarian, trending, profil, dan header saham memakai section full-bleed (`EditorialSection`, `EditorialSectionHeader` di `feed/presentation/widgets/editorial_section.dart`, header lewat slot `shared.sectionHeader`) dan jalur `style.sectionGap`; `CommunityCard` inset tidak berubah. `AttachmentGrid(edgeToEdge: true)` untuk gambar post di feed/detail; chat tetap memakai grid inset. Kolom terakhir mencatat slot yang dipakai dan perbedaan nama field dari usulan awal (bila ada).

### Feed (`features/feed`)

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunityFeedList` | ya | n/a (pembungkus) | sudah: latar `style.background` |
| `FeedPostList` | tidak | ya (`feed.loading`, `feed.empty`, `feed.error`, `feed.newPosts`) | sudah: kartu dipisah `spacing.sm`, skeleton kartu statis; tombol "post baru" → `CommunityNewPostsDetails` (`count`, `label`; `onTap`) |
| `FeedPostCard`, `PostCard` | tidak | ya (`feed.postCard`) | sudah: section full-bleed (tanpa margin, border, radius), judul dari baris pertama pendek, isi 4 baris + "Baca lebih lanjut", gambar full-bleed; detail dengan bar aksi menempel (`PostCard(actionsOnly:)` internal) |
| `_DefaultPostCard` | tidak | fallback | sudah: identitas (avatar + nama + meta) satu target sentuh ≥ 48 |
| `PostCardHeader` | tidak | ya (`feed.postHeader`) | sudah: nama + badge, meta `@username · waktu · (diedit)`, sentimen, menu |
| `PostTopics` (baru) | tidak | ya (`feed.stockTags`) | sudah: kosong di feed; di detail chip topik persegi membulat di atas judul, "+N" setelah tiga |
| `PostActionBar`, `_ActionButton` | tidak | ya (`feed.actionBar`) | sudah: `CommunityActionBar` + pil suka (`communityCountText`) + tombol komentar & simpan |
| `_PostMenu` | tidak | ya (`feed.postMenu`) | sudah: `CommunityPostDetails`; ikon `more_horiz` |
| `PinnedPostCard`, `_DefaultPinnedMarker` | tidak | ya (`feed.pinnedMarker`) | sudah: penanda di atas kartu |
| `CommunityStreamFeed` (tab) | ya | ya (`feed.feedTabs`) | sudah: `CommunityFeedTabsDetails` (`tabs`, `labels`, `selected`; `onSelect`); fallback chip `CommunityTag` |
| `ComposePromptCard` | tidak | ya (`feed.composePrompt`) | sudah: `CommunityComposePromptDetails` (`user`, `hintText`; `onCompose`) |
| `SentimentBadge`, `_DefaultSentimentBadge` | ya | ya (`badges.sentiment`) | sudah: token (pil, `typography.badge`) |

### Post & komentar (`features/post`)

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunityPostDetail`, `_PostDetailView` | ya | ya (`feed.postCard`, `feed.comment`, `feed.threadHeader`) | sudah: `CommunityThreadHeaderDetails` (`post`, `commentCount`, `label`); fallback `CommunitySectionHeader`; komentar tingkat atas dipisah `CommunityDivider` |
| `_ThreadContext` | tidak | ya (`feed.threadContext`) | sudah: `CommunityThreadContextDetails` (`root`, `label`, `actionLabel`, `comment`; `onOpenPost`), menggantikan `ancestors`/`onOpenRoot` karena state hanya punya satu komentar akar |
| `_ReplyComposer` | tidak | ya (`feed.replyComposer`) | sudah: `CommunityReplyComposerDetails` (`controller`, `focusNode`, `hintText`, `field`, `replyTo`, `replyingLabel`, `sending`, `sendLabel`, `cancelLabel`; `onSend`, `onCancelReply`) |
| `CommentTile` | tidak | ya (`feed.comment`) | sudah: gaya Facebook, gelembung abu radius 16 (nama tebal + teks), baris kecil "waktu · Suka · Balas · ⋯" (target 48), jumlah suka dalam pil kecil, tombol ciutkan di samping gelembung; avatar `comment` (32), balasan `reply` (24); `CommunityCommentDetails.level` memberi tingkat indentasi |
| `ThreadRowView`, `_Indented` | tidak | ya (`feed.threadMore`) | sudah: `CommunityThreadMoreDetails` (`kind`: `moreReplies`/`continueThread`/`moreComments`, `label`, `level`, `remaining`, `loading`; `onTap`); indentasi `CommunityTheme.threadIndent` (bawaan 40) dengan garis 1 px `threadLine` di tengah avatar induk; "Lanjutkan thread →" dan "Lihat N balasan" berupa teks aksen kecil |

### Compose (`features/compose`)

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunityComposePost`, `showCommunityComposer`, `_ComposeView` | ya | ya (`feed.composeAuthor`, `feed.composeToolbar`, `feed.composeSentiment`) | sudah: `CommunityComposeDetails` (`controller`, `posting`, `uploading`, `hasPoll`, `imageCount`, label; `onPost`, `onPickImage`, `onAddPoll`; `canPost`); `CommunityComposeSentimentDetails` (`title`, `selected`, `options`, `labels`; `onChanged`). `CommunityComposeAuthorDetails` (`user`, `sentiment`) untuk header avatar + nama (hanya bila ada user masuk); field tanpa border, toolbar berupa tombol berlabel (gambar, polling) dan tombol Kirim selebar konten. Composer tidak punya tombol simpan draf/tutup, jadi handler itu tidak ada |
| Chip lampiran compose | tidak | ya (`feed.composeImage`) | sudah: `CommunityComposeImageDetails` (`attachment`, `name`, `held`, `removeLabel`; `onRemove`) |
| `CommunityComposerImage` | ya | n/a (data gambar awal) | – |
| `PollEditor` | tidak | ya (`feed.pollEditor`) | sudah: `CommunityPollEditorDetails` (`poll`, `options`, `duration`, `controllers`, `durationLabels`, `title`, `enabled`; `onAddOption`, `onRemoveOption`, `onOptionChanged`, `onDurationChanged`, `onRemovePoll`) |

### Polling, link preview, media

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunityPollView` | ya | ya (`feed.poll`) | sudah |
| `_PollBody`, `_VoteButton`, `_ResultBar` | tidak | ya (`feed.pollOption`) | sudah: `CommunityPollOptionDetails` (`option`, `index`, `share`, `percentLabel`, `showResults`, `resultsVisible`, `mine`, `leading`, `pending`; `onVote`); bar hasil membulat |
| `LinkPreviewCard`, `_PreviewCard` | ya | ya (`feed.linkPreview`) | sudah: kartu bergaris tipis, gambar radius `image` |
| `AttachmentGrid` | ya | ya (`feed.attachments` untuk post, `feed.attachmentImage` per gambar) | sudah: `CommunityAttachmentImageDetails` (`attachment`, `index`, `count`, `held`, `blurred`, `image`). Berlaku di mana pun grid dipakai (post, chat, pratinjau post). Tidak ada `onOpen`: library belum punya penampil media, jadi tidak ditambah |
| `_AttachmentImage` | tidak | fallback | sudah: placeholder `skeleton` |
| `DocumentAttachments`, `_DocumentTile` | tidak | ya (`feed.document`) | sudah: `CommunityDocumentDetails` (`attachment`, `name`, `type`, `typeLabel`, `sizeLabel`, `color`, `opening`, `semanticLabel`; `onOpen`) |
| `VideoAttachments`, `_VideoTile` | tidak | ya (`chat.video`) | sudah: `CommunityVideoDetails` (`attachment`, `name`, `durationLabel`, `sizeLabel`, `color`, `thumbnail`, `playsInApp`, `opening`, `semanticLabel`, `downloadLabel`, `downloading`; `onPlay`, `onDownload`) |
| `CommunityVideoPlayerPage`, `showCommunityVideoPlayer` | ya | tidak (layar penuh `video_player`; host bisa memakai `chat.video` + `onPlay` sendiri) | – |

### Pencarian, hashtag, trending (`features/search`, `features/trending`) → set `discovery`

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunitySearch`, `openCommunitySearch`, `_SearchView` | ya | ya (`discovery.searchField`, `discovery.searchTabs`) | sudah: `CommunitySearchFieldDetails` (`controller`, `hintText`, `clearLabel`, `autofocus`; `onChanged`, `onSubmitted`, `onClear`); `CommunitySearchTabsDetails` (`types`, `labels`, `selected`; `onSelect`). `CommunitySearch(builders:)` baru |
| `_SearchBody`, `_Section` | tidak | ya (`discovery.loading/empty/error`) | sudah: `_Section` → `CommunitySectionHeader`; status → `CommunityList*Details` |
| `_UserTile` | tidak | ya (`discovery.userResult`) | sudah: `CommunityUserResultDetails` (`result`, `user`, `subtitle`; `onOpen`) |
| `_StockTile` | tidak | ya (`discovery.stockResult`) | sudah: `CommunityStockResultDetails` (`result`, `code`, `subtitle`, `watching`; `onOpen`); nama saham tidak tersedia di hasil |
| `_HashtagTile`, `_TrendingHashtagsView` | tidak | ya (`discovery.hashtag`) | sudah: `CommunityHashtagDetails` (`hashtag`, `tag`, `placement`: `searchResult`/`trending`/`suggestion`, `countLabel`, `rank`; `onOpen`) |
| `DiscoveryTile`, `DiscoveryIcon` (baru) | tidak | fallback | baris ringkas bersama untuk hasil & trending |
| `CommunityHashtagFeed` | ya | ya (feed builders, `discovery.hashtagHeader`) | sudah: `CommunityHashtagHeaderDetails` (`tag`, `header`); fallback = `header` dari pemanggil. Jumlah post tidak tersedia di layar ini |
| `CommunityTrending`, `_TrendingView` (tab) | ya | ya (`discovery.trendingTabs`) | sudah: `CommunityTrendingTabsDetails` (`tabs`, `labels`, `selected`, `window`, `windows`, `windowLabels`; `onSelect`, `onWindowChanged`); `CommunityTrending(builders:)` baru |
| `_TrendingStockTile`, `_RisingStockTile` | tidak | ya (`discovery.trendingStock`) | sudah: `CommunityTrendingStockDetails` (`kind`, `rank`, `code`, `postsLabel`, `growthLabel`, `bullishPct`, `bearishPct`; `onOpen`) |
| Baris hashtag trending | tidak | ya (`discovery.hashtag`, `placement: trending`) | sudah |
| `SentimentBar` | ya | ya (`discovery.sentimentBar`) | sudah: `CommunitySentimentBarDetails` (`bullishPct`, `bearishPct`, `neutralPct`, `height`); segmen kini terlihat (sebelumnya tingginya 0) |
| `CommunityStockSentiment`, `_SentimentView` | ya | ya (`discovery.stockSentiment`) | sudah: `CommunityStockSentimentDetails` (`code`, `title`, `window`, `windows`, `windowLabels`, `loading`, `breakdown`, `error`, `errorMessage`, label; `onWindowChanged`, `onRetry`); loading memakai skeleton statis |

### Bookmark, draf, profil, saham, edit

| Widget | Pub | Builder | Status |
|---|---|---|---|
| `CommunityBookmarks` | ya | ya (feed builders lewat daftar post) | sudah |
| `CommunityPostDrafts`, `openCommunityPostDrafts`, `_DraftsView` | ya | ya (`feed.draftTile`) | sudah: `CommunityDraftDetails` (`draft`, `preview`, `timeLabel`, `subtitle`, `synced`, `deleteLabel`; `onOpen`, `onDelete`) |
| `CommunityUserProfile`, `_ProfileHeader` | ya | ya (`profile.header`, `profile.stats`, `profile.followButton`, `profile.messageButton`, `profile.menu`; `chat.officialNotice` 1.16.0) | sudah: gaya Instagram, avatar `profile` (80) kiri dan statistik ringkas (post/pengikut/mengikuti, angka `communityCountText`, semantik memakai label lengkap) di kanan; nama, @username, bio di bawah; tombol Ikuti/Pesan selebar setengah. Profil tidak punya tab, jadi tidak ditambah |
| `CommunityStockFeed`, `_StockHeader` | ya | ya (`feed.stockHeader`) | sudah: `CommunityStockHeaderDetails` (`code`, `name`, `subtitle`, `found`, `loaded`, `watching`, `joining`, `watchLabel`, `discussionLabel`; `onToggleWatch`, `onOpenDiscussion`) |
| `showEditContentDialog`, `_EditContentDialog` | tidak | ya (`feed.editDialog`) | sudah: `CommunityEditDialogDetails` (`title`, `controller`, `maxLength`, `field`, `saveLabel`, `cancelLabel`; `onSave`, `onCancel`); builder diambil dari context pemanggil |

## Kelompok B

### Chat (`features/chat`)

| Widget | Pub | Builder | Details |
|---|---|---|---|
| `CommunityChatBadge` | ya | ya (`badges.countOverlay`) | – |
| `CommunityChatList`, `_RoomList`, `_DefaultListHeader` | ya | ya (`chat.listHeader`, `chat.roomTile`, `chat.loading`, `chat.empty`, `chat.error`) | daftar di atas `surface`, judul 22/w700, hairline antar room |
| `_ListVisibility`, `_ChatListLayout` | tidak | n/a (layout) | – |
| `CommunityChatRoom`, `_ChatRoomView` | ya | ya (`chat.loading`, `chat.error`) | – |
| `_ReconnectBanner`, `_OfflineBanner`, `_RealtimeBanner` | tidak | ya (`chat.connectionBanner`) | strip lembut `tertiary` (menyambung ulang) / `system.offlineBanner` (offline) |
| `_TypingIndicator`, `TypingBubble` | tidak | ya (`chat.typingIndicator`) | gelembung tiga titik (avatar 28 di grup/saham bila satu orang); animasi 8 siklus lalu diam, mati bila `MediaQuery.disableAnimations`; teks hanya sebagai label semantik |
| `MessageBubble`, `_DefaultBubble` | tidak | ya (`chat.message`) | gaya WhatsApp/Messenger: milik sendiri terisi aksen (`myBubble`), lawan abu (`otherBubble`); radius 18, sudut sambung 6, ekor 4 hanya pada pesan terakhir grup (`endsGroup`); jarak 2 dalam grup, 10 antar grup; di grup/saham avatar 28 di pesan terakhir grup dan nama berwarna (per pengirim, AA) di pesan pertama; waktu + centang di kanan bawah (sebaris bila muat); kutipan balasan bergaris aksen + nama; pratinjau tautan di atas teks; gambar dibulatkan; reaksi menumpang di sudut bawah (−8) |
| `MessageBubble._showActions`, `_DefaultMessageActions` (sheet tekan lama) | tidak | sudah (`chat.messageActions`) | `CommunityMessageActionsDetails` (`message`: `CommunityMessageDetails`, `actions`, `moderationActions`: `CommunityMessageAction` (`icon`, `label`; `onSelected` menutup sheet lalu menjalankan aksi), `moderationLabel`, `moderationNote`; `onReact`) |
| `MessageDeliveryNotice` | ya | sudah (`chat.deliveryNotice`) | `CommunityDeliveryNoticeDetails` (`message`, `isMine`, `failed`, `label`, `errorLabel`; `onRetry`, `onDiscard`) |
| `ReactionPicker` | ya | sudah (`chat.reactionPicker`) | `CommunityReactionPickerDetails` (`choices`, `selected`; `onSelected`) |
| `ReactionChips` | ya | sudah (`chat.reactions`) | `CommunityReactionsDetails` (`reactions`, `isMine`; `onReact` null bila reaksi tidak berlaku); parameter baru opsional `isMine`. Pil ringkas tinggi 24 menumpang di gelembung; bila builder `reactions` diisi, hasilnya ditaruh di bawah gelembung (tidak menumpang) |
| `MessageComposer`, `_DefaultComposer` | tidak | ya (`chat.composer`) | pil `pill` berisi ikon lampiran + field; tombol kirim bulat 48 di kanan, abu saat kosong dan aksen saat berisi (tetap bisa ditekan seperti sebelumnya); kutipan balasan bergaris tautan |
| `MessageList`, `_DayDivider` | tidak | ya (`chat.dayDivider`, `chat.loading`, `chat.empty`) | pemisah tanggal: chip pil `chip` di tengah |
| `showNewGroupDialog`, `_NewGroupDialog` | tidak | sudah (`chat.newGroupDialog`) | `CommunityNewGroupDetails` (`nameController`, `queryController`, `results`, `selected`, `creating`, `canCreate`, `isSelected()`; `onNameChanged`, `onQueryChanged`, `onToggle`, `onCancel`, `onCreate` null sampai nama terisi) |
| `ReceiptIcon` | ya | sudah (`chat.receipt`) | `CommunityReceiptDetails` (`receipt`, `sendStatus`, `color`, `size`, `semanticLabel`, `read`, `readColor`); parameter baru opsional `readColor` |
| `StockRoomBanner`, `DmRequestNotice`, `RoomNotice` | tidak | sudah (`chat.roomNotice`) | `CommunityRoomNoticeDetails` (`kind`: `pinned`/`slowMode`/`dmRequestReceived`/`dmRequestLimit`/`dmRequestSent`/`dmRequestInfo`, `icon`, `title`, `message`, `strong`, `pinned`, `actionLabel`; `onAction`) |
| `RoomHeader`, `_DefaultRoomHeader` | tidak | ya (`chat.roomHeader`) | bar `surface` + hairline bawah, avatar `medium`, subjudul `meta` (hijau saat online/mengetik) |
| `RoomModerationDialog` | tidak | sudah (`chat.moderationDialog`) | `CommunityRoomModerationDialogDetails` (`action`, `memberName`, `title`, `body`, `confirmLabel`, `cancelLabel`, `reasonLabel`, `reasons`/`durations`: `CommunitySettingsOption`, `reason`, `duration`, `durationLabel`, `noteController`, `noteHint`, `destructive`; `onReasonChanged`, `onDurationChanged` hanya untuk bisukan, `onSubmit`, `onCancel`) |
| `RoomModeratorBadge`, `_DefaultModeratorBadge` | ya | ya (`badges.roomModerator`) | – |
| `RoomModerationBanner` | ya | sudah (`chat.moderationBanner`) | `CommunityRoomModerationDetails` (`kind`: `muted`/`moderator`, `icon`, `message`, `mutedUntil`) |
| `RoomTile`, `_DefaultRoomTile` | tidak | ya (`chat.roomTile`) | gaya Instagram DM: avatar 52 (titik online), nama tebal hanya bila belum dibaca, ikon sematan/bisu kecil di samping nama, pratinjau 1 baris + " · waktu" (tebal bila belum dibaca), badge aksen di kanan, hairline berindentasi 80. Tanpa kolom cari (belum ada fungsi cari room) |
| `CommunityRoomAvatar`, `roomAvatar` | ya | sudah (`chat.roomAvatar`) | `CommunityRoomAvatarDetails` (`room`, `radius`, `online`); dipakai juga oleh tile, header, dan sheet bagikan |
| `showSharePostToChat`, `_SharePostSheet` | ya | sudah (`chat.shareTarget`) | `CommunityShareTargetDetails` (`room`, `title`, `sending`; `onShare` null saat ada kiriman berjalan); status sheet lewat `shared.skeleton`/`emptyView`/`errorView` |
| `SharedPostCard` | ya | sudah (`chat.sharedPost`) | `CommunitySharedPostDetails` (`postId`, `loading`, `available`, `post`, `color`; `onOpen` null bila post tidak tersedia) |
| `StockCards`, `StockCardTile` | ya | ya (`chat.stockCard`) | kartu `surface` berborder, perubahan harga dalam pil `bullish`/`bearish` |
| `StockCardPicker`, `showStockCardPicker` | ya | sudah (`chat.stockCardPicker`) | `CommunityStockCardPickerDetails` (`controller`, `codes`, `max`, `error`; `onAdd`, `onRemove`, `onSend`, `onCancel`) |

Dialog, sheet, dan halaman yang didorong chat (aksi pesan, moderasi, kartu saham, grup baru, bagikan, permintaan pesan) membawa builder lewat `carryCommunityBuilders`, jadi slot di atas tetap berlaku di rute baru.

### Permintaan pesan (`features/message_requests`)

| Widget | Pub | Builder | Details |
|---|---|---|---|
| `MessageRequestsEntry` | ya | sudah (`chat.requestsEntry`) | `CommunityRequestsEntryDetails` (`count`, `label`; `onOpen`) |
| `CommunityMessageRequests`, `openCommunityMessageRequests`, `_RequestsView` | ya | sudah (`chat.requestTile`) | `CommunityMessageRequestDetails` (`request`, `preview`, `timeLabel`, `countLabel`; `onOpen`); status lewat `shared.*` |
| `MessageRequestRoom`, `_RequestRoomView` | tidak | sudah (`chat.requestIntro`, `chat.requestActions`) | `CommunityRequestIntroDetails` (`request`, `message`, `imageNotice`); `CommunityRequestActionsDetails` (`request`, `busy`, `responding`; `onAccept`, `onDecline`, `onBlock` null saat sibuk) |
| `_RequestBubble` | tidak | sudah (`chat.requestBubble`) | `CommunityMessageDetails` (tanpa handler; `isMine` selalu `false`) |
| `CommunityDmPolicySettings`, `_PolicyView` | ya | sudah (`settings.dmPolicy`, `settings.loading`, `settings.error`) | `CommunityDmPolicyDetails` (`policy`, `title`, `options`: `CommunitySettingsOption<DmPolicy>` (`value`, `label`, `hint`), `saving`; `onChanged` null saat menyimpan) |

### Chat CS (`features/support`) → set `support`

| Widget | Pub | Builder | Details |
|---|---|---|---|
| `CommunitySupportBadge` | ya | ya (`badges.countOverlay`) | – |
| `CommunitySupportChat`, `CommunitySupportPage`, `openCommunitySupport`, `_SupportView`, `_Conversation` | ya | sudah (`support.loading`, `support.error`; pesan lewat `chat.message`) | `CommunityListLoadingDetails`, `CommunityListErrorDetails` |
| `CommunitySupportTickets`, `SupportTicketTile` | ya | sudah (`support.ticketTile`, `support.loading`, `support.empty`, `support.error`) | `CommunitySupportTicketDetails` (`ticket`, `number`, `title`, `statusLabel`, `meta`, `timeLabel`, `icon`, `closed`; `onOpen`) |
| `SupportSubpage`, `SupportTranscriptPage` (header **Tiket saya** dan transkrip) | tidak | sudah (`support.pageHeader`, 1.8.0) | `CommunitySupportPageHeaderDetails` (`title`, `subtitle`, `ticket`, `downloadLabel`, `downloading`, `canDownload`; `onBack`, `onClose`, `onDownload`) |
| `SupportIncidentBanners`, `SupportIncidentBanner` (chat CS, pilih topik, Pusat Bantuan) | tidak | sudah (`support.incidentBanner`) | `CommunitySupportIncidentDetails` (`incident`, `title`, `body`, `level`, `tone`, `icon`, `levelLabel`, `dismissLabel`, `moreLabel`; `onDismiss`, `onMore`) |
| `SupportIntakeForm`, `SupportIntakeFieldView` | tidak | sudah (`support.intakeForm`, `support.intakeField`) | `CommunitySupportIntakeDetails` (`topic`, `fields`, `answers`, `errors`, `fieldViews`, `notice`, label, `busy`; `onSubmit`, `onBack`); `CommunitySupportIntakeFieldDetails` (`field`, `type`, `label`, `value`, `error`, `controller`, `dateLabel`; `onChanged`, `onPickDate`) |
| `SupportReplySuggestions` | tidak | sudah (`support.replySuggestions`) | `CommunitySupportReplySuggestionsDetails` (`replies`, `label`, `enabled`; `onSelect`) |
| `SupportSurveyReasonsView`, `SupportRatingFaces` | tidak | sudah (`support.surveyReasons`; wajah lewat `support.ratingDialog`) | `CommunitySupportSurveyReasonsDetails` (`reasons`, `selected`, `title`, `hint`; `onToggle`) |
| `SupportComposer` | tidak | sudah (`support.sensitiveWarning`; field lewat `chat.composer`) | `CommunitySensitiveWarningDetails` (`kinds`, `message`) |
| `SupportClosedBar` | tidak | sudah (`support.closedBar`) | `CommunitySupportClosedDetails` (`ticketNumber`, `message`, `newTicketLabel`; `onNewTicket`) |
| `askSupportRating`, `SupportRatingDialog`, `SupportRatingStars` | tidak | sudah (`support.ratingDialog`) | `CommunitySupportRatingDetails` (`rating`, `maxRating`, `controller`, `title`, `commentLabel`, `submitLabel`, `cancelLabel`, `canSubmit`, `survey`, `values`, `faces`, `ratingLabels`, `asksReasons`, `selectedReasons`, `reasons`; `onRate`, `onSubmit` null bila belum memilih nilai, `onCancel`, `onToggleReason`) |
| `askFakeCsReport`, `_FakeCsDialog` | tidak | sudah (`support.fakeCsWarning`) | `CommunityFakeCsDetails` (`controller`, `title`, `hintText`, `submitLabel`, `cancelLabel`, `canSubmit`; `onSubmit` null bila < 5 huruf, `onCancel`) |
| `confirmSupport` | tidak | sudah (`shared.confirmDialog`) | `CommunityConfirmDetails` |
| `SupportHeader`, `_DefaultSupportHeader`, `SupportBanner` | tidak | sudah (`support.header`, `support.banner`) | `CommunitySupportHeaderDetails` (`title`, `subtitle`, `menuTooltip`, `ticket`, `ticketNumber`, `status`, `statusLabel`, `busy`; `onComplaint`, `onReportFake`, `onEndChat`, `onNewTicket`, `onShowTickets`, `onClose`); `CommunitySupportBannerDetails` (`message`, `tone`: `neutral`/`info`/`warning`/`danger`, `icon`) |
| `SupportSystemNotice` | tidak | sudah (`support.systemNotice`) | `CommunitySupportNoticeDetails` (`message`, `text`, `icon`, `code`, `kind`, `timeLabel`, `rateLabel`; `onRate` hanya untuk CSAT yang bisa dinilai) |
| `OfficialSenderLabel` | tidak | sudah (`support.officialSender`) | `CommunityOfficialSenderDetails` (`sender`, `name`, `color`); builder wajib tetap menampilkan penanda resmi (mis. `OfficialBadge`) |
| `OfficialBadge`, `_DefaultSupportOfficialBadge` | ya | ya (`badges.supportOfficial`) | – |
| `SupportMessageExtras`, `_QuickReplies`, `_HelpLink` | tidak | sudah (`support.quickReplies`, `support.helpLink`) | `CommunityQuickRepliesDetails` (`message`, `options`, `mine`, `enabled`; `onSelect` null untuk pesan sendiri); `CommunityHelpLinkDetails` (`uri`, `label`; `onOpen`, hanya `https`) |
| `SupportTopicPicker`, `SupportTopicTile` | tidak | sudah (`support.topicPicker`, `support.topicTile`) | `CommunitySupportTopicPickerDetails` (`topics`, `title`, `hint`, `busy`, `historyLabel`; `onSelect`, `onShowHistory`); `CommunitySupportTopicDetails` (`topic`, `icon`, `busy`, `urgent`; `onSelect` null saat sibuk) |
| `CommunitySupportMessageActions` | ya | n/a (InheritedWidget) | – |

### Notifikasi (`features/notifications`)

| Widget | Pub | Builder | Usulan |
|---|---|---|---|
| `CommunityNotificationList`, `_NotificationHeader`, `_NotificationTile`, `_OltNotificationTile`, `_NotificationRow`, `_NotificationSectionHeader` | ya | sudah (`notifications.item`, `header`, `icon`, `section`, `loading`, `empty`, `error`) | `CommunityNotificationSectionDetails` (`section`, `title`) untuk judul "Baru"/"Sebelumnya"; `CommunityNotificationIconDetails` (`notification`, `icon`, `important`, `size`, `isOlt`, `isRead`) untuk penanda jenis (lencana kecil di avatar sosial 44, lingkaran 44 untuk notifikasi OLT) |
| `NotificationTypeIcon` | tidak | sudah (`notifications.icon`) | lihat di atas |
| `CommunityNotificationBadge` | ya | ya (`badges.countOverlay`) | – |
| `CommunityNotificationSettings`, `openCommunityNotificationSettings`, `_SettingsView`, `_TypeRow` | ya | sudah (`settings.notificationType`, `settings.loading`, `settings.error`) | `CommunityNotificationTypeDetails` (`preference`, `type`, `label`, `description`, `inAppLabel`, `pushLabel`, `supportsInApp`, `inApp`, `push`, `locked`, `isOlt`; `onInAppChanged` null bila tidak didukung/terkunci, `onPushChanged`) |

### Moderasi, banding, hukum, akun → set `settings`

| Widget | Pub | Builder | Usulan |
|---|---|---|---|
| `showReportDialog`, `_ReportDialog`, `DefaultReportDialog` (`features/moderation`) | tidak | sudah (`settings.reportDialog`) | `CommunityReportDetails` (`target`, `targetId`, `title`, `options`, `selected`, `controller`, `hintText`, `maxLength`, `submitting`, `submitLabel`, `cancelLabel`, `error`, `errorMessage`; `onSelect`, `onSubmit`/`onCancel` null saat mengirim) |
| `showCommunityAppealDialog`, `_AppealDialog`, `DefaultAppealDialog` | ya | sudah (`settings.appealDialog`) | `CommunityAppealDialogDetails` (`targetType`, `title`, `hint`, `controller`, `maxLength`, `canSubmit`, `submitting`, `submitLabel`, `cancelLabel`, `error`, `errorMessage`; `onSubmit` null bila alasan belum valid, `onCancel`) |
| `CommunityAppeals`, `openCommunityAppeals`, `_AppealsView`, `_AppealTile` | ya | sudah (`settings.appealTile`, `settings.loading`, `settings.empty`, `settings.error`) | `CommunityAppealTileDetails` (`kind`: `sanction`/`moderatedContent`/`appeal`, `icon`, `color`, `title`, `subtitle`, `appealLabel`, `sanction`, `moderated`, `appeal`, `status`; `onAppeal` null bila sudah dibanding); judul bagian → `CommunitySectionHeader` |
| `CommunityConsentView`, `showCommunityConsent`, `_ConsentBody`, `_ConsentFailure`, `CommunityLegalDocumentTile` | ya | sudah (`settings.consent`, `settings.legalDocumentTile`, `settings.loading`, `settings.error`) | `CommunityConsentDetails` (`documents`, `title`, `intro`, `agreeLabel`, `agreed`, `submitting`, `canAccept`, `acceptLabel`, `laterLabel`, `error`, `errorMessage`; `onAgreedChanged`, `onAccept`, `onLater`, `onOpenDocument`); `CommunityLegalDocumentTileDetails` (`document`, `placement`: `consent`/`accountSettings`, `icon`, `title`, `meta`, `changes`, `actionLabel`; `onOpen`) |
| `CommunityLegalDocumentReader`, `showCommunityLegalDocument` | ya | sudah (`settings.legalReader`) | `CommunityLegalReaderDetails` (`document`, `title` null bila judul di app bar, `meta`, `changesLabel`, `changes`, `body`, `padding`) |
| `CommunityAccountSettings`, `openCommunityAccountSettings`, `_AccountSettingsView`, `_AccountTile` | ya | sudah (`settings.accountTile`, `settings.legalDocumentTile`, `settings.loading`, `settings.error`) | `CommunityAccountTileDetails` (`kind`: `appeals`/`exportData`/`deleteAccount`, `icon`, `title`, `subtitle`, `destructive`, `busy`, `enabled`; `onTap` null saat sibuk); judul bagian → `CommunitySectionHeader` |
| `DeleteAccountDialog`, `DefaultDeleteAccountDialog` | tidak | sudah (`settings.deleteAccountDialog`) | `CommunityDeleteAccountDetails` (`title`, `intro`, `consequences`: `CommunityDeleteConsequence` (`icon`, `text`), `controller`, `confirmWord`, `fieldLabel`, `confirmLabel`, `cancelLabel`, `progressLabel`, `canConfirm`, `deleting`, `error`, `errorMessage`; `onConfirm` null sampai kata konfirmasi cocok, `onCancel` null saat menghapus) |
| status di bagian pengaturan | – | sudah (`settings.loading`, `settings.empty`, `settings.error`) | `CommunitySettingsLoadingDetails`, `CommunitySettingsEmptyDetails` (`message`), `CommunitySettingsErrorDetails` (`error`, `message`, `retryLabel`; `onRetry`); semuanya membawa `area`: `appeals`/`sanctions`/`moderatedContent`/`myAppeals`/`legalDocuments`/`consent`/`dmPolicy`/`notificationPreferences` |

### Konfigurasi, offline, persetujuan → set `system`

| Widget | Pub | Builder | Usulan |
|---|---|---|---|
| `CommunityBannerHost` | ya | sudah (tiap item lewat `system.banner`; parameter `builder` host tetap didahulukan) | – |
| `CommunityPromoPopupHost`, `showCommunityPromoPopup` | ya | sudah (isi kartu lewat `system.popup`; overlay, animasi, dan tombol kembali tetap milik paket) | – |
| `CommunityPromoPopupCard` | ya | sudah (`system.popup`, 1.7.0) | `CommunityPromoPopupDetails` (`banner`, `imageUrl`, `title`, `body`, `dismissible`, `ctaLabel`, `laterLabel`, `closeLabel`, `semanticLabel`, `hasLink`; `onCta` null tanpa tautan, `onClose`) |
| `CommunityBannerCard` | ya | sudah (`system.banner`) | `CommunityBannerDetails` (`banner`, `title`, `message`, `level`, `icon`, `openLabel`, `dismissLabel`; `onOpen` null tanpa tautan, `onDismiss` null bila tidak bisa ditutup) |
| `CommunitySocialGate`, `CommunityUnavailableView` | ya | sudah (`system.unavailable`; `unavailableBuilder`/`CommunityAvailabilityScope` tetap didahulukan) | `CommunityUnavailableDetails` (`reason`: `socialDisabled`/`featureDisabled`, `icon`, `title` null untuk fitur mati, `message`, `socialDisabled`). "Perlu update" tidak punya tampilan bawaan: host menanganinya lewat `CommunityUpdateListener` |
| `CommunityAvailabilityScope`, `CommunityUpdateListener` | ya | n/a (scope/listener) | – |
| `CommunityOfflineBanner`, `CommunityOfflineNotice` | ya | sudah (`system.offlineBanner`; parameter `builder` banner dan `chat.connectionBanner` di room tetap didahulukan) | `CommunityOfflineDetails` (`message`) |
| `CommunityConsentBanner` | ya | sudah (`system.consentBanner`) | `CommunityConsentBannerDetails` (`documents`, `message`, `updated`, `reviewLabel`, `dismissLabel`, `margin`; `onReview`, `onDismiss`) |

### Tanpa widget

`features/analytics`, `features/push`, `features/edit` (selain dialog di atas), `features/offline` (selain banner), `post_actions.dart`, `typing_text.dart`: logika saja, tidak ada yang perlu builder.

## Ringkasan

Hitungan per nama kelas/fungsi di kolom pertama (satu baris tabel bisa memuat beberapa nama, mis. widget publik + view privatnya + fungsi `show*`/`open*`):

| | Shared | A | B | Total |
|---|---|---|---|---|
| Nama widget/fungsi visual | 30 | 64 | 114 | 208 |
| Sudah punya builder | 27 | 18 | 32 | 77 |
| Fallback dari builder lain | – | 5 | – | 5 |
| Non-visual (`n/a`) | – | 1 | 5 | 6 |
| Cukup token/tema host | 3 | – | – | 3 |
| Belum punya builder / baru sebagian | 0 | 40 | 77 | 117 |
| Baris usulan slot (pekerjaan tahap 2) | 0 | 24 | 41 | 65 |

Widget yang hanya sebagian bisa diganti (mis. `CommunityPostDetail`, `SupportComposer`) dihitung "belum".

Angka di atas adalah kondisi awal tahap 2. Kelompok A: ke-24 baris usulan sudah dikerjakan (18 slot baru di `feed`, 13 di `discovery`, 1 di `profile`), lihat kolom Status.

Kelompok B: ke-41 baris usulan sudah dikerjakan (18 slot baru di `chat`, 16 di `support`, 13 di `settings`, 4 di `system`, 1 di `notifications`). Status chat & permintaan pesan diganti lewat `shared.*` (bukan nilai enum baru di `CommunityChatLoad`/`CommunityChatEmpty`, supaya `switch` di host tidak rusak); status pengaturan membawa `area` sendiri.

## Checklist per widget (tahap 2)

1. Ganti nilai hard-coded dengan token `CommunityStyle` (warna, spasi, radius, tipografi) dan komponen dasar (`CommunityCard`, `CommunityAuthorRow`, `CommunityActionPill`/`Button`/`Bar`, `CommunityDivider`, `CommunityTag`, `CommunitySectionHeader`, state view). Jangan mengubah urutan handler, teks, kunci tes, atau alur.
2. Tambahkan slot builder bila tabel menandai "tidak": details immutable `const`, handler `null` bila aksi tidak berlaku, fallback = tampilan bawaan.
3. Tambahkan tes: builder menerima details & menimpa tampilan, fallback dipakai tanpa builder, `merge` per field.
4. Tambahkan scene di `tool/screenshots/` (terang & gelap), jalankan harness, periksa PNG.
