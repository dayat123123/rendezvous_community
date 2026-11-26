import 'package:rendezvous_community/src/features/feed/domain/entities/post_info_card.dart';

Object? readPostAttachments(Map<dynamic, dynamic> json, String key) => json['attachments'];

PostInfoCard? infoCardFromAttachments(Object? value) {
  if (value is! List) return null;
  for (final item in value) {
    if (item is Map && item['type'] == 'card') return _card(item);
  }
  return null;
}

PostInfoCard? _card(Map<dynamic, dynamic> json) {
  final document = _document(json['document']);
  if (document == null) return null;
  final source = switch (json['source']) {
    'research' => InfoCardSource.research,
    'manual' => InfoCardSource.manual,
    _ => InfoCardSource.other,
  };
  final research = source == InfoCardSource.research;
  return PostInfoCard(
    source: source,
    researchId: research ? _text(json['research_id']) : null,
    kind: research ? _text(json['kind']) : null,
    stockCode: _text(json['stock_code'])?.toUpperCase(),
    document: document,
  );
}

InfoCardDocument? _document(Object? value) {
  if (value is! Map) return null;
  final version = value['version'];
  if (version is! num || version.toInt() != InfoCardDocument.supportedVersion) return null;
  final title = _text(value['title']);
  final headline = _text(value['headline']);
  if (title == null && headline == null) return null;
  final raw = value['blocks'];
  final blocks = <InfoCardBlock>[];
  if (raw is List) {
    for (final item in raw) {
      if (blocks.length >= InfoCardDocument.maxBlocks) break;
      if (item is Map) {
        if (_block(item) case final block?) blocks.add(block);
      }
    }
  }
  return InfoCardDocument(
    badge: _text(value['badge']),
    title: title ?? '',
    subtitle: _text(value['subtitle']),
    headline: headline,
    blocks: blocks,
    disclaimer: _text(value['disclaimer']),
  );
}

InfoCardBlock? _block(Map<dynamic, dynamic> json) {
  switch (json['type']) {
    case 'paragraph':
      final text = _text(json['text']);
      return text == null ? null : InfoCardParagraph(text);
    case 'list':
      final items = [
        if (json['items'] case final List list)
          for (final item in list) ?_text(item),
      ];
      return items.isEmpty ? null : InfoCardList(numbered: json['style'] == 'numbered', items: items);
    case 'callout':
      final text = _text(json['text']);
      return text == null ? null : InfoCardCallout(title: _text(json['title']), text: text);
    case 'metrics':
      final metrics = [
        if (json['metrics'] case final List list)
          for (final item in list)
            if (item is Map) ?_metric(item),
      ];
      return metrics.isEmpty ? null : InfoCardMetrics(metrics);
  }
  return null;
}

InfoCardMetric? _metric(Map<dynamic, dynamic> json) {
  final label = _text(json['label']);
  final value = _text(json['value']);
  if (label == null || value == null) return null;
  return InfoCardMetric(
    label: label,
    value: value,
    change: _text(json['change']),
    trend: switch (json['trend']) {
      'up' => InfoCardTrend.up,
      'down' => InfoCardTrend.down,
      'flat' => InfoCardTrend.flat,
      _ => null,
    },
  );
}

String? _text(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  return text.isEmpty ? null : text;
}
