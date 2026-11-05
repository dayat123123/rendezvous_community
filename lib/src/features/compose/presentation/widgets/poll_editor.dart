import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class PollEditor extends StatefulWidget {
  const PollEditor({super.key, required this.poll, required this.enabled});

  final PollDraft poll;
  final bool enabled;

  @override
  State<PollEditor> createState() => _PollEditorState();
}

class _PollEditorState extends State<PollEditor> {
  final _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(PollEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final options = widget.poll.options;
    while (_controllers.length > options.length) {
      _controllers.removeLast().dispose();
    }
    for (var i = 0; i < options.length; i++) {
      if (i >= _controllers.length) {
        _controllers.add(TextEditingController(text: options[i]));
      } else if (_controllers[i].text != options[i]) {
        _controllers[i].text = options[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _durationLabel(BuildContext context, PollDuration duration) {
    final l10n = context.communityL10n;
    return switch (duration) {
      PollDuration.oneHour => l10n.pollDuration1h,
      PollDuration.sixHours => l10n.pollDuration6h,
      PollDuration.oneDay => l10n.pollDuration1d,
      PollDuration.threeDays => l10n.pollDuration3d,
      PollDuration.sevenDays => l10n.pollDuration7d,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<ComposeCubit>();
    final options = widget.poll.options;
    final enabled = widget.enabled;
    final details = CommunityPollEditorDetails(
      poll: widget.poll,
      enabled: enabled,
      controllers: List.unmodifiable(_controllers),
      durationLabels: {for (final d in PollDuration.values) d: _durationLabel(context, d)},
      title: l10n.pollAddTooltip,
      onAddOption: enabled && options.length < PollDraft.maxOptions ? cubit.addPollOption : null,
      onRemoveOption: enabled && options.length > PollDraft.minOptions ? cubit.removePollOption : null,
      onOptionChanged: cubit.setPollOption,
      onDurationChanged: enabled ? cubit.setPollDuration : null,
      onRemovePoll: enabled ? cubit.removePoll : null,
    );
    return buildFeedPart((b) => b.pollEditor, context, details, _DefaultPollEditor(details: details));
  }
}

class _DefaultPollEditor extends StatelessWidget {
  const _DefaultPollEditor({required this.details});

  final CommunityPollEditorDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final options = details.options;
    final border = OutlineInputBorder(borderRadius: style.radii.controlRadius, borderSide: style.borderSide);
    final remove = details.onRemoveOption;
    final changed = details.onOptionChanged;
    final durationChanged = details.onDurationChanged;
    return DecoratedBox(
      decoration: style.cardDecoration(),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(spacing.md, spacing.xs, spacing.xs, spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.poll_outlined, size: 18, color: style.accent),
                SizedBox(width: spacing.sm),
                Expanded(child: Text(details.title, style: style.typography.sectionTitle)),
                IconButton(
                  tooltip: l10n.pollRemove,
                  color: style.textSecondary,
                  onPressed: details.onRemovePoll,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: ValueKey('poll-option-$i'),
                        controller: details.controllers[i],
                        enabled: details.enabled,
                        maxLength: PollDraft.maxOptionLength,
                        style: style.typography.body.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: l10n.pollOptionHint(i + 1),
                          hintStyle: style.typography.body.copyWith(fontSize: 14, color: style.textSecondary),
                          isDense: true,
                          counterText: '',
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border.copyWith(
                            borderSide: BorderSide(color: style.accent, width: style.borderWidth),
                          ),
                        ),
                        onChanged: changed == null ? null : (value) => changed(i, value),
                      ),
                    ),
                    SizedBox(
                      width: style.minTouchTarget,
                      child: options.length > PollDraft.minOptions
                          ? IconButton(
                              color: style.textSecondary,
                              onPressed: remove == null ? null : () => remove(i),
                              icon: const Icon(Icons.remove_circle_outline),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing.md,
              children: [
                if (options.length < PollDraft.maxOptions)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                    onPressed: details.onAddOption,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.pollAddOption),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.pollDuration, style: style.typography.label),
                    SizedBox(width: spacing.sm),
                    DropdownButton<PollDuration>(
                      value: details.duration,
                      style: style.typography.body.copyWith(fontSize: 14),
                      underline: const SizedBox.shrink(),
                      borderRadius: style.radii.cardRadius,
                      onChanged: durationChanged == null ? null : (d) => d == null ? null : durationChanged(d),
                      items: [
                        for (final d in PollDuration.values)
                          DropdownMenuItem(value: d, child: Text(details.durationLabels[d] ?? d.name)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
