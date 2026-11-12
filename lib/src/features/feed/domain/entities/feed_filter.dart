import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/feed_sort.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';

part 'feed_filter.freezed.dart';

abstract final class FeedFilterContent {
  static const media = 'media';
  static const poll = 'poll';
}

@freezed
abstract class FeedFilter with _$FeedFilter {
  const FeedFilter._();

  const factory FeedFilter({
    required String key,
    required String labelEn,
    required String labelId,
    @Default(CommunityFeedSort.latest) CommunityFeedSort sort,
    String? content,
    String? icon,
    @Default(0) int position,
  }) = _FeedFilter;

  String label(Locale locale) => locale.languageCode == 'id' ? labelId : labelEn;

  bool get knownContent => content == null || content == FeedFilterContent.media || content == FeedFilterContent.poll;

  bool matches(Post post) => switch (content) {
    null => true,
    FeedFilterContent.media => post.attachments.isNotEmpty,
    FeedFilterContent.poll => post.poll != null,
    _ => false,
  };
}

const builtInFeedFilters = [
  FeedFilter(key: 'latest', labelEn: 'Latest', labelId: 'Terbaru', icon: 'schedule'),
  FeedFilter(
    key: 'top',
    labelEn: 'Top',
    labelId: 'Teratas',
    sort: CommunityFeedSort.top,
    icon: 'trending_up',
    position: 1,
  ),
  FeedFilter(
    key: 'media',
    labelEn: 'Chart & Media',
    labelId: 'Grafik & Media',
    content: FeedFilterContent.media,
    icon: 'image',
    position: 2,
  ),
  FeedFilter(
    key: 'polls',
    labelEn: 'Polls',
    labelId: 'Polling',
    content: FeedFilterContent.poll,
    icon: 'poll',
    position: 3,
  ),
];
