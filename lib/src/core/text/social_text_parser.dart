final cashtagPattern = RegExp(
  r'(?<![A-Za-z0-9_$])\$([A-Za-z][A-Za-z0-9]{0,19}(?:-[A-Za-z0-9]{1,19})*)(?![A-Za-z0-9_])',
);

final _plainCashtag = RegExp(r'^[A-Z][A-Z0-9]{1,11}$');

typedef CashtagResolver = String? Function(String token);

final mentionPattern = RegExp(r'(?<![A-Za-z0-9_@])@([A-Za-z0-9_]{3,30})(?![A-Za-z0-9_])');

final hashtagTextPattern = RegExp(r'(?<![\p{L}\p{N}_#&/])#([A-Za-z0-9_]{2,50})(?![A-Za-z0-9_])', unicode: true);

final linkPattern = RegExp(r'''https?://[^\s<>"'`{}|\\^\[\]]+''', caseSensitive: false);

final _trailingPunctuation = RegExp(r'''[.,;:!?\]}'"»”’]+$''');

final _wwwLinkPattern = RegExp(
  r'''(?<![\w@./-])www\.[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+(?:[/?#][^\s<>"'`{}|\\^\[\]]*)?''',
  caseSensitive: false,
);

final _emailPattern = RegExp(
  r'(?<![\w.%+-])[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}(?![\w-])',
);

final _phonePattern = RegExp(r'(?<![\w+])(?:\+62[ -]?|0)\d(?:[ -]?\d){8,13}(?!\w)');

const maxTagsPerPost = 10;

const maxLinksPerContent = 3;

List<String> extractCashtags(String text, {CashtagResolver? resolve}) => _distinct([
  for (final m in cashtagPattern.allMatches(text)) ?resolveCashtagToken(m.group(1)!, resolve: resolve)?.code,
]);

({String code, int length})? resolveCashtagToken(String token, {CashtagResolver? resolve, Set<String>? known}) {
  var candidate = token.toUpperCase();
  while (true) {
    final code =
        resolve?.call(candidate) ??
        ((known?.contains(candidate) ?? false) || _plainCashtag.hasMatch(candidate) ? candidate : null);
    if (code != null) return (code: code, length: candidate.length);
    final dash = candidate.lastIndexOf('-');
    if (dash < 0) return null;
    candidate = candidate.substring(0, dash);
  }
}

List<String> extractMentions(String text) =>
    _distinct(mentionPattern.allMatches(text).map((m) => m.group(1)!.toLowerCase()));

String lowercaseMentions(String text) {
  if (!text.contains('@')) return text;
  final protected = [
    for (final m in linkPattern.allMatches(text)) (start: m.start, end: m.start + trimLinkMatch(m.group(0)!).length),
    for (final m in _wwwLinkPattern.allMatches(text)) (start: m.start, end: m.end),
    for (final m in _emailPattern.allMatches(text)) (start: m.start, end: m.end),
  ];
  return text.replaceAllMapped(mentionPattern, (m) {
    final token = m.group(0)!;
    return protected.any((p) => m.start >= p.start && m.start < p.end) ? token : token.toLowerCase();
  });
}

List<String> extractHashtags(String text) =>
    _distinct(_withoutLinks(text, hashtagTextPattern).map((m) => m.group(1)!.toLowerCase()));

List<String> extractLinks(String text, {int max = maxLinksPerContent}) {
  final found = <String>[];
  for (final match in linkPattern.allMatches(text)) {
    final url = trimLinkMatch(match.group(0)!);
    final uri = safeLinkUri(url);
    if (uri == null || found.contains(url)) continue;
    found.add(url);
    if (found.length == max) break;
  }
  return found;
}

String trimLinkMatch(String raw) {
  var url = raw.replaceFirst(_trailingPunctuation, '');
  while (url.endsWith(')') && '('.allMatches(url).length < ')'.allMatches(url).length) {
    url = url.substring(0, url.length - 1).replaceFirst(_trailingPunctuation, '');
  }
  return url;
}

Uri? safeLinkUri(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return null;
  if (uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
  return uri;
}

Iterable<RegExpMatch> _withoutLinks(String text, RegExp pattern) {
  final links = [
    for (final m in linkPattern.allMatches(text)) (start: m.start, end: m.start + trimLinkMatch(m.group(0)!).length),
  ];
  return pattern.allMatches(text).where((m) => !links.any((l) => m.start >= l.start && m.start < l.end));
}

List<String> _distinct(Iterable<String> values) {
  final seen = <String>{};
  return [
    for (final v in values)
      if (seen.add(v)) v,
  ];
}

sealed class SocialTextSegment {
  const SocialTextSegment(this.text);

  final String text;
}

class PlainSegment extends SocialTextSegment {
  const PlainSegment(super.text);
}

class CashtagSegment extends SocialTextSegment {
  const CashtagSegment(super.text, this.code);

  final String code;
}

class MentionSegment extends SocialTextSegment {
  const MentionSegment(super.text, this.username);

  final String username;
}

class HashtagSegment extends SocialTextSegment {
  const HashtagSegment(super.text, this.tag);

  final String tag;
}

class LinkSegment extends SocialTextSegment {
  const LinkSegment(super.text, this.uri);

  final Uri uri;
}

List<SocialTextSegment> parseSocialText(
  String text, {
  Set<String>? validStockCodes,
  CashtagResolver? resolveCashtag,
  bool hashtags = false,
  bool links = false,
  bool contacts = false,
  bool cashtags = true,
  bool mentions = true,
}) {
  final matches = <({int start, int end, SocialTextSegment segment})>[];

  if (links) {
    for (final m in linkPattern.allMatches(text)) {
      final url = trimLinkMatch(m.group(0)!);
      final uri = safeLinkUri(url);
      if (uri == null) continue;
      matches.add((start: m.start, end: m.start + url.length, segment: LinkSegment(url, uri)));
    }
    for (final m in _wwwLinkPattern.allMatches(text)) {
      final url = trimLinkMatch(m.group(0)!);
      final uri = safeLinkUri('https://$url');
      if (uri == null) continue;
      matches.add((start: m.start, end: m.start + url.length, segment: LinkSegment(url, uri)));
    }
  }
  if (contacts) {
    for (final m in _emailPattern.allMatches(text)) {
      final email = m.group(0)!;
      matches.add((start: m.start, end: m.end, segment: LinkSegment(email, Uri(scheme: 'mailto', path: email))));
    }
    for (final m in _phonePattern.allMatches(text)) {
      final number = m.group(0)!;
      final digits = number.replaceAll(RegExp(r'\D'), '');
      final uri = Uri.parse('tel:${number.startsWith('+') ? '+' : ''}$digits');
      matches.add((start: m.start, end: m.end, segment: LinkSegment(number, uri)));
    }
  }
  if (cashtags) {
    for (final m in cashtagPattern.allMatches(text)) {
      final resolved = resolveCashtagToken(m.group(1)!, resolve: resolveCashtag, known: validStockCodes);
      if (resolved == null) continue;
      if (validStockCodes != null && !validStockCodes.contains(resolved.code)) continue;
      final end = m.start + 1 + resolved.length;
      matches.add((start: m.start, end: end, segment: CashtagSegment(text.substring(m.start, end), resolved.code)));
    }
  }
  if (mentions) {
    for (final m in mentionPattern.allMatches(text)) {
      matches.add((start: m.start, end: m.end, segment: MentionSegment(m.group(0)!, m.group(1)!)));
    }
  }
  if (hashtags) {
    for (final m in hashtagTextPattern.allMatches(text)) {
      matches.add((start: m.start, end: m.end, segment: HashtagSegment(m.group(0)!, m.group(1)!.toLowerCase())));
    }
  }
  matches.sort((a, b) => a.start != b.start ? a.start.compareTo(b.start) : b.end.compareTo(a.end));

  final segments = <SocialTextSegment>[];
  var cursor = 0;
  for (final m in matches) {
    if (m.start < cursor) continue;
    if (m.start > cursor) segments.add(PlainSegment(text.substring(cursor, m.start)));
    segments.add(m.segment);
    cursor = m.end;
  }
  if (cursor < text.length) segments.add(PlainSegment(text.substring(cursor)));
  return segments;
}

class ActiveToken {
  const ActiveToken({required this.trigger, required this.query, required this.start, required this.end});

  final String trigger;

  final String query;

  final int start;

  final int end;
}

final _activeTokenPattern = RegExp(r'(?:^|[^A-Za-z0-9_$@])(?:(\$)([A-Za-z0-9-]{0,24})|(@)([A-Za-z0-9_]{0,30}))$');

ActiveToken? findActiveToken(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;
  final match = _activeTokenPattern.firstMatch(text.substring(0, cursor));
  if (match == null) return null;
  final trigger = match.group(1) ?? match.group(3)!;
  final query = match.group(2) ?? match.group(4)!;
  return ActiveToken(trigger: trigger, query: query, start: cursor - query.length - 1, end: cursor);
}
