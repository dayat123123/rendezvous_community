import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

abstract interface class CommunityUserChanges {
  Stream<UserSummary?> get userChanges;
}

class CommunityCurrentUserBuilder extends StatelessWidget {
  const CommunityCurrentUserBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, UserSummary? user) builder;

  @override
  Widget build(BuildContext context) {
    final dependencies = CommunityScope.of(context);
    if (dependencies case final CommunityUserChanges source) {
      return StreamBuilder<UserSummary?>(
        stream: source.userChanges,
        builder: (context, _) => builder(context, dependencies.currentUser),
      );
    }
    return builder(context, dependencies.currentUser);
  }
}
