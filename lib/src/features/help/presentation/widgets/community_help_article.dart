import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rendezvous_community/src/app/community_builders.dart';
import 'package:rendezvous_community/src/app/community_help_scope.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/app/community_support_scope.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_builders.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/features/help/presentation/cubit/help_article_cubit.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/community_help_markdown.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/help_parts.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/community_support_chat.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/community_divider.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/feedback.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

typedef CommunityHelpContactCallback = void Function(BuildContext context, String? topic);

const helpCenterScreen = 'help_center';

String helpLanguage(BuildContext context) => Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'id';

void openSupportFromHelp(BuildContext context, String? topic) {
  openCommunitySupport(context, topic: topic, screen: helpCenterScreen);
}

class HelpDependencies implements CommunityHelpDependencies {
  const HelpDependencies(this.help);

  @override
  final HelpRepository help;
}

Widget Function(Widget child) carryHelpScopes(BuildContext context, HelpRepository help) {
  final carry = carryCommunityBuilders(context);
  final community = CommunityScope.maybeOf(context);
  final support = CommunitySupportScope.maybeOf(context);
  return (child) {
    Widget result = CommunityHelpScope(dependencies: HelpDependencies(help), child: child);
    if (support != null) result = CommunitySupportScope(dependencies: support, child: result);
    if (community != null) result = CommunityScope(dependencies: community, child: result);
    return carry(result);
  };
}

Future<void> pushHelpPage(BuildContext context, HelpRepository help, {required String title, required Widget body}) {
  final carry = carryHelpScopes(context, help);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => carry(
        Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(top: false, child: body),
        ),
      ),
    ),
  );
}

Future<void> openCommunityHelpArticle(
  BuildContext context,
  HelpArticle article, {
  CommunityHelpContactCallback? onContactSupport,
  String? categoryName,
  HelpRepository? repository,
}) {
  final help = repository ?? CommunityHelpScope.of(context).help;
  return pushHelpPage(
    context,
    help,
    title: context.communityL10n.helpTitle,
    body: CommunityHelpArticleView(
      article: article,
      categoryName: categoryName,
      onContactSupport: onContactSupport,
      repository: help,
    ),
  );
}

Future<void> openCommunityHelpArticleById(
  BuildContext context,
  String id, {
  String? title,
  CommunityHelpContactCallback? onContactSupport,
  HelpRepository? repository,
}) => openCommunityHelpArticle(
  context,
  HelpArticle(id: id, category: '', question: title ?? '', answer: ''),
  onContactSupport: onContactSupport,
  repository: repository,
);

class CommunityHelpArticleView extends StatelessWidget {
  const CommunityHelpArticleView({
    super.key,
    required this.article,
    this.categoryName,
    this.onContactSupport,
    this.repository,
  });

  final HelpArticle article;
  final String? categoryName;
  final CommunityHelpContactCallback? onContactSupport;
  final HelpRepository? repository;

  @override
  Widget build(BuildContext context) {
    final help = repository ?? CommunityHelpScope.of(context).help;
    return BlocProvider(
      create: (_) => HelpArticleCubit(help: help, article: article, language: helpLanguage(context))..load(),
      child: _ArticleView(categoryName: categoryName, onContactSupport: onContactSupport ?? openSupportFromHelp),
    );
  }
}

class _ArticleView extends StatelessWidget {
  const _ArticleView({required this.categoryName, required this.onContactSupport});

  final String? categoryName;
  final CommunityHelpContactCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    return BlocConsumer<HelpArticleCubit, HelpArticleState>(
      listenWhen: (a, b) => a.actionErrorId != b.actionErrorId,
      listener: (context, state) => showCommunityError(context, state.actionError!),
      builder: (context, state) {
        final cubit = context.read<HelpArticleCubit>();
        final error = state.error;
        if (error != null) {
          return buildHelpPart(
            (b) => b.error,
            context,
            CommunityListErrorDetails(error: error, message: l10n.errorMessage(error), onRetry: cubit.load),
            CommunityErrorView(error: error, onRetry: state.missing ? null : cubit.load),
          );
        }
        final article = state.article;
        final updatedAt = article.updatedAt;
        final details = CommunityHelpArticleDetails(
          article: article,
          title: article.question,
          categoryName: categoryName,
          updatedLabel: updatedAt == null
              ? null
              : l10n.helpUpdated(DateFormat.yMMMMd(l10n.localeName).format(updatedAt.toLocal())),
          body: CommunityHelpMarkdown(article.answer),
          feedback: const HelpFeedbackBlock(),
          contact: HelpContactCard(
            details: CommunityHelpContactDetails(
              title: l10n.helpStillNeedHelp,
              actionLabel: l10n.helpChatCs,
              topic: article.topic,
              onContact: () => onContactSupport(context, article.topic),
            ),
          ),
          loading: state.loading,
          offline: state.offline,
        );
        return buildHelpPart((b) => b.articleDetail, context, details, _DefaultArticle(details: details));
      },
    );
  }
}

class _DefaultArticle extends StatelessWidget {
  const _DefaultArticle({required this.details});

  final CommunityHelpArticleDetails details;

  @override
  Widget build(BuildContext context) {
    final d = details;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final category = d.categoryName;
    final updated = d.updatedLabel;
    return ColoredBox(
      color: style.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.xl, spacing.lg, spacing.xl),
            children: [
              if (category != null && category.isNotEmpty) ...[
                Text(category, style: style.typography.label.copyWith(color: style.accent)),
                SizedBox(height: spacing.xs),
              ],
              Semantics(header: true, child: Text(d.title, style: style.typography.title.copyWith(fontSize: 22))),
              if (updated != null) ...[SizedBox(height: spacing.xs), Text(updated, style: style.typography.meta)],
              SizedBox(height: spacing.lg),
              d.body,
              SizedBox(height: spacing.xl),
              const CommunityDivider(),
              SizedBox(height: spacing.xl),
              d.feedback,
              SizedBox(height: spacing.md),
              d.contact,
            ],
          ),
        ),
      ),
    );
  }
}

class HelpFeedbackBlock extends StatefulWidget {
  const HelpFeedbackBlock({super.key});

  @override
  State<HelpFeedbackBlock> createState() => _HelpFeedbackBlockState();
}

class _HelpFeedbackBlockState extends State<HelpFeedbackBlock> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final cubit = context.read<HelpArticleCubit>();
    final state = context.watch<HelpArticleCubit>().state;
    final feedback = state.article.feedback;
    final details = CommunityHelpFeedbackDetails(
      question: l10n.helpWasHelpful,
      yesLabel: l10n.helpYes,
      noLabel: l10n.helpNo,
      thanksLabel: l10n.helpFeedbackThanks,
      commentLabel: l10n.helpFeedbackComment,
      submitLabel: l10n.helpFeedbackSend,
      commentSentLabel: l10n.helpFeedbackCommentSent,
      controller: _controller,
      busy: state.sending,
      commentSent: state.commentSent || feedback?.comment != null,
      feedback: feedback,
      onVote: state.sending ? null : cubit.vote,
      onSubmitComment: feedback == null || state.sending ? null : () => cubit.submitComment(_controller.text),
    );
    return HelpFeedbackView(details: details);
  }
}
