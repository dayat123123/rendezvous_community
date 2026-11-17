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

class CommentSettings {
  const CommentSettings({
    this.audience = CommentAudience.everyone,
    this.allOff = false,
    this.allOffAvailable = true,
  });

  final CommentAudience audience;
  final bool allOff;
  final bool allOffAvailable;

  CommentSettings copyWith({CommentAudience? audience, bool? allOff, bool? allOffAvailable}) => CommentSettings(
    audience: audience ?? this.audience,
    allOff: allOff ?? this.allOff,
    allOffAvailable: allOffAvailable ?? this.allOffAvailable,
  );

  @override
  bool operator ==(Object other) =>
      other is CommentSettings &&
      other.audience == audience &&
      other.allOff == allOff &&
      other.allOffAvailable == allOffAvailable;

  @override
  int get hashCode => Object.hash(audience, allOff, allOffAvailable);

  @override
  String toString() =>
      'CommentSettings(audience: ${audience.wire}, allOff: $allOff, allOffAvailable: $allOffAvailable)';
}
