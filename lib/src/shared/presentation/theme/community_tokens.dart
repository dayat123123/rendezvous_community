import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class CommunitySpacing {
  const CommunitySpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  EdgeInsets get card => EdgeInsets.fromLTRB(lg, md, lg, md);

  EdgeInsets get page => EdgeInsets.symmetric(horizontal: lg);

  CommunitySpacing copyWith({double? xxs, double? xs, double? sm, double? md, double? lg, double? xl, double? xxl}) =>
      CommunitySpacing(
        xxs: xxs ?? this.xxs,
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
      );

  CommunitySpacing lerp(CommunitySpacing other, double t) => CommunitySpacing(
    xxs: lerpDouble(xxs, other.xxs, t)!,
    xs: lerpDouble(xs, other.xs, t)!,
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
    xxl: lerpDouble(xxl, other.xxl, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is CommunitySpacing &&
      other.xxs == xxs &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl &&
      other.xxl == xxl;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl);
}

@immutable
class CommunityRadii {
  const CommunityRadii({this.badge = 4, this.image = 6, this.card = 8, this.control = 8, this.pill = 999});

  final double badge;
  final double image;
  final double card;
  final double control;
  final double pill;

  BorderRadius get badgeRadius => BorderRadius.circular(badge);
  BorderRadius get imageRadius => BorderRadius.circular(image);
  BorderRadius get cardRadius => BorderRadius.circular(card);
  BorderRadius get controlRadius => BorderRadius.circular(control);
  BorderRadius get pillRadius => BorderRadius.circular(pill);

  CommunityRadii copyWith({double? badge, double? image, double? card, double? control, double? pill}) =>
      CommunityRadii(
        badge: badge ?? this.badge,
        image: image ?? this.image,
        card: card ?? this.card,
        control: control ?? this.control,
        pill: pill ?? this.pill,
      );

  CommunityRadii lerp(CommunityRadii other, double t) => CommunityRadii(
    badge: lerpDouble(badge, other.badge, t)!,
    image: lerpDouble(image, other.image, t)!,
    card: lerpDouble(card, other.card, t)!,
    control: lerpDouble(control, other.control, t)!,
    pill: lerpDouble(pill, other.pill, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is CommunityRadii &&
      other.badge == badge &&
      other.image == image &&
      other.card == card &&
      other.control == control &&
      other.pill == pill;

  @override
  int get hashCode => Object.hash(badge, image, card, control, pill);
}

@immutable
class CommunityAvatarSizes {
  const CommunityAvatarSizes({
    this.small = 28,
    this.medium = 36,
    this.large = 64,
    this.post = 40,
    this.comment = 32,
    this.reply = 24,
    this.profile = 80,
  });

  final double small;
  final double medium;
  final double large;
  final double post;
  final double comment;
  final double reply;
  final double profile;

  CommunityAvatarSizes copyWith({
    double? small,
    double? medium,
    double? large,
    double? post,
    double? comment,
    double? reply,
    double? profile,
  }) => CommunityAvatarSizes(
    small: small ?? this.small,
    medium: medium ?? this.medium,
    large: large ?? this.large,
    post: post ?? this.post,
    comment: comment ?? this.comment,
    reply: reply ?? this.reply,
    profile: profile ?? this.profile,
  );

  CommunityAvatarSizes lerp(CommunityAvatarSizes other, double t) => CommunityAvatarSizes(
    small: lerpDouble(small, other.small, t)!,
    medium: lerpDouble(medium, other.medium, t)!,
    large: lerpDouble(large, other.large, t)!,
    post: lerpDouble(post, other.post, t)!,
    comment: lerpDouble(comment, other.comment, t)!,
    reply: lerpDouble(reply, other.reply, t)!,
    profile: lerpDouble(profile, other.profile, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is CommunityAvatarSizes &&
      other.small == small &&
      other.medium == medium &&
      other.large == large &&
      other.post == post &&
      other.comment == comment &&
      other.reply == reply &&
      other.profile == profile;

  @override
  int get hashCode => Object.hash(small, medium, large, post, comment, reply, profile);
}

@immutable
class CommunityTypography {
  const CommunityTypography({
    required this.title,
    required this.body,
    required this.author,
    required this.meta,
    required this.label,
    required this.sectionTitle,
    required this.badge,
  });

  factory CommunityTypography.fallback(TextTheme text, {required Color primary, required Color secondary}) {
    TextStyle base(TextStyle? style) => (style ?? const TextStyle()).copyWith(color: primary, letterSpacing: 0);
    return CommunityTypography(
      title: base(text.titleMedium).copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.35),
      body: base(text.bodyLarge).copyWith(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.1),
      author: base(text.titleSmall).copyWith(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
      meta: base(text.bodySmall).copyWith(fontSize: 13, fontWeight: FontWeight.w400, height: 1.35, color: secondary),
      label: base(
        text.labelLarge,
      ).copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0.1, color: secondary),
      sectionTitle: base(text.titleSmall).copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
      badge: base(text.labelSmall).copyWith(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
    );
  }

  final TextStyle title;
  final TextStyle body;
  final TextStyle author;
  final TextStyle meta;
  final TextStyle label;
  final TextStyle sectionTitle;
  final TextStyle badge;

  CommunityTypography copyWith({
    TextStyle? title,
    TextStyle? body,
    TextStyle? author,
    TextStyle? meta,
    TextStyle? label,
    TextStyle? sectionTitle,
    TextStyle? badge,
  }) => CommunityTypography(
    title: title ?? this.title,
    body: body ?? this.body,
    author: author ?? this.author,
    meta: meta ?? this.meta,
    label: label ?? this.label,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    badge: badge ?? this.badge,
  );

  CommunityTypography lerp(CommunityTypography other, double t) => CommunityTypography(
    title: TextStyle.lerp(title, other.title, t)!,
    body: TextStyle.lerp(body, other.body, t)!,
    author: TextStyle.lerp(author, other.author, t)!,
    meta: TextStyle.lerp(meta, other.meta, t)!,
    label: TextStyle.lerp(label, other.label, t)!,
    sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
    badge: TextStyle.lerp(badge, other.badge, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is CommunityTypography &&
      other.title == title &&
      other.body == body &&
      other.author == author &&
      other.meta == meta &&
      other.label == label &&
      other.sectionTitle == sectionTitle &&
      other.badge == badge;

  @override
  int get hashCode => Object.hash(title, body, author, meta, label, sectionTitle, badge);
}
