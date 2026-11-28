import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/appeals/presentation/widgets/community_appeals.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/room_moderation.dart'
    show roomModerationTime;
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/notices/domain/entities/community_notice.dart';
import 'package:rendezvous_community/src/features/notices/presentation/community_notice_page.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/notification_event.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/notification_preferences.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/builders/community_notification_builders.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/builders/community_notification_details.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/widgets/community_notification_settings.dart';
import 'package:rendezvous_community/src/features/notifications/presentation/widgets/notification_visuals.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/trade_share/domain/entities/trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/builders/community_trade_share_details.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_navigation.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/trade_share_texts.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_activity.dart';
import 'package:rendezvous_community/src/features/trade_share/presentation/widgets/community_trade_share_gate.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_badge_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_count_badge.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityNotificationList extends StatelessWidget {
  const CommunityNotificationList({super.key, this.onNotificationTap, this.builders});

  final void Function(BuildContext context, AppNotification notification)? onNotificationTap;
  final CommunityNotificationBuilders? builders;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    return withNotificationBuilders(
      context,
      builders,
      BlocProvider(
        create: (_) => NotificationsCubit(notifications: deps.notifications)..load(),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            final l10n = context.communityL10n;
            final cubit = context.read<NotificationsCubit>();
            final parts = CommunityNotificationBuilders.of(context);
            final header = CommunityNotificationHeaderDetails(
              title: l10n.notifications,
              unread: state.unread,
              onMarkAllRead: state.unread == 0 ? null : cubit.markAllRead,
            );
            return switch (state.status) {
              LoadStatus.initial || LoadStatus.loading => buildCommunityPart(
                parts.loading,
                context,
                const CommunityListLoadingDetails(),
                const CommunitySkeleton(),
              ),
              LoadStatus.failure => buildCommunityPart(
                parts.error,
                context,
                CommunityListErrorDetails(
                  error: state.error!,
                  message: l10n.errorMessage(state.error!),
                  onRetry: cubit.load,
                ),
                CommunityErrorView(error: state.error!, onRetry: cubit.load),
              ),
              LoadStatus.ready => ColoredBox(
                color: CommunityStyle.of(context).surface,
                child: Column(
                  children: [
                    buildCommunityPart(parts.header, context, header, _NotificationHeader(details: header)),
                    Expanded(
                      child: _NotificationFilter(
                        items: state.items,
                        hasMore: state.nextCursor != null,
                        onLoadMore: cubit.loadMore,
                        builder: (context, items, trade) => items.isEmpty
                            ? buildCommunityPart(
                                parts.empty,
                                context,
                                CommunityListEmptyDetails(message: trade ? l10n.notifTradeEmpty : l10n.noNotifications),
                                CommunityEmptyView(
                                  message: trade ? l10n.notifTradeEmpty : l10n.noNotifications,
                                  icon: Icons.notifications_none,
                                ),
                              )
                            : NotificationListener<ScrollEndNotification>(
                                onNotification: (n) {
                                  if (n.metrics.extentAfter < 300) cubit.loadMore();
                                  return false;
                                },
                                child: _NotificationRows(
                                  items: items,
                                  itemBuilder: (context, n) {
                                    return _NotificationTile(
                                      key: ValueKey(n.id),
                                      notification: n,
                                      onTap: () {
                                        cubit.markRead(n);
                                        final reporter = context.communityFeatures?.notificationReporter;
                                        final source = NotificationSource(notificationId: n.id);
                                        unawaited(reporter?.opened(source));
                                        final custom = onNotificationTap;
                                        if (custom != null) return custom(context, n);
                                        if (openCommunityNotification(context, n)) unawaited(reporter?.tapped(source));
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

bool openCommunityNotification(BuildContext context, AppNotification n) {
  if (n.isTrade) return _openTradeNotification(context, n);
  if (n.isOlt) {
    final callback = CommunityScope.of(context).callbacks.onOltNotificationTap;
    callback?.call(context, Map.unmodifiable({...n.payload, 'notification_id': n.id}));
    return callback != null;
  }
  final noticeId = n.noticeId;
  if (noticeId != null) {
    unawaited(
      openCommunityNotice(
        context,
        notice: CommunityNotice.fromJson(n.payload, id: noticeId, notificationId: n.id, sentAt: n.createdAt),
      ),
    );
    return true;
  }
  final postId = n.postId;
  final roomId = n.roomId;
  final me = CommunityScope.of(context).currentUser;
  final url = Uri.tryParse(n.url ?? '');
  if (n.isRoomMute && roomId != null) {
    CommunityNavigator.openRoom(context, roomId);
  } else if (n.type == NotificationType.appeal || n.type == NotificationType.moderation) {
    if (context.communityFeatures == null) return false;
    unawaited(openCommunityAppeals(context));
  } else if (n.type == NotificationType.watchlistDigest) {
    if (n.stocks.isEmpty) return false;
    CommunityNavigator.openStocks(context, n.stocks, title: context.communityL10n.notifWatchlistDigest);
  } else if (n.type == NotificationType.announcement && postId == null && url != null && url.scheme == 'https') {
    unawaited(launchUrl(url, mode: LaunchMode.externalApplication));
  } else if ((n.type == NotificationType.message || n.isRoomMention) && roomId != null) {
    CommunityNavigator.openRoom(context, roomId);
  } else if (n.type == NotificationType.follow && n.totalActors > 1 && me != null) {
    CommunityNavigator.openFollowList(context, me, FollowListKind.followers, kinds: const [FollowListKind.followers]);
  } else if (n.type == NotificationType.followedPost && n.eventCount > 1 && n.actor != null) {
    CommunityNavigator.openUser(context, n.actor!);
  } else if (n.type == NotificationType.quote && n.eventCount <= 1 && n.quotePostId != null) {
    CommunityNavigator.openPost(context, n.quotePostId!);
  } else if (postId != null) {
    CommunityNavigator.openPost(context, postId, rootCommentId: n.commentRoot);
  } else if (n.actor != null) {
    CommunityNavigator.openUser(context, n.actor!);
  } else {
    return false;
  }
  return true;
}

bool _openTradeNotification(BuildContext context, AppNotification n) {
  final actor = n.actor;
  if (n.type == NotificationType.tradeActivity) {
    final id = n.tradeActivityId;
    if (id == null || !canOpenTradeShare(context)) return false;
    unawaited(openCommunityTradeActivity(context, id, activity: TradeActivity.fromPayload(n.payload, trader: actor)));
    return true;
  }
  if (n.tradeAction == 'subscription_approved' && actor != null) {
    CommunityNavigator.openUser(context, actor);
    return true;
  }
  if (!canOpenTradeShare(context)) return false;
  if (n.tradeAction == 'subscription_request') {
    unawaited(openCommunityTradeSubscribers(context, requests: true));
  } else {
    unawaited(openCommunityTradeShare(context));
  }
  return true;
}

String notificationTradeShareTitle(CommunityLocalizations l10n, AppNotification n, String name) =>
    switch (n.tradeAction) {
      'approved' => l10n.notifTradeApproved,
      'rejected' => l10n.notifTradeRejected,
      'suspended' => l10n.notifTradeSuspended,
      'revoked' => l10n.notifTradeRevoked,
      'reinstated' || 'suspension_ended' => l10n.notifTradeReinstated,
      'auto_paused' => l10n.notifTradeAutoPaused,
      'auto_resumed' => l10n.notifTradeAutoResumed,
      'subscription_request' => l10n.notifTradeRequest(name),
      'subscription_approved' => l10n.notifTradeRequestApproved(name),
      _ => n.title ?? l10n.notifTradeUpdate,
    };

String? notificationTradeShareBody(CommunityLocalizations l10n, AppNotification n) => switch (n.tradeAction) {
  'approved' => l10n.notifTradeApprovedBody,
  'auto_paused' => l10n.notifTradeAutoPausedBody,
  'auto_resumed' => l10n.notifTradeAutoResumedBody,
  'subscription_request' => l10n.notifTradeRequestBody,
  'rejected' || 'suspended' || 'revoked' => n.tradeReason ?? n.body,
  _ => n.body,
};

class _NotificationFilter extends StatefulWidget {
  const _NotificationFilter({
    required this.items,
    required this.hasMore,
    required this.onLoadMore,
    required this.builder,
  });

  final List<AppNotification> items;
  final bool hasMore;
  final Future<void> Function() onLoadMore;
  final Widget Function(BuildContext context, List<AppNotification> items, bool trade) builder;

  @override
  State<_NotificationFilter> createState() => _NotificationFilterState();
}

class _NotificationFilterState extends State<_NotificationFilter> {
  bool _trade = false;

  @override
  Widget build(BuildContext context) {
    return CommunityTradeShareStatusBuilder(
      builder: (context, status) {
        final enabled = status?.enabled ?? false;
        final trade = enabled && _trade;
        final items = trade
            ? [
                for (final n in widget.items)
                  if (n.isTrade) n,
              ]
            : widget.items;
        final waiting = trade && items.isEmpty && widget.hasMore;
        if (waiting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(widget.onLoadMore());
          });
        }
        final body = waiting ? const CommunityLoadingView() : widget.builder(context, items, trade);
        if (!enabled) return body;
        final l10n = context.communityL10n;
        final style = CommunityStyle.of(context);
        final spacing = style.spacing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xs, spacing.lg, spacing.xs),
              child: Wrap(
                spacing: spacing.sm,
                children: [
                  ChoiceChip(
                    key: const ValueKey('notification-filter-all'),
                    selected: !trade,
                    label: Text(l10n.notifFilterAll),
                    onSelected: (_) => setState(() => _trade = false),
                  ),
                  ChoiceChip(
                    key: const ValueKey('notification-filter-trade'),
                    selected: trade,
                    avatar: Icon(style.icons.tradeShare, size: 16),
                    label: Text(l10n.notifFilterTrade),
                    onSelected: (_) => setState(() => _trade = true),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

const _leadingSize = 44.0;
const _thumbnailMargin = EdgeInsetsDirectional.only(start: 12);

class _NotificationRows extends StatelessWidget {
  const _NotificationRows({required this.items, required this.itemBuilder});

  final List<AppNotification> items;
  final Widget Function(BuildContext context, AppNotification notification) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final split = items.lastIndexWhere((n) => !n.isRead) + 1;
    final grouped = split > 0;
    final earlier = grouped && split < items.length;
    final headers = (grouped ? 1 : 0) + (earlier ? 1 : 0);
    Widget section(CommunityNotificationSection kind) {
      final details = CommunityNotificationSectionDetails(
        section: kind,
        title: kind == CommunityNotificationSection.newer ? l10n.notifGroupNew : l10n.notifGroupEarlier,
      );
      return KeyedSubtree(
        key: ValueKey('section-${kind.name}'),
        child: buildCommunityPart(
          CommunityNotificationBuilders.of(context).section,
          context,
          details,
          _NotificationSectionHeader(details: details),
        ),
      );
    }

    final rows = <String, int>{
      if (grouped) 'section-${CommunityNotificationSection.newer.name}': 0,
      if (earlier) 'section-${CommunityNotificationSection.earlier.name}': split + 1,
      for (final (index, n) in items.indexed)
        'row-${n.id}': index + (grouped ? 1 : 0) + (earlier && index >= split ? 1 : 0),
    };
    return CommunityScrollArea(
      child: ListView.builder(
        addAutomaticKeepAlives: false,
        itemCount: items.length + headers,
        findChildIndexCallback: (key) => key is ValueKey<String> ? rows[key.value] : null,
        itemBuilder: (context, row) {
          if (grouped && row == 0) return section(CommunityNotificationSection.newer);
          if (earlier && row == split + 1) return section(CommunityNotificationSection.earlier);
          final index = row - (grouped ? 1 : 0) - (earlier && row > split ? 1 : 0);
          final last = index == items.length - 1 || (earlier && index == split - 1);
          return Column(
            key: ValueKey('row-${items[index].id}'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              itemBuilder(context, items[index]),
              if (!last) _NotificationSeparator(unread: !items[index].isRead && !items[index + 1].isRead),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationSectionHeader extends StatelessWidget {
  const _NotificationSectionHeader({required this.details});

  final CommunityNotificationSectionDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return ColoredBox(
      color: style.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.xs),
        child: Semantics(
          header: true,
          child: Text(details.title, style: style.typography.sectionTitle.copyWith(fontSize: 16)),
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader({required this.details});

  final CommunityNotificationHeaderDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.sm, spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(details.title, style: style.typography.title.copyWith(fontSize: 26, height: 1.2)),
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
            onPressed: details.onMarkAllRead,
            icon: Icon(style.icons.markRead, size: 18),
            label: Text(context.communityL10n.markAllRead),
          ),
        ],
      ),
    );
  }
}

class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({super.key, required this.details});

  final CommunityNotificationIconDetails details;

  @override
  Widget build(BuildContext context) => buildCommunityPart(
    CommunityNotificationBuilders.of(context).icon,
    context,
    details,
    _DefaultNotificationIcon(details: details),
  );
}

class _DefaultNotificationIcon extends StatelessWidget {
  const _DefaultNotificationIcon({required this.details});

  final CommunityNotificationIconDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final size = details.size;
    final color = details.important ? Theme.of(context).colorScheme.error : style.accent;
    final small = size < 32;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(color.withValues(alpha: 0.14), style.surface),
          shape: BoxShape.circle,
          border: small ? Border.all(color: style.surface, width: 2) : null,
        ),
        child: Icon(details.icon, size: small ? size * 0.55 : size * 0.5, color: color),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.details, required this.leading, this.trailing});

  final CommunityNotificationDetails details;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final unread = !d.isRead;
    final snippet = d.snippet;
    final name = d.highlight ?? d.notification.actor?.name;
    final title = d.title;
    final at = name == null || name.isEmpty ? -1 : title.indexOf(name);
    final base = style.typography.body.copyWith(fontSize: 14, height: 1.4, fontWeight: FontWeight.w400);
    final strong = base.copyWith(fontWeight: FontWeight.w700);
    return Material(
      color: unread ? _unreadTint(style) : style.surface,
      child: InkWell(
        onTap: d.onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.md, spacing.lg, spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      at < 0
                          ? TextSpan(
                              text: title,
                              style: base.copyWith(fontWeight: FontWeight.w600),
                            )
                          : TextSpan(
                              children: [
                                if (at > 0) TextSpan(text: title.substring(0, at)),
                                TextSpan(text: name, style: strong),
                                TextSpan(text: title.substring(at + name!.length)),
                              ],
                            ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: base,
                    ),
                    if (snippet != null) ...[
                      SizedBox(height: spacing.xxs),
                      Text(snippet, maxLines: 2, overflow: TextOverflow.ellipsis, style: style.typography.meta),
                    ],
                    SizedBox(height: spacing.xxs),
                    Text(d.timeLabel, style: style.typography.meta.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: EdgeInsets.only(left: spacing.md, top: (_leadingSize - 10) / 2),
                  child: SizedBox.square(
                    dimension: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: style.accent, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    if (n.isOlt) return _OltNotificationTile(notification: n, onTap: onTap);
    final l10n = context.communityL10n;
    final icons = CommunityStyle.of(context).icons;
    final name = n.actor?.name ?? l10n.someone;
    final names = notificationActorNames(l10n, n) ?? name;
    final grouped = switch (n.type) {
      NotificationType.reply => n.replyScope == 'post' || n.replyScope == 'comment',
      NotificationType.like => n.targetType == 'post' || n.targetType == 'comment',
      NotificationType.follow => true,
      NotificationType.quote => true,
      _ => false,
    };
    final activity = n.type == NotificationType.tradeActivity
        ? TradeActivity.fromPayload(n.payload, trader: n.actor)
        : null;
    final activityText = activity == null ? null : l10n.tradeActivityText(activity);
    final title = switch (n.type) {
      NotificationType.reply when n.replyScope == 'post' => l10n.notifCommentedPost(names),
      NotificationType.reply when n.replyScope == 'comment' => l10n.notifRepliedComment(names),
      NotificationType.reply => l10n.notifReply(name),
      NotificationType.mention when n.isRoomMention => l10n.notifMentionRoom(
        name,
        n.stockCode == null ? (n.payload['room_name'] as String? ?? '') : '\$${n.stockCode}',
      ),
      NotificationType.mention => l10n.notifMention(name),
      NotificationType.quote => l10n.notifQuotedPost(names),
      NotificationType.like when n.targetType == 'post' => switch (n.reactionEmoji) {
        final String emoji when emoji != postLikeReaction => l10n.notifReactedPost(names, emoji),
        _ => l10n.notifLikedPost(names),
      },
      NotificationType.like when n.targetType == 'comment' => l10n.notifLikedComment(names),
      NotificationType.like => l10n.notifLike(name, n.actorCount < 1 ? 1 : n.actorCount, n.otherActors),
      NotificationType.follow => l10n.notifFollowedYou(names),
      NotificationType.message => l10n.notifMessage(name, n.eventCount),
      NotificationType.announcement => n.title ?? l10n.notifAnnouncement(name),
      NotificationType.appeal => n.appealStatus == 'accepted' ? l10n.notifAppealAccepted : l10n.notifAppealRejected,
      NotificationType.followedPost =>
        n.eventCount > 1 ? l10n.notifFollowedPostMany(name, n.eventCount) : l10n.notifFollowedPost(name),
      NotificationType.watchlistDigest => l10n.notifWatchlistDigest,
      NotificationType.moderation => notificationModerationTitle(l10n, n),
      NotificationType.tradeActivity => activityText?.title ?? n.title ?? l10n.notifTypeTradeActivity,
      NotificationType.tradeShare => notificationTradeShareTitle(l10n, n, name),
    };
    final icon = switch (n.type) {
      NotificationType.followedPost => Icons.article_outlined,
      NotificationType.watchlistDigest => Icons.insights_outlined,
      NotificationType.moderation => Icons.shield_outlined,
      NotificationType.reply => Icons.reply,
      NotificationType.mention => Icons.alternate_email,
      NotificationType.quote => Icons.format_quote,
      NotificationType.like => Icons.favorite,
      NotificationType.follow => Icons.person_add_alt,
      NotificationType.message => Icons.chat_bubble,
      NotificationType.announcement when n.isNotice => switch (n.payload['level']) {
        'critical' => Icons.error_outline,
        'warning' => Icons.warning_amber,
        _ => Icons.info_outline,
      },
      NotificationType.announcement => Icons.campaign,
      NotificationType.appeal => Icons.gavel_outlined,
      NotificationType.tradeActivity => icons.tradeShare,
      NotificationType.tradeShare => n.tradeAction == 'subscription_request' ? icons.tradeBell : icons.tradeShare,
    };
    final snippet = switch (n.type) {
      NotificationType.announcement => n.body,
      NotificationType.appeal => n.note ?? n.body,
      NotificationType.watchlistDigest => notificationDigestText(l10n, n),
      NotificationType.moderation when n.isRoomMute => roomMuteNotificationText(l10n, n),
      NotificationType.moderation => [
        if ((n.excerpt ?? '').isNotEmpty) n.excerpt!,
        n.appealable ? l10n.notifModerationAppealable : l10n.notifModerationAppealed,
      ].join('\n'),
      NotificationType.tradeActivity => activityText?.body ?? n.body,
      NotificationType.tradeShare => notificationTradeShareBody(l10n, n),
      _ => n.snippet,
    };
    final details = CommunityNotificationDetails(
      notification: n,
      title: title,
      snippet: snippet == null || snippet.isEmpty ? null : snippet,
      icon: icon,
      timeLabel: l10n.relativeTime(n.createdAt),
      onTap: onTap,
      highlight: grouped ? names : null,
    );
    final style = CommunityStyle.of(context);
    final row = buildCommunityPart(
      CommunityNotificationBuilders.of(context).item,
      context,
      details,
      _NotificationRow(
        details: details,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CommunityNotificationAvatars(
              notification: n,
              size: _leadingSize,
              ringColor: n.isRead ? style.surface : _unreadTint(style),
            ),
            Positioned(
              right: -3,
              bottom: -3,
              child: NotificationTypeIcon(
                details: CommunityNotificationIconDetails(notification: n, icon: icon, size: 20),
              ),
            ),
          ],
        ),
        trailing: n.hasImage
            ? CommunityNotificationThumbnail(notification: n, size: _leadingSize, margin: _thumbnailMargin)
            : null,
      ),
    );
    if (activity == null) return row;
    return TradeActivityTile(
      activity: activity,
      placement: CommunityTradeActivityPlacement.notification,
      notification: n,
      onTap: onTap,
      fallback: row,
    );
  }
}

String notificationModerationTitle(CommunityLocalizations l10n, AppNotification n) {
  if (n.isRoomMute) {
    final room = n.stockCode == null ? (n.payload['room_name'] as String? ?? '') : '\$${n.stockCode}';
    return n.moderationState == 'muted' ? l10n.notifRoomMuted(room) : l10n.notifRoomUnmuted(room);
  }
  final target = switch (n.targetType) {
    'comment' => l10n.notifTargetComment,
    'message' => l10n.notifTargetMessage,
    _ => l10n.notifTargetPost,
  };
  return n.moderationState == 'removed' ? l10n.notifModerationRemoved(target) : l10n.notifModerationHidden(target);
}

String roomMuteNotificationText(CommunityLocalizations l10n, AppNotification n) {
  final until = n.muteUntil;
  return n.moderationState == 'muted' && until != null
      ? l10n.notifRoomMutedUntil(roomModerationTime(l10n, until))
      : l10n.notifRoomUnmutedBody;
}

String notificationDigestText(CommunityLocalizations l10n, AppNotification n) {
  final codes = [for (final code in n.stocks) '\$$code'].join(', ');
  final others = n.stockCount - n.stocks.length;
  return l10n.notifWatchlistDigestBody(n.postCount, codes, others < 0 ? 0 : others);
}

class _OltNotificationTile extends StatelessWidget {
  const _OltNotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final l10n = context.communityL10n;
    final language = l10n.localeName.split('_').first;
    final kind = n.oltKind;
    final kindLabel = kind == null ? null : notificationTypeLabel(l10n, kind);
    final title =
        n.localizedTitle(language) ?? (kindLabel == null || kindLabel == kind ? l10n.notifSectionOlt : kindLabel);
    final body = n.localizedBody(language);
    final important = n.oltCategory == 'important';
    final icon = important
        ? Icons.notification_important_outlined
        : switch (kind) {
            notificationTradeType => Icons.receipt_long_outlined,
            notificationFundsType => Icons.account_balance_wallet_outlined,
            notificationMarketType => Icons.show_chart,
            notificationPromoType => Icons.local_offer_outlined,
            _ => n.oltCategory == 'promo' ? Icons.local_offer_outlined : Icons.info_outline,
          };
    final details = CommunityNotificationDetails(
      notification: n,
      title: title,
      snippet: body,
      icon: icon,
      important: important,
      timeLabel: l10n.relativeTime(n.createdAt),
      onTap: onTap,
    );
    return buildCommunityPart(
      CommunityNotificationBuilders.of(context).item,
      context,
      details,
      _NotificationRow(
        details: details,
        leading: NotificationTypeIcon(
          details: CommunityNotificationIconDetails(
            notification: n,
            icon: icon,
            important: important,
            size: _leadingSize,
          ),
        ),
        trailing: n.hasImage
            ? CommunityNotificationThumbnail(notification: n, size: _leadingSize, margin: _thumbnailMargin)
            : null,
      ),
    );
  }
}

class CommunityNotificationBadge extends StatelessWidget {
  const CommunityNotificationBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    return BlocProvider(
      create: (_) => NotificationsCubit(notifications: deps.notifications, countOnly: true)..load(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        buildWhen: (a, b) => a.unread != b.unread,
        builder: (context, state) =>
            CommunityCountOverlay(kind: CommunityCountKind.notificationUnread, count: state.unread, child: child),
      ),
    );
  }
}

Color _unreadTint(CommunityStyle style) => Color.lerp(style.surface, style.accentMuted, 0.6)!;

class _NotificationSeparator extends StatelessWidget {
  const _NotificationSeparator({this.unread = false});

  final bool unread;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return ColoredBox(
      color: unread ? _unreadTint(style) : style.surface,
      child: CommunityDivider(indent: spacing.lg + _leadingSize + spacing.md),
    );
  }
}
