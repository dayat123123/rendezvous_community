import 'package:flutter/foundation.dart';
import 'package:rendezvous_community/src/features/profile/domain/entities/user_profile.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

class CommunityProfileDetails {
  const CommunityProfileDetails({
    required this.profile,
    required this.busy,
    required this.followersLabel,
    required this.followingLabel,
    required this.postsLabel,
    this.onToggleFollow,
    this.onMessage,
    this.onEdit,
    this.onReport,
    this.onBlock,
    this.onUnblock,
    this.isOfficial = false,
    this.onOfficialContact,
    this.onOpenFollowers,
    this.onOpenFollowing,
  });

  final UserProfile profile;
  final bool busy;
  final String followersLabel;
  final String followingLabel;
  final String postsLabel;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onMessage;
  final VoidCallback? onEdit;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;
  final bool isOfficial;
  final VoidCallback? onOfficialContact;
  final VoidCallback? onOpenFollowers;
  final VoidCallback? onOpenFollowing;

  bool get isMe => profile.isMe;

  bool get isFollowing => profile.isFollowing;
}

class CommunityFollowListEntryDetails {
  const CommunityFollowListEntryDetails({
    required this.entry,
    required this.kind,
    required this.pending,
    required this.followLabel,
    required this.followingLabel,
    required this.followBackLabel,
    required this.followsYouLabel,
    required this.onOpen,
    this.onToggleFollow,
  });

  final FollowListEntry entry;
  final FollowListKind kind;
  final bool pending;
  final String followLabel;
  final String followingLabel;
  final String followBackLabel;
  final String followsYouLabel;
  final VoidCallback onOpen;
  final VoidCallback? onToggleFollow;

  UserSummary get user => entry.user;

  bool get isMe => entry.isMe;

  bool get following => entry.isFollowing;

  bool get followsMe => entry.followsMe;

  String get buttonLabel => isMe
      ? ''
      : following
      ? followingLabel
      : followsMe
      ? followBackLabel
      : followLabel;
}
