import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/domain/repositories/profile_repository.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

bool communityBlockedUsersAvailable(BuildContext context) =>
    CommunityScope.maybeOf(context)?.profiles is BlockListRepository;

Future<void> showCommunityBlockedUsers(BuildContext context) =>
    communityBlockedUsersOpener(context)?.call() ?? Future<void>.value();

Future<void> Function()? communityBlockedUsersOpener(BuildContext context) {
  final dependencies = CommunityScope.maybeOf(context);
  if (dependencies == null || dependencies.profiles is! BlockListRepository) return null;
  final navigator = Navigator.maybeOf(context, rootNavigator: true);
  if (navigator == null) return null;
  final theme = Theme.of(context);
  final carry = carryCommunityBuilders(context);
  return () async {
    if (!navigator.mounted) return;
    await showDialog<void>(
      context: navigator.context,
      builder: (_) => carry(
        Theme(
          data: theme,
          child: CommunityScope(dependencies: dependencies, child: const _BlockedUsersDialog()),
        ),
      ),
    );
  };
}

class _BlockedUsersDialog extends StatelessWidget {
  const _BlockedUsersDialog();

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final l10n = context.communityL10n;
    final spacing = style.spacing;
    return AlertDialog(
      backgroundColor: style.surface,
      surfaceTintColor: style.surface,
      shape: communityDialogShape(style),
      title: Text(l10n.blockedUsersTitle, style: style.typography.title),
      contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
      content: SizedBox(
        width: 440,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480),
          child: const CommunityBlockedUsers(shrinkWrap: true),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: style.textSecondary, textStyle: style.typography.label),
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class CommunityBlockedUsers extends StatefulWidget {
  const CommunityBlockedUsers({super.key, this.shrinkWrap = false});

  final bool shrinkWrap;

  @override
  State<CommunityBlockedUsers> createState() => _CommunityBlockedUsersState();
}

class _CommunityBlockedUsersState extends State<CommunityBlockedUsers> {
  late final CommunityDependencies _dependencies = CommunityScope.of(context);
  List<BlockedUser>? _items;
  Object? _error;
  final _pending = <String>{};

  BlockListRepository? get _lists => switch (_dependencies.profiles) {
    final BlockListRepository lists => lists,
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final lists = _lists;
    if (lists == null) return;
    setState(() {
      _items = null;
      _error = null;
    });
    try {
      final items = await lists.blockedUsers();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _unblock(BlockedUser entry) async {
    final user = entry.user;
    final l10n = context.communityL10n;
    if (_pending.contains(user.id)) return;
    if (!await confirmCommunityAction(context, l10n.unblockConfirm(user.name), confirmLabel: l10n.unblock)) return;
    if (!mounted) return;
    setState(() => _pending.add(user.id));
    try {
      await _dependencies.profiles.unblock(user.id);
      if (!mounted) return;
      setState(() {
        _pending.remove(user.id);
        _items = [
          for (final item in _items ?? const <BlockedUser>[])
            if (item.user.id != user.id) item,
        ];
      });
      showCommunityMessage(context, l10n.unblocked(user.name));
    } catch (e) {
      if (!mounted) return;
      setState(() => _pending.remove(user.id));
      showCommunityError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    final error = _error;
    final items = _items;
    if (_lists == null) return const SizedBox.shrink();
    if (error != null) {
      return Padding(
        padding: EdgeInsets.all(spacing.md),
        child: CommunityErrorView(error: error, onRetry: _load),
      );
    }
    if (items == null) {
      return Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.md),
        child: CommunityEmptyView(message: l10n.blockedUsersEmpty, icon: Icons.block_outlined),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: false,
      shrinkWrap: widget.shrinkWrap,
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        return _BlockedUserRow(
          key: ValueKey('blocked-${entry.user.id}'),
          entry: entry,
          pending: _pending.contains(entry.user.id),
          onUnblock: () => _unblock(entry),
        );
      },
    );
  }
}

class _BlockedUserRow extends StatelessWidget {
  const _BlockedUserRow({super.key, required this.entry, required this.pending, required this.onUnblock});

  final BlockedUser entry;
  final bool pending;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final user = entry.user;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      child: Row(
        children: [
          CommunityAvatar(user: user, radius: 20),
          SizedBox(width: spacing.sm + spacing.xxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommunityUserName(user: user, showUsername: false, official: user.isOfficial),
                SizedBox(height: spacing.xxs),
                Text(
                  user.handle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.typography.meta.copyWith(color: style.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          OutlinedButton(
            key: ValueKey('unblock-${user.id}'),
            style: style.secondaryButtonStyle(),
            onPressed: pending ? null : onUnblock,
            child: Text(context.communityL10n.unblock),
          ),
        ],
      ),
    );
  }
}
