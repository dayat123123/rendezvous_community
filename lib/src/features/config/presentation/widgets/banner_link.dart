import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/link_opener.dart';

Future<bool> openCommunityBannerLink(
  BuildContext context,
  CommunityBanner banner, {
  CommunityBannerLinkCallback? onBannerLink,
  CommunityLinkLauncher? launcher,
}) async {
  final uri = banner.link;
  if (uri == null) return false;
  final handler = onBannerLink ?? CommunityScope.maybeOf(context)?.callbacks.onBannerLink;
  if (handler != null) {
    var handled = false;
    try {
      handled = await handler(context, uri, banner);
    } catch (error) {
      CommunityLoggers.config.event(
        Level.WARNING,
        'Banner link callback failed',
        fields: {'errorType': error.runtimeType.toString()},
      );
    }
    if (handled) return true;
  }
  if (!context.mounted || (uri.scheme != 'https' && uri.scheme != 'http')) return false;
  return openCommunityLink(context, uri, launcher: launcher);
}
