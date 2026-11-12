import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_text.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final builder = CommunityChatBuilders.of(context).roomHeader;
    return BlocBuilder<ChatRoomCubit, ChatRoomState>(
      buildWhen: (a, b) =>
          a.room != b.room ||
          a.typing != b.typing ||
          a.typingOthers != b.typingOthers ||
          a.members.length != b.members.length ||
          a.removedFromGroup != b.removedFromGroup ||
          a.closed != b.closed ||
          a.online != b.online,
      builder: (context, state) {
        final room = state.room;
        if (room == null) return const SizedBox.shrink();
        final open = !state.roomClosed;
        final cubit = context.read<ChatRoomCubit>();
        final typing = state.anyoneTyping;
        final otherUser = room.otherUser;
        final stockCode = room.stockCode;
        final details = CommunityRoomHeaderDetails(
          room: room,
          title: roomTitle(room),
          subtitle: typing
              ? typingText(l10n, state.typing.values, direct: room.type == RoomType.direct, others: state.typingOthers)
              : switch (room.type) {
                  RoomType.direct when state.otherOnline => l10n.online,
                  RoomType.direct => communityHandle(otherUser?.username ?? ''),
                  RoomType.group => l10n.members(state.members.length),
                  RoomType.stock => '${room.name ?? ''} · ${l10n.members(state.members.length)}',
                  RoomType.support => l10n.supportOfficialChannel,
                },
          highlightSubtitle: typing || (room.type == RoomType.direct && state.otherOnline),
          online: state.otherOnline,
          typing: state.typing.values.toList(),
          memberCount: state.members.length,
          onTap: room.type == RoomType.direct && otherUser != null
              ? () => CommunityNavigator.openUser(context, otherUser)
              : room.type == RoomType.stock && stockCode != null
              ? () => CommunityNavigator.openStock(context, stockCode)
              : room.type == RoomType.group && !state.removedFromGroup
              ? () async {
                  final left = await CommunityNavigator.openGroupInfo(context, room.id);
                  if (!context.mounted || (left ?? false)) return;
                  unawaited(cubit.refreshGroup());
                }
              : null,
          onToggleMute: room.type == RoomType.support ? null : () => cubit.setMuted(!room.muted),
          onLeave: !open || !room.canLeave || state.removedFromGroup ? null : cubit.leave,
          onHide: open && room.canHide
              ? () async {
                  if (await confirmCommunityAction(context, l10n.hideChatConfirm, confirmLabel: l10n.hideChat)) {
                    await cubit.hideRoom();
                  }
                }
              : null,
        );
        return buildChatPart(builder, context, details, _DefaultRoomHeader(details: details));
      },
    );
  }
}

class _DefaultRoomHeader extends StatelessWidget {
  const _DefaultRoomHeader({required this.details});

  final CommunityRoomHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onToggleMute = d.onToggleMute;
    final onLeave = d.onLeave;
    final onHide = d.onHide;
    final radius = style.avatarSizes.medium / 2;
    return Material(
      color: style.surface,
      shape: Border(bottom: style.borderSide.copyWith(color: style.divider)),
      child: InkWell(
        onTap: d.onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.sm, spacing.xs, spacing.sm),
          child: Row(
            children: [
              roomAvatar(context, d.room, online: d.online, radius: radius),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      d.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.typography.author.copyWith(fontSize: 15),
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      d.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: d.highlightSubtitle
                          ? style.typography.meta.copyWith(
                              color: CommunityTheme.of(context).onlineIndicator,
                              fontWeight: FontWeight.w600,
                            )
                          : style.typography.meta,
                    ),
                  ],
                ),
              ),
              if (onToggleMute != null)
                PopupMenuButton<VoidCallback>(
                  iconColor: style.textSecondary,
                  onSelected: (action) => action(),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: onToggleMute, child: Text(d.room.muted ? l10n.unmute : l10n.mute)),
                    if (onHide != null) PopupMenuItem(value: onHide, child: Text(l10n.hideChat)),
                    if (onLeave != null) PopupMenuItem(value: onLeave, child: Text(l10n.leaveRoom)),
                  ],
                )
              else
                SizedBox(height: style.minTouchTarget),
            ],
          ),
        ),
      ),
    );
  }
}
