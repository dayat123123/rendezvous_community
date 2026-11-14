import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_icons.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_tokens.dart';

@immutable
class CommunityStyle extends ThemeExtension<CommunityStyle> {
  const CommunityStyle({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentMuted,
    required this.pill,
    required this.onPill,
    required this.chip,
    required this.onChip,
    required this.skeleton,
    required this.typography,
    this.spacing = const CommunitySpacing(),
    this.radii = const CommunityRadii(),
    this.avatarSizes = const CommunityAvatarSizes(),
    this.borderWidth = 1,
    this.minTouchTarget = 48,
    this.danger = const Color(0xFFD92D20),
    this.menuItemHeight = 36,
    this.menuIconSize = 17,
    this.icons = const CommunityIcons(),
  });

  factory CommunityStyle.fallback(ThemeData theme) {
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    Color tint(Color base, double alpha) => Color.alphaBlend(scheme.onSurface.withValues(alpha: alpha), base);
    final surface = theme.scaffoldBackgroundColor;
    final background = _distinct(
      dark ? scheme.surfaceContainerLowest : scheme.surfaceContainerHigh,
      surface,
      tint(surface, dark ? 0.05 : 0.06),
    );
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurfaceVariant;
    final pill = tint(surface, dark ? 0.08 : 0.04);
    return CommunityStyle(
      background: background,
      surface: surface,
      border: _distinct(scheme.outlineVariant, surface, tint(surface, 0.12)),
      divider: _distinct(scheme.outlineVariant, surface, tint(surface, 0.08)).withValues(alpha: 0.6),
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: scheme.outline,
      accent: scheme.primary,
      onAccent: scheme.onPrimary,
      accentMuted: Color.alphaBlend(scheme.primary.withValues(alpha: dark ? 0.18 : 0.10), surface),
      pill: pill,
      onPill: textSecondary,
      chip: pill,
      onChip: textPrimary,
      skeleton: tint(surface, dark ? 0.10 : 0.07),
      typography: CommunityTypography.fallback(theme.textTheme, primary: textPrimary, secondary: textSecondary),
      danger: scheme.error,
    );
  }

  static final _fallbacks = Expando<CommunityStyle>();

  static CommunityStyle of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CommunityStyle>() ?? (_fallbacks[theme] ??= CommunityStyle.fallback(theme));
  }

  static Color _distinct(Color candidate, Color other, Color replacement) =>
      candidate == other ? replacement : candidate;

  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color onAccent;
  final Color accentMuted;
  final Color pill;
  final Color onPill;
  final Color chip;
  final Color onChip;
  final Color skeleton;
  final CommunityTypography typography;
  final CommunitySpacing spacing;
  final CommunityRadii radii;
  final CommunityAvatarSizes avatarSizes;
  final double borderWidth;
  final double minTouchTarget;
  final Color danger;
  final double menuItemHeight;
  final double menuIconSize;
  final CommunityIcons icons;

  double get sectionGap => spacing.sm;

  BorderSide get borderSide => BorderSide(color: border, width: borderWidth);

  BoxDecoration cardDecoration({bool selected = false}) => BoxDecoration(
    color: surface,
    borderRadius: radii.cardRadius,
    border: Border.fromBorderSide(selected ? BorderSide(color: accent, width: borderWidth) : borderSide),
  );

  ShapeBorder cardShape({bool selected = false}) => RoundedRectangleBorder(
    borderRadius: radii.cardRadius,
    side: selected ? BorderSide(color: accent, width: borderWidth) : borderSide,
  );

  ButtonStyle primaryButtonStyle() => FilledButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: onAccent,
    textStyle: typography.label.copyWith(fontSize: 14),
    shape: const StadiumBorder(),
    minimumSize: const Size(64, 40),
    padding: EdgeInsets.symmetric(horizontal: spacing.lg),
    tapTargetSize: MaterialTapTargetSize.padded,
  );

  ButtonStyle secondaryButtonStyle() => OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    textStyle: typography.label.copyWith(fontSize: 14),
    side: borderSide,
    shape: const StadiumBorder(),
    minimumSize: const Size(64, 40),
    padding: EdgeInsets.symmetric(horizontal: spacing.lg),
    tapTargetSize: MaterialTapTargetSize.padded,
  );

  @override
  CommunityStyle copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentMuted,
    Color? pill,
    Color? onPill,
    Color? chip,
    Color? onChip,
    Color? skeleton,
    CommunityTypography? typography,
    CommunitySpacing? spacing,
    CommunityRadii? radii,
    CommunityAvatarSizes? avatarSizes,
    double? borderWidth,
    double? minTouchTarget,
    Color? danger,
    double? menuItemHeight,
    double? menuIconSize,
    CommunityIcons? icons,
  }) => CommunityStyle(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentMuted: accentMuted ?? this.accentMuted,
    pill: pill ?? this.pill,
    onPill: onPill ?? this.onPill,
    chip: chip ?? this.chip,
    onChip: onChip ?? this.onChip,
    skeleton: skeleton ?? this.skeleton,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    radii: radii ?? this.radii,
    avatarSizes: avatarSizes ?? this.avatarSizes,
    borderWidth: borderWidth ?? this.borderWidth,
    minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    danger: danger ?? this.danger,
    menuItemHeight: menuItemHeight ?? this.menuItemHeight,
    menuIconSize: menuIconSize ?? this.menuIconSize,
    icons: icons ?? this.icons,
  );

  @override
  CommunityStyle lerp(covariant CommunityStyle? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return CommunityStyle(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      border: c(border, other.border),
      divider: c(divider, other.divider),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      accentMuted: c(accentMuted, other.accentMuted),
      pill: c(pill, other.pill),
      onPill: c(onPill, other.onPill),
      chip: c(chip, other.chip),
      onChip: c(onChip, other.onChip),
      skeleton: c(skeleton, other.skeleton),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      radii: radii.lerp(other.radii, t),
      avatarSizes: avatarSizes.lerp(other.avatarSizes, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t)!,
      danger: c(danger, other.danger),
      menuItemHeight: lerpDouble(menuItemHeight, other.menuItemHeight, t)!,
      menuIconSize: lerpDouble(menuIconSize, other.menuIconSize, t)!,
      icons: icons.lerp(other.icons, t),
    );
  }
}
