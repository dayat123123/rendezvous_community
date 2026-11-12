import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/chat/presentation/widgets/community_chat_room.dart';
import 'package:rendezvous_community/src/features/group/presentation/widgets/community_group_info.dart';
import 'package:rendezvous_community/src/features/instruments/presentation/community_instruments.dart';
import 'package:rendezvous_community/src/features/instruments/presentation/widgets/community_index_feed.dart';
import 'package:rendezvous_community/src/features/post/presentation/widgets/community_post_detail.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/features/profile/presentation/widgets/community_follow_list.dart';
import 'package:rendezvous_community/src/features/profile/presentation/widgets/community_user_profile.dart';
import 'package:rendezvous_community/src/features/search/presentation/widgets/community_hashtag_feed.dart';
import 'package:rendezvous_community/src/features/stocks/presentation/widgets/community_stock_feed.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';

class CommunityScope extends InheritedWidget {
  const CommunityScope({super.key, required this.dependencies, required super.child});

  final CommunityDependencies dependencies;

  static CommunityDependencies of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityScope>()?.dependencies ?? RendezvousCommunity.instance;

  static CommunityDependencies? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityScope>()?.dependencies ??
      (RendezvousCommunity.isInitialized ? RendezvousCommunity.instance : null);

  @override
  bool updateShouldNotify(CommunityScope oldWidget) => !identical(dependencies, oldWidget.dependencies);
}

abstract final class CommunityNavigator {
  static void openStock(BuildContext context, String code, {String? source}) {
    final instruments = CommunityInstruments.maybeOf(context);
    if (instruments?.isIndex(code) ?? false) return openIndex(context, code, source: source);
    context.trackCommunityEvent(CommunityAnalyticsEvent.stockTap, {'stock_code': code, 'source': source ?? 'other'});
    final callback = CommunityScope.of(context).callbacks.onStockTap;
    if (callback != null) return callback(context, code);
    _push(context, '\$$code', CommunityStockFeed(stockCode: code));
  }

  static void openIndex(BuildContext context, String code, {String? source}) {
    final canonical = CommunityInstruments.maybeOf(context)?.canonicalOr(code) ?? code.trim().toUpperCase();
    context.trackCommunityEvent(CommunityAnalyticsEvent.stockTap, {
      'stock_code': canonical,
      'source': source ?? 'other',
    });
    final callbacks = CommunityScope.of(context).callbacks;
    final callback = callbacks.onIndexTap ?? callbacks.onStockTap;
    if (callback != null) return callback(context, canonical);
    _push(context, '\$$canonical', CommunityIndexFeed(indexCode: canonical));
  }

  static void openUser(BuildContext context, UserSummary user) {
    final callback = CommunityScope.of(context).callbacks.onUserTap;
    if (callback != null) return callback(context, user);
    _push(
      context,
      user.handle,
      CommunityUserProfile(userId: user.id.isEmpty ? null : user.id, username: user.username),
    );
  }

  static void openFollowList(
    BuildContext context,
    UserSummary user,
    FollowListKind kind, {
    List<FollowListKind> kinds = FollowListKind.values,
  }) {
    _push<void>(context, user.handle, CommunityFollowList(userId: user.id, initialKind: kind, kinds: kinds));
  }

  static void openUsername(BuildContext context, String username) {
    openUser(context, UserSummary(id: '', username: username));
  }

  static void openHashtag(BuildContext context, String tag) {
    final callback = CommunityScope.of(context).callbacks.onHashtagTap;
    if (callback != null) return callback(context, tag);
    _push(context, '#$tag', CommunityHashtagFeed(tag: tag));
  }

  static void openPost(BuildContext context, String postId, {String? rootCommentId}) {
    final callback = CommunityScope.of(context).callbacks.onPostTap;
    if (callback != null && rootCommentId == null) return callback(context, postId);
    _push(context, null, CommunityPostDetail(postId: postId, rootCommentId: rootCommentId));
  }

  static void openRoom(BuildContext context, String roomId) {
    final callback = CommunityScope.of(context).callbacks.onRoomTap;
    if (callback != null) {
      unawaited(Future.sync(() => callback(context, roomId)));
      return;
    }
    unawaited(pushRoom(context, roomId));
  }

  static Future<void> pushRoom(BuildContext context, String roomId, {String? title}) {
    final navigator = Navigator.of(context);
    late final Route<void> route;
    route = _route<void>(
      context,
      title,
      CommunityChatRoom(
        roomId: roomId,
        onClosed: () {
          if (route.isActive) navigator.removeRoute(route);
        },
      ),
    );
    return navigator.push(route);
  }

  static Future<bool?> openGroupInfo(BuildContext context, String roomId) =>
      _push<bool>(context, context.communityL10n.groupInfo, CommunityGroupInfo(roomId: roomId));

  static Future<T?> _push<T>(BuildContext context, String? title, Widget body) =>
      Navigator.of(context).push(_route<T>(context, title, body));

  static Route<T> _route<T>(BuildContext context, String? title, Widget body) {
    final dependencies = CommunityScope.of(context);
    final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
    final carry = carryCommunityBuilders(context);
    return MaterialPageRoute<T>(
      builder: (_) {
        Widget page = CommunityScope(
          dependencies: dependencies,
          child: Scaffold(
            appBar: AppBar(title: title == null ? null : Text(title)),
            body: SafeArea(top: false, child: body),
          ),
        );
        if (features != null) page = CommunityFeatureScope(dependencies: features, child: page);
        return carry(page);
      },
    );
  }
}
