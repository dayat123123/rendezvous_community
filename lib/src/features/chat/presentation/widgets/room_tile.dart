import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/receipt_icon.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_text.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_count_badge.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.room,
    required this.me,
    required this.online,
    required this.typing,
    required this.selected,
    required this.onTap,
    this.onHide,
    this.onLeave,
    this.onDeleteGroup,
  });

  final ChatRoom room;
  final UserSummary? me;
  final bool online;
  final List<UserSummary> typing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onHide;
  final VoidCallback? onLeave;
  final VoidCallback? onDeleteGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final preview = room.lastMessagePreview;
    final fromMe = room.lastMessageSenderId != null && room.lastMessageSenderId == me?.id;
    final hide = room.canHide ? onHide : null;
    final leave = room.canLeave ? onLeave : null;
    final deleteGroup = room.canDeleteGroup ? onDeleteGroup : null;
    final actionable = hide != null || leave != null || deleteGroup != null;
    late final CommunityRoomTileDetails details;
    details = CommunityRoomTileDetails(
      room: room,
      title: roomTitle(room),
      timeLabel: l10n.relativeTime(room.sortTime),
      online: online,
      selected: selected,
      typing: typing,
      onTap: onTap,
      preview: preview == null || !fromMe || room.type == RoomType.direct ? preview : '${l10n.you}: $preview',
      typingText: typing.isEmpty ? null : typingText(l10n, typing, direct: room.type == RoomType.direct),
      lastMessageReceipt: fromMe ? room.lastMessageStatus : null,
      onHide: hide,
      onLeave: leave,
      onDeleteGroup: deleteGroup,
      onShowActions: actionable ? () => showRoomActions(context, details) : null,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).roomTile,
      context,
      details,
      _DefaultRoomTile(details: details),
    );
  }
}

Future<void> showRoomActions(BuildContext context, CommunityRoomTileDetails room) async {
  final l10n = context.communityL10n;
  final carry = carryCommunityBuilders(context);
  final action = await showModalBottomSheet<VoidCallback>(
    context: context,
    builder: (sheetContext) {
      CommunityRoomAction entry(
        CommunityRoomActionKind kind,
        VoidCallback handler,
        IconData icon,
        String label, {
        bool destructive = false,
      }) => CommunityRoomAction(
        kind: kind,
        icon: icon,
        label: label,
        destructive: destructive,
        onSelected: () => Navigator.pop(sheetContext, handler),
      );
      final hide = room.onHide;
      final leave = room.onLeave;
      final deleteGroup = room.onDeleteGroup;
      final details = CommunityRoomActionsDetails(
        room: room,
        actions: [
          if (hide != null) entry(CommunityRoomActionKind.hide, hide, Icons.delete_outlined, l10n.hideChat),
          if (leave != null) entry(CommunityRoomActionKind.leave, leave, Icons.logout, l10n.leaveRoom),
          if (deleteGroup != null)
            entry(
              CommunityRoomActionKind.deleteGroup,
              deleteGroup,
              Icons.delete_forever_outlined,
              l10n.deleteGroup,
              destructive: true,
            ),
        ],
        onDismiss: () => Navigator.pop(sheetContext),
      );
      return carry(
        Builder(
          builder: (context) => buildChatPart(
            CommunityChatBuilders.of(context).roomActions,
            context,
            details,
            _DefaultRoomActions(details: details),
          ),
        ),
      );
    },
  );
  if (context.mounted) action?.call();
}

class _DefaultRoomActions extends StatelessWidget {
  const _DefaultRoomActions({required this.details});

  final CommunityRoomActionsDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final danger = Theme.of(context).colorScheme.error;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              details.room.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.typography.author,
            ),
          ),
          for (final action in details.actions)
            ListTile(
              leading: Icon(action.icon, color: action.destructive ? danger : style.textSecondary),
              title: Text(
                action.label,
                style: style.typography.body.copyWith(color: action.destructive ? danger : null),
              ),
              onTap: action.onSelected,
            ),
        ],
      ),
    );
  }
}

class _DefaultRoomTile extends StatelessWidget {
  const _DefaultRoomTile({required this.details});

  final CommunityRoomTileDetails details;

  static const _avatarSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final room = d.room;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final unread = room.unreadCount > 0;
    final support = room.type == RoomType.support;
    final title = Text(
      d.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style.typography.author.copyWith(fontSize: 15, fontWeight: unread ? FontWeight.w700 : FontWeight.w500),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: d.selected ? style.accentMuted : style.surface,
          child: InkWell(
            onTap: d.onTap,
            onLongPress: d.onShowActions,
            onSecondaryTap: d.onShowActions,
            child: Semantics(
              selected: d.selected,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm + spacing.xxs),
                child: Row(
                  children: [
                    roomAvatar(context, room, online: d.online, radius: _avatarSize / 2),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(child: title),
                              if (support) ...[
                                SizedBox(width: spacing.xs + spacing.xxs),
                                OfficialBadge(color: t.link),
                                SizedBox(width: spacing.xs),
                                Icon(Icons.push_pin, size: 14, color: style.textTertiary),
                              ],
                              if (room.muted) ...[
                                SizedBox(width: spacing.xs),
                                Icon(Icons.notifications_off_outlined, size: 14, color: style.textTertiary),
                              ],
                            ],
                          ),
                          SizedBox(height: spacing.xxs),
                          _subtitle(context, style, unread: unread),
                        ],
                      ),
                    ),
                    if (unread) ...[
                      SizedBox(width: spacing.md),
                      CommunityCountBadge(count: room.unreadCount, muted: room.muted),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        CommunityDivider(indent: spacing.lg + _avatarSize + spacing.md),
      ],
    );
  }

  Widget _subtitle(BuildContext context, CommunityStyle style, {required bool unread}) {
    final d = details;
    final meta = style.typography.meta;
    final emphasis = unread ? meta.copyWith(color: style.textPrimary, fontWeight: FontWeight.w600) : meta;
    final typing = d.typingText;
    if (typing != null) {
      return Text(
        typing,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: meta.copyWith(color: CommunityTheme.of(context).onlineIndicator, fontWeight: FontWeight.w600),
      );
    }
    final preview = d.preview;
    final receipt = d.lastMessageReceipt;
    return Row(
      children: [
        if (receipt != null && preview != null) ...[
          ReceiptIcon(receipt: receipt, color: style.textTertiary),
          SizedBox(width: style.spacing.xs),
        ],
        if (preview != null) ...[
          Flexible(
            child: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: emphasis),
          ),
          Text(' · ', style: meta),
        ],
        Text(d.timeLabel, maxLines: 1, style: unread && !d.room.muted ? emphasis : meta),
      ],
    );
  }
}
