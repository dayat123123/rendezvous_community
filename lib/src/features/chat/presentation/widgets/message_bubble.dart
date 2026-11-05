import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/appeals/domain/entities/appeal.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/widgets/community_appeals.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_extras.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/receipt_icon.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/shared_post_card.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/stock_cards.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/link_preview/presentation/widgets/link_preview_card.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/moderation/presentation/widgets/moderation_actions.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_message_parts.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/moderation_notice.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/social_text.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.receipt,
    required this.showSender,
    this.startsGroup = true,
    this.endsGroup = true,
    this.showAvatar = false,
  });

  final ChatMessage message;
  final bool mine;
  final ReceiptStatus? receipt;
  final bool showSender;
  final bool startsGroup;
  final bool endsGroup;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final details = _details(context);
    final fallback = message.isSystem ? SupportSystemNotice(message: message) : _DefaultBubble(details: details);
    return buildChatPart(CommunityChatBuilders.of(context).message, context, details, fallback);
  }

  CommunityMessageDetails _details(BuildContext context) {
    final cubit = context.read<ChatRoomCubit>();
    final m = message;
    final sender = m.sender;
    final support = m.senderRole != null;
    final sent = m.status == MessageStatus.sent && !m.isDeleted && !m.isSystem;
    final reacting =
        sent &&
        !support &&
        !m.isLocal &&
        cubit.state.supportsReactions &&
        context.communityFeature(CommunityFlags.messageReactions);
    final sharedPostId = m.sharedPostId;
    final room = cubit.state;
    final moderating = room.canModerate(m);
    VoidCallback moderate(RoomModerationAction action) =>
        () => runRoomModeration(context, cubit, m, action);
    late final CommunityMessageDetails details;
    details = CommunityMessageDetails(
      message: m,
      isMine: mine,
      receipt: receipt,
      showSender: showSender,
      startsGroup: startsGroup,
      endsGroup: endsGroup,
      showAvatar: showAvatar,
      timeLabel: context.communityL10n.clockTime(m.createdAt),
      onReply: sent ? () => cubit.setReplyTo(m) : null,
      onDelete: sent && mine && !support ? () => _delete(context, cubit) : null,
      onReport: sent && !mine && !support
          ? () => showReportDialog(context, target: ReportTarget.message, targetId: m.id)
          : null,
      onRetry: m.status == MessageStatus.failed ? () => cubit.retry(m) : null,
      onDiscard: m.isLocal && (m.status == MessageStatus.failed || m.status == MessageStatus.pending)
          ? () => cubit.discard(m)
          : null,
      onSenderTap: sender != null && !support && !mine ? () => CommunityNavigator.openUser(context, sender) : null,
      onShowActions: sent ? () => _showActions(context, details) : null,
      reactions: m.reactions,
      reactionChoices: reacting ? context.communityConfig.messageReactions : const [],
      onReact: reacting ? (emoji) => cubit.react(m, emoji) : null,
      onAppeal: mine && m.isHidden && context.communityFeatures != null
          ? () => showCommunityAppealDialog(context, targetType: AppealTargetType.message, targetId: m.id)
          : null,
      onOpenSharedPost: sharedPostId == null ? null : () => CommunityNavigator.openPost(context, sharedPostId),
      senderIsModerator: room.isModerator(m.senderId),
      senderMutedUntil: room.isRoomModerator ? room.memberMutedUntil(m.senderId) : null,
      onHide: moderating ? moderate(RoomModerationAction.hide) : null,
      onMuteSender: moderating ? moderate(RoomModerationAction.mute) : null,
      onEscalate: room.canEscalate(m) ? moderate(RoomModerationAction.escalate) : null,
    );
    return details;
  }

  Future<void> _delete(BuildContext context, ChatRoomCubit cubit) async {
    if (await confirmCommunityAction(context, context.communityL10n.deleteMessageConfirm)) {
      await cubit.deleteMessage(message);
    }
  }

  Future<void> _showActions(BuildContext context, CommunityMessageDetails details) async {
    final l10n = context.communityL10n;
    final onReact = details.onReact;
    final carry = carryCommunityBuilders(context);
    final mutedUntil = details.senderMutedUntil;
    final action = await showModalBottomSheet<VoidCallback>(
      context: context,
      isScrollControlled: details.hasModeration,
      builder: (sheetContext) {
        CommunityMessageAction entry(VoidCallback handler, IconData icon, String label) =>
            CommunityMessageAction(icon: icon, label: label, onSelected: () => Navigator.pop(sheetContext, handler));
        final sheet = CommunityMessageActionsDetails(
          message: details,
          actions: [
            for (final (handler, icon, label) in [
              (details.onReply, Icons.reply, l10n.replyToMessage),
              (details.onDelete, Icons.delete_outline, l10n.delete),
              (details.onReport, Icons.flag_outlined, l10n.report),
            ])
              if (handler != null) entry(handler, icon, label),
          ],
          moderationActions: [
            for (final (handler, icon, label) in [
              (details.onHide, Icons.visibility_off_outlined, l10n.roomModHide),
              (details.onMuteSender, Icons.volume_off_outlined, l10n.roomModMute),
              (details.onEscalate, Icons.outlined_flag, l10n.roomModEscalate),
            ])
              if (handler != null) entry(handler, icon, label),
          ],
          moderationLabel: details.hasModeration ? l10n.roomModeratorBadge : null,
          moderationNote: details.hasModeration && mutedUntil != null
              ? l10n.roomModMemberMuted(roomModerationTime(l10n, mutedUntil))
              : null,
          onReact: onReact == null ? null : (emoji) => Navigator.pop(sheetContext, () => onReact(emoji)),
        );
        return carry(
          Builder(
            builder: (context) => buildChatPart(
              CommunityChatBuilders.of(context).messageActions,
              context,
              sheet,
              _DefaultMessageActions(details: sheet),
            ),
          ),
        );
      },
    );
    if (context.mounted) action?.call();
  }
}

class _DefaultMessageActions extends StatelessWidget {
  const _DefaultMessageActions({required this.details});

  final CommunityMessageActionsDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onReact = details.onReact;
    final moderationLabel = details.moderationLabel;
    final moderationNote = details.moderationNote;
    Widget tile(CommunityMessageAction action) => ListTile(
      leading: Icon(action.icon, color: style.textSecondary),
      title: Text(action.label, style: style.typography.body),
      onTap: action.onSelected,
    );
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReact != null)
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, spacing.xs),
                child: ReactionPicker(
                  choices: details.message.reactionChoices,
                  selected: myReaction(details.message.reactions),
                  onSelected: onReact,
                ),
              ),
            for (final action in details.actions) tile(action),
            if (moderationLabel != null) ...[
              const CommunityDivider(),
              ListTile(
                dense: true,
                leading: Icon(Icons.shield_outlined, color: style.accent),
                title: Text(moderationLabel, style: style.typography.label.copyWith(color: style.accent)),
                subtitle: moderationNote == null ? null : Text(moderationNote, style: style.typography.meta),
              ),
              for (final action in details.moderationActions) tile(action),
            ],
          ],
        ),
      ),
    );
  }
}

const _bubbleRadius = Radius.circular(18);
const _joinRadius = Radius.circular(6);
const _tailRadius = Radius.circular(4);
const _reactionHeight = 24.0;
const _reactionOverlap = 8.0;

final _linkThemes = Expando<(Color, ThemeData)>();

ThemeData _bubbleLinkTheme(ThemeData theme, CommunityTheme t, Color link) {
  final cached = _linkThemes[theme];
  if (cached != null && cached.$1 == link) return cached.$2;
  final next = theme.copyWith(
    extensions: [
      for (final e in theme.extensions.values)
        if (e is! CommunityTheme) e,
      t.copyWith(link: link),
    ],
  );
  _linkThemes[theme] = (link, next);
  return next;
}

class _DefaultBubble extends StatefulWidget {
  const _DefaultBubble({required this.details});

  final CommunityMessageDetails details;

  @override
  State<_DefaultBubble> createState() => _DefaultBubbleState();
}

class _DefaultBubbleState extends State<_DefaultBubble> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.details;
    final m = d.message;
    final support = m.senderRole != null;
    final l10n = context.communityL10n;
    final theme = Theme.of(context);
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final bg = d.isMine ? t.myBubble : t.otherBubble;
    final fg = d.isMine ? t.onMyBubble : t.onOtherBubble;
    final line = chatReadableOn(t.link, bg) ? t.link : fg;
    final metaColor = fg.withValues(alpha: 0.82);
    final meta = style.typography.meta.copyWith(fontSize: 11, height: 1.2, color: metaColor);
    final body = style.typography.body.copyWith(color: fg, height: 1.4);
    final width = MediaQuery.sizeOf(context).width * 0.72;
    final maxWidth = width > 520 ? 520.0 : width;
    final senderColor = m.sender == null ? line : chatSenderColor(m.senderId ?? '', bg, fallback: line);
    final senderStyle = style.typography.label.copyWith(color: senderColor, fontWeight: FontWeight.w700);
    final top = d.startsGroup ? _bubbleRadius : _joinRadius;
    final bottom = d.endsGroup ? _tailRadius : _joinRadius;
    final images = [
      for (final a in m.attachments)
        if (!a.isDocument) a,
    ];
    final documents = [
      for (final a in m.attachments)
        if (a.isDocument) a,
    ];
    final text = m.body ?? '';
    final extras = !m.isDeleted && (m.kind == MessageKind.quickReply || m.kind == MessageKind.helpLink);
    final mediaOnly =
        !m.isDeleted &&
        images.isNotEmpty &&
        documents.isEmpty &&
        text.isEmpty &&
        m.sharedPostId == null &&
        m.stockCodes.isEmpty &&
        m.replyToId == null &&
        !(d.showSender && m.sender != null) &&
        !extras;
    final inset = mediaOnly ? spacing.xs : spacing.md;

    final metaRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (m.editedAt != null && !m.isDeleted) Text('${l10n.edited} ', style: meta),
        Text(d.timeLabel, style: meta),
        if (d.isMine) ...[
          SizedBox(width: spacing.xxs + 1),
          ReceiptIcon(
            receipt: d.receipt,
            sendStatus: m.status,
            color: metaColor,
            size: 15,
            readColor: chatReadableOn(t.readReceipt, bg, minimum: 3) ? null : fg,
          ),
        ],
      ],
    );

    Widget? message;
    if (m.isDeleted) {
      message = Text(
        l10n.messageDeleted,
        style: body.copyWith(fontStyle: FontStyle.italic, color: fg.withValues(alpha: 0.8)),
      );
    } else if (text.isNotEmpty) {
      message = support
          ? SelectableText(text, style: body)
          : line == t.link
          ? SocialText(text, style: body, source: 'chat')
          : Theme(
              data: _bubbleLinkTheme(theme, t, line),
              child: SocialText(text, style: body, source: 'chat'),
            );
    }

    final sender = m.sender;
    final content = <Widget>[
      if (d.showSender && sender != null)
        Padding(
          padding: EdgeInsets.only(bottom: spacing.xxs),
          child: m.isOfficial
              ? OfficialSenderLabel(sender: sender, color: line)
              : d.senderIsModerator
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: d.onSenderTap,
                        child: Text(sender.name, style: senderStyle, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    RoomModeratorBadge(color: senderColor),
                  ],
                )
              : GestureDetector(
                  onTap: d.onSenderTap,
                  child: Text(sender.name, style: senderStyle),
                ),
        ),
      if (m.replyToId != null)
        Container(
          margin: EdgeInsets.only(top: spacing.xxs, bottom: spacing.xs + spacing.xxs),
          padding: EdgeInsets.fromLTRB(spacing.sm + spacing.xxs, spacing.xs + spacing.xxs, spacing.sm, spacing.xs + 2),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: d.isMine ? 0.14 : 0.06),
            border: Border(left: BorderSide(color: line, width: 3)),
            borderRadius: style.radii.controlRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (m.replyToSenderUsername != null)
                Text(
                  '@${m.replyToSenderUsername}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.typography.label.copyWith(color: line, fontWeight: FontWeight.w700),
                ),
              Text(
                m.replyToBody ?? l10n.messageDeleted,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: style.typography.meta.copyWith(color: fg.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      if (!m.isDeleted) ...[
        if (images.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: mediaOnly ? spacing.xs : spacing.xs + spacing.xxs),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_bubbleRadius.x - inset),
              child: AttachmentGrid(attachments: images, maxHeight: 220),
            ),
          ),
        if (documents.isNotEmpty) DocumentAttachments(attachments: documents, color: fg),
        if (m.sharedPostId != null)
          SharedPostCard(postId: m.sharedPostId!, sharedPost: m.sharedPost, color: fg, onOpen: d.onOpenSharedPost),
        if (m.stockCodes.isNotEmpty) StockCards(codes: m.stockCodes, isMine: d.isMine),
        if (!support && text.isNotEmpty)
          LinkPreviewCard(
            text: text,
            margin: EdgeInsets.only(bottom: spacing.xs + spacing.xxs),
          ),
      ],
    ];

    final inline = message != null && !extras;
    if (inline) {
      content.add(
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: spacing.sm,
          children: [
            message,
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs),
              child: metaRow,
            ),
          ],
        ),
      );
    } else {
      if (message != null) content.add(message);
      if (extras) content.add(SupportMessageExtras(message: m, color: fg, mine: d.isMine));
    }

    final reactionsDefault = CommunityChatBuilders.of(context).reactions == null;
    final overlayReactions = d.reactions.isNotEmpty && reactionsDefault;
    final minWidth = overlayReactions ? d.reactions.length * 52.0 + spacing.xl : 0.0;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth > maxWidth ? maxWidth : minWidth),
      padding: mediaOnly
          ? EdgeInsets.all(inset)
          : EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.xs + spacing.xxs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: d.isMine ? _bubbleRadius : top,
          topRight: d.isMine ? top : _bubbleRadius,
          bottomLeft: d.isMine ? _bubbleRadius : bottom,
          bottomRight: d.isMine ? bottom : _bubbleRadius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: content),
          if (!inline)
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs, right: mediaOnly ? spacing.xs : 0),
              child: metaRow,
            ),
          if (d.isMine && !m.isDeleted)
            ModerationNotice(status: m.moderationStatus, compact: true, color: fg, onAppeal: d.onAppeal),
        ],
      ),
    );

    final reactionInset = _reactionHeight - _reactionOverlap;
    final Widget decorated;
    if (overlayReactions) {
      decorated = Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: reactionInset),
            child: bubble,
          ),
          Positioned(
            bottom: 0,
            left: d.isMine ? null : spacing.md,
            right: d.isMine ? spacing.md : null,
            child: ReactionChips(reactions: d.reactions, onReact: d.onReact, isMine: d.isMine),
          ),
        ],
      );
    } else if (d.reactions.isNotEmpty) {
      decorated = Column(
        crossAxisAlignment: d.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubble,
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: ReactionChips(reactions: d.reactions, onReact: d.onReact, isMine: d.isMine),
          ),
        ],
      );
    } else {
      decorated = bubble;
    }

    final actions = _hovered && (d.onReply != null || d.onDelete != null || d.onReact != null)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (d.onReact != null)
                PopupMenuButton<String>(
                  tooltip: l10n.reactionAdd,
                  iconSize: 18,
                  iconColor: style.textSecondary,
                  icon: const Icon(Icons.add_reaction_outlined),
                  onSelected: d.onReact,
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: ReactionPicker(
                        choices: d.reactionChoices,
                        selected: myReaction(d.reactions),
                        onSelected: (emoji) {
                          Navigator.pop(context);
                          d.onReact!(emoji);
                        },
                      ),
                    ),
                  ],
                ),
              if (d.onReply != null)
                IconButton(
                  tooltip: l10n.replyToMessage,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: style.textSecondary,
                  onPressed: d.onReply,
                  icon: const Icon(Icons.reply),
                ),
              if (d.onDelete != null)
                IconButton(
                  tooltip: l10n.delete,
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: style.textSecondary,
                  onPressed: d.onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          )
        : const SizedBox(width: 108);

    final avatarSize = style.avatarSizes.small;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Padding(
        padding: EdgeInsets.only(top: d.startsGroup ? spacing.sm + spacing.xxs : spacing.xxs),
        child: Row(
          mainAxisAlignment: d.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (d.isMine) actions,
            if (d.showAvatar && !d.isMine) ...[
              Padding(
                padding: EdgeInsets.only(bottom: overlayReactions ? reactionInset : 0),
                child: SizedBox.square(
                  dimension: avatarSize,
                  child: d.endsGroup ? CommunityAvatar(user: sender, radius: avatarSize / 2) : null,
                ),
              ),
              SizedBox(width: spacing.sm),
            ],
            Flexible(
              child: GestureDetector(
                onTap: d.onRetry,
                onLongPress: d.onShowActions,
                child: Column(
                  crossAxisAlignment: d.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    decorated,
                    if (m.status == MessageStatus.pending || m.status == MessageStatus.failed)
                      MessageDeliveryNotice(details: d),
                  ],
                ),
              ),
            ),
            if (!d.isMine) actions,
          ],
        ),
      ),
    );
  }
}

class MessageDeliveryNotice extends StatelessWidget {
  const MessageDeliveryNotice({super.key, required this.details});

  final CommunityMessageDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final message = details.message;
    final failed = message.status == MessageStatus.failed;
    final error = message.sendError;
    final notice = CommunityDeliveryNoticeDetails(
      message: message,
      isMine: details.isMine,
      failed: failed,
      label: failed ? l10n.messageFailed : l10n.messagePending,
      errorLabel: failed && error != null ? l10n.errorMessage(error) : null,
      onRetry: details.onRetry,
      onDiscard: details.onDiscard,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).deliveryNotice,
      context,
      notice,
      _DefaultDeliveryNotice(details: notice),
    );
  }
}

class _DefaultDeliveryNotice extends StatelessWidget {
  const _DefaultDeliveryNotice({required this.details});

  final CommunityDeliveryNoticeDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final error = Theme.of(context).colorScheme.error;
    final text = style.typography.meta.copyWith(fontSize: 12, color: details.failed ? error : style.textSecondary);
    final errorLabel = details.errorLabel;
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: style.accent,
      textStyle: style.typography.label,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      minimumSize: const Size(0, 32),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Padding(
      padding: EdgeInsets.only(top: spacing.xxs),
      child: Column(
        crossAxisAlignment: details.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                details.failed ? Icons.error_outline : Icons.cloud_upload_outlined,
                size: 14,
                color: details.failed ? error : style.textSecondary,
              ),
              SizedBox(width: spacing.xs),
              Text(details.label, style: text),
            ],
          ),
          if (errorLabel != null) Text(errorLabel, style: text),
          if (details.onRetry != null || details.onDiscard != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (details.onRetry != null)
                  TextButton(style: buttonStyle, onPressed: details.onRetry, child: Text(l10n.retry)),
                if (details.onDiscard != null)
                  TextButton(
                    style: buttonStyle.copyWith(foregroundColor: WidgetStatePropertyAll(style.textSecondary)),
                    onPressed: details.onDiscard,
                    child: Text(l10n.delete),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ReactionPicker extends StatelessWidget {
  const ReactionPicker({super.key, required this.choices, required this.onSelected, this.selected});

  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final details = CommunityReactionPickerDetails(choices: choices, selected: selected, onSelected: onSelected);
    return buildChatPart(
      CommunityChatBuilders.of(context).reactionPicker,
      context,
      details,
      _DefaultReactionPicker(details: details),
    );
  }
}

class _DefaultReactionPicker extends StatelessWidget {
  const _DefaultReactionPicker({required this.details});

  final CommunityReactionPickerDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Wrap(
      spacing: style.spacing.xs,
      alignment: WrapAlignment.center,
      children: [
        for (final emoji in details.choices)
          Semantics(
            button: true,
            selected: emoji == details.selected,
            child: InkResponse(
              radius: style.minTouchTarget / 2,
              onTap: () => details.onSelected(emoji),
              child: SizedBox.square(
                dimension: style.minTouchTarget,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emoji == details.selected ? style.accentMuted : null,
                    border: emoji == details.selected
                        ? Border.all(color: style.accent.withValues(alpha: 0.4), width: style.borderWidth)
                        : null,
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ReactionChips extends StatelessWidget {
  const ReactionChips({super.key, required this.reactions, this.onReact, this.isMine = false});

  final List<MessageReaction> reactions;
  final ValueChanged<String>? onReact;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final details = CommunityReactionsDetails(reactions: reactions, isMine: isMine, onReact: onReact);
    return buildChatPart(
      CommunityChatBuilders.of(context).reactions,
      context,
      details,
      _DefaultReactionChips(details: details),
    );
  }
}

class _DefaultReactionChips extends StatelessWidget {
  const _DefaultReactionChips({required this.details});

  final CommunityReactionsDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onReact = details.onReact;
    final label = style.typography.label.copyWith(fontSize: 12, height: 1.2);
    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        for (final r in details.reactions)
          Material(
            color: r.mine ? style.accentMuted : style.surface,
            shape: StadiumBorder(
              side: BorderSide(
                color: r.mine ? style.accent.withValues(alpha: 0.5) : style.border,
                width: style.borderWidth,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onReact == null ? null : () => onReact(r.emoji),
              child: SizedBox(
                height: _reactionHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      '${r.emoji} ${r.count}',
                      style: label.copyWith(color: r.mine ? style.accent : style.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
