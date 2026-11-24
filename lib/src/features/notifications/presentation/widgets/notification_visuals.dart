import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/notifications/domain/entities/app_notification.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/gen/community_localizations.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';

String? notificationActorNames(CommunityLocalizations l10n, AppNotification n) {
  final users = n.knownActors;
  if (users.isEmpty) return null;
  final total = n.totalActors;
  final first = users.first.name;
  if (total <= 1) return first;
  if (users.length < 2) return l10n.notifNamesMore(first, total - 1);
  final second = users[1].name;
  if (total == 2) return l10n.notifNamesTwo(first, second);
  return l10n.notifNamesMany(first, second, total - 2);
}

class CommunityNotificationAvatars extends StatelessWidget {
  const CommunityNotificationAvatars({super.key, required this.notification, this.size = 44, this.ringColor});

  final AppNotification notification;
  final double size;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final users = notification.knownActors;
    if (users.length < 2) return CommunityAvatar(user: users.firstOrNull, radius: size / 2);
    final small = size * 0.7;
    const ring = 2.0;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: CommunityAvatar(user: users[1], radius: small / 2),
          ),
          Positioned(
            right: -ring,
            bottom: -ring,
            child: Container(
              padding: const EdgeInsets.all(ring),
              decoration: BoxDecoration(color: ringColor ?? CommunityStyle.of(context).surface, shape: BoxShape.circle),
              child: CommunityAvatar(user: users.first, radius: small / 2),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityNotificationThumbnail extends StatelessWidget {
  const CommunityNotificationThumbnail({super.key, required this.notification, this.size = 44, this.radius = 6});

  final AppNotification notification;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final attachment = notification.postAttachment;
    if (attachment == null) return const SizedBox.shrink();
    final style = CommunityStyle.of(context);
    final media = CommunityScope.of(context).media;
    final bucket = attachment.bucket ?? attachmentBucket;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: CommunityNetworkImage(
          cacheKey: imageCacheKeyForObject(bucket, attachment.path),
          source: () => media.attachmentImage(attachment),
          placeholder: ColoredBox(color: style.skeleton),
          error: ColoredBox(
            color: style.skeleton,
            child: Center(
              child: Icon(Icons.image_outlined, size: size * 0.4, color: style.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}
