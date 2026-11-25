import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class CommunityWindowControls extends InheritedWidget {
  const CommunityWindowControls({super.key, required this.size, required super.child});

  final Size size;

  static Size sizeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommunityWindowControls>()?.size ?? Size.zero;

  static Widget below(BuildContext context, Widget child) {
    final reserved = sizeOf(context).height;
    if (reserved <= 0) return child;
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(top: math.max(media.padding.top, reserved)),
        viewPadding: media.viewPadding.copyWith(top: math.max(media.viewPadding.top, reserved)),
      ),
      child: child,
    );
  }

  @override
  bool updateShouldNotify(CommunityWindowControls oldWidget) => oldWidget.size != size;
}
