import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/core/network/realtime_status.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_message.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/chat_room.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_extras.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/message_info.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/outgoing_file.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/receipt.dart';
import 'package:rendezvous_community/src/features/chat/domain/entities/room_moderation.dart';
import 'package:rendezvous_community/src/features/group/domain/entities/group_event.dart';
import 'package:rendezvous_community/src/features/media/domain/entities/attachment_policy.dart';
import 'package:rendezvous_community/src/features/message_requests/domain/entities/message_request.dart';
import 'package:rendezvous_community/src/features/moderation/domain/entities/report.dart';
import 'package:rendezvous_community/src/features/stocks/domain/entities/stock_info.dart';
import 'package:rendezvous_community/src/shared/domain/entities/attachment.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

class CommunityMessageDetails {
  const CommunityMessageDetails({
    required this.message,
    required this.isMine,
    required this.receipt,
    required this.showSender,
    required this.startsGroup,
    required this.timeLabel,
    this.onReply,
    this.onDelete,
    this.onReport,
    this.onRetry,
    this.onDiscard,
    this.onSenderTap,
    this.onShowActions,
    this.reactions = const [],
    this.reactionChoices = const [],
    this.onReact,
    this.onAppeal,
    this.onOpenSharedPost,
    this.senderIsModerator = false,
    this.senderMutedUntil,
    this.onHide,
    this.onMuteSender,
    this.onEscalate,
    this.endsGroup = true,
    this.showAvatar = false,
    this.replyToName,
    this.onReplyTap,
    this.onCopy,
    this.onInfo,
  });

  final ChatMessage message;
  final bool isMine;
  final ReceiptStatus? receipt;
  final bool showSender;
  final bool startsGroup;
  final String timeLabel;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;
  final VoidCallback? onSenderTap;
  final VoidCallback? onShowActions;
  final List<MessageReaction> reactions;
  final List<String> reactionChoices;
  final ValueChanged<String>? onReact;
  final VoidCallback? onAppeal;
  final VoidCallback? onOpenSharedPost;
  final bool senderIsModerator;
  final DateTime? senderMutedUntil;
  final VoidCallback? onHide;
  final VoidCallback? onMuteSender;
  final VoidCallback? onEscalate;
  final bool endsGroup;
  final bool showAvatar;
  final String? replyToName;
  final VoidCallback? onReplyTap;
  final VoidCallback? onCopy;
  final VoidCallback? onInfo;

  bool get hasModeration => onHide != null || onMuteSender != null || onEscalate != null;
}

class CommunityComposerDetails {
  const CommunityComposerDetails({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.maxLength,
    required this.uploading,
    required this.onSend,
    this.replyTo,
    this.replyPreview,
    this.onCancelReply,
    this.onPickImage,
    this.allowsDocuments = false,
    this.extraActions = const [],
    this.cooldown = Duration.zero,
    this.onSendStockCard,
    this.mutedUntil,
    this.replyToName,
    this.onPaste,
    this.onContentInserted,
    this.files = const [],
    this.onRemoveFile,
    this.attachmentPolicy = CommunityAttachmentPolicy.imagesOnly,
    this.attachLabel,
    this.uploadingLabel,
    this.enabled = true,
    this.enableAutocomplete = true,
    this.fieldKey,
    this.sendKey,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final int maxLength;
  final bool uploading;
  final VoidCallback onSend;
  final ChatMessage? replyTo;
  final String? replyPreview;
  final VoidCallback? onCancelReply;
  final VoidCallback? onPickImage;
  final bool allowsDocuments;
  final List<Widget> extraActions;
  final Duration cooldown;
  final VoidCallback? onSendStockCard;
  final DateTime? mutedUntil;
  final String? replyToName;
  final Future<bool> Function()? onPaste;
  final ValueChanged<Uint8List>? onContentInserted;
  final List<ChatOutgoingFile> files;
  final ValueChanged<int>? onRemoveFile;
  final CommunityAttachmentPolicy attachmentPolicy;
  final String? attachLabel;
  final String? uploadingLabel;
  final bool enabled;
  final bool enableAutocomplete;
  final Key? fieldKey;
  final Key? sendKey;

  bool get coolingDown => cooldown > Duration.zero;

  bool get muted => mutedUntil != null;

  int get cooldownSeconds => (cooldown.inMilliseconds + 999) ~/ 1000;
}

class CommunityRoomHeaderDetails {
  const CommunityRoomHeaderDetails({
    required this.room,
    required this.title,
    required this.subtitle,
    required this.highlightSubtitle,
    required this.online,
    required this.typing,
    required this.memberCount,
    this.onTap,
    this.onToggleMute,
    this.onLeave,
  });

  final ChatRoom room;
  final String title;
  final String subtitle;
  final bool highlightSubtitle;
  final bool online;
  final List<UserSummary> typing;
  final int memberCount;
  final VoidCallback? onTap;
  final VoidCallback? onToggleMute;
  final VoidCallback? onLeave;
}

class CommunityTypingDetails {
  const CommunityTypingDetails({required this.users, required this.text, this.count = 0});

  final List<UserSummary> users;
  final String text;
  final int count;
}

class CommunityOfficialNoticeDetails {
  const CommunityOfficialNoticeDetails({
    required this.user,
    required this.message,
    required this.contactLabel,
    this.onContact,
  });

  final UserSummary user;
  final String message;
  final String contactLabel;
  final VoidCallback? onContact;
}

class CommunityGroupEventDetails {
  const CommunityGroupEventDetails({required this.message, required this.event, required this.text});

  final ChatMessage message;
  final GroupEvent event;
  final String text;
}

class CommunityGroupNoticeDetails {
  const CommunityGroupNoticeDetails({required this.room, required this.message, required this.removed});

  final ChatRoom room;
  final String message;
  final bool removed;
}

class CommunityGroupMemberDetails {
  const CommunityGroupMemberDetails({
    required this.member,
    required this.isMe,
    required this.title,
    this.roleLabel,
    this.onTap,
  });

  final RoomMember member;
  final bool isMe;
  final String title;
  final String? roleLabel;
  final VoidCallback? onTap;
}

class CommunityGroupEditDetails {
  const CommunityGroupEditDetails({
    required this.nameController,
    required this.descriptionController,
    required this.nameMaxLength,
    required this.descriptionMaxLength,
    required this.title,
    required this.nameLabel,
    required this.descriptionLabel,
    required this.saveLabel,
    required this.cancelLabel,
    required this.onCancel,
    this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final int nameMaxLength;
  final int descriptionMaxLength;
  final String title;
  final String nameLabel;
  final String descriptionLabel;
  final String saveLabel;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  bool get canSave => onSave != null;
}

class CommunityGroupAddMembersDetails {
  const CommunityGroupAddMembersDetails({
    required this.queryController,
    required this.results,
    required this.selected,
    required this.onQueryChanged,
    required this.onToggle,
    required this.title,
    required this.addLabel,
    required this.cancelLabel,
    required this.onCancel,
    this.onAdd,
  });

  final TextEditingController queryController;
  final List<UserSummary> results;
  final List<UserSummary> selected;
  final ValueChanged<String> onQueryChanged;
  final void Function(UserSummary user, bool selected) onToggle;
  final String title;
  final String addLabel;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback? onAdd;

  bool get canAdd => onAdd != null;

  bool isSelected(UserSummary user) => selected.any((u) => u.id == user.id);
}

enum CommunityGroupMemberActionKind { viewProfile, makeAdmin, dismissAdmin, makeOwner, remove }

class CommunityGroupMemberAction {
  const CommunityGroupMemberAction({
    required this.kind,
    required this.label,
    required this.onSelected,
    this.destructive = false,
  });

  final CommunityGroupMemberActionKind kind;
  final String label;
  final bool destructive;
  final VoidCallback onSelected;
}

class CommunityGroupMemberActionsDetails {
  const CommunityGroupMemberActionsDetails({required this.member, required this.actions, required this.onDismiss});

  final RoomMember member;
  final List<CommunityGroupMemberAction> actions;
  final VoidCallback onDismiss;
}

class CommunityGroupSettingDetails {
  const CommunityGroupSettingDetails({
    required this.kind,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final GroupSetting kind;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class CommunityGroupInfoPageDetails {
  const CommunityGroupInfoPageDetails({
    required this.room,
    required this.title,
    required this.memberCount,
    required this.membersLabel,
    required this.descriptionEmptyLabel,
    required this.avatar,
    required this.buildAvatar,
    required this.canEditInfo,
    required this.isAdmin,
    required this.hasPhoto,
    required this.busy,
    required this.editInfoLabel,
    required this.changePhotoLabel,
    required this.removePhotoLabel,
    required this.settingsTitle,
    required this.settings,
    required this.membersTitle,
    required this.members,
    required this.addMembersLabel,
    required this.onLeave,
    required this.leaveLabel,
    this.description,
    this.onEditInfo,
    this.onChangePhoto,
    this.onRemovePhoto,
    this.onAddMembers,
  });

  final ChatRoom room;
  final String title;
  final int memberCount;
  final String membersLabel;
  final String? description;
  final String descriptionEmptyLabel;
  final Widget avatar;
  final Widget Function({required double radius}) buildAvatar;
  final bool canEditInfo;
  final bool isAdmin;
  final bool hasPhoto;
  final bool busy;
  final VoidCallback? onEditInfo;
  final VoidCallback? onChangePhoto;
  final VoidCallback? onRemovePhoto;
  final String editInfoLabel;
  final String changePhotoLabel;
  final String removePhotoLabel;
  final String settingsTitle;
  final List<Widget> settings;
  final String membersTitle;
  final List<Widget> members;
  final VoidCallback? onAddMembers;
  final String addMembersLabel;
  final VoidCallback onLeave;
  final String leaveLabel;
}

class CommunityConnectionDetails {
  const CommunityConnectionDetails({required this.status, required this.label, this.offline = false});

  final RealtimeStatus status;
  final String label;
  final bool offline;
}

class CommunityDayDetails {
  const CommunityDayDetails({required this.day, required this.label});

  final DateTime day;
  final String label;
}

class CommunityRoomTileDetails {
  const CommunityRoomTileDetails({
    required this.room,
    required this.title,
    required this.timeLabel,
    required this.online,
    required this.selected,
    required this.typing,
    required this.onTap,
    this.preview,
    this.typingText,
    this.lastMessageReceipt,
  });

  final ChatRoom room;
  final String title;
  final String timeLabel;
  final bool online;
  final bool selected;
  final List<UserSummary> typing;
  final VoidCallback onTap;
  final String? preview;
  final String? typingText;
  final ReceiptStatus? lastMessageReceipt;
}

class CommunityChatListHeaderDetails {
  const CommunityChatListHeaderDetails({required this.title, required this.onNewGroup, required this.onRefresh});

  final String title;
  final VoidCallback onNewGroup;
  final Future<void> Function() onRefresh;
}

enum CommunityChatLoad { rooms, moreRooms, messages, olderMessages }

class CommunityLoadingDetails {
  const CommunityLoadingDetails(this.kind);

  final CommunityChatLoad kind;
}

enum CommunityChatEmpty { rooms, messages, noRoomSelected }

class CommunityEmptyDetails {
  const CommunityEmptyDetails({required this.kind, required this.message});

  final CommunityChatEmpty kind;
  final String message;
}

class CommunityErrorDetails {
  const CommunityErrorDetails({required this.error, required this.message, required this.onRetry});

  final Object error;
  final String message;
  final VoidCallback onRetry;
}

class CommunityStockCardDetails {
  const CommunityStockCardDetails({required this.code, required this.isMine, this.info, this.onTap});

  final String code;
  final bool isMine;
  final CommunityStockInfo? info;
  final VoidCallback? onTap;
}

class CommunityDeliveryNoticeDetails {
  const CommunityDeliveryNoticeDetails({
    required this.message,
    required this.isMine,
    required this.failed,
    required this.label,
    this.errorLabel,
    this.onRetry,
    this.onDiscard,
  });

  final ChatMessage message;
  final bool isMine;
  final bool failed;
  final String label;
  final String? errorLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onDiscard;
}

class CommunityReactionPickerDetails {
  const CommunityReactionPickerDetails({required this.choices, required this.onSelected, this.selected});

  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;
}

class CommunityReactionsDetails {
  const CommunityReactionsDetails({required this.reactions, this.isMine = false, this.onReact});

  final List<MessageReaction> reactions;
  final bool isMine;
  final ValueChanged<String>? onReact;
}

class CommunityReceiptDetails {
  const CommunityReceiptDetails({
    required this.receipt,
    required this.sendStatus,
    required this.color,
    required this.size,
    this.semanticLabel,
    this.readColor,
  });

  final ReceiptStatus? receipt;
  final MessageStatus sendStatus;
  final Color color;
  final double size;
  final String? semanticLabel;
  final Color? readColor;

  bool get read => sendStatus == MessageStatus.sent && receipt == ReceiptStatus.read;
}

class CommunityMessageAction {
  const CommunityMessageAction({required this.icon, required this.label, required this.onSelected});

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
}

class CommunityMessageActionsDetails {
  const CommunityMessageActionsDetails({
    required this.message,
    required this.actions,
    this.moderationActions = const [],
    this.moderationLabel,
    this.moderationNote,
    this.onReact,
  });

  final CommunityMessageDetails message;
  final List<CommunityMessageAction> actions;
  final List<CommunityMessageAction> moderationActions;
  final String? moderationLabel;
  final String? moderationNote;
  final ValueChanged<String>? onReact;
}

class CommunityJumpToLatestDetails {
  const CommunityJumpToLatestDetails({required this.unread, required this.label, required this.onPressed});

  final int unread;
  final String label;
  final VoidCallback onPressed;
}

class CommunityMessageInfoDetails {
  const CommunityMessageInfoDetails({
    required this.message,
    required this.isGroup,
    required this.loading,
    required this.timeLabel,
    this.info,
    this.error,
    this.onRetry,
    this.anchored = false,
  });

  final ChatMessage message;
  final bool anchored;
  final bool isGroup;
  final bool loading;
  final String Function(DateTime time) timeLabel;
  final MessageInfo? info;
  final Object? error;
  final VoidCallback? onRetry;
}

enum CommunityRoomNoticeKind { pinned, slowMode, dmRequestReceived, dmRequestLimit, dmRequestSent, dmRequestInfo }

class CommunityRoomNoticeDetails {
  const CommunityRoomNoticeDetails({
    required this.kind,
    required this.icon,
    required this.message,
    this.title,
    this.strong = false,
    this.pinned,
    this.actionLabel,
    this.onAction,
  });

  final CommunityRoomNoticeKind kind;
  final IconData icon;
  final String message;
  final String? title;
  final bool strong;
  final ChatMessage? pinned;
  final String? actionLabel;
  final VoidCallback? onAction;
}

enum CommunityRoomModerationKind { muted, moderator }

class CommunityRoomModerationDetails {
  const CommunityRoomModerationDetails({
    required this.kind,
    required this.icon,
    required this.message,
    this.mutedUntil,
  });

  final CommunityRoomModerationKind kind;
  final IconData icon;
  final String message;
  final DateTime? mutedUntil;
}

class CommunityRoomModerationDialogDetails {
  const CommunityRoomModerationDialogDetails({
    required this.action,
    required this.memberName,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.reasonLabel,
    required this.reasons,
    required this.reason,
    required this.noteController,
    required this.noteHint,
    required this.onReasonChanged,
    required this.onSubmit,
    required this.onCancel,
    this.durationLabel,
    this.durations = const [],
    this.duration,
    this.onDurationChanged,
  });

  final RoomModerationAction action;
  final String memberName;
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final String reasonLabel;
  final List<CommunitySettingsOption<ReportReason>> reasons;
  final ReportReason reason;
  final TextEditingController noteController;
  final String noteHint;
  final ValueChanged<ReportReason> onReasonChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String? durationLabel;
  final List<CommunitySettingsOption<Duration>> durations;
  final Duration? duration;
  final ValueChanged<Duration>? onDurationChanged;

  bool get destructive => action != RoomModerationAction.escalate;
}

class CommunityRoomAvatarDetails {
  const CommunityRoomAvatarDetails({required this.room, required this.radius, this.online = false});

  final ChatRoom room;
  final double radius;
  final bool online;
}

class CommunityNewGroupDetails {
  const CommunityNewGroupDetails({
    required this.nameController,
    required this.queryController,
    required this.results,
    required this.selected,
    required this.creating,
    required this.onNameChanged,
    required this.onQueryChanged,
    required this.onToggle,
    required this.onCancel,
    this.onCreate,
  });

  final TextEditingController nameController;
  final TextEditingController queryController;
  final List<UserSummary> results;
  final List<UserSummary> selected;
  final bool creating;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onQueryChanged;
  final void Function(UserSummary user, bool selected) onToggle;
  final VoidCallback onCancel;
  final VoidCallback? onCreate;

  bool get canCreate => onCreate != null;

  bool isSelected(UserSummary user) => selected.any((u) => u.id == user.id);
}

class CommunityShareTargetDetails {
  const CommunityShareTargetDetails({required this.room, required this.title, required this.sending, this.onShare});

  final ChatRoom room;
  final String title;
  final bool sending;
  final VoidCallback? onShare;
}

class CommunitySharedPostDetails {
  const CommunitySharedPostDetails({
    required this.postId,
    required this.loading,
    required this.available,
    this.post,
    this.color,
    this.onOpen,
  });

  final String postId;
  final bool loading;
  final bool available;
  final SharedPost? post;
  final Color? color;
  final VoidCallback? onOpen;
}

class CommunityStockCardPickerDetails {
  const CommunityStockCardPickerDetails({
    required this.controller,
    required this.codes,
    required this.max,
    required this.onAdd,
    required this.onRemove,
    required this.onSend,
    required this.onCancel,
    this.error,
  });

  final TextEditingController controller;
  final List<String> codes;
  final int max;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onSend;
  final VoidCallback onCancel;
  final String? error;
}

class CommunityRequestsEntryDetails {
  const CommunityRequestsEntryDetails({required this.count, required this.label, required this.onOpen});

  final int count;
  final String label;
  final VoidCallback onOpen;
}

class CommunityMessageRequestDetails {
  const CommunityMessageRequestDetails({
    required this.request,
    required this.preview,
    required this.timeLabel,
    required this.countLabel,
    required this.onOpen,
  });

  final MessageRequest request;
  final String preview;
  final String timeLabel;
  final String countLabel;
  final VoidCallback onOpen;
}

class CommunityRequestIntroDetails {
  const CommunityRequestIntroDetails({required this.request, required this.message, this.imageNotice});

  final MessageRequest request;
  final String message;
  final String? imageNotice;
}

class CommunityRequestActionsDetails {
  const CommunityRequestActionsDetails({
    required this.request,
    required this.busy,
    this.responding,
    this.onAccept,
    this.onDecline,
    this.onBlock,
  });

  final MessageRequest request;
  final bool busy;
  final MessageRequestAction? responding;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onBlock;
}

class CommunityVideoDetails {
  const CommunityVideoDetails({
    required this.attachment,
    required this.name,
    required this.durationLabel,
    required this.sizeLabel,
    required this.color,
    required this.playsInApp,
    required this.opening,
    required this.semanticLabel,
    this.thumbnail,
    this.onPlay,
    this.downloadLabel = '',
    this.downloading = false,
    this.onDownload,
  });

  final Attachment attachment;
  final String name;
  final String durationLabel;
  final String sizeLabel;
  final Color color;
  final bool playsInApp;
  final bool opening;
  final String semanticLabel;
  final Widget? thumbnail;
  final VoidCallback? onPlay;
  final String downloadLabel;
  final bool downloading;
  final VoidCallback? onDownload;

  Duration? get duration {
    final seconds = attachment.duration;
    return seconds == null ? null : Duration(milliseconds: (seconds * 1000).round());
  }
}
