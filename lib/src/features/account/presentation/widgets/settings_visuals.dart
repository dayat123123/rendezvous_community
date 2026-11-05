import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_builders.dart';
import 'package:rendezvous_community/src/features/account/presentation/builders/community_settings_details.dart';
import 'package:rendezvous_community/src/shared/presentation/l10n/l10n.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

Color communitySoftTone(CommunityStyle style, Color tone) =>
    Color.alphaBlend(tone.withValues(alpha: 0.12), style.surface);

class CommunityToneIcon extends StatelessWidget {
  const CommunityToneIcon({super.key, required this.icon, this.tone, this.size = 36});

  final IconData icon;
  final Color? tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final tone = this.tone ?? style.accent;
    final compact = size < 48;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: this.tone == null ? style.accentMuted : communitySoftTone(style, tone),
          shape: compact ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: compact ? BorderRadius.circular(size * 0.28) : null,
        ),
        child: Icon(icon, size: size * 0.5, color: tone),
      ),
    );
  }
}

class CommunitySettingsGroup extends StatelessWidget {
  const CommunitySettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final hairline = BorderSide(color: style.divider, width: style.borderWidth);
    return Material(
      color: style.surface,
      shape: Border(top: hairline, bottom: hairline),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: style.borderWidth,
                thickness: style.borderWidth,
                color: style.divider,
                indent: style.spacing.lg,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

ListTileThemeData communitySettingsTileTheme(CommunityStyle style) => ListTileThemeData(
  contentPadding: EdgeInsets.symmetric(horizontal: style.spacing.lg),
  minVerticalPadding: style.spacing.md,
  horizontalTitleGap: style.spacing.md,
  iconColor: style.textSecondary,
  titleTextStyle: style.typography.body.copyWith(fontWeight: FontWeight.w600, height: 1.35),
  subtitleTextStyle: style.typography.meta,
  leadingAndTrailingTextStyle: style.typography.meta,
);

InputDecoration communityFieldDecoration(CommunityStyle style, {String? hintText, String? labelText}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: style.radii.controlRadius,
    borderSide: BorderSide(color: color, width: style.borderWidth),
  );
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    hintStyle: style.typography.body.copyWith(color: style.textTertiary),
    filled: true,
    fillColor: style.surface,
    border: border(style.border),
    enabledBorder: border(style.border),
    focusedBorder: border(style.accent),
  );
}

ShapeBorder communityDialogShape(CommunityStyle style) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(style.radii.card + style.spacing.sm));

class CommunitySettingsLoading extends StatelessWidget {
  const CommunitySettingsLoading({super.key, required this.area, this.fallback});

  final CommunitySettingsArea area;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return buildSettingsPart(
      (b) => b.loading,
      context,
      CommunitySettingsLoadingDetails(area),
      fallback ??
          Padding(
            padding: EdgeInsets.symmetric(horizontal: style.spacing.lg, vertical: style.spacing.md),
            child: ClipRRect(
              borderRadius: style.radii.pillRadius,
              child: LinearProgressIndicator(minHeight: 3, color: style.accent, backgroundColor: style.pill),
            ),
          ),
    );
  }
}

class CommunitySettingsEmpty extends StatelessWidget {
  const CommunitySettingsEmpty({super.key, required this.area, required this.message});

  final CommunitySettingsArea area;
  final String message;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    return buildSettingsPart(
      (b) => b.empty,
      context,
      CommunitySettingsEmptyDetails(area: area, message: message),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: style.spacing.lg, vertical: style.spacing.md + style.spacing.xs),
        child: Text(message, style: style.typography.meta),
      ),
    );
  }
}

class CommunitySettingsError extends StatelessWidget {
  const CommunitySettingsError({
    super.key,
    required this.area,
    required this.error,
    required this.onRetry,
    this.fallback,
  });

  final CommunitySettingsArea area;
  final Object error;
  final VoidCallback onRetry;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.communityL10n;
    final style = CommunityStyle.of(context);
    final scheme = Theme.of(context).colorScheme;
    final details = CommunitySettingsErrorDetails(
      area: area,
      error: error,
      message: l10n.errorMessage(error),
      retryLabel: l10n.retry,
      onRetry: onRetry,
    );
    return buildSettingsPart(
      (b) => b.error,
      context,
      details,
      fallback ??
          ListTileTheme(
            data: communitySettingsTileTheme(style),
            child: ListTile(
              leading: CommunityToneIcon(icon: Icons.error_outline, tone: scheme.error),
              title: Text(details.message, style: style.typography.body),
              trailing: TextButton(
                style: TextButton.styleFrom(foregroundColor: style.accent, textStyle: style.typography.label),
                onPressed: onRetry,
                child: Text(details.retryLabel),
              ),
            ),
          ),
    );
  }
}
