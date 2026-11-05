import 'package:flutter/material.dart';
import 'package:rendezvous_community/rendezvous_community.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_official_badge.dart';

import 'screenshot_harness.dart';

const _rina = UserSummary(id: 'u-rina', username: 'rina.invest', displayName: 'Rina Wulandari', isVerified: true);
const _budi = UserSummary(id: 'u-budi', username: 'budi_s', displayName: 'Budi Santoso');
const _olt = UserSummary(id: 'u-olt', username: 'olt_resmi', displayName: 'OLT Resmi');

Widget _gap(BuildContext context, [double? size]) => SizedBox(height: size ?? CommunityStyle.of(context).spacing.lg);

class _PostSample extends StatelessWidget {
  const _PostSample();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return CommunityCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityAuthorRow(
            user: _rina,
            meta: 'Analis ritel · 2 jam',
            onOpenAuthor: () {},
            trailing: CommunityActionButton(icon: Icons.more_horiz, tooltip: 'Lainnya', onPressed: () {}),
          ),
          SizedBox(height: spacing.sm),
          Text('Apakah sektor perbankan masih menarik setelah rilis laporan Q3?', style: style.typography.title),
          SizedBox(height: spacing.sm),
          Text(
            'Laba bersih tumbuh dua digit dan rasio kredit macet turun. Namun valuasi sudah premium, '
            'jadi saya lebih memilih akumulasi bertahap sambil memantau arah suku bunga.',
            style: style.typography.body,
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              CommunityTag(label: r'$BBCA', onTap: () {}),
              CommunityTag(label: r'$BMRI', onTap: () {}),
              CommunityTag(label: '#perbankan', icon: Icons.tag, selected: true, onTap: () {}),
            ],
          ),
          SizedBox(height: spacing.sm),
          CommunityActionBar(
            leading: [
              CommunityActionPill(
                icon: Icons.favorite_border_rounded,
                label: 'Naik',
                count: 1240,
                active: true,
                onPressed: () {},
              ),
              CommunityActionPill(icon: Icons.arrow_downward_rounded, onPressed: () {}),
            ],
            trailing: [
              CommunityActionButton(
                icon: Icons.mode_comment_outlined,
                tooltip: 'Komentar',
                count: 38,
                onPressed: () {},
              ),
              CommunityActionButton(icon: Icons.share_outlined, tooltip: 'Bagikan', onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentSample extends StatelessWidget {
  const _CommentSample({required this.user, required this.body});

  final UserSummary user;
  final String body;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: style.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityAuthorRow(user: user, meta: '15 mnt', avatarSize: style.avatarSizes.small, onOpenAuthor: () {}),
          Padding(
            padding: EdgeInsetsDirectional.only(start: style.avatarSizes.small + style.spacing.sm + style.spacing.xxs),
            child: Text(body, style: style.typography.body.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

final sharedScenes = <ScreenshotScene>[
  ScreenshotScene(
    'components_post',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CommunitySectionHeader(
          title: 'Untuk Anda',
          subtitle: 'Diskusi pilihan hari ini',
          padding: EdgeInsets.zero,
        ),
        _gap(context, 12),
        const _PostSample(),
        _gap(context, 8),
        CommunityCard(
          child: Column(
            children: [
              const _CommentSample(
                user: _budi,
                body: 'Setuju, tapi perhatikan juga margin bunga bersih yang mulai menyempit.',
              ),
              const CommunityDivider(),
              const _CommentSample(user: _olt, body: 'Terima kasih atas diskusinya. Tetap bijak berinvestasi.'),
            ],
          ),
        ),
      ],
    ),
  ),
  ScreenshotScene('components_controls', (context) {
    final style = CommunityStyle.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommunitySectionHeader(title: 'Pil aksi', padding: EdgeInsets.zero),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CommunityActionPill(icon: Icons.favorite_border, label: 'Suka', count: 12, onPressed: () {}),
            CommunityActionPill(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: 'Suka',
              count: 13,
              active: true,
              onPressed: () {},
            ),
            const CommunityActionPill(icon: Icons.bookmark_border, label: 'Simpan'),
            CommunityActionButton(icon: Icons.share_outlined, tooltip: 'Bagikan', onPressed: () {}),
            CommunityActionButton(
              icon: Icons.bookmark_border,
              activeIcon: Icons.bookmark,
              tooltip: 'Simpan',
              active: true,
              onPressed: () {},
            ),
          ],
        ),
        _gap(context),
        const CommunitySectionHeader(title: 'Tag', padding: EdgeInsets.zero),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CommunityTag(label: r'$TLKM', onTap: () {}),
            CommunityTag(label: 'Terpilih', selected: true, onTap: () {}),
            const CommunityTag(label: 'Statis', icon: Icons.local_offer_outlined),
          ],
        ),
        _gap(context),
        const CommunitySectionHeader(title: 'Tombol', padding: EdgeInsets.zero),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(style: style.primaryButtonStyle(), onPressed: () {}, child: const Text('Ikuti')),
            OutlinedButton(style: style.secondaryButtonStyle(), onPressed: () {}, child: const Text('Pesan')),
          ],
        ),
        _gap(context),
        CommunitySectionHeader(title: 'Bagian dengan aksi', actionLabel: 'Lihat semua', onAction: () {}),
        const CommunityDivider(),
        _gap(context, 8),
        const CommunityDisclaimer(padding: EdgeInsets.zero),
      ],
    );
  }),
  ScreenshotScene(
    'shared_identity',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CommunityAvatar(user: _rina, radius: 14),
            SizedBox(width: 12),
            CommunityAvatar(user: _budi, radius: 18, online: true),
            SizedBox(width: 12),
            CommunityAvatar(user: _olt, radius: 32),
            SizedBox(width: 12),
            CommunityAvatar(user: null),
          ],
        ),
        _gap(context),
        const CommunityAuthorRow(user: _rina, meta: '@rina.invest · terverifikasi'),
        const CommunityAuthorRow(user: _olt, official: true, meta: 'Akun resmi'),
        const CommunityAuthorRow(user: _budi, online: true, showUsername: true, meta: 'Aktif sekarang'),
        _gap(context),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CommunityOfficialBadge(),
            CommunityBotBadge(),
            HeldAttachmentLabel(),
            CommunityCountBadge(count: 7),
            CommunityCountBadge(count: 120, muted: true),
          ],
        ),
        _gap(context),
        const ModerationNotice(status: ModerationStatus.held),
        ModerationNotice(status: ModerationStatus.hidden, onAppeal: () {}),
        _gap(context, 8),
        ModerationNotice(status: ModerationStatus.hidden, compact: true, onAppeal: () {}),
        _gap(context),
        CommunityComposerField(
          controller: TextEditingController(text: r'Pantau $BBCA minggu ini'),
          hintText: 'Tulis komentar',
          enableAutocomplete: false,
        ),
      ],
    ),
  ),
  ScreenshotScene(
    'shared_states',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommunityCard(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 270,
            child: CommunityEmptyView(
              message: 'Belum ada diskusi. Jadilah yang pertama menulis.',
              action: FilledButton(
                style: CommunityStyle.of(context).primaryButtonStyle(),
                onPressed: () {},
                child: const Text('Tulis post'),
              ),
            ),
          ),
        ),
        _gap(context, 8),
        CommunityCard(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 270,
            child: CommunityErrorView(error: Exception('offline'), onRetry: () {}),
          ),
        ),
        _gap(context, 8),
        const CommunityCard(
          padding: EdgeInsets.zero,
          child: SizedBox(height: 120, child: CommunityLoadingView(message: 'Memuat diskusi')),
        ),
        _gap(context, 8),
        const CommunityCard(
          padding: EdgeInsets.zero,
          child: SizedBox(height: 270, child: CommunitySkeleton(itemCount: 2)),
        ),
      ],
    ),
  ),
];
