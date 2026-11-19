import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/banner_link.dart';
import 'package:rendezvous_community/src/features/notices/domain/entities/community_notice.dart';
import 'package:rendezvous_community/src/features/notices/domain/repositories/notice_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

abstract interface class CommunityNoticeDependencies {
  NoticeRepository get notices;
}

NoticeRepository? communityNoticeRepository(BuildContext context) => switch (context.communityFeatures) {
  final CommunityNoticeDependencies features => features.notices,
  _ => null,
};

Future<void> openCommunityNotice(
  BuildContext context, {
  CommunityNotice? notice,
  String? noticeId,
  CommunityBannerLinkCallback? onBannerLink,
}) {
  final carry = carryCommunityBuilders(context);
  final dependencies = context.getInheritedWidgetOfExactType<CommunityScope>()?.dependencies;
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  final repository = communityNoticeRepository(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) {
        Widget page = CommunityNoticePage(
          notice: notice,
          noticeId: noticeId,
          repository: repository,
          onBannerLink: onBannerLink,
        );
        if (features != null) page = CommunityFeatureScope(dependencies: features, child: page);
        if (dependencies != null) page = CommunityScope(dependencies: dependencies, child: page);
        return carry(page);
      },
    ),
  );
}

class CommunityNoticePage extends StatefulWidget {
  const CommunityNoticePage({super.key, this.notice, this.noticeId, this.repository, this.onBannerLink})
    : assert(notice != null || noticeId != null, 'notice or noticeId is required');

  final CommunityNotice? notice;
  final String? noticeId;
  final NoticeRepository? repository;
  final CommunityBannerLinkCallback? onBannerLink;

  @override
  State<CommunityNoticePage> createState() => _CommunityNoticePageState();
}

class _CommunityNoticePageState extends State<CommunityNoticePage> {
  CommunityNotice? _notice;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _notice = widget.notice;
    if (_notice == null) unawaited(_load());
  }

  Future<void> _load() async {
    final id = widget.noticeId;
    final repository = widget.repository ?? communityNoticeRepository(context);
    if (id == null || repository == null) {
      setState(() => _failed = true);
      return;
    }
    setState(() => _failed = false);
    try {
      final notice = await repository.get(id);
      if (mounted) setState(() => _notice = notice);
    } catch (error) {
      mapError(error);
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final notice = _notice;
    final title = l10n.noticeTitle;
    final body = SafeArea(
      top: false,
      child: notice != null
          ? CommunityNoticeView(notice: notice, onBannerLink: widget.onBannerLink)
          : _failed
          ? _NoticeUnavailable(onRetry: widget.noticeId == null ? null : _load)
          : const Center(child: CircularProgressIndicator()),
    );
    final appBar = AppBar(title: Text(title));
    if (CommunitySystemBuilders.of(context).noticeHeader == null) return Scaffold(appBar: appBar, body: body);
    final navigator = Navigator.maybeOf(context);
    final details = CommunityNoticeHeaderDetails(
      title: title,
      onBack: navigator != null && navigator.canPop() ? () => unawaited(navigator.maybePop()) : null,
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSystemPart((b) => b.noticeHeader, context, details, appBar),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _NoticeUnavailable extends StatelessWidget {
  const _NoticeUnavailable({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(style.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.noticeUnavailable, textAlign: TextAlign.center, style: style.typography.body),
            if (onRetry != null) TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class CommunityNoticeView extends StatelessWidget {
  const CommunityNoticeView({super.key, required this.notice, this.onBannerLink});

  final CommunityNotice notice;
  final CommunityBannerLinkCallback? onBannerLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final sentAt = notice.sentAt;
    final details = CommunityNoticeDetails(
      notice: notice,
      icon: switch (notice.level) {
        CommunityBannerLevel.info => Icons.info_outline,
        CommunityBannerLevel.warning => Icons.warning_amber,
        CommunityBannerLevel.critical => Icons.error_outline,
      },
      levelLabel: switch (notice.level) {
        CommunityBannerLevel.info => l10n.noticeLevelInfo,
        CommunityBannerLevel.warning => l10n.noticeLevelWarning,
        CommunityBannerLevel.critical => l10n.noticeLevelCritical,
      },
      openLabel: notice.ctaLabel ?? l10n.bannerOpen,
      timeLabel: sentAt == null ? null : l10n.noticeSentAt(l10n.dayLabel(sentAt), l10n.clockTime(sentAt)),
      onOpen: notice.link == null
          ? null
          : () => unawaited(openCommunityBannerLink(context, notice.toBanner(), onBannerLink: onBannerLink)),
    );
    return buildSystemPart((b) => b.notice, context, details, _DefaultNoticeView(details: details));
  }
}

class _DefaultNoticeView extends StatelessWidget {
  const _DefaultNoticeView({required this.details});

  final CommunityNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final scheme = Theme.of(context).colorScheme;
    final d = details;
    final tone = switch (d.level) {
      CommunityBannerLevel.info => style.accent,
      CommunityBannerLevel.warning => scheme.tertiary,
      CommunityBannerLevel.critical => scheme.error,
    };
    final image = d.imageUrl;
    final onOpen = d.onOpen;
    final timeLabel = d.timeLabel;
    return ListView(
      padding: EdgeInsets.all(spacing.lg),
      children: [
        Row(
          children: [
            CommunityToneIcon(icon: d.icon, tone: tone, size: 32),
            SizedBox(width: spacing.sm),
            Text(d.levelLabel, style: style.typography.label.copyWith(color: tone)),
          ],
        ),
        SizedBox(height: spacing.md),
        Semantics(header: true, child: Text(d.title, style: style.typography.title)),
        if (timeLabel != null) ...[SizedBox(height: spacing.xxs), Text(timeLabel, style: style.typography.meta)],
        if (image != null) ...[
          SizedBox(height: spacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              semanticLabel: d.title,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
        if (d.body.isNotEmpty) ...[SizedBox(height: spacing.lg), SelectableText(d.body, style: style.typography.body)],
        if (onOpen != null) ...[
          SizedBox(height: spacing.xl),
          FilledButton(onPressed: onOpen, child: Text(d.openLabel)),
        ],
      ],
    );
  }
}
