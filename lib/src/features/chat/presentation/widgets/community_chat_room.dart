import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_official_scope.dart';
import 'package:rendezvous_community/src/app/community_offline_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/network/realtime_status.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_events.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_composer.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/message_list.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_banners.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_header.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_bubble.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/typing_text.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/features/offline/presentation/widgets/community_offline_banner.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_selectable.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityChatRoom extends StatelessWidget {
  const CommunityChatRoom({
    super.key,
    required this.roomId,
    this.showHeader = true,
    this.repository,
    this.header,
    this.composer,
    this.builders,
    this.onClosed,
  });

  final String roomId;
  final bool showHeader;
  final ChatRepository? repository;
  final Widget? header;
  final Widget? composer;
  final CommunityChatBuilders? builders;
  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = repository == null ? context.communityFeatures : null;
    final offline = CommunityOfflineScope.maybeOf(context);
    final cached = repository == null ? offline : null;
    return withChatBuilders(
      context,
      builders,
      BlocProvider(
        create: (_) => ChatRoomCubit(
          chat: repository ?? deps.chat,
          media: deps.media,
          me: deps.ensureSignedIn,
          roomId: roomId,
          consent: communityConsentGate(context),
          extras: features?.chatExtras,
          analytics: features?.analytics,
          requests: features?.messageRequests,
          cache: cached?.chatCache,
          outbox: cached?.outbox,
          connectivity: offline?.connectivity,
          stockCards: deps.callbacks.chatStockCards,
        )..load(),
        child: _ChatRoomView(showHeader: showHeader, header: header, composer: composer, onClosed: onClosed),
      ),
    );
  }
}

class _ChatRoomView extends StatelessWidget {
  const _ChatRoomView({required this.showHeader, this.header, this.composer, this.onClosed});

  final bool showHeader;
  final Widget? header;
  final Widget? composer;
  final VoidCallback? onClosed;

  static String closedMessage(BuildContext context, ChatRoomState state) {
    final l10n = context.communityL10n;
    final actor = state.closedBy;
    return switch (state.closed) {
      RoomRemovalReason.hidden => l10n.chatHiddenNotice,
      RoomRemovalReason.groupDeleted when actor != null && actor.isNotEmpty => l10n.groupDeletedBy(actor),
      _ => l10n.groupDeletedNotice,
    };
  }

  @override
  Widget build(BuildContext context) {
    final builders = CommunityChatBuilders.of(context);
    return BlocConsumer<ChatRoomCubit, ChatRoomState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId || (!a.roomClosed && b.roomClosed),
      listener: (context, state) {
        if (state.roomClosed) {
          showCommunityMessage(context, closedMessage(context, state));
          onClosed?.call();
          return;
        }
        showCommunityError(context, state.actionError!);
      },
      buildWhen: (a, b) => a.status != b.status || a.roomClosed != b.roomClosed,
      builder: (context, state) {
        final cubit = context.read<ChatRoomCubit>();
        if (state.roomClosed) {
          return _RoomSurface(
            child: CommunityEmptyView(
              message: closedMessage(context, state),
              icon: state.closed == RoomRemovalReason.hidden ? Icons.delete_outline : Icons.group_off_outlined,
            ),
          );
        }
        return switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => buildChatPart(
            builders.loading,
            context,
            const CommunityLoadingDetails(CommunityChatLoad.messages),
            const CommunitySkeleton(itemCount: 6),
          ),
          LoadStatus.failure => buildChatPart(
            builders.error,
            context,
            CommunityErrorDetails(
              error: state.error!,
              message: context.communityL10n.errorMessage(state.error!),
              onRetry: cubit.load,
            ),
            CommunityErrorView(error: state.error!, onRetry: cubit.load),
          ),
          LoadStatus.ready => _gate(
            state,
            _RoomSurface(
              child: Column(
                children: [
                  Expanded(
                    child: CommunitySelectable(
                      child: Column(
                        children: [
                          if (header != null) header! else if (showHeader) const RoomHeader(),
                          const _ReconnectBanner(),
                          const StockRoomBanner(),
                          const RoomModerationBanner(),
                          const DmRequestNotice(),
                          const Expanded(child: MessageList()),
                        ],
                      ),
                    ),
                  ),
                  const _TypingIndicator(),
                  const CommunityDivider(),
                  _GroupGate(child: _OfficialGate(child: composer ?? const MessageComposer())),
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}

class _GroupGate extends StatelessWidget {
  const _GroupGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final room = context.select((ChatRoomCubit c) => c.state.room);
    final removed = context.select((ChatRoomCubit c) => c.state.removedFromGroup);
    if (room == null || room.type != RoomType.group || (!removed && room.canSend)) return child;
    final l10n = context.communityL10n;
    final details = CommunityGroupNoticeDetails(
      room: room,
      message: removed ? l10n.groupRemovedNotice : l10n.groupAdminsOnlyNotice,
      removed: removed,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupNotice,
      context,
      details,
      SafeArea(
        top: false,
        child: ChatStrip(icon: removed ? Icons.block : Icons.campaign_outlined, message: details.message),
      ),
    );
  }
}

class _OfficialGate extends StatelessWidget {
  const _OfficialGate({required this.child});

  final Widget child;

  static final _none = ValueNotifier<Set<String>>(const <String>{});

  @override
  Widget build(BuildContext context) {
    final room = context.select((ChatRoomCubit c) => c.state.room);
    final other = room?.type == RoomType.direct ? room?.otherUser : null;
    if (other == null) return child;
    final accounts = CommunityOfficialScope.maybeOf(context)?..ensureLoaded();
    return ValueListenableBuilder<Set<String>>(
      valueListenable: accounts ?? _none,
      builder: (context, ids, _) {
        final me = CommunityScope.of(context).currentUser;
        final meOfficial = me != null && (me.isOfficial || ids.contains(me.id));
        if (meOfficial || !CommunityOfficialScope.isOfficial(context, other)) return child;
        final l10n = context.communityL10n;
        final contact = CommunityScope.of(context).callbacks.onOfficialContact;
        final details = CommunityOfficialNoticeDetails(
          user: other,
          message: l10n.officialDmNotice,
          contactLabel: l10n.officialContact,
          onContact: contact == null ? null : () => contact(context, other),
        );
        return buildChatPart(
          CommunityChatBuilders.of(context).officialNotice,
          context,
          details,
          _DefaultOfficialNotice(details: details),
        );
      },
    );
  }
}

class _DefaultOfficialNotice extends StatelessWidget {
  const _DefaultOfficialNotice({required this.details});

  final CommunityOfficialNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final contact = details.onContact;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: style.textSecondary),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(details.message, style: style.typography.meta.copyWith(color: style.textSecondary)),
            ),
            if (contact != null) ...[
              SizedBox(width: spacing.sm),
              TextButton.icon(
                onPressed: contact,
                icon: const Icon(Icons.support_agent_outlined, size: 18),
                label: Text(details.contactLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoomSurface extends StatelessWidget {
  const _RoomSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(color: CommunityStyle.of(context).surface, child: child);
}

Widget _gate(ChatRoomState state, Widget child) =>
    state.room?.type == RoomType.support ? child : CommunitySocialGate(child: child);

class _ReconnectBanner extends StatelessWidget {
  const _ReconnectBanner();

  @override
  Widget build(BuildContext context) {
    final connectivity = CommunityOfflineScope.maybeOf(context)?.connectivity;
    if (connectivity == null) return const _RealtimeBanner();
    return ValueListenableBuilder<bool>(
      valueListenable: connectivity.online,
      builder: (context, online, _) => online ? const _RealtimeBanner() : const _OfflineBanner(),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatRoomCubit>();
    final status = context.select((ChatRoomCubit c) => c.state.connection);
    final l10n = context.communityL10n;
    final label = cubit.queuesOffline ? l10n.offlineChatBanner : l10n.errorNetwork;
    return buildChatPart(
      CommunityChatBuilders.of(context).connectionBanner,
      context,
      CommunityConnectionDetails(status: status, label: label, offline: true),
      CommunityOfflineNotice(message: label),
    );
  }
}

class _RealtimeBanner extends StatelessWidget {
  const _RealtimeBanner();

  @override
  Widget build(BuildContext context) {
    final status = context.select((ChatRoomCubit c) => c.state.connection);
    if (status != RealtimeStatus.reconnecting) return const SizedBox.shrink();
    final label = context.communityL10n.reconnecting;
    final tone = Theme.of(context).colorScheme.tertiary;
    return buildChatPart(
      CommunityChatBuilders.of(context).connectionBanner,
      context,
      CommunityConnectionDetails(status: status, label: label),
      ChatStrip(
        icon: Icons.sync,
        message: label,
        tone: tone,
        leading: SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: tone)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final state = context.select((ChatRoomCubit c) => c.state);
    if (!state.anyoneTyping) return const SizedBox(height: 0);
    final type = state.room?.type;
    final typists = state.typing.values.toList();
    final text = typingText(
      context.communityL10n,
      state.typing.values,
      direct: state.room?.type == RoomType.direct,
      others: state.typingOthers,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).typingIndicator,
      context,
      CommunityTypingDetails(users: typists, text: text, count: state.typingOthers),
      TypingBubble(
        label: text,
        user: (type == RoomType.group || type == RoomType.stock) && typists.length == 1 && state.typingOthers == 0
            ? typists.single
            : null,
      ),
    );
  }
}
