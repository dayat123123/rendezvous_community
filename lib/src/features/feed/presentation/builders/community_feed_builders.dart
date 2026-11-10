import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/feed/presentation/builders/community_feed_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_list_state_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunityFeedBuilders {
  const CommunityFeedBuilders({
    this.postCard,
    this.postAvatar,
    this.postHeader,
    this.postBody,
    this.attachments,
    this.linkPreview,
    this.stockTags,
    this.actionBar,
    this.poll,
    this.pinnedMarker,
    this.loading,
    this.empty,
    this.error,
    this.comment,
    this.postMenu,
    this.feedTabs,
    this.newPosts,
    this.composePrompt,
    this.threadHeader,
    this.threadContext,
    this.replyComposer,
    this.threadMore,
    this.composeToolbar,
    this.composeSentiment,
    this.composeAuthor,
    this.composeImage,
    this.pollEditor,
    this.pollOption,
    this.attachmentImage,
    this.document,
    this.draftTile,
    this.stockHeader,
    this.editDialog,
    this.inlineComments,
    this.commentSort,
    this.topComment,
    this.composeField,
  });

  final CommunityPartBuilder<CommunityPostDetails>? postCard;
  final CommunityPartBuilder<CommunityPostDetails>? postAvatar;
  final CommunityPartBuilder<CommunityPostDetails>? postHeader;
  final CommunityPartBuilder<CommunityPostDetails>? postBody;
  final CommunityPartBuilder<CommunityPostDetails>? attachments;
  final CommunityPartBuilder<CommunityLinkPreviewDetails>? linkPreview;
  final CommunityPartBuilder<CommunityPostDetails>? stockTags;
  final CommunityPartBuilder<CommunityPostDetails>? actionBar;
  final CommunityPartBuilder<CommunityPollDetails>? poll;
  final CommunityPartBuilder<CommunityPinnedMarkerDetails>? pinnedMarker;
  final CommunityPartBuilder<CommunityListLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityListEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityListErrorDetails>? error;
  final CommunityPartBuilder<CommunityCommentDetails>? comment;
  final CommunityPartBuilder<CommunityPostDetails>? postMenu;
  final CommunityPartBuilder<CommunityFeedTabsDetails>? feedTabs;
  final CommunityPartBuilder<CommunityNewPostsDetails>? newPosts;
  final CommunityPartBuilder<CommunityComposePromptDetails>? composePrompt;
  final CommunityPartBuilder<CommunityThreadHeaderDetails>? threadHeader;
  final CommunityPartBuilder<CommunityThreadContextDetails>? threadContext;
  final CommunityPartBuilder<CommunityReplyComposerDetails>? replyComposer;
  final CommunityPartBuilder<CommunityThreadMoreDetails>? threadMore;
  final CommunityPartBuilder<CommunityComposeDetails>? composeToolbar;
  final CommunityPartBuilder<CommunityComposeSentimentDetails>? composeSentiment;
  final CommunityPartBuilder<CommunityComposeAuthorDetails>? composeAuthor;
  final CommunityPartBuilder<CommunityComposeImageDetails>? composeImage;
  final CommunityPartBuilder<CommunityPollEditorDetails>? pollEditor;
  final CommunityPartBuilder<CommunityPollOptionDetails>? pollOption;
  final CommunityPartBuilder<CommunityAttachmentImageDetails>? attachmentImage;
  final CommunityPartBuilder<CommunityDocumentDetails>? document;
  final CommunityPartBuilder<CommunityDraftDetails>? draftTile;
  final CommunityPartBuilder<CommunityStockHeaderDetails>? stockHeader;
  final CommunityPartBuilder<CommunityEditDialogDetails>? editDialog;
  final CommunityPartBuilder<CommunityInlineCommentsDetails>? inlineComments;
  final CommunityPartBuilder<CommunityCommentSortDetails>? commentSort;
  final CommunityPartBuilder<CommunityPostDetails>? topComment;
  final CommunityPartBuilder<CommunityComposeFieldDetails>? composeField;

  static CommunityFeedBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunityFeedBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunityFeedBuildersScope>();
    return scope?.builders ?? const CommunityFeedBuilders();
  }

  CommunityFeedBuilders merge(CommunityFeedBuilders? other) {
    if (other == null) return this;
    return CommunityFeedBuilders(
      postCard: other.postCard ?? postCard,
      postAvatar: other.postAvatar ?? postAvatar,
      postHeader: other.postHeader ?? postHeader,
      postBody: other.postBody ?? postBody,
      attachments: other.attachments ?? attachments,
      linkPreview: other.linkPreview ?? linkPreview,
      stockTags: other.stockTags ?? stockTags,
      actionBar: other.actionBar ?? actionBar,
      poll: other.poll ?? poll,
      pinnedMarker: other.pinnedMarker ?? pinnedMarker,
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      comment: other.comment ?? comment,
      postMenu: other.postMenu ?? postMenu,
      feedTabs: other.feedTabs ?? feedTabs,
      newPosts: other.newPosts ?? newPosts,
      composePrompt: other.composePrompt ?? composePrompt,
      threadHeader: other.threadHeader ?? threadHeader,
      threadContext: other.threadContext ?? threadContext,
      replyComposer: other.replyComposer ?? replyComposer,
      threadMore: other.threadMore ?? threadMore,
      composeToolbar: other.composeToolbar ?? composeToolbar,
      composeSentiment: other.composeSentiment ?? composeSentiment,
      composeAuthor: other.composeAuthor ?? composeAuthor,
      composeImage: other.composeImage ?? composeImage,
      pollEditor: other.pollEditor ?? pollEditor,
      pollOption: other.pollOption ?? pollOption,
      attachmentImage: other.attachmentImage ?? attachmentImage,
      document: other.document ?? document,
      draftTile: other.draftTile ?? draftTile,
      stockHeader: other.stockHeader ?? stockHeader,
      editDialog: other.editDialog ?? editDialog,
      inlineComments: other.inlineComments ?? inlineComments,
      commentSort: other.commentSort ?? commentSort,
      topComment: other.topComment ?? topComment,
      composeField: other.composeField ?? composeField,
    );
  }
}

class CommunityFeedBuildersScope extends InheritedWidget {
  const CommunityFeedBuildersScope({super.key, required this.builders, required super.child});

  final CommunityFeedBuilders builders;

  @override
  bool updateShouldNotify(CommunityFeedBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget withFeedBuilders(BuildContext context, CommunityFeedBuilders? builders, Widget child) => builders == null
    ? child
    : CommunityFeedBuildersScope(builders: CommunityFeedBuilders.of(context).merge(builders), child: child);

Widget buildFeedPart<T>(
  CommunityPartBuilder<T>? Function(CommunityFeedBuilders builders) select,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(select(CommunityFeedBuilders.of(context)), context, details, fallback);
