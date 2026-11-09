import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/rendezvous_community.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';

abstract interface class CommunityHelpDependencies {
  HelpRepository get help;
}

class CommunityHelpScope extends InheritedWidget {
  const CommunityHelpScope({super.key, required this.dependencies, required super.child});

  final CommunityHelpDependencies dependencies;

  static CommunityHelpDependencies of(BuildContext context) =>
      maybeOf(context) ?? (throw StateError('No CommunityHelpScope found and RendezvousCommunity is not initialized'));

  static CommunityHelpDependencies? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityHelpScope>()?.dependencies ??
      (RendezvousCommunity.isInitialized ? RendezvousCommunity.instance : null);

  @override
  bool updateShouldNotify(CommunityHelpScope oldWidget) => !identical(dependencies, oldWidget.dependencies);
}
