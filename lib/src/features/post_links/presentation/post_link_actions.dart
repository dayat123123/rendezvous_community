import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/post_links/domain/post_link.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus;

PostLinkRepository? _repository(BuildContext context) => switch (context.communityFeatures?.chatExtras) {
  final PostLinkRepository repository => repository,
  _ => null,
};

PostLinkRepository? communityPostLinks(BuildContext context) =>
    context.communityFeature(CommunityFlags.postLinks) ? _repository(context) : null;

bool get communityCanShareToApps =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

Future<bool> copyCommunityPostLink(BuildContext context, PostLinkRepository links, String postId) async {
  try {
    final link = await links.postLink(postId);
    await Clipboard.setData(ClipboardData(text: link.url.toString()));
    if (context.mounted) showCommunityMessage(context, context.communityL10n.postLinkCopied);
    return true;
  } catch (error) {
    if (context.mounted) showCommunityError(context, error);
    return false;
  }
}

Future<bool> shareCommunityPostLink(BuildContext context, PostLinkRepository links, String postId) async {
  final box = context.findRenderObject();
  final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  try {
    final link = await links.postLink(postId);
    await SharePlus.instance.share(ShareParams(text: link.url.toString(), sharePositionOrigin: origin));
    return true;
  } catch (error) {
    if (context.mounted) showCommunityError(context, error);
    return false;
  }
}

Future<String?> resolveCommunityPostLink(BuildContext context, Uri uri) async {
  final code = communityPostLinkCode(uri);
  final links = code == null ? null : _repository(context);
  if (code == null || links == null) return null;
  try {
    return await links.resolvePostLink(code);
  } catch (_) {
    return null;
  }
}

Future<bool> openCommunityPostLink(BuildContext context, Uri uri) async {
  final code = communityPostLinkCode(uri);
  final links = code == null ? null : _repository(context);
  if (code == null || links == null) return false;
  try {
    final postId = await links.resolvePostLink(code);
    if (!context.mounted) return true;
    if (postId == null) {
      showCommunityMessage(context, context.communityL10n.postLinkUnavailable);
    } else {
      CommunityNavigator.openPost(context, postId);
    }
  } catch (error) {
    if (context.mounted) showCommunityError(context, error);
  }
  return true;
}
