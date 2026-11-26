import 'package:material_ui/material_ui.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';

class CommunityFileTile extends StatelessWidget {
  const CommunityFileTile({
    super.key,
    required this.name,
    required this.meta,
    required this.semanticLabel,
    this.icon = Icons.description_outlined,
    this.preview,
    this.opening = false,
    this.onOpen,
  });

  final String name;
  final String meta;
  final String semanticLabel;
  final IconData icon;
  final Widget? preview;
  final bool opening;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final preview = this.preview;
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        borderRadius: style.radii.controlRadius,
        child: Container(
          constraints: BoxConstraints(minHeight: style.minTouchTarget),
          padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.sm),
          decoration: BoxDecoration(
            borderRadius: style.radii.controlRadius,
            border: Border.all(color: style.divider, width: style.borderWidth),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: preview != null
                    ? ClipRRect(borderRadius: style.radii.controlRadius, child: preview)
                    : DecoratedBox(
                        decoration: BoxDecoration(color: style.pill, borderRadius: style.radii.controlRadius),
                        child: Icon(icon, color: style.accent),
                      ),
              ),
              SizedBox(width: spacing.sm + spacing.xxs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: style.typography.author.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(meta, style: style.typography.meta),
                  ],
                ),
              ),
              SizedBox(width: spacing.sm),
              opening
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: style.accent),
                    )
                  : Icon(Icons.open_in_new, size: 18, color: style.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
