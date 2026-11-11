import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required UserSummary user,
    String? bio,
    required int followerCount,
    required int followingCount,
    required int postCount,
    required DateTime createdAt,
    required bool isMe,
    required bool isFollowing,
    required bool followsMe,
    required bool isBlocked,
  }) = _UserProfile;
}

@freezed
abstract class SuggestedUser with _$SuggestedUser {
  const factory SuggestedUser({
    required UserSummary user,
    @Default(0) int followerCount,
    @Default(0) int mutualCount,
    @Default(false) bool isOfficial,
  }) = _SuggestedUser;
}

enum FollowListKind { followers, following }

@freezed
abstract class FollowListEntry with _$FollowListEntry {
  const factory FollowListEntry({
    required UserSummary user,
    @Default(false) bool isMe,
    @Default(false) bool isFollowing,
    @Default(false) bool followsMe,
    DateTime? followedAt,
    String? cursor,
  }) = _FollowListEntry;
}
