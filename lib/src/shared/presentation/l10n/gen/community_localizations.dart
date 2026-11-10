import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'community_localizations_en.dart';
import 'community_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CommunityLocalizations
/// returned by `CommunityLocalizations.of(context)`.
///
/// Applications need to include `CommunityLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/community_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CommunityLocalizations.localizationsDelegates,
///   supportedLocales: CommunityLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CommunityLocalizations.supportedLocales
/// property.
abstract class CommunityLocalizations {
  CommunityLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CommunityLocalizations? of(BuildContext context) {
    return Localizations.of<CommunityLocalizations>(context, CommunityLocalizations);
  }

  static const LocalizationsDelegate<CommunityLocalizations> delegate = _CommunityLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('id'), Locale('en')];

  /// No description provided for @disclaimer.
  ///
  /// In id, this message translates to:
  /// **'Konten ini opini pengguna, bukan rekomendasi investasi.'**
  String get disclaimer;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @you.
  ///
  /// In id, this message translates to:
  /// **'Anda'**
  String get you;

  /// No description provided for @edited.
  ///
  /// In id, this message translates to:
  /// **'(diedit)'**
  String get edited;

  /// No description provided for @justNow.
  ///
  /// In id, this message translates to:
  /// **'baru saja'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In id, this message translates to:
  /// **'{count} mnt'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In id, this message translates to:
  /// **'{count} j'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In id, this message translates to:
  /// **'{count} h'**
  String daysAgo(int count);

  /// No description provided for @errorNetwork.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi. Periksa jaringan Anda.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthenticated.
  ///
  /// In id, this message translates to:
  /// **'Sesi berakhir. Silakan login ulang di OLT.'**
  String get errorUnauthenticated;

  /// No description provided for @errorRateLimited.
  ///
  /// In id, this message translates to:
  /// **'Terlalu cepat. Coba lagi sebentar lagi.'**
  String get errorRateLimited;

  /// No description provided for @errorContentBlocked.
  ///
  /// In id, this message translates to:
  /// **'Konten mengandung kata atau frasa yang tidak diizinkan.'**
  String get errorContentBlocked;

  /// No description provided for @errorInvalidInput.
  ///
  /// In id, this message translates to:
  /// **'Data tidak valid.'**
  String get errorInvalidInput;

  /// No description provided for @errorForbidden.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak memiliki akses untuk aksi ini.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In id, this message translates to:
  /// **'Konten tidak ditemukan atau sudah dihapus.'**
  String get errorNotFound;

  /// No description provided for @errorUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Layanan sedang tidak tersedia. Coba lagi nanti.'**
  String get errorUnavailable;

  /// No description provided for @errorUnknown.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get errorUnknown;

  /// No description provided for @feedLatest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get feedLatest;

  /// No description provided for @feedFollowing.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti'**
  String get feedFollowing;

  /// No description provided for @feedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post. Jadilah yang pertama!'**
  String get feedEmpty;

  /// No description provided for @feedFollowingEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post dari user yang Anda ikuti.'**
  String get feedFollowingEmpty;

  /// No description provided for @stockFeedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada diskusi tentang \${code}.'**
  String stockFeedEmpty(String code);

  /// No description provided for @userFeedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post.'**
  String get userFeedEmpty;

  /// No description provided for @newPosts.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 post baru} other{{count} post baru}}'**
  String newPosts(int count);

  /// No description provided for @composePrompt.
  ///
  /// In id, this message translates to:
  /// **'Apa pendapat Anda tentang pasar hari ini?'**
  String get composePrompt;

  /// No description provided for @composeTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat post'**
  String get composeTitle;

  /// No description provided for @composeHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis analisis Anda. Gunakan \$KODE untuk menandai saham dan @username untuk menyebut user.'**
  String get composeHint;

  /// No description provided for @composeSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get composeSubmit;

  /// No description provided for @composeCharsLeft.
  ///
  /// In id, this message translates to:
  /// **'{count} karakter tersisa'**
  String composeCharsLeft(int count);

  /// No description provided for @composeAddImage.
  ///
  /// In id, this message translates to:
  /// **'Tambah gambar'**
  String get composeAddImage;

  /// No description provided for @composeAddImageOrPdf.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan gambar atau PDF'**
  String get composeAddImageOrPdf;

  /// No description provided for @documentTooLarge.
  ///
  /// In id, this message translates to:
  /// **'PDF maksimal 10 MB.'**
  String get documentTooLarge;

  /// No description provided for @documentOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Dokumen tidak bisa dibuka. Coba lagi.'**
  String get documentOpenFailed;

  /// No description provided for @documentFallbackName.
  ///
  /// In id, this message translates to:
  /// **'Dokumen.pdf'**
  String get documentFallbackName;

  /// No description provided for @openDocument.
  ///
  /// In id, this message translates to:
  /// **'Buka {name}'**
  String openDocument(String name);

  /// No description provided for @errorAttachmentNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Format lampiran ini tidak diterima di chat ini. Chat CS menerima format sesuai daftar dari server; chat lain hanya gambar.'**
  String get errorAttachmentNotAllowed;

  /// No description provided for @composeRemoveImage.
  ///
  /// In id, this message translates to:
  /// **'Hapus gambar'**
  String get composeRemoveImage;

  /// No description provided for @composeTooManyImages.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 4 gambar'**
  String get composeTooManyImages;

  /// No description provided for @composeImageTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Ukuran gambar maksimal 5 MB'**
  String get composeImageTooLarge;

  /// No description provided for @composePosted.
  ///
  /// In id, this message translates to:
  /// **'Post terkirim'**
  String get composePosted;

  /// No description provided for @sentimentLabel.
  ///
  /// In id, this message translates to:
  /// **'Sentimen'**
  String get sentimentLabel;

  /// No description provided for @sentimentBullish.
  ///
  /// In id, this message translates to:
  /// **'Bullish'**
  String get sentimentBullish;

  /// No description provided for @sentimentBearish.
  ///
  /// In id, this message translates to:
  /// **'Bearish'**
  String get sentimentBearish;

  /// No description provided for @sentimentNeutral.
  ///
  /// In id, this message translates to:
  /// **'Netral'**
  String get sentimentNeutral;

  /// No description provided for @sentimentNone.
  ///
  /// In id, this message translates to:
  /// **'Tanpa'**
  String get sentimentNone;

  /// No description provided for @like.
  ///
  /// In id, this message translates to:
  /// **'Suka'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In id, this message translates to:
  /// **'Batal suka'**
  String get unlike;

  /// No description provided for @comment.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get comment;

  /// No description provided for @reply.
  ///
  /// In id, this message translates to:
  /// **'Balas'**
  String get reply;

  /// No description provided for @postDetail.
  ///
  /// In id, this message translates to:
  /// **'Post'**
  String get postDetail;

  /// No description provided for @postNotFound.
  ///
  /// In id, this message translates to:
  /// **'Post tidak ditemukan atau sudah dihapus.'**
  String get postNotFound;

  /// No description provided for @postDeleted.
  ///
  /// In id, this message translates to:
  /// **'Post dihapus'**
  String get postDeleted;

  /// No description provided for @deletePostConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus post ini?'**
  String get deletePostConfirm;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus komentar ini?'**
  String get deleteCommentConfirm;

  /// No description provided for @comments.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get comments;

  /// No description provided for @noComments.
  ///
  /// In id, this message translates to:
  /// **'Belum ada komentar. Mulai diskusi!'**
  String get noComments;

  /// No description provided for @writeComment.
  ///
  /// In id, this message translates to:
  /// **'Tulis komentar…'**
  String get writeComment;

  /// No description provided for @replyingTo.
  ///
  /// In id, this message translates to:
  /// **'Membalas {name}'**
  String replyingTo(String name);

  /// No description provided for @commentDeleted.
  ///
  /// In id, this message translates to:
  /// **'[komentar dihapus]'**
  String get commentDeleted;

  /// No description provided for @viewMoreReplies.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Lihat 1 balasan lainnya} other{Lihat {count} balasan lainnya}}'**
  String viewMoreReplies(int count);

  /// No description provided for @loadMoreComments.
  ///
  /// In id, this message translates to:
  /// **'Muat komentar lainnya'**
  String get loadMoreComments;

  /// No description provided for @continueThread.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan thread'**
  String get continueThread;

  /// No description provided for @commentSortTop.
  ///
  /// In id, this message translates to:
  /// **'Disarankan'**
  String get commentSortTop;

  /// No description provided for @commentSortLatest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get commentSortLatest;

  /// No description provided for @commentSortTooltip.
  ///
  /// In id, this message translates to:
  /// **'Urutkan komentar'**
  String get commentSortTooltip;

  /// No description provided for @commentsFirst.
  ///
  /// In id, this message translates to:
  /// **'Jadilah yang pertama berkomentar'**
  String get commentsFirst;

  /// No description provided for @viewMoreComments.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Lihat 1 komentar lainnya} other{Lihat {count} komentar lainnya}}'**
  String viewMoreComments(int count);

  /// No description provided for @addComment.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan komentar…'**
  String get addComment;

  /// No description provided for @threadContext.
  ///
  /// In id, this message translates to:
  /// **'Melanjutkan thread'**
  String get threadContext;

  /// No description provided for @collapse.
  ///
  /// In id, this message translates to:
  /// **'Ciutkan'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In id, this message translates to:
  /// **'Bentangkan'**
  String get expand;

  /// No description provided for @hiddenReplies.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 balasan disembunyikan} other{{count} balasan disembunyikan}}'**
  String hiddenReplies(int count);

  /// No description provided for @newCommentsAvailable.
  ///
  /// In id, this message translates to:
  /// **'Ada komentar baru'**
  String get newCommentsAvailable;

  /// No description provided for @report.
  ///
  /// In id, this message translates to:
  /// **'Laporkan'**
  String get report;

  /// No description provided for @reportTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporkan konten'**
  String get reportTitle;

  /// No description provided for @reportDetailsHint.
  ///
  /// In id, this message translates to:
  /// **'Keterangan tambahan (opsional)'**
  String get reportDetailsHint;

  /// No description provided for @reportSent.
  ///
  /// In id, this message translates to:
  /// **'Laporan terkirim. Terima kasih.'**
  String get reportSent;

  /// No description provided for @reasonSpam.
  ///
  /// In id, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @reasonAbuse.
  ///
  /// In id, this message translates to:
  /// **'Pelecehan / kasar'**
  String get reasonAbuse;

  /// No description provided for @reasonScam.
  ///
  /// In id, this message translates to:
  /// **'Penipuan'**
  String get reasonScam;

  /// No description provided for @reasonPumpAndDump.
  ///
  /// In id, this message translates to:
  /// **'Ajakan goreng saham'**
  String get reasonPumpAndDump;

  /// No description provided for @reasonMisinformation.
  ///
  /// In id, this message translates to:
  /// **'Informasi menyesatkan'**
  String get reasonMisinformation;

  /// No description provided for @reasonOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get reasonOther;

  /// No description provided for @block.
  ///
  /// In id, this message translates to:
  /// **'Blokir'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In id, this message translates to:
  /// **'Buka blokir'**
  String get unblock;

  /// No description provided for @blockConfirm.
  ///
  /// In id, this message translates to:
  /// **'Blokir {name}? Anda tidak akan saling melihat post, komentar, dan pesan.'**
  String blockConfirm(String name);

  /// No description provided for @blocked.
  ///
  /// In id, this message translates to:
  /// **'{name} diblokir'**
  String blocked(String name);

  /// No description provided for @follow.
  ///
  /// In id, this message translates to:
  /// **'Ikuti'**
  String get follow;

  /// No description provided for @followingLabel.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti'**
  String get followingLabel;

  /// No description provided for @followers.
  ///
  /// In id, this message translates to:
  /// **'{count} pengikut'**
  String followers(int count);

  /// No description provided for @followingCount.
  ///
  /// In id, this message translates to:
  /// **'{count} mengikuti'**
  String followingCount(int count);

  /// No description provided for @postsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} post'**
  String postsCount(int count);

  /// No description provided for @profileStatPosts.
  ///
  /// In id, this message translates to:
  /// **'Post'**
  String get profileStatPosts;

  /// No description provided for @profileStatFollowers.
  ///
  /// In id, this message translates to:
  /// **'Pengikut'**
  String get profileStatFollowers;

  /// No description provided for @followsYou.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti Anda'**
  String get followsYou;

  /// No description provided for @sendMessage.
  ///
  /// In id, this message translates to:
  /// **'Kirim pesan'**
  String get sendMessage;

  /// No description provided for @editProfile.
  ///
  /// In id, this message translates to:
  /// **'Ubah profil'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In id, this message translates to:
  /// **'Nama tampilan'**
  String get displayName;

  /// No description provided for @bio.
  ///
  /// In id, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @changeAvatar.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get changeAvatar;

  /// No description provided for @profileNotFound.
  ///
  /// In id, this message translates to:
  /// **'User tidak ditemukan.'**
  String get profileNotFound;

  /// No description provided for @watch.
  ///
  /// In id, this message translates to:
  /// **'Pantau'**
  String get watch;

  /// No description provided for @watching.
  ///
  /// In id, this message translates to:
  /// **'Dipantau'**
  String get watching;

  /// No description provided for @watchers.
  ///
  /// In id, this message translates to:
  /// **'{count} pemantau'**
  String watchers(int count);

  /// No description provided for @stockDiscussion.
  ///
  /// In id, this message translates to:
  /// **'Diskusi'**
  String get stockDiscussion;

  /// No description provided for @stockNotFound.
  ///
  /// In id, this message translates to:
  /// **'Kode saham tidak valid.'**
  String get stockNotFound;

  /// No description provided for @chats.
  ///
  /// In id, this message translates to:
  /// **'Chat'**
  String get chats;

  /// No description provided for @noChats.
  ///
  /// In id, this message translates to:
  /// **'Belum ada percakapan.'**
  String get noChats;

  /// No description provided for @selectChat.
  ///
  /// In id, this message translates to:
  /// **'Pilih percakapan untuk mulai chat.'**
  String get selectChat;

  /// No description provided for @newGroup.
  ///
  /// In id, this message translates to:
  /// **'Grup baru'**
  String get newGroup;

  /// No description provided for @groupName.
  ///
  /// In id, this message translates to:
  /// **'Nama grup'**
  String get groupName;

  /// No description provided for @addMembers.
  ///
  /// In id, this message translates to:
  /// **'Tambah anggota'**
  String get addMembers;

  /// No description provided for @create.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get create;

  /// No description provided for @searchUsers.
  ///
  /// In id, this message translates to:
  /// **'Cari user…'**
  String get searchUsers;

  /// No description provided for @members.
  ///
  /// In id, this message translates to:
  /// **'{count} anggota'**
  String members(int count);

  /// No description provided for @online.
  ///
  /// In id, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @typing.
  ///
  /// In id, this message translates to:
  /// **'{name} sedang mengetik…'**
  String typing(String name);

  /// No description provided for @typingMany.
  ///
  /// In id, this message translates to:
  /// **'Beberapa orang sedang mengetik…'**
  String get typingMany;

  /// No description provided for @typingSomeone.
  ///
  /// In id, this message translates to:
  /// **'Seseorang sedang mengetik…'**
  String get typingSomeone;

  /// No description provided for @messageHint.
  ///
  /// In id, this message translates to:
  /// **'Tulis pesan…'**
  String get messageHint;

  /// No description provided for @messageDeleted.
  ///
  /// In id, this message translates to:
  /// **'[pesan dihapus]'**
  String get messageDeleted;

  /// No description provided for @messageFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal terkirim. Ketuk untuk kirim ulang.'**
  String get messageFailed;

  /// No description provided for @messageRead.
  ///
  /// In id, this message translates to:
  /// **'Dibaca'**
  String get messageRead;

  /// No description provided for @messageSent.
  ///
  /// In id, this message translates to:
  /// **'Terkirim'**
  String get messageSent;

  /// No description provided for @messageSending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim…'**
  String get messageSending;

  /// No description provided for @messagePending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu dikirim'**
  String get messagePending;

  /// No description provided for @offlineBanner.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang offline. Menampilkan data tersimpan.'**
  String get offlineBanner;

  /// No description provided for @offlineChatBanner.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang offline. Pesan teks dikirim otomatis saat tersambung kembali.'**
  String get offlineChatBanner;

  /// No description provided for @errorAttachmentOffline.
  ///
  /// In id, this message translates to:
  /// **'Gambar dan dokumen hanya bisa dikirim saat online.'**
  String get errorAttachmentOffline;

  /// No description provided for @reconnecting.
  ///
  /// In id, this message translates to:
  /// **'Menyambungkan ulang…'**
  String get reconnecting;

  /// No description provided for @attachment.
  ///
  /// In id, this message translates to:
  /// **'[lampiran]'**
  String get attachment;

  /// No description provided for @replyToMessage.
  ///
  /// In id, this message translates to:
  /// **'Balas pesan'**
  String get replyToMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus pesan ini untuk semua orang?'**
  String get deleteMessageConfirm;

  /// No description provided for @leaveRoom.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get leaveRoom;

  /// No description provided for @mute.
  ///
  /// In id, this message translates to:
  /// **'Bisukan'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan suara'**
  String get unmute;

  /// No description provided for @sendShortcutHint.
  ///
  /// In id, this message translates to:
  /// **'Enter untuk kirim, Shift+Enter untuk baris baru'**
  String get sendShortcutHint;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi.'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In id, this message translates to:
  /// **'Tandai semua dibaca'**
  String get markAllRead;

  /// No description provided for @notifReply.
  ///
  /// In id, this message translates to:
  /// **'{name} membalas Anda'**
  String notifReply(String name);

  /// No description provided for @notifMention.
  ///
  /// In id, this message translates to:
  /// **'{name} menyebut Anda'**
  String notifMention(String name);

  /// No description provided for @notifLike.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{{name} menyukai konten Anda} other{{name} dan {others} lainnya menyukai konten Anda}}'**
  String notifLike(String name, int count, int others);

  /// No description provided for @notifFollow.
  ///
  /// In id, this message translates to:
  /// **'{name} mulai mengikuti Anda'**
  String notifFollow(String name);

  /// No description provided for @notifMessage.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Pesan baru dari {name}} other{{count} pesan baru dari {name}}}'**
  String notifMessage(String name, int count);

  /// No description provided for @someone.
  ///
  /// In id, this message translates to:
  /// **'Seseorang'**
  String get someone;

  /// No description provided for @typingShort.
  ///
  /// In id, this message translates to:
  /// **'mengetik…'**
  String get typingShort;

  /// No description provided for @messageDelivered.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get messageDelivered;

  /// No description provided for @pollAddTooltip.
  ///
  /// In id, this message translates to:
  /// **'Tambah polling'**
  String get pollAddTooltip;

  /// No description provided for @pollRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus polling'**
  String get pollRemove;

  /// No description provided for @pollOptionHint.
  ///
  /// In id, this message translates to:
  /// **'Pilihan {index}'**
  String pollOptionHint(int index);

  /// No description provided for @pollAddOption.
  ///
  /// In id, this message translates to:
  /// **'Tambah pilihan'**
  String get pollAddOption;

  /// No description provided for @pollDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get pollDuration;

  /// No description provided for @pollDuration1h.
  ///
  /// In id, this message translates to:
  /// **'1 jam'**
  String get pollDuration1h;

  /// No description provided for @pollDuration6h.
  ///
  /// In id, this message translates to:
  /// **'6 jam'**
  String get pollDuration6h;

  /// No description provided for @pollDuration1d.
  ///
  /// In id, this message translates to:
  /// **'1 hari'**
  String get pollDuration1d;

  /// No description provided for @pollDuration3d.
  ///
  /// In id, this message translates to:
  /// **'3 hari'**
  String get pollDuration3d;

  /// No description provided for @pollDuration7d.
  ///
  /// In id, this message translates to:
  /// **'7 hari'**
  String get pollDuration7d;

  /// No description provided for @pollVotes.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Belum ada suara} other{{count} suara}}'**
  String pollVotes(int count);

  /// No description provided for @pollEndsIn.
  ///
  /// In id, this message translates to:
  /// **'Sisa {time}'**
  String pollEndsIn(String time);

  /// No description provided for @pollEnded.
  ///
  /// In id, this message translates to:
  /// **'Polling selesai'**
  String get pollEnded;

  /// No description provided for @pollYourVote.
  ///
  /// In id, this message translates to:
  /// **'Pilihan Anda'**
  String get pollYourVote;

  /// No description provided for @pollInvalidDraft.
  ///
  /// In id, this message translates to:
  /// **'Isi 2–4 pilihan berbeda, masing-masing maksimal 40 karakter.'**
  String get pollInvalidDraft;

  /// No description provided for @pollTimeMinutes.
  ///
  /// In id, this message translates to:
  /// **'{count} menit'**
  String pollTimeMinutes(int count);

  /// No description provided for @pollTimeHours.
  ///
  /// In id, this message translates to:
  /// **'{count} jam'**
  String pollTimeHours(int count);

  /// No description provided for @pollTimeDays.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String pollTimeDays(int count);

  /// No description provided for @errorPollClosed.
  ///
  /// In id, this message translates to:
  /// **'Polling sudah berakhir.'**
  String get errorPollClosed;

  /// No description provided for @errorAlreadyVoted.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah memilih di polling ini.'**
  String get errorAlreadyVoted;

  /// No description provided for @errorOwnPoll.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak bisa memilih di polling sendiri.'**
  String get errorOwnPoll;

  /// No description provided for @errorInvalidPoll.
  ///
  /// In id, this message translates to:
  /// **'Polling tidak valid. Periksa pilihan dan durasinya.'**
  String get errorInvalidPoll;

  /// No description provided for @errorDuplicateContent.
  ///
  /// In id, this message translates to:
  /// **'Konten yang sama sudah dikirim berulang kali. Coba lagi beberapa menit lagi.'**
  String get errorDuplicateContent;

  /// No description provided for @errorUserMuted.
  ///
  /// In id, this message translates to:
  /// **'Akun Anda sedang dibatasi dan belum bisa mengirim konten.'**
  String get errorUserMuted;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get yesterday;

  /// No description provided for @supportOfficialBadge.
  ///
  /// In id, this message translates to:
  /// **'CS Resmi'**
  String get supportOfficialBadge;

  /// No description provided for @supportOfficialChannel.
  ///
  /// In id, this message translates to:
  /// **'Layanan resmi'**
  String get supportOfficialChannel;

  /// No description provided for @supportOpenLink.
  ///
  /// In id, this message translates to:
  /// **'Buka panduan'**
  String get supportOpenLink;

  /// No description provided for @supportRatePrompt.
  ///
  /// In id, this message translates to:
  /// **'Beri nilai layanan ini'**
  String get supportRatePrompt;

  /// No description provided for @supportRated.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih atas penilaian Anda'**
  String get supportRated;

  /// No description provided for @errorSecretRequestBlocked.
  ///
  /// In id, this message translates to:
  /// **'Pesan ditahan: CS tidak boleh meminta OTP, PIN, atau password. Supervisor sudah diberi tahu.'**
  String get errorSecretRequestBlocked;

  /// No description provided for @supportTitle.
  ///
  /// In id, this message translates to:
  /// **'Bantuan / Chat CS'**
  String get supportTitle;

  /// No description provided for @supportPickTopic.
  ///
  /// In id, this message translates to:
  /// **'Apa yang bisa kami bantu?'**
  String get supportPickTopic;

  /// No description provided for @supportPickTopicHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih topik agar CS yang tepat langsung membantu Anda.'**
  String get supportPickTopicHint;

  /// No description provided for @supportHistory.
  ///
  /// In id, this message translates to:
  /// **'Lihat riwayat chat'**
  String get supportHistory;

  /// No description provided for @supportOutOfHours.
  ///
  /// In id, this message translates to:
  /// **'CS sedang di luar jam layanan. Pesan Anda dibalas mulai {time}.'**
  String supportOutOfHours(String time);

  /// No description provided for @supportStatusWaiting.
  ///
  /// In id, this message translates to:
  /// **'Menunggu CS'**
  String get supportStatusWaiting;

  /// No description provided for @supportQueueAhead.
  ///
  /// In id, this message translates to:
  /// **'{count} tiket di depan Anda'**
  String supportQueueAhead(int count);

  /// No description provided for @supportStatusHandled.
  ///
  /// In id, this message translates to:
  /// **'Ditangani oleh {name} – CS Resmi'**
  String supportStatusHandled(String name);

  /// No description provided for @supportStatusWaitingYou.
  ///
  /// In id, this message translates to:
  /// **'Menunggu balasan Anda'**
  String get supportStatusWaitingYou;

  /// No description provided for @supportStatusResolved.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In id, this message translates to:
  /// **'Ditutup'**
  String get supportStatusClosed;

  /// No description provided for @supportMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu bantuan'**
  String get supportMenu;

  /// No description provided for @supportEndChat.
  ///
  /// In id, this message translates to:
  /// **'Akhiri chat'**
  String get supportEndChat;

  /// No description provided for @supportEndConfirm.
  ///
  /// In id, this message translates to:
  /// **'Akhiri chat dan tandai tiket ini selesai?'**
  String get supportEndConfirm;

  /// No description provided for @supportComplaint.
  ///
  /// In id, this message translates to:
  /// **'Ajukan pengaduan'**
  String get supportComplaint;

  /// No description provided for @supportComplaintConfirm.
  ///
  /// In id, this message translates to:
  /// **'Tiket ini akan dicatat sebagai pengaduan resmi dengan tenggat penyelesaian. Lanjutkan?'**
  String get supportComplaintConfirm;

  /// No description provided for @supportReportFake.
  ///
  /// In id, this message translates to:
  /// **'Laporkan CS palsu'**
  String get supportReportFake;

  /// No description provided for @supportReportFakeHint.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan kejadiannya: siapa yang menghubungi, lewat apa, dan apa yang diminta.'**
  String get supportReportFakeHint;

  /// No description provided for @supportSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get supportSend;

  /// No description provided for @supportMyTickets.
  ///
  /// In id, this message translates to:
  /// **'Tiket saya'**
  String get supportMyTickets;

  /// No description provided for @supportNoTickets.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tiket.'**
  String get supportNoTickets;

  /// No description provided for @supportNewTicket.
  ///
  /// In id, this message translates to:
  /// **'Buat tiket baru'**
  String get supportNewTicket;

  /// No description provided for @supportRateTitle.
  ///
  /// In id, this message translates to:
  /// **'Nilai layanan CS'**
  String get supportRateTitle;

  /// No description provided for @supportRateComment.
  ///
  /// In id, this message translates to:
  /// **'Komentar (opsional)'**
  String get supportRateComment;

  /// No description provided for @supportRateSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim nilai'**
  String get supportRateSubmit;

  /// No description provided for @supportSensitiveWarning.
  ///
  /// In id, this message translates to:
  /// **'Pesan ini berisi {kinds} dan akan disamarkan. CS OLT tidak pernah meminta OTP, PIN, atau password.'**
  String supportSensitiveWarning(String kinds);

  /// No description provided for @supportKindOtp.
  ///
  /// In id, this message translates to:
  /// **'kode OTP'**
  String get supportKindOtp;

  /// No description provided for @supportKindPassword.
  ///
  /// In id, this message translates to:
  /// **'password/PIN'**
  String get supportKindPassword;

  /// No description provided for @supportKindCard.
  ///
  /// In id, this message translates to:
  /// **'nomor kartu'**
  String get supportKindCard;

  /// No description provided for @supportKindNik.
  ///
  /// In id, this message translates to:
  /// **'NIK'**
  String get supportKindNik;

  /// No description provided for @supportKindAccount.
  ///
  /// In id, this message translates to:
  /// **'nomor rekening'**
  String get supportKindAccount;

  /// No description provided for @supportComplaintFiled.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan dicatat. Tenggat penyelesaian tampil di chat.'**
  String get supportComplaintFiled;

  /// No description provided for @supportFakeReported.
  ///
  /// In id, this message translates to:
  /// **'Laporan terkirim. Tim kami segera menindaklanjuti.'**
  String get supportFakeReported;

  /// No description provided for @supportClosed.
  ///
  /// In id, this message translates to:
  /// **'Chat diakhiri.'**
  String get supportClosed;

  /// No description provided for @officialAccountBadge.
  ///
  /// In id, this message translates to:
  /// **'Resmi'**
  String get officialAccountBadge;

  /// No description provided for @pinnedLabel.
  ///
  /// In id, this message translates to:
  /// **'Disematkan'**
  String get pinnedLabel;

  /// No description provided for @announcementLabel.
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get announcementLabel;

  /// No description provided for @notifAnnouncement.
  ///
  /// In id, this message translates to:
  /// **'{name} membuat pengumuman'**
  String notifAnnouncement(String name);

  /// No description provided for @supportTicketClosedNotice.
  ///
  /// In id, this message translates to:
  /// **'Tiket #{ticket} sudah ditutup dan tidak bisa dibalas lagi.'**
  String supportTicketClosedNotice(String ticket);

  /// No description provided for @supportTicketMeta.
  ///
  /// In id, this message translates to:
  /// **'{date} · {status}'**
  String supportTicketMeta(String date, String status);

  /// No description provided for @supportRating.
  ///
  /// In id, this message translates to:
  /// **'Nilai {rating}/5'**
  String supportRating(int rating);

  /// No description provided for @supportUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Chat CS belum tersedia. Coba lagi sebentar lagi.'**
  String get supportUnavailable;

  /// No description provided for @errorUnsupportedType.
  ///
  /// In id, this message translates to:
  /// **'Jenis file tidak didukung. Gambar: JPEG, PNG, WebP, atau GIF (foto profil tanpa GIF). Chat CS juga menerima dokumen dan video sesuai daftar format dari server.'**
  String get errorUnsupportedType;

  /// No description provided for @errorFileTooLarge.
  ///
  /// In id, this message translates to:
  /// **'File terlalu besar. Batasnya 5 MB untuk gambar dan 2 MB untuk foto profil; batas dokumen dan video di chat CS diatur server.'**
  String get errorFileTooLarge;

  /// No description provided for @errorEmptyFile.
  ///
  /// In id, this message translates to:
  /// **'File kosong. Pilih file lain.'**
  String get errorEmptyFile;

  /// No description provided for @errorInvalidImage.
  ///
  /// In id, this message translates to:
  /// **'Gambar rusak atau tidak bisa dibaca. Coba gambar lain.'**
  String get errorInvalidImage;

  /// No description provided for @errorImageTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Resolusi gambar terlalu besar. Maksimal 10.000 piksel per sisi dan 40 megapiksel.'**
  String get errorImageTooLarge;

  /// No description provided for @errorInvalidPdf.
  ///
  /// In id, this message translates to:
  /// **'PDF rusak atau tidak bisa dibaca.'**
  String get errorInvalidPdf;

  /// No description provided for @errorPdfEncrypted.
  ///
  /// In id, this message translates to:
  /// **'PDF yang dikunci kata sandi tidak bisa dikirim. Buka kuncinya dulu, lalu kirim ulang.'**
  String get errorPdfEncrypted;

  /// No description provided for @errorPdfActiveContent.
  ///
  /// In id, this message translates to:
  /// **'PDF berisi skrip, file tersemat, atau konten aktif lain. Simpan ulang sebagai PDF biasa (misalnya lewat Cetak ke PDF), lalu kirim ulang.'**
  String get errorPdfActiveContent;

  /// No description provided for @errorUploadForbidden.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak diizinkan mengunggah file ke sini.'**
  String get errorUploadForbidden;

  /// No description provided for @errorTooManyUploads.
  ///
  /// In id, this message translates to:
  /// **'Batas unggahan hari ini sudah tercapai. Coba lagi besok.'**
  String get errorTooManyUploads;

  /// No description provided for @errorUploadBusy.
  ///
  /// In id, this message translates to:
  /// **'Server unggahan sedang sibuk. Coba lagi sebentar lagi.'**
  String get errorUploadBusy;

  /// No description provided for @errorStorageUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Unggahan file sedang tidak tersedia. Coba lagi nanti.'**
  String get errorStorageUnavailable;

  /// No description provided for @errorConsentRequired.
  ///
  /// In id, this message translates to:
  /// **'Setujui Syarat & Ketentuan dan Pedoman Komunitas terbaru untuk mengirim konten.'**
  String get errorConsentRequired;

  /// No description provided for @consentDeclined.
  ///
  /// In id, this message translates to:
  /// **'Belum terkirim. Setujui dokumen terbaru untuk mengirim; tulisan Anda tetap tersimpan.'**
  String get consentDeclined;

  /// No description provided for @consentTitle.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan diperlukan'**
  String get consentTitle;

  /// No description provided for @consentIntro.
  ///
  /// In id, this message translates to:
  /// **'Sebelum ikut berdiskusi, baca dan setujui dokumen berikut.'**
  String get consentIntro;

  /// No description provided for @consentAgree.
  ///
  /// In id, this message translates to:
  /// **'Saya telah membaca dan menyetujui {documents}.'**
  String consentAgree(String documents);

  /// No description provided for @consentAccept.
  ///
  /// In id, this message translates to:
  /// **'Setuju'**
  String get consentAccept;

  /// No description provided for @consentLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get consentLater;

  /// No description provided for @consentRead.
  ///
  /// In id, this message translates to:
  /// **'Baca'**
  String get consentRead;

  /// No description provided for @consentReview.
  ///
  /// In id, this message translates to:
  /// **'Tinjau'**
  String get consentReview;

  /// No description provided for @consentAccepted.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih. Persetujuan Anda sudah tersimpan.'**
  String get consentAccepted;

  /// No description provided for @consentBannerUpdated.
  ///
  /// In id, this message translates to:
  /// **'{documents} diperbarui — tinjau dan setujui.'**
  String consentBannerUpdated(String documents);

  /// No description provided for @consentBannerRequired.
  ///
  /// In id, this message translates to:
  /// **'Tinjau dan setujui {documents} untuk ikut berdiskusi.'**
  String consentBannerRequired(String documents);

  /// No description provided for @legalVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi {version} · berlaku {date}'**
  String legalVersion(int version, String date);

  /// No description provided for @legalChanges.
  ///
  /// In id, this message translates to:
  /// **'Yang berubah'**
  String get legalChanges;

  /// No description provided for @listAnd.
  ///
  /// In id, this message translates to:
  /// **'dan'**
  String get listAnd;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi & akun'**
  String get accountSettingsTitle;

  /// No description provided for @accountLegalSection.
  ///
  /// In id, this message translates to:
  /// **'Dokumen hukum'**
  String get accountLegalSection;

  /// No description provided for @accountDataSection.
  ///
  /// In id, this message translates to:
  /// **'Data Anda'**
  String get accountDataSection;

  /// No description provided for @accountExport.
  ///
  /// In id, this message translates to:
  /// **'Unduh data saya'**
  String get accountExport;

  /// No description provided for @accountExportHint.
  ///
  /// In id, this message translates to:
  /// **'Salinan data komunitas Anda dalam format JSON. Bisa diunduh 3 kali sehari.'**
  String get accountExportHint;

  /// No description provided for @accountExportSaved.
  ///
  /// In id, this message translates to:
  /// **'Data komunitas Anda sudah diunduh.'**
  String get accountExportSaved;

  /// No description provided for @accountExportLimit.
  ///
  /// In id, this message translates to:
  /// **'Unduh data dibatasi 3 kali sehari. Coba lagi besok.'**
  String get accountExportLimit;

  /// No description provided for @accountDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun komunitas'**
  String get accountDelete;

  /// No description provided for @accountDeleteHint.
  ///
  /// In id, this message translates to:
  /// **'Menghapus profil dan konten komunitas Anda. Akun trading tidak terpengaruh.'**
  String get accountDeleteHint;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun komunitas?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteIntro.
  ///
  /// In id, this message translates to:
  /// **'Yang terjadi bila akun komunitas dihapus:'**
  String get accountDeleteIntro;

  /// No description provided for @accountDeleteContent.
  ///
  /// In id, this message translates to:
  /// **'Postingan, komentar, dan pesan chat Anda dihapus dari tampilan semua orang.'**
  String get accountDeleteContent;

  /// No description provided for @accountDeleteArchive.
  ///
  /// In id, this message translates to:
  /// **'Salinan konten tetap diarsipkan untuk regulator sesuai ketentuan hukum.'**
  String get accountDeleteArchive;

  /// No description provided for @accountDeleteRelations.
  ///
  /// In id, this message translates to:
  /// **'Pengikut, akun yang Anda ikuti, blokir, dan bisukan dihapus.'**
  String get accountDeleteRelations;

  /// No description provided for @accountDeleteSupport.
  ///
  /// In id, this message translates to:
  /// **'Tiket layanan CS tetap tercatat untuk keperluan kepatuhan, tetapi pesan dan lampiran chat CS ikut dihapus.'**
  String get accountDeleteSupport;

  /// No description provided for @accountDeleteTrading.
  ///
  /// In id, this message translates to:
  /// **'Akun trading OLT Anda tidak terpengaruh.'**
  String get accountDeleteTrading;

  /// No description provided for @accountDeleteFresh.
  ///
  /// In id, this message translates to:
  /// **'Saat membuka komunitas lagi, profil komunitas baru yang kosong akan dibuat.'**
  String get accountDeleteFresh;

  /// No description provided for @accountDeleteTypeToConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ketik {word} untuk konfirmasi'**
  String accountDeleteTypeToConfirm(String word);

  /// No description provided for @accountDeleteWord.
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get accountDeleteWord;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus akun'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleteProgress.
  ///
  /// In id, this message translates to:
  /// **'Menghapus akun komunitas…'**
  String get accountDeleteProgress;

  /// No description provided for @accountDeleted.
  ///
  /// In id, this message translates to:
  /// **'Akun komunitas Anda sudah dihapus.'**
  String get accountDeleted;

  /// No description provided for @errorNewAccountImage.
  ///
  /// In id, this message translates to:
  /// **'Akun baru belum bisa melampirkan gambar. Coba lagi beberapa hari lagi.'**
  String get errorNewAccountImage;

  /// No description provided for @errorNewAccountLink.
  ///
  /// In id, this message translates to:
  /// **'Akun baru belum bisa membagikan tautan. Coba lagi beberapa hari lagi.'**
  String get errorNewAccountLink;

  /// No description provided for @errorLinkBlocked.
  ///
  /// In id, this message translates to:
  /// **'Tautan ini tidak diizinkan.'**
  String get errorLinkBlocked;

  /// No description provided for @errorContactBlocked.
  ///
  /// In id, this message translates to:
  /// **'Konten ini tidak bisa dikirim karena melanggar Pedoman Komunitas.'**
  String get errorContactBlocked;

  /// No description provided for @errorSlowMode.
  ///
  /// In id, this message translates to:
  /// **'Slow mode aktif. Tunggu {seconds} detik sebelum mengirim lagi.'**
  String errorSlowMode(int seconds);

  /// No description provided for @errorSlowModeShort.
  ///
  /// In id, this message translates to:
  /// **'Slow mode aktif. Tunggu sebentar sebelum mengirim lagi.'**
  String get errorSlowModeShort;

  /// No description provided for @errorDmNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Pengguna ini tidak menerima pesan langsung dari Anda.'**
  String get errorDmNotAllowed;

  /// No description provided for @errorDmRequestLimit.
  ///
  /// In id, this message translates to:
  /// **'Tunggu sampai penerima menerima permintaan pesan Anda sebelum mengirim pesan lagi.'**
  String get errorDmRequestLimit;

  /// No description provided for @errorSocialDisabled.
  ///
  /// In id, this message translates to:
  /// **'Fitur komunitas sementara tidak tersedia. Chat CS tetap bisa dipakai.'**
  String get errorSocialDisabled;

  /// No description provided for @errorEditWindowExpired.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu edit sudah lewat.'**
  String get errorEditWindowExpired;

  /// No description provided for @errorPollNotEditable.
  ///
  /// In id, this message translates to:
  /// **'Post dengan polling tidak bisa diedit.'**
  String get errorPollNotEditable;

  /// No description provided for @errorImageBlocked.
  ///
  /// In id, this message translates to:
  /// **'Gambar ini tidak bisa diunggah karena melanggar Pedoman Komunitas.'**
  String get errorImageBlocked;

  /// No description provided for @errorImageCheckUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan gambar sedang tidak tersedia. Coba lagi sebentar lagi.'**
  String get errorImageCheckUnavailable;

  /// No description provided for @errorAppealExists.
  ///
  /// In id, this message translates to:
  /// **'Banding untuk ini sudah pernah diajukan.'**
  String get errorAppealExists;

  /// No description provided for @errorAppealWindowClosed.
  ///
  /// In id, this message translates to:
  /// **'Batas waktu pengajuan banding sudah lewat.'**
  String get errorAppealWindowClosed;

  /// No description provided for @errorAppealNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Keputusan ini tidak bisa diajukan banding.'**
  String get errorAppealNotAllowed;

  /// No description provided for @errorAppealReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan banding 10–1000 karakter.'**
  String get errorAppealReason;

  /// No description provided for @errorQueryTooShort.
  ///
  /// In id, this message translates to:
  /// **'Kata kunci terlalu pendek.'**
  String get errorQueryTooShort;

  /// No description provided for @errorQueryTooLong.
  ///
  /// In id, this message translates to:
  /// **'Kata kunci terlalu panjang.'**
  String get errorQueryTooLong;

  /// No description provided for @errorShareNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Post tidak bisa dibagikan ke chat ini.'**
  String get errorShareNotAllowed;

  /// No description provided for @errorRequestNotFound.
  ///
  /// In id, this message translates to:
  /// **'Permintaan pesan sudah tidak ada.'**
  String get errorRequestNotFound;

  /// No description provided for @errorInvalidQuietHours.
  ///
  /// In id, this message translates to:
  /// **'Jam tenang tidak valid.'**
  String get errorInvalidQuietHours;

  /// No description provided for @socialUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Komunitas sedang tidak tersedia'**
  String get socialUnavailableTitle;

  /// No description provided for @socialUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Fitur komunitas sedang dalam pemeliharaan. Chat CS tetap bisa dipakai.'**
  String get socialUnavailableBody;

  /// No description provided for @featureUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini sedang tidak tersedia.'**
  String get featureUnavailable;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In id, this message translates to:
  /// **'Perbarui aplikasi'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi ini tidak lagi didukung fitur komunitas. Perbarui aplikasi untuk melanjutkan.'**
  String get updateRequiredBody;

  /// No description provided for @moderationHeld.
  ///
  /// In id, this message translates to:
  /// **'Menunggu tinjauan'**
  String get moderationHeld;

  /// No description provided for @moderationHeldHint.
  ///
  /// In id, this message translates to:
  /// **'Hanya Anda yang bisa melihatnya sampai ditinjau moderator.'**
  String get moderationHeldHint;

  /// No description provided for @moderationHidden.
  ///
  /// In id, this message translates to:
  /// **'Disembunyikan moderator'**
  String get moderationHidden;

  /// No description provided for @moderationHiddenHint.
  ///
  /// In id, this message translates to:
  /// **'Konten ini tidak terlihat oleh orang lain.'**
  String get moderationHiddenHint;

  /// No description provided for @messageRequests.
  ///
  /// In id, this message translates to:
  /// **'Permintaan pesan'**
  String get messageRequests;

  /// No description provided for @messageRequestsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada permintaan pesan.'**
  String get messageRequestsEmpty;

  /// No description provided for @messageRequestMessages.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 pesan} other{{count} pesan}}'**
  String messageRequestMessages(int count);

  /// No description provided for @messageRequestIntro.
  ///
  /// In id, this message translates to:
  /// **'{name} belum Anda ikuti. Terima untuk membalas, atau tolak untuk menyembunyikan permintaan ini.'**
  String messageRequestIntro(String name);

  /// No description provided for @messageRequestAccept.
  ///
  /// In id, this message translates to:
  /// **'Terima'**
  String get messageRequestAccept;

  /// No description provided for @messageRequestDecline.
  ///
  /// In id, this message translates to:
  /// **'Tolak'**
  String get messageRequestDecline;

  /// No description provided for @messageRequestBlock.
  ///
  /// In id, this message translates to:
  /// **'Blokir & laporkan'**
  String get messageRequestBlock;

  /// No description provided for @messageRequestBlockConfirm.
  ///
  /// In id, this message translates to:
  /// **'Blokir {name} dan laporkan permintaan ini sebagai spam?'**
  String messageRequestBlockConfirm(String name);

  /// No description provided for @messageRequestAccepted.
  ///
  /// In id, this message translates to:
  /// **'Permintaan diterima.'**
  String get messageRequestAccepted;

  /// No description provided for @messageRequestDeclined.
  ///
  /// In id, this message translates to:
  /// **'Permintaan ditolak.'**
  String get messageRequestDeclined;

  /// No description provided for @messageRequestImageHidden.
  ///
  /// In id, this message translates to:
  /// **'Gambar diburamkan sampai Anda menerima permintaan.'**
  String get messageRequestImageHidden;

  /// No description provided for @dmRequestSenderNotice.
  ///
  /// In id, this message translates to:
  /// **'Bila {name} belum mengikuti Anda, pesan Anda masuk sebagai permintaan pesan. Anda bisa mengirim hingga {max} pesan sampai permintaan diterima.'**
  String dmRequestSenderNotice(String name, int max);

  /// No description provided for @dmRequestLimitNotice.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah mengirim {max} pesan. Tunggu {name} menerima permintaan pesan Anda.'**
  String dmRequestLimitNotice(String name, int max);

  /// No description provided for @accountMessagesSection.
  ///
  /// In id, this message translates to:
  /// **'Pesan langsung'**
  String get accountMessagesSection;

  /// No description provided for @dmPolicyTitle.
  ///
  /// In id, this message translates to:
  /// **'Siapa yang bisa mengirim pesan langsung'**
  String get dmPolicyTitle;

  /// No description provided for @dmPolicyEveryone.
  ///
  /// In id, this message translates to:
  /// **'Semua orang'**
  String get dmPolicyEveryone;

  /// No description provided for @dmPolicyEveryoneHint.
  ///
  /// In id, this message translates to:
  /// **'Orang yang tidak Anda ikuti masuk ke Permintaan pesan.'**
  String get dmPolicyEveryoneHint;

  /// No description provided for @dmPolicyFollowing.
  ///
  /// In id, this message translates to:
  /// **'Hanya yang saya ikuti'**
  String get dmPolicyFollowing;

  /// No description provided for @dmPolicyNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get dmPolicyNone;

  /// No description provided for @dmPolicyNoneHint.
  ///
  /// In id, this message translates to:
  /// **'Percakapan yang sudah ada tetap berjalan.'**
  String get dmPolicyNoneHint;

  /// No description provided for @dmPolicySaved.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan pesan disimpan.'**
  String get dmPolicySaved;

  /// No description provided for @appealAction.
  ///
  /// In id, this message translates to:
  /// **'Ajukan banding'**
  String get appealAction;

  /// No description provided for @appealTitle.
  ///
  /// In id, this message translates to:
  /// **'Ajukan banding'**
  String get appealTitle;

  /// No description provided for @appealHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan mengapa menurut Anda keputusan ini keliru (10–1000 karakter).'**
  String get appealHint;

  /// No description provided for @appealSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim banding'**
  String get appealSubmit;

  /// No description provided for @appealSent.
  ///
  /// In id, this message translates to:
  /// **'Banding terkirim. Kami akan memberi tahu hasilnya.'**
  String get appealSent;

  /// No description provided for @myAppeals.
  ///
  /// In id, this message translates to:
  /// **'Banding saya'**
  String get myAppeals;

  /// No description provided for @myAppealsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada banding.'**
  String get myAppealsEmpty;

  /// No description provided for @appealStatusPending.
  ///
  /// In id, this message translates to:
  /// **'Sedang ditinjau'**
  String get appealStatusPending;

  /// No description provided for @appealStatusAccepted.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get appealStatusAccepted;

  /// No description provided for @appealStatusRejected.
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get appealStatusRejected;

  /// No description provided for @appealTargetSanction.
  ///
  /// In id, this message translates to:
  /// **'Sanksi akun'**
  String get appealTargetSanction;

  /// No description provided for @appealTargetPost.
  ///
  /// In id, this message translates to:
  /// **'Post'**
  String get appealTargetPost;

  /// No description provided for @appealTargetComment.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get appealTargetComment;

  /// No description provided for @appealTargetMessage.
  ///
  /// In id, this message translates to:
  /// **'Pesan'**
  String get appealTargetMessage;

  /// No description provided for @appealDecisionNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan: {note}'**
  String appealDecisionNote(String note);

  /// No description provided for @activeSanctions.
  ///
  /// In id, this message translates to:
  /// **'Sanksi aktif'**
  String get activeSanctions;

  /// No description provided for @noActiveSanctions.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sanksi aktif.'**
  String get noActiveSanctions;

  /// No description provided for @sanctionWarning.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get sanctionWarning;

  /// No description provided for @sanctionMute.
  ///
  /// In id, this message translates to:
  /// **'Dibatasi mengirim konten'**
  String get sanctionMute;

  /// No description provided for @sanctionBan.
  ///
  /// In id, this message translates to:
  /// **'Akun diblokir'**
  String get sanctionBan;

  /// No description provided for @sanctionUntil.
  ///
  /// In id, this message translates to:
  /// **'Sampai {date}'**
  String sanctionUntil(String date);

  /// No description provided for @sanctionPermanent.
  ///
  /// In id, this message translates to:
  /// **'Tanpa batas waktu'**
  String get sanctionPermanent;

  /// No description provided for @accountAppealsSection.
  ///
  /// In id, this message translates to:
  /// **'Banding & sanksi'**
  String get accountAppealsSection;

  /// No description provided for @accountAppealsHint.
  ///
  /// In id, this message translates to:
  /// **'Lihat sanksi aktif dan status banding Anda.'**
  String get accountAppealsHint;

  /// No description provided for @notifAppealAccepted.
  ///
  /// In id, this message translates to:
  /// **'Banding Anda diterima'**
  String get notifAppealAccepted;

  /// No description provided for @notifAppealRejected.
  ///
  /// In id, this message translates to:
  /// **'Banding Anda ditolak'**
  String get notifAppealRejected;

  /// No description provided for @notificationSettings.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsHint.
  ///
  /// In id, this message translates to:
  /// **'Atur notifikasi di aplikasi dan push per jenis, serta jam tenang.'**
  String get notificationSettingsHint;

  /// No description provided for @notifTypeReply.
  ///
  /// In id, this message translates to:
  /// **'Balasan'**
  String get notifTypeReply;

  /// No description provided for @notifTypeMention.
  ///
  /// In id, this message translates to:
  /// **'Mention'**
  String get notifTypeMention;

  /// No description provided for @notifTypeLike.
  ///
  /// In id, this message translates to:
  /// **'Suka'**
  String get notifTypeLike;

  /// No description provided for @notifTypeFollow.
  ///
  /// In id, this message translates to:
  /// **'Pengikut baru'**
  String get notifTypeFollow;

  /// No description provided for @notifTypeMessage.
  ///
  /// In id, this message translates to:
  /// **'Pesan chat'**
  String get notifTypeMessage;

  /// No description provided for @notifTypeAnnouncement.
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get notifTypeAnnouncement;

  /// No description provided for @notifTypeAppeal.
  ///
  /// In id, this message translates to:
  /// **'Banding'**
  String get notifTypeAppeal;

  /// No description provided for @notifTypeTrade.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get notifTypeTrade;

  /// No description provided for @notifTypeTradeHint.
  ///
  /// In id, this message translates to:
  /// **'Order dan transaksi saham'**
  String get notifTypeTradeHint;

  /// No description provided for @notifTypeFunds.
  ///
  /// In id, this message translates to:
  /// **'Dana'**
  String get notifTypeFunds;

  /// No description provided for @notifTypeFundsHint.
  ///
  /// In id, this message translates to:
  /// **'Setoran, penarikan, dan RDN'**
  String get notifTypeFundsHint;

  /// No description provided for @notifTypeMarket.
  ///
  /// In id, this message translates to:
  /// **'Pasar'**
  String get notifTypeMarket;

  /// No description provided for @notifTypeMarketHint.
  ///
  /// In id, this message translates to:
  /// **'Alert harga, IPO, dan aksi korporasi'**
  String get notifTypeMarketHint;

  /// No description provided for @notifTypeOltInfo.
  ///
  /// In id, this message translates to:
  /// **'Info'**
  String get notifTypeOltInfo;

  /// No description provided for @notifTypeOltInfoHint.
  ///
  /// In id, this message translates to:
  /// **'Informasi lain dari OLT'**
  String get notifTypeOltInfoHint;

  /// No description provided for @notifTypePromo.
  ///
  /// In id, this message translates to:
  /// **'Promo'**
  String get notifTypePromo;

  /// No description provided for @notifTypePromoHint.
  ///
  /// In id, this message translates to:
  /// **'Promo dan penawaran'**
  String get notifTypePromoHint;

  /// No description provided for @notifSectionOlt.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi OLT'**
  String get notifSectionOlt;

  /// No description provided for @notifGroupNew.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get notifGroupNew;

  /// No description provided for @notifGroupEarlier.
  ///
  /// In id, this message translates to:
  /// **'Sebelumnya'**
  String get notifGroupEarlier;

  /// No description provided for @notifOltImportantHint.
  ///
  /// In id, this message translates to:
  /// **'Pesan penting dari OLT selalu dikirim, termasuk saat jam tenang.'**
  String get notifOltImportantHint;

  /// No description provided for @notifInApp.
  ///
  /// In id, this message translates to:
  /// **'Di aplikasi'**
  String get notifInApp;

  /// No description provided for @notifPush.
  ///
  /// In id, this message translates to:
  /// **'Push'**
  String get notifPush;

  /// No description provided for @notifSupportAlwaysOn.
  ///
  /// In id, this message translates to:
  /// **'Pesan dari CS resmi selalu dikirim.'**
  String get notifSupportAlwaysOn;

  /// No description provided for @quietHours.
  ///
  /// In id, this message translates to:
  /// **'Jam tenang'**
  String get quietHours;

  /// No description provided for @quietHoursHint.
  ///
  /// In id, this message translates to:
  /// **'Push ditunda selama jam tenang (WIB). Notifikasi di aplikasi tetap masuk.'**
  String get quietHoursHint;

  /// No description provided for @quietHoursStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get quietHoursStart;

  /// No description provided for @quietHoursEnd.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get quietHoursEnd;

  /// No description provided for @quietHoursRange.
  ///
  /// In id, this message translates to:
  /// **'{start}–{end} WIB'**
  String quietHoursRange(String start, String end);

  /// No description provided for @notifFollowMany.
  ///
  /// In id, this message translates to:
  /// **'{name} dan {others} lainnya mulai mengikuti Anda'**
  String notifFollowMany(String name, int others);

  /// No description provided for @searchTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari post, pengguna, \$KODE, #hashtag'**
  String get searchHint;

  /// No description provided for @searchTabAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get searchTabAll;

  /// No description provided for @searchTabPosts.
  ///
  /// In id, this message translates to:
  /// **'Post'**
  String get searchTabPosts;

  /// No description provided for @searchTabUsers.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get searchTabUsers;

  /// No description provided for @searchTabStocks.
  ///
  /// In id, this message translates to:
  /// **'Saham'**
  String get searchTabStocks;

  /// No description provided for @searchTabHashtags.
  ///
  /// In id, this message translates to:
  /// **'Hashtag'**
  String get searchTabHashtags;

  /// No description provided for @searchMinLength.
  ///
  /// In id, this message translates to:
  /// **'Ketik minimal {min} karakter.'**
  String searchMinLength(int min);

  /// No description provided for @searchNoResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil untuk \"{query}\".'**
  String searchNoResults(String query);

  /// No description provided for @searchSeeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get searchSeeAll;

  /// No description provided for @postsLast7Days.
  ///
  /// In id, this message translates to:
  /// **'{count} post (7 hari)'**
  String postsLast7Days(int count);

  /// No description provided for @trendingHashtags.
  ///
  /// In id, this message translates to:
  /// **'Hashtag trending'**
  String get trendingHashtags;

  /// No description provided for @hashtagFeedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post dengan #{tag}.'**
  String hashtagFeedEmpty(String tag);

  /// No description provided for @trendingTitle.
  ///
  /// In id, this message translates to:
  /// **'Trending'**
  String get trendingTitle;

  /// No description provided for @trendingStocks.
  ///
  /// In id, this message translates to:
  /// **'Saham'**
  String get trendingStocks;

  /// No description provided for @trendingRising.
  ///
  /// In id, this message translates to:
  /// **'Naik daun'**
  String get trendingRising;

  /// No description provided for @trendingPosts.
  ///
  /// In id, this message translates to:
  /// **'Populer'**
  String get trendingPosts;

  /// No description provided for @trendingWindowDay.
  ///
  /// In id, this message translates to:
  /// **'24 jam'**
  String get trendingWindowDay;

  /// No description provided for @trendingWindowWeek.
  ///
  /// In id, this message translates to:
  /// **'7 hari'**
  String get trendingWindowWeek;

  /// No description provided for @trendingEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data trending.'**
  String get trendingEmpty;

  /// No description provided for @trendingPostCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 post} other{{count} post}}'**
  String trendingPostCount(int count);

  /// No description provided for @trendingGrowth.
  ///
  /// In id, this message translates to:
  /// **'+{percent}%'**
  String trendingGrowth(String percent);

  /// No description provided for @sentimentTitle.
  ///
  /// In id, this message translates to:
  /// **'Sentimen komunitas'**
  String get sentimentTitle;

  /// No description provided for @sentimentNoData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post berlabel sentimen.'**
  String get sentimentNoData;

  /// No description provided for @sentimentBasedOn.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{Dari 1 post} other{Dari {count} post}}'**
  String sentimentBasedOn(int count);

  /// No description provided for @editAction.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @editPostTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit post'**
  String get editPostTitle;

  /// No description provided for @editCommentTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit komentar'**
  String get editCommentTitle;

  /// No description provided for @editSaved.
  ///
  /// In id, this message translates to:
  /// **'Perubahan disimpan.'**
  String get editSaved;

  /// No description provided for @bookmarkAdd.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get bookmarkAdd;

  /// No description provided for @bookmarkRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari simpanan'**
  String get bookmarkRemove;

  /// No description provided for @bookmarksTitle.
  ///
  /// In id, this message translates to:
  /// **'Disimpan'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada post yang disimpan.'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarkAdded.
  ///
  /// In id, this message translates to:
  /// **'Post disimpan.'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In id, this message translates to:
  /// **'Dihapus dari simpanan.'**
  String get bookmarkRemoved;

  /// No description provided for @reactionAdd.
  ///
  /// In id, this message translates to:
  /// **'Beri reaksi'**
  String get reactionAdd;

  /// No description provided for @shareToChat.
  ///
  /// In id, this message translates to:
  /// **'Kirim ke chat'**
  String get shareToChat;

  /// No description provided for @sharePickRoom.
  ///
  /// In id, this message translates to:
  /// **'Kirim ke…'**
  String get sharePickRoom;

  /// No description provided for @shareMessageHint.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan pesan (opsional)'**
  String get shareMessageHint;

  /// No description provided for @shareSent.
  ///
  /// In id, this message translates to:
  /// **'Post dikirim ke chat.'**
  String get shareSent;

  /// No description provided for @shareNoRooms.
  ///
  /// In id, this message translates to:
  /// **'Belum ada chat. Mulai percakapan dulu.'**
  String get shareNoRooms;

  /// No description provided for @sharedPostUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Post tidak tersedia'**
  String get sharedPostUnavailable;

  /// No description provided for @sharedPostLabel.
  ///
  /// In id, this message translates to:
  /// **'Post'**
  String get sharedPostLabel;

  /// No description provided for @linkOpenTitle.
  ///
  /// In id, this message translates to:
  /// **'Buka tautan?'**
  String get linkOpenTitle;

  /// No description provided for @linkOpenBody.
  ///
  /// In id, this message translates to:
  /// **'Anda akan membuka {domain} di luar aplikasi. Pastikan Anda mempercayai situs ini.'**
  String linkOpenBody(String domain);

  /// No description provided for @linkOpenAction.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get linkOpenAction;

  /// No description provided for @linkOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Tautan tidak bisa dibuka.'**
  String get linkOpenFailed;

  /// No description provided for @botLabel.
  ///
  /// In id, this message translates to:
  /// **'Bot'**
  String get botLabel;

  /// No description provided for @slowModeBanner.
  ///
  /// In id, this message translates to:
  /// **'Slow mode: 1 pesan tiap {seconds} detik'**
  String slowModeBanner(int seconds);

  /// No description provided for @slowModeWait.
  ///
  /// In id, this message translates to:
  /// **'Tunggu {seconds} dtk'**
  String slowModeWait(int seconds);

  /// No description provided for @pinnedMessageLabel.
  ///
  /// In id, this message translates to:
  /// **'Pesan disematkan'**
  String get pinnedMessageLabel;

  /// No description provided for @dmRequestPendingSender.
  ///
  /// In id, this message translates to:
  /// **'Pesan Anda masih berupa permintaan ({sent}/{max}). {name} perlu menerimanya sebelum Anda bisa mengirim lebih banyak.'**
  String dmRequestPendingSender(String name, int sent, int max);

  /// No description provided for @dmRequestPendingRecipient.
  ///
  /// In id, this message translates to:
  /// **'{name} mengirim permintaan pesan. Terima untuk membalas.'**
  String dmRequestPendingRecipient(String name);

  /// No description provided for @moderatedContent.
  ///
  /// In id, this message translates to:
  /// **'Konten yang dimoderasi'**
  String get moderatedContent;

  /// No description provided for @moderatedContentEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada konten Anda yang dimoderasi dalam 90 hari terakhir.'**
  String get moderatedContentEmpty;

  /// No description provided for @moderationRemoved.
  ///
  /// In id, this message translates to:
  /// **'Dihapus moderator'**
  String get moderationRemoved;

  /// No description provided for @stockCardSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim kartu saham'**
  String get stockCardSend;

  /// No description provided for @stockCardHint.
  ///
  /// In id, this message translates to:
  /// **'Kode saham, mis. BBCA, TLKM'**
  String get stockCardHint;

  /// No description provided for @stockCardAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get stockCardAdd;

  /// No description provided for @stockCardInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kode saham tidak valid'**
  String get stockCardInvalid;

  /// No description provided for @stockCardLimit.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {count} saham per pesan'**
  String stockCardLimit(int count);

  /// No description provided for @bannerOpen.
  ///
  /// In id, this message translates to:
  /// **'Selengkapnya'**
  String get bannerOpen;

  /// No description provided for @readMore.
  ///
  /// In id, this message translates to:
  /// **'Baca lebih lanjut'**
  String get readMore;

  /// No description provided for @bannerDismiss.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get bannerDismiss;

  /// No description provided for @promoPopupCta.
  ///
  /// In id, this message translates to:
  /// **'Lihat'**
  String get promoPopupCta;

  /// No description provided for @promoPopupLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get promoPopupLater;

  /// No description provided for @promoPopupClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup promo'**
  String get promoPopupClose;

  /// No description provided for @promoPopupLabel.
  ///
  /// In id, this message translates to:
  /// **'Promo'**
  String get promoPopupLabel;

  /// No description provided for @draftsTitle.
  ///
  /// In id, this message translates to:
  /// **'Draf postingan'**
  String get draftsTitle;

  /// No description provided for @draftsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada draf.'**
  String get draftsEmpty;

  /// No description provided for @draftNoText.
  ///
  /// In id, this message translates to:
  /// **'(tanpa teks)'**
  String get draftNoText;

  /// No description provided for @draftSaved.
  ///
  /// In id, this message translates to:
  /// **'Draf tersimpan'**
  String get draftSaved;

  /// No description provided for @draftSavedLocally.
  ///
  /// In id, this message translates to:
  /// **'Draf tersimpan di perangkat ini'**
  String get draftSavedLocally;

  /// No description provided for @draftReplaced.
  ///
  /// In id, this message translates to:
  /// **'Draf ini diperbarui di perangkat lain; versi terbaru dimuat.'**
  String get draftReplaced;

  /// No description provided for @draftLimit.
  ///
  /// In id, this message translates to:
  /// **'Batas {count} draf tercapai. Draf ini hanya tersimpan di perangkat ini.'**
  String draftLimit(int count);

  /// No description provided for @notifMentionRoom.
  ///
  /// In id, this message translates to:
  /// **'{name} menyebut Anda di {room}'**
  String notifMentionRoom(String name, String room);

  /// No description provided for @notifFollowedPost.
  ///
  /// In id, this message translates to:
  /// **'{name} membuat postingan baru'**
  String notifFollowedPost(String name);

  /// No description provided for @notifFollowedPostMany.
  ///
  /// In id, this message translates to:
  /// **'{name} membuat {count} postingan baru'**
  String notifFollowedPostMany(String name, int count);

  /// No description provided for @notifWatchlistDigest.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan saham pantauan'**
  String get notifWatchlistDigest;

  /// No description provided for @notifWatchlistDigestBody.
  ///
  /// In id, this message translates to:
  /// **'{count} postingan baru tentang {stocks}{others, plural, =0{} other{, dan {others} saham lainnya}}'**
  String notifWatchlistDigestBody(int count, String stocks, int others);

  /// No description provided for @notifTargetPost.
  ///
  /// In id, this message translates to:
  /// **'Postingan'**
  String get notifTargetPost;

  /// No description provided for @notifTargetComment.
  ///
  /// In id, this message translates to:
  /// **'Komentar'**
  String get notifTargetComment;

  /// No description provided for @notifTargetMessage.
  ///
  /// In id, this message translates to:
  /// **'Pesan'**
  String get notifTargetMessage;

  /// No description provided for @notifModerationHidden.
  ///
  /// In id, this message translates to:
  /// **'{target} Anda disembunyikan moderator'**
  String notifModerationHidden(String target);

  /// No description provided for @notifModerationRemoved.
  ///
  /// In id, this message translates to:
  /// **'{target} Anda dihapus moderator'**
  String notifModerationRemoved(String target);

  /// No description provided for @notifModerationAppealable.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk melihat detail dan mengajukan banding'**
  String get notifModerationAppealable;

  /// No description provided for @notifModerationAppealed.
  ///
  /// In id, this message translates to:
  /// **'Banding untuk konten ini sudah diajukan'**
  String get notifModerationAppealed;

  /// No description provided for @notifRoomMuted.
  ///
  /// In id, this message translates to:
  /// **'Anda dibisukan moderator di {room}'**
  String notifRoomMuted(String room);

  /// No description provided for @notifRoomUnmuted.
  ///
  /// In id, this message translates to:
  /// **'Bisu Anda di {room} dicabut'**
  String notifRoomUnmuted(String room);

  /// No description provided for @notifRoomMutedUntil.
  ///
  /// In id, this message translates to:
  /// **'Anda bisa mengirim pesan lagi setelah {time}'**
  String notifRoomMutedUntil(String time);

  /// No description provided for @notifRoomUnmutedBody.
  ///
  /// In id, this message translates to:
  /// **'Anda bisa mengirim pesan lagi di room ini'**
  String get notifRoomUnmutedBody;

  /// No description provided for @notifTypeFollowedPost.
  ///
  /// In id, this message translates to:
  /// **'Postingan akun yang diikuti'**
  String get notifTypeFollowedPost;

  /// No description provided for @notifTypeFollowedPostHint.
  ///
  /// In id, this message translates to:
  /// **'Push bawaan mati'**
  String get notifTypeFollowedPostHint;

  /// No description provided for @notifTypeWatchlistDigest.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan saham pantauan'**
  String get notifTypeWatchlistDigest;

  /// No description provided for @notifTypeWatchlistDigestHint.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari pukul 17.05 WIB'**
  String get notifTypeWatchlistDigestHint;

  /// No description provided for @notifTypeModeration.
  ///
  /// In id, this message translates to:
  /// **'Moderasi'**
  String get notifTypeModeration;

  /// No description provided for @notifTypeModerationHint.
  ///
  /// In id, this message translates to:
  /// **'Selalu tampil di aplikasi'**
  String get notifTypeModerationHint;

  /// No description provided for @roomModeratorBadge.
  ///
  /// In id, this message translates to:
  /// **'Moderator'**
  String get roomModeratorBadge;

  /// No description provided for @roomModeratorNotice.
  ///
  /// In id, this message translates to:
  /// **'Anda moderator room ini. Tekan lama pesan anggota untuk aksi moderasi.'**
  String get roomModeratorNotice;

  /// No description provided for @roomModHide.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan pesan'**
  String get roomModHide;

  /// No description provided for @roomModMute.
  ///
  /// In id, this message translates to:
  /// **'Bisukan anggota'**
  String get roomModMute;

  /// No description provided for @roomModEscalate.
  ///
  /// In id, this message translates to:
  /// **'Eskalasi ke staf'**
  String get roomModEscalate;

  /// No description provided for @roomModHideTitle.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan pesan ini?'**
  String get roomModHideTitle;

  /// No description provided for @roomModHideBody.
  ///
  /// In id, this message translates to:
  /// **'Pesan disembunyikan dari anggota lain. Staf meninjau setiap aksi moderator dan pengirim bisa mengajukan banding.'**
  String get roomModHideBody;

  /// No description provided for @roomModMuteTitle.
  ///
  /// In id, this message translates to:
  /// **'Bisukan {name} di room ini'**
  String roomModMuteTitle(String name);

  /// No description provided for @roomModMuteBody.
  ///
  /// In id, this message translates to:
  /// **'Anggota tetap bisa membaca room, tetapi tidak bisa mengirim pesan sampai waktu bisu berakhir.'**
  String get roomModMuteBody;

  /// No description provided for @roomModEscalateTitle.
  ///
  /// In id, this message translates to:
  /// **'Eskalasi pesan ke staf'**
  String get roomModEscalateTitle;

  /// No description provided for @roomModEscalateBody.
  ///
  /// In id, this message translates to:
  /// **'Pesan dikirim ke antrean laporan staf untuk ditinjau. Pesan tetap tampil sampai staf memutuskan.'**
  String get roomModEscalateBody;

  /// No description provided for @roomModReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get roomModReason;

  /// No description provided for @roomModDuration.
  ///
  /// In id, this message translates to:
  /// **'Lama bisu'**
  String get roomModDuration;

  /// No description provided for @roomModNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Catatan untuk staf (opsional)'**
  String get roomModNoteHint;

  /// No description provided for @roomModMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit'**
  String roomModMinutes(int minutes);

  /// No description provided for @roomModHours.
  ///
  /// In id, this message translates to:
  /// **'{hours} jam'**
  String roomModHours(int hours);

  /// No description provided for @roomModHidden.
  ///
  /// In id, this message translates to:
  /// **'Pesan disembunyikan'**
  String get roomModHidden;

  /// No description provided for @roomModMuted.
  ///
  /// In id, this message translates to:
  /// **'{name} dibisukan sampai {time}'**
  String roomModMuted(String name, String time);

  /// No description provided for @roomModEscalated.
  ///
  /// In id, this message translates to:
  /// **'Pesan dieskalasi ke staf'**
  String get roomModEscalated;

  /// No description provided for @roomModMemberMuted.
  ///
  /// In id, this message translates to:
  /// **'Dibisukan sampai {time}'**
  String roomModMemberMuted(String time);

  /// No description provided for @roomMutedBanner.
  ///
  /// In id, this message translates to:
  /// **'Moderator membisukan Anda di room ini sampai {time}. Anda tetap bisa membaca pesan.'**
  String roomMutedBanner(String time);

  /// No description provided for @roomMutedComposer.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang dibisukan di room ini'**
  String get roomMutedComposer;

  /// No description provided for @errorRoomMuted.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang dibisukan moderator di room ini.'**
  String get errorRoomMuted;

  /// No description provided for @errorNotRoomModerator.
  ///
  /// In id, this message translates to:
  /// **'Anda bukan lagi moderator room ini.'**
  String get errorNotRoomModerator;

  /// No description provided for @errorRoomModeratorSuspended.
  ///
  /// In id, this message translates to:
  /// **'Hak moderator Anda sedang ditangguhkan.'**
  String get errorRoomModeratorSuspended;

  /// No description provided for @errorRoomModTarget.
  ///
  /// In id, this message translates to:
  /// **'Akun resmi, moderator lain, dan pesan Anda sendiri tidak bisa dimoderasi.'**
  String get errorRoomModTarget;

  /// No description provided for @errorAlreadyModerated.
  ///
  /// In id, this message translates to:
  /// **'Aksi ini sudah dilakukan sebelumnya.'**
  String get errorAlreadyModerated;

  /// No description provided for @photo.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get photo;

  /// No description provided for @replyOriginalMissing.
  ///
  /// In id, this message translates to:
  /// **'Pesan yang dibalas tidak ditemukan.'**
  String get replyOriginalMissing;

  /// No description provided for @pasteImageFailed.
  ///
  /// In id, this message translates to:
  /// **'Gambar dari clipboard tidak bisa dikirim.'**
  String get pasteImageFailed;

  /// No description provided for @messageInfo.
  ///
  /// In id, this message translates to:
  /// **'Info pesan'**
  String get messageInfo;

  /// No description provided for @messageInfoRead.
  ///
  /// In id, this message translates to:
  /// **'Dibaca'**
  String get messageInfoRead;

  /// No description provided for @messageInfoDelivered.
  ///
  /// In id, this message translates to:
  /// **'Terkirim'**
  String get messageInfoDelivered;

  /// No description provided for @messageInfoReadBy.
  ///
  /// In id, this message translates to:
  /// **'Dibaca oleh'**
  String get messageInfoReadBy;

  /// No description provided for @messageInfoDeliveredTo.
  ///
  /// In id, this message translates to:
  /// **'Terkirim ke'**
  String get messageInfoDeliveredTo;

  /// No description provided for @messageInfoNotYet.
  ///
  /// In id, this message translates to:
  /// **'Belum'**
  String get messageInfoNotYet;

  /// No description provided for @messageInfoTimeUnknown.
  ///
  /// In id, this message translates to:
  /// **'Waktu tidak tercatat'**
  String get messageInfoTimeUnknown;

  /// No description provided for @messageInfoPending.
  ///
  /// In id, this message translates to:
  /// **'{count} anggota belum menerima'**
  String messageInfoPending(int count);

  /// No description provided for @messageInfoTime.
  ///
  /// In id, this message translates to:
  /// **'{day}, {time}'**
  String messageInfoTime(String day, String time);

  /// No description provided for @messageInfoFailed.
  ///
  /// In id, this message translates to:
  /// **'Info pesan tidak bisa dimuat.'**
  String get messageInfoFailed;

  /// No description provided for @copyMessage.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get copyMessage;

  /// No description provided for @messageCopied.
  ///
  /// In id, this message translates to:
  /// **'Pesan disalin'**
  String get messageCopied;

  /// No description provided for @moreActions.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get moreActions;

  /// No description provided for @attachmentsTooMany.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 4 lampiran per pesan.'**
  String get attachmentsTooMany;

  /// No description provided for @removeAttachment.
  ///
  /// In id, this message translates to:
  /// **'Hapus lampiran'**
  String get removeAttachment;

  /// No description provided for @imageTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Gambar terlalu besar untuk dikirim.'**
  String get imageTooLarge;

  /// No description provided for @imageDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh'**
  String get imageDownload;

  /// No description provided for @imageSaved.
  ///
  /// In id, this message translates to:
  /// **'Gambar disimpan'**
  String get imageSaved;

  /// No description provided for @imageSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gambar tidak bisa diunduh.'**
  String get imageSaveFailed;

  /// No description provided for @imageOpen.
  ///
  /// In id, this message translates to:
  /// **'Lihat gambar'**
  String get imageOpen;

  /// No description provided for @imagePrevious.
  ///
  /// In id, this message translates to:
  /// **'Gambar sebelumnya'**
  String get imagePrevious;

  /// No description provided for @imageNext.
  ///
  /// In id, this message translates to:
  /// **'Gambar berikutnya'**
  String get imageNext;

  /// No description provided for @imageCounter.
  ///
  /// In id, this message translates to:
  /// **'{index} dari {count}'**
  String imageCounter(int index, int count);

  /// No description provided for @imageZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get imageZoomIn;

  /// No description provided for @imageZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil'**
  String get imageZoomOut;

  /// No description provided for @imageRotate.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get imageRotate;

  /// No description provided for @imageActualSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran pas layar'**
  String get imageActualSize;

  /// No description provided for @imageCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin gambar'**
  String get imageCopy;

  /// No description provided for @imageCopied.
  ///
  /// In id, this message translates to:
  /// **'Gambar disalin'**
  String get imageCopied;

  /// No description provided for @imageCopyFailed.
  ///
  /// In id, this message translates to:
  /// **'Gambar tidak bisa disalin.'**
  String get imageCopyFailed;

  /// No description provided for @imageReact.
  ///
  /// In id, this message translates to:
  /// **'Beri reaksi'**
  String get imageReact;

  /// No description provided for @jumpToLatest.
  ///
  /// In id, this message translates to:
  /// **'Ke pesan terbaru'**
  String get jumpToLatest;

  /// No description provided for @jumpToLatestUnread.
  ///
  /// In id, this message translates to:
  /// **'{count} pesan baru, ke pesan terbaru'**
  String jumpToLatestUnread(int count);

  /// No description provided for @contactCall.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get contactCall;

  /// No description provided for @contactSendEmail.
  ///
  /// In id, this message translates to:
  /// **'Kirim email'**
  String get contactSendEmail;

  /// No description provided for @contactCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin'**
  String get contactCopy;

  /// No description provided for @contactPhoneCopied.
  ///
  /// In id, this message translates to:
  /// **'Nomor disalin'**
  String get contactPhoneCopied;

  /// No description provided for @contactEmailCopied.
  ///
  /// In id, this message translates to:
  /// **'Email disalin'**
  String get contactEmailCopied;

  /// No description provided for @helpTitle.
  ///
  /// In id, this message translates to:
  /// **'Pusat Bantuan'**
  String get helpTitle;

  /// No description provided for @helpSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari pertanyaan, misalnya: lupa PIN'**
  String get helpSearchHint;

  /// No description provided for @helpSearchClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get helpSearchClear;

  /// No description provided for @helpCategoryCount.
  ///
  /// In id, this message translates to:
  /// **'{count} artikel'**
  String helpCategoryCount(int count);

  /// No description provided for @helpEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada artikel bantuan.'**
  String get helpEmpty;

  /// No description provided for @helpSearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada artikel yang cocok dengan “{query}”.'**
  String helpSearchEmpty(String query);

  /// No description provided for @helpSearchSaved.
  ///
  /// In id, this message translates to:
  /// **'Hasil dari Pusat Bantuan yang tersimpan.'**
  String get helpSearchSaved;

  /// No description provided for @helpOffline.
  ///
  /// In id, this message translates to:
  /// **'Anda sedang offline. Menampilkan Pusat Bantuan yang tersimpan.'**
  String get helpOffline;

  /// No description provided for @helpUpdated.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui {date}'**
  String helpUpdated(String date);

  /// No description provided for @helpWasHelpful.
  ///
  /// In id, this message translates to:
  /// **'Apakah ini membantu?'**
  String get helpWasHelpful;

  /// No description provided for @helpYes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get helpYes;

  /// No description provided for @helpNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get helpNo;

  /// No description provided for @helpFeedbackThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih atas masukan Anda.'**
  String get helpFeedbackThanks;

  /// No description provided for @helpFeedbackComment.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan lebih lanjut (opsional)'**
  String get helpFeedbackComment;

  /// No description provided for @helpFeedbackSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get helpFeedbackSend;

  /// No description provided for @helpFeedbackCommentSent.
  ///
  /// In id, this message translates to:
  /// **'Komentar Anda sudah terkirim.'**
  String get helpFeedbackCommentSent;

  /// No description provided for @helpStillNeedHelp.
  ///
  /// In id, this message translates to:
  /// **'Masih butuh bantuan?'**
  String get helpStillNeedHelp;

  /// No description provided for @helpChatCs.
  ///
  /// In id, this message translates to:
  /// **'Chat CS'**
  String get helpChatCs;

  /// No description provided for @helpSuggestionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Mungkin ini membantu'**
  String get helpSuggestionsTitle;

  /// No description provided for @helpSuggestionsHint.
  ///
  /// In id, this message translates to:
  /// **'Artikel untuk topik {topic}. Bila belum terjawab, lanjutkan ke chat CS.'**
  String helpSuggestionsHint(String topic);

  /// No description provided for @helpContinueChat.
  ///
  /// In id, this message translates to:
  /// **'Lanjut chat dengan CS'**
  String get helpContinueChat;

  /// No description provided for @helpPickAnotherTopic.
  ///
  /// In id, this message translates to:
  /// **'Pilih topik lain'**
  String get helpPickAnotherTopic;

  /// No description provided for @errorHelpArticleNotFound.
  ///
  /// In id, this message translates to:
  /// **'Artikel ini sudah tidak tersedia.'**
  String get errorHelpArticleNotFound;

  /// No description provided for @errorHelpQuery.
  ///
  /// In id, this message translates to:
  /// **'Kata pencarian harus 2–100 karakter.'**
  String get errorHelpQuery;

  /// No description provided for @documentTypePdf.
  ///
  /// In id, this message translates to:
  /// **'PDF'**
  String get documentTypePdf;

  /// No description provided for @documentTypeWord.
  ///
  /// In id, this message translates to:
  /// **'Word'**
  String get documentTypeWord;

  /// No description provided for @documentTypeExcel.
  ///
  /// In id, this message translates to:
  /// **'Excel'**
  String get documentTypeExcel;

  /// No description provided for @documentTypePowerPoint.
  ///
  /// In id, this message translates to:
  /// **'PowerPoint'**
  String get documentTypePowerPoint;

  /// No description provided for @documentTypeCsv.
  ///
  /// In id, this message translates to:
  /// **'CSV'**
  String get documentTypeCsv;

  /// No description provided for @documentTypeText.
  ///
  /// In id, this message translates to:
  /// **'Teks'**
  String get documentTypeText;

  /// No description provided for @documentTypeOther.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get documentTypeOther;

  /// No description provided for @video.
  ///
  /// In id, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @videoPlay.
  ///
  /// In id, this message translates to:
  /// **'Putar video {duration}'**
  String videoPlay(String duration);

  /// No description provided for @videoOpenExternal.
  ///
  /// In id, this message translates to:
  /// **'Buka di pemutar video'**
  String get videoOpenExternal;

  /// No description provided for @videoPlayFailed.
  ///
  /// In id, this message translates to:
  /// **'Video tidak bisa diputar di sini. Coba lagi atau buka di pemutar video perangkat.'**
  String get videoPlayFailed;

  /// No description provided for @videoOpenFailed.
  ///
  /// In id, this message translates to:
  /// **'Video tidak bisa dibuka. Coba lagi.'**
  String get videoOpenFailed;

  /// No description provided for @videoDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh video'**
  String get videoDownload;

  /// No description provided for @videoSaved.
  ///
  /// In id, this message translates to:
  /// **'Video disimpan.'**
  String get videoSaved;

  /// No description provided for @videoDownloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Video tidak bisa diunduh. Coba lagi.'**
  String get videoDownloadFailed;

  /// No description provided for @videoPause.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get videoPause;

  /// No description provided for @videoResume.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get videoResume;

  /// No description provided for @attachmentChecking.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa file…'**
  String get attachmentChecking;

  /// No description provided for @composeAttachFiles.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan foto, video, atau dokumen'**
  String get composeAttachFiles;

  /// No description provided for @attachmentGroupImages.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get attachmentGroupImages;

  /// No description provided for @attachmentGroupVideos.
  ///
  /// In id, this message translates to:
  /// **'Video'**
  String get attachmentGroupVideos;

  /// No description provided for @attachmentGroupDocuments.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get attachmentGroupDocuments;

  /// No description provided for @attachmentFormatRejected.
  ///
  /// In id, this message translates to:
  /// **'{name} tidak bisa dikirim. Format yang diterima: {formats}.'**
  String attachmentFormatRejected(String name, String formats);

  /// No description provided for @attachmentFileTooLarge.
  ///
  /// In id, this message translates to:
  /// **'{name} terlalu besar. Batasnya {limit}.'**
  String attachmentFileTooLarge(String name, String limit);

  /// No description provided for @heicUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Foto HEIC belum bisa diubah ke JPEG di perangkat ini. Simpan foto sebagai JPEG, lalu kirim lagi.'**
  String get heicUnsupported;

  /// No description provided for @errorAttachmentTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Lampiran melebihi batas ukuran untuk chat ini.'**
  String get errorAttachmentTooLarge;

  /// No description provided for @errorAttachmentTooLong.
  ///
  /// In id, this message translates to:
  /// **'Video melebihi batas durasi. Kirim video yang lebih pendek.'**
  String get errorAttachmentTooLong;

  /// No description provided for @errorKindDisabled.
  ///
  /// In id, this message translates to:
  /// **'Jenis lampiran ini sedang tidak diterima di chat CS.'**
  String get errorKindDisabled;

  /// No description provided for @errorPolicyUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Daftar format lampiran belum bisa dimuat. Coba lagi sebentar lagi.'**
  String get errorPolicyUnavailable;

  /// No description provided for @errorOfficeMacro.
  ///
  /// In id, this message translates to:
  /// **'Dokumen berisi makro dan ditolak demi keamanan. Simpan ulang sebagai .docx, .xlsx, atau .pptx tanpa makro.'**
  String get errorOfficeMacro;

  /// No description provided for @errorOfficeUnsafe.
  ///
  /// In id, this message translates to:
  /// **'Dokumen berisi objek tertanam yang tidak aman sehingga ditolak.'**
  String get errorOfficeUnsafe;

  /// No description provided for @errorArchiveBomb.
  ///
  /// In id, this message translates to:
  /// **'Isi dokumen tidak wajar (terlalu banyak atau terlalu besar saat dibuka) sehingga ditolak.'**
  String get errorArchiveBomb;

  /// No description provided for @errorInvalidText.
  ///
  /// In id, this message translates to:
  /// **'File teks atau CSV harus memakai UTF-8 dan tidak boleh berisi data biner.'**
  String get errorInvalidText;

  /// No description provided for @errorInvalidVideo.
  ///
  /// In id, this message translates to:
  /// **'Video rusak atau formatnya tidak didukung. Gunakan MP4 (H.264), MOV, atau WebM.'**
  String get errorInvalidVideo;

  /// No description provided for @errorVideoTooLong.
  ///
  /// In id, this message translates to:
  /// **'Video terlalu panjang. Potong videonya, lalu kirim lagi.'**
  String get errorVideoTooLong;

  /// No description provided for @errorMalwareDetected.
  ///
  /// In id, this message translates to:
  /// **'File ditolak karena pemindai antivirus mendeteksi isi berbahaya.'**
  String get errorMalwareDetected;

  /// No description provided for @errorScannerUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Pemeriksaan file sedang tidak tersedia. Coba kirim lagi sebentar lagi.'**
  String get errorScannerUnavailable;

  /// No description provided for @supportQueueEta.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan menunggu ± {minutes} menit'**
  String supportQueueEta(int minutes);

  /// No description provided for @supportIntakeTitle.
  ///
  /// In id, this message translates to:
  /// **'Sebelum mulai chat'**
  String get supportIntakeTitle;

  /// No description provided for @supportIntakeHint.
  ///
  /// In id, this message translates to:
  /// **'Jawab beberapa pertanyaan singkat agar CS bisa langsung membantu.'**
  String get supportIntakeHint;

  /// No description provided for @supportIntakeSubmit.
  ///
  /// In id, this message translates to:
  /// **'Mulai chat'**
  String get supportIntakeSubmit;

  /// No description provided for @supportIntakeOptional.
  ///
  /// In id, this message translates to:
  /// **'opsional'**
  String get supportIntakeOptional;

  /// No description provided for @supportIntakePickDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get supportIntakePickDate;

  /// No description provided for @supportIntakeRequired.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi.'**
  String get supportIntakeRequired;

  /// No description provided for @supportIntakeTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} karakter.'**
  String supportIntakeTooLong(int max);

  /// No description provided for @supportIntakeNumber.
  ///
  /// In id, this message translates to:
  /// **'Isi dengan angka, misalnya 1500 atau 12,5.'**
  String get supportIntakeNumber;

  /// No description provided for @supportIntakeDate.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal yang valid.'**
  String get supportIntakeDate;

  /// No description provided for @supportIntakeChoice.
  ///
  /// In id, this message translates to:
  /// **'Pilih salah satu.'**
  String get supportIntakeChoice;

  /// No description provided for @errorIntakeRequired.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi dulu pertanyaan yang wajib diisi.'**
  String get errorIntakeRequired;

  /// No description provided for @errorInvalidIntakeAnswers.
  ///
  /// In id, this message translates to:
  /// **'Ada jawaban yang belum sesuai. Periksa lagi isian Anda.'**
  String get errorInvalidIntakeAnswers;

  /// No description provided for @supportIncidentInfo.
  ///
  /// In id, this message translates to:
  /// **'Info layanan'**
  String get supportIncidentInfo;

  /// No description provided for @supportIncidentWarning.
  ///
  /// In id, this message translates to:
  /// **'Gangguan layanan'**
  String get supportIncidentWarning;

  /// No description provided for @supportIncidentCritical.
  ///
  /// In id, this message translates to:
  /// **'Gangguan serius'**
  String get supportIncidentCritical;

  /// No description provided for @supportIncidentMore.
  ///
  /// In id, this message translates to:
  /// **'Selengkapnya'**
  String get supportIncidentMore;

  /// No description provided for @supportIncidentDismiss.
  ///
  /// In id, this message translates to:
  /// **'Tutup pemberitahuan'**
  String get supportIncidentDismiss;

  /// No description provided for @supportLeaveMessage.
  ///
  /// In id, this message translates to:
  /// **'Tinggalkan pesan'**
  String get supportLeaveMessage;

  /// No description provided for @supportLeaveMessageTitle.
  ///
  /// In id, this message translates to:
  /// **'CS sedang di luar jam layanan'**
  String get supportLeaveMessageTitle;

  /// No description provided for @supportLeaveMessageHint.
  ///
  /// In id, this message translates to:
  /// **'Tinggalkan pesan sekarang. Tiket Anda tercatat dan dibalas saat layanan buka.'**
  String get supportLeaveMessageHint;

  /// No description provided for @supportLeaveMessageArticles.
  ///
  /// In id, this message translates to:
  /// **'Sambil menunggu, artikel ini mungkin menjawab pertanyaan Anda.'**
  String get supportLeaveMessageArticles;

  /// No description provided for @supportSurveyReasons.
  ///
  /// In id, this message translates to:
  /// **'Apa yang kurang?'**
  String get supportSurveyReasons;

  /// No description provided for @supportSurveyReasonsHint.
  ///
  /// In id, this message translates to:
  /// **'Boleh pilih lebih dari satu.'**
  String get supportSurveyReasonsHint;

  /// No description provided for @supportRateBad.
  ///
  /// In id, this message translates to:
  /// **'Kurang puas'**
  String get supportRateBad;

  /// No description provided for @supportRateOkay.
  ///
  /// In id, this message translates to:
  /// **'Biasa saja'**
  String get supportRateOkay;

  /// No description provided for @supportRateGood.
  ///
  /// In id, this message translates to:
  /// **'Puas'**
  String get supportRateGood;

  /// No description provided for @supportReplySuggestions.
  ///
  /// In id, this message translates to:
  /// **'Saran balasan'**
  String get supportReplySuggestions;

  /// No description provided for @supportTranscriptDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh transkrip'**
  String get supportTranscriptDownload;

  /// No description provided for @supportTranscriptSaved.
  ///
  /// In id, this message translates to:
  /// **'Transkrip disimpan.'**
  String get supportTranscriptSaved;

  /// No description provided for @supportTranscriptTitle.
  ///
  /// In id, this message translates to:
  /// **'Transkrip chat CS'**
  String get supportTranscriptTitle;

  /// No description provided for @supportTranscriptTicket.
  ///
  /// In id, this message translates to:
  /// **'Tiket'**
  String get supportTranscriptTicket;

  /// No description provided for @supportTranscriptTopic.
  ///
  /// In id, this message translates to:
  /// **'Topik'**
  String get supportTranscriptTopic;

  /// No description provided for @supportTranscriptCreated.
  ///
  /// In id, this message translates to:
  /// **'Dibuat'**
  String get supportTranscriptCreated;

  /// No description provided for @supportTranscriptResolved.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get supportTranscriptResolved;

  /// No description provided for @supportTranscriptClosed.
  ///
  /// In id, this message translates to:
  /// **'Ditutup'**
  String get supportTranscriptClosed;

  /// No description provided for @supportTranscriptCustomer.
  ///
  /// In id, this message translates to:
  /// **'Anda'**
  String get supportTranscriptCustomer;

  /// No description provided for @supportTranscriptAgent.
  ///
  /// In id, this message translates to:
  /// **'CS'**
  String get supportTranscriptAgent;

  /// No description provided for @supportTranscriptSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get supportTranscriptSystem;

  /// No description provided for @supportTranscriptDeleted.
  ///
  /// In id, this message translates to:
  /// **'(pesan dihapus)'**
  String get supportTranscriptDeleted;

  /// No description provided for @supportTranscriptAttachments.
  ///
  /// In id, this message translates to:
  /// **'Lampiran'**
  String get supportTranscriptAttachments;

  /// No description provided for @supportTranscriptEmpty.
  ///
  /// In id, this message translates to:
  /// **'(belum ada pesan)'**
  String get supportTranscriptEmpty;

  /// No description provided for @supportTranscriptFilePrefix.
  ///
  /// In id, this message translates to:
  /// **'transkrip'**
  String get supportTranscriptFilePrefix;

  /// No description provided for @errorTicketActive.
  ///
  /// In id, this message translates to:
  /// **'Transkrip tersedia setelah tiket selesai.'**
  String get errorTicketActive;

  /// No description provided for @errorSurveyChanged.
  ///
  /// In id, this message translates to:
  /// **'Survei baru saja diperbarui. Tutup dialog lalu beri nilai lagi.'**
  String get errorSurveyChanged;

  /// No description provided for @guestSupportEntry.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa masuk? Hubungi CS'**
  String get guestSupportEntry;

  /// No description provided for @guestSupportTitle.
  ///
  /// In id, this message translates to:
  /// **'Hubungi CS'**
  String get guestSupportTitle;

  /// No description provided for @guestSupportFormTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa masuk ke akun?'**
  String get guestSupportFormTitle;

  /// No description provided for @guestSupportFormHint.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan masalahnya tanpa perlu login. CS membalas di halaman ini.'**
  String get guestSupportFormHint;

  /// No description provided for @guestSupportSecurityTitle.
  ///
  /// In id, this message translates to:
  /// **'Jaga keamanan akun Anda'**
  String get guestSupportSecurityTitle;

  /// No description provided for @guestSupportSecurityNote.
  ///
  /// In id, this message translates to:
  /// **'CS tidak pernah meminta password, PIN, atau OTP. Reset password/PIN hanya dikirim ke email yang terdaftar di akun Anda.'**
  String get guestSupportSecurityNote;

  /// No description provided for @guestSupportName.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get guestSupportName;

  /// No description provided for @guestSupportLoginId.
  ///
  /// In id, this message translates to:
  /// **'Login ID'**
  String get guestSupportLoginId;

  /// No description provided for @guestSupportLoginIdHint.
  ///
  /// In id, this message translates to:
  /// **'Huruf besar, misalnya BUDI01'**
  String get guestSupportLoginIdHint;

  /// No description provided for @guestSupportProblem.
  ///
  /// In id, this message translates to:
  /// **'Masalah yang dialami'**
  String get guestSupportProblem;

  /// No description provided for @guestSupportDescription.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan masalahnya'**
  String get guestSupportDescription;

  /// No description provided for @guestSupportDescriptionHint.
  ///
  /// In id, this message translates to:
  /// **'Misalnya: lupa PIN setelah ganti HP. Jangan tulis password, PIN, atau OTP.'**
  String get guestSupportDescriptionHint;

  /// No description provided for @guestSupportSubmit.
  ///
  /// In id, this message translates to:
  /// **'Kirim pengaduan'**
  String get guestSupportSubmit;

  /// No description provided for @guestSupportNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Isi nama Anda.'**
  String get guestSupportNameRequired;

  /// No description provided for @guestSupportNameLength.
  ///
  /// In id, this message translates to:
  /// **'Nama {min}–{max} karakter.'**
  String guestSupportNameLength(int min, int max);

  /// No description provided for @guestSupportLoginIdInvalid.
  ///
  /// In id, this message translates to:
  /// **'Login ID hanya boleh huruf A–Z, angka, titik, garis bawah, @, dan tanda hubung (maks. {max} karakter).'**
  String guestSupportLoginIdInvalid(int max);

  /// No description provided for @guestSupportProblemRequired.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis masalah.'**
  String get guestSupportProblemRequired;

  /// No description provided for @guestSupportDescriptionRequired.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan masalahnya.'**
  String get guestSupportDescriptionRequired;

  /// No description provided for @guestSupportDescriptionLength.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan masalahnya ({min}–{max} karakter).'**
  String guestSupportDescriptionLength(int min, int max);

  /// No description provided for @guestSupportTicket.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan #{number}'**
  String guestSupportTicket(String number);

  /// No description provided for @guestSupportEnd.
  ///
  /// In id, this message translates to:
  /// **'Akhiri'**
  String get guestSupportEnd;

  /// No description provided for @guestSupportEndConfirm.
  ///
  /// In id, this message translates to:
  /// **'Akhiri pengaduan ini? Percakapan tidak bisa dibuka lagi dari perangkat ini.'**
  String get guestSupportEndConfirm;

  /// No description provided for @guestSupportReconnecting.
  ///
  /// In id, this message translates to:
  /// **'Koneksi terputus. Mencoba lagi…'**
  String get guestSupportReconnecting;

  /// No description provided for @guestSupportSessionSaved.
  ///
  /// In id, this message translates to:
  /// **'Anda bisa kembali ke percakapan ini sampai {time}.'**
  String guestSupportSessionSaved(String time);

  /// No description provided for @guestSupportSessionMemory.
  ///
  /// In id, this message translates to:
  /// **'Biarkan aplikasi tetap terbuka: percakapan ini hilang bila aplikasi ditutup. Sesi berlaku sampai {time}.'**
  String guestSupportSessionMemory(String time);

  /// No description provided for @guestSupportAttachment.
  ///
  /// In id, this message translates to:
  /// **'Lampiran bisa dibuka setelah Anda masuk ke aplikasi.'**
  String get guestSupportAttachment;

  /// No description provided for @guestSupportEndedResolved.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan #{number} sudah selesai. Bila masih perlu bantuan, buat pengaduan baru.'**
  String guestSupportEndedResolved(String number);

  /// No description provided for @guestSupportEndedClosed.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan #{number} sudah ditutup. Bila masih perlu bantuan, buat pengaduan baru.'**
  String guestSupportEndedClosed(String number);

  /// No description provided for @guestSupportEndedExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi pengaduan sudah berakhir. Silakan buat pengaduan baru.'**
  String get guestSupportEndedExpired;

  /// No description provided for @guestSupportEndedByYou.
  ///
  /// In id, this message translates to:
  /// **'Anda sudah mengakhiri pengaduan #{number}.'**
  String guestSupportEndedByYou(String number);

  /// No description provided for @guestSupportNew.
  ///
  /// In id, this message translates to:
  /// **'Buat pengaduan baru'**
  String get guestSupportNew;

  /// No description provided for @guestSupportDisabled.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan tanpa login sedang tidak tersedia. Silakan coba lagi nanti atau hubungi kantor cabang.'**
  String get guestSupportDisabled;

  /// No description provided for @guestErrorRateLimited.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak pengaduan dari perangkat ini. Coba lagi nanti.'**
  String get guestErrorRateLimited;

  /// No description provided for @guestErrorLoginLimit.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan untuk Login ID ini sudah banyak hari ini. Coba lagi besok atau hubungi kantor cabang.'**
  String get guestErrorLoginLimit;

  /// No description provided for @guestErrorMessageRate.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak pesan. Tunggu sebentar lalu kirim lagi.'**
  String get guestErrorMessageRate;

  /// No description provided for @guestErrorTicketNotActive.
  ///
  /// In id, this message translates to:
  /// **'Pengaduan ini sudah selesai. Buat pengaduan baru bila masih perlu bantuan.'**
  String get guestErrorTicketNotActive;

  /// No description provided for @guestErrorSessionExpired.
  ///
  /// In id, this message translates to:
  /// **'Sesi pengaduan sudah berakhir. Silakan buat pengaduan baru.'**
  String get guestErrorSessionExpired;

  /// No description provided for @guestErrorInvalidMessage.
  ///
  /// In id, this message translates to:
  /// **'Pesan 1–{max} karakter.'**
  String guestErrorInvalidMessage(int max);
}

class _CommunityLocalizationsDelegate extends LocalizationsDelegate<CommunityLocalizations> {
  const _CommunityLocalizationsDelegate();

  @override
  Future<CommunityLocalizations> load(Locale locale) {
    return SynchronousFuture<CommunityLocalizations>(lookupCommunityLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_CommunityLocalizationsDelegate old) => false;
}

CommunityLocalizations lookupCommunityLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CommunityLocalizationsEn();
    case 'id':
      return CommunityLocalizationsId();
  }

  throw FlutterError(
    'CommunityLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
