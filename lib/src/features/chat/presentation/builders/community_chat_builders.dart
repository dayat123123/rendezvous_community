import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/features/chat/presentation/builders/community_chat_details.dart';
import 'package:rendezvous_community/src/shared/presentation/builders/community_part_builder.dart';

class CommunityChatBuilders {
  const CommunityChatBuilders({
    this.message,
    this.composer,
    this.roomHeader,
    this.typingIndicator,
    this.connectionBanner,
    this.dayDivider,
    this.floatingDate,
    this.roomTile,
    this.listHeader,
    this.loading,
    this.empty,
    this.error,
    this.stockCard,
    this.deliveryNotice,
    this.reactionPicker,
    this.reactions,
    this.receipt,
    this.messageActions,
    this.messageInfo,
    this.jumpToLatest,
    this.roomNotice,
    this.moderationBanner,
    this.moderationDialog,
    this.roomAvatar,
    this.newGroupDialog,
    this.shareTarget,
    this.sharedPost,
    this.stockCardPicker,
    this.requestsEntry,
    this.requestTile,
    this.requestIntro,
    this.requestActions,
    this.requestBubble,
  });

  final CommunityPartBuilder<CommunityMessageDetails>? message;
  final CommunityPartBuilder<CommunityComposerDetails>? composer;
  final CommunityPartBuilder<CommunityRoomHeaderDetails>? roomHeader;
  final CommunityPartBuilder<CommunityTypingDetails>? typingIndicator;
  final CommunityPartBuilder<CommunityConnectionDetails>? connectionBanner;
  final CommunityPartBuilder<CommunityDayDetails>? dayDivider;
  final CommunityPartBuilder<CommunityDayDetails>? floatingDate;
  final CommunityPartBuilder<CommunityRoomTileDetails>? roomTile;
  final CommunityPartBuilder<CommunityChatListHeaderDetails>? listHeader;
  final CommunityPartBuilder<CommunityLoadingDetails>? loading;
  final CommunityPartBuilder<CommunityEmptyDetails>? empty;
  final CommunityPartBuilder<CommunityErrorDetails>? error;
  final CommunityPartBuilder<CommunityStockCardDetails>? stockCard;
  final CommunityPartBuilder<CommunityDeliveryNoticeDetails>? deliveryNotice;
  final CommunityPartBuilder<CommunityReactionPickerDetails>? reactionPicker;
  final CommunityPartBuilder<CommunityReactionsDetails>? reactions;
  final CommunityPartBuilder<CommunityReceiptDetails>? receipt;
  final CommunityPartBuilder<CommunityMessageActionsDetails>? messageActions;
  final CommunityPartBuilder<CommunityMessageInfoDetails>? messageInfo;
  final CommunityPartBuilder<CommunityJumpToLatestDetails>? jumpToLatest;
  final CommunityPartBuilder<CommunityRoomNoticeDetails>? roomNotice;
  final CommunityPartBuilder<CommunityRoomModerationDetails>? moderationBanner;
  final CommunityPartBuilder<CommunityRoomModerationDialogDetails>? moderationDialog;
  final CommunityPartBuilder<CommunityRoomAvatarDetails>? roomAvatar;
  final CommunityPartBuilder<CommunityNewGroupDetails>? newGroupDialog;
  final CommunityPartBuilder<CommunityShareTargetDetails>? shareTarget;
  final CommunityPartBuilder<CommunitySharedPostDetails>? sharedPost;
  final CommunityPartBuilder<CommunityStockCardPickerDetails>? stockCardPicker;
  final CommunityPartBuilder<CommunityRequestsEntryDetails>? requestsEntry;
  final CommunityPartBuilder<CommunityMessageRequestDetails>? requestTile;
  final CommunityPartBuilder<CommunityRequestIntroDetails>? requestIntro;
  final CommunityPartBuilder<CommunityRequestActionsDetails>? requestActions;
  final CommunityPartBuilder<CommunityMessageDetails>? requestBubble;

  static CommunityChatBuilders of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<CommunityChatBuildersScope>()
        : context.getInheritedWidgetOfExactType<CommunityChatBuildersScope>();
    return scope?.builders ?? const CommunityChatBuilders();
  }

  CommunityChatBuilders merge(CommunityChatBuilders? other) {
    if (other == null) return this;
    return CommunityChatBuilders(
      message: other.message ?? message,
      composer: other.composer ?? composer,
      roomHeader: other.roomHeader ?? roomHeader,
      typingIndicator: other.typingIndicator ?? typingIndicator,
      connectionBanner: other.connectionBanner ?? connectionBanner,
      dayDivider: other.dayDivider ?? dayDivider,
      floatingDate: other.floatingDate ?? floatingDate,
      roomTile: other.roomTile ?? roomTile,
      listHeader: other.listHeader ?? listHeader,
      loading: other.loading ?? loading,
      empty: other.empty ?? empty,
      error: other.error ?? error,
      stockCard: other.stockCard ?? stockCard,
      deliveryNotice: other.deliveryNotice ?? deliveryNotice,
      reactionPicker: other.reactionPicker ?? reactionPicker,
      reactions: other.reactions ?? reactions,
      receipt: other.receipt ?? receipt,
      messageActions: other.messageActions ?? messageActions,
      messageInfo: other.messageInfo ?? messageInfo,
      jumpToLatest: other.jumpToLatest ?? jumpToLatest,
      roomNotice: other.roomNotice ?? roomNotice,
      moderationBanner: other.moderationBanner ?? moderationBanner,
      moderationDialog: other.moderationDialog ?? moderationDialog,
      roomAvatar: other.roomAvatar ?? roomAvatar,
      newGroupDialog: other.newGroupDialog ?? newGroupDialog,
      shareTarget: other.shareTarget ?? shareTarget,
      sharedPost: other.sharedPost ?? sharedPost,
      stockCardPicker: other.stockCardPicker ?? stockCardPicker,
      requestsEntry: other.requestsEntry ?? requestsEntry,
      requestTile: other.requestTile ?? requestTile,
      requestIntro: other.requestIntro ?? requestIntro,
      requestActions: other.requestActions ?? requestActions,
      requestBubble: other.requestBubble ?? requestBubble,
    );
  }
}

class CommunityChatBuildersScope extends InheritedWidget {
  const CommunityChatBuildersScope({super.key, required this.builders, required super.child});

  final CommunityChatBuilders builders;

  @override
  bool updateShouldNotify(CommunityChatBuildersScope oldWidget) => !identical(builders, oldWidget.builders);
}

Widget buildChatPart<T>(CommunityPartBuilder<T>? builder, BuildContext context, T details, Widget fallback) =>
    buildCommunityPart(builder, context, details, fallback);

Widget withChatBuilders(BuildContext context, CommunityChatBuilders? builders, Widget child) => builders == null
    ? child
    : CommunityChatBuildersScope(builders: CommunityChatBuilders.of(context).merge(builders), child: child);
