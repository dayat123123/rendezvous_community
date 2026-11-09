import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/help/presentation/builders/community_help_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunityHelpBuilders {
  const CommunityHelpBuilders({
    this.loading,
    this.empty,
    this.error,
    this.searchField,
    this.categoryTile,
    this.articleTile,
    this.articleDetail,
    this.feedback,
    this.contact,
    this.offlineNotice,
    this.topicSuggestions,
  });

  final CommunityPartBuilder<CommunityListLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityListEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityListErrorDetails>? error;
  final CommunityPartBuilder<CommunityHelpSearchDetails>? searchField;
  final CommunityPartBuilder<CommunityHelpCategoryDetails>? categoryTile;
  final CommunityPartBuilder<CommunityHelpArticleTileDetails>? articleTile;
  final CommunityPartBuilder<CommunityHelpArticleDetails>? articleDetail;
  final CommunityPartBuilder<CommunityHelpFeedbackDetails>? feedback;
  final CommunityPartBuilder<CommunityHelpContactDetails>? contact;
  final CommunityPartBuilder<CommunityHelpOfflineDetails>? offlineNotice;
  final CommunityPartBuilder<CommunityHelpSuggestionsDetails>? topicSuggestions;

  static CommunityHelpBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunityHelpBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunityHelpBuildersScope>();
    return scope?.builders ?? const CommunityHelpBuilders();
  }

  CommunityHelpBuilders merge(CommunityHelpBuilders? other) {
    if (other == null) return this;
    return CommunityHelpBuilders(
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      searchField: other.searchField ?? searchField,
      categoryTile: other.categoryTile ?? categoryTile,
      articleTile: other.articleTile ?? articleTile,
      articleDetail: other.articleDetail ?? articleDetail,
      feedback: other.feedback ?? feedback,
      contact: other.contact ?? contact,
      offlineNotice: other.offlineNotice ?? offlineNotice,
      topicSuggestions: other.topicSuggestions ?? topicSuggestions,
    );
  }
}

class CommunityHelpBuildersScope extends InheritedWidget {
  const CommunityHelpBuildersScope({super.key, required this.builders, required super.child});

  final CommunityHelpBuilders builders;

  @override
  bool updateShouldNotify(CommunityHelpBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildHelpPart<T>(
  CommunityPartBuilder<T>? Function(CommunityHelpBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunityHelpBuilders.of(context)), context, details, fallback);
