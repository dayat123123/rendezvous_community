import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_offline_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/community_chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/new_group_dialog.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_tile.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/widgets/community_message_requests.dart';
import 'package:rendezvous_community/src/features/offline/presentation/widgets/community_offline_banner.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/community_support_chat.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityChatList extends StatelessWidget {
  const CommunityChatList({super.key, this.initialRoomId, this.builders});

  final String? initialRoomId;
  final CommunityChatBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final offline = CommunityOfflineScope.maybeOf(context);
    return withChatBuilders(
      context,
      builders,
      BlocProvider(
        create: (_) => ChatListCubit(
          chat: deps.chat,
          me: deps.ensureSignedIn,
          cache: offline?.chatCache,
          connectivity: offline?.connectivity,
          analytics: context.communityFeatures?.analytics,
        )..load(),
        child: _ListVisibility(child: _ChatListLayout(initialRoomId: initialRoomId)),
      ),
    );
  }
}

class _ListVisibility extends StatefulWidget {
  const _ListVisibility({required this.child});

  final Widget child;

  @override
  State<_ListVisibility> createState() => _ListVisibilityState();
}

class _ListVisibilityState extends State<_ListVisibility> {
  ValueListenable<TickerModeData>? _ticker;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onShow: _update, onHide: _update);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ticker = TickerMode.getValuesNotifier(context);
    if (identical(ticker, _ticker)) return;
    _ticker?.removeListener(_update);
    _ticker = ticker..addListener(_update);
    _update();
  }

  void _update() {
    if (!mounted) return;
    final shown = switch (SchedulerBinding.instance.lifecycleState) {
      AppLifecycleState.hidden || AppLifecycleState.paused || AppLifecycleState.detached => false,
      _ => true,
    };
    context.read<ChatListCubit>().setVisible(shown && (_ticker?.value.enabled ?? true));
  }

  @override
  void dispose() {
    _ticker?.removeListener(_update);
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ChatListLayout extends StatefulWidget {
  const _ChatListLayout({this.initialRoomId});

  final String? initialRoomId;

  @override
  State<_ChatListLayout> createState() => _ChatListLayoutState();
}

class _ChatListLayoutState extends State<_ChatListLayout> {
  late String? _selected = widget.initialRoomId;
  bool _selectedSupport = false;

  Future<void> _open(BuildContext context, ChatRoom room, {required bool wide}) async {
    final roomId = room.id;
    final support = room.type == RoomType.support;
    final cubit = context.read<ChatListCubit>()..markOpened(roomId);
    if (wide) {
      setState(() {
        _selected = roomId;
        _selectedSupport = support;
      });
      return;
    }
    if (support) {
      await openCommunitySupport(context);
      await cubit.refresh();
      return;
    }
    final deps = CommunityScope.of(context);
    final callback = deps.callbacks.onRoomTap;
    if (callback != null) return callback(context, roomId);
    final carry = carryCommunityBuilders(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => carry(
          CommunityScope(
            dependencies: deps,
            child: Scaffold(
              appBar: AppBar(),
              body: Builder(
                builder: (routeContext) => SafeArea(
                  top: false,
                  child: CommunityChatRoom(roomId: roomId, onClosed: () => Navigator.of(routeContext).maybePop()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= CommunityBreakpoints.wide;
        final list = _RoomList(
          selectedRoomId: wide ? _selected : null,
          onOpen: (room) => _open(context, room, wide: wide),
          onRemoved: (roomId) {
            if (_selected == roomId) setState(() => _selected = null);
          },
        );
        if (!wide) return list;
        return Row(
          children: [
            SizedBox(width: 340, child: list),
            VerticalDivider(width: 1, thickness: 1, color: CommunityStyle.of(context).divider),
            Expanded(
              child: _selected == null
                  ? buildChatPart(
                      CommunityChatBuilders.of(context).empty,
                      context,
                      CommunityEmptyDetails(
                        kind: CommunityChatEmpty.noRoomSelected,
                        message: context.communityL10n.selectChat,
                      ),
                      CommunityEmptyView(message: context.communityL10n.selectChat, icon: Icons.chat_outlined),
                    )
                  : _selectedSupport
                  ? const CommunitySupportChat()
                  : CommunityChatRoom(key: ValueKey(_selected), roomId: _selected!),
            ),
          ],
        );
      },
    );
  }
}

final _defaultConfig = ValueNotifier(const ClientConfig());

class _RoomList extends StatefulWidget {
  const _RoomList({required this.selectedRoomId, required this.onOpen, required this.onRemoved});

  final String? selectedRoomId;
  final ValueChanged<ChatRoom> onOpen;
  final ValueChanged<String> onRemoved;

  @override
  State<_RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<_RoomList> {
  final _scroll = ScrollController();
  int _requestsToken = 0;

  Future<void> _refresh(ChatListCubit cubit) async {
    setState(() => _requestsToken++);
    await cubit.refresh();
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 600) context.read<ChatListCubit>().loadMore();
  }

  Future<void> _newGroup(BuildContext context, ChatListCubit cubit) async {
    final roomId = await showNewGroupDialog(context);
    if (roomId == null || !context.mounted) return;
    await cubit.refresh();
    final room = cubit.state.rooms.where((r) => r.id == roomId).firstOrNull;
    if (room != null) widget.onOpen(room);
  }

  Future<void> _hide(BuildContext context, ChatListCubit cubit, ChatRoom room) async {
    final l10n = context.communityL10n;
    if (!await confirmCommunityAction(context, l10n.hideChatConfirm, confirmLabel: l10n.hideChat)) return;
    if (await cubit.hideRoom(room)) widget.onRemoved(room.id);
  }

  Future<void> _leave(BuildContext context, ChatListCubit cubit, ChatRoom room) async {
    final l10n = context.communityL10n;
    if (room.type == RoomType.group &&
        !await confirmCommunityAction(context, l10n.groupLeaveConfirm, confirmLabel: l10n.leaveRoom)) {
      return;
    }
    if (await cubit.leaveRoom(room)) widget.onRemoved(room.id);
  }

  Future<void> _deleteGroup(BuildContext context, ChatListCubit cubit, ChatRoom room) async {
    final l10n = context.communityL10n;
    if (!await confirmCommunityAction(context, l10n.deleteGroupConfirm, confirmLabel: l10n.deleteGroup)) return;
    if (await cubit.deleteGroup(room)) widget.onRemoved(room.id);
  }

  @override
  Widget build(BuildContext context) {
    final features = context.communityFeatures;
    return ValueListenableBuilder<ClientConfig>(
      valueListenable: features?.configService.listenable ?? _defaultConfig,
      builder: (context, config, _) => BlocConsumer<ChatListCubit, ChatListState>(
        listenWhen: (a, b) => a.actionErrorId != b.actionErrorId && b.actionError != null,
        listener: (context, state) => showCommunityError(context, state.actionError!),
        builder: (context, state) => _build(context, state, social: config.socialEnabled),
      ),
    );
  }

  Widget _build(BuildContext context, ChatListState state, {required bool social}) {
    final features = context.communityFeatures;
    final l10n = context.communityL10n;
    final builders = CommunityChatBuilders.of(context);
    final cubit = context.read<ChatListCubit>();
    final rooms = social
        ? state.rooms
        : [
            for (final r in state.rooms)
              if (r.type == RoomType.support) r,
          ];
    final Widget body = switch (state.status) {
      LoadStatus.initial || LoadStatus.loading => buildChatPart(
        builders.loading,
        context,
        const CommunityLoadingDetails(CommunityChatLoad.rooms),
        const CommunitySkeleton(itemCount: 6),
      ),
      LoadStatus.failure => buildChatPart(
        builders.error,
        context,
        CommunityErrorDetails(error: state.error!, message: l10n.errorMessage(state.error!), onRetry: cubit.load),
        CommunityErrorView(error: state.error!, onRetry: cubit.load),
      ),
      LoadStatus.ready when rooms.isEmpty && !social => const CommunityUnavailableView(),
      LoadStatus.ready when rooms.isEmpty => buildChatPart(
        builders.empty,
        context,
        CommunityEmptyDetails(kind: CommunityChatEmpty.rooms, message: l10n.noChats),
        CommunityEmptyView(message: l10n.noChats, icon: Icons.chat_bubble_outline),
      ),
      LoadStatus.ready => CommunityRefresh(
        onRefresh: () => _refresh(cubit),
        child: ListView.builder(
          addAutomaticKeepAlives: false,
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: rooms.length + (state.loadingMore && social ? 1 : 0) + (social ? 0 : 1),
          itemBuilder: (context, i) {
            if (!social && i == rooms.length) {
              return const SizedBox(height: 280, child: CommunityUnavailableView());
            }
            if (i == rooms.length) {
              return buildChatPart(
                builders.loading,
                context,
                const CommunityLoadingDetails(CommunityChatLoad.moreRooms),
                const CommunityLoadingView(),
              );
            }
            final room = rooms[i];
            return RoomTile(
              room: room,
              me: state.me,
              online: state.isOnline(room),
              typing: state.typingIn(room.id),
              selected: room.id == widget.selectedRoomId,
              onTap: () => widget.onOpen(room),
              onHide: () => _hide(context, cubit, room),
              onLeave: () => _leave(context, cubit, room),
              onDeleteGroup: () => _deleteGroup(context, cubit, room),
            );
          },
        ),
      ),
    };
    if (social && state.status == LoadStatus.ready && state.rooms.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMoreNearEnd();
      });
    }
    final header = CommunityChatListHeaderDetails(
      title: l10n.chats,
      onNewGroup: () => _newGroup(context, cubit),
      onRefresh: () => _refresh(cubit),
    );
    return Material(
      color: CommunityStyle.of(context).surface,
      child: Column(
        children: [
          buildChatPart(builders.listHeader, context, header, _DefaultListHeader(details: header)),
          const CommunityOfflineBanner(),
          if (social && features != null) MessageRequestsEntry(refreshToken: _requestsToken),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _DefaultListHeader extends StatelessWidget {
  const _DefaultListHeader({required this.details});

  final CommunityChatListHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.xs, spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(details.title, style: style.typography.title.copyWith(fontSize: 26, height: 1.2)),
            ),
          ),
          IconButton(
            tooltip: context.communityL10n.newGroup,
            onPressed: details.onNewGroup,
            color: style.textSecondary,
            icon: const Icon(Icons.group_add_outlined),
          ),
        ],
      ),
    );
  }
}
