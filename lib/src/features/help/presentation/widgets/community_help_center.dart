import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rendezvous_community/src/app/community_help_scope.dart';
import 'package:rendezvous_community/src/app/community_support_scope.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/help/domain/repositories/help_repository.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_builders.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/features/help/presentation/cubit/help_center_cubit.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/community_help_article.dart';
import 'package:rendezvous_community/src/features/help/presentation/widgets/help_parts.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';
import 'package:rendezvous_community/src/features/support/domain/repositories/support_repository.dart';
import 'package:rendezvous_community/src/features/support/presentation/widgets/support_incidents.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/load_status.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_theme.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/state_views.dart';

class CommunityHelpCenter extends StatelessWidget {
  const CommunityHelpCenter({super.key, this.onContactSupport, this.repository, this.support});

  final CommunityHelpContactCallback? onContactSupport;
  final HelpRepository? repository;
  final SupportRepository? support;

  @override
  Widget build(BuildContext context) {
    final help = repository ?? CommunityHelpScope.of(context).help;
    final status = support ?? CommunitySupportScope.maybeOf(context)?.support;
    return BlocProvider(
      create: (_) => HelpCenterCubit(help: help, support: status, language: helpLanguage(context))..load(),
      child: _HelpCenterView(help: help, onContactSupport: onContactSupport ?? openSupportFromHelp),
    );
  }
}

Future<void> openCommunityHelpCenter(BuildContext context, {CommunityHelpContactCallback? onContactSupport}) {
  final help = CommunityHelpScope.of(context).help;
  return pushHelpPage(
    context,
    help,
    title: context.communityL10n.helpTitle,
    body: CommunityHelpCenter(onContactSupport: onContactSupport, repository: help),
  );
}

class _HelpCenterView extends StatefulWidget {
  const _HelpCenterView({required this.help, required this.onContactSupport});

  final HelpRepository help;
  final CommunityHelpContactCallback onContactSupport;

  @override
  State<_HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<_HelpCenterView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _openArticle(HelpArticle article, HelpCenterContent content) => openCommunityHelpArticle(
    context,
    article,
    repository: widget.help,
    categoryName: content.category(article.category)?.name,
    onContactSupport: widget.onContactSupport,
  );

  void _openIncident(BuildContext context, SupportIncident incident, HelpCenterContent content) {
    final id = incident.faqArticleId;
    if (id == null) return;
    final known = content.articles.where((a) => a.id == id).firstOrNull;
    if (known != null) return _openArticle(known, content);
    openCommunityHelpArticleById(
      context,
      id,
      title: incident.title,
      repository: widget.help,
      onContactSupport: widget.onContactSupport,
    );
  }

  void _openCategory(HelpCategory category, HelpCenterContent content) => pushHelpPage(
    context,
    widget.help,
    title: category.name,
    body: _CategoryArticles(
      category: category,
      onOpen: (context, article) => openCommunityHelpArticle(
        context,
        article,
        repository: widget.help,
        categoryName: category.name,
        onContactSupport: widget.onContactSupport,
      ),
      onContactSupport: widget.onContactSupport,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    return BlocBuilder<HelpCenterCubit, HelpCenterState>(
      builder: (context, state) {
        final cubit = context.read<HelpCenterCubit>();
        final content = state.content;
        final error = state.error;
        if (content == null) {
          return ColoredBox(
            color: style.background,
            child: state.status == LoadStatus.failure && error != null
                ? buildHelpPart(
                    (b) => b.error,
                    context,
                    CommunityListErrorDetails(error: error, message: l10n.errorMessage(error), onRetry: cubit.load),
                    CommunityErrorView(error: error, onRetry: cubit.load),
                  )
                : buildHelpPart(
                    (b) => b.loading,
                    context,
                    const CommunityListLoadingDetails(),
                    const CommunitySkeleton(itemCount: 5),
                  ),
          );
        }
        return ColoredBox(
          color: style.background,
          child: Column(
            children: [
              if (state.offline)
                HelpOfflineNotice(
                  details: CommunityHelpOfflineDetails(
                    message: l10n.helpOffline,
                    retryLabel: l10n.retry,
                    onRetry: cubit.load,
                    savedAt: content.savedAt,
                  ),
                ),
              if (state.incidents.isNotEmpty)
                SupportIncidentBanners(
                  incidents: state.incidents,
                  onOpenArticle: (context, incident) => _openIncident(context, incident, content),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.sm),
                          child: HelpSearchField(
                            details: CommunityHelpSearchDetails(
                              controller: _query,
                              hintText: l10n.helpSearchHint,
                              clearLabel: l10n.helpSearchClear,
                              searching: state.searching,
                              onChanged: cubit.search,
                              onClear: () {
                                _query.clear();
                                cubit.clearSearch();
                              },
                            ),
                          ),
                        ),
                        if (state.searching) LinearProgressIndicator(minHeight: 2, color: style.accent),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: cubit.load,
                            child: state.searchActive
                                ? _results(context, state, content)
                                : _categories(context, content),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  EdgeInsets _listPadding(CommunityStyle style) =>
      EdgeInsets.fromLTRB(style.spacing.lg, style.spacing.sm, style.spacing.lg, style.spacing.xl);

  Widget _contact(BuildContext context, {String? topic}) {
    final l10n = context.communityL10n;
    return HelpContactCard(
      details: CommunityHelpContactDetails(
        title: l10n.helpStillNeedHelp,
        actionLabel: l10n.helpChatCs,
        topic: topic,
        onContact: () => widget.onContactSupport(context, topic),
      ),
    );
  }

  Widget _empty(BuildContext context, String message, {IconData icon = Icons.help_outline}) => buildHelpPart(
    (b) => b.empty,
    context,
    CommunityListEmptyDetails(message: message),
    CommunityEmptyView(message: message, icon: icon),
  );

  Widget _categories(BuildContext context, HelpCenterContent content) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding(style),
      children: [
        if (content.isEmpty)
          _empty(context, l10n.helpEmpty)
        else
          for (final category in content.categories)
            HelpCategoryTile(
              details: CommunityHelpCategoryDetails(
                category: category,
                icon: helpCategoryIcon(category),
                title: category.name,
                countLabel: l10n.helpCategoryCount(category.articles.length),
                onOpen: () => _openCategory(category, content),
              ),
            ),
        SizedBox(height: style.spacing.lg),
        _contact(context),
      ],
    );
  }

  Widget _results(BuildContext context, HelpCenterState state, HelpCenterContent content) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final cubit = context.read<HelpCenterCubit>();
    final error = state.searchError;
    final results = state.results;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: _listPadding(style),
      children: [
        if (error != null)
          buildHelpPart(
            (b) => b.error,
            context,
            CommunityListErrorDetails(
              error: error,
              message: l10n.errorMessage(error),
              onRetry: () => cubit.search(state.query),
            ),
            CommunityErrorView(error: error, onRetry: () => cubit.search(state.query)),
          )
        else if (results != null && results.isEmpty && !state.searching)
          _empty(context, l10n.helpSearchEmpty(state.query.trim()), icon: Icons.search_off)
        else if (results != null) ...[
          if (state.savedResults) ...[
            Text(l10n.helpSearchSaved, style: style.typography.meta),
            SizedBox(height: style.spacing.sm),
          ],
          for (final article in results)
            HelpArticleTile(
              details: CommunityHelpArticleTileDetails(
                article: article,
                title: article.question,
                subtitle: content.category(article.category)?.name,
                onOpen: () => _openArticle(article, content),
              ),
            ),
        ],
        SizedBox(height: style.spacing.lg),
        _contact(context),
      ],
    );
  }
}

class _CategoryArticles extends StatelessWidget {
  const _CategoryArticles({required this.category, required this.onOpen, required this.onContactSupport});

  final HelpCategory category;
  final void Function(BuildContext context, HelpArticle article) onOpen;
  final CommunityHelpContactCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final topics = {for (final article in category.articles) ?article.topic};
    final topic = topics.length == 1 ? topics.single : null;
    return ColoredBox(
      color: style.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: CommunityBreakpoints.contentMaxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.xl),
            children: [
              for (final article in category.articles)
                HelpArticleTile(
                  details: CommunityHelpArticleTileDetails(
                    article: article,
                    title: article.question,
                    onOpen: () => onOpen(context, article),
                  ),
                ),
              SizedBox(height: spacing.lg),
              HelpContactCard(
                details: CommunityHelpContactDetails(
                  title: l10n.helpStillNeedHelp,
                  actionLabel: l10n.helpChatCs,
                  topic: topic,
                  onContact: () => onContactSupport(context, topic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
