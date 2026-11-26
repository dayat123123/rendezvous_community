import 'package:flutter/foundation.dart';

enum ResearchTrend { up, down, flat }

sealed class ResearchBlock {
  const ResearchBlock();
}

final class ResearchParagraph extends ResearchBlock {
  const ResearchParagraph(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is ResearchParagraph && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

final class ResearchList extends ResearchBlock {
  const ResearchList({required this.numbered, required this.items});

  final bool numbered;
  final List<String> items;

  @override
  bool operator ==(Object other) =>
      other is ResearchList && other.numbered == numbered && listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(numbered, Object.hashAll(items));
}

final class ResearchCallout extends ResearchBlock {
  const ResearchCallout({required this.text, this.title});

  final String? title;
  final String text;

  @override
  bool operator ==(Object other) => other is ResearchCallout && other.title == title && other.text == text;

  @override
  int get hashCode => Object.hash(title, text);
}

final class ResearchMetrics extends ResearchBlock {
  const ResearchMetrics(this.metrics);

  final List<ResearchMetric> metrics;

  @override
  bool operator ==(Object other) => other is ResearchMetrics && listEquals(other.metrics, metrics);

  @override
  int get hashCode => Object.hashAll(metrics);
}

class ResearchMetric {
  const ResearchMetric({required this.label, required this.value, this.change, this.trend});

  final String label;
  final String value;
  final String? change;
  final ResearchTrend? trend;

  @override
  bool operator ==(Object other) =>
      other is ResearchMetric &&
      other.label == label &&
      other.value == value &&
      other.change == change &&
      other.trend == trend;

  @override
  int get hashCode => Object.hash(label, value, change, trend);
}

class ResearchDocument {
  const ResearchDocument({
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
  final List<ResearchBlock> blocks;
  final String? disclaimer;

  @override
  bool operator ==(Object other) =>
      other is ResearchDocument &&
      other.badge == badge &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.headline == headline &&
      other.disclaimer == disclaimer &&
      listEquals(other.blocks, blocks);

  @override
  int get hashCode => Object.hash(badge, title, subtitle, headline, disclaimer, Object.hashAll(blocks));
}

class PostResearch {
  const PostResearch({required this.id, required this.kind, required this.document, this.stockCode});

  final String id;
  final String kind;
  final String? stockCode;
  final ResearchDocument document;

  @override
  bool operator ==(Object other) =>
      other is PostResearch &&
      other.id == id &&
      other.kind == kind &&
      other.stockCode == stockCode &&
      other.document == document;

  @override
  int get hashCode => Object.hash(id, kind, stockCode, document);
}
