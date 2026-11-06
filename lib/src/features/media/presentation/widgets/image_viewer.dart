import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_image_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/media/pasted_image.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/media/domain/repositories/media_repository.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_builders.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';
import 'package:rendezvous_community/src/shared/presentation/images/community_image_loader.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, ShareResultStatus;

typedef CommunityImageSaver =
    Future<bool> Function(BuildContext context, Uint8List bytes, {required String name, required String mimeType});

bool get _savesWithDialog =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => true,
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

String _fileName(String mimeType, DateTime now) {
  String two(int value) => value.toString().padLeft(2, '0');
  final stamp = '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
  return 'chat-image-$stamp.${imageExtension(mimeType)}';
}

Future<void> showCommunityImageViewer(
  BuildContext context, {
  required List<Attachment> images,
  int initialIndex = 0,
  CommunityImageSaver saver = saveCommunityImage,
}) {
  if (images.isEmpty) return Future.value();
  final deps = CommunityScope.of(context);
  final loader = CommunityImageScope.of(context);
  final persist = CommunityImagePersistence.of(context);
  final carry = carryCommunityBuilders(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black,
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
  });

  final List<Attachment> images;
  final int initialIndex;
  final MediaRepository media;
  final CommunityImageLoader loader;
  final bool persist;
  final CommunityImageSaver saver;

  bool _persists(Attachment attachment) => persist && (attachment.bucket ?? attachmentBucket) != supportDocumentBucket;

  Future<void> _download(BuildContext context, Attachment attachment) async {
    final l10n = context.communityL10n;
    try {
      final bucket = attachment.bucket ?? attachmentBucket;
      final bytes = await loader.load(
        cacheKey: imageCacheKeyForObject(bucket, attachment.path),
        resolve: () => media.attachmentImage(attachment),
        persist: _persists(attachment),
      );
      if (!context.mounted) return;
      final mimeType = sniffImageMime(bytes) ?? attachment.mime ?? 'image/jpeg';
      final saved = await saver(context, bytes, name: _fileName(mimeType, DateTime.now()), mimeType: mimeType);
      if (saved && context.mounted) showCommunityMessage(context, l10n.imageSaved);
    } on Object {
      if (context.mounted) showCommunityMessage(context, l10n.imageSaveFailed);
    }
  }

  Widget _image(Attachment attachment) {
    final bucket = attachment.bucket ?? attachmentBucket;
    return CommunityNetworkImage(
      cacheKey: imageCacheKeyForObject(bucket, attachment.path),
      source: () => media.attachmentImage(attachment),
      persist: _persists(attachment),
      fit: BoxFit.contain,
      placeholder: const Center(child: CircularProgressIndicator(color: Colors.white70)),
      error: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = CommunityImageViewerDetails(
      attachments: images,
      initialIndex: initialIndex,
      image: _image,
      onClose: () => Navigator.of(context).maybePop(),
      onDownload: (attachment) => _download(context, attachment),
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
  final _focus = FocusNode();
  bool _downloading = false;

  @override
  void dispose() {
    _pages.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _count => widget.details.attachments.length;

  void _go(int delta) {
    final target = _index + delta;
    if (target < 0 || target >= _count) return;
    unawaited(_pages.animateToPage(target, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic));
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      await widget.details.onDownload(widget.details.attachments[_index]);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.details;
    final l10n = context.communityL10n;
    final multiple = _count > 1;
    const onDark = Colors.white;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
      },
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: _count,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) =>
                        InteractiveViewer(maxScale: 5, child: Center(child: d.image(d.attachments[index]))),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n.close,
                          color: onDark,
                          onPressed: d.onClose,
                          icon: const Icon(Icons.close),
                        ),
                        if (multiple)
                          Text(
                            l10n.imageCounter(_index + 1, _count),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: onDark),
                          ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.imageDownload,
                          color: onDark,
                          onPressed: _downloading ? null : _download,
                          icon: _downloading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: onDark),
                                )
                              : const Icon(Icons.download_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
                if (multiple && _index > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton.filledTonal(
                        tooltip: l10n.imagePrevious,
                        onPressed: () => _go(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                    ),
                  ),
                if (multiple && _index < _count - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton.filledTonal(
                        tooltip: l10n.imageNext,
                        onPressed: () => _go(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
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
