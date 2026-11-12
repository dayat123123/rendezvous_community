import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/compose/presentation/composer_action.dart';
import 'package:rendezvous_community/src/features/drafts/domain/entities/post_draft.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_filter.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/pinned_post.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/features/feed/presentation/widgets/community_stream_feed.dart';
import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';
import 'package:rendezvous_community/src/features/link_preview/domain/entities/link_preview.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/document_type.dart';
import 'package:rendezvous_community/src/features/poll/domain/entities/poll.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/comment_sort.dart';
import 'package:rendezvous_community/src/features/post/domain/entities/thread_comment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

class CommunityPostDetails {
  const CommunityPostDetails({
    required this.post,
    required this.isMine,
    required this.timeLabel,
    required this.onLike,
    required this.onOpenAuthor,
    required this.onOpenStock,
    required this.onOpenHashtag,
    this.expanded = false,
    this.source = 'feed',
    this.pinned,
    this.onOpen,
    this.onComment,
    this.onShare,
    this.onToggleBookmark,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.onAppeal,
    this.commentsExpanded = false,
    this.onToggleComments,
    this.topComment,
    this.onOpenComments,
    this.onOpenImage,
  });

  final Post post;
  final bool isMine;
  final String timeLabel;
  final bool expanded;
  final String source;
  final PinnedPost? pinned;
  final VoidCallback onLike;
  final VoidCallback onOpenAuthor;
  final ValueChanged<String> onOpenStock;
  final ValueChanged<String> onOpenHashtag;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onToggleBookmark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onAppeal;
  final bool commentsExpanded;
  final VoidCallback? onToggleComments;
  final ThreadComment? topComment;
  final VoidCallback? onOpenComments;
  final ValueChanged<int>? onOpenImage;

  bool get edited => post.editedAt != null;

  bool get canVote => !isMine;
}

class CommunityPinnedMarkerDetails {
  const CommunityPinnedMarkerDetails({required this.pinned, required this.label});

  final PinnedPost pinned;
  final String label;

  bool get announcement => pinned.announcement;

  String? get title => pinned.title;
}

class CommunityLinkPreviewDetails {
  const CommunityLinkPreviewDetails({required this.preview, this.onOpen});

  final LinkPreview preview;
  final VoidCallback? onOpen;
}

class CommunityPollDetails {
  const CommunityPollDetails({
    required this.postId,
    required this.poll,
    required this.canVote,
    required this.closed,
    required this.showResults,
    required this.summary,
    this.pendingOptionId,
    this.onVote,
  });

  final String postId;
  final Poll poll;
  final bool canVote;
  final bool closed;
  final bool showResults;
  final String summary;
  final String? pendingOptionId;
  final ValueChanged<PollOption>? onVote;
}

class CommunityCommentDetails {
  const CommunityCommentDetails({
    required this.comment,
    required this.isMine,
    required this.collapsed,
    required this.timeLabel,
    this.onLike,
    this.onReply,
    this.onToggleCollapse,
    this.onOpenAuthor,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onBlock,
    this.onAppeal,
    this.level = 0,
    this.hasVisibleReplies = false,
    this.isLastSibling = false,
  });

  final ThreadComment comment;
  final bool isMine;
  final bool collapsed;
  final String timeLabel;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onToggleCollapse;
  final VoidCallback? onOpenAuthor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onAppeal;
  final int level;
  final bool hasVisibleReplies;
  final bool isLastSibling;

  int get replyCount => comment.replyCount;

  bool get edited => comment.editedAt != null && !comment.isDeleted;
}

class CommunityInlineCommentsDetails {
  const CommunityInlineCommentsDetails({
    required this.post,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final Post post;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
}

class CommunityCommentSortDetails {
  const CommunityCommentSortDetails({
    required this.title,
    required this.tooltip,
    required this.selected,
    required this.options,
    required this.labels,
    this.onSelect,
  });

  final String title;
  final String tooltip;
  final CommunityCommentSort selected;
  final List<CommunityCommentSort> options;
  final List<String> labels;
  final ValueChanged<CommunityCommentSort>? onSelect;

  String get selectedLabel {
    final index = options.indexOf(selected);
    return labels[index < 0 ? 0 : index];
  }
}

enum CommunityThreadMoreKind { moreReplies, continueThread, moreComments }

class CommunityFeedTabsDetails {
  const CommunityFeedTabsDetails({
    required this.tabs,
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  final List<CommunityFeedTab> tabs;
  final List<String> labels;
  final CommunityFeedTab selected;
  final ValueChanged<CommunityFeedTab> onSelect;
}

class CommunityFeedFilterTabsDetails {
  const CommunityFeedFilterTabsDetails({
    required this.filters,
    required this.labels,
    required this.selected,
    required this.onSelect,
    this.loading = false,
  });

  final List<FeedFilter> filters;
  final List<String> labels;
  final String? selected;
  final ValueChanged<FeedFilter> onSelect;
  final bool loading;
}

class CommunityNewPostsDetails {
  const CommunityNewPostsDetails({required this.count, required this.label, required this.onTap});

  final int count;
  final String label;
  final VoidCallback onTap;
}

class CommunityComposePromptDetails {
  const CommunityComposePromptDetails({
    required this.user,
    required this.hintText,
    required this.onCompose,
    this.onComposeWith,
    this.quickActions = const [],
  });

  final UserSummary? user;
  final String hintText;
  final VoidCallback onCompose;
  final void Function({Sentiment? sentiment, CommunityComposerAction? action})? onComposeWith;
  final List<CommunityComposeQuickAction> quickActions;
}

class CommunityComposeQuickAction {
  const CommunityComposeQuickAction({required this.label, required this.icon, this.sentiment, this.action});

  final String label;
  final IconData icon;
  final Sentiment? sentiment;
  final CommunityComposerAction? action;
}

class CommunityThreadHeaderDetails {
  const CommunityThreadHeaderDetails({required this.post, required this.commentCount, required this.label});

  final Post post;
  final int commentCount;
  final String label;
}

class CommunityThreadContextDetails {
  const CommunityThreadContextDetails({
    required this.root,
    required this.label,
    required this.actionLabel,
    required this.comment,
    required this.onOpenPost,
  });

  final ThreadComment root;
  final String label;
  final String actionLabel;
  final Widget comment;
  final VoidCallback onOpenPost;
}

class CommunityReplyComposerDetails {
  const CommunityReplyComposerDetails({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.sending,
    required this.sendLabel,
    required this.cancelLabel,
    required this.field,
    this.replyTo,
    this.replyingLabel,
    this.onSend,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool sending;
  final String sendLabel;
  final String cancelLabel;
  final Widget field;
  final ThreadComment? replyTo;
  final String? replyingLabel;
  final VoidCallback? onSend;
  final VoidCallback? onCancelReply;
}

class CommunityThreadMoreDetails {
  const CommunityThreadMoreDetails({
    required this.kind,
    required this.label,
    required this.level,
    this.remaining,
    this.loading = false,
    this.onTap,
  });

  final CommunityThreadMoreKind kind;
  final String label;
  final int level;
  final int? remaining;
  final bool loading;
  final VoidCallback? onTap;
}

typedef CommunityComposeFieldBuilder =
    Widget Function({TextStyle? textStyle, TextStyle? hintStyle, InputDecoration? decoration});

class CommunityComposeFieldDetails {
  const CommunityComposeFieldDetails({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.minLines,
    required this.maxLines,
    required this.enabled,
    required this.autofocus,
    required this.onSubmit,
    required this.textStyle,
    required this.hintStyle,
    required this.decoration,
    required this.field,
    required this.buildField,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final VoidCallback onSubmit;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final InputDecoration decoration;
  final Widget field;
  final CommunityComposeFieldBuilder buildField;
}

class CommunityComposeDetails {
  const CommunityComposeDetails({
    required this.controller,
    required this.posting,
    required this.uploading,
    required this.hasPoll,
    required this.imageCount,
    required this.submitLabel,
    required this.addImageLabel,
    required this.addPollLabel,
    this.onPost,
    this.onPickImage,
    this.onAddPoll,
  });

  final TextEditingController controller;
  final bool posting;
  final bool uploading;
  final bool hasPoll;
  final int imageCount;
  final String submitLabel;
  final String addImageLabel;
  final String addPollLabel;
  final VoidCallback? onPost;
  final VoidCallback? onPickImage;
  final VoidCallback? onAddPoll;

  bool get canPost => onPost != null;
}

class CommunityComposeSentimentDetails {
  const CommunityComposeSentimentDetails({
    required this.title,
    required this.selected,
    required this.options,
    required this.labels,
    required this.onChanged,
  });

  final String title;
  final Sentiment? selected;
  final List<Sentiment?> options;
  final List<String> labels;
  final ValueChanged<Sentiment?> onChanged;
}

class CommunityComposeAuthorDetails {
  const CommunityComposeAuthorDetails({required this.user, this.sentiment});

  final UserSummary user;
  final Sentiment? sentiment;
}

class CommunityComposeImageDetails {
  const CommunityComposeImageDetails({
    required this.attachment,
    required this.name,
    required this.removeLabel,
    this.onRemove,
  });

  final Attachment attachment;
  final String name;
  final String removeLabel;
  final VoidCallback? onRemove;

  bool get held => attachment.held;
}

class CommunityPollEditorDetails {
  const CommunityPollEditorDetails({
    required this.poll,
    required this.enabled,
    required this.controllers,
    required this.durationLabels,
    required this.title,
    this.onAddOption,
    this.onRemoveOption,
    this.onOptionChanged,
    this.onDurationChanged,
    this.onRemovePoll,
  });

  final PollDraft poll;
  final bool enabled;
  final List<TextEditingController> controllers;
  final Map<PollDuration, String> durationLabels;
  final String title;
  final VoidCallback? onAddOption;
  final ValueChanged<int>? onRemoveOption;
  final void Function(int index, String value)? onOptionChanged;
  final ValueChanged<PollDuration>? onDurationChanged;
  final VoidCallback? onRemovePoll;

  List<String> get options => poll.options;

  PollDuration get duration => poll.duration;

  bool get canAddOption => onAddOption != null;
}

class CommunityPollOptionDetails {
  const CommunityPollOptionDetails({
    required this.option,
    required this.index,
    required this.share,
    required this.showResults,
    required this.resultsVisible,
    required this.mine,
    required this.leading,
    required this.pending,
    this.percentLabel,
    this.onVote,
  });

  final PollOption option;
  final int index;
  final double share;
  final bool showResults;
  final bool resultsVisible;
  final bool mine;
  final bool leading;
  final bool pending;
  final String? percentLabel;
  final VoidCallback? onVote;
}

class CommunityAttachmentImageDetails {
  const CommunityAttachmentImageDetails({
    required this.attachment,
    required this.index,
    required this.count,
    required this.blurred,
    required this.image,
  });

  final Attachment attachment;
  final int index;
  final int count;
  final bool blurred;
  final Widget image;

  bool get held => attachment.held;
}

class CommunityDocumentDetails {
  const CommunityDocumentDetails({
    required this.attachment,
    required this.name,
    required this.sizeLabel,
    required this.color,
    required this.opening,
    required this.semanticLabel,
    this.onOpen,
    this.type = CommunityDocumentType.pdf,
    this.typeLabel = 'PDF',
  });

  final Attachment attachment;
  final String name;
  final String sizeLabel;
  final Color color;
  final bool opening;
  final String semanticLabel;
  final VoidCallback? onOpen;
  final CommunityDocumentType type;
  final String typeLabel;
}

class CommunityDraftDetails {
  const CommunityDraftDetails({
    required this.draft,
    required this.preview,
    required this.timeLabel,
    required this.subtitle,
    required this.deleteLabel,
    required this.onOpen,
    required this.onDelete,
  });

  final PostDraft draft;
  final String preview;
  final String timeLabel;
  final String subtitle;
  final String deleteLabel;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  bool get synced => draft.synced;
}

class CommunityStockHeaderDetails {
  const CommunityStockHeaderDetails({
    required this.code,
    required this.found,
    required this.loaded,
    required this.watching,
    required this.joining,
    required this.watchLabel,
    required this.discussionLabel,
    this.name,
    this.subtitle,
    this.onToggleWatch,
    this.onOpenDiscussion,
  });

  final String code;
  final bool found;
  final bool loaded;
  final bool watching;
  final bool joining;
  final String watchLabel;
  final String discussionLabel;
  final String? name;
  final String? subtitle;
  final VoidCallback? onToggleWatch;
  final VoidCallback? onOpenDiscussion;
}

class CommunityEditDialogDetails {
  const CommunityEditDialogDetails({
    required this.title,
    required this.controller,
    required this.maxLength,
    required this.saveLabel,
    required this.cancelLabel,
    required this.field,
    required this.onSave,
    required this.onCancel,
  });

  final String title;
  final TextEditingController controller;
  final int maxLength;
  final String saveLabel;
  final String cancelLabel;
  final Widget field;
  final VoidCallback onSave;
  final VoidCallback onCancel;
}

class CommunityIndexHeaderDetails {
  const CommunityIndexHeaderDetails({
    required this.code,
    required this.name,
    required this.kindLabel,
    required this.found,
    required this.loaded,
    required this.watching,
    required this.joining,
    required this.roomEnabled,
    required this.watchLabel,
    required this.discussionLabel,
    required this.roomClosedLabel,
    this.instrument,
    this.description,
    this.aliases = const [],
    this.aliasesLabel,
    this.subtitle,
    this.onToggleWatch,
    this.onOpenDiscussion,
  });

  final String code;
  final String name;
  final String kindLabel;
  final bool found;
  final bool loaded;
  final bool watching;
  final bool joining;
  final bool roomEnabled;
  final String watchLabel;
  final String discussionLabel;
  final String roomClosedLabel;
  final MarketInstrument? instrument;
  final String? description;
  final List<String> aliases;
  final String? aliasesLabel;
  final String? subtitle;
  final VoidCallback? onToggleWatch;
  final VoidCallback? onOpenDiscussion;
}

class CommunityIndexTileDetails {
  const CommunityIndexTileDetails({
    required this.instrument,
    required this.code,
    required this.name,
    required this.kindLabel,
    required this.onOpen,
    this.postsToday,
    this.bullishPct,
    this.statsLabel,
  });

  final MarketInstrument instrument;
  final String code;
  final String name;
  final String kindLabel;
  final VoidCallback onOpen;
  final int? postsToday;
  final int? bullishPct;
  final String? statsLabel;
}
