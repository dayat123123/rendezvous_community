import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class CommunityIcons {
  const CommunityIcons({
    this.reply = Icons.reply_outlined,
    this.copy = Icons.copy_outlined,
    this.edit = Icons.edit_outlined,
    this.info = Icons.info_outlined,
    this.delete = Icons.delete_outlined,
    this.deleteGroup = Icons.delete_forever_outlined,
    this.report = Icons.flag_outlined,
    this.hide = Icons.visibility_off_outlined,
    this.mute = Icons.volume_off_outlined,
    this.unmute = Icons.volume_up_outlined,
    this.escalate = Icons.outlined_flag,
    this.block = Icons.block,
    this.unblock = Icons.lock_open_outlined,
    this.share = Icons.send_outlined,
    this.bookmark = Icons.bookmark_add_outlined,
    this.unbookmark = Icons.bookmark_remove_outlined,
    this.pin = Icons.push_pin_outlined,
    this.unpin = Icons.push_pin,
    this.leave = Icons.logout,
    this.more = Icons.more_horiz,
    this.moreVertical = Icons.more_vert,
    this.download = Icons.download_outlined,
    this.markRead = Icons.done_all,
    this.react = Icons.add_reaction_outlined,
    this.changePhoto = Icons.photo_camera_outlined,
    this.complaint = Icons.gavel_outlined,
    this.reportFake = Icons.gpp_maybe_outlined,
    this.newTicket = Icons.add_comment_outlined,
    this.tickets = Icons.receipt_long_outlined,
    this.endChat = Icons.logout,
    this.check = Icons.check,
  });

  final IconData reply;
  final IconData copy;
  final IconData edit;
  final IconData info;
  final IconData delete;
  final IconData deleteGroup;
  final IconData report;
  final IconData hide;
  final IconData mute;
  final IconData unmute;
  final IconData escalate;
  final IconData block;
  final IconData unblock;
  final IconData share;
  final IconData bookmark;
  final IconData unbookmark;
  final IconData pin;
  final IconData unpin;
  final IconData leave;
  final IconData more;
  final IconData moreVertical;
  final IconData download;
  final IconData markRead;
  final IconData react;
  final IconData changePhoto;
  final IconData complaint;
  final IconData reportFake;
  final IconData newTicket;
  final IconData tickets;
  final IconData endChat;
  final IconData check;

  List<IconData> get _values => [
    reply,
    copy,
    edit,
    info,
    delete,
    deleteGroup,
    report,
    hide,
    mute,
    unmute,
    escalate,
    block,
    unblock,
    share,
    bookmark,
    unbookmark,
    pin,
    unpin,
    leave,
    more,
    moreVertical,
    download,
    markRead,
    react,
    changePhoto,
    complaint,
    reportFake,
    newTicket,
    tickets,
    endChat,
    check,
  ];

  CommunityIcons copyWith({
    IconData? reply,
    IconData? copy,
    IconData? edit,
    IconData? info,
    IconData? delete,
    IconData? deleteGroup,
    IconData? report,
    IconData? hide,
    IconData? mute,
    IconData? unmute,
    IconData? escalate,
    IconData? block,
    IconData? unblock,
    IconData? share,
    IconData? bookmark,
    IconData? unbookmark,
    IconData? pin,
    IconData? unpin,
    IconData? leave,
    IconData? more,
    IconData? moreVertical,
    IconData? download,
    IconData? markRead,
    IconData? react,
    IconData? changePhoto,
    IconData? complaint,
    IconData? reportFake,
    IconData? newTicket,
    IconData? tickets,
    IconData? endChat,
    IconData? check,
  }) => CommunityIcons(
    reply: reply ?? this.reply,
    copy: copy ?? this.copy,
    edit: edit ?? this.edit,
    info: info ?? this.info,
    delete: delete ?? this.delete,
    deleteGroup: deleteGroup ?? this.deleteGroup,
    report: report ?? this.report,
    hide: hide ?? this.hide,
    mute: mute ?? this.mute,
    unmute: unmute ?? this.unmute,
    escalate: escalate ?? this.escalate,
    block: block ?? this.block,
    unblock: unblock ?? this.unblock,
    share: share ?? this.share,
    bookmark: bookmark ?? this.bookmark,
    unbookmark: unbookmark ?? this.unbookmark,
    pin: pin ?? this.pin,
    unpin: unpin ?? this.unpin,
    leave: leave ?? this.leave,
    more: more ?? this.more,
    moreVertical: moreVertical ?? this.moreVertical,
    download: download ?? this.download,
    markRead: markRead ?? this.markRead,
    react: react ?? this.react,
    changePhoto: changePhoto ?? this.changePhoto,
    complaint: complaint ?? this.complaint,
    reportFake: reportFake ?? this.reportFake,
    newTicket: newTicket ?? this.newTicket,
    tickets: tickets ?? this.tickets,
    endChat: endChat ?? this.endChat,
    check: check ?? this.check,
  );

  CommunityIcons lerp(CommunityIcons other, double t) => t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) => other is CommunityIcons && listEquals(other._values, _values);

  @override
  int get hashCode => Object.hashAll(_values);
}
