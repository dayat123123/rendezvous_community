import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/group/domain/entities/group_event.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

String groupEventText(CommunityLocalizations l10n, ChatMessage message, {String? meId}) {
  final event = GroupEvent.fromMessage(message);
  final actor = event.actor;
  if (actor == null) return (message.body ?? '');
  String subject(GroupEventUser user) => user.id == meId ? l10n.groupEventYou : user.name;
  String object(GroupEventUser user) => user.id == meId ? l10n.groupEventYouObject : user.name;
  final who = subject(actor);
  final target = event.target;
  final newOwner = event.newOwner;
  return switch (event.type) {
    GroupEventType.added when event.targets.isNotEmpty => l10n.groupEventAdded(who, _targets(l10n, event, object)),
    GroupEventType.removed when target != null => l10n.groupEventRemoved(who, object(target)),
    GroupEventType.left when newOwner != null => l10n.groupEventLeftNewOwner(who, object(newOwner)),
    GroupEventType.left => l10n.groupEventLeft(who),
    GroupEventType.promoted when target != null => l10n.groupEventPromoted(who, object(target)),
    GroupEventType.demoted when target != null => l10n.groupEventDemoted(who, object(target)),
    GroupEventType.ownerChanged when target != null => l10n.groupEventOwnerChanged(who, object(target)),
    GroupEventType.renamed when event.name != null => l10n.groupEventRenamed(who, event.name!),
    GroupEventType.descriptionChanged =>
      event.removed ? l10n.groupEventDescriptionRemoved(who) : l10n.groupEventDescriptionChanged(who),
    GroupEventType.photoChanged => event.removed ? l10n.groupEventPhotoRemoved(who) : l10n.groupEventPhotoChanged(who),
    GroupEventType.settingsChanged => switch ((event.setting, event.enabled)) {
      (GroupSetting.onlyAdminsSend, true) => l10n.groupEventOnlyAdminsSend(who),
      (GroupSetting.onlyAdminsSend, false) => l10n.groupEventAllSend(who),
      (GroupSetting.onlyAdminsEdit, true) => l10n.groupEventOnlyAdminsEdit(who),
      (GroupSetting.onlyAdminsEdit, false) => l10n.groupEventAllEdit(who),
      _ => (message.body ?? ''),
    },
    _ => (message.body ?? ''),
  };
}

String _targets(CommunityLocalizations l10n, GroupEvent event, String Function(GroupEventUser) name) {
  final shown = event.targets.take(3).map(name).join(', ');
  final extra = event.count - (event.targets.length < 3 ? event.targets.length : 3);
  return extra > 0 ? l10n.groupEventMore(shown, extra) : shown;
}

IconData groupEventIcon(GroupEventType type) => switch (type) {
  GroupEventType.added => Icons.person_add_alt,
  GroupEventType.removed || GroupEventType.left => Icons.person_remove_outlined,
  GroupEventType.promoted ||
  GroupEventType.demoted ||
  GroupEventType.ownerChanged => Icons.admin_panel_settings_outlined,
  GroupEventType.photoChanged => Icons.photo_camera_outlined,
  GroupEventType.settingsChanged => Icons.tune,
  _ => Icons.edit_outlined,
};

class GroupEventNotice extends StatelessWidget {
  const GroupEventNotice({super.key, required this.message, this.meId});

  final ChatMessage message;
  final String? meId;

  @override
  Widget build(BuildContext context) {
    final details = CommunityGroupEventDetails(
      message: message,
      event: GroupEvent.fromMessage(message),
      text: groupEventText(context.communityL10n, message, meId: meId),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupEvent,
      context,
      details,
      _DefaultGroupEventNotice(details: details),
    );
  }
}

class _DefaultGroupEventNotice extends StatelessWidget {
  const _DefaultGroupEventNotice({required this.details});

  final CommunityGroupEventDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final meta = style.typography.meta.copyWith(fontSize: 12, height: 1.35);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs + spacing.xxs),
          decoration: BoxDecoration(color: style.chip, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(groupEventIcon(details.event.type), size: 14, color: style.textSecondary),
              SizedBox(width: spacing.xs + spacing.xxs),
              Flexible(
                child: Text(details.text, textAlign: TextAlign.center, style: meta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
