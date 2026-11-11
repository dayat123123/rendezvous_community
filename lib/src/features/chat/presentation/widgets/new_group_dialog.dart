import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_official_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

Future<String?> showNewGroupDialog(BuildContext context) {
  final deps = CommunityScope.of(context);
  final carry = carryCommunityBuilders(context);
  return showDialog<String>(
    context: context,
    builder: (_) => carry(CommunityScope(dependencies: deps, child: const _NewGroupDialog())),
  );
}

class _NewGroupDialog extends StatefulWidget {
  const _NewGroupDialog();

  @override
  State<_NewGroupDialog> createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<_NewGroupDialog> {
  final _name = TextEditingController();
  final _query = TextEditingController();
  final _selected = <String, UserSummary>{};
  List<UserSummary> _results = const [];
  Timer? _debounce;
  bool _creating = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _query.dispose();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    final deps = CommunityScope.of(context);
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final users = await deps.profiles.searchUsers(q);
        final me = deps.currentUser?.id;
        if (mounted) {
          setState(
            () => _results = [
              for (final u in users)
                if (u.id != me && !CommunityOfficialScope.isOfficial(context, u)) u,
            ],
          );
        }
      } catch (_) {}
    });
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    try {
      final id = await CommunityScope.of(context).chat.createGroupRoom(_name.text.trim(), _selected.keys.toList());
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        setState(() => _creating = false);
        showCommunityError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = CommunityNewGroupDetails(
      nameController: _name,
      queryController: _query,
      results: _results,
      selected: List.unmodifiable(_selected.values),
      creating: _creating,
      onNameChanged: (_) => setState(() {}),
      onQueryChanged: _search,
      onToggle: (u, v) => setState(() => v ? _selected[u.id] = u : _selected.remove(u.id)),
      onCancel: () => Navigator.pop(context),
      onCreate: _creating || _name.text.trim().isEmpty ? null : _create,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).newGroupDialog,
      context,
      details,
      _DefaultNewGroupDialog(details: details),
    );
  }
}

class _DefaultNewGroupDialog extends StatelessWidget {
  const _DefaultNewGroupDialog({required this.details});

  final CommunityNewGroupDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final field = OutlineInputBorder(borderRadius: style.radii.controlRadius);
    return AlertDialog(
      backgroundColor: style.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(style.radii.card * 2)),
      title: Text(l10n.newGroup, style: style.typography.title),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: d.nameController,
              maxLength: 80,
              decoration: InputDecoration(labelText: l10n.groupName, border: field),
              onChanged: d.onNameChanged,
            ),
            if (d.selected.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: spacing.xs + spacing.xxs,
                    runSpacing: spacing.xs,
                    children: [
                      for (final u in d.selected)
                        InputChip(
                          avatar: CommunityAvatar(user: u, radius: 10),
                          label: Text(u.name),
                          labelStyle: style.typography.label.copyWith(color: style.onChip),
                          backgroundColor: style.chip,
                          shape: const StadiumBorder(),
                          side: style.borderSide,
                          onDeleted: () => d.onToggle(u, false),
                        ),
                    ],
                  ),
                ),
              ),
            TextField(
              controller: d.queryController,
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
            SizedBox(height: spacing.xs),
            Expanded(
              child: ListView(
                children: [
                  for (final u in d.results)
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
          child: Text(l10n.cancel),
        ),
        FilledButton(style: style.primaryButtonStyle(), onPressed: d.onCreate, child: Text(l10n.create)),
      ],
    );
  }
}
