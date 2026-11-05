import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_dependencies.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/domain/services/client_config_service.dart';
import 'package:rendezvous_community/src/features/config/domain/services/community_promo_popups.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_builders.dart';
import 'package:rendezvous_community/src/features/config/presentation/builders/community_system_details.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/banner_link.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';

const communityPromoPopupMinRatio = 4 / 5;
const communityPromoPopupMaxRatio = 16 / 9;

class CommunityPromoPopupHost extends StatefulWidget {
  const CommunityPromoPopupHost({super.key, required this.child, this.enabled = true, this.onBannerLink});

  final Widget child;
  final bool enabled;
  final CommunityBannerLinkCallback? onBannerLink;

  @override
  State<CommunityPromoPopupHost> createState() => _CommunityPromoPopupHostState();
}

class _CommunityPromoPopupHostState extends State<CommunityPromoPopupHost> {
  ClientConfigService? _config;
  CommunityPromoPopups? _popups;
  bool _routeCurrent = true;
  bool _scheduled = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeCurrent = ModalRoute.isCurrentOf(context) ?? true;
    _bind();
    _schedule();
  }

  @override
  void didUpdateWidget(CommunityPromoPopupHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) _schedule();
  }

  bool _bind() {
    final config = context.communityFeatures?.configService;
    final popups = context.communityPromoPopups;
    var changed = false;
    if (!identical(config, _config)) {
      _config?.listenable.removeListener(_schedule);
      _config = config?..listenable.addListener(_schedule);
      changed = true;
    }
    if (!identical(popups, _popups)) {
      _popups?.removeListener(_schedule);
      _popups = popups?..addListener(_schedule);
      changed = true;
    }
    return changed;
  }

  void _schedule() {
    if (_scheduled || !mounted) return;
    _scheduled = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        _scheduled = false;
        unawaited(_evaluate());
      })
      ..ensureVisualUpdate();
  }

  bool get _ready {
    final popups = _popups;
    return mounted &&
        widget.enabled &&
        _routeCurrent &&
        !_busy &&
        _config != null &&
        popups != null &&
        !popups.shownThisSession;
  }

  Future<void> _evaluate() async {
    if (!_ready) return;
    final popups = _popups!;
    _busy = true;
    try {
      final banner = await popups.candidate(_config!.current);
      if (banner == null || !mounted || !widget.enabled || !_routeCurrent) return;
      if (Navigator.maybeOf(context, rootNavigator: true) == null) return;
      if (_config?.current.updateRequired ?? true) return;
      if (!popups.claim(banner)) return;
      await showCommunityPromoPopup(context, banner, onBannerLink: widget.onBannerLink, popups: popups);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _config?.listenable.removeListener(_schedule);
    _popups?.removeListener(_schedule);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bind()) _schedule();
    return widget.child;
  }
}

Future<CommunityBannerEvent> showCommunityPromoPopup(
  BuildContext context,
  CommunityBanner banner, {
  CommunityBannerLinkCallback? onBannerLink,
  CommunityPromoPopups? popups,
}) async {
  final l10n = context.communityL10n;
  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final carry = carryCommunityBuilders(context);
  final loader = CommunityImageScope.of(context);
  final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final action = await showGeneralDialog<CommunityBannerEvent>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: banner.dismissible,
    barrierLabel: l10n.promoPopupClose,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: still ? Duration.zero : const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) => themes.wrap(
      carry(
        CommunityImageScope(
          loader: loader,
          child: PopScope(
            canPop: banner.dismissible,
            child: CommunityPromoPopupCard(
              banner: banner,
              onCta: banner.link == null ? null : () => Navigator.pop(dialogContext, CommunityBannerEvent.click),
              onClose: () => Navigator.pop(dialogContext, CommunityBannerEvent.dismiss),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween<double>(begin: 0.94, end: 1).animate(curved), child: child),
      );
    },
  );
  final event = action ?? CommunityBannerEvent.dismiss;
  popups?.record(banner, event);
  if (event == CommunityBannerEvent.click && context.mounted) {
    await openCommunityBannerLink(context, banner, onBannerLink: onBannerLink);
  }
  return event;
}

class CommunityPromoPopupCard extends StatelessWidget {
  const CommunityPromoPopupCard({super.key, required this.banner, required this.onClose, this.onCta});

  final CommunityBanner banner;
  final VoidCallback? onCta;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final details = CommunityPromoPopupDetails(
      banner: banner,
      ctaLabel: banner.ctaLabel ?? l10n.promoPopupCta,
      laterLabel: onCta == null ? l10n.bannerDismiss : l10n.promoPopupLater,
      closeLabel: l10n.promoPopupClose,
      semanticLabel: l10n.promoPopupLabel,
      onCta: onCta,
      onClose: onClose,
    );
    return buildSystemPart((b) => b.popup, context, details, _DefaultPromoPopup(details: details));
  }
}

class _DefaultPromoPopup extends StatelessWidget {
  const _DefaultPromoPopup({required this.details});

  final CommunityPromoPopupDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final d = details;
    final imageUrl = d.imageUrl;
    final hasImage = imageUrl != null;
    final target = math.max(48.0, style.minTouchTarget);
    final buttonShape = RoundedRectangleBorder(borderRadius: style.radii.controlRadius);
    final buttonText = style.typography.label.copyWith(fontSize: 15);
    final onCta = d.onCta;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: d.semanticLabel,
              child: Material(
                color: style.surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(style.radii.card + spacing.sm),
                  side: Theme.of(context).brightness == Brightness.dark ? style.borderSide : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasImage) _PromoImage(url: imageUrl, onTap: onCta),
                          Padding(
                            padding: EdgeInsets.fromLTRB(spacing.lg, hasImage ? spacing.lg : spacing.xl, spacing.lg, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: !hasImage && d.dismissible ? target - spacing.xs : 0),
                                  child: Semantics(header: true, child: Text(d.title, style: style.typography.title)),
                                ),
                                if (d.body.isNotEmpty) ...[
                                  SizedBox(height: spacing.sm),
                                  Text(d.body, style: style.typography.body.copyWith(color: style.textSecondary)),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              spacing.lg,
                              spacing.lg,
                              spacing.lg,
                              onCta == null ? spacing.lg : spacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: style.accent,
                                    foregroundColor: style.onAccent,
                                    minimumSize: Size.fromHeight(target),
                                    shape: buttonShape,
                                    textStyle: buttonText,
                                  ),
                                  onPressed: onCta ?? d.onClose,
                                  child: Text(onCta == null ? d.laterLabel : d.ctaLabel),
                                ),
                                if (onCta != null) ...[
                                  SizedBox(height: spacing.xs),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: style.textSecondary,
                                      minimumSize: Size.fromHeight(target),
                                      shape: buttonShape,
                                      textStyle: buttonText,
                                    ),
                                    onPressed: d.onClose,
                                    child: Text(d.laterLabel),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (d.dismissible)
                      Positioned(
                        top: spacing.sm,
                        right: spacing.sm,
                        child: IconButton(
                          tooltip: d.closeLabel,
                          onPressed: d.onClose,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(36),
                            tapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: hasImage ? Colors.black.withValues(alpha: 0.45) : null,
                            foregroundColor: hasImage ? Colors.white : style.textSecondary,
                          ),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoImage extends StatelessWidget {
  const _PromoImage({required this.url, this.onTap});

  final String url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth ? constraints.maxWidth : 360.0;
      final image = _SizedPromoImage(
        provider: communityUrlImageProvider(context, url, width: width),
        width: width,
      );
      final onTap = this.onTap;
      return ExcludeSemantics(
        child: onTap == null
            ? image
            : MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: image),
              ),
      );
    },
  );
}

class _SizedPromoImage extends StatefulWidget {
  const _SizedPromoImage({required this.provider, required this.width});

  final ImageProvider provider;
  final double width;

  @override
  State<_SizedPromoImage> createState() => _SizedPromoImageState();
}

class _SizedPromoImageState extends State<_SizedPromoImage> {
  double _ratio = communityPromoPopupMaxRatio;
  ImageStream? _stream;
  late final _listener = ImageStreamListener(_onImage, onError: (_, _) {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_SizedPromoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider != oldWidget.provider) _resolve();
  }

  void _resolve() {
    final stream = widget.provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool _) {
    final width = info.image.width;
    final height = info.image.height;
    info.dispose();
    if (!mounted || width <= 0 || height <= 0) return;
    final ratio = (width / height).clamp(communityPromoPopupMinRatio, communityPromoPopupMaxRatio).toDouble();
    if (ratio != _ratio) setState(() => _ratio = ratio);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.width,
    height: widget.width / _ratio,
    child: Image(
      image: widget.provider,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      frameBuilder: (context, child, frame, synchronous) =>
          frame == null && !synchronous ? communityImagePlaceholder() : child,
      errorBuilder: (context, _, _) => communityImagePlaceholder(failed: true),
    ),
  );
}
