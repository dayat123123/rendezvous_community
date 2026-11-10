import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/rendezvous_community.dart';

@immutable
class CommunityScrollSettings {
  const CommunityScrollSettings({this.behavior, this.pullToRefresh = true});

  static const defaults = CommunityScrollSettings();

  final ScrollBehavior? behavior;
  final bool pullToRefresh;

  @override
  bool operator ==(Object other) =>
      other is CommunityScrollSettings && other.behavior == behavior && other.pullToRefresh == pullToRefresh;

  @override
  int get hashCode => Object.hash(behavior, pullToRefresh);
}

class CommunityMouseDragScrollBehavior extends MaterialScrollBehavior {
  const CommunityMouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {...super.dragDevices, PointerDeviceKind.mouse};
}

class CommunityScrollScope extends InheritedWidget {
  const CommunityScrollScope({super.key, required this.settings, required super.child});

  final CommunityScrollSettings settings;

  static CommunityScrollSettings of(BuildContext context) {
    final scoped = context.dependOnInheritedWidgetOfExactType<CommunityScrollScope>()?.settings;
    if (scoped != null) return scoped;
    final dependencies = CommunityScope.maybeOf(context);
    return dependencies is RendezvousCommunity ? dependencies.scroll : CommunityScrollSettings.defaults;
  }

  static CommunityScrollSettings? maybeScoped(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityScrollScope>()?.settings;

  @override
  bool updateShouldNotify(CommunityScrollScope oldWidget) => settings != oldWidget.settings;
}

class CommunityScrollArea extends StatelessWidget {
  const CommunityScrollArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = CommunityScrollScope.of(context).behavior;
    return behavior == null ? child : ScrollConfiguration(behavior: behavior, child: child);
  }
}

class CommunityRefresh extends StatelessWidget {
  const CommunityRefresh({super.key, required this.onRefresh, required this.child});

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final settings = CommunityScrollScope.of(context);
    final Widget content = settings.pullToRefresh ? RefreshIndicator(onRefresh: onRefresh, child: child) : child;
    return CommunityScrollArea(child: content);
  }
}
