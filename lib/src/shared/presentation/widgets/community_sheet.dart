import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

abstract final class CommunitySheetLayout {
  static const double phoneMaxWidth = 700;

  static const double phoneShortestSide = 600;

  static const double dialogMaxWidth = 440;

  static Size windowSize(BuildContext context) {
    final view = View.maybeOf(context);
    if (view == null) return MediaQuery.sizeOf(context);
    return view.physicalSize / view.devicePixelRatio;
  }

  static bool usesBottomSheet(BuildContext context) {
    final size = windowSize(context);
    if (size.width < phoneMaxWidth) return true;
    final touch = switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
    return touch && size.shortestSide < phoneShortestSide;
  }
}

Future<T?> showCommunitySheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final carry = carryCommunityBuilders(context);
  final deps = CommunityScope.maybeOf(context);
  final features = CommunityFeatureScope.maybeOf(context);
  final style = CommunityStyle.of(context);
  Widget scoped(Widget child) {
    if (features != null) child = CommunityFeatureScope(dependencies: features, child: child);
    if (deps != null) child = CommunityScope(dependencies: deps, child: child);
    return carry(child);
  }

  if (!CommunitySheetLayout.usesBottomSheet(context)) {
    return showDialog<T>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        final height = MediaQuery.sizeOf(dialogContext).height;
        return Dialog(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: CommunitySheetLayout.dialogMaxWidth, maxHeight: height * 0.85),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: style.spacing.md),
              child: scoped(Builder(builder: builder)),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    backgroundColor: style.surface,
    builder: (_) => scoped(Builder(builder: builder)),
  );
}
