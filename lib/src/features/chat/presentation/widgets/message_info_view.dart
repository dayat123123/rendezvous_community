import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_info.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/receipt_icon.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/attachment_grid.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/image_viewer.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_selectable.dart';

const _wideLayout = 600.0;
const _panelWidth = 320.0;
const _gap = 12.0;
const _edge = 8.0;

Future<void> showCommunityMessageInfo(BuildContext context, ChatMessage message, {Rect? anchor}) {
  final cubit = context.read<ChatRoomCubit>();
  final carry = carryCommunityBuilders(context);
  final deps = CommunityScope.maybeOf(context);
  final loader = CommunityImageScope.of(context);
  final persist = CommunityImagePersistence.of(context);
  Widget content({required bool anchored}) {
    final view = CommunityImageScope(
      loader: loader,
      child: CommunityImagePersistence(
        persist: persist,
        child: BlocProvider.value(
          value: cubit,
          child: MessageInfoView(message: message, anchored: anchored),
        ),
      ),
    );
    return carry(deps == null ? view : CommunityScope(dependencies: deps, child: view));
  }

  if (MediaQuery.sizeOf(context).width >= _wideLayout) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (dialogContext, _, _) => CustomSingleChildLayout(
        delegate: _PopoverLayout(target: anchor, padding: MediaQuery.paddingOf(dialogContext)),
        child: content(anchored: true),
      ),
    );
  }
  final title = context.communityL10n.messageInfo;
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: content(anchored: false),
      ),
    ),
  );
}

class _PopoverLayout extends SingleChildLayoutDelegate {
  const _PopoverLayout({required this.target, required this.padding});

  final Rect? target;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final width = (constraints.maxWidth - _edge * 2).clamp(0.0, _panelWidth);
    final height = (constraints.maxHeight - padding.vertical - _edge * 2).clamp(0.0, 560.0);
    return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: height);
  }

  @override
  Offset getPositionForChild(Size size, Size child) {
    final minX = _edge + padding.left;
    final maxX = size.width - child.width - _edge - padding.right;
    final minY = _edge + padding.top;
    final maxY = size.height - child.height - _edge - padding.bottom;
    final rect = target;
    if (rect == null) {
      return Offset(
        ((size.width - child.width) / 2).clamp(minX, maxX),
        ((size.height - child.height) / 2).clamp(minY, maxY),
      );
    }
    final left = rect.left - _gap - child.width;
    final right = rect.right + _gap;
    final preferLeft = rect.center.dx > size.width / 2;
    final fitsLeft = left >= minX;
    final fitsRight = right <= maxX;
    final x = preferLeft ? (fitsLeft || !fitsRight ? left : right) : (fitsRight || !fitsLeft ? right : left);
    final y = rect.center.dy - child.height / 2;
    return Offset(x.clamp(minX, maxX < minX ? minX : maxX), y.clamp(minY, maxY < minY ? minY : maxY));
  }

  @override
  bool shouldRelayout(_PopoverLayout oldDelegate) => target != oldDelegate.target || padding != oldDelegate.padding;
}

class MessageInfoView extends StatefulWidget {
  const MessageInfoView({super.key, required this.message, this.anchored = false});

  final ChatMessage message;
  final bool anchored;

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
      anchored: widget.anchored,
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
    final recipient = info?.recipients.firstOrNull;
    final direct = !d.isGroup && (info?.recipients.length ?? 0) <= 1;
    final sections = <Widget>[
      if (direct) ...[
        _InfoSection(
          receipt: ReceiptStatus.read,
          label: l10n.messageInfoRead,
          child: _timeOrDots(l10n, d, recipient?.read ?? false, recipient?.readAt, style),
        ),
        SizedBox(height: spacing.lg),
        _InfoSection(
          receipt: ReceiptStatus.delivered,
          label: l10n.messageInfoDelivered,
          child: _timeOrDots(l10n, d, recipient?.delivered ?? false, recipient?.deliveredAt, style),
        ),
      ] else ...[
        _InfoSection(
          receipt: ReceiptStatus.read,
          label: l10n.messageInfoReadBy,
          child: _people(l10n, d, info?.readBy ?? const [], read: true),
        ),
        SizedBox(height: spacing.lg),
        _InfoSection(
          receipt: ReceiptStatus.delivered,
          label: l10n.messageInfoDeliveredTo,
          child: _people(l10n, d, info?.deliveredOnly ?? const [], read: false),
        ),
        if ((info?.pending ?? 0) > 0)
          Padding(
            padding: EdgeInsets.only(top: spacing.md),
            child: Text(
              l10n.messageInfoPending(info!.pending),
              style: style.typography.meta.copyWith(color: style.textSecondary),
            ),
          ),
      ],
      if (error != null && info == null)
        Padding(
          padding: EdgeInsets.only(top: spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.messageInfoFailed, style: style.typography.meta.copyWith(color: style.textSecondary)),
              ),
              TextButton(onPressed: d.onRetry, child: Text(l10n.retry)),
            ],
          ),
        ),
    ];
    if (!d.anchored) return _InfoPage(details: d, direct: direct);
    final body = Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: sections),
    );
    return Material(
      color: Color.alphaBlend(style.textPrimary.withValues(alpha: 0.035), style.surface),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: style.divider, width: style.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: CommunitySelectable(child: SingleChildScrollView(child: body)),
    );
  }

  Widget _timeOrDots(
    CommunityLocalizations l10n,
    CommunityMessageInfoDetails d,
    bool done,
    DateTime? at,
    CommunityStyle style,
  ) {
    if (!done) return const _Dots();
    return Center(
      child: Text(
        at == null ? l10n.messageInfoTimeUnknown : d.timeLabel(at),
        style: style.typography.body.copyWith(color: style.textPrimary),
      ),
    );
  }

  Widget _people(
    CommunityLocalizations l10n,
    CommunityMessageInfoDetails d,
    List<MessageRecipientInfo> people, {
    required bool read,
  }) {
    if (people.isEmpty) return const _Dots();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final person in people)
          _RecipientRow(
            recipient: person,
            value: (read ? person.readAt : person.deliveredAt) == null
                ? l10n.messageInfoTimeUnknown
                : d.timeLabel((read ? person.readAt : person.deliveredAt)!),
          ),
      ],
    );
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
    final images = [
      for (final a in message.attachments)
        if (!a.isDocument) a,
    ];
    final documents = [
      for (final a in message.attachments)
        if (a.isDocument) a,
    ];
    final summary = text.isNotEmpty
        ? text
        : images.isEmpty && documents.isEmpty
        ? l10n.attachment
        : null;
    final meta = style.typography.meta.copyWith(fontSize: 11, color: t.onMyBubble.withValues(alpha: 0.82));
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.lg),
        constraints: const BoxConstraints(maxWidth: 320),
        padding: EdgeInsets.fromLTRB(
          images.isEmpty ? spacing.md : spacing.xs,
          images.isEmpty ? spacing.sm : spacing.xs,
          images.isEmpty ? spacing.md : spacing.xs,
          spacing.xs + spacing.xxs,
        ),
        decoration: BoxDecoration(color: t.myBubble, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (images.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AttachmentGrid(
                  attachments: images,
                  maxHeight: 240,
                  onOpen: (index) => unawaited(
                    showCommunityImageViewer(
                      context,
                      images: images,
                      initialIndex: index,
                      sender: message.sender,
                      sentAt: message.createdAt,
                    ),
                  ),
                ),
              ),
            if (documents.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: images.isEmpty ? 0 : spacing.xs),
                child: DocumentAttachments(attachments: documents, color: t.onMyBubble),
              ),
            if (summary != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  images.isEmpty ? 0 : spacing.sm,
                  images.isEmpty && documents.isEmpty ? 0 : spacing.xs,
                  images.isEmpty ? 0 : spacing.sm,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    summary,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: style.typography.body.copyWith(color: t.onMyBubble),
                  ),
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.receipt, required this.label, required this.child});

  final ReceiptStatus receipt;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: spacing.xs, bottom: spacing.sm),
          child: Row(
            children: [
              ReceiptIcon(receipt: receipt, color: style.textSecondary, size: 18),
              SizedBox(width: spacing.sm),
              Text(
                label.toUpperCase(),
                style: style.typography.label.copyWith(
                  color: style.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(color: style.pill, borderRadius: BorderRadius.circular(22)),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    final color = CommunityStyle.of(context).textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.4),
            ),
          ),
      ],
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({required this.recipient, required this.value});

  final MessageRecipientInfo recipient;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        children: [
          CommunityAvatar(user: recipient.user, radius: 14),
          SizedBox(width: spacing.sm + spacing.xxs),
          Expanded(
            child: Text(
              recipient.user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.typography.body.copyWith(color: style.textPrimary),
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(value, style: style.typography.meta.copyWith(color: style.textSecondary)),
        ],
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.details, required this.direct});

  final CommunityMessageInfoDetails details;
  final bool direct;

  String _time(CommunityLocalizations l10n, bool done, DateTime? at) {
    if (!done) return l10n.messageInfoNotYet;
    return at == null ? l10n.messageInfoTimeUnknown : details.timeLabel(at);
  }

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final info = d.info;
    final recipient = info?.recipients.firstOrNull;
    final loading = d.loading && info == null;
    final List<Widget> rows;
    if (direct) {
      rows = [
        _PageStatus(
          receipt: ReceiptStatus.read,
          label: l10n.messageInfoRead,
          value: loading ? null : _time(l10n, recipient?.read ?? false, recipient?.readAt),
        ),
        _PageDivider(indent: spacing.lg + 40),
        _PageStatus(
          receipt: ReceiptStatus.delivered,
          label: l10n.messageInfoDelivered,
          value: loading ? null : _time(l10n, recipient?.delivered ?? false, recipient?.deliveredAt),
        ),
      ];
    } else {
      final readBy = info?.readBy ?? const <MessageRecipientInfo>[];
      final delivered = info?.deliveredOnly ?? const <MessageRecipientInfo>[];
      rows = [
        _PageHeader(receipt: ReceiptStatus.read, label: l10n.messageInfoReadBy),
        if (loading || readBy.isEmpty)
          _PageEmpty(loading: loading)
        else
          for (final person in readBy) _PagePerson(person: person, value: _time(l10n, true, person.readAt)),
        _PageDivider(indent: 0),
        _PageHeader(receipt: ReceiptStatus.delivered, label: l10n.messageInfoDeliveredTo),
        if (loading || delivered.isEmpty)
          _PageEmpty(loading: loading)
        else
          for (final person in delivered) _PagePerson(person: person, value: _time(l10n, true, person.deliveredAt)),
        if ((info?.pending ?? 0) > 0) ...[
          _PageDivider(indent: 0),
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
            child: Text(
              l10n.messageInfoPending(info!.pending),
              style: style.typography.meta.copyWith(color: style.textSecondary),
            ),
          ),
        ],
      ];
    }
    return ColoredBox(
      color: style.background,
      child: CommunitySelectable(
        child: ListView(
          padding: EdgeInsets.only(top: spacing.lg, bottom: spacing.xl),
          children: [
            _MessagePreview(message: d.message, sentAt: info?.sentAt ?? d.message.createdAt, details: d),
            SizedBox(height: spacing.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.md),
              child: Material(
                color: style.surface,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
              ),
            ),
            if (d.error != null && info == null)
              Padding(
                padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.md, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.messageInfoFailed,
                        style: style.typography.meta.copyWith(color: style.textSecondary),
                      ),
                    ),
                    TextButton(onPressed: d.onRetry, child: Text(l10n.retry)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PageStatus extends StatelessWidget {
  const _PageStatus({required this.receipt, required this.label, required this.value});

  final ReceiptStatus receipt;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final text = value;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: ReceiptIcon(receipt: receipt, color: style.textSecondary, size: 20),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: style.typography.body.copyWith(color: style.textPrimary, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: spacing.xxs),
                if (text == null)
                  const Align(alignment: Alignment.centerLeft, child: _Dots())
                else
                  Text(text, style: style.typography.meta.copyWith(color: style.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.receipt, required this.label});

  final ReceiptStatus receipt;
  final String label;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: style.typography.label.copyWith(color: style.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ReceiptIcon(receipt: receipt, color: style.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _PagePerson extends StatelessWidget {
  const _PagePerson({required this.person, required this.value});

  final MessageRecipientInfo person;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      child: Row(
        children: [
          CommunityAvatar(user: person.user, radius: 20),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.typography.body.copyWith(color: style.textPrimary),
                ),
                Text(value, style: style.typography.meta.copyWith(color: style.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageEmpty extends StatelessWidget {
  const _PageEmpty({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xs, spacing.lg, spacing.md),
      child: loading
          ? const Align(alignment: Alignment.centerLeft, child: _Dots())
          : Text(
              context.communityL10n.messageInfoNotYet,
              style: style.typography.meta.copyWith(color: style.textTertiary),
            ),
    );
  }
}

class _PageDivider extends StatelessWidget {
  const _PageDivider({required this.indent});

  final double indent;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Divider(height: 1, thickness: style.borderWidth, indent: indent, color: style.divider);
  }
}
