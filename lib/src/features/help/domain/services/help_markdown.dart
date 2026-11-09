class HelpInline {
  const HelpInline(this.text, {this.bold = false, this.italic = false, this.link});

  final String text;
  final bool bold;
  final bool italic;
  final Uri? link;

  @override
  bool operator ==(Object other) =>
      other is HelpInline && other.text == text && other.bold == bold && other.italic == italic && other.link == link;

  @override
  int get hashCode => Object.hash(text, bold, italic, link);

  @override
  String toString() => 'HelpInline($text, bold: $bold, italic: $italic, link: $link)';
}

sealed class HelpMarkdownBlock {
  const HelpMarkdownBlock();
}

final class HelpParagraphBlock extends HelpMarkdownBlock {
  const HelpParagraphBlock(this.inlines);

  final List<HelpInline> inlines;
}

final class HelpHeadingBlock extends HelpMarkdownBlock {
  const HelpHeadingBlock(this.level, this.inlines);

  final int level;
  final List<HelpInline> inlines;
}

final class HelpListBlock extends HelpMarkdownBlock {
  const HelpListBlock({required this.ordered, required this.items, this.start = 1});

  final bool ordered;
  final int start;
  final List<List<HelpInline>> items;
}

final class HelpImageBlock extends HelpMarkdownBlock {
  const HelpImageBlock({required this.uri, required this.alt});

  final Uri uri;
  final String alt;
}

final _image = RegExp(r'^\s{0,3}!\[([^\]]*)\]\(\s*(\S+?)\s*\)\s*$');
final _imagePath = RegExp(
  r'^/storage/v1/object/public/faq-images/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\.(jpg|png|webp)$',
);
final _bullet = RegExp(r'^\s{0,3}[-*+]\s+(.+)$');
final _number = RegExp(r'^\s{0,3}(\d{1,3})[.)]\s+(.+)$');
final _heading = RegExp(r'^\s{0,3}(#{1,6})\s+(.+?)\s*#*$');
final _leadingSpace = RegExp(r'^\s');
const _escapable = {'\\', '*', '_', '[', ']', '(', ')', '#', '-', '+', '.', '!', '`'};

Uri? helpLinkUri(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
  return uri;
}

Uri? helpImageUri(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) return null;
  if (uri.host.isEmpty || uri.userInfo.isNotEmpty || uri.hasQuery || uri.hasFragment) return null;
  return _imagePath.hasMatch(uri.path) ? uri : null;
}

List<HelpMarkdownBlock> parseHelpMarkdown(String source) {
  final blocks = <HelpMarkdownBlock>[];
  final paragraph = <String>[];
  List<String>? items;
  var ordered = false;
  var start = 1;

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(HelpParagraphBlock(parseHelpInlines(paragraph.join('\n'))));
    paragraph.clear();
  }

  void flushList() {
    final current = items;
    if (current == null) return;
    blocks.add(
      HelpListBlock(ordered: ordered, start: start, items: [for (final item in current) parseHelpInlines(item)]),
    );
    items = null;
  }

  for (final raw in source.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      flushParagraph();
      flushList();
      continue;
    }
    final image = _image.firstMatch(line);
    if (image != null) {
      flushParagraph();
      flushList();
      final alt = image.group(1)!.trim();
      final uri = helpImageUri(image.group(2)!);
      if (uri != null) {
        blocks.add(HelpImageBlock(uri: uri, alt: alt));
      } else if (alt.isNotEmpty) {
        blocks.add(HelpParagraphBlock([HelpInline(alt)]));
      }
      continue;
    }
    final heading = _heading.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      flushList();
      blocks.add(HelpHeadingBlock(heading.group(1)!.length, parseHelpInlines(heading.group(2)!)));
      continue;
    }
    final number = _number.firstMatch(line);
    final bullet = number == null ? _bullet.firstMatch(line) : null;
    if (number != null || bullet != null) {
      flushParagraph();
      final isOrdered = number != null;
      if (items != null && ordered != isOrdered) flushList();
      final current = items ??= [];
      if (current.isEmpty) {
        ordered = isOrdered;
        start = isOrdered ? int.parse(number.group(1)!) : 1;
      }
      current.add(isOrdered ? number.group(2)! : bullet!.group(1)!);
      continue;
    }
    final current = items;
    if (current != null && _leadingSpace.hasMatch(raw)) {
      current[current.length - 1] = '${current.last}\n${line.trim()}';
      continue;
    }
    flushList();
    paragraph.add(line.trim());
  }
  flushParagraph();
  flushList();
  return blocks;
}

List<HelpInline> parseHelpInlines(String text) {
  final parser = _InlineParser(text)..parse(0, text.length, bold: false, italic: false, link: null);
  return parser.merged();
}

final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

bool _isWordChar(String char) => _wordChar.hasMatch(char);

class _InlineParser {
  _InlineParser(this.source);

  final String source;
  final List<HelpInline> _out = [];

  List<HelpInline> merged() {
    final result = <HelpInline>[];
    for (final inline in _out) {
      final last = result.isEmpty ? null : result.last;
      if (last != null && last.bold == inline.bold && last.italic == inline.italic && last.link == inline.link) {
        result[result.length - 1] = HelpInline(
          last.text + inline.text,
          bold: last.bold,
          italic: last.italic,
          link: last.link,
        );
      } else {
        result.add(inline);
      }
    }
    return result;
  }

  void parse(int start, int end, {required bool bold, required bool italic, required Uri? link}) {
    final buffer = StringBuffer();
    void flush() {
      if (buffer.isEmpty) return;
      _out.add(HelpInline(buffer.toString(), bold: bold, italic: italic, link: link));
      buffer.clear();
    }

    var i = start;
    while (i < end) {
      final char = source[i];
      if (char == r'\' && i + 1 < end && _escapable.contains(source[i + 1])) {
        buffer.write(source[i + 1]);
        i += 2;
        continue;
      }
      if (!bold && source.startsWith('**', i)) {
        final close = _boldClose(i + 2, end);
        if (close != null) {
          flush();
          parse(i + 2, close, bold: true, italic: italic, link: link);
          i = close + 2;
          continue;
        }
      }
      if (!italic && (char == '*' || char == '_') && !source.startsWith('**', i)) {
        final close = _italicClose(char, i, end);
        if (close != null) {
          flush();
          parse(i + 1, close, bold: bold, italic: true, link: link);
          i = close + 1;
          continue;
        }
      }
      if (char == '!' && i + 1 < end && source[i + 1] == '[') {
        final match = _linkAt(i + 1, end);
        if (match != null) {
          flush();
          parse(i + 2, match.labelEnd, bold: bold, italic: italic, link: link);
          i = match.end;
          continue;
        }
      }
      if (link == null && char == '[') {
        final match = _linkAt(i, end);
        if (match != null) {
          flush();
          parse(i + 1, match.labelEnd, bold: bold, italic: italic, link: helpLinkUri(match.url));
          i = match.end;
          continue;
        }
      }
      buffer.write(char);
      i++;
    }
    flush();
  }

  int? _boldClose(int from, int end) {
    if (from >= end || source[from].trim().isEmpty) return null;
    var j = from + 1;
    while (j < end - 1) {
      if (source.startsWith('**', j) && source[j - 1].trim().isNotEmpty) return j;
      j++;
    }
    return null;
  }

  int? _italicClose(String marker, int open, int end) {
    final from = open + 1;
    if (from >= end || source[from].trim().isEmpty) return null;
    if (marker == '_' && open > 0 && _isWordChar(source[open - 1])) return null;
    var j = from + 1;
    while (j < end) {
      if (marker == '*' && source.startsWith('**', j)) {
        j += 2;
        continue;
      }
      if (source[j] == marker && source[j - 1].trim().isNotEmpty) {
        final after = j + 1 < source.length ? source[j + 1] : '';
        if (marker == '*' || after.isEmpty || !_isWordChar(after)) return j;
      }
      j++;
    }
    return null;
  }

  ({int labelEnd, String url, int end})? _linkAt(int open, int end) {
    final labelEnd = source.indexOf(']', open + 1);
    if (labelEnd < 0 || labelEnd >= end || labelEnd == open + 1) return null;
    if (source.substring(open + 1, labelEnd).contains('\n')) return null;
    if (labelEnd + 1 >= end || source[labelEnd + 1] != '(') return null;
    final close = source.indexOf(')', labelEnd + 2);
    if (close < 0 || close >= end) return null;
    final url = source.substring(labelEnd + 2, close).trim();
    if (url.isEmpty || url.contains(RegExp(r'\s'))) return null;
    return (labelEnd: labelEnd, url: url, end: close + 1);
  }
}
