import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rendezvous_community/rendezvous_community.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

final _themes = <String, ThemeData>{
  for (final brightness in Brightness.values) ...{
    'baseline ${brightness.name}': ThemeData(brightness: brightness),
    'olt blue ${brightness.name}': ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FFF), brightness: brightness),
    ),
    'green ${brightness.name}': ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B8A3A), brightness: brightness),
    ),
  },
  'legacy light': ThemeData(colorScheme: const ColorScheme.light()),
  'legacy dark': ThemeData(colorScheme: const ColorScheme.dark()),
};

void main() {
  group('CommunityStyle.fallback', () {
    for (final MapEntry(key: name, value: theme) in _themes.entries) {
      test('$name keeps text readable (WCAG AA)', () {
        final style = CommunityStyle.fallback(theme);
        for (final base in [style.surface, style.background]) {
          expect(_contrast(style.textPrimary, base), greaterThanOrEqualTo(4.5));
          expect(_contrast(style.textSecondary, base), greaterThanOrEqualTo(4.5));
          expect(_contrast(style.textTertiary, base), greaterThanOrEqualTo(3));
        }
        expect(_contrast(style.onPill, style.pill), greaterThanOrEqualTo(4.5));
        expect(_contrast(style.onChip, style.chip), greaterThanOrEqualTo(4.5));
        expect(_contrast(style.accent, style.accentMuted), greaterThanOrEqualTo(3));
        expect(_contrast(style.onAccent, style.accent), greaterThanOrEqualTo(4.5));
      });

      test('$name separates page, card and border', () {
        final style = CommunityStyle.fallback(theme);
        expect(style.background, isNot(style.surface));
        expect(style.border, isNot(style.surface));
        expect(style.divider, isNot(style.surface));
        expect(style.accent, theme.colorScheme.primary);
      });
    }

    test('uses the editorial defaults for spacing, radius, avatar and type', () {
      final style = CommunityStyle.fallback(ThemeData());
      expect(style.spacing, const CommunitySpacing());
      expect(
        [style.spacing.xs, style.spacing.sm, style.spacing.md, style.spacing.lg, style.spacing.xl],
        [4, 8, 12, 16, 24],
      );
      expect(style.radii.card, 8);
      expect(style.avatarSizes.medium, 36);
      expect(style.borderWidth, 1);
      expect(style.minTouchTarget, 48);
      expect(style.typography.body.fontSize, 15);
      expect(style.typography.body.height, 1.5);
      expect(style.typography.title.fontWeight, FontWeight.w700);
      expect(style.typography.meta.color, style.textSecondary);
    });

    test('keeps the host font family', () {
      final theme = ThemeData(fontFamily: 'HostSans');
      expect(CommunityStyle.fallback(theme).typography.body.fontFamily, 'HostSans');
    });
  });

  group('CommunityStyle.of', () {
    testWidgets('falls back without configuration and caches per theme', (tester) async {
      late CommunityStyle first;
      late CommunityStyle second;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              first = CommunityStyle.of(context);
              second = CommunityStyle.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(identical(first, second), isTrue);
      expect(first.surface, CommunityStyle.fallback(Theme.of(tester.element(find.byType(SizedBox)))).surface);
    });

    testWidgets('prefers the host extension', (tester) async {
      final custom = CommunityStyle.fallback(ThemeData()).copyWith(surface: const Color(0xFF123456));
      late CommunityStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [custom]),
          home: Builder(
            builder: (context) {
              resolved = CommunityStyle.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolved.surface, const Color(0xFF123456));
    });

    testWidgets('CommunityTheme.of still works without configuration', (tester) async {
      late CommunityTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme = CommunityTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(theme.link, Theme.of(tester.element(find.byType(SizedBox))).colorScheme.primary);
    });
  });

  group('copyWith and lerp', () {
    test('copyWith replaces only the given tokens', () {
      final base = CommunityStyle.fallback(ThemeData());
      final changed = base.copyWith(
        radii: base.radii.copyWith(card: 12),
        spacing: base.spacing.copyWith(lg: 20),
        avatarSizes: base.avatarSizes.copyWith(medium: 40),
        typography: base.typography.copyWith(body: base.typography.body.copyWith(fontSize: 16)),
      );
      expect(changed.radii.card, 12);
      expect(changed.radii.pill, base.radii.pill);
      expect(changed.spacing.lg, 20);
      expect(changed.spacing.sm, base.spacing.sm);
      expect(changed.avatarSizes.medium, 40);
      expect(changed.typography.body.fontSize, 16);
      expect(changed.surface, base.surface);
    });

    test('lerp interpolates colors and sizes', () {
      final light = CommunityStyle.fallback(ThemeData());
      final dark = CommunityStyle.fallback(ThemeData(brightness: Brightness.dark));
      final wide = dark.copyWith(radii: const CommunityRadii(card: 16), spacing: const CommunitySpacing(lg: 32));
      final mid = light.lerp(wide, 0.5);
      expect(mid.surface, Color.lerp(light.surface, wide.surface, 0.5));
      expect(mid.radii.card, 12);
      expect(mid.spacing.lg, 24);
      expect(light.lerp(null, 0.5), same(light));
      expect(light.lerp(wide, 1).textPrimary, wide.textPrimary);
    });

    test('button styles follow the tokens', () {
      final style = CommunityStyle.fallback(ThemeData());
      expect(style.primaryButtonStyle().backgroundColor?.resolve({}), style.accent);
      expect(style.secondaryButtonStyle().side?.resolve({}), style.borderSide);
      expect(style.cardDecoration().border, Border.fromBorderSide(style.borderSide));
    });
  });
}
