import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_current_user.dart';
import 'package:rendezvous_community/src/app/community_feature_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/media/image_mime.dart';
import 'package:rendezvous_community/src/features/analytics/domain/entities/analytics_event.dart';
import 'package:rendezvous_community/src/features/compose/presentation/composer_action.dart';
import 'package:rendezvous_community/src/features/compose/presentation/cubit/compose_cubit.dart';
import 'package:rendezvous_community/src/features/compose/presentation/widgets/poll_editor.dart';
import 'package:rendezvous_community/src/features/config/presentation/widgets/community_social_gate.dart';
import 'package:rendezvous_community/src/features/drafts/domain/entities/post_draft.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_builders.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/features/legal/presentation/widgets/community_consent_flow.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_avatar.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_composer_field.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_disclaimer.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_tag.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_user_name.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/moderation_notice.dart';

class CommunityComposerImage {
  const CommunityComposerImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

Future<Post?> showCommunityComposer(
  BuildContext context, {
  String? initialStock,
  CommunityComposerImage? initialImage,
  PostDraft? draft,
  Sentiment? initialSentiment,
  CommunityComposerAction? initialAction,
  String? hintText,
}) {
  final deps = CommunityScope.of(context);
  final features = context.getInheritedWidgetOfExactType<CommunityFeatureScope>()?.dependencies;
  final l10n = context.communityL10n;
  Widget scoped(Widget child) {
    final page = CommunityScope(dependencies: deps, child: child);
    return features == null ? page : CommunityFeatureScope(dependencies: features, child: page);
  }

  if (CommunityBreakpoints.isWide(context)) {
    return showDialog<Post>(
      context: context,
      builder: (dialogContext) => scoped(
        Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CommunityComposePost(
              initialStock: initialStock,
              initialImage: initialImage,
              draft: draft,
              initialSentiment: initialSentiment,
              initialAction: initialAction,
              hintText: hintText,
              autofocus: true,
              onPosted: (post) => Navigator.pop(dialogContext, post),
            ),
          ),
        ),
      ),
    );
  }
  return Navigator.of(context).push<Post>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (pageContext) => scoped(
        Scaffold(
          appBar: AppBar(title: Text(l10n.composeTitle)),
          body: SafeArea(
            child: CommunityComposePost(
              initialStock: initialStock,
              initialImage: initialImage,
              draft: draft,
              initialSentiment: initialSentiment,
              initialAction: initialAction,
              hintText: hintText,
              autofocus: true,
              onPosted: (post) => Navigator.pop(pageContext, post),
            ),
          ),
        ),
      ),
    ),
  );
}

class CommunityComposePost extends StatelessWidget {
  const CommunityComposePost({
    super.key,
    this.initialStock,
    this.initialImage,
    this.onPosted,
    this.autofocus = false,
    this.draft,
    this.initialSentiment,
    this.initialAction,
    this.hintText,
  });

  final String? initialStock;
  final CommunityComposerImage? initialImage;
  final ValueChanged<Post>? onPosted;
  final bool autofocus;
  final PostDraft? draft;
  final Sentiment? initialSentiment;
  final CommunityComposerAction? initialAction;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final deps = CommunityScope.of(context);
    final drafts = deps.callbacks.postDrafts ? context.communityFeatures?.drafts : null;
    final resumed = drafts == null ? null : draft;
    return CommunitySocialGate(
      child: BlocProvider(
        create: (_) => ComposeCubit(
          feed: deps.feed,
          media: deps.media,
          consent: communityConsentGate(context),
          drafts: drafts,
          draft: resumed,
        ),
        child: _ComposeView(
          initialStock: initialStock,
          initialImage: initialImage,
          onPosted: onPosted,
          autofocus: autofocus,
          draft: resumed,
          initialSentiment: initialSentiment,
          initialAction: initialAction,
          hintText: hintText,
        ),
      ),
    );
  }
}

class _ComposeView extends StatefulWidget {
  const _ComposeView({
    this.initialStock,
    this.initialImage,
    this.onPosted,
    required this.autofocus,
    this.draft,
    this.initialSentiment,
    this.initialAction,
    this.hintText,
  });

  final String? initialStock;
  final CommunityComposerImage? initialImage;
  final ValueChanged<Post>? onPosted;
  final bool autofocus;
  final PostDraft? draft;
  final Sentiment? initialSentiment;
  final CommunityComposerAction? initialAction;
  final String? hintText;

  @override
  State<_ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<_ComposeView> {
  late final _controller = TextEditingController(
    text: widget.draft?.body ?? (widget.initialStock == null ? '' : '\$${widget.initialStock!.toUpperCase()} '),
  );

  String? _chartPath;
  int _draftNotice = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => context.read<ComposeCubit>().bodyChanged(_controller.text));
    final sentiment = widget.initialSentiment;
    if (sentiment != null) context.read<ComposeCubit>().setSentiment(sentiment);
    switch (widget.initialAction) {
      case CommunityComposerAction.poll:
        context.read<ComposeCubit>().addPoll();
      case CommunityComposerAction.cashtag:
        final text = _controller.text;
        final prefix = text.isEmpty || text.endsWith(' ') ? text : '$text ';
        _controller.value = TextEditingValue(
          text: '$prefix\$',
          selection: TextSelection.collapsed(offset: prefix.length + 1),
        );
      case CommunityComposerAction.image:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _pickImage();
        });
      case null:
        break;
    }
    final image = widget.initialImage;
    if (image != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final cubit = context.read<ComposeCubit>();
        await cubit.addImage(image.bytes, image.mimeType);
        if (mounted && cubit.state.attachments.isNotEmpty) _chartPath = cubit.state.attachments.first.path;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ComposeCubit>();
    final hasPoll = cubit.state.poll != null;
    final hasChart = _chartPath != null && cubit.state.attachments.any((a) => a.path == _chartPath);
    final post = await cubit.submit(_controller.text);
    if (post == null || !mounted) return;
    final stock = post.stockCodes.firstOrNull ?? widget.initialStock;
    context.trackCommunityEvent(CommunityAnalyticsEvent.postCreate, {
      'post_id': post.id,
      'has_attachment': post.attachments.isNotEmpty,
      'has_poll': hasPoll,
      'stock_code': stock,
      'source': hasChart ? 'share' : 'feed',
    });
    if (hasChart) {
      context.trackCommunityEvent(CommunityAnalyticsEvent.shareChart, {'post_id': post.id, 'stock_code': stock});
    }
    _chartPath = null;
    _controller.clear();
    showCommunityMessage(context, context.communityL10n.composePosted);
    widget.onPosted?.call(post);
  }

  Future<void> _pickImage() async {
    const group = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
      uniformTypeIdentifiers: ['public.image'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    await context.read<ComposeCubit>().addImage(bytes, mimeFromName(file.name, file.mimeType));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocConsumer<ComposeCubit, ComposeState>(
      listenWhen: (a, b) => a.errorId != b.errorId || a.draftNoticeId != b.draftNoticeId,
      listener: (context, state) {
        if (state.draftNoticeId != _draftNotice) {
          _draftNotice = state.draftNoticeId;
          if (state.draftStatus == DraftSyncStatus.replaced && state.restoredBody != null) {
            _controller.text = state.restoredBody!;
            return showCommunityMessage(context, l10n.draftReplaced);
          }
          return showCommunityMessage(context, l10n.draftLimit(maxPostDrafts));
        }
        final error = state.error;
        if (error == null) return;
        final code = error is CommunityException ? error.code : null;
        showCommunityMessage(context, switch (code) {
          'too_many_images' => l10n.composeTooManyImages,
          'file_too_large' => l10n.composeImageTooLarge,
          'invalid_poll_draft' => l10n.pollInvalidDraft,
          _ => l10n.errorMessage(error),
        });
      },
      builder: (context, state) {
        final cubit = context.read<ComposeCubit>();
        final poll = state.poll;
        final style = CommunityStyle.of(context);
        final spacing = style.spacing;
        final sentiment = CommunityComposeSentimentDetails(
          title: l10n.sentimentLabel,
          selected: state.sentiment,
          options: const [Sentiment.bullish, Sentiment.bearish, Sentiment.neutral, null],
          labels: [l10n.sentimentBullish, l10n.sentimentBearish, l10n.sentimentNeutral, l10n.sentimentNone],
          onChanged: cubit.setSentiment,
        );
        final toolbar = CommunityComposeDetails(
          controller: _controller,
          posting: state.submitting,
          uploading: state.uploading,
          hasPoll: poll != null,
          imageCount: state.attachments.length,
          submitLabel: l10n.composeSubmit,
          addImageLabel: l10n.composeAddImage,
          addPollLabel: l10n.pollAddTooltip,
          onPost: state.busy ? null : _submit,
          onPickImage: state.busy || !state.canAddImage ? null : _pickImage,
          onAddPoll: state.busy || !state.canAddPoll ? null : cubit.addPoll,
        );
        final hint = style.typography.meta.copyWith(color: style.textSecondary);
        final bodyStyle = style.typography.body;
        final fieldHintStyle = bodyStyle.copyWith(color: style.textSecondary);
        final fieldDecoration = InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isCollapsed: true,
          hintStyle: fieldHintStyle,
          counterStyle: style.typography.meta,
          contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
        );
        final hintText = widget.hintText ?? l10n.composeHint;
        final minLines = poll == null ? 4 : 2;
        Widget buildField({TextStyle? textStyle, TextStyle? hintStyle, InputDecoration? decoration}) {
          final base = decoration ?? fieldDecoration;
          return CommunityComposerField(
            controller: _controller,
            hintText: hintText,
            maxLength: maxPostLength,
            minLines: minLines,
            maxLines: 12,
            autofocus: widget.autofocus,
            enabled: !state.submitting,
            onSubmit: _submit,
            style: textStyle ?? bodyStyle,
            decoration: hintStyle == null ? base : base.copyWith(hintStyle: hintStyle),
          );
        }

        final field = CommunityComposeFieldDetails(
          controller: _controller,
          hintText: hintText,
          maxLength: maxPostLength,
          minLines: minLines,
          maxLines: 12,
          enabled: !state.submitting,
          autofocus: widget.autofocus,
          onSubmit: _submit,
          textStyle: bodyStyle,
          hintStyle: fieldHintStyle,
          decoration: fieldDecoration,
          field: buildField(),
          buildField: buildField,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommunityCurrentUserBuilder(
                builder: (context, user) {
                  if (user == null) return const SizedBox.shrink();
                  final author = CommunityComposeAuthorDetails(user: user, sentiment: state.sentiment);
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: buildFeedPart(
                      (b) => b.composeAuthor,
                      context,
                      author,
                      _DefaultComposeAuthor(details: author),
                    ),
                  );
                },
              ),
              buildFeedPart((b) => b.composeField, context, field, field.field),
              if (poll != null) ...[SizedBox(height: spacing.md), PollEditor(poll: poll, enabled: !state.submitting)],
              SizedBox(height: spacing.md),
              buildFeedPart(
                (b) => b.composeSentiment,
                context,
                sentiment,
                _DefaultComposeSentiment(details: sentiment),
              ),
              if (state.attachments.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    for (final a in state.attachments)
                      Builder(
                        builder: (context) {
                          final image = CommunityComposeImageDetails(
                            attachment: a,
                            name: a.path.split('/').last,
                            removeLabel: l10n.composeRemoveImage,
                            onRemove: state.busy ? null : () => cubit.removeImage(a),
                          );
                          return buildFeedPart(
                            (b) => b.composeImage,
                            context,
                            image,
                            _DefaultComposeImage(details: image),
                          );
                        },
                      ),
                  ],
                ),
              ],
              SizedBox(height: spacing.md),
              const CommunityDivider(),
              SizedBox(height: spacing.xs),
              buildFeedPart((b) => b.composeToolbar, context, toolbar, _DefaultComposeToolbar(details: toolbar)),
              if (isDesktopPlatform(context)) Text(l10n.sendShortcutHint, textAlign: TextAlign.end, style: hint),
              if (state.draftStatus != null)
                Text(
                  state.draftStatus == DraftSyncStatus.synced ? l10n.draftSaved : l10n.draftSavedLocally,
                  textAlign: TextAlign.end,
                  style: hint,
                ),
              CommunityDisclaimer(padding: EdgeInsets.only(top: spacing.md)),
            ],
          ),
        );
      },
    );
  }
}

class _DefaultComposeSentiment extends StatelessWidget {
  const _DefaultComposeSentiment({required this.details});

  final CommunityComposeSentimentDetails details;

  static const _icons = {
    Sentiment.bullish: Icons.trending_up,
    Sentiment.bearish: Icons.trending_down,
    Sentiment.neutral: Icons.trending_flat,
  };

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(details.title, style: style.typography.label),
        SizedBox(height: spacing.xs),
        Wrap(
          spacing: spacing.sm,
          children: [
            for (final (index, option) in details.options.indexed)
              CommunityTag(
                label: details.labels[index],
                icon: _icons[option],
                selected: option == details.selected,
                onTap: () => details.onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _DefaultComposeImage extends StatelessWidget {
  const _DefaultComposeImage({required this.details});

  final CommunityComposeImageDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final name = Text(details.name, overflow: TextOverflow.ellipsis);
    return InputChip(
      avatar: Icon(Icons.image_outlined, color: style.textSecondary),
      label: details.held
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: name),
                SizedBox(width: style.spacing.xs + style.spacing.xxs),
                const HeldAttachmentLabel(),
              ],
            )
          : name,
      labelStyle: style.typography.label.copyWith(color: style.onChip),
      backgroundColor: style.chip,
      shape: const StadiumBorder(),
      side: style.borderSide,
      deleteIconColor: style.textSecondary,
      deleteButtonTooltipMessage: details.removeLabel,
      onDeleted: details.onRemove,
    );
  }
}

class _DefaultComposeToolbar extends StatelessWidget {
  const _DefaultComposeToolbar({required this.details});

  final CommunityComposeDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: spacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ComposeTool(
                    icon: Icons.add_photo_alternate_outlined,
                    label: details.addImageLabel,
                    onPressed: details.onPickImage,
                  ),
                  _ComposeTool(icon: Icons.poll_outlined, label: details.addPollLabel, onPressed: details.onAddPoll),
                ],
              ),
            ),
            if (details.uploading)
              SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        FilledButton.icon(
          style: style.primaryButtonStyle().copyWith(
            minimumSize: WidgetStatePropertyAll(Size.fromHeight(style.minTouchTarget)),
          ),
          onPressed: details.onPost,
          icon: details.posting
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: style.textSecondary),
                )
              : const Icon(Icons.send, size: 18),
          label: Text(details.submitLabel),
        ),
      ],
    );
  }
}

class _ComposeTool extends StatelessWidget {
  const _ComposeTool({required this.icon, required this.label, this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: style.textPrimary,
        iconColor: style.accent,
        disabledForegroundColor: style.textTertiary,
        disabledIconColor: style.textTertiary,
        textStyle: style.typography.label.copyWith(fontSize: 14),
        minimumSize: Size(style.minTouchTarget, style.minTouchTarget),
        padding: EdgeInsets.symmetric(horizontal: style.spacing.md),
        shape: const StadiumBorder(),
        backgroundColor: style.pill,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

class _DefaultComposeAuthor extends StatelessWidget {
  const _DefaultComposeAuthor({required this.details});

  final CommunityComposeAuthorDetails details;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final user = details.user;
    return Row(
      children: [
        CommunityAvatar(user: user, radius: style.avatarSizes.post / 2),
        SizedBox(width: style.spacing.sm + style.spacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommunityUserName(user: user, showUsername: false),
              SizedBox(height: style.spacing.xxs),
              Text(user.handle, maxLines: 1, overflow: TextOverflow.ellipsis, style: style.typography.meta),
            ],
          ),
        ),
      ],
    );
  }
}
