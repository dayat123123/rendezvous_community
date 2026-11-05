import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.online = false,
    this.onTap,
    this.ringColor,
  });

  final UserSummary? user;
  final double radius;
  final bool online;
  final VoidCallback? onTap;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '?';
    final url = user?.avatarUrl;
    final details = CommunityAvatarDetails(
      user: user,
      name: name,
      initials: name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
      radius: radius,
      image: url == null ? null : communityUrlImageProvider(context, url, width: radius * 2, height: radius * 2),
      online: online,
      onTap: onTap,
      ringColor: ringColor,
    );
    return buildSharedPart((b) => b.avatar, context, details, _DefaultAvatar(details: details));
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.details});

  final CommunityAvatarDetails details;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = details.radius;
    final image = details.image;
    final ring = details.ringColor;
    final ringWidth = radius >= 24 ? 2.0 : 1.5;
    final inner = ring == null ? radius : radius - ringWidth * 2;

    Widget avatar = CircleAvatar(
      radius: inner,
      backgroundColor: scheme.secondaryContainer,
      foregroundColor: scheme.onSecondaryContainer,
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Text(
        details.initials,
        style: TextStyle(fontSize: inner * 0.8, fontWeight: FontWeight.w600),
      ),
    );

    if (ring != null) {
      avatar = Container(
        width: radius * 2,
        height: radius * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: ringWidth),
        ),
        child: avatar,
      );
    }

    if (details.online) {
      final dot = radius * 0.55;
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: CommunityTheme.of(context).onlineIndicator,
                shape: BoxShape.circle,
                border: Border.all(color: CommunityStyle.of(context).surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    final onTap = details.onTap;
    if (onTap == null) return Semantics(label: details.name, child: avatar);
    return Semantics(
      button: true,
      label: details.name,
      child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: avatar),
    );
  }
}
