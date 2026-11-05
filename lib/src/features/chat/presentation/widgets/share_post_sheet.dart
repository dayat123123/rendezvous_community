import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/chat/presentation/cubit/share_post_cubit.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_visuals.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<bool> showSharePostToChat(BuildContext context, Post post) async {
  final features = CommunityFeatureScope.maybeOf(context);
  if (features == null) return false;
  final deps = CommunityScope.of(context);
  final carry = carryCommunityBuilders(context);
  final shared = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: CommunityStyle.of(context).surface,
    builder: (_) => carry(
      CommunityScope(
        dependencies: deps,
        child: BlocProvider(
          create: (_) => SharePostCubit(chat: deps.chat, extras: features.chatExtras, postId: post.id)..load(),
          child: const _SharePostSheet(),
        ),
      ),
    ),
  );
  if (shared == true && context.mounted) showCommunityMessage(context, context.communityL10n.shareSent);
  return shared ?? false;
}

class _SharePostSheet extends StatefulWidget {
  const _SharePostSheet();

  @override
  State<_SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends State<_SharePostSheet> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _share(ChatRoom room) async {
    if (await context.read<SharePostCubit>().share(room.id, body: _message.text) && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final builder = CommunityChatBuilders.of(context).shareTarget;
    final height = MediaQuery.sizeOf(context).height * 0.7;
    final field = OutlineInputBorder(borderRadius: style.radii.pillRadius, borderSide: BorderSide.none);
    return BlocConsumer<SharePostCubit, SharePostState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<SharePostCubit>();
        return SafeArea(
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(spacing.lg, 0, spacing.lg, spacing.md),
                  child: Text(l10n.sharePickRoom, style: style.typography.title),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                  child: TextField(
                    controller: _message,
                    maxLength: 4000,
                    decoration: InputDecoration(
                      hintText: l10n.shareMessageHint,
                      filled: true,
                      fillColor: style.pill,
                      border: field,
                      enabledBorder: field,
                      focusedBorder: field.copyWith(
                        borderSide: BorderSide(color: style.accent, width: style.borderWidth),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
                      counterText: '',
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(height: spacing.sm),
                Expanded(
                  child: switch (state.status) {
                    LoadStatus.initial || LoadStatus.loading => const CommunitySkeleton(itemCount: 4),
                    LoadStatus.failure => CommunityErrorView(error: state.error!, onRetry: cubit.load),
                    LoadStatus.ready when state.rooms.isEmpty => CommunityEmptyView(
                      message: l10n.shareNoRooms,
                      icon: Icons.chat_bubble_outline,
                    ),
                    LoadStatus.ready => ListView.builder(
                      addAutomaticKeepAlives: false,
                      itemCount: state.rooms.length,
                      itemBuilder: (context, i) {
                        final room = state.rooms[i];
                        final details = CommunityShareTargetDetails(
                          room: room,
                          title: roomTitle(room),
                          sending: state.sendingRoomId == room.id,
                          onShare: state.sendingRoomId == null ? () => _share(room) : null,
                        );
                        return buildChatPart(builder, context, details, _DefaultShareTarget(details: details));
                      },
                    ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DefaultShareTarget extends StatelessWidget {
  const _DefaultShareTarget({required this.details});

  final CommunityShareTargetDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg),
          leading: CommunityRoomAvatar(room: details.room),
          title: Text(
            details.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.typography.author.copyWith(fontSize: 15),
          ),
          trailing: details.sending
              ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: style.accent))
              : Icon(Icons.send_outlined, color: details.onShare == null ? style.textTertiary : style.accent),
          enabled: details.onShare != null,
          onTap: details.onShare,
        ),
        CommunityDivider(indent: spacing.lg + 40 + spacing.lg),
      ],
    );
  }
}
