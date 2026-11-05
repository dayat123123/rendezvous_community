import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/message_requests/domain/entities/message_request.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class StockRoomBanner extends StatelessWidget {
  const StockRoomBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final stockRoom = context.select((ChatRoomCubit c) => c.state.stockRoom);
    if (stockRoom == null) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final slow = stockRoom.slowModeActive();
    final pinned = stockRoom.pinnedMessage;
    if (!slow && pinned == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pinned != null && !pinned.isDeleted)
          RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.pinned,
              icon: Icons.push_pin,
              title: [l10n.pinnedMessageLabel, if (pinned.sender != null) pinned.sender!.name].join(' · '),
              message: (pinned.body ?? '').isEmpty ? l10n.attachment : pinned.body!,
              pinned: pinned,
            ),
          ),
        if (slow)
          RoomNotice(
            details: CommunityRoomNoticeDetails(
              kind: CommunityRoomNoticeKind.slowMode,
              icon: Icons.timer_outlined,
              message: l10n.slowModeBanner(stockRoom.slowModeSeconds),
            ),
          ),
      ],
    );
  }
}

class DmRequestNotice extends StatelessWidget {
  const DmRequestNotice({super.key, this.maxMessages = defaultRequestMaxMessages});

  final int maxMessages;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ChatRoomCubit c) => c.state);
    final room = state.room;
    if (room == null || room.type != RoomType.direct) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final name = room.otherUser?.name ?? l10n.someone;
    final request = state.dmRequest;
    CommunityRoomNoticeDetails limit(int max) => CommunityRoomNoticeDetails(
      kind: CommunityRoomNoticeKind.dmRequestLimit,
      icon: Icons.mark_email_unread_outlined,
      message: l10n.dmRequestLimitNotice(name, max),
      strong: true,
    );
    final CommunityRoomNoticeDetails? details;
    if (request != null) {
      if (request.pendingAsRecipient) {
        details = CommunityRoomNoticeDetails(
          kind: CommunityRoomNoticeKind.dmRequestReceived,
          icon: Icons.mark_email_unread_outlined,
          message: l10n.dmRequestPendingRecipient(name),
          actionLabel: l10n.messageRequestAccept,
          onAction: () => context.read<ChatRoomCubit>().acceptDmRequest(),
        );
      } else if (request.limitReached || (request.pendingAsSender && state.dmRequestLimited)) {
        details = limit(request.maxMessages);
      } else if (request.pendingAsSender) {
        details = CommunityRoomNoticeDetails(
          kind: CommunityRoomNoticeKind.dmRequestSent,
          icon: Icons.outgoing_mail,
          message: l10n.dmRequestPendingSender(name, request.sent, request.maxMessages),
        );
      } else {
        details = null;
      }
    } else if (state.dmRequestLimited) {
      details = limit(maxMessages);
    } else if (state.awaitingReply) {
      details = CommunityRoomNoticeDetails(
        kind: CommunityRoomNoticeKind.dmRequestInfo,
        icon: Icons.info_outline,
        message: l10n.dmRequestSenderNotice(name, maxMessages),
      );
    } else {
      details = null;
    }
    if (details == null) return const SizedBox.shrink();
    return RoomNotice(details: details);
  }
}

class RoomNotice extends StatelessWidget {
  const RoomNotice({super.key, required this.details});

  final CommunityRoomNoticeDetails details;

  @override
  Widget build(BuildContext context) => buildChatPart(
    CommunityChatBuilders.of(context).roomNotice,
    context,
    details,
    _DefaultRoomNotice(details: details),
  );
}

class _DefaultRoomNotice extends StatelessWidget {
  const _DefaultRoomNotice({required this.details});

  final CommunityRoomNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = CommunityStyle.of(context);
    final tone = switch (details.kind) {
      CommunityRoomNoticeKind.pinned => style.accent,
      CommunityRoomNoticeKind.slowMode => scheme.tertiary,
      CommunityRoomNoticeKind.dmRequestReceived => style.accent,
      _ => details.strong ? scheme.error : null,
    };
    final onAction = details.onAction;
    final actionLabel = details.actionLabel;
    return ChatStrip(
      icon: details.icon,
      title: details.title,
      message: details.message,
      tone: tone,
      maxLines: details.kind == CommunityRoomNoticeKind.pinned ? 2 : null,
      action: onAction == null || actionLabel == null
          ? null
          : TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
              child: Text(actionLabel),
            ),
    );
  }
}
