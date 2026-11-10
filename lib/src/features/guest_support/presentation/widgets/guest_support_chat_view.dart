import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/guest_support/domain/services/guest_support_form.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/builders/community_guest_support_details.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/cubit/guest_support_cubit.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/guest_support_texts.dart';
import 'package:rendezvous_community/src/features/guest_support/presentation/widgets/guest_support_form_view.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_dialogs.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_header.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_actions.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';

class GuestSupportChatView extends StatelessWidget {
  const GuestSupportChatView({super.key, this.persistent = false});

  final bool persistent;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GuestSupportCubit>();
    final state = context.watch<GuestSupportCubit>().state;
    final ended = state.phase == GuestSupportPhase.ended;
    return ColoredBox(
      color: CommunityStyle.of(context).background,
      child: Column(
        children: [
          GuestSupportHeader(persistent: persistent),
          Expanded(
            child: CommunitySupportMessageActions(
              onQuickReply: state.canSend ? (option) => cubit.send(option) : null,
              child: _GuestMessageList(messages: state.messages),
            ),
          ),
          if (ended) const _GuestEndedBar() else const _GuestComposer(),
        ],
      ),
    );
  }
}

class GuestSupportHeader extends StatelessWidget {
  const GuestSupportHeader({super.key, this.persistent = false});

  final bool persistent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<GuestSupportCubit>();
    final state = context.watch<GuestSupportCubit>().state;
    final ticket = state.ticket;
    final token = state.token;
    final active = state.phase == GuestSupportPhase.chat && token != null;
    final until = token == null ? null : '${l10n.dayLabel(token.expiresAt)} ${l10n.clockTime(token.expiresAt)}';
    final details = CommunityGuestHeaderDetails(
      title: ticket == null ? l10n.guestSupportTitle : l10n.guestSupportTicket(ticket.ticketNumber),
      subtitle: ticket?.topicName ?? l10n.guestSupportTitle,
      endLabel: l10n.guestSupportEnd,
      ticket: ticket,
      statusLabel: ticket == null ? null : supportStatusText(l10n, ticket),
      sessionNote: until == null || !active
          ? null
          : (persistent ? l10n.guestSupportSessionSaved(until) : l10n.guestSupportSessionMemory(until)),
      onEnd: active && !state.ending ? () => _end(context, cubit) : null,
      busy: state.busy,
      reconnectingLabel: state.reconnecting && active ? l10n.guestSupportReconnecting : null,
    );
    return Material(
      color: style.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildSupportPart((b) => b.guestHeader, context, details, _DefaultGuestHeader(details: details)),
          if (state.ending) const LinearProgressIndicator(minHeight: 2) else const CommunityDivider(),
          if (details.reconnectingLabel case final label?)
            buildSupportPart(
              (b) => b.banner,
              context,
              CommunitySupportBannerDetails(message: label, tone: CommunitySupportTone.warning, icon: Icons.wifi_off),
              SupportBanner(
                details: CommunitySupportBannerDetails(
                  message: label,
                  tone: CommunitySupportTone.warning,
                  icon: Icons.wifi_off,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _end(BuildContext context, GuestSupportCubit cubit) async {
    final l10n = context.communityL10n;
    if (await confirmSupport(context, message: l10n.guestSupportEndConfirm, confirm: l10n.guestSupportEnd)) {
      await cubit.end();
    }
  }
}

class _DefaultGuestHeader extends StatelessWidget {
  const _DefaultGuestHeader({required this.details});

  final CommunityGuestHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final status = d.status;
    final statusLabel = d.statusLabel;
    final note = d.sessionNote;
    final onEnd = d.onEnd;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.sm, spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SupportIconCircle(icon: Icons.support_agent, color: style.accent, filled: true),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.author),
                SizedBox(height: spacing.xxs),
                Text(d.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                if (status != null && statusLabel != null) ...[
                  SizedBox(height: spacing.xs + spacing.xxs),
                  SupportSoftPill(label: statusLabel, color: supportStatusColor(context, status), maxLines: 2),
                ],
                if (note != null) ...[
                  SizedBox(height: spacing.xs),
                  Text(note, style: style.typography.meta.copyWith(fontSize: 12)),
                ],
              ],
            ),
          ),
          if (onEnd != null)
            TextButton(
              key: const ValueKey('guest-end'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                textStyle: style.typography.label,
              ),
              onPressed: onEnd,
              child: Text(d.endLabel),
            ),
        ],
      ),
    );
  }
}

class _GuestMessageList extends StatelessWidget {
  const _GuestMessageList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    final items = messages.reversed.toList();
    return CommunityScrollArea(
      child: ListView.builder(
        reverse: true,
        addAutomaticKeepAlives: false,
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.md),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: spacing.md),
              child: const GuestSecurityNote(compact: true),
            );
          }
          final message = items[index];
          return KeyedSubtree(
            key: ValueKey(message.clientId ?? message.id),
            child: _GuestMessage(message: message),
          );
        },
      ),
    );
  }
}

class _GuestMessage extends StatelessWidget {
  const _GuestMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final m = message;
    if (m.isSystem || m.kind == MessageKind.system || m.kind == MessageKind.csat) {
      return SupportSystemNotice(message: m);
    }
    return _GuestBubble(message: m, mine: m.senderRole == SenderRole.customer);
  }
}

class _GuestBubble extends StatelessWidget {
  const _GuestBubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final theme = CommunityTheme.of(context);
    final spacing = style.spacing;
    final bg = mine ? theme.myBubble : theme.otherBubble;
    final fg = mine ? theme.onMyBubble : theme.onOtherBubble;
    final meta = style.typography.meta.copyWith(fontSize: 11, color: fg.withValues(alpha: 0.82));
    final sender = m.sender;
    final failed = m.status == MessageStatus.failed;
    final width = MediaQuery.sizeOf(context).width * 0.78;
    final clientId = m.clientId;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: width > 520 ? 520 : width),
      padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.xs + spacing.xxs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!mine && m.isOfficial && sender != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xxs),
              child: OfficialSenderLabel(sender: sender, color: style.accent),
            ),
          if (m.isDeleted)
            Text(
              l10n.messageDeleted,
              style: style.typography.body.copyWith(color: fg.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
            )
          else if ((m.body ?? '').isNotEmpty)
            SelectableText(m.body!, style: style.typography.body.copyWith(color: fg, height: 1.4)),
          if (m.attachments.isNotEmpty && !m.isDeleted)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_file, size: 14, color: fg),
                  SizedBox(width: spacing.xxs),
                  Flexible(
                    child: Text(l10n.guestSupportAttachment, style: meta.copyWith(color: fg)),
                  ),
                ],
              ),
            ),
          if (!m.isDeleted) SupportMessageExtras(message: m, color: style.accent, mine: mine),
          SizedBox(height: spacing.xxs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.clockTime(m.createdAt), style: meta),
              if (mine && m.status == MessageStatus.sending) ...[
                SizedBox(width: spacing.xxs),
                Icon(Icons.schedule, size: 12, color: meta.color),
              ],
            ],
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xxs + 1),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          bubble,
          if (failed && clientId != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                visualDensity: VisualDensity.compact,
                textStyle: style.typography.meta,
              ),
              onPressed: () => context.read<GuestSupportCubit>().retry(clientId),
              icon: const Icon(Icons.error_outline, size: 14),
              label: Text(l10n.messageFailed),
            ),
        ],
      ),
    );
  }
}

class _GuestComposer extends StatefulWidget {
  const _GuestComposer();

  @override
  State<_GuestComposer> createState() => _GuestComposerState();
}

class _GuestComposerState extends State<_GuestComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final cubit = context.read<GuestSupportCubit>();
    final text = _controller.text;
    if (!cubit.state.canSend || cubit.state.sending || !isGuestMessageValid(text)) return;
    _focus.requestFocus();
    _controller.clear();
    await cubit.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final state = context.watch<GuestSupportCubit>().state;
    final details = CommunityComposerDetails(
      controller: _controller,
      focusNode: _focus,
      hintText: l10n.messageHint,
      maxLength: guestMessageMaxLength,
      uploading: state.sending,
      onSend: _send,
      enabled: state.canSend,
      enableAutocomplete: false,
      fieldKey: const ValueKey('guest-composer'),
      sendKey: const ValueKey('guest-send'),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).composer,
      context,
      details,
      DefaultMessageComposer(details: details),
    );
  }
}

class _GuestEndedBar extends StatelessWidget {
  const _GuestEndedBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<GuestSupportCubit>();
    final state = context.watch<GuestSupportCubit>().state;
    final number = state.ticket?.ticketNumber;
    final details = CommunitySupportClosedDetails(
      ticketNumber: number ?? '',
      message: guestEndedText(l10n, state.endReason ?? GuestSupportEndReason.closed, number),
      newTicketLabel: l10n.guestSupportNew,
      onNewTicket: cubit.restart,
    );
    return buildSupportPart((b) => b.closedBar, context, details, _DefaultEndedBar(details: details));
  }
}

class _DefaultEndedBar extends StatelessWidget {
  const _DefaultEndedBar({required this.details});

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
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SupportIconCircle(icon: Icons.lock_outline, color: style.textSecondary, size: 32),
                SizedBox(width: spacing.md),
                Expanded(child: Text(details.message, style: style.typography.body)),
              ],
            ),
            SizedBox(height: spacing.md),
            FilledButton.icon(
              key: const ValueKey('guest-new'),
              style: style.primaryButtonStyle(),
              onPressed: details.onNewTicket,
              icon: const Icon(Icons.add_comment_outlined, size: 18),
              label: Text(details.newTicketLabel),
            ),
          ],
        ),
      ),
    );
  }
}
