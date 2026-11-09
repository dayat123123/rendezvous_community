import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class SupportComposer extends StatelessWidget {
  const SupportComposer({super.key});

  String _kinds(CommunityLocalizations l10n, List<String> kinds) => <String>{
    for (final kind in kinds)
      switch (kind) {
        'otp' => l10n.supportKindOtp,
        'password' => l10n.supportKindPassword,
        'card' => l10n.supportKindCard,
        'nik' => l10n.supportKindNik,
        'account' => l10n.supportKindAccount,
        _ => kind,
      },
  }.join(', ');

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<SupportCubit>();
    final sensitive = context.select((SupportCubit c) => c.state.sensitive);
    final policy = context.select((SupportCubit c) => c.state.attachmentPolicy);
    final ticket = context.select((SupportCubit c) => c.state.ticket);
    final replies = ticket != null && ticket.isActive ? ticket.quickReplies : const <String>[];
    final kinds = sensitive.kinds.isEmpty ? const ['otp'] : sensitive.kinds;
    final warning = sensitive.masked
        ? CommunitySensitiveWarningDetails(kinds: kinds, message: l10n.supportSensitiveWarning(_kinds(l10n, kinds)))
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replies.isNotEmpty) SupportReplySuggestions(replies: replies),
        if (warning != null)
          buildSupportPart((b) => b.sensitiveWarning, context, warning, _DefaultSensitiveWarning(details: warning)),
        MessageComposer(onChanged: cubit.checkText, allowDocuments: true, attachmentPolicy: policy),
      ],
    );
  }
}

class SupportReplySuggestions extends StatelessWidget {
  const SupportReplySuggestions({super.key, required this.replies});

  final List<String> replies;

  @override
  Widget build(BuildContext context) {
    final chat = context.read<ChatRoomCubit>();
    final uploading = context.select((ChatRoomCubit c) => c.state.uploading);
    final details = CommunitySupportReplySuggestionsDetails(
      replies: replies,
      label: context.communityL10n.supportReplySuggestions,
      onSelect: uploading
          ? null
          : (text) {
              if (chat.state.cooldownLeft() > Duration.zero || chat.state.uploading) return;
              chat.send(text);
            },
    );
    return buildSupportPart((b) => b.replySuggestions, context, details, _DefaultReplySuggestions(details: details));
  }
}

class _DefaultReplySuggestions extends StatelessWidget {
  const _DefaultReplySuggestions({required this.details});

  final CommunitySupportReplySuggestionsDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onSelect = d.onSelect;
    return Semantics(
      container: true,
      label: d.label,
      child: SizedBox(
        height: style.minTouchTarget + spacing.sm,
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(spacing.sm, spacing.xs, spacing.sm, 0),
          itemCount: d.replies.length,
          separatorBuilder: (_, _) => SizedBox(width: spacing.xs),
          itemBuilder: (context, i) {
            final reply = d.replies[i];
            return Center(
              child: ActionChip(
                label: Text(reply),
                onPressed: onSelect == null ? null : () => onSelect(reply),
                backgroundColor: style.surface,
                side: BorderSide(color: style.accent.withValues(alpha: 0.5), width: style.borderWidth),
                labelStyle: style.typography.label.copyWith(color: style.accent),
                shape: RoundedRectangleBorder(borderRadius: style.radii.pillRadius),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DefaultSensitiveWarning extends StatelessWidget {
  const _DefaultSensitiveWarning({required this.details});

  final CommunitySensitiveWarningDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final color = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.sm, 0),
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm + spacing.xxs),
      decoration: BoxDecoration(
        color: supportSoftBackground(style, color),
        borderRadius: style.radii.controlRadius,
        border: Border.all(color: color.withValues(alpha: 0.3), width: style.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: color),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(details.message, style: style.typography.meta.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class SupportClosedBar extends StatelessWidget {
  const SupportClosedBar({super.key, required this.ticketNumber});

  final String ticketNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunitySupportClosedDetails(
      ticketNumber: ticketNumber,
      message: l10n.supportTicketClosedNotice(ticketNumber),
      newTicketLabel: l10n.supportNewTicket,
      onNewTicket: context.read<SupportCubit>().pickTopic,
    );
    return buildSupportPart((b) => b.closedBar, context, details, _DefaultClosedBar(details: details));
  }
}

class _DefaultClosedBar extends StatelessWidget {
  const _DefaultClosedBar({required this.details});

  final CommunitySupportClosedDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: style.surface,
          border: Border(
            top: BorderSide(color: style.divider, width: style.borderWidth),
          ),
        ),
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.md, spacing.sm),
        child: Row(
          children: [
            SupportIconCircle(icon: Icons.lock_outline, color: style.textSecondary, size: 32),
            SizedBox(width: spacing.md),
            Expanded(child: Text(details.message, style: style.typography.meta)),
            SizedBox(width: spacing.md),
            FilledButton(
              style: style.primaryButtonStyle(),
              onPressed: details.onNewTicket,
              child: Text(details.newTicketLabel),
            ),
          ],
        ),
      ),
    );
  }
}
