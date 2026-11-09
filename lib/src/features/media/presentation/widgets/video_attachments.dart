import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/core/network/authorized_image.dart';
import 'package:rendezvous_community/src/core/storage/image_disk_cache.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_builders.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/features/media/domain/repositories/media_repository.dart';
import 'package:rendezvous_community/src/features/media/presentation/file_opener.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/document_attachments.dart';
import 'package:rendezvous_community/src/features/media/presentation/widgets/video_player_page.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_network_image.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';

typedef CommunityVideoLauncher = Future<void> Function(BuildContext context, Attachment video, Uri uri);

const _maxVideoHeight = 220.0;

String videoDurationLabel(double? seconds) {
  if (seconds == null || seconds.isNaN || seconds < 0) return '';
  final total = seconds.round();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

Attachment? videoThumbnailOf(Attachment video) {
  final thumbnail = video.thumbnail;
  if (thumbnail == null || thumbnail.isEmpty) return null;
  return Attachment(path: thumbnail, bucket: video.bucket ?? supportVideoBucket, mime: 'image/jpeg');
}

class VideoAttachments extends StatelessWidget {
  const VideoAttachments({
    super.key,
    required this.attachments,
    required this.color,
    this.playsInApp,
    this.onPlay,
    this.onOpenExternal,
  });

  final List<Attachment> attachments;
  final Color color;
  final bool? playsInApp;
  final CommunityVideoLauncher? onPlay;
  final DocumentOpener? onOpenExternal;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final a in attachments)
        Padding(
          padding: EdgeInsets.only(bottom: CommunityStyle.of(context).spacing.xs),
          child: _VideoTile(
            attachment: a,
            color: color,
            playsInApp: playsInApp ?? communityVideoPlaysInApp(),
            onPlay: onPlay,
            onOpenExternal: onOpenExternal,
          ),
        ),
    ],
  );
}

class _VideoTile extends StatefulWidget {
  const _VideoTile({
    required this.attachment,
    required this.color,
    required this.playsInApp,
    this.onPlay,
    this.onOpenExternal,
  });

  final Attachment attachment;
  final Color color;
  final bool playsInApp;
  final CommunityVideoLauncher? onPlay;
  final DocumentOpener? onOpenExternal;

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  bool _opening = false;

  String _name(CommunityLocalizations l10n) {
    final name = widget.attachment.name ?? '';
    if (name.isNotEmpty) return name;
    final path = widget.attachment.path;
    return '${l10n.video}${path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.mp4'}';
  }

  Future<void> _play() async {
    final l10n = context.communityL10n;
    final media = CommunityScope.of(context).media;
    final a = widget.attachment;
    setState(() => _opening = true);
    try {
      final uri = await media.documentUri(a);
      if (!mounted) return;
      if (widget.playsInApp) {
        setState(() => _opening = false);
        final launch = widget.onPlay ?? _openPlayer;
        await launch(context, a, uri);
        return;
      }
      final external = widget.onOpenExternal;
      final opened = external != null
          ? await external(uri)
          : await const CommunityFileOpener().open(uri, fileName: _name(l10n), key: a.path);
      if (!opened && mounted) showCommunityMessage(context, l10n.videoOpenFailed);
    } catch (_) {
      if (mounted) showCommunityMessage(context, l10n.videoOpenFailed);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _openPlayer(BuildContext context, Attachment video, Uri uri) {
    final l10n = context.communityL10n;
    return showCommunityVideoPlayer(
      context,
      uri: uri,
      title: _name(l10n),
      onOpenExternal: () => const CommunityFileOpener().open(uri, fileName: _name(l10n), key: video.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final a = widget.attachment;
    final duration = videoDurationLabel(a.duration);
    final thumb = videoThumbnailOf(a);
    final media = CommunityScope.of(context).media;
    final details = CommunityVideoDetails(
      attachment: a,
      name: _name(l10n),
      durationLabel: duration,
      sizeLabel: documentSize(a.size),
      color: widget.color,
      playsInApp: widget.playsInApp,
      opening: _opening,
      semanticLabel: l10n.videoPlay(duration).trim(),
      thumbnail: thumb == null ? null : _Thumbnail(thumbnail: thumb, media: media),
      onPlay: _opening ? null : _play,
    );
    return buildChatPart(
      CommunityChatBuilders.of(context).video,
      context,
      details,
      _DefaultVideoTile(details: details),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.thumbnail, required this.media});

  final Attachment thumbnail;
  final MediaRepository media;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return CommunityNetworkImage(
      cacheKey: imageCacheKeyForObject(thumbnail.bucket ?? supportVideoBucket, thumbnail.path),
      source: () async => AuthorizedImage((await media.documentUri(thumbnail)).toString(), const {}),
      persist: false,
      placeholder: ColoredBox(color: style.skeleton),
      error: ColoredBox(color: style.skeleton),
    );
  }
}

class _DefaultVideoTile extends StatelessWidget {
  const _DefaultVideoTile({required this.details});

  final CommunityVideoDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final a = details.attachment;
    final w = a.width;
    final h = a.height;
    final ratio = w != null && h != null && w > 0 && h > 0 ? (w / h).clamp(0.56, 1.91).toDouble() : 16 / 9;
    const overlay = Color(0xB3000000);
    final chip = style.typography.meta.copyWith(color: Colors.white, fontWeight: FontWeight.w600);
    return Semantics(
      button: true,
      label: details.semanticLabel,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: style.radii.controlRadius,
        child: Material(
          color: style.skeleton,
          child: InkWell(
            onTap: details.onPlay,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 260.0;
                final height = (width / ratio).clamp(120.0, _maxVideoHeight);
                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      details.thumbnail ??
                          ColoredBox(
                            color: style.skeleton,
                            child: Center(child: Icon(Icons.movie_outlined, size: 40, color: style.textTertiary)),
                          ),
                      Center(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: overlay, shape: BoxShape.circle),
                          child: Padding(
                            padding: EdgeInsets.all(spacing.sm + spacing.xxs),
                            child: details.opening
                                ? const SizedBox.square(
                                    dimension: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                  )
                                : Icon(
                                    details.playsInApp ? Icons.play_arrow_rounded : Icons.open_in_new,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: spacing.sm,
                        bottom: spacing.sm,
                        right: spacing.sm,
                        child: Row(
                          children: [
                            _Chip(
                              icon: Icons.videocam_outlined,
                              label: details.durationLabel,
                              style: chip,
                              color: overlay,
                            ),
                            const Spacer(),
                            if (details.sizeLabel.isNotEmpty)
                              _Chip(label: details.sizeLabel, style: chip, color: overlay),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.style, required this.color, this.icon});

  final String label;
  final TextStyle style;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final spacing = CommunityStyle.of(context).spacing;
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(spacing.sm)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.white),
              if (label.isNotEmpty) SizedBox(width: spacing.xxs),
            ],
            if (label.isNotEmpty) Text(label, style: style),
          ],
        ),
      ),
    );
  }
}
