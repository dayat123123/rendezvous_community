import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/features/message_requests/domain/entities/message_request.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/cubit/message_request_room_cubit.dart';
import 'package:rendezvous_community/src/features/message_requests/presentation/cubit/message_requests_cubit.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_count_badge.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Widget _scoped(BuildContext context, Widget child) {
  final deps = CommunityScope.of(context);
  final features = CommunityFeatureScope.of(context);
  final carry = carryCommunityBuilders(context);
  return carry(
    CommunityFeatureScope(
      dependencies: features,
      child: CommunityScope(dependencies: deps, child: child),
    ),
  );
}

Future<bool> openCommunityMessageRequests(BuildContext context) async {
  final title = context.communityL10n.messageRequests;
  final changed = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (pageContext) => _scoped(
        context,
        Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const SafeArea(top: false, child: CommunityMessageRequests()),
        ),
      ),
    ),
  );
  return changed ?? false;
}

class MessageRequestsEntry extends StatefulWidget {
  const MessageRequestsEntry({super.key, this.refreshToken = 0});

  final int refreshToken;

  @override
  State<MessageRequestsEntry> createState() => _MessageRequestsEntryState();
}

class _MessageRequestsEntryState extends State<MessageRequestsEntry> {
  MessageRequestsCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final features = CommunityFeatureScope.maybeOf(context);
    if (_cubit == null && features != null) _cubit = MessageRequestsCubit(features.messageRequests)..loadCount();
  }

  @override
  void didUpdateWidget(MessageRequestsEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _cubit?.loadCount();
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  Future<void> _open() async {
    await openCommunityMessageRequests(context);
    await _cubit?.loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    if (cubit == null) return const SizedBox.shrink();
    return BlocBuilder<MessageRequestsCubit, MessageRequestsState>(
      bloc: cubit,
      buildWhen: (a, b) => a.count != b.count,
      builder: (context, state) {
        if (state.count <= 0) return const SizedBox.shrink();
        final details = CommunityRequestsEntryDetails(
          count: state.count,
          label: context.communityL10n.messageRequests,
          onOpen: _open,
        );
        return buildChatPart(
          CommunityChatBuilders.of(context).requestsEntry,
          context,
          details,
          _DefaultRequestsEntry(details: details),
        );
      },
    );
  }
}

class _DefaultRequestsEntry extends StatelessWidget {
  const _DefaultRequestsEntry({required this.details});

  final CommunityRequestsEntryDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    const radius = 26.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: details.onOpen,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm + spacing.xxs),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: radius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: style.accentMuted, shape: BoxShape.circle),
                    child: Icon(Icons.mark_email_unread_outlined, size: radius, color: style.accent),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(child: Text(details.label, style: style.typography.author.copyWith(fontSize: 15))),
                CommunityCountBadge(count: details.count, kind: CommunityCountKind.messageRequests),
                SizedBox(width: spacing.xs),
                Icon(Icons.chevron_right, color: style.textTertiary),
              ],
            ),
          ),
        ),
        CommunityDivider(indent: spacing.lg + radius * 2 + spacing.md),
      ],
    );
  }
}

class CommunityMessageRequests extends StatelessWidget {
  const CommunityMessageRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final features = CommunityFeatureScope.of(context);
    return BlocProvider(
      create: (_) => MessageRequestsCubit(features.messageRequests)..load(),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView();

  Future<void> _open(BuildContext context, MessageRequest request) async {
    final cubit = context.read<MessageRequestsCubit>();
    final result = await Navigator.of(context).push<MessageRequestAction>(
      MaterialPageRoute(
        builder: (_) => _scoped(
          context,
          Scaffold(
            appBar: AppBar(title: Text(request.sender.name)),
            body: SafeArea(top: false, child: MessageRequestRoom(request: request)),
          ),
        ),
      ),
    );
    if (result == null || !context.mounted) return;
    cubit.removeRequest(request.roomId);
    if (result == MessageRequestAction.accept) CommunityNavigator.openRoom(context, request.roomId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final builder = CommunityChatBuilders.of(context).requestTile;
    return BlocConsumer<MessageRequestsCubit, MessageRequestsState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<MessageRequestsCubit>();
        return switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => const CommunitySkeleton(itemCount: 4),
          LoadStatus.failure => CommunityErrorView(error: state.error!, onRetry: cubit.load),
          LoadStatus.ready when state.requests.isEmpty => CommunityEmptyView(
            message: l10n.messageRequestsEmpty,
            icon: Icons.mark_email_read_outlined,
          ),
          LoadStatus.ready => Material(
            color: style.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
                child: RefreshIndicator(
                  onRefresh: cubit.load,
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 300) cubit.loadMore();
                      return false;
                    },
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.requests.length,
                      itemBuilder: (context, i) {
                        final request = state.requests[i];
                        final time = request.lastMessageAt ?? request.createdAt;
                        final details = CommunityMessageRequestDetails(
                          request: request,
                          preview: [
                            if (request.hasImage) '📷',
                            request.lastMessagePreview ?? l10n.attachment,
                          ].join(' '),
                          timeLabel: l10n.relativeTime(time),
                          countLabel: l10n.messageRequestMessages(request.messageCount),
                          onOpen: () => _open(context, request),
                        );
                        return buildChatPart(builder, context, details, _DefaultRequestTile(details: details));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        };
      },
    );
  }
}

class _DefaultRequestTile extends StatelessWidget {
  const _DefaultRequestTile({required this.details});

  final CommunityMessageRequestDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    const radius = 26.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: details.onOpen,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm + spacing.xxs),
            child: Row(
              children: [
                CommunityAvatar(user: details.request.sender, radius: radius),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommunityUserName(
                        user: details.request.sender,
                        showUsername: false,
                        style: style.typography.author.copyWith(fontSize: 15),
                      ),
                      SizedBox(height: spacing.xxs),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              details.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style.typography.meta.copyWith(color: style.textPrimary),
                            ),
                          ),
                          Text(' · ', style: style.typography.meta),
                          Text(details.timeLabel, style: style.typography.meta),
                        ],
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(details.countLabel, style: style.typography.badge.copyWith(color: style.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        CommunityDivider(indent: spacing.lg + radius * 2 + spacing.md),
      ],
    );
  }
}

class MessageRequestRoom extends StatelessWidget {
  const MessageRequestRoom({super.key, required this.request});

  final MessageRequest request;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = CommunityFeatureScope.of(context);
    return BlocProvider(
      create: (_) =>
          MessageRequestRoomCubit(chat: deps.chat, requests: features.messageRequests, roomId: request.roomId)..load(),
      child: _RequestRoomView(request: request),
    );
  }
}

class _RequestRoomView extends StatelessWidget {
  const _RequestRoomView({required this.request});

  final MessageRequest request;

  Future<void> _respond(BuildContext context, MessageRequestAction action) async {
    final l10n = context.communityL10n;
    if (action == MessageRequestAction.block &&
        !await confirmCommunityAction(
          context,
          l10n.messageRequestBlockConfirm(request.sender.name),
          confirmLabel: l10n.messageRequestBlock,
        )) {
      return;
    }
    if (!context.mounted) return;
    final ok = await context.read<MessageRequestRoomCubit>().respond(action);
    if (!ok || !context.mounted) return;
    showCommunityMessage(context, switch (action) {
      MessageRequestAction.accept => l10n.messageRequestAccepted,
      MessageRequestAction.decline => l10n.messageRequestDeclined,
      MessageRequestAction.block => l10n.blocked(request.sender.name),
    });
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final builders = CommunityChatBuilders.of(context);
    final style = CommunityStyle.of(context);
    return BlocConsumer<MessageRequestRoomCubit, MessageRequestRoomState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<MessageRequestRoomCubit>();
        final busy = state.responding != null;
        final intro = CommunityRequestIntroDetails(
          request: request,
          message: l10n.messageRequestIntro(request.sender.name),
          imageNotice: request.hasImage ? l10n.messageRequestImageHidden : null,
        );
        final actions = CommunityRequestActionsDetails(
          request: request,
          busy: busy,
          responding: state.responding,
          onAccept: busy ? null : () => _respond(context, MessageRequestAction.accept),
          onDecline: busy ? null : () => _respond(context, MessageRequestAction.decline),
          onBlock: busy ? null : () => _respond(context, MessageRequestAction.block),
        );
        return Material(
          color: style.surface,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildChatPart(builders.requestIntro, context, intro, _DefaultRequestIntro(details: intro)),
                  Expanded(
                    child: switch (state.status) {
                      LoadStatus.initial || LoadStatus.loading => const CommunitySkeleton(itemCount: 3),
                      LoadStatus.failure => CommunityErrorView(error: state.error!, onRetry: cubit.load),
                      LoadStatus.ready => ListView(
                        reverse: true,
                        padding: EdgeInsets.all(style.spacing.md),
                        children: [for (final m in state.messages) _RequestBubble(message: m)],
                      ),
                    },
                  ),
                  const CommunityDivider(),
                  buildChatPart(builders.requestActions, context, actions, _DefaultRequestActions(details: actions)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DefaultRequestIntro extends StatelessWidget {
  const _DefaultRequestIntro({required this.details});

  final CommunityRequestIntroDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final imageNotice = details.imageNotice;
    final sender = details.request.sender;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.surface,
        border: Border(
          bottom: BorderSide(color: style.divider, width: style.borderWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.xl, spacing.lg, spacing.xl, spacing.lg),
        child: Column(
          children: [
            CommunityAvatar(user: sender, radius: style.avatarSizes.large / 2),
            SizedBox(height: spacing.sm),
            CommunityUserName(user: sender, showUsername: false, style: style.typography.title),
            SizedBox(height: spacing.xs),
            Text(details.message, textAlign: TextAlign.center, style: style.typography.meta),
            if (imageNotice != null)
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Text(
                  imageNotice,
                  textAlign: TextAlign.center,
                  style: style.typography.meta.copyWith(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DefaultRequestActions extends StatelessWidget {
  const _DefaultRequestActions({required this.details});

  final CommunityRequestActionsDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final error = Theme.of(context).colorScheme.error;
    return Material(
      color: style.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(style.spacing.md),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: style.spacing.sm,
            runSpacing: style.spacing.sm,
            children: [
              TextButton.icon(
                onPressed: details.onBlock,
                style: TextButton.styleFrom(
                  foregroundColor: error,
                  textStyle: style.typography.label.copyWith(fontSize: 14),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.block),
                label: Text(l10n.messageRequestBlock),
              ),
              OutlinedButton(
                style: style.secondaryButtonStyle(),
                onPressed: details.onDecline,
                child: Text(l10n.messageRequestDecline),
              ),
              FilledButton(
                style: style.primaryButtonStyle(),
                onPressed: details.onAccept,
                child: details.responding == MessageRequestAction.accept
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: style.onAccent),
                      )
                    : Text(l10n.messageRequestAccept),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestBubble extends StatelessWidget {
  const _RequestBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final details = CommunityMessageDetails(
      message: message,
      isMine: false,
      receipt: null,
      showSender: false,
      startsGroup: true,
      timeLabel: context.communityL10n.clockTime(message.createdAt),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).requestBubble,
      context,
      details,
      _DefaultRequestBubble(details: details),
    );
  }
}

class _DefaultRequestBubble extends StatelessWidget {
  const _DefaultRequestBubble({required this.details});

  final CommunityMessageDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final colors = CommunityTheme.of(context);
    final message = details.message;
    final body = message.body ?? '';
    final fg = colors.onOtherBubble;
    const round = Radius.circular(18);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: spacing.xxs + 1),
        padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.xs + spacing.xxs),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: colors.otherBubble,
          borderRadius: BorderRadius.only(
            topLeft: round,
            topRight: round,
            bottomRight: round,
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.isDeleted)
              Text(
                l10n.messageDeleted,
                style: style.typography.body.copyWith(color: fg, fontStyle: FontStyle.italic),
              )
            else ...[
              if (message.attachments.isNotEmpty)
                AttachmentGrid(attachments: message.attachments, maxHeight: 200, blurred: true),
            ],
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: spacing.sm,
              children: [
                if (!message.isDeleted && body.isNotEmpty)
                  Text(body, style: style.typography.body.copyWith(color: fg, height: 1.4)),
                Padding(
                  padding: EdgeInsets.only(top: spacing.xxs),
                  child: Text(
                    details.timeLabel,
                    style: style.typography.meta.copyWith(fontSize: 11, height: 1.2, color: fg.withValues(alpha: 0.82)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
