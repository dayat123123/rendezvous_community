import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/features/account/presentation/widgets/settings_visuals.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

enum CommunityUnavailableReason { socialDisabled, featureDisabled }

typedef CommunityUnavailableBuilder =
    Widget Function(BuildContext context, CommunityUnavailableReason reason, Widget fallback);

class CommunityAvailabilityScope extends InheritedWidget {
  const CommunityAvailabilityScope({super.key, required this.builder, required super.child});

  final CommunityUnavailableBuilder builder;

  static CommunityUnavailableBuilder? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CommunityAvailabilityScope>()?.builder;

  @override
  bool updateShouldNotify(CommunityAvailabilityScope oldWidget) => !identical(builder, oldWidget.builder);
}

class CommunitySocialGate extends StatelessWidget {
  const CommunitySocialGate({super.key, required this.child, this.feature, this.unavailableBuilder});

  final Widget child;
  final String? feature;
  final CommunityUnavailableBuilder? unavailableBuilder;

  @override
  Widget build(BuildContext context) {
    final features = CommunityFeatureScope.maybeOf(context);
    if (features == null) return child;
    return ValueListenableBuilder<ClientConfig>(
      valueListenable: features.configService.listenable,
      child: child,
      builder: (context, config, child) {
        final feature = this.feature;
        if (config.socialEnabled && (feature == null || config.flag(feature))) return child!;
        final reason = config.socialEnabled
            ? CommunityUnavailableReason.featureDisabled
            : CommunityUnavailableReason.socialDisabled;
        final fallback = CommunityUnavailableView(reason: reason);
        final builder = unavailableBuilder ?? CommunityAvailabilityScope.maybeOf(context);
        return builder == null ? fallback : builder(context, reason, fallback);
      },
    );
  }
}

class CommunityUnavailableView extends StatelessWidget {
  const CommunityUnavailableView({super.key, this.reason = CommunityUnavailableReason.socialDisabled});

  final CommunityUnavailableReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final social = reason == CommunityUnavailableReason.socialDisabled;
    final details = CommunityUnavailableDetails(
      reason: reason,
      icon: social ? Icons.construction_outlined : Icons.visibility_off_outlined,
      title: social ? l10n.socialUnavailableTitle : null,
      message: social ? l10n.socialUnavailableBody : l10n.featureUnavailable,
    );
    return buildSystemPart((b) => b.unavailable, context, details, _DefaultUnavailableView(details: details));
  }
}

class _DefaultUnavailableView extends StatelessWidget {
  const _DefaultUnavailableView({required this.details});

  final CommunityUnavailableDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final title = details.title;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommunityToneIcon(icon: details.icon, size: 64),
              SizedBox(height: spacing.lg),
              if (title != null) ...[
                Text(title, textAlign: TextAlign.center, style: style.typography.title),
                SizedBox(height: spacing.xs + spacing.xxs),
              ],
              Text(
                details.message,
                textAlign: TextAlign.center,
                style: style.typography.body.copyWith(color: style.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CommunityUpdateRequiredHandler = void Function(BuildContext context, ClientConfig config);

class CommunityUpdateListener extends StatefulWidget {
  const CommunityUpdateListener({super.key, required this.onUpdateRequired, required this.child});

  final CommunityUpdateRequiredHandler onUpdateRequired;
  final Widget child;

  @override
  State<CommunityUpdateListener> createState() => _CommunityUpdateListenerState();
}

class _CommunityUpdateListenerState extends State<CommunityUpdateListener> {
  CommunityFeatureDependencies? _features;
  bool _notified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final features = CommunityFeatureScope.maybeOf(context);
    if (identical(features, _features)) return;
    _features?.configService.listenable.removeListener(_check);
    _features = features;
    features?.configService.listenable.addListener(_check);
    _check();
  }

  void _check() {
    final config = _features?.configService.current;
    if (config == null) return;
    if (!config.updateRequired) {
      _notified = false;
      return;
    }
    if (_notified) return;
    _notified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onUpdateRequired(context, config);
    });
  }

  @override
  void dispose() {
    _features?.configService.listenable.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
