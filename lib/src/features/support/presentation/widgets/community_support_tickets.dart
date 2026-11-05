import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_support_scope.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/chat/data/realtime/room_connection.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_events.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/community_chat_room.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/repositories/support_repository.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_header.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunitySupportTickets extends StatefulWidget {
  const CommunitySupportTickets({super.key});

  @override
  State<CommunitySupportTickets> createState() => _CommunitySupportTicketsState();
}

class _CommunitySupportTicketsState extends State<CommunitySupportTickets> {
  late Future<List<SupportTicket>> _tickets = CommunitySupportScope.of(context).support.myTickets();

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return FutureBuilder<List<SupportTicket>>(
      future: _tickets,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          void retry() => setState(() => _tickets = CommunitySupportScope.of(context).support.myTickets());
          return buildSupportPart(
            (b) => b.error,
            context,
            CommunityListErrorDetails(
              error: snapshot.error!,
              message: l10n.errorMessage(snapshot.error!),
              onRetry: retry,
            ),
            CommunityErrorView(error: snapshot.error!, onRetry: retry),
          );
        }
        if (!snapshot.hasData) {
          return buildSupportPart(
            (b) => b.loading,
            context,
            const CommunityListLoadingDetails(),
            const CommunitySkeleton(itemCount: 4),
          );
        }
        final tickets = snapshot.data!;
        if (tickets.isEmpty) {
          return buildSupportPart(
            (b) => b.empty,
            context,
            CommunityListEmptyDetails(message: l10n.supportNoTickets),
            CommunityEmptyView(message: l10n.supportNoTickets, icon: Icons.inbox_outlined),
          );
        }
        final indent = style.spacing.lg + 40 + style.spacing.md;
        return ColoredBox(
          color: style.surface,
          child: ListView.separated(
            addAutomaticKeepAlives: false,
            itemCount: tickets.length,
            separatorBuilder: (_, _) => CommunityDivider(indent: indent),
            itemBuilder: (context, i) {
              final ticket = tickets[i];
              final day = l10n.dayLabel(ticket.createdAt);
              final details = CommunitySupportTicketDetails(
                ticket: ticket,
                title: '${ticket.ticketNumber} · ${ticket.topicName ?? ticket.topic}',
                statusLabel: supportStatusText(l10n, ticket),
                meta: [day, if (ticket.rating != null) l10n.supportRating(ticket.rating!)].join(' · '),
                timeLabel: day,
                icon: supportTopicIcon(ticket.topic),
                onOpen: () => _openTranscript(context, ticket),
              );
              return buildSupportPart(
                (b) => b.ticketTile,
                context,
                details,
                SupportTicketTile(key: ValueKey(ticket.id), details: details),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openTranscript(BuildContext context, SupportTicket ticket) {
    final deps = CommunityScope.of(context);
    final support = CommunitySupportScope.of(context).support;
    final carry = carryCommunityBuilders(context);
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => carry(
          CommunityScope(
            dependencies: deps,
            child: Scaffold(
              appBar: AppBar(title: Text('${ticket.ticketNumber} · ${ticket.topicName ?? ticket.topic}')),
              body: CommunityImagePersistence(
                persist: false,
                child: CommunityChatRoom(
                  roomId: ticket.roomId,
                  repository: _TranscriptRepository(support, ticket),
                  showHeader: false,
                  composer: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SupportTicketTile extends StatelessWidget {
  const SupportTicketTile({super.key, required this.details});

  final CommunitySupportTicketDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final statusColor = supportStatusColor(context, d.ticket.status);
    return Material(
      color: style.surface,
      child: InkWell(
        onTap: d.onOpen,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.minTouchTarget),
          child: Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.sm, spacing.md),
            child: Row(
              children: [
                SupportIconCircle(icon: d.icon, color: d.closed ? style.textSecondary : style.accent),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.author),
                      SizedBox(height: spacing.xxs),
                      Text(d.meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                      SizedBox(height: spacing.xs + spacing.xxs),
                      SupportSoftPill(label: d.statusLabel, color: statusColor),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: style.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptRepository implements ChatRepository {
  _TranscriptRepository(this._support, this._ticket);

  final SupportRepository _support;
  final SupportTicket _ticket;

  static const _readOnly = CommunityException(CommunityErrorKind.forbidden, code: 'transcript_read_only');

  ChatRoom get _room =>
      ChatRoom(id: _ticket.roomId, type: RoomType.support, createdAt: _ticket.createdAt, lastReadAt: _ticket.createdAt);

  @override
  Future<Paged<ChatRoom>> getRooms({String? cursor, int limit = 30}) async =>
      cursor == null ? Paged([_room]) : const Paged.empty();

  @override
  Future<ChatRoom?> getRoom(String roomId) async => roomId == _ticket.roomId ? _room : null;

  @override
  Future<Paged<ChatMessage>> getMessages(String roomId, {String? cursor, int limit = 30}) async {
    if (cursor != null) return const Paged([]);
    final messages = await _support.ticketMessages(_ticket.id);
    return Paged([...messages]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Future<Paged<ChatMessage>> getMessagesAfter(String roomId, String cursor, {int limit = 100}) async =>
      const Paged.empty();

  @override
  Future<List<RoomMember>> getMembers(String roomId) async => const [];

  @override
  ChatRoomConnection connectRoom(String roomId, {required UserSummary me}) => NoopRoomConnection();

  @override
  Future<void> markRoomRead(String roomId) async {}

  @override
  Future<int> markDelivered({List<String>? roomIds}) async => 0;

  @override
  Future<Map<String, int>> unreadCounts() async => const {};

  @override
  Future<int> unreadChatCount() async => 0;

  @override
  Stream<void> watchUnreadChanges() => const Stream.empty();

  @override
  Stream<RoomActivity> watchRoomActivity() => const Stream.empty();

  @override
  Stream<RoomSignal> watchRoomSignals(Set<String> roomIds, {required UserSummary me}) => const Stream.empty();

  @override
  Future<ChatMessage> sendMessage(
    String roomId, {
    required String body,
    required String clientId,
    String? replyToId,
    List<Attachment> attachments = const [],
  }) => Future.error(_readOnly);

  @override
  Future<void> deleteMessage(String messageId) => Future.error(_readOnly);

  @override
  Future<String> getOrCreateDirectRoom(String otherUserId) => Future.error(_readOnly);

  @override
  Future<String> createGroupRoom(String name, List<String> memberIds) => Future.error(_readOnly);

  @override
  Future<String> joinStockRoom(String stockCode) => Future.error(_readOnly);

  @override
  Future<void> leaveRoom(String roomId) => Future.error(_readOnly);

  @override
  Future<void> setMuted(String roomId, {required bool muted}) => Future.error(_readOnly);
}
