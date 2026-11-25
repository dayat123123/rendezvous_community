import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/core/paging/paged.dart';
import 'package:rendezvous_community/src/features/feed/domain/entities/post.dart';
import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

part 'post_reaction.freezed.dart';

const postReactionsUnavailableCode = 'post_reactions_unavailable';

String? normalizePostReaction(String? emoji) {
  final value = emoji?.trim() ?? '';
  if (value.isEmpty) return null;
  return value == 'like' ? postLikeReaction : value;
}

List<PostReactionCount> sortPostReactions(
  Iterable<PostReactionCount> reactions, {
  List<String> order = defaultPostReactions,
}) {
  int rank(String emoji) {
    final index = order.indexOf(emoji);
    return index < 0 ? order.length : index;
  }

  final list = [
    for (final r in reactions)
      if (r.count > 0) r,
  ];
  final position = {for (final (i, r) in list.indexed) r.emoji: i};
  list.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    if (byCount != 0) return byCount;
    final byOrder = rank(a.emoji).compareTo(rank(b.emoji));
    if (byOrder != 0) return byOrder;
    return position[a.emoji]!.compareTo(position[b.emoji]!);
  });
  return list;
}

Post applyPostReaction(Post post, String? emoji, {List<String> order = defaultPostReactions}) {
  final next = normalizePostReaction(emoji);
  final previous = post.effectiveReaction;
  if (next == previous) return post;
  final counts = <String, int>{for (final r in post.effectiveReactionSummary) r.emoji: r.count};
  if (previous != null) counts[previous] = (counts[previous] ?? 0) - 1;
  if (next != null) counts[next] = (counts[next] ?? 0) + 1;
  final delta = switch ((previous, next)) {
    (null, _?) => 1,
    (_?, null) => -1,
    _ => 0,
  };
  final likeCount = post.likeCount + delta;
  return post.copyWith(
    myReaction: next,
    likedByMe: next != null,
    likeCount: likeCount < 0 ? 0 : likeCount,
    reactionSummary: sortPostReactions([
      for (final MapEntry(:key, :value) in counts.entries) PostReactionCount(emoji: key, count: value),
    ], order: order),
  );
}

@freezed
abstract class PostReactor with _$PostReactor {
  const factory PostReactor({
    required UserSummary user,
    required String emoji,
    DateTime? reactedAt,
    @Default(false) bool isMe,
    @Default(false) bool isFollowing,
    String? cursor,
  }) = _PostReactor;
}

class PostReactorsPage extends Paged<PostReactor> {
  const PostReactorsPage(super.items, {super.nextCursor});
}
