import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key, required this.label, this.user});

  final String label;
  final UserSummary? user;

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  static const _cycles = 8;

  late final AnimationController _dots = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync(restart: false);
  }

  @override
  void didUpdateWidget(TypingBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label || oldWidget.user?.id != widget.user?.id) _sync(restart: true);
  }

  void _sync({required bool restart}) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _dots
        ..stop()
        ..value = 0;
      return;
    }
    if (!_dots.isAnimating || restart) _dots.repeat(count: _cycles);
  }

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final t = CommunityTheme.of(context);
    final user = widget.user;
    final avatar = style.avatarSizes.small;
    final dot = t.onOtherBubble.withValues(alpha: 0.6);
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.md, spacing.xxs, spacing.md, spacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (user != null) ...[CommunityAvatar(user: user, radius: avatar / 2), SizedBox(width: spacing.sm)],
              RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.otherBubble,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.md + spacing.xxs, vertical: spacing.md),
                    child: AnimatedBuilder(
                      animation: _dots,
                      builder: (context, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: EdgeInsets.only(left: i == 0 ? 0 : spacing.xs),
                              child: Opacity(
                                opacity: _opacity(i),
                                child: SizedBox.square(
                                  dimension: 7,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _opacity(int index) {
    if (!_dots.isAnimating) return 1;
    final phase = (_dots.value + 1 - index * 0.2) % 1;
    final wave = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    return 0.35 + 0.65 * wave;
  }
}
