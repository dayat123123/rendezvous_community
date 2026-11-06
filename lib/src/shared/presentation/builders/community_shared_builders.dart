import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_shared_details.dart';

class CommunitySharedBuilders {
  const CommunitySharedBuilders({
    this.avatar,
    this.userName,
    this.card,
    this.authorRow,
    this.actionPill,
    this.actionButton,
    this.actionBar,
    this.sectionHeader,
    this.divider,
    this.tag,
    this.skeleton,
    this.loadingView,
    this.emptyView,
    this.errorView,
    this.disclaimer,
    this.moderationNotice,
    this.heldLabel,
    this.composerSuggestion,
    this.confirmDialog,
    this.linkDialog,
    this.imagePlaceholder,
    this.imageViewer,
  });

  final CommunityPartBuilder<CommunityAvatarDetails>? avatar;
  final CommunityPartBuilder<CommunityUserNameDetails>? userName;
  final CommunityPartBuilder<CommunityCardDetails>? card;
  final CommunityPartBuilder<CommunityAuthorRowDetails>? authorRow;
  final CommunityPartBuilder<CommunityActionPillDetails>? actionPill;
  final CommunityPartBuilder<CommunityActionButtonDetails>? actionButton;
  final CommunityPartBuilder<CommunityActionBarDetails>? actionBar;
  final CommunityPartBuilder<CommunitySectionHeaderDetails>? sectionHeader;
  final CommunityPartBuilder<CommunityDividerDetails>? divider;
  final CommunityPartBuilder<CommunityTagDetails>? tag;
  final CommunityPartBuilder<CommunitySkeletonDetails>? skeleton;
  final CommunityPartBuilder<CommunityLoadingViewDetails>? loadingView;
  final CommunityPartBuilder<CommunityEmptyViewDetails>? emptyView;
  final CommunityPartBuilder<CommunityErrorViewDetails>? errorView;
  final CommunityPartBuilder<CommunityDisclaimerDetails>? disclaimer;
  final CommunityPartBuilder<CommunityModerationNoticeDetails>? moderationNotice;
  final CommunityPartBuilder<CommunityHeldLabelDetails>? heldLabel;
  final CommunityPartBuilder<CommunityComposerSuggestionDetails>? composerSuggestion;
  final CommunityPartBuilder<CommunityConfirmDetails>? confirmDialog;
  final CommunityPartBuilder<CommunityLinkConfirmDetails>? linkDialog;
  final CommunityPartBuilder<CommunityImagePlaceholderDetails>? imagePlaceholder;
  final CommunityPartBuilder<CommunityImageViewerDetails>? imageViewer;

  static CommunitySharedBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunitySharedBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunitySharedBuildersScope>();
    return scope?.builders ?? const CommunitySharedBuilders();
  }

  CommunitySharedBuilders merge(CommunitySharedBuilders? other) {
    if (other == null) return this;
    return CommunitySharedBuilders(
      avatar: other.avatar ?? avatar,
      userName: other.userName ?? userName,
      card: other.card ?? card,
      authorRow: other.authorRow ?? authorRow,
      actionPill: other.actionPill ?? actionPill,
      actionButton: other.actionButton ?? actionButton,
      actionBar: other.actionBar ?? actionBar,
      sectionHeader: other.sectionHeader ?? sectionHeader,
      divider: other.divider ?? divider,
      tag: other.tag ?? tag,
      skeleton: other.skeleton ?? skeleton,
      loadingView: other.loadingView ?? loadingView,
      emptyView: other.emptyView ?? emptyView,
      errorView: other.errorView ?? errorView,
      disclaimer: other.disclaimer ?? disclaimer,
      moderationNotice: other.moderationNotice ?? moderationNotice,
      heldLabel: other.heldLabel ?? heldLabel,
      composerSuggestion: other.composerSuggestion ?? composerSuggestion,
      confirmDialog: other.confirmDialog ?? confirmDialog,
      linkDialog: other.linkDialog ?? linkDialog,
      imagePlaceholder: other.imagePlaceholder ?? imagePlaceholder,
      imageViewer: other.imageViewer ?? imageViewer,
    );
  }
}

class CommunitySharedBuildersScope extends InheritedWidget {
  const CommunitySharedBuildersScope({super.key, required this.builders, required super.child});

  final CommunitySharedBuilders builders;

  @override
  bool updateShouldNotify(CommunitySharedBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildSharedPart<T>(
  CommunityPartBuilder<T>? Function(CommunitySharedBuilders builders) slot,
  BuildContext context,
  T details,
  Widget fallback,
) => buildCommunityPart(slot(CommunitySharedBuilders.of(context)), context, details, fallback);
