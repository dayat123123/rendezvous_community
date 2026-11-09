import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/help/domain/entities/help_article.dart';
import 'package:rendezvous_community/src/features/support/domain/entities/support_ticket.dart';

class CommunityHelpSearchDetails {
  const CommunityHelpSearchDetails({
    required this.controller,
    required this.hintText,
    required this.clearLabel,
    required this.onChanged,
    required this.onClear,
    this.searching = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String clearLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool searching;
}

class CommunityHelpCategoryDetails {
  const CommunityHelpCategoryDetails({
    required this.category,
    required this.icon,
    required this.title,
    required this.countLabel,
    required this.onOpen,
  });

  final HelpCategory category;
  final IconData icon;
  final String title;
  final String countLabel;
  final VoidCallback onOpen;

  String get code => category.code;

  int get articleCount => category.articles.length;
}

class CommunityHelpArticleTileDetails {
  const CommunityHelpArticleTileDetails({
    required this.article,
    required this.title,
    required this.onOpen,
    this.subtitle,
  });

  final HelpArticle article;
  final String title;
  final String? subtitle;
  final VoidCallback onOpen;
}

class CommunityHelpArticleDetails {
  const CommunityHelpArticleDetails({
    required this.article,
    required this.title,
    required this.body,
    required this.feedback,
    required this.contact,
    this.updatedLabel,
    this.categoryName,
    this.loading = false,
    this.offline = false,
  });

  final HelpArticle article;
  final String title;
  final String? updatedLabel;
  final String? categoryName;
  final Widget body;
  final Widget feedback;
  final Widget contact;
  final bool loading;
  final bool offline;

  String get answer => article.answer;

  String? get topic => article.topic;
}

class CommunityHelpFeedbackDetails {
  const CommunityHelpFeedbackDetails({
    required this.question,
    required this.yesLabel,
    required this.noLabel,
    required this.thanksLabel,
    required this.commentLabel,
    required this.submitLabel,
    required this.commentSentLabel,
    required this.controller,
    required this.busy,
    required this.commentSent,
    this.feedback,
    this.onVote,
    this.onSubmitComment,
    this.maxCommentLength = 500,
  });

  final String question;
  final String yesLabel;
  final String noLabel;
  final String thanksLabel;
  final String commentLabel;
  final String submitLabel;
  final String commentSentLabel;
  final TextEditingController controller;
  final bool busy;
  final bool commentSent;
  final HelpFeedback? feedback;
  final ValueChanged<bool>? onVote;
  final VoidCallback? onSubmitComment;
  final int maxCommentLength;

  bool? get helpful => feedback?.helpful;

  bool get voted => feedback != null;
}

class CommunityHelpContactDetails {
  const CommunityHelpContactDetails({
    required this.title,
    required this.actionLabel,
    required this.onContact,
    this.topic,
  });

  final String title;
  final String actionLabel;
  final String? topic;
  final VoidCallback onContact;
}

class CommunityHelpOfflineDetails {
  const CommunityHelpOfflineDetails({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.savedAt,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  final DateTime? savedAt;
}

class CommunityHelpSuggestionsDetails {
  const CommunityHelpSuggestionsDetails({
    required this.topicCode,
    required this.title,
    required this.hint,
    required this.articles,
    required this.continueLabel,
    required this.backLabel,
    required this.onOpenArticle,
    required this.onContinue,
    required this.onBack,
    this.topic,
    this.busy = false,
    this.notice,
    this.outOfHours = false,
  });

  final String topicCode;
  final SupportTopic? topic;
  final String title;
  final String hint;
  final List<HelpArticle> articles;
  final String continueLabel;
  final String backLabel;
  final ValueChanged<HelpArticle> onOpenArticle;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final bool busy;
  final String? notice;
  final bool outOfHours;
}
