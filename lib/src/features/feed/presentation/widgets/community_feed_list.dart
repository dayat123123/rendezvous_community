import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_offline_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_banner_host.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/post_open_mode.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/pinned_post_card.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_actions.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_card.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/post_skeletons.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_banner.dart';
import 'package:rendezvous_community/src/features/offline/presentation/widgets/community_offline_banner.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/community_post_comments.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

String feedScopeName(FeedScope scope) => switch (scope) {
  GlobalFeedScope() => 'global',
  FollowingFeedScope() => 'following',
  StockFeedScope() => 'stock',
  UserFeedScope() => 'user',
};

class CommunityFeedList extends StatelessWidget {
  const CommunityFeedList({
    super.key,
    required this.scope,
    required this.emptyMessage,
    this.header,
    this.builders,
    this.postOpenMode = CommunityPostOpenMode.navigate,
  });

  final FeedScope scope;
  final String emptyMessage;

  final Widget? header;
  final CommunityFeedBuilders? builders;
  final CommunityPostOpenMode postOpenMode;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final features = context.communityFeatures;
    final offline = CommunityOfflineScope.maybeOf(context);
    return withFeedBuilders(
      context,
      builders,
      CommunitySocialGate(
        child: BlocProvider(
          create: (_) {
            context.trackCommunityEvent(CommunityAnalyticsEvent.feedOpen, {
              'scope': feedScopeName(scope),
              if (scope is StockFeedScope) 'stock_code': (scope as StockFeedScope).code,
            });
            return FeedCubit(
              feed: deps.feed,
              scope: scope,
              currentUserId: () => deps.currentUser?.id,
              bookmarks: features?.bookmarks,
              edits: features?.edits,
              cache: offline?.feedCache,
              connectivity: offline?.connectivity,
            )..load();
          },
          child: FeedPostList(
            emptyMessage: emptyMessage,
            header: header,
            showBanners: scope is GlobalFeedScope || scope is FollowingFeedScope,
            postOpenMode: postOpenMode,
          ),
        ),
      ),
    );
  }
}

class FeedPostList extends StatefulWidget {
  const FeedPostList({
    super.key,
    required this.emptyMessage,
    this.header,
    this.showConsentBanner = true,
    this.source = 'feed',
    this.showBanners = false,
    this.postOpenMode = CommunityPostOpenMode.navigate,
  });

  final String emptyMessage;
  final Widget? header;
  final bool showConsentBanner;
  final String source;
  final bool showBanners;
  final CommunityPostOpenMode postOpenMode;

  @override
  State<FeedPostList> createState() => _FeedPostListState();
}

class _FeedPostListState extends State<FeedPostList> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) context.read<FeedCubit>().loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _showNewPosts() async {
    await context.read<FeedCubit>().refresh();
    if (_scroll.hasClients) {
      await _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return BlocConsumer<FeedCubit, FeedState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<FeedCubit>();
        final pinnedIds = {for (final pin in state.pinned) pin.post.id};
        final posts = [
          for (final post in state.posts)
            if (!pinnedIds.contains(post.id)) post,
        ];
        final builders = CommunityFeedBuilders.of(context);
        final empty = CommunityListEmptyDetails(message: widget.emptyMessage);
        final Widget body = switch (state.status) {
          LoadStatus.initial || LoadStatus.loading => buildCommunityPart(
            builders.loading,
            context,
            const CommunityListLoadingDetails(),
            CommunitySkeleton(itemCount: 3, itemBuilder: (_) => const PostCardSkeleton()),
          ),
          LoadStatus.failure => buildCommunityPart(
            builders.error,
            context,
            CommunityListErrorDetails(
              error: state.error!,
              message: l10n.errorMessage(state.error!),
              onRetry: cubit.load,
            ),
            CommunityErrorView(error: state.error!, onRetry: cubit.load),
          ),
          LoadStatus.ready => RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.builder(
              addAutomaticKeepAlives: false,
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: style.sectionGap),
              itemCount: posts.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      if (widget.showBanners) const CommunityBannerHost(),
                      if (widget.showConsentBanner) const CommunityConsentBanner(),
                      ?widget.header,
                      for (final pin in state.pinned)
                        PinnedPostCard(
                          pinned: pin,
                          onLike: () => cubit.toggleLike(pin.post),
                          onOpen: () => CommunityNavigator.openPost(context, pin.post.id),
                          onToggleBookmark: cubit.canBookmark ? () => cubit.toggleBookmark(pin.post) : null,
                        ),
                      if (posts.isEmpty && state.pinned.isEmpty)
                        buildCommunityPart(
                          builders.empty,
                          context,
                          empty,
                          CommunityEmptyView(message: widget.emptyMessage),
                        ),
                    ],
                  );
                }
                if (index == posts.length + 1) {
                  return state.loadingMore
                      ? buildCommunityPart(
                          builders.loading,
                          context,
                          const CommunityListLoadingDetails(more: true),
                          const CommunityLoadingView(),
                        )
                      : SizedBox(height: spacing.xxl);
                }
                final post = posts[index - 1];
                return Padding(
                  key: ValueKey(post.id),
                  padding: EdgeInsets.only(bottom: style.sectionGap),
                  child: FeedPostCard(post: post, cubit: cubit, source: widget.source, openMode: widget.postOpenMode),
                );
              },
            ),
          ),
        };

        return Column(
          children: [
            const CommunityOfflineBanner(),
            Expanded(
              child: ColoredBox(
                color: style.background,
                child: Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
                        child: body,
                      ),
                    ),
                    if (state.newPosts > 0)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: buildFeedPart(
                            (b) => b.newPosts,
                            context,
                            CommunityNewPostsDetails(
                              count: state.newPosts,
                              label: l10n.newPosts(state.newPosts),
                              onTap: _showNewPosts,
                            ),
                            FilledButton.icon(
                              style: style.primaryButtonStyle(),
                              onPressed: _showNewPosts,
                              icon: const Icon(Icons.arrow_upward, size: 18),
                              label: Text(l10n.newPosts(state.newPosts)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.cubit,
    this.source = 'feed',
    this.openMode = CommunityPostOpenMode.navigate,
  });

  final Post post;
  final FeedCubit cubit;
  final String source;
  final CommunityPostOpenMode openMode;

  @override
  Widget build(BuildContext context) {
    final inline = openMode == CommunityPostOpenMode.inlineComments;
    final expanded = inline && cubit.state.openComments.contains(post.id);
    void toggle() => cubit.toggleComments(post.id);
    final card = PostCard(
      post: post,
      source: source,
      onLike: () => cubit.toggleLike(post),
      onOpen: inline ? null : () => CommunityNavigator.openPost(context, post.id),
      onDelete: () => cubit.delete(post),
      onAuthorBlocked: () => cubit.hideAuthor(post.author.id),
      onEdit: editPostAction(context, post, cubit.canEdit ? cubit.editPost : null),
      onToggleBookmark: bookmarkPostAction(context, cubit.canBookmark ? () => cubit.toggleBookmark(post) : null),
      onShare: sharePostAction(context, post),
      onAppeal: appealPostAction(context, post),
      commentsExpanded: expanded,
      onToggleComments: inline ? toggle : null,
      readMoreInPlace: inline,
    );
    if (!expanded) return card;
    final focus = cubit.state.focusComments == post.id;
    if (focus) WidgetsBinding.instance.addPostFrameCallback((_) => cubit.commentsFocused(post.id));
    final details = CommunityInlineCommentsDetails(
      post: post,
      expanded: true,
      onToggle: toggle,
      child: CommunityPostComments(
        postId: post.id,
        commentCount: post.commentCount,
        autofocusComposer: focus,
        onCommentCountChanged: (delta) => cubit.adjustCommentCount(post.id, delta),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        buildFeedPart((b) => b.inlineComments, context, details, _DefaultInlineComments(details: details)),
      ],
    );
  }
}

class _DefaultInlineComments extends StatelessWidget {
  const _DefaultInlineComments({required this.details});

  final CommunityInlineCommentsDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): details.onToggle},
      child: Material(
        color: style.surface,
        child: Padding(
          padding: EdgeInsets.only(bottom: spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommunityDivider(indent: spacing.lg, endIndent: spacing.lg),
              SizedBox(height: spacing.xs),
              details.child,
            ],
          ),
        ),
      ),
    );
  }
}
