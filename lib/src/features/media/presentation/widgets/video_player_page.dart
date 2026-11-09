import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:video_player/video_player.dart';

typedef CommunityVideoControllerFactory = VideoPlayerController Function(Uri uri);

VideoPlayerController _networkController(Uri uri) => VideoPlayerController.networkUrl(uri);

Future<void> showCommunityVideoPlayer(
  BuildContext context, {
  required Uri uri,
  required String title,
  Future<bool> Function()? onOpenExternal,
  CommunityVideoControllerFactory controller = _networkController,
}) => Navigator.of(context, rootNavigator: true).push<void>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) =>
        CommunityVideoPlayerPage(uri: uri, title: title, onOpenExternal: onOpenExternal, controller: controller),
  ),
);

class CommunityVideoPlayerPage extends StatefulWidget {
  const CommunityVideoPlayerPage({
    super.key,
    required this.uri,
    required this.title,
    this.onOpenExternal,
    this.controller = _networkController,
  });

  final Uri uri;
  final String title;
  final Future<bool> Function()? onOpenExternal;
  final CommunityVideoControllerFactory controller;

  @override
  State<CommunityVideoPlayerPage> createState() => _CommunityVideoPlayerPageState();
}

class _CommunityVideoPlayerPageState extends State<CommunityVideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final controller = widget.controller(widget.uri);
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      await controller.play();
    } catch (error) {
      CommunityLoggers.chat.warning('Video playback could not start', error);
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    unawaited(_controller?.dispose());
    super.dispose();
  }

  Future<void> _openExternal() async {
    final open = widget.onOpenExternal;
    if (open == null) return;
    final l10n = context.communityL10n;
    var opened = false;
    try {
      opened = await open();
    } catch (_) {}
    if (!opened && mounted) showCommunityMessage(context, l10n.videoOpenFailed);
  }

  void _toggle(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      unawaited(controller.pause());
    } else {
      unawaited(controller.play());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (widget.onOpenExternal != null)
            IconButton(tooltip: l10n.videoOpenExternal, icon: const Icon(Icons.open_in_new), onPressed: _openExternal),
        ],
      ),
      body: SafeArea(
        child: _failed
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(style.spacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 48),
                      SizedBox(height: style.spacing.md),
                      Text(
                        l10n.videoPlayFailed,
                        textAlign: TextAlign.center,
                        style: style.typography.body.copyWith(color: Colors.white),
                      ),
                      if (widget.onOpenExternal != null) ...[
                        SizedBox(height: style.spacing.lg),
                        FilledButton.icon(
                          onPressed: _openExternal,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.videoOpenExternal),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : !ready
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: controller,
                builder: (context, value, _) => Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggle(controller),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: value.aspectRatio > 0 ? value.aspectRatio : 16 / 9,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: style.spacing.md, vertical: style.spacing.sm),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: value.isPlaying ? l10n.videoPause : l10n.videoResume,
                            color: Colors.white,
                            icon: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                            onPressed: () => _toggle(controller),
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              controller,
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(vertical: style.spacing.sm),
                              colors: VideoProgressColors(
                                playedColor: style.accent,
                                bufferedColor: Colors.white38,
                                backgroundColor: Colors.white12,
                              ),
                            ),
                          ),
                          SizedBox(width: style.spacing.sm),
                          Text(
                            '${_clock(value.position)} / ${_clock(value.duration)}',
                            style: style.typography.meta.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

String _clock(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
