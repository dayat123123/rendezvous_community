import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_scroll.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/community_help_article.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/help_parts.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_builders.dart';
import 'package:rendezvous_community/src/features/support/presentation/builders/community_support_details.dart';
import 'package:rendezvous_community/src/features/support/presentation/cubit/support_cubit.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_intake_form.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_tone.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_card.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/content_icons.dart';

IconData supportTopicIconFor(SupportTopic topic) => communityContentIcon(topic.icon) ?? supportTopicIcon(topic.code);

IconData supportTopicIcon(String code) => switch (code) {
  'account' => Icons.person_outline,
  'funds' => Icons.account_balance_wallet_outlined,
  'orders' => Icons.receipt_long_outlined,
  'portfolio' => Icons.pie_chart_outline,
  'technical' => Icons.build_outlined,
  'fraud' => Icons.gpp_maybe_outlined,
  _ => Icons.help_outline,
};

class SupportTopicPicker extends StatelessWidget {
  const SupportTopicPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<SupportCubit>();
    final state = context.watch<SupportCubit>().state;
    final history = state.home?.roomId != null;
    final language = Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'id';
    final suggestionTopic = state.suggestionTopic;
    final nextOpenAt = state.home?.nextOpenAt;
    final closedNotice = state.serviceOpen
        ? null
        : nextOpenAt == null
        ? l10n.supportLeaveMessageTitle
        : l10n.supportOutOfHours('${l10n.dayLabel(nextOpenAt)} ${l10n.clockTime(nextOpenAt)}');
    final intakeTopic = state.intakeTopic == null ? null : state.topicByCode(state.intakeTopic!);
    if (intakeTopic != null && intakeTopic.hasIntake) {
      return SupportIntakeForm(key: ValueKey(intakeTopic.code), topic: intakeTopic, notice: closedNotice);
    }
    if (state.showsSuggestions && suggestionTopic != null) {
      final topic = state.topicByCode(suggestionTopic);
      final leaving = state.leavingMessage;
      final articles = state.suggestions;
      return HelpTopicSuggestions(
        details: CommunityHelpSuggestionsDetails(
          topicCode: suggestionTopic,
          topic: topic,
          title: leaving ? l10n.supportLeaveMessageTitle : l10n.helpSuggestionsTitle,
          hint: !leaving
              ? l10n.helpSuggestionsHint(topic?.name ?? suggestionTopic)
              : articles.isEmpty
              ? l10n.supportLeaveMessageHint
              : l10n.supportLeaveMessageArticles,
          articles: articles,
          continueLabel: leaving ? l10n.supportLeaveMessage : l10n.helpContinueChat,
          backLabel: l10n.helpPickAnotherTopic,
          busy: state.busy,
          notice: leaving ? closedNotice : null,
          outOfHours: leaving,
          onOpenArticle: (article) => openCommunityHelpArticle(
            context,
            article,
            onContactSupport: (articleContext, _) {
              Navigator.of(articleContext).pop();
              cubit.proceed(suggestionTopic);
            },
          ),
          onContinue: () => cubit.proceed(suggestionTopic),
          onBack: cubit.dismissSuggestions,
        ),
      );
    }
    final details = CommunitySupportTopicPickerDetails(
      topics: state.topics,
      title: state.home?.topicTitle(language) ?? l10n.supportPickTopic,
      hint: state.home?.topicHint(language) ?? l10n.supportPickTopicHint,
      busy: state.busy || state.suggesting != null,
      onSelect: cubit.select,
      historyLabel: history ? l10n.supportHistory : null,
      onShowHistory: history ? cubit.showHistory : null,
    );
    return buildSupportPart((b) => b.topicPicker, context, details, _DefaultTopicPicker(details: details));
  }
}

class _DefaultTopicPicker extends StatelessWidget {
  const _DefaultTopicPicker({required this.details});

  final CommunitySupportTopicPickerDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final onShowHistory = d.onShowHistory;
    final historyLabel = d.historyLabel;
    return ColoredBox(
      color: style.background,
      child: CommunityScrollArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xl, spacing.lg, spacing.xl),
          children: [
            Semantics(header: true, child: Text(d.title, style: style.typography.title)),
            SizedBox(height: spacing.xs),
            Text(d.hint, style: style.typography.body.copyWith(color: style.textSecondary)),
            if (onShowHistory != null && historyLabel != null) ...[
              SizedBox(height: spacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                  onPressed: onShowHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: Text(historyLabel),
                ),
              ),
            ],
            SizedBox(height: spacing.lg),
            for (final topic in d.topics)
              SupportTopicTile(
                details: CommunitySupportTopicDetails(
                  topic: topic,
                  icon: supportTopicIconFor(topic),
                  busy: d.busy,
                  onSelect: d.busy ? null : () => d.onSelect(topic.code),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SupportTopicTile extends StatelessWidget {
  const SupportTopicTile({super.key, required this.details});

  final CommunitySupportTopicDetails details;

  @override
  Widget build(BuildContext context) =>
      buildSupportPart((b) => b.topicTile, context, details, _DefaultTopicTile(details: details));
}

class _DefaultTopicTile extends StatelessWidget {
  const _DefaultTopicTile({required this.details});

  final CommunitySupportTopicDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final error = Theme.of(context).colorScheme.error;
    final color = d.urgent || d.danger ? error : style.accent;
    final description = d.topic.description;
    final enabled = d.onSelect != null;
    return CommunityCard(
      margin: EdgeInsets.only(bottom: spacing.sm),
      padding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      onTap: d.onSelect,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Row(
          children: [
            SupportIconCircle(icon: d.icon, color: color),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.topic.name,
                    style: style.typography.author.copyWith(fontSize: 15, color: d.danger ? error : null),
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    SizedBox(height: spacing.xxs),
                    Text(description, style: style.typography.meta.copyWith(color: style.textSecondary)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: style.textTertiary),
          ],
        ),
      ),
    );
  }
}
