import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

String roomTitle(ChatRoom room) => switch (room.type) {
  RoomType.direct => room.otherUser?.name ?? '',
  RoomType.group || RoomType.support => room.name ?? '',
  RoomType.stock => '\$${room.stockCode}',
};

class CommunityRoomAvatar extends StatelessWidget {
  const CommunityRoomAvatar({super.key, required this.room, this.online = false, this.radius = 20});

  final ChatRoom room;
  final bool online;
  final double radius;

  @override
  Widget build(BuildContext context) => roomAvatar(context, room, online: online, radius: radius);
}

Widget roomAvatar(BuildContext context, ChatRoom room, {bool online = false, double radius = 20}) {
  final details = CommunityRoomAvatarDetails(room: room, radius: radius, online: online);
  return buildChatPart(
    CommunityChatBuilders.of(context).roomAvatar,
    context,
    details,
    _DefaultRoomAvatar(details: details),
  );
}

class _DefaultRoomAvatar extends StatelessWidget {
  const _DefaultRoomAvatar({required this.details});

  final CommunityRoomAvatarDetails details;

  @override
  Widget build(BuildContext context) {
    final room = details.room;
    final radius = details.radius;
    if (room.type == RoomType.direct) {
      return CommunityAvatar(user: room.otherUser, online: details.online, radius: radius);
    }
    final style = CommunityStyle.of(context);
    final (icon, background, foreground) = switch (room.type) {
      RoomType.stock => (Icons.show_chart, style.accentMuted, style.accent),
      RoomType.support => (Icons.support_agent, style.accent, style.onAccent),
      _ => (Icons.group_outlined, style.pill, style.textSecondary),
    };
    return SizedBox.square(
      dimension: radius * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: radius, color: foreground),
      ),
    );
  }
}

Color chatSoftTone(CommunityStyle style, Color color, {double alpha = 0.12}) =>
    Color.alphaBlend(color.withValues(alpha: alpha), style.surface);

class ChatStrip extends StatelessWidget {
  const ChatStrip({
    super.key,
    required this.icon,
    required this.message,
    this.tone,
    this.title,
    this.action,
    this.maxLines,
    this.leading,
  });

  final IconData icon;
  final String message;
  final Color? tone;
  final String? title;
  final Widget? action;
  final int? maxLines;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final tone = this.tone;
    final foreground = tone ?? style.textSecondary;
    final title = this.title;
    final action = this.action;
    final maxLines = this.maxLines;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone == null ? style.pill : chatSoftTone(style, tone, alpha: 0.10),
        border: Border(
          bottom: BorderSide(color: style.divider, width: style.borderWidth),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, action == null ? spacing.lg : spacing.sm, spacing.sm),
        child: Row(
          crossAxisAlignment: title == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            leading ?? Icon(icon, size: 16, color: foreground),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) Text(title, style: style.typography.label.copyWith(color: foreground)),
                  Text(
                    message,
                    maxLines: maxLines,
                    overflow: maxLines == null ? null : TextOverflow.ellipsis,
                    style: style.typography.meta.copyWith(color: style.textPrimary),
                  ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

double chatContrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

bool chatReadableOn(Color foreground, Color background, {double minimum = 4.5}) =>
    chatContrast(foreground, background) >= minimum;

const _senderHues = [214.0, 262.0, 326.0, 2.0, 22.0, 174.0, 146.0, 290.0];

final _senderColors = <(int, int), Color>{};

Color chatSenderColor(String senderId, Color bubble, {required Color fallback}) {
  var hash = 0;
  for (final unit in senderId.codeUnits) {
    hash = (hash * 31 + unit) & 0x3fffffff;
  }
  final slot = hash % _senderHues.length;
  final key = (slot, bubble.toARGB32());
  final cached = _senderColors[key];
  if (cached != null) return cached;
  final dark = ThemeData.estimateBrightnessForColor(bubble) == Brightness.dark;
  final hue = _senderHues[slot];
  var color = HSLColor.fromAHSL(1, hue, dark ? 0.6 : 0.62, dark ? 0.74 : 0.34).toColor();
  if (!chatReadableOn(color, bubble)) {
    color = HSLColor.fromAHSL(1, hue, 0.6, dark ? 0.82 : 0.26).toColor();
  }
  if (!chatReadableOn(color, bubble)) color = fallback;
  if (_senderColors.length > 64) _senderColors.clear();
  return _senderColors[key] = color;
}
