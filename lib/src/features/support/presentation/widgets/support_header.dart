import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_help_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_support_scope.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/community_help_article.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/community_support_tickets.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_incidents.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_subpage.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';

String supportStatusText(CommunityLocalizations l10n, SupportTicket ticket) => switch (ticket.status) {
  SupportStatus.open => [
    l10n.supportStatusWaiting,
    if ((ticket.queueAhead ?? 0) > 0) l10n.supportQueueAhead(ticket.queueAhead!),
    if ((ticket.etaMinutes ?? 0) > 0) l10n.supportQueueEta(ticket.etaMinutes!),
  ].join(' · '),
  SupportStatus.claimed => l10n.supportStatusHandled(ticket.agent?.displayName ?? ''),
  SupportStatus.waitingCustomer => l10n.supportStatusWaitingYou,
  SupportStatus.resolved => l10n.supportStatusResolved,
  SupportStatus.closed => l10n.supportStatusClosed,
};

enum _MenuAction { complaint, reportFake, endChat, myTickets, newTicket }

class SupportHeader extends StatelessWidget {
  const SupportHeader({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final state = context.watch<SupportCubit>().state;
    final home = state.home;
    final ticket = state.ticket;
    final active = ticket?.isActive ?? false;
    VoidCallback run(_MenuAction action) =>
        () => _onAction(context, action);
    final details = CommunitySupportHeaderDetails(
      title: home?.supportName ?? '',
      subtitle: ticket == null
          ? l10n.supportOfficialChannel
          : '#${ticket.ticketNumber} · ${ticket.topicName ?? ticket.topic}',
      menuTooltip: l10n.supportMenu,
      ticket: ticket,
      statusLabel: ticket == null ? null : supportStatusText(l10n, ticket),
      busy: state.busy,
      onComplaint: active && ticket?.complaintReceivedAt == null ? run(_MenuAction.complaint) : null,
      onReportFake: run(_MenuAction.reportFake),
      onEndChat: active ? run(_MenuAction.endChat) : null,
      onNewTicket: active ? null : run(_MenuAction.newTicket),
      onShowTickets: run(_MenuAction.myTickets),
      onClose: onClose,
    );
    final nextOpenAt = home?.nextOpenAt;
    final banner = home != null && !home.serviceOpen && nextOpenAt != null
        ? CommunitySupportBannerDetails(
            message: l10n.supportOutOfHours('${l10n.dayLabel(nextOpenAt)} ${l10n.clockTime(nextOpenAt)}'),
            tone: CommunitySupportTone.warning,
            icon: Icons.schedule,
          )
        : null;
    return Material(
      color: style.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSupportPart((b) => b.header, context, details, _DefaultSupportHeader(details: details)),
          if (state.busy) const LinearProgressIndicator(minHeight: 2) else const CommunityDivider(),
          if (banner != null) buildSupportPart((b) => b.banner, context, banner, SupportBanner(details: banner)),
          if (home != null && home.incidents.isNotEmpty)
            SupportIncidentBanners(
              incidents: home.incidents,
              onOpenArticle: CommunityHelpScope.maybeOf(context) == null ? null : openSupportIncidentArticle,
            ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext context, _MenuAction action) async {
    final l10n = context.communityL10n;
    final cubit = context.read<SupportCubit>();
    switch (action) {
      case _MenuAction.complaint:
        if (await confirmSupport(context, message: l10n.supportComplaintConfirm, confirm: l10n.supportComplaint)) {
          await cubit.fileComplaint();
        }
      case _MenuAction.reportFake:
        final description = await askFakeCsReport(context);
        if (description != null) await cubit.reportFakeCs(description);
      case _MenuAction.endChat:
        if (await confirmSupport(context, message: l10n.supportEndConfirm, confirm: l10n.supportEndChat)) {
          await cubit.closeTicket();
        }
      case _MenuAction.newTicket:
        cubit.pickTopic();
      case _MenuAction.myTickets:
        if (!context.mounted) return;
        final deps = CommunityScope.of(context);
        final support = CommunitySupportScope.of(context);
        final carry = carryCommunityBuilders(context);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => carry(
              CommunityScope(
                dependencies: deps,
                child: CommunitySupportScope(
                  dependencies: support,
                  child: SupportPanelScope(
                    onClose: onClose,
                    child: SupportSubpage(title: l10n.supportMyTickets, body: const CommunitySupportTickets()),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

void openSupportIncidentArticle(BuildContext context, SupportIncident incident) {
  final id = incident.faqArticleId;
  if (id == null) return;
  openCommunityHelpArticleById(
    context,
    id,
    title: incident.title,
    onContactSupport: (articleContext, _) => Navigator.of(articleContext).pop(),
  );
}

class _DefaultSupportHeader extends StatelessWidget {
  const _DefaultSupportHeader({required this.details});

  final CommunitySupportHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final status = d.status;
    final statusLabel = d.statusLabel;
    final onClose = d.onClose;
    final menu = <(VoidCallback?, String)>[
      (d.onComplaint, l10n.supportComplaint),
      (d.onReportFake, l10n.supportReportFake),
      (d.onNewTicket, l10n.supportNewTicket),
      (d.onShowTickets, l10n.supportMyTickets),
      (d.onEndChat, l10n.supportEndChat),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.xs, spacing.md),
      child: Row(
        children: [
          SupportIconCircle(icon: Icons.support_agent, color: style.accent, filled: true),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        d.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.typography.author,
                      ),
                    ),
                    SizedBox(width: spacing.xs + spacing.xxs),
                    OfficialBadge(color: style.accent),
                  ],
                ),
                SizedBox(height: spacing.xxs),
                Text(d.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                if (status != null && statusLabel != null) ...[
                  SizedBox(height: spacing.xs + spacing.xxs),
                  SupportSoftPill(label: statusLabel, color: supportStatusColor(context, status), maxLines: 2),
                ],
              ],
            ),
          ),
          PopupMenuButton<VoidCallback>(
            tooltip: d.menuTooltip,
            icon: Icon(Icons.more_horiz, color: style.textSecondary),
            onSelected: (action) => action(),
            itemBuilder: (context) => [
              for (final (handler, label) in menu)
                if (handler != null) PopupMenuItem(value: handler, child: Text(label)),
            ],
          ),
          if (onClose != null)
            IconButton(
              tooltip: l10n.close,
              onPressed: onClose,
              icon: Icon(Icons.close, color: style.textSecondary),
            ),
        ],
      ),
    );
  }
}

class SupportBanner extends StatelessWidget {
  const SupportBanner({super.key, required this.details});

  final CommunitySupportBannerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final color = supportToneColor(context, details.tone);
    return Container(
      width: double.infinity,
      color: supportSoftBackground(style, color),
      padding: EdgeInsets.symmetric(horizontal: style.spacing.lg, vertical: style.spacing.sm),
      child: Row(
        children: [
          Icon(details.icon ?? Icons.info_outline, size: 16, color: color),
          SizedBox(width: style.spacing.sm),
          Expanded(
            child: Text(details.message, style: style.typography.meta.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
