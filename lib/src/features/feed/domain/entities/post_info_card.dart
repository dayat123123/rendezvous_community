import 'package:flutter/foundation.dart';

enum InfoCardTrend { up, down, flat }

enum InfoCardSource { research, manual, other }

sealed class InfoCardBlock {
  const InfoCardBlock();
}

final class InfoCardParagraph extends InfoCardBlock {
  const InfoCardParagraph(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is InfoCardParagraph && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

final class InfoCardList extends InfoCardBlock {
  const InfoCardList({required this.numbered, required this.items});

  final bool numbered;
  final List<String> items;

  @override
  bool operator ==(Object other) =>
      other is InfoCardList && other.numbered == numbered && listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(numbered, Object.hashAll(items));
}

final class InfoCardCallout extends InfoCardBlock {
  const InfoCardCallout({required this.text, this.title});

  final String? title;
  final String text;

  @override
  bool operator ==(Object other) => other is InfoCardCallout && other.title == title && other.text == text;

  @override
  int get hashCode => Object.hash(title, text);
}

final class InfoCardMetrics extends InfoCardBlock {
  const InfoCardMetrics(this.metrics);

  final List<InfoCardMetric> metrics;

  @override
  bool operator ==(Object other) => other is InfoCardMetrics && listEquals(other.metrics, metrics);

  @override
  int get hashCode => Object.hashAll(metrics);
}

class InfoCardMetric {
  const InfoCardMetric({required this.label, required this.value, this.change, this.trend});

  final String label;
  final String value;
  final String? change;
  final InfoCardTrend? trend;

  @override
  bool operator ==(Object other) =>
      other is InfoCardMetric &&
      other.label == label &&
      other.value == value &&
      other.change == change &&
      other.trend == trend;

  @override
  int get hashCode => Object.hash(label, value, change, trend);
}

class InfoCardDocument {
  const InfoCardDocument({
    required this.title,
    required this.blocks,
    this.badge,
    this.subtitle,
    this.headline,
    this.disclaimer,
  });

  static const int supportedVersion = 1;
  static const int maxBlocks = 20;

  final String? badge;
  final String title;
  final String? subtitle;
  final String? headline;
  final List<InfoCardBlock> blocks;
  final String? disclaimer;

  @override
  bool operator ==(Object other) =>
      other is InfoCardDocument &&
      other.badge == badge &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.headline == headline &&
      other.disclaimer == disclaimer &&
      listEquals(other.blocks, blocks);

  @override
  int get hashCode => Object.hash(badge, title, subtitle, headline, disclaimer, Object.hashAll(blocks));
}

class PostInfoCard {
  const PostInfoCard({required this.source, required this.document, this.researchId, this.kind, this.stockCode});

  final InfoCardSource source;
  final String? researchId;
  final String? kind;
  final String? stockCode;
  final InfoCardDocument document;

  @override
  bool operator ==(Object other) =>
      other is PostInfoCard &&
      other.source == source &&
      other.researchId == researchId &&
      other.kind == kind &&
      other.stockCode == stockCode &&
      other.document == document;

  @override
  int get hashCode => Object.hash(source, researchId, kind, stockCode, document);
}
