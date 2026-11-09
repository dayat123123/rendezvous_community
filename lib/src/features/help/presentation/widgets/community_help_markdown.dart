import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_community/src/features/help/domain/services/help_markdown.dart';
import 'package:rendezvous_community/src/shared/presentation/theme/community_style.dart';
import 'package:rendezvous_community/src/shared/presentation/widgets/link_opener.dart';

typedef CommunityHelpLinkHandler = void Function(BuildContext context, Uri uri);

typedef CommunityHelpImageBuilder = Widget Function(BuildContext context, Uri uri, String alt);

class CommunityHelpMarkdown extends StatefulWidget {
  const CommunityHelpMarkdown(this.data, {super.key, this.style, this.onLinkTap, this.imageBuilder});

  final String data;
  final TextStyle? style;
  final CommunityHelpLinkHandler? onLinkTap;
  final CommunityHelpImageBuilder? imageBuilder;

  @override
  State<CommunityHelpMarkdown> createState() => _CommunityHelpMarkdownState();
}

class _CommunityHelpMarkdownState extends State<CommunityHelpMarkdown> {
  final _recognizers = <TapGestureRecognizer>[];
  late List<HelpMarkdownBlock> _blocks = parseHelpMarkdown(widget.data);

  @override
  void didUpdateWidget(CommunityHelpMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _blocks = parseHelpMarkdown(widget.data);
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  void _open(Uri uri) {
    final handler = widget.onLinkTap;
    if (handler != null) {
      handler(context, uri);
    } else {
      openCommunityLink(context, uri);
    }
  }

  TextSpan _span(List<HelpInline> inlines, TextStyle base, CommunityStyle style) => TextSpan(
    style: base,
    children: [
      for (final inline in inlines)
        TextSpan(
          text: inline.text,
          style: TextStyle(
            fontWeight: inline.bold ? FontWeight.w700 : null,
            fontStyle: inline.italic ? FontStyle.italic : null,
            color: inline.link != null ? style.accent : null,
            decoration: inline.link != null ? TextDecoration.underline : null,
            decorationColor: inline.link != null ? style.accent : null,
          ),
          recognizer: switch (inline.link) {
            final Uri uri => _recognizer(() => _open(uri)),
            null => null,
          },
          semanticsLabel: inline.link == null ? null : inline.text,
        ),
    ],
  );

  TapGestureRecognizer _recognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer()..onTap = onTap;
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final style = CommunityStyle.of(context);
    final spacing = style.spacing;
    final base = widget.style ?? style.typography.body.copyWith(height: 1.55);
    final children = <Widget>[];
    for (final block in _blocks) {
      if (children.isNotEmpty) children.add(SizedBox(height: spacing.md));
      children.add(switch (block) {
        HelpParagraphBlock(:final inlines) => Text.rich(_span(inlines, base, style)),
        HelpImageBlock(:final uri, :final alt) =>
          widget.imageBuilder?.call(context, uri, alt) ?? HelpMarkdownImage(uri: uri, alt: alt),
        HelpHeadingBlock(:final level, :final inlines) => Semantics(
          header: true,
          child: Text.rich(
            _span(
              inlines,
              base.copyWith(fontWeight: FontWeight.w700, fontSize: (base.fontSize ?? 15) + (level <= 2 ? 3 : 1)),
              style,
            ),
          ),
        ),
        HelpListBlock(:final ordered, :final start, :final items) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : spacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ordered ? 28 : 20,
                      child: Text(
                        ordered ? '${start + i}.' : '•',
                        style: base.copyWith(color: style.textSecondary),
                        textAlign: ordered ? TextAlign.end : TextAlign.center,
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(child: Text.rich(_span(items[i], base, style))),
                  ],
                ),
              ),
          ],
        ),
      });
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: children);
  }
}

class HelpMarkdownImage extends StatelessWidget {
  const HelpMarkdownImage({super.key, required this.uri, required this.alt, this.maxHeight = 360});

  final Uri uri;
  final String alt;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final style = CommunityStyle.of(context);
    Widget placeholder({required bool broken}) => Semantics(
      image: true,
      label: alt.isEmpty ? null : alt,
      child: Container(
        height: broken ? 96 : 160,
        color: style.pill,
        alignment: Alignment.center,
        child: broken ? Icon(Icons.broken_image_outlined, color: style.textTertiary) : null,
      ),
    );
    return ClipRRect(
      borderRadius: style.radii.cardRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Image.network(
          uri.toString(),
          fit: BoxFit.contain,
          semanticLabel: alt.isEmpty ? null : alt,
          excludeFromSemantics: alt.isEmpty,
          loadingBuilder: (context, child, progress) => progress == null ? child : placeholder(broken: false),
          errorBuilder: (context, error, stackTrace) => placeholder(broken: true),
        ),
      ),
    );
  }
}
