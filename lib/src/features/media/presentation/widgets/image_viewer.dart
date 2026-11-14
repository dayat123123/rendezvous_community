import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/media/pasted_image.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/media/domain/repositories/media_repository.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/images/community_image_loader.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_menu.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, ShareResultStatus;

typedef CommunityImageSaver =
    Future<bool> Function(BuildContext context, Uint8List bytes, {required String name, required String mimeType});

typedef CommunityImageCopier = Future<void> Function(Uint8List bytes);

const _surface = Color(0xFF1F1F1F);
const _onSurface = Color(0xFFE3E3E3);
const _muted = Color(0xFFA8ACB1);
const _minScale = 1.0;
const _maxScale = 5.0;
const _zoomStep = 1.5;
const _iconSize = 21.0;

bool get _savesWithDialog =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => true,
      _ => false,
    };

bool get _canCopyImages =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

Future<bool> saveCommunityImage(
  BuildContext context,
  Uint8List bytes, {
  required String name,
  required String mimeType,
}) async {
  final file = XFile.fromData(bytes, mimeType: mimeType, name: name, length: bytes.length);
  if (kIsWeb) {
    await file.saveTo(name);
    return true;
  }
  if (_savesWithDialog) {
    final extension = name.split('.').last;
    final location = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: [
        XTypeGroup(label: 'images', extensions: [extension], mimeTypes: [mimeType]),
      ],
    );
    if (location == null) return false;
    await file.saveTo(location.path);
    return true;
  }
  final box = context.findRenderObject();
  final origin = box is RenderBox && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
  final result = await SharePlus.instance.share(
    ShareParams(files: [file], fileNameOverrides: [name], sharePositionOrigin: origin),
  );
  return result.status != ShareResultStatus.dismissed;
}

Future<void> copyCommunityImage(Uint8List bytes) => Pasteboard.writeImage(bytes);

String _fileName(String mimeType, DateTime now) {
  String two(int value) => value.toString().padLeft(2, '0');
  final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
  return 'chat-image-$stamp.${imageExtension(mimeType)}';
}

Future<void> showCommunityImageViewer(
  BuildContext context, {
  required List<Attachment> images,
  int initialIndex = 0,
  UserSummary? sender,
  DateTime? sentAt,
  VoidCallback? onReply,
  List<String> reactionChoices = const [],
  ValueChanged<String>? onReact,
  CommunityImageSaver saver = saveCommunityImage,
  CommunityImageCopier? copier,
}) {
  if (images.isEmpty) return Future.value();
  final deps = CommunityScope.of(context);
  final loader = CommunityImageScope.of(context);
  final persist = CommunityImagePersistence.of(context);
  final carry = carryCommunityBuilders(context);
  final l10n = context.communityL10n;
  final time = sentAt == null ? null : l10n.messageInfoTime(l10n.dayLabel(sentAt), l10n.clockTime(sentAt));
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: _surface,
    pageBuilder: (dialogContext, _, _) => carry(
      CommunityScope(
        dependencies: deps,
        child: CommunityImageScope(
          loader: loader,
          child: CommunityImagePersistence(
            persist: persist,
            child: _ImageViewer(
              images: images,
              initialIndex: initialIndex.clamp(0, images.length - 1),
              media: deps.media,
              loader: loader,
              persist: persist,
              saver: saver,
              copier: copier ?? (_canCopyImages ? copyCommunityImage : null),
              sender: sender,
              timeLabel: time,
              onReply: onReply,
              reactionChoices: reactionChoices,
              onReact: onReact,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({
    required this.images,
    required this.initialIndex,
    required this.media,
    required this.loader,
    required this.persist,
    required this.saver,
    required this.copier,
    required this.sender,
    required this.timeLabel,
    required this.onReply,
    required this.reactionChoices,
    required this.onReact,
  });

  final List<Attachment> images;
  final int initialIndex;
  final MediaRepository media;
  final CommunityImageLoader loader;
  final bool persist;
  final CommunityImageSaver saver;
  final CommunityImageCopier? copier;
  final UserSummary? sender;
  final String? timeLabel;
  final VoidCallback? onReply;
  final List<String> reactionChoices;
  final ValueChanged<String>? onReact;

  bool _persists(Attachment attachment) => persist && (attachment.bucket ?? attachmentBucket) != supportDocumentBucket;

  Future<Uint8List> _bytes(Attachment attachment) => loader.load(
    cacheKey: imageCacheKeyForObject(attachment.bucket ?? attachmentBucket, attachment.path),
    resolve: () => media.attachmentImage(attachment),
    persist: _persists(attachment),
  );

  Future<String?> _download(BuildContext context, Attachment attachment) async {
    final l10n = context.communityL10n;
    try {
      final bytes = await _bytes(attachment);
      if (!context.mounted) return null;
      final mimeType = sniffImageMime(bytes) ?? attachment.mime ?? 'image/jpeg';
      final saved = await saver(context, bytes, name: _fileName(mimeType, DateTime.now()), mimeType: mimeType);
      return saved ? l10n.imageSaved : null;
    } on Object {
      return l10n.imageSaveFailed;
    }
  }

  Future<String?> _copy(BuildContext context, Attachment attachment, CommunityImageCopier copy) async {
    final l10n = context.communityL10n;
    try {
      await copy(await _bytes(attachment));
      return l10n.imageCopied;
    } on Object {
      return l10n.imageCopyFailed;
    }
  }

  Widget _image(Attachment attachment) {
    final bucket = attachment.bucket ?? attachmentBucket;
    return CommunityNetworkImage(
      cacheKey: imageCacheKeyForObject(bucket, attachment.path),
      source: () => media.attachmentImage(attachment),
      persist: _persists(attachment),
      fit: BoxFit.contain,
      placeholder: const Center(
        child: SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: _muted)),
      ),
      error: const Center(child: Icon(Icons.broken_image_outlined, color: _muted, size: 44)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = copier;
    final reply = onReply;
    final details = CommunityImageViewerDetails(
      attachments: images,
      initialIndex: initialIndex,
      image: _image,
      onClose: () => Navigator.of(context).maybePop(),
      onDownload: (attachment) => _download(context, attachment),
      onCopy: copy == null ? null : (attachment) => _copy(context, attachment, copy),
      sender: sender,
      timeLabel: timeLabel,
      onReply: reply == null
          ? null
          : () {
              Navigator.of(context).maybePop();
              reply();
            },
      reactionChoices: reactionChoices,
      onReact: onReact,
    );
    return buildSharedPart((b) => b.imageViewer, context, details, _DefaultImageViewer(details: details));
  }
}

class _DefaultImageViewer extends StatefulWidget {
  const _DefaultImageViewer({required this.details});

  final CommunityImageViewerDetails details;

  @override
  State<_DefaultImageViewer> createState() => _DefaultImageViewerState();
}

class _DefaultImageViewerState extends State<_DefaultImageViewer> {
  late final _pages = PageController(initialPage: widget.details.initialIndex);
  late int _index = widget.details.initialIndex;
  final _zoom = <int, TransformationController>{};
  final _turns = <int, int>{};
  final _focus = FocusNode();
  final _viewport = GlobalKey();
  bool _busy = false;
  String? _toast;
  Timer? _toastTimer;

  @override
  void dispose() {
    _toastTimer?.cancel();
    for (final controller in _zoom.values) {
      controller.dispose();
    }
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _count => widget.details.attachments.length;

  TransformationController _controller(int index) =>
      _zoom.putIfAbsent(index, () => TransformationController()..addListener(_onZoom));

  void _onZoom() {
    if (mounted) setState(() {});
  }

  double get _scale => _controller(_index).value.getMaxScaleOnAxis();

  void _zoomBy(double factor) {
    final controller = _controller(_index);
    final target = (_scale * factor).clamp(_minScale, _maxScale);
    if (target <= _minScale + 0.01) {
      controller.value = Matrix4.identity();
      return;
    }
    final box = _viewport.currentContext?.findRenderObject();
    final size = box is RenderBox && box.hasSize ? box.size : MediaQuery.sizeOf(context);
    final center = Offset(size.width / 2, size.height / 2);
    final focal = controller.toScene(center);
    final relative = target / _scale;
    controller.value = controller.value.clone()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(relative, relative, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1);
  }

  void _fit() {
    _controller(_index).value = Matrix4.identity();
    setState(() => _turns[_index] = 0);
  }

  void _rotate() => setState(() => _turns[_index] = ((_turns[_index] ?? 0) + 1) % 4);

  void _go(int delta) {
    final target = _index + delta;
    if (target < 0 || target >= _count) return;
    unawaited(_pages.animateToPage(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic));
  }

  void _show(String? message) {
    if (message == null || !mounted) return;
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _run(Future<String?> Function(Attachment attachment) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _show(await action(widget.details.attachments[_index]));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.details;
    final l10n = context.communityL10n;
    final multiple = _count > 1;
    final zoomed = _scale > _minScale + 0.01;
    final onCopy = d.onCopy;
    final onReply = d.onReply;
    final onReact = d.onReact;
    final icons = CommunityStyle.of(context).icons;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
        const SingleActivator(LogicalKeyboardKey.equal): () => _zoomBy(_zoomStep),
        const SingleActivator(LogicalKeyboardKey.add): () => _zoomBy(_zoomStep),
        const SingleActivator(LogicalKeyboardKey.numpadAdd): () => _zoomBy(_zoomStep),
        const SingleActivator(LogicalKeyboardKey.minus): () => _zoomBy(1 / _zoomStep),
        const SingleActivator(LogicalKeyboardKey.numpadSubtract): () => _zoomBy(1 / _zoomStep),
        const SingleActivator(LogicalKeyboardKey.digit0): _fit,
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: Material(
          color: _surface,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SenderLabel(sender: d.sender, timeLabel: d.timeLabel),
                      ),
                      _BarButton(
                        icon: Icons.zoom_out_outlined,
                        tooltip: l10n.imageZoomOut,
                        onPressed: zoomed ? () => _zoomBy(1 / _zoomStep) : null,
                      ),
                      _BarButton(
                        icon: Icons.zoom_in_outlined,
                        tooltip: l10n.imageZoomIn,
                        onPressed: _scale < _maxScale - 0.01 ? () => _zoomBy(_zoomStep) : null,
                      ),
                      if (onReply != null)
                        _BarButton(icon: icons.reply, size: 20, tooltip: l10n.replyToMessage, onPressed: onReply),
                      if (onReact != null && d.reactionChoices.isNotEmpty)
                        _ReactButton(choices: d.reactionChoices, onReact: onReact),
                      if (onCopy != null)
                        _BarButton(
                          icon: icons.copy,
                          size: 16,
                          tooltip: l10n.imageCopy,
                          onPressed: _busy ? null : () => _run(onCopy),
                        ),
                      _BarButton(
                        icon: icons.download,
                        tooltip: l10n.imageDownload,
                        onPressed: _busy ? null : () => _run(d.onDownload),
                      ),
                      _MoreButton(
                        tooltip: l10n.moreActions,
                        items: [
                          (Icons.rotate_right_outlined, l10n.imageRotate, _rotate),
                          (Icons.fit_screen_outlined, l10n.imageActualSize, _fit),
                        ],
                      ),
                      const SizedBox(width: 4),
                      _BarButton(icon: Icons.close_rounded, size: 22, tooltip: l10n.close, onPressed: d.onClose),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    key: _viewport,
                    children: [
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _pages,
                          itemCount: _count,
                          physics: zoomed ? const NeverScrollableScrollPhysics() : null,
                          onPageChanged: (index) => setState(() => _index = index),
                          itemBuilder: (context, index) => GestureDetector(
                            key: ValueKey('image-viewer-backdrop-$index'),
                            behavior: HitTestBehavior.opaque,
                            onTap: d.onClose,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                multiple ? 72 : 24,
                                8,
                                multiple ? 72 : 24,
                                multiple ? 60 : 24,
                              ),
                              child: InteractiveViewer(
                                transformationController: _controller(index),
                                maxScale: _maxScale,
                                child: Center(
                                  child: GestureDetector(
                                    key: ValueKey('image-viewer-image-$index'),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {},
                                    child: RotatedBox(
                                      quarterTurns: _turns[index] ?? 0,
                                      child: d.image(d.attachments[index]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (multiple)
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _NavButton(
                              icon: Icons.chevron_left_rounded,
                              tooltip: l10n.imagePrevious,
                              onPressed: _index > 0 ? () => _go(-1) : null,
                            ),
                          ),
                        ),
                      if (multiple)
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _NavButton(
                              icon: Icons.chevron_right_rounded,
                              tooltip: l10n.imageNext,
                              onPressed: _index < _count - 1 ? () => _go(1) : null,
                            ),
                          ),
                        ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedOpacity(
                              opacity: _toast == null ? 0 : 1,
                              duration: const Duration(milliseconds: 160),
                              child: _Pill(text: _toast ?? '', strong: true),
                            ),
                            if (multiple) ...[
                              const SizedBox(height: 8),
                              _Pill(text: l10n.imageCounter(_index + 1, _count)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SenderLabel extends StatelessWidget {
  const _SenderLabel({required this.sender, required this.timeLabel});

  final UserSummary? sender;
  final String? timeLabel;

  @override
  Widget build(BuildContext context) {
    final user = sender;
    final time = timeLabel;
    if (user == null && time == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        if (user != null) ...[CommunityAvatar(user: user, radius: 16), const SizedBox(width: 12)],
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null)
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    color: _onSurface,
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (time != null)
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(
                    color: _onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

ButtonStyle _barStyle() => IconButton.styleFrom(
  foregroundColor: _onSurface,
  disabledForegroundColor: _onSurface.withValues(alpha: 0.32),
  hoverColor: Colors.white.withValues(alpha: 0.08),
  highlightColor: Colors.white.withValues(alpha: 0.12),
  fixedSize: const Size.square(40),
  minimumSize: const Size.square(40),
  padding: EdgeInsets.zero,
);

class _BarButton extends StatelessWidget {
  const _BarButton({required this.icon, required this.tooltip, this.onPressed, this.size = _iconSize});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: tooltip, style: _barStyle(), iconSize: size, onPressed: onPressed, icon: Icon(icon));
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.tooltip, required this.items});

  final String tooltip;
  final List<(IconData, String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) => PopupMenuButton<VoidCallback>(
    tooltip: tooltip,
    style: _barStyle(),
    iconSize: _iconSize,
    icon: Icon(CommunityStyle.of(context).icons.moreVertical),
    color: const Color(0xFF2D2E30),
    onSelected: (action) => action(),
    itemBuilder: (menuContext) => [
      for (final (icon, label, action) in items)
        communityMenuItem<VoidCallback>(menuContext, value: action, icon: icon, label: label, color: _onSurface),
    ],
  );
}

class _ReactButton extends StatelessWidget {
  const _ReactButton({required this.choices, required this.onReact});

  final List<String> choices;
  final ValueChanged<String> onReact;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: context.communityL10n.imageReact,
    style: _barStyle(),
    iconSize: _iconSize,
    icon: Icon(CommunityStyle.of(context).icons.react, size: 17),
    color: const Color(0xFF2D2E30),
    onSelected: onReact,
    itemBuilder: (_) => [
      PopupMenuItem<String>(
        enabled: false,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final emoji in choices)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.of(context).pop();
                  onReact(emoji);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: onPressed == null ? 0.35 : 1,
    duration: const Duration(milliseconds: 150),
    child: IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        disabledBackgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: _onSurface,
        disabledForegroundColor: _onSurface.withValues(alpha: 0.4),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        fixedSize: const Size.square(40),
        shape: const CircleBorder(),
      ),
      iconSize: 26,
      onPressed: onPressed,
      icon: Icon(icon),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: strong ? const Color(0xFF3C4043) : Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _onSurface, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
