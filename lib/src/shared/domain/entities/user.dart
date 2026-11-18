import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

String communityHandle(String username) => '@${username.toLowerCase()}';

@freezed
abstract class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default(false) bool isOfficial,
  }) = _UserSummary;

  const UserSummary._();

  String get name => (displayName?.trim().isNotEmpty ?? false) ? displayName!.trim() : username;

  String get handle => communityHandle(username);

  bool get isDeleted => username.trim().isEmpty || _deletedUsername.hasMatch(username);
}

final RegExp _deletedUsername = RegExp(r'^deleted_[0-9a-f]{12}$');
