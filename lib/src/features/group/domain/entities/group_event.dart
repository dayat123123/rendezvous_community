import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';

enum GroupEventType {
  added,
  removed,
  left,
  promoted,
  demoted,
  ownerChanged,
  renamed,
  descriptionChanged,
  photoChanged,
  settingsChanged,
  unknown,
}

enum GroupSetting { onlyAdminsSend, onlyAdminsEdit }

class GroupEventUser {
  const GroupEventUser({required this.id, required this.name});

  final String id;
  final String name;
}

class GroupEvent {
  const GroupEvent({
    required this.type,
    this.actor,
    this.targets = const [],
    this.count = 0,
    this.name,
    this.removed = false,
    this.setting,
    this.enabled,
    this.newOwner,
  });

  factory GroupEvent.fromMessage(ChatMessage message) {
    final payload = message.payload;
    final targets = switch (payload['targets']) {
      final List<Object?> list => [
        for (final item in list)
          if (item is Map) ?_user(item['id'], item['name']),
      ],
      _ => [?_user(payload['target_id'], payload['target_name'])],
    };
    return GroupEvent(
      type: _types[payload['event']] ?? GroupEventType.unknown,
      actor: _user(payload['actor_id'], payload['actor_name']),
      targets: targets,
      count: (payload['count'] as num?)?.toInt() ?? targets.length,
      name: payload['name'] as String?,
      removed: payload['removed'] == true,
      setting: _settings[payload['setting']],
      enabled: payload['value'] as bool?,
      newOwner: _user(payload['new_owner_id'], payload['new_owner_name']),
    );
  }

  static const _types = {
    'added': GroupEventType.added,
    'removed': GroupEventType.removed,
    'left': GroupEventType.left,
    'promoted': GroupEventType.promoted,
    'demoted': GroupEventType.demoted,
    'owner_changed': GroupEventType.ownerChanged,
    'renamed': GroupEventType.renamed,
    'description_changed': GroupEventType.descriptionChanged,
    'photo_changed': GroupEventType.photoChanged,
    'settings_changed': GroupEventType.settingsChanged,
  };

  static const _settings = {
    'only_admins_send': GroupSetting.onlyAdminsSend,
    'only_admins_edit': GroupSetting.onlyAdminsEdit,
  };

  static GroupEventUser? _user(Object? id, Object? name) =>
      id is String && id.isNotEmpty ? GroupEventUser(id: id, name: name is String ? name : '') : null;

  final GroupEventType type;
  final GroupEventUser? actor;
  final List<GroupEventUser> targets;
  final int count;
  final String? name;
  final bool removed;
  final GroupSetting? setting;
  final bool? enabled;
  final GroupEventUser? newOwner;

  GroupEventUser? get target => targets.firstOrNull;

  bool removes(String? userId) => userId != null && type == GroupEventType.removed && target?.id == userId;
}
