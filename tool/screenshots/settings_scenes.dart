import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/account/presentation/cubit/account_settings_cubit.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/delete_account_dialog.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/widgets/community_appeals.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';

import '../../test/support/fakes.dart';
import '../../test/support/feature_fakes.dart';
import '../../test/support/legal_fakes.dart';
import 'screenshot_harness.dart';

final _decided = DateTime.utc(2026, 11, 2, 4);

FakeFeatureDependencies _features() {
  final features = FakeFeatureDependencies(config: loadedConfig());
  features.appeals
    ..sanctions = [Sanction(id: 's-1', kind: 'mute', reason: 'Ajakan pump and dump', endsAt: DateTime.utc(2026, 11, 9))]
    ..moderated = [
      ModeratedContent(
        type: AppealTargetType.post,
        id: 'p-1',
        state: ModeratedState.hidden,
        excerpt: r'$GOTO pasti naik 30% besok, borong sekarang!',
        decidedAt: _decided,
      ),
      ModeratedContent(
        type: AppealTargetType.message,
        id: 'm-1',
        state: ModeratedState.removed,
        excerpt: 'Link grup sinyal berbayar',
        decidedAt: _decided,
        appeal: Appeal(
          id: 'a-2',
          targetType: AppealTargetType.message,
          targetId: 'm-1',
          reason: 'Itu tautan edukasi, bukan sinyal.',
          createdAt: _decided,
        ),
      ),
    ]
    ..appeals = [
      Appeal(
        id: 'a-1',
        targetType: AppealTargetType.comment,
        targetId: 'c-1',
        reason: 'Komentar saya hanya mengutip berita resmi emiten.',
        status: AppealStatus.accepted,
        decisionNote: 'Konten dipulihkan.',
        createdAt: DateTime.utc(2026, 10, 28),
      ),
    ];
  return features;
}

Widget _scoped(Widget child, {FakeAccount? account, CommunityFeatureDependencies? features}) {
  Widget body = child;
  if (features != null) body = CommunityFeatureScope(dependencies: features, child: body);
  if (account != null) body = CommunityAccountScope(dependencies: account, child: body);
  return CommunityScope(dependencies: FakeDependencies(), child: body);
}

Widget _label(BuildContext context, String text) => Padding(
  padding: EdgeInsets.only(top: CommunityStyle.of(context).spacing.lg, bottom: CommunityStyle.of(context).spacing.sm),
  child: Text(text, style: CommunityStyle.of(context).typography.label),
);

final _reportController = TextEditingController();
final _appealController = TextEditingController(text: 'Saya hanya membagikan ringkasan laporan keuangan resmi.');
final _deleteController = TextEditingController(text: 'HAP');

final settingsScenes = <ScreenshotScene>[
  ScreenshotScene('system_unavailable', padding: EdgeInsets.zero, (context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityUnavailableView(),
        CommunityDivider(),
        CommunityUnavailableView(reason: CommunityUnavailableReason.featureDisabled),
      ],
    );
  }),
  ScreenshotScene('system_banners', padding: EdgeInsets.zero, (context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityBannerCard(
          banner: const CommunityBanner(
            id: 'b-1',
            title: 'Fitur baru: kartu saham di chat',
            body: 'Bagikan kode saham langsung dari percakapan.',
          ),
          onOpen: () {},
          onDismiss: () {},
        ),
        CommunityBannerCard(
          banner: const CommunityBanner(
            id: 'b-2',
            title: 'Pemeliharaan terjadwal',
            body: 'Chat dibatasi Sabtu pukul 22.00–23.00 WIB.',
            level: CommunityBannerLevel.warning,
          ),
          onDismiss: () {},
        ),
        const CommunityBannerCard(
          banner: CommunityBanner(
            id: 'b-3',
            title: 'Gangguan pengiriman pesan',
            body: 'Tim kami sedang menangani. Pesan Anda tetap tersimpan.',
            level: CommunityBannerLevel.critical,
            dismissible: false,
          ),
        ),
        const CommunityOfflineNotice(message: 'Anda sedang offline. Menampilkan data tersimpan.'),
        _scoped(const CommunityConsentBanner(), account: FakeAccount(FakeLegalRepository([updatedTerms]))),
        const SizedBox(height: 16),
      ],
    );
  }),
  ScreenshotScene('settings_account', padding: EdgeInsets.zero, (context) {
    return SizedBox(
      height: 1720,
      child: _scoped(
        const CommunityAccountSettings(),
        account: FakeAccount(FakeLegalRepository([updatedTerms, updatedGuidelines, privacyPolicy])),
        features: _features(),
      ),
    );
  }),
  ScreenshotScene('settings_appeals', padding: EdgeInsets.zero, (context) {
    return SizedBox(height: 560, child: _scoped(const CommunityAppeals(), features: _features()));
  }),
  ScreenshotScene('settings_dialogs', (context) {
    final l10n = context.communityL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(context, 'Laporkan'),
        DefaultReportDialog(
          details: CommunityReportDetails(
            target: ReportTarget.post,
            targetId: 'p-1',
            title: l10n.reportTitle,
            options: [
              CommunitySettingsOption(value: ReportReason.spam, label: l10n.reasonSpam),
              CommunitySettingsOption(value: ReportReason.abuse, label: l10n.reasonAbuse),
              CommunitySettingsOption(value: ReportReason.scam, label: l10n.reasonScam),
              CommunitySettingsOption(value: ReportReason.pumpAndDump, label: l10n.reasonPumpAndDump),
              CommunitySettingsOption(value: ReportReason.misinformation, label: l10n.reasonMisinformation),
              CommunitySettingsOption(value: ReportReason.other, label: l10n.reasonOther),
            ],
            selected: ReportReason.pumpAndDump,
            controller: _reportController,
            hintText: l10n.reportDetailsHint,
            maxLength: 1000,
            submitting: false,
            submitLabel: l10n.report,
            cancelLabel: 'Batal',
            onSelect: (_) {},
            onSubmit: () {},
            onCancel: () {},
          ),
        ),
        _label(context, 'Banding'),
        DefaultAppealDialog(
          details: CommunityAppealDialogDetails(
            targetType: AppealTargetType.post,
            title: l10n.appealTitle,
            hint: l10n.appealHint,
            controller: _appealController,
            maxLength: 1000,
            canSubmit: true,
            submitting: false,
            submitLabel: l10n.appealSubmit,
            cancelLabel: 'Batal',
            onSubmit: () {},
            onCancel: () {},
          ),
        ),
        _label(context, 'Hapus akun'),
        BlocProvider(
          create: (_) => AccountSettingsCubit(FakeAccount(FakeLegalRepository(const []))),
          child: DefaultDeleteAccountDialog(
            details: CommunityDeleteAccountDetails(
              title: l10n.accountDeleteTitle,
              intro: l10n.accountDeleteIntro,
              consequences: const [
                CommunityDeleteConsequence(
                  icon: Icons.visibility_off_outlined,
                  text: 'Post dan komentar disembunyikan.',
                ),
                CommunityDeleteConsequence(
                  icon: Icons.account_balance_outlined,
                  text: 'Akun trading OLT Anda tidak terpengaruh.',
                ),
              ],
              controller: _deleteController,
              confirmWord: 'HAPUS',
              fieldLabel: l10n.accountDeleteTypeToConfirm(l10n.accountDeleteWord),
              confirmLabel: 'Hapus akun',
              cancelLabel: 'Batal',
              progressLabel: 'Menghapus akun komunitas…',
              canConfirm: false,
              deleting: false,
              onCancel: () {},
            ),
          ),
        ),
      ],
    );
  }),
];
