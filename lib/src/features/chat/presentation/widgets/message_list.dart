import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_bubble.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_jump.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scroll = ScrollController();
  final _anchors = MessageAnchors();
  final _highlight = ValueNotifier<String?>(null);
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadOlderNearTop);
  }

  void _loadOlderNearTop() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 400) context.read<ChatRoomCubit>().loadOlder();
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _highlight.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reveal(String id) async {
    final cubit = context.read<ChatRoomCubit>();
    int indexOf() => cubit.state.messages.indexWhere((m) => m.id == id);
    var index = indexOf();
    for (var page = 0; index < 0 && page < 20 && !cubit.isClosed; page++) {
      if (cubit.state.loadingOlder) {
        await cubit.stream.firstWhere((s) => !s.loadingOlder);
      } else if (cubit.state.nextCursor == null) {
        break;
      } else {
        await cubit.loadOlder();
      }
      index = indexOf();
    }
    if (!mounted) return;
    if (index < 0) {
      showCommunityMessage(context, context.communityL10n.replyOriginalMissing);
      return;
    }
    for (var step = 0; step < 60 && mounted && _scroll.hasClients; step++) {
      final target = _anchors.contextOf(id);
      if (target != null && target.mounted) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
        _flash(id);
        return;
      }
      final range = _anchors.builtRange;
      final position = _scroll.position;
      final older = range == null || indexOf() > range.$2;
      final next = (position.pixels + position.viewportDimension * (older ? 0.8 : -0.8)).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (next == position.pixels) break;
      _scroll.jumpTo(next);
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _flash(String id) {
    _highlightTimer?.cancel();
    _highlight.value = id;
    _highlightTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) _highlight.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final builders = CommunityChatBuilders.of(context);
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    return BlocBuilder<ChatRoomCubit, ChatRoomState>(
      buildWhen: (a, b) =>
          a.messages != b.messages ||
          a.members != b.members ||
          a.loadingOlder != b.loadingOlder ||
          a.room != b.room ||
          a.stockRoom?.moderatorIds != b.stockRoom?.moderatorIds ||
          a.stockRoom?.mutes != b.stockRoom?.mutes ||
          a.me != b.me,
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return buildChatPart(
            builders.empty,
            context,
            CommunityEmptyDetails(kind: CommunityChatEmpty.messages, message: l10n.messageHint),
            CommunityEmptyView(message: l10n.messageHint, icon: Icons.waving_hand_outlined),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadOlderNearTop();
        });
        return MessageJumpScope(
          reveal: _reveal,
          highlighted: _highlight,
          child: ListView.builder(
            addAutomaticKeepAlives: false,
            controller: _scroll,
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
            itemCount: state.messages.length + (state.loadingOlder ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == state.messages.length) {
                return buildChatPart(
                  builders.loading,
                  context,
                  const CommunityLoadingDetails(CommunityChatLoad.olderMessages),
                  const CommunityLoadingView(),
                );
              }
              final message = state.messages[i];
              final older = i + 1 < state.messages.length ? state.messages[i + 1] : null;
              final newer = i > 0 ? state.messages[i - 1] : null;
              final newDay = older == null || !_sameDay(older.createdAt, message.createdAt);
              final grouped = older != null && !newDay && _joins(older, message);
              final continued = newer != null && _sameDay(message.createdAt, newer.createdAt) && _joins(message, newer);
              final mine = state.isMine(message);
              final type = state.room?.type;
              final bubble = MessageBubble(
                key: ValueKey(message.clientId ?? message.id),
                message: message,
                mine: mine,
                receipt: state.receiptOf(message),
                showSender: !grouped && type != RoomType.direct && !mine,
                startsGroup: !grouped,
                endsGroup: !continued,
                showAvatar: !mine && (type == RoomType.group || type == RoomType.stock),
              );
              final anchored = MessageAnchor(
                key: ValueKey('anchor-${message.clientId ?? message.id}'),
                id: message.id,
                index: i,
                anchors: _anchors,
                highlighted: _highlight,
                child: bubble,
              );
              if (!newDay) return anchored;
              final divider = buildChatPart(
                builders.dayDivider,
                context,
                CommunityDayDetails(day: message.createdAt, label: l10n.dayLabel(message.createdAt)),
                _DayDivider(time: message.createdAt),
              );
              return Column(
                key: ValueKey('day-${message.clientId ?? message.id}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [divider, anchored],
              );
            },
          ),
        );
      },
    );
  }
}

bool _joins(ChatMessage older, ChatMessage newer) =>
    !older.isSystem &&
    !newer.isSystem &&
    older.senderId == newer.senderId &&
    newer.createdAt.difference(older.createdAt).inMinutes < 3;

bool _sameDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.only(top: spacing.lg, bottom: spacing.xs),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(color: style.chip, borderRadius: style.radii.pillRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
            child: Text(
              context.communityL10n.dayLabel(time),
              style: style.typography.label.copyWith(fontSize: 12, color: style.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
