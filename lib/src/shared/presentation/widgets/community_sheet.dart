import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

Future<T?> showCommunitySheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final carry = carryCommunityBuilders(context);
  final deps = CommunityScope.maybeOf(context);
  final features = CommunityFeatureScope.maybeOf(context);
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    backgroundColor: CommunityStyle.of(context).surface,
    builder: (_) {
      Widget child = Builder(builder: builder);
      if (features != null) child = CommunityFeatureScope(dependencies: features, child: child);
      if (deps != null) child = CommunityScope(dependencies: deps, child: child);
      return carry(child);
    },
  );
}
