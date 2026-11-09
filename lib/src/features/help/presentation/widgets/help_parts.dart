import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_builders.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/features/help/presentation/cubit/help_center_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_topic_picker.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_card.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/content_icons.dart';

IconData helpCategoryIcon(HelpCategory category) => communityContentIcon(category.icon) ?? Icons.help_outline;

class HelpSearchField extends StatelessWidget {
  const HelpSearchField({super.key, required this.details});

  final CommunityHelpSearchDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.searchField, context, details, _DefaultSearchField(details: details));
}

class _DefaultSearchField extends StatelessWidget {
  const _DefaultSearchField({required this.details});

  final CommunityHelpSearchDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final border = OutlineInputBorder(borderRadius: style.radii.pillRadius, borderSide: BorderSide.none);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: d.controller,
      builder: (context, value, _) => TextField(
        controller: d.controller,
        onChanged: d.onChanged,
        maxLength: helpQueryMaxLength,
        textInputAction: TextInputAction.search,
        style: style.typography.body,
        decoration: InputDecoration(
          hintText: d.hintText,
          hintStyle: style.typography.body.copyWith(color: style.textTertiary),
          counterText: '',
          filled: true,
          fillColor: style.pill,
          isDense: true,
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: style.radii.pillRadius,
            borderSide: BorderSide(color: style.accent, width: style.borderWidth * 1.5),
          ),
          prefixIcon: Icon(Icons.search, color: style.textSecondary),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: d.clearLabel,
                  onPressed: d.onClear,
                  icon: Icon(Icons.close, color: style.textSecondary),
                ),
        ),
      ),
    );
  }
}

class HelpCategoryTile extends StatelessWidget {
  const HelpCategoryTile({super.key, required this.details});

  final CommunityHelpCategoryDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.categoryTile, context, details, _DefaultCategoryTile(details: details));
}

class _DefaultCategoryTile extends StatelessWidget {
  const _DefaultCategoryTile({required this.details});

  final CommunityHelpCategoryDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return CommunityCard(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      onTap: d.onOpen,
      child: Row(
        children: [
          SupportIconCircle(icon: d.icon, color: style.accent),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.title, style: style.typography.author.copyWith(fontSize: 15)),
                SizedBox(height: spacing.xxs),
                Text(d.countLabel, style: style.typography.meta.copyWith(color: style.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: style.textTertiary),
        ],
      ),
    );
  }
}

class HelpArticleTile extends StatelessWidget {
  const HelpArticleTile({super.key, required this.details});

  final CommunityHelpArticleTileDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.articleTile, context, details, _DefaultArticleTile(details: details));
}

class _DefaultArticleTile extends StatelessWidget {
  const _DefaultArticleTile({required this.details});

  final CommunityHelpArticleTileDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final subtitle = d.subtitle;
    return CommunityCard(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      onTap: d.onOpen,
      child: Row(
        children: [
          Icon(Icons.article_outlined, size: 20, color: style.accent),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(d.title, style: style.typography.author.copyWith(fontSize: 15)),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: spacing.xxs),
                  Text(subtitle, style: style.typography.meta.copyWith(color: style.textSecondary)),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: style.textTertiary),
        ],
      ),
    );
  }
}

class HelpContactCard extends StatelessWidget {
  const HelpContactCard({super.key, required this.details});

  final CommunityHelpContactDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.contact, context, details, _DefaultContactCard(details: details));
}

class _DefaultContactCard extends StatelessWidget {
  const _DefaultContactCard({required this.details});

  final CommunityHelpContactDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return CommunityCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Row(
        children: [
          SupportIconCircle(icon: Icons.support_agent, color: style.accent),
          SizedBox(width: spacing.md),
          Expanded(child: Text(d.title, style: style.typography.author.copyWith(fontSize: 15))),
          SizedBox(width: spacing.sm),
          FilledButton.icon(
            style: style.primaryButtonStyle(),
            onPressed: d.onContact,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(d.actionLabel),
          ),
        ],
      ),
    );
  }
}

class HelpOfflineNotice extends StatelessWidget {
  const HelpOfflineNotice({super.key, required this.details});

  final CommunityHelpOfflineDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.offlineNotice, context, details, _DefaultOfflineNotice(details: details));
}

class _DefaultOfflineNotice extends StatelessWidget {
  const _DefaultOfflineNotice({required this.details});

  final CommunityHelpOfflineDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.pill,
          border: Border(
            bottom: BorderSide(color: style.divider, width: style.borderWidth),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xs, spacing.sm, spacing.xs),
          child: Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: style.textSecondary),
              SizedBox(width: spacing.sm),
              Expanded(child: Text(d.message, style: style.typography.meta)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                onPressed: d.onRetry,
                child: Text(d.retryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpFeedbackView extends StatelessWidget {
  const HelpFeedbackView({super.key, required this.details});

  final CommunityHelpFeedbackDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.feedback, context, details, _DefaultFeedback(details: details));
}

class _DefaultFeedback extends StatelessWidget {
  const _DefaultFeedback({required this.details});

  final CommunityHelpFeedbackDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onVote = d.onVote;
    final onSubmit = d.onSubmitComment;
    return CommunityCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(d.question, style: style.typography.author.copyWith(fontSize: 15)),
          SizedBox(height: spacing.md),
          Row(
            children: [
              _VoteButton(
                label: d.yesLabel,
                icon: Icons.thumb_up_alt_outlined,
                selected: d.helpful == true,
                onPressed: onVote == null ? null : () => onVote(true),
              ),
              SizedBox(width: spacing.sm),
              _VoteButton(
                label: d.noLabel,
                icon: Icons.thumb_down_alt_outlined,
                selected: d.helpful == false,
                onPressed: onVote == null ? null : () => onVote(false),
              ),
              if (d.busy) ...[
                SizedBox(width: spacing.md),
                SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: style.accent)),
              ],
            ],
          ),
          if (d.voted) ...[
            SizedBox(height: spacing.md),
            Text(d.thanksLabel, style: style.typography.meta.copyWith(color: style.textSecondary)),
            SizedBox(height: spacing.sm),
            if (d.commentSent)
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: style.accent),
                  SizedBox(width: spacing.xs),
                  Expanded(child: Text(d.commentSentLabel, style: style.typography.meta)),
                ],
              )
            else ...[
              TextField(
                controller: d.controller,
                maxLength: d.maxCommentLength,
                minLines: 2,
                maxLines: 4,
                style: style.typography.body,
                decoration: InputDecoration(
                  hintText: d.commentLabel,
                  hintStyle: style.typography.body.copyWith(color: style.textTertiary),
                  border: OutlineInputBorder(borderRadius: style.radii.cardRadius),
                  isDense: true,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: d.controller,
                  builder: (context, value, _) => FilledButton(
                    style: style.primaryButtonStyle(),
                    onPressed: onSubmit == null || value.text.trim().isEmpty ? null : onSubmit,
                    child: Text(d.submitLabel),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({required this.label, required this.icon, required this.selected, this.onPressed});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final button = selected
        ? FilledButton.icon(
            style: style.primaryButtonStyle(),
            onPressed: onPressed ?? () {},
            icon: Icon(icon, size: 18),
            label: Text(label),
          )
        : OutlinedButton.icon(
            style: style.secondaryButtonStyle(),
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );
    return Semantics(selected: selected, button: true, child: button);
  }
}

class HelpTopicSuggestions extends StatelessWidget {
  const HelpTopicSuggestions({super.key, required this.details});

  final CommunityHelpSuggestionsDetails details;

  @override
  Widget build(BuildContext context) =>
      buildHelpPart((b) => b.topicSuggestions, context, details, _DefaultTopicSuggestions(details: details));
}

class _DefaultTopicSuggestions extends StatelessWidget {
  const _DefaultTopicSuggestions({required this.details});

  final CommunityHelpSuggestionsDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final topic = d.topic;
    return ColoredBox(
      color: style.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xl, spacing.lg, spacing.xl),
        children: [
          if (topic != null) ...[
            Row(
              children: [
                SupportIconCircle(icon: supportTopicIconFor(topic), color: style.accent, size: 28),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(topic.name, style: style.typography.label.copyWith(color: style.textSecondary)),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
          ],
          Semantics(header: true, child: Text(d.title, style: style.typography.title)),
          SizedBox(height: spacing.xs),
          Text(d.hint, style: style.typography.body.copyWith(color: style.textSecondary)),
          SizedBox(height: spacing.lg),
          for (final article in d.articles)
            HelpArticleTile(
              details: CommunityHelpArticleTileDetails(
                article: article,
                title: article.question,
                onOpen: () => d.onOpenArticle(article),
              ),
            ),
          SizedBox(height: spacing.lg),
          FilledButton.icon(
            style: style.primaryButtonStyle(),
            onPressed: d.busy ? null : d.onContinue,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(d.continueLabel),
          ),
          SizedBox(height: spacing.xs),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
            onPressed: d.busy ? null : d.onBack,
            child: Text(d.backLabel),
          ),
        ],
      ),
    );
  }
}
