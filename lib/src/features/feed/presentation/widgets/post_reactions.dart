import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post_reaction.dart';
import 'package:rendezvous_community/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_actions.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_sheet.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

const _cellSize = 36.0;

const _hoverDelay = Duration(milliseconds: 400);

const _hoverCloseDelay = Duration(milliseconds: 300);

const _longPressDelay = Duration(milliseconds: 350);

String communityReactionSummaryText(CommunityLocalizations l10n, {required int count, required bool reactedByMe}) {
  if (reactedByMe) return count <= 1 ? l10n.reactionYou : l10n.reactionYouAndOthers(count - 1);
  final locale = Intl.verifiedLocale(l10n.localeName, NumberFormat.localeExists, onFailure: (_) => 'en');
  return NumberFormat.compact(locale: locale).format(count);
}

int _totalReactions(Post post) {
  final sum = post.effectiveReactionSummary.fold<int>(0, (total, r) => total + r.count);
  return math.max(post.likeCount, sum);
}

class CommunityReactionPicker extends StatelessWidget {
  const CommunityReactionPicker({super.key, required this.choices, required this.onSelected, this.selected});

  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final current = normalizePostReaction(selected);
    return Material(
      color: style.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: StadiumBorder(side: style.borderSide),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: style.spacing.xs, vertical: style.spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final emoji in choices)
              Semantics(
                button: true,
                selected: emoji == current,
                child: InkResponse(
                  radius: _cellSize / 2,
                  onTap: () => onSelected(emoji),
                  child: SizedBox.square(
                    dimension: _cellSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: emoji == current ? style.accentMuted : null,
                        border: emoji == current
                            ? Border.all(color: style.accent.withValues(alpha: 0.4), width: style.borderWidth)
                            : null,
                      ),
                      child: Center(
                        child: Text(emoji, style: TextStyle(fontSize: 20, height: 1, color: style.textPrimary)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CommunityPostReactionSummary extends StatelessWidget {
  const CommunityPostReactionSummary({super.key, required this.post, this.onTap, this.maxEmojis = 3});

  final Post post;
  final VoidCallback? onTap;
  final int maxEmojis;

  @override
  Widget build(BuildContext context) {
    final total = _totalReactions(post);
    if (total <= 0) return const SizedBox.shrink();
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final emojis = [for (final r in post.effectiveReactionSummary.take(maxEmojis)) r.emoji];
    const size = 20.0;
    const step = size * 0.7;
    final stack = SizedBox(
      width: emojis.isEmpty ? 0 : size + step * (emojis.length - 1),
      height: size,
      child: Stack(
        children: [
          for (final (index, emoji) in emojis.indexed)
            Positioned(
              left: step * index,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style.pill,
                  border: Border.all(color: style.surface, width: 1.5),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 11, height: 1)),
              ),
            ),
        ],
      ),
    );
    final tap = onTap ?? () => showCommunityPostReactors(context, post);
    return Semantics(
      button: true,
      hint: l10n.reactorsShow,
      child: InkWell(
        onTap: tap,
        borderRadius: style.radii.pillRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: style.minTouchTarget, minWidth: style.minTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: style.spacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                stack,
                SizedBox(width: style.spacing.xs),
                Flexible(
                  child: Text(
                    communityReactionSummaryText(l10n, count: total, reactedByMe: post.effectiveReaction != null),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.typography.meta.copyWith(color: style.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostReactionButton extends StatefulWidget {
  const PostReactionButton({super.key, required this.details});

  final CommunityPostDetails details;

  @override
  State<PostReactionButton> createState() => _PostReactionButtonState();
}

class _PostReactionButtonState extends State<PostReactionButton> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _group = Object();
  Timer? _hoverTimer;
  Timer? _closeTimer;
  bool _openedByHover = false;

  bool get _canReact => widget.details.onReact != null && widget.details.reactionChoices.isNotEmpty;

  void _open({bool hover = false}) {
    _hoverTimer?.cancel();
    _closeTimer?.cancel();
    if (!_canReact || !mounted) return;
    _openedByHover = hover;
    if (!_portal.isShowing) setState(_portal.show);
  }

  void _close() {
    _hoverTimer?.cancel();
    _closeTimer?.cancel();
    if (mounted && _portal.isShowing) setState(_portal.hide);
  }

  void _scheduleClose() {
    _hoverTimer?.cancel();
    if (!_openedByHover || !_portal.isShowing) return;
    _closeTimer?.cancel();
    _closeTimer = Timer(_hoverCloseDelay, _close);
  }

  void _select(String emoji) {
    _close();
    final react = widget.details.onReact;
    if (react == null) return;
    HapticFeedback.selectionClick();
    react(emoji == widget.details.myReaction ? null : emoji);
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final d = widget.details;
    final mine = d.myReaction;
    final pill = CommunityActionPill(
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
      activeColor: CommunityTheme.of(context).like,
      emoji: mine,
      label: l10n.like,
      count: d.post.likeCount,
      active: mine != null,
      tooltip: mine != null ? l10n.unlike : l10n.like,
      onPressed: () {
        _close();
        HapticFeedback.selectionClick();
        d.onLike();
      },
    );
    if (!_canReact) return pill;
    return TapRegion(
      groupId: _group,
      enabled: _portal.isShowing,
      onTapOutside: (_) => _close(),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: _picker,
          child: MouseRegion(
            onEnter: (event) {
              if (event.kind != PointerDeviceKind.mouse) return;
              _closeTimer?.cancel();
              if (_portal.isShowing) return;
              _hoverTimer?.cancel();
              _hoverTimer = Timer(_hoverDelay, () => _open(hover: true));
            },
            onExit: (_) => _scheduleClose(),
            child: RawGestureDetector(
              gestures: {
                LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer(debugOwner: this, duration: _longPressDelay),
                  (recognizer) => recognizer.onLongPress = () {
                    HapticFeedback.mediumImpact();
                    _open();
                  },
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  () => TapGestureRecognizer(debugOwner: this),
                  (recognizer) => recognizer.onSecondaryTap = _open,
                ),
              },
              child: pill,
            ),
          ),
        ),
      ),
    );
  }

  Widget _picker(BuildContext context) {
    final d = widget.details;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.bottomLeft,
        offset: Offset(0, -CommunityStyle.of(context).spacing.xs),
        child: TapRegion(
          groupId: _group,
          child: MouseRegion(
            onEnter: (_) => _closeTimer?.cancel(),
            onExit: (_) => _scheduleClose(),
            child: CommunityReactionPicker(choices: d.reactionChoices, selected: d.myReaction, onSelected: _select),
          ),
        ),
      ),
    );
  }
}

Future<void> showCommunityPostReactors(BuildContext context, Post post) {
  final feed = CommunityScope.maybeOf(context)?.feed;
  return showCommunitySheet<void>(
    context,
    isScrollControlled: true,
    builder: (sheetContext) => _PostReactorsView(
      key: const ValueKey('post-reactors'),
      post: post,
      onOpenUser: (user) {
        Navigator.of(sheetContext).pop();
        if (context.mounted) CommunityNavigator.openUser(context, user);
      },
      repository: switch (feed) {
        final PostReactionRepository reactions => reactions,
        _ => null,
      },
    ),
  );
}

class _PostReactorsView extends StatelessWidget {
  const _PostReactorsView({super.key, required this.post, required this.repository, required this.onOpenUser});

  final Post post;
  final PostReactionRepository? repository;
  final ValueChanged<UserSummary> onOpenUser;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final summary = post.effectiveReactionSummary;
    final height = math.min(MediaQuery.sizeOf(context).height * 0.7, 560.0);
    return SizedBox(
      height: height,
      child: DefaultTabController(
        length: summary.length + 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(style.spacing.lg, style.spacing.lg, style.spacing.xl * 2, style.spacing.xxs),
              child: Text(l10n.reactionsTitle, style: style.typography.title),
            ),
            SizedBox(height: style.spacing.xs),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: style.textPrimary,
              unselectedLabelColor: style.textSecondary,
              indicatorColor: style.accent,
              labelStyle: style.typography.label.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: style.typography.label.copyWith(fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: l10n.reactorsAll(_totalReactions(post))),
                for (final r in summary) Tab(text: '${r.emoji} ${r.count}'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ReactorsList(postId: post.id, repository: repository, onOpenUser: onOpenUser),
                  for (final r in summary)
                    _ReactorsList(postId: post.id, repository: repository, emoji: r.emoji, onOpenUser: onOpenUser),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactorsList extends StatefulWidget {
  const _ReactorsList({required this.postId, required this.repository, required this.onOpenUser, this.emoji});

  final ValueChanged<UserSummary> onOpenUser;

  final String postId;
  final PostReactionRepository? repository;
  final String? emoji;

  @override
  State<_ReactorsList> createState() => _ReactorsListState();
}

class _ReactorsListState extends State<_ReactorsList> with AutomaticKeepAliveClientMixin {
  static const _pageSize = 30;

  final _items = <PostReactor>[];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.repository == null) {
      _loading = false;
      _error = const CommunityException(CommunityErrorKind.unavailable, code: postReactionsUnavailableCode);
    } else {
      unawaited(_load());
    }
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _load();
  }

  Future<void> _load() async {
    final repository = widget.repository;
    if (repository == null) return;
    try {
      final page = await repository.postReactors(widget.postId, emoji: widget.emoji, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _cursor = page.nextCursor;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  Future<void> _loadMore() async {
    final repository = widget.repository;
    final cursor = _cursor;
    if (repository == null || cursor == null || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final page = await repository.postReactors(widget.postId, emoji: widget.emoji, limit: _pageSize, cursor: cursor);
      if (!mounted) return;
      final known = {for (final r in _items) r.user.id};
      setState(() {
        _items.addAll(page.items.where((r) => !known.contains(r.user.id)));
        _cursor = page.items.isEmpty ? null : page.nextCursor;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      showCommunityError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.communityL10n;
    final spacing = CommunityStyle.of(context).spacing;
    if (_loading) return const Center(child: CircularProgressIndicator.adaptive());
    final error = _error;
    if (error != null) {
      final unavailable = mapError(error).code == postReactionsUnavailableCode;
      return CommunityErrorView(error: error, onRetry: unavailable ? null : _retry);
    }
    if (_items.isEmpty) {
      return CommunityEmptyView(message: l10n.reactorsEmpty, icon: Icons.emoji_emotions_outlined);
    }
    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < 300) unawaited(_loadMore());
        return false;
      },
      child: ListView.builder(
        addAutomaticKeepAlives: false,
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return Padding(
              padding: EdgeInsets.all(spacing.md),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (index >= _items.length - 3 && _cursor != null && !_loadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) unawaited(_loadMore());
            });
          }
          final reactor = _items[index];
          return KeyedSubtree(
            key: ValueKey(reactor.user.id),
            child: _ReactorRow(reactor: reactor, onOpen: widget.onOpenUser),
          );
        },
      ),
    );
  }
}

class _ReactorRow extends StatelessWidget {
  const _ReactorRow({required this.reactor, required this.onOpen});

  final PostReactor reactor;
  final ValueChanged<UserSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final user = reactor.user;
    return InkWell(
      onTap: user.isDeleted ? null : () => onOpen(user),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
        child: Row(
          children: [
            CommunityAvatar(user: user, radius: 20, ringColor: user.isOfficial ? style.accent : null),
            SizedBox(width: spacing.sm + spacing.xxs),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: CommunityUserName(user: user, showUsername: false, official: user.isOfficial),
                  ),
                  if (reactor.isMe) ...[
                    SizedBox(width: spacing.xs),
                    DecoratedBox(
                      decoration: BoxDecoration(color: style.accentMuted, borderRadius: style.radii.badgeRadius),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
                        child: Text(l10n.reactionYou, style: style.typography.badge.copyWith(color: style.accent)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.sm),
            Text(reactor.emoji, style: const TextStyle(fontSize: 20, height: 1)),
          ],
        ),
      ),
    );
  }
}
