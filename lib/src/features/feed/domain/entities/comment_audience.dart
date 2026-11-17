enum CommentAudience {
  everyone('everyone'),
  following('following'),
  followers('followers'),
  followingAndFollowers('following_and_followers'),
  off('off');

  const CommentAudience(this.wire);

  final String wire;

  static const accountOptions = [everyone, following, followers, followingAndFollowers];

  static const postOptions = [everyone, following, followers, followingAndFollowers, off];

  static CommentAudience? fromWire(Object? value) {
    for (final audience in values) {
      if (audience.wire == value) return audience;
    }
    return null;
  }
}
