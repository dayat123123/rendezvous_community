import 'dart:async';
import 'dart:math' as math;

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
import 'package:rendezvous_community/src/shared/presentation/theme/community_tokens.dart';
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
  final _away = ValueNotifier<bool>(false);
  final _unseen = ValueNotifier<int>(0);
  final _listKey = GlobalKey();
  final _floatingDay = ValueNotifier<DateTime?>(null);
  final _floatingShown = ValueNotifier<bool>(false);
  Timer? _floatingTimer;
  bool _floatingPending = false;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _scroll
      ..addListener(_loadOlderNearTop)
      ..addListener(_trackPosition);
  }

  void _trackPosition() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final away = position.pixels - position.minScrollExtent > math.max(240.0, position.viewportDimension * 0.5);
    if (away && !_away.value) _lastSeenTop = context.read<ChatRoomCubit>().state.messages.firstOrNull?.id;
    _away.value = away;
    if (!away) _unseen.value = 0;
    if (!_floatingPending) {
      _floatingPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateFloatingDate());
    }
  }

  void _updateFloatingDate() {
    _floatingPending = false;
    if (!mounted || !_scroll.hasClients) return;
    final position = _scroll.position;
    final viewport = _listKey.currentContext?.findRenderObject();
    final top = viewport is RenderBox && viewport.hasSize ? _anchors.topmost(viewport) : null;
    final messages = context.read<ChatRoomCubit>().state.messages;
    if (position.pixels - position.minScrollExtent < 24 || top == null || top.$1 >= messages.length) {
      _floatingTimer?.cancel();
      _floatingShown.value = false;
      return;
    }
    final index = top.$1;
    final message = messages[index];
    final older = index + 1 < messages.length ? messages[index + 1] : null;
    final dividerShowing = (older == null || !_sameDay(older.createdAt, message.createdAt)) && top.$2 < 56;
    _floatingDay.value = message.createdAt;
    _floatingShown.value = !dividerShowing;
    _floatingTimer?.cancel();
    _floatingTimer = Timer(_floatingHold, () {
      if (mounted) _floatingShown.value = false;
    });
  }

  bool _arrivedWhileAway(ChatRoomState before, ChatRoomState after) {
    if (!_away.value) return false;
    final latest = after.messages.firstOrNull;
    if (latest == null || after.isMine(latest) || latest.id == before.messages.firstOrNull?.id) return false;
    return before.messages.isNotEmpty;
  }

  void _countArrivals(ChatRoomState state) {
    final previous = _lastSeenTop;
    var added = 0;
    if (previous != null && state.messages.any((m) => m.id == previous)) {
      for (final message in state.messages) {
        if (message.id == previous) break;
        if (!state.isMine(message)) added++;
      }
    }
    _unseen.value += added == 0 ? 1 : added;
    _lastSeenTop = state.messages.firstOrNull?.id;
  }

  String? _lastSeenTop;

  void _jumpToLatest() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    _unseen.value = 0;
    if (position.pixels - position.minScrollExtent > position.viewportDimension * 3) {
      _scroll.jumpTo(position.minScrollExtent);
    } else {
      unawaited(
        _scroll.animateTo(
          position.minScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  void _loadOlderNearTop() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 400) context.read<ChatRoomCubit>().loadOlder();
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _highlight.dispose();
    _away.dispose();
    _unseen.dispose();
    _floatingTimer?.cancel();
    _floatingDay.dispose();
    _floatingShown.dispose();
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

  bool _sentByMe(ChatRoomState before, ChatRoomState after) {
    final latest = after.messages.firstOrNull;
    if (latest == null || !latest.isLocal || !after.isMine(latest)) return false;
    return before.messages.firstOrNull?.clientId != latest.clientId;
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (position.pixels <= position.minScrollExtent) return;
      if (position.pixels > position.viewportDimension * 3) {
        _scroll.jumpTo(position.minScrollExtent);
      } else {
        unawaited(
          _scroll.animateTo(
            position.minScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final builders = CommunityChatBuilders.of(context);
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatRoomCubit, ChatRoomState>(listenWhen: _sentByMe, listener: (_, _) => _scrollToLatest()),
        BlocListener<ChatRoomCubit, ChatRoomState>(
          listenWhen: (before, after) {
            if (!_away.value) _lastSeenTop = after.messages.firstOrNull?.id;
            return _arrivedWhileAway(before, after);
          },
          listener: (_, state) => _countArrivals(state),
        ),
      ],
      child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: KeyedSubtree(key: _listKey, child: _list(context, state, builders, l10n, spacing)),
                ),
                Positioned(
                  top: spacing.sm,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Center(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _floatingShown,
                          builder: (context, shown, _) => AnimatedOpacity(
                            key: const ValueKey('community-floating-date-fade'),
                            opacity: shown ? 1 : 0,
                            duration: Duration(milliseconds: shown ? 150 : 300),
                            curve: Curves.easeOut,
                            child: ValueListenableBuilder<DateTime?>(
                              valueListenable: _floatingDay,
                              builder: (context, day, _) => KeyedSubtree(
                                key: const ValueKey('community-floating-date'),
                                child: day == null
                                    ? const SizedBox.shrink()
                                    : buildChatPart(
                                        builders.floatingDate,
                                        context,
                                        CommunityDayDetails(day: day, label: l10n.dayLabel(day)),
                                        _FloatingDate(label: l10n.dayLabel(day)),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: spacing.md,
                  bottom: spacing.md,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _away,
                    builder: (context, away, _) => IgnorePointer(
                      ignoring: !away,
                      child: AnimatedScale(
                        scale: away ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOutBack,
                        child: ValueListenableBuilder<int>(
                          valueListenable: _unseen,
                          builder: (context, unread, _) {
                            final details = CommunityJumpToLatestDetails(
                              unread: unread,
                              label: unread > 0 ? l10n.jumpToLatestUnread(unread) : l10n.jumpToLatest,
                              onPressed: _jumpToLatest,
                            );
                            return buildChatPart(
                              builders.jumpToLatest,
                              context,
                              details,
                              _JumpToLatestButton(details: details),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _list(
    BuildContext context,
    ChatRoomState state,
    CommunityChatBuilders builders,
    CommunityLocalizations l10n,
    CommunitySpacing spacing,
  ) {
    return ListView.builder(
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
    );
  }
}

class _JumpToLatestButton extends StatelessWidget {
  const _JumpToLatestButton({required this.details});

  final CommunityJumpToLatestDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final unread = d.unread;
    return Tooltip(
      message: d.label,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Color.alphaBlend(style.textPrimary.withValues(alpha: 0.05), style.surface),
            shape: CircleBorder(
              side: BorderSide(color: style.divider, width: style.borderWidth),
            ),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            surfaceTintColor: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: d.onPressed,
              child: Semantics(
                button: true,
                label: d.label,
                excludeSemantics: true,
                child: SizedBox.square(
                  dimension: 42,
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: style.textSecondary),
                ),
              ),
            ),
          ),
          if (unread > 0)
            Positioned(
              top: -6,
              right: -4,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: style.accent, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: style.typography.label.copyWith(
                      color: style.onAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
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

const _floatingHold = Duration(milliseconds: 1500);

class _FloatingDate extends StatelessWidget {
  const _FloatingDate({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.chip,
        borderRadius: style.radii.pillRadius,
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 1))],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
        child: Text(label, style: style.typography.label.copyWith(fontSize: 12, color: style.textSecondary)),
      ),
    );
  }
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
