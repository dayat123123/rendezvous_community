import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/community_compose_post.dart';
import 'package:rendezvous_community/src/features/drafts/domain/entities/post_draft.dart';
import 'package:rendezvous_community/src/features/drafts/presentation/cubit/post_drafts_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

Future<void> openCommunityPostDrafts(BuildContext context) {
  final deps = CommunityScope.of(context);
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) {
        final page = CommunityScope(
          dependencies: deps,
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(context.communityL10n.draftsTitle)),
              body: const CommunityPostDrafts(),
            ),
          ),
        );
        return features == null ? page : CommunityFeatureScope(dependencies: features, child: page);
      },
    ),
  );
}

class CommunityPostDrafts extends StatelessWidget {
  const CommunityPostDrafts({super.key});

  @override
  Widget build(BuildContext context) {
    final drafts = context.communityFeatures?.drafts;
    if (drafts == null) return const SizedBox.shrink();
    return BlocProvider(create: (_) => PostDraftsCubit(drafts)..load(), child: const _DraftsView());
  }
}

class _DraftsView extends StatelessWidget {
  const _DraftsView();

  Future<void> _open(BuildContext context, PostDraft draft) async {
    final cubit = context.read<PostDraftsCubit>();
    await showCommunityComposer(context, draft: draft);
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return BlocBuilder<PostDraftsCubit, PostDraftsState>(
      builder: (context, state) {
        final cubit = context.read<PostDraftsCubit>();
        return switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => const CommunitySkeleton(itemCount: 3),
          LoadStatus.failure => CommunityErrorView(error: state.error!, onRetry: cubit.load),
          LoadStatus.ready when state.drafts.isEmpty => CommunityEmptyView(
            message: l10n.draftsEmpty,
            icon: Icons.drafts_outlined,
          ),
          LoadStatus.ready => ColoredBox(
            color: style.surface,
            child: CommunityRefresh(
              onRefresh: cubit.load,
              child: ListView.separated(
                addAutomaticKeepAlives: false,
                itemCount: state.drafts.length,
                separatorBuilder: (_, _) => CommunityDivider(indent: style.spacing.lg),
                itemBuilder: (context, index) {
                  final draft = state.drafts[index];
                  final preview = draft.body.trim().isEmpty ? l10n.draftNoText : draft.body.trim();
                  final time = l10n.relativeTime(draft.updatedAt);
                  final details = CommunityDraftDetails(
                    draft: draft,
                    preview: preview,
                    timeLabel: time,
                    subtitle: draft.synced ? time : '$time · ${l10n.draftSavedLocally}',
                    deleteLabel: l10n.delete,
                    onOpen: () => _open(context, draft),
                    onDelete: () => cubit.delete(draft),
                  );
                  return buildFeedPart((b) => b.draftTile, context, details, _DefaultDraftTile(details: details));
                },
              ),
            ),
          ),
        };
      },
    );
  }
}

class _DefaultDraftTile extends StatelessWidget {
  const _DefaultDraftTile({required this.details});

  final CommunityDraftDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final size = style.avatarSizes.medium;
    return InkWell(
      onTap: details.onOpen,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(spacing.lg, spacing.md, spacing.xs, spacing.md),
        child: Row(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: style.pill, shape: BoxShape.circle),
              child: Icon(
                details.synced ? Icons.cloud_done_outlined : Icons.phone_android_outlined,
                size: 18,
                color: style.textSecondary,
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details.preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: style.typography.body),
                  SizedBox(height: spacing.xxs),
                  Text(details.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                ],
              ),
            ),
            IconButton(
              tooltip: details.deleteLabel,
              color: style.textSecondary,
              onPressed: details.onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
