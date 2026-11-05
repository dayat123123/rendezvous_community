import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_moderation.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/chat_room_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class RoomModerationInput {
  const RoomModerationInput({required this.reason, this.duration, this.note});

  final ReportReason reason;
  final Duration? duration;
  final String? note;
}

String roomModerationTime(CommunityLocalizations l10n, DateTime time, {DateTime? now}) {
  final local = time.toLocal();
  final current = (now ?? DateTime.now()).toLocal();
  final sameDay = local.year == current.year && local.month == current.month && local.day == current.day;
  return sameDay ? l10n.clockTime(time) : '${DateFormat.MMMd(l10n.localeName).format(local)} ${l10n.clockTime(time)}';
}

String roomMuteDurationLabel(CommunityLocalizations l10n, Duration duration) =>
    duration.inMinutes < 60 ? l10n.roomModMinutes(duration.inMinutes) : l10n.roomModHours(duration.inHours);

String reportReasonLabel(CommunityLocalizations l10n, ReportReason reason) => switch (reason) {
  ReportReason.spam => l10n.reasonSpam,
  ReportReason.abuse => l10n.reasonAbuse,
  ReportReason.scam => l10n.reasonScam,
  ReportReason.pumpAndDump => l10n.reasonPumpAndDump,
  ReportReason.misinformation => l10n.reasonMisinformation,
  ReportReason.other => l10n.reasonOther,
};

Future<void> runRoomModeration(
  BuildContext context,
  ChatRoomCubit cubit,
  ChatMessage message,
  RoomModerationAction action,
) async {
  final l10n = context.communityL10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final name = message.sender?.name ?? l10n.someone;
  final carry = carryCommunityBuilders(context);
  final input = await showDialog<RoomModerationInput>(
    context: context,
    builder: (_) => carry(RoomModerationDialog(action: action, memberName: name)),
  );
  if (input == null) return;
  void notify(String text) => messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
  switch (action) {
    case RoomModerationAction.hide:
      if (await cubit.hideMessage(message, input.reason, note: input.note)) notify(l10n.roomModHidden);
    case RoomModerationAction.mute:
      final result = await cubit.muteMember(
        message,
        input.duration ?? roomMuteDurations.first,
        input.reason,
        note: input.note,
      );
      final until = result?.muteUntil ?? cubit.state.memberMutedUntil(message.senderId);
      if (result != null && until != null) notify(l10n.roomModMuted(name, roomModerationTime(l10n, until)));
    case RoomModerationAction.escalate:
      if (await cubit.escalateMessage(message, input.reason, note: input.note)) notify(l10n.roomModEscalated);
  }
}

class RoomModerationDialog extends StatefulWidget {
  const RoomModerationDialog({super.key, required this.action, required this.memberName});

  final RoomModerationAction action;
  final String memberName;

  @override
  State<RoomModerationDialog> createState() => _RoomModerationDialogState();
}

class _RoomModerationDialogState extends State<RoomModerationDialog> {
  ReportReason _reason = ReportReason.spam;
  Duration _duration = roomMuteDurations[1];
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _note.text.trim();
    Navigator.pop(
      context,
      RoomModerationInput(
        reason: _reason,
        duration: widget.action == RoomModerationAction.mute ? _duration : null,
        note: note.isEmpty ? null : note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final mute = widget.action == RoomModerationAction.mute;
    final (title, body, confirm) = switch (widget.action) {
      RoomModerationAction.hide => (l10n.roomModHideTitle, l10n.roomModHideBody, l10n.roomModHide),
      RoomModerationAction.mute => (l10n.roomModMuteTitle(widget.memberName), l10n.roomModMuteBody, l10n.roomModMute),
      RoomModerationAction.escalate => (l10n.roomModEscalateTitle, l10n.roomModEscalateBody, l10n.roomModEscalate),
    };
    final details = CommunityRoomModerationDialogDetails(
      action: widget.action,
      memberName: widget.memberName,
      title: title,
      body: body,
      confirmLabel: confirm,
      cancelLabel: l10n.cancel,
      reasonLabel: l10n.roomModReason,
      reasons: [
        for (final r in ReportReason.values) CommunitySettingsOption(value: r, label: reportReasonLabel(l10n, r)),
      ],
      reason: _reason,
      noteController: _note,
      noteHint: l10n.roomModNoteHint,
      onReasonChanged: (r) => setState(() => _reason = r),
      onSubmit: _submit,
      onCancel: () => Navigator.pop(context),
      durationLabel: mute ? l10n.roomModDuration : null,
      durations: mute
          ? [
              for (final d in roomMuteDurations)
                CommunitySettingsOption(value: d, label: roomMuteDurationLabel(l10n, d)),
            ]
          : const [],
      duration: mute ? _duration : null,
      onDurationChanged: mute ? (d) => setState(() => _duration = d) : null,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).moderationDialog,
      context,
      details,
      _DefaultModerationDialog(details: details),
    );
  }
}

class _DefaultModerationDialog extends StatelessWidget {
  const _DefaultModerationDialog({required this.details});

  final CommunityRoomModerationDialogDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final scheme = Theme.of(context).colorScheme;
    final durationLabel = d.durationLabel;
    final onDurationChanged = d.onDurationChanged;
    return AlertDialog(
      backgroundColor: style.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(style.radii.card * 2)),
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.body, style: style.typography.meta),
              if (durationLabel != null && onDurationChanged != null) ...[
                SizedBox(height: spacing.lg),
                Text(durationLabel, style: style.typography.label.copyWith(color: style.textPrimary)),
                SizedBox(height: spacing.sm),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  children: [
                    for (final option in d.durations)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: option.value == d.duration,
                        showCheckmark: false,
                        shape: const StadiumBorder(),
                        side: option.value == d.duration ? BorderSide(color: style.accent) : style.borderSide,
                        backgroundColor: style.chip,
                        selectedColor: style.accentMuted,
                        labelStyle: style.typography.label.copyWith(
                          color: option.value == d.duration ? style.accent : style.onChip,
                        ),
                        onSelected: (_) => onDurationChanged(option.value),
                      ),
                  ],
                ),
              ],
              SizedBox(height: spacing.lg),
              Text(d.reasonLabel, style: style.typography.label.copyWith(color: style.textPrimary)),
              RadioGroup<ReportReason>(
                groupValue: d.reason,
                onChanged: (r) {
                  if (r != null) d.onReasonChanged(r);
                },
                child: Column(
                  children: [
                    for (final option in d.reasons)
                      RadioListTile<ReportReason>(
                        value: option.value,
                        title: Text(option.label, style: style.typography.body.copyWith(fontSize: 14)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              TextField(
                controller: d.noteController,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: d.noteHint,
                  border: OutlineInputBorder(borderRadius: style.radii.controlRadius),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: d.onCancel,
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          child: Text(d.cancelLabel),
        ),
        FilledButton(
          style: d.destructive
              ? style.primaryButtonStyle().copyWith(
                  backgroundColor: WidgetStatePropertyAll(scheme.error),
                  foregroundColor: WidgetStatePropertyAll(scheme.onError),
                )
              : style.primaryButtonStyle(),
          onPressed: d.onSubmit,
          child: Text(d.confirmLabel),
        ),
      ],
    );
  }
}

class RoomModeratorBadge extends StatelessWidget {
  const RoomModeratorBadge({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = context.communityL10n.roomModeratorBadge;
    final accent = color ?? theme.colorScheme.primary;
    final details = CommunityLabelBadgeDetails(
      kind: CommunityBadgeKind.roomModerator,
      label: label,
      icon: Icons.shield_outlined,
      foreground: accent,
      background: accent.withValues(alpha: 0.12),
    );
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: buildLabelBadge(context, details, _DefaultModeratorBadge(details: details)),
    );
  }
}

class _DefaultModeratorBadge extends StatelessWidget {
  const _DefaultModeratorBadge({required this.details});

  final CommunityLabelBadgeDetails details;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(color: details.background, borderRadius: BorderRadius.circular(6)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(details.icon, size: 11, color: details.foreground),
        const SizedBox(width: 2),
        Text(
          details.label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: details.foreground, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class RoomModerationBanner extends StatelessWidget {
  const RoomModerationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.select((ChatRoomCubit c) => c.state);
    if (!state.isStockRoom) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final muted = state.mutedUntil();
    final CommunityRoomModerationDetails details;
    if (muted != null) {
      details = CommunityRoomModerationDetails(
        kind: CommunityRoomModerationKind.muted,
        icon: Icons.volume_off_outlined,
        message: l10n.roomMutedBanner(roomModerationTime(l10n, muted)),
        mutedUntil: muted,
      );
    } else if (state.isRoomModerator) {
      details = CommunityRoomModerationDetails(
        kind: CommunityRoomModerationKind.moderator,
        icon: Icons.shield_outlined,
        message: l10n.roomModeratorNotice,
      );
    } else {
      return const SizedBox.shrink();
    }
    return buildChatPart(
      CommunityChatBuilders.of(context).moderationBanner,
      context,
      details,
      ChatStrip(
        icon: details.icon,
        message: details.message,
        tone: details.kind == CommunityRoomModerationKind.muted
            ? Theme.of(context).colorScheme.error
            : CommunityStyle.of(context).accent,
      ),
    );
  }
}
