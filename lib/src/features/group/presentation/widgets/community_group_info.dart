import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_official_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/group/domain/entities/group_event.dart';
import 'package:rendezvous_community/src/features/group/presentation/cubit/group_info_cubit.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_menu.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityGroupInfo extends StatelessWidget {
  const CommunityGroupInfo({super.key, required this.roomId, this.onLeft});

  final String roomId;
  final VoidCallback? onLeft;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    return BlocProvider(
      create: (context) => GroupInfoCubit(
        chat: deps.chat,
        groups: CommunityFeatureScope.of(context).groups,
        roomId: roomId,
        me: deps.ensureSignedIn,
        analytics: CommunityFeatureScope.of(context).analytics,
      )..load(),
      child: _GroupInfoView(onLeft: onLeft),
    );
  }
}

class _GroupInfoView extends StatelessWidget {
  const _GroupInfoView({this.onLeft});

  final VoidCallback? onLeft;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupInfoCubit, GroupInfoState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId || (!a.left && b.left),
      listener: (context, state) {
        if (state.left) {
          final left = onLeft;
          if (left != null) {
            left();
          } else {
            Navigator.maybePop(context, true);
          }
          return;
        }
        final error = state.actionError;
        if (error != null) showCommunityError(context, error);
      },
      builder: (context, state) {
        final cubit = context.read<GroupInfoCubit>();
        final room = state.room;
        if (state.status == LoadStatus.failure) {
          return CommunityErrorView(error: state.error ?? Exception('load failed'), onRetry: cubit.load);
        }
        if (room == null) return const CommunityLoadingView();
        final l10n = context.communityL10n;
        final hasPhoto = room.avatarUrl != null;
        final membersLabel = l10n.members(state.members.length);
        final details = CommunityGroupInfoPageDetails(
          room: room,
          title: roomTitle(room),
          memberCount: state.members.length,
          membersLabel: membersLabel,
          description: room.description,
          descriptionEmptyLabel: l10n.groupDescriptionEmpty,
          avatar: roomAvatar(context, room, radius: 44),
          buildAvatar: ({required double radius}) => roomAvatar(context, room, radius: radius),
          canEditInfo: state.canEditInfo,
          isAdmin: state.isAdmin,
          hasPhoto: hasPhoto,
          busy: state.busy,
          onEditInfo: state.canEditInfo ? () => _editInfo(context, room) : null,
          onChangePhoto: state.canEditInfo ? () => _pickPhoto(cubit) : null,
          onRemovePhoto: state.canEditInfo && hasPhoto ? cubit.removePhoto : null,
          editInfoLabel: l10n.groupEditInfo,
          changePhotoLabel: l10n.groupChangePhoto,
          removePhotoLabel: l10n.groupRemovePhoto,
          settingsTitle: l10n.groupSettings,
          settings: state.isAdmin
              ? [
                  _GroupSettingTile(
                    key: const ValueKey(GroupSetting.onlyAdminsSend),
                    details: CommunityGroupSettingDetails(
                      kind: GroupSetting.onlyAdminsSend,
                      title: l10n.groupOnlyAdminsSend,
                      value: room.onlyAdminsSend,
                      onChanged: cubit.setOnlyAdminsSend,
                    ),
                  ),
                  _GroupSettingTile(
                    key: const ValueKey(GroupSetting.onlyAdminsEdit),
                    details: CommunityGroupSettingDetails(
                      kind: GroupSetting.onlyAdminsEdit,
                      title: l10n.groupOnlyAdminsEdit,
                      value: room.onlyAdminsEdit,
                      onChanged: cubit.setOnlyAdminsEdit,
                    ),
                  ),
                ]
              : const [],
          membersTitle: membersLabel,
          members: [
            for (final member in state.members)
              _MemberTile(key: ValueKey(member.user.id), member: member, state: state),
          ],
          onAddMembers: state.isAdmin ? () => _addMembers(context, state) : null,
          addMembersLabel: l10n.groupAddMembers,
          onLeave: () => _leave(context, cubit),
          leaveLabel: l10n.groupLeave,
          onDeleteGroup: state.canDeleteGroup ? () => _deleteGroup(context, cubit) : null,
          deleteGroupLabel: l10n.deleteGroup,
        );
        return AbsorbPointer(
          absorbing: state.busy,
          child: buildChatPart(
            CommunityChatBuilders.of(context).groupInfoPage,
            context,
            details,
            _DefaultGroupInfoPage(details: details),
          ),
        );
      },
    );
  }

  Future<void> _leave(BuildContext context, GroupInfoCubit cubit) async {
    final l10n = context.communityL10n;
    if (await confirmCommunityAction(context, l10n.groupLeaveConfirm, confirmLabel: l10n.leaveRoom)) {
      await cubit.leave();
    }
  }

  Future<void> _deleteGroup(BuildContext context, GroupInfoCubit cubit) async {
    final l10n = context.communityL10n;
    if (await confirmCommunityAction(context, l10n.deleteGroupConfirm, confirmLabel: l10n.deleteGroup)) {
      await cubit.deleteGroup();
    }
  }

  Future<void> _pickPhoto(GroupInfoCubit cubit) async {
    const group = XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png', 'webp']);
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null) return;
    await cubit.changePhoto(await file.readAsBytes(), mimeFromName(file.name, file.mimeType));
  }

  Future<void> _editInfo(BuildContext context, ChatRoom room) async {
    final cubit = context.read<GroupInfoCubit>();
    final deps = CommunityScope.of(context);
    final carry = carryCommunityBuilders(context);
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => carry(
        CommunityScope(
          dependencies: deps,
          child: _EditInfoDialog(name: room.name ?? '', description: room.description ?? ''),
        ),
      ),
    );
    if (result != null) await cubit.updateInfo(name: result.$1, description: result.$2);
  }

  Future<void> _addMembers(BuildContext context, GroupInfoState state) async {
    final cubit = context.read<GroupInfoCubit>();
    final deps = CommunityScope.of(context);
    final carry = carryCommunityBuilders(context);
    final ids = await showDialog<List<String>>(
      context: context,
      builder: (_) => carry(
        CommunityScope(
          dependencies: deps,
          child: _AddMembersDialog(existing: {for (final m in state.members) m.user.id}),
        ),
      ),
    );
    if (ids != null && ids.isNotEmpty) await cubit.addMembers(ids);
  }
}

class _DefaultGroupInfoPage extends StatelessWidget {
  const _DefaultGroupInfoPage({required this.details});

  final CommunityGroupInfoPageDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final danger = Theme.of(context).colorScheme.error;
    final onAddMembers = d.onAddMembers;
    final onDeleteGroup = d.onDeleteGroup;
    return ListView(
      padding: EdgeInsets.symmetric(vertical: style.spacing.lg),
      children: [
        _DefaultGroupHeader(details: d),
        if (d.settings.isNotEmpty) ...[const CommunityDivider(), _SectionTitle(d.settingsTitle), ...d.settings],
        const CommunityDivider(),
        _SectionTitle(d.membersTitle),
        if (onAddMembers != null)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: style.accentMuted,
              child: Icon(Icons.person_add_alt, color: style.accent),
            ),
            title: Text(d.addMembersLabel, style: style.typography.author),
            onTap: onAddMembers,
          ),
        ...d.members,
        const CommunityDivider(),
        ListTile(
          leading: Icon(style.icons.leave, color: danger),
          title: Text(d.leaveLabel, style: style.typography.body.copyWith(color: danger)),
          onTap: d.onLeave,
        ),
        if (onDeleteGroup != null)
          ListTile(
            leading: Icon(style.icons.deleteGroup, color: danger),
            title: Text(d.deleteGroupLabel, style: style.typography.body.copyWith(color: danger)),
            onTap: onDeleteGroup,
          ),
      ],
    );
  }
}

class _GroupSettingTile extends StatelessWidget {
  const _GroupSettingTile({super.key, required this.details});

  final CommunityGroupSettingDetails details;

  @override
  Widget build(BuildContext context) => buildChatPart(
    CommunityChatBuilders.of(context).groupSetting,
    context,
    details,
    Material(
      type: MaterialType.transparency,
      child: SwitchListTile(
        title: Text(details.title, style: CommunityStyle.of(context).typography.body),
        value: details.value,
        onChanged: details.onChanged,
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(style.spacing.lg, style.spacing.md, style.spacing.lg, style.spacing.xs),
      child: Text(text, style: style.typography.meta.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _DefaultGroupHeader extends StatelessWidget {
  const _DefaultGroupHeader({required this.details});

  final CommunityGroupInfoPageDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final description = d.description;
    final onChangePhoto = d.onChangePhoto;
    final onRemovePhoto = d.onRemovePhoto;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg),
      child: Column(
        children: [
          if (onChangePhoto != null)
            PopupMenuButton<VoidCallback>(
              tooltip: d.changePhotoLabel,
              onSelected: (action) => action(),
              itemBuilder: (menuContext) => [
                communityMenuItem(
                  menuContext,
                  value: onChangePhoto,
                  icon: style.icons.changePhoto,
                  label: d.changePhotoLabel,
                ),
                if (onRemovePhoto != null)
                  communityMenuItem(
                    menuContext,
                    value: onRemovePhoto,
                    icon: style.icons.delete,
                    label: d.removePhotoLabel,
                    danger: true,
                  ),
              ],
              child: Stack(
                children: [
                  d.avatar,
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: style.accent,
                      child: Icon(Icons.photo_camera_outlined, size: 16, color: style.onAccent),
                    ),
                  ),
                ],
              ),
            )
          else
            d.avatar,
          SizedBox(height: spacing.md),
          Text(d.title, textAlign: TextAlign.center, style: style.typography.title),
          SizedBox(height: spacing.xxs),
          Text(d.membersLabel, style: style.typography.meta),
          SizedBox(height: spacing.md),
          Text(
            description ?? d.descriptionEmptyLabel,
            textAlign: TextAlign.center,
            style: description == null
                ? style.typography.meta.copyWith(fontStyle: FontStyle.italic)
                : style.typography.body,
          ),
          if (d.onEditInfo != null)
            Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: TextButton.icon(
                onPressed: d.onEditInfo,
                icon: Icon(style.icons.edit, size: 18),
                label: Text(d.editInfoLabel),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditInfoDialog extends StatefulWidget {
  const _EditInfoDialog({required this.name, required this.description});

  final String name;
  final String description;

  @override
  State<_EditInfoDialog> createState() => _EditInfoDialogState();
}

class _EditInfoDialogState extends State<_EditInfoDialog> {
  late final _name = TextEditingController(text: widget.name);
  late final _description = TextEditingController(text: widget.description);
  late bool _canSave = _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final canSave = _name.text.trim().isNotEmpty;
    if (canSave != _canSave) setState(() => _canSave = canSave);
  }

  void _save() => Navigator.pop(context, (_name.text.trim(), _description.text.trim()));

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityGroupEditDetails(
      nameController: _name,
      descriptionController: _description,
      nameMaxLength: 80,
      descriptionMaxLength: 500,
      title: l10n.groupEditInfo,
      nameLabel: l10n.groupName,
      descriptionLabel: l10n.groupDescription,
      saveLabel: l10n.save,
      cancelLabel: l10n.cancel,
      onCancel: () => Navigator.pop(context),
      onSave: _canSave ? _save : null,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupEditDialog,
      context,
      details,
      _DefaultEditInfoDialog(details: details),
    );
  }
}

class _DefaultEditInfoDialog extends StatelessWidget {
  const _DefaultEditInfoDialog({required this.details});

  final CommunityGroupEditDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    return AlertDialog(
      backgroundColor: style.surface,
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: d.nameController,
              maxLength: d.nameMaxLength,
              decoration: InputDecoration(labelText: d.nameLabel),
            ),
            TextField(
              controller: d.descriptionController,
              maxLength: d.descriptionMaxLength,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(labelText: d.descriptionLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: d.onCancel,
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          child: Text(d.cancelLabel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onSave, child: Text(d.saveLabel)),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({super.key, required this.member, required this.state});

  final RoomMember member;
  final GroupInfoState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final isMe = state.isMe(member);
    final details = CommunityGroupMemberDetails(
      member: member,
      isMe: isMe,
      title: isMe ? l10n.you : member.user.name,
      roleLabel: switch (member.role) {
        MemberRole.owner => l10n.groupRoleOwner,
        MemberRole.admin => l10n.groupRoleAdmin,
        MemberRole.member => null,
      },
      onTap: isMe ? null : () => _showActions(context),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupMember,
      context,
      details,
      _DefaultMemberTile(details: details),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final cubit = context.read<GroupInfoCubit>();
    final l10n = context.communityL10n;
    final user = member.user;
    final deps = CommunityScope.of(context);
    final carry = carryCommunityBuilders(context);
    final actions = <_MemberAction>[
      (
        kind: CommunityGroupMemberActionKind.viewProfile,
        label: l10n.groupViewProfile,
        destructive: false,
        run: () async => CommunityNavigator.openUser(context, user),
      ),
      if (state.canPromote(member))
        (
          kind: CommunityGroupMemberActionKind.makeAdmin,
          label: l10n.groupMakeAdmin,
          destructive: false,
          run: () => cubit.setAdmin(user.id, admin: true),
        ),
      if (state.canDemote(member))
        (
          kind: CommunityGroupMemberActionKind.dismissAdmin,
          label: l10n.groupDismissAdmin,
          destructive: false,
          run: () => cubit.setAdmin(user.id, admin: false),
        ),
      if (state.canTransfer(member))
        (
          kind: CommunityGroupMemberActionKind.makeOwner,
          label: l10n.groupMakeOwner,
          destructive: true,
          run: () async {
            if (await confirmCommunityAction(
              context,
              l10n.groupMakeOwnerConfirm(user.name),
              confirmLabel: l10n.groupMakeOwner,
            )) {
              await cubit.transferOwnership(user.id);
            }
          },
        ),
      if (state.canRemove(member))
        (
          kind: CommunityGroupMemberActionKind.remove,
          label: l10n.groupRemoveMember,
          destructive: true,
          run: () async {
            if (await confirmCommunityAction(
              context,
              l10n.groupRemoveConfirm(user.name),
              confirmLabel: l10n.groupRemoveMember,
            )) {
              await cubit.removeMember(user.id);
            }
          },
        ),
    ];
    final chosen = await showModalBottomSheet<Future<void> Function()>(
      context: context,
      builder: (_) => carry(
        CommunityScope(
          dependencies: deps,
          child: _MemberActionsSheet(member: member, actions: actions),
        ),
      ),
    );
    if (chosen != null && context.mounted) await chosen();
  }
}

typedef _MemberAction = ({
  CommunityGroupMemberActionKind kind,
  String label,
  bool destructive,
  Future<void> Function() run,
});

class _MemberActionsSheet extends StatelessWidget {
  const _MemberActionsSheet({required this.member, required this.actions});

  final RoomMember member;
  final List<_MemberAction> actions;

  @override
  Widget build(BuildContext context) {
    final details = CommunityGroupMemberActionsDetails(
      member: member,
      actions: [
        for (final action in actions)
          CommunityGroupMemberAction(
            kind: action.kind,
            label: action.label,
            destructive: action.destructive,
            onSelected: () => Navigator.pop(context, action.run),
          ),
      ],
      onDismiss: () => Navigator.pop(context),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupMemberActions,
      context,
      details,
      _DefaultMemberActions(details: details),
    );
  }
}

class _DefaultMemberActions extends StatelessWidget {
  const _DefaultMemberActions({required this.details});

  final CommunityGroupMemberActionsDetails details;

  static IconData _icon(CommunityGroupMemberActionKind kind) => switch (kind) {
    CommunityGroupMemberActionKind.viewProfile => Icons.person_outline,
    CommunityGroupMemberActionKind.makeAdmin => Icons.admin_panel_settings_outlined,
    CommunityGroupMemberActionKind.dismissAdmin => Icons.remove_moderator_outlined,
    CommunityGroupMemberActionKind.makeOwner => Icons.workspace_premium_outlined,
    CommunityGroupMemberActionKind.remove => Icons.person_remove_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final user = details.member.user;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CommunityAvatar(user: user, radius: 18),
            title: Text(user.name, style: style.typography.author),
            subtitle: Text(user.handle, style: style.typography.meta),
          ),
          const CommunityDivider(),
          for (final action in details.actions)
            ListTile(leading: Icon(_icon(action.kind)), title: Text(action.label), onTap: action.onSelected),
        ],
      ),
    );
  }
}

class _DefaultMemberTile extends StatelessWidget {
  const _DefaultMemberTile({required this.details});

  final CommunityGroupMemberDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final role = details.roleLabel;
    final user = details.member.user;
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: CommunityAvatar(user: user, radius: 20),
        title: Text(details.title, style: style.typography.author),
        subtitle: Text(user.handle, style: style.typography.meta),
        trailing: role == null
            ? null
            : Container(
                padding: EdgeInsets.symmetric(horizontal: style.spacing.sm, vertical: style.spacing.xxs),
                decoration: BoxDecoration(color: style.accentMuted, borderRadius: style.radii.pillRadius),
                child: Text(role, style: style.typography.meta.copyWith(color: style.accent)),
              ),
        onTap: details.onTap,
      ),
    );
  }
}

class _AddMembersDialog extends StatefulWidget {
  const _AddMembersDialog({required this.existing});

  final Set<String> existing;

  @override
  State<_AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<_AddMembersDialog> {
  final _query = TextEditingController();
  final _selected = <String, UserSummary>{};
  List<UserSummary> _results = const [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _search(String query) {
    _debounce?.cancel();
    final deps = CommunityScope.of(context);
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final users = await deps.profiles.searchUsers(query);
        if (!mounted) return;
        setState(
          () => _results = [
            for (final u in users)
              if (!widget.existing.contains(u.id) && !CommunityOfficialScope.isOfficial(context, u)) u,
          ],
        );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityGroupAddMembersDetails(
      queryController: _query,
      results: _results,
      selected: List.unmodifiable(_selected.values),
      onQueryChanged: _search,
      onToggle: (u, v) => setState(() => v ? _selected[u.id] = u : _selected.remove(u.id)),
      title: l10n.groupAddMembers,
      addLabel: l10n.groupAdd,
      cancelLabel: l10n.cancel,
      onCancel: () => Navigator.pop(context),
      onAdd: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.keys.toList()),
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).groupAddMembersDialog,
      context,
      details,
      _DefaultAddMembersDialog(details: details),
    );
  }
}

class _DefaultAddMembersDialog extends StatelessWidget {
  const _DefaultAddMembersDialog({required this.details});

  final CommunityGroupAddMembersDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return AlertDialog(
      backgroundColor: style.surface,
      title: Text(d.title, style: style.typography.title),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: d.queryController,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: style.textSecondary),
                hintText: l10n.searchUsers,
                filled: true,
                fillColor: style.pill,
                border: OutlineInputBorder(borderRadius: style.radii.pillRadius, borderSide: BorderSide.none),
                isDense: true,
              ),
              onChanged: d.onQueryChanged,
            ),
            SizedBox(height: style.spacing.xs),
            Expanded(
              child: ListView(
                children: [
                  for (final u in {...d.selected, ...d.results})
                    CheckboxListTile(
                      value: d.isSelected(u),
                      contentPadding: EdgeInsets.zero,
                      secondary: CommunityAvatar(user: u, radius: 16),
                      title: Text(u.name, style: style.typography.author),
                      subtitle: Text(u.handle, style: style.typography.meta),
                      onChanged: (v) => d.onToggle(u, v ?? false),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: d.onCancel,
          style: TextButton.styleFrom(foregroundColor: style.textSecondary),
          child: Text(d.cancelLabel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onAdd, child: Text(d.addLabel)),
      ],
    );
  }
}
