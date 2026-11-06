import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_info.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/receipt_icon.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

const _wideLayout = 600.0;

Future<void> showCommunityMessageInfo(BuildContext context, ChatMessage message) {
  final cubit = context.read<ChatRoomCubit>();
  final carry = carryCommunityBuilders(context);
  final deps = CommunityScope.maybeOf(context);
  Widget content(BuildContext _) {
    final view = BlocProvider.value(
      value: cubit,
      child: MessageInfoView(message: message),
    );
    return carry(deps == null ? view : CommunityScope(dependencies: deps, child: view));
  }

  if (MediaQuery.sizeOf(context).width >= _wideLayout) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
          child: content(dialogContext),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85),
      child: content(sheetContext),
    ),
  );
}

class MessageInfoView extends StatefulWidget {
  const MessageInfoView({super.key, required this.message});

  final ChatMessage message;

  @override
  State<MessageInfoView> createState() => _MessageInfoViewState();
}

class _MessageInfoViewState extends State<MessageInfoView> {
  MessageInfo? _info;
  Object? _error;
  bool _loading = true;
  Timer? _debounce;
  StreamSubscription<ChatRoomState>? _receipts;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ChatRoomCubit>();
    var members = cubit.state.members;
    _receipts = cubit.stream.listen((state) {
      if (identical(state.members, members)) return;
      members = state.members;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), _load);
    });
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_receipts?.cancel());
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final info = await context.read<ChatRoomCubit>().messageInfo(widget.message);
      if (!mounted) return;
      setState(() {
        _info = info;
        _error = null;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final type = context.select((ChatRoomCubit c) => c.state.room?.type);
    final details = CommunityMessageInfoDetails(
      message: widget.message,
      isGroup: type != RoomType.direct,
      loading: _loading,
      info: _info,
      error: _error,
      timeLabel: (time) => l10n.messageInfoTime(l10n.dayLabel(time), l10n.clockTime(time)),
      onRetry: () {
        setState(() {
          _loading = true;
          _error = null;
        });
        unawaited(_load());
      },
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).messageInfo,
      context,
      details,
      _DefaultMessageInfo(details: details),
    );
  }
}

class _DefaultMessageInfo extends StatelessWidget {
  const _DefaultMessageInfo({required this.details});

  final CommunityMessageInfoDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final info = d.info;
    final error = d.error;
    final Widget body;
    if (d.loading && info == null) {
      body = const Padding(padding: EdgeInsets.all(24), child: CommunityLoadingView());
    } else if (error != null && info == null) {
      body = CommunityErrorView(error: error, onRetry: d.onRetry);
    } else if (info == null) {
      body = const SizedBox.shrink();
    } else if (!d.isGroup && info.recipients.length <= 1) {
      final recipient = info.recipients.firstOrNull;
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusRow(
            receipt: ReceiptStatus.read,
            label: l10n.messageInfoRead,
            value: _value(l10n, d, recipient?.read ?? false, recipient?.readAt),
          ),
          _StatusRow(
            receipt: ReceiptStatus.delivered,
            label: l10n.messageInfoDelivered,
            value: _value(l10n, d, recipient?.delivered ?? false, recipient?.deliveredAt),
          ),
        ],
      );
    } else {
      final readBy = info.readBy;
      final deliveredOnly = info.deliveredOnly;
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            receipt: ReceiptStatus.read,
            label: l10n.messageInfoReadBy,
            children: [for (final r in readBy) _RecipientTile(recipient: r, value: _value(l10n, d, true, r.readAt))],
          ),
          _Section(
            receipt: ReceiptStatus.delivered,
            label: l10n.messageInfoDeliveredTo,
            children: [
              for (final r in deliveredOnly) _RecipientTile(recipient: r, value: _value(l10n, d, true, r.deliveredAt)),
            ],
          ),
          if (info.pending > 0)
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.md),
              child: Text(
                l10n.messageInfoPending(info.pending),
                style: style.typography.meta.copyWith(color: style.textSecondary),
              ),
            ),
        ],
      );
    }
    return Material(
      color: style.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.xs, spacing.xs),
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.messageInfo, style: style.typography.title)),
                    IconButton(
                      tooltip: l10n.close,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              _MessagePreview(message: d.message, sentAt: info?.sentAt ?? d.message.createdAt, details: d),
              SizedBox(height: spacing.sm),
              body,
            ],
          ),
        ),
      ),
    );
  }

  String _value(CommunityLocalizations l10n, CommunityMessageInfoDetails d, bool done, DateTime? at) {
    if (!done) return l10n.messageInfoNotYet;
    return at == null ? l10n.messageInfoTimeUnknown : d.timeLabel(at);
  }
}

class _MessagePreview extends StatelessWidget {
  const _MessagePreview({required this.message, required this.sentAt, required this.details});

  final ChatMessage message;
  final DateTime sentAt;
  final CommunityMessageInfoDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final text = message.body?.trim() ?? '';
    final image = message.attachments.any((a) => !a.isDocument);
    final document = message.attachments.where((a) => a.isDocument).firstOrNull;
    final summary = text.isNotEmpty
        ? text
        : image
        ? l10n.photo
        : document?.name ?? l10n.attachment;
    final meta = style.typography.meta.copyWith(fontSize: 11, color: t.onMyBubble.withValues(alpha: 0.82));
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.lg),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.xs + spacing.xxs),
        decoration: BoxDecoration(color: t.myBubble, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                summary,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: style.typography.body.copyWith(color: t.onMyBubble),
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(details.timeLabel(sentAt), style: meta),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.receipt, required this.label, required this.value});

  final ReceiptStatus receipt;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return ListTile(
      leading: ReceiptIcon(receipt: receipt, color: style.textSecondary, size: 20),
      title: Text(label, style: style.typography.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: style.typography.meta.copyWith(color: style.textSecondary)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.receipt, required this.label, required this.children});

  final ReceiptStatus receipt;
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xs),
          child: Row(
            children: [
              ReceiptIcon(receipt: receipt, color: style.textSecondary, size: 18),
              SizedBox(width: spacing.sm),
              Text(label, style: style.typography.label.copyWith(color: style.textSecondary)),
            ],
          ),
        ),
        if (children.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.xs),
            child: Text(l10n.messageInfoNotYet, style: style.typography.meta.copyWith(color: style.textTertiary)),
          )
        else
          ...children,
      ],
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({required this.recipient, required this.value});

  final MessageRecipientInfo recipient;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return ListTile(
      dense: true,
      leading: CommunityAvatar(user: recipient.user, radius: style.avatarSizes.small / 2),
      title: Text(recipient.user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.body),
      subtitle: Text(value, style: style.typography.meta.copyWith(color: style.textSecondary)),
    );
  }
}
