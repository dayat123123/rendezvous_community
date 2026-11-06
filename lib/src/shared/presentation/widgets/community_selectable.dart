import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';

class CommunitySelectable extends StatelessWidget {
  const CommunitySelectable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => kIsWeb || isDesktopPlatform(context) ? SelectionArea(child: child) : child;
}
