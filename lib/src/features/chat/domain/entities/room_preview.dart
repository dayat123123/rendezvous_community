class RoomPreview {
  const RoomPreview({
    required this.roomId,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  final String roomId;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final String? lastMessageSenderId;
  final int unreadCount;
}

class RoomPreviewPage {
  const RoomPreviewPage(this.previews, {this.pollInterval});

  final List<RoomPreview> previews;
  final Duration? pollInterval;
}
