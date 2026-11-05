import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_actions.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportSystemNotice extends StatelessWidget {
  const SupportSystemNotice({super.key, required this.message});

  final ChatMessage message;

  static IconData iconFor(String? code) => switch (code) {
    'ticket_opened' => Icons.confirmation_number_outlined,
    'ticket_claimed' || 'ticket_reopened_owner' => Icons.support_agent,
    'ticket_transferred' => Icons.swap_horiz,
    'ticket_released' || 'ticket_reopened' => Icons.replay,
    'agent_away' => Icons.schedule,
    'ticket_resolved' => Icons.task_alt,
    'ticket_closed' => Icons.lock_outline,
    'secured' => Icons.shield_outlined,
    _ => Icons.info_outline,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final actions = CommunitySupportMessageActions.maybeOf(context);
    final ticketId = message.ticketId;
    final onRate = actions?.onRate;
    final rateable =
        message.kind == MessageKind.csat &&
        ticketId != null &&
        onRate != null &&
        (actions?.canRate?.call(ticketId) ?? false);
    final details = CommunitySupportNoticeDetails(
      message: message,
      text: message.body ?? '',
      icon: iconFor(message.systemCode),
      timeLabel: l10n.clockTime(message.createdAt),
      rateLabel: rateable ? l10n.supportRatePrompt : null,
      onRate: rateable ? () => onRate(ticketId) : null,
    );
    return buildSupportPart((b) => b.systemNotice, context, details, _DefaultSystemNotice(details: details));
  }
}

class _DefaultSystemNotice extends StatelessWidget {
  const _DefaultSystemNotice({required this.details});

  final CommunitySupportNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onRate = d.onRate;
    final rateLabel = d.rateLabel;
    final meta = style.typography.meta.copyWith(fontSize: 12, height: 1.35);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
          decoration: BoxDecoration(color: style.chip, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(d.icon, size: 14, color: style.textSecondary),
                  SizedBox(width: spacing.xs + spacing.xxs),
                  Flexible(
                    child: Text(d.text, textAlign: TextAlign.center, style: meta),
                  ),
                ],
              ),
              SizedBox(height: spacing.xxs),
              Text(d.timeLabel, style: meta.copyWith(fontSize: 11)),
              if (onRate != null && rateLabel != null)
                Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: FilledButton.icon(
                    style: style.primaryButtonStyle(),
                    onPressed: onRate,
                    icon: const Icon(Icons.star_rounded, size: 18),
                    label: Text(rateLabel),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OfficialSenderLabel extends StatelessWidget {
  const OfficialSenderLabel({super.key, required this.sender, required this.color});

  final UserSummary sender;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final details = CommunityOfficialSenderDetails(sender: sender, color: color);
    return buildSupportPart((b) => b.officialSender, context, details, _DefaultOfficialSender(details: details));
  }
}

class _DefaultOfficialSender extends StatelessWidget {
  const _DefaultOfficialSender({required this.details});

  final CommunityOfficialSenderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            details.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.typography.author.copyWith(color: details.color, fontSize: 13),
          ),
        ),
        SizedBox(width: style.spacing.xs + style.spacing.xxs),
        OfficialBadge(color: details.color),
      ],
    );
  }
}

class OfficialBadge extends StatelessWidget {
  const OfficialBadge({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final details = CommunityLabelBadgeDetails(
      kind: CommunityBadgeKind.supportOfficial,
      label: context.communityL10n.supportOfficialBadge,
      icon: Icons.verified,
      foreground: color,
      border: color.withValues(alpha: 0.6),
    );
    return buildLabelBadge(context, details, _DefaultSupportOfficialBadge(details: details));
  }
}

class _DefaultSupportOfficialBadge extends StatelessWidget {
  const _DefaultSupportOfficialBadge({required this.details});

  final CommunityLabelBadgeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final foreground = details.foreground;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: style.spacing.xs + style.spacing.xxs, vertical: 1),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.08),
        border: Border.all(color: details.border ?? foreground, width: style.borderWidth),
        borderRadius: style.radii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(details.icon, size: 12, color: foreground),
          SizedBox(width: style.spacing.xxs + 1),
          Text(details.label, style: style.typography.badge.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

class SupportMessageExtras extends StatelessWidget {
  const SupportMessageExtras({super.key, required this.message, required this.color, required this.mine});

  final ChatMessage message;
  final Color color;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final actions = CommunitySupportMessageActions.maybeOf(context);
    switch (message.kind) {
      case MessageKind.quickReply:
        final onQuickReply = actions?.onQuickReply;
        final details = CommunityQuickRepliesDetails(
          message: message,
          options: [for (final o in (message.payload['options'] as List<Object?>? ?? const [])) '$o'],
          mine: mine,
          onSelect: mine || onQuickReply == null ? null : (option) => onQuickReply(option),
        );
        return buildSupportPart((b) => b.quickReplies, context, details, _QuickReplies(details: details));
      case MessageKind.helpLink:
        final url = message.payload['url'] as String?;
        final uri = url == null ? null : Uri.tryParse(url);
        if (uri == null || uri.scheme != 'https') return const SizedBox.shrink();
        final onOpenLink = actions?.onOpenLink;
        final details = CommunityHelpLinkDetails(
          uri: uri,
          label: context.communityL10n.supportOpenLink,
          onOpen: () => onOpenLink == null ? launchUrl(uri, mode: LaunchMode.externalApplication) : onOpenLink(uri),
        );
        return buildSupportPart((b) => b.helpLink, context, details, _HelpLink(details: details, color: color));
      default:
        return const SizedBox.shrink();
    }
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.details});

  final CommunityQuickRepliesDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final select = details.onSelect;
    final button = OutlinedButton.styleFrom(
      foregroundColor: style.accent,
      disabledForegroundColor: style.textSecondary,
      backgroundColor: style.surface,
      textStyle: style.typography.label.copyWith(fontSize: 14),
      side: BorderSide(color: select == null ? style.border : style.accent, width: style.borderWidth),
      shape: const StadiumBorder(),
      minimumSize: const Size(48, 36),
      padding: EdgeInsets.symmetric(horizontal: style.spacing.md),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    return Padding(
      padding: EdgeInsets.only(top: style.spacing.xs),
      child: Wrap(
        spacing: style.spacing.sm,
        children: [
          for (final option in details.options)
            OutlinedButton(style: button, onPressed: select == null ? null : () => select(option), child: Text(option)),
        ],
      ),
    );
  }
}

class _HelpLink extends StatelessWidget {
  const _HelpLink({required this.details, required this.color});

  final CommunityHelpLinkDetails details;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: color,
          textStyle: style.typography.label,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
        onPressed: details.onOpen,
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(details.label, style: const TextStyle(decoration: TextDecoration.underline)),
      ),
    );
  }
}
