import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
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

class CommunitySheetPresentation extends InheritedWidget {
  const CommunitySheetPresentation({super.key, required this.dialog, required super.child});

  final bool dialog;

  static bool isDialog(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommunitySheetPresentation>()?.dialog ?? false;

  @override
  bool updateShouldNotify(CommunitySheetPresentation oldWidget) => dialog != oldWidget.dialog;
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
  Widget scoped(Widget child, {required bool dialog}) {
    child = CommunitySheetPresentation(dialog: dialog, child: child);
    if (features != null) child = CommunityFeatureScope(dependencies: features, child: child);
    if (deps != null) child = CommunityScope(dependencies: deps, child: child);
    return carry(child);
  }

  if (!CommunitySheetLayout.usesBottomSheet(context)) {
    final frame = CommunitySharedBuilders.of(context, listen: false).sheetDialog;
    return showDialog<T>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) {
        final details = CommunitySheetDialogDetails(
          child: scoped(Builder(builder: builder), dialog: true),
          onClose: () => Navigator.pop(dialogContext),
        );
        return buildCommunityPart(frame, dialogContext, details, _DefaultSheetDialog(details: details));
      },
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    showDragHandle: true,
    backgroundColor: style.surface,
    builder: (_) => scoped(Builder(builder: builder), dialog: false),
  );
}

class _DefaultSheetDialog extends StatelessWidget {
  const _DefaultSheetDialog({required this.details});

  final CommunitySheetDialogDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final height = MediaQuery.sizeOf(context).height;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: CommunitySheetLayout.dialogMaxWidth, maxHeight: height * 0.85),
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.symmetric(vertical: style.spacing.md), child: details.child),
            Positioned(
              top: style.spacing.xs,
              right: style.spacing.xs,
              child: IconButton(
                key: const ValueKey('community-sheet-close'),
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                color: style.textSecondary,
                icon: const Icon(Icons.close_rounded),
                onPressed: details.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
