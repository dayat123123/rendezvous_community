import 'package:rendezvous_community/src/shared/domain/entities/user.dart';

enum TradeSide { buy, sell }

class TradeActivityText {
  const TradeActivityText({required this.title, this.body = ''});

  final String title;
  final String body;
}

class TradeActivity {
  const TradeActivity({
    required this.id,
    this.traderId,
    this.trader,
    required this.stock,
    required this.side,
    this.lots,
    this.orderLots,
    this.shares,
    this.price,
    this.partial = false,
    this.additional = false,
    this.completedAt,
    this.texts = const {},
    this.disclaimers = const {},
    this.cursor,
  });

  static TradeActivity? fromPayload(Map<String, Object?> payload, {UserSummary? trader}) {
    final id = _text(payload['activity_id']) ?? _text(payload['id']);
    final stock = _text(payload['stock']);
    if (id == null || stock == null) return null;
    return TradeActivity(
      id: id,
      traderId: _text(payload['trader_id']) ?? trader?.id,
      trader: trader,
      stock: stock,
      side: payload['side'] == 'sell' ? TradeSide.sell : TradeSide.buy,
      lots: _number(payload['lots']),
      orderLots: _number(payload['order_lots']),
      shares: _number(payload['shares'])?.toInt(),
      price: _number(payload['price'])?.toInt(),
      partial: payload['partial'] == true,
      additional: payload['additional'] == true,
      completedAt: _time(payload['completed_at']),
      texts: _texts(payload['text']),
      disclaimers: _strings(payload['disclaimer']),
      cursor: _text(payload['cursor']),
    );
  }

  final String id;
  final String? traderId;
  final UserSummary? trader;
  final String stock;
  final TradeSide side;
  final num? lots;
  final num? orderLots;
  final int? shares;
  final int? price;
  final bool partial;
  final bool additional;
  final DateTime? completedAt;
  final Map<String, TradeActivityText> texts;
  final Map<String, String> disclaimers;
  final String? cursor;

  TradeActivityText? text(String languageCode) => texts[languageCode] ?? texts['id'] ?? texts['en'];

  String? disclaimer(String languageCode) => disclaimers[languageCode] ?? disclaimers['id'] ?? disclaimers['en'];
}

String? _text(Object? value) => value is String && value.isNotEmpty ? value : null;

num? _number(Object? value) => switch (value) {
  final num n => n,
  final String s => num.tryParse(s),
  _ => null,
};

DateTime? _time(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;

Map<String, TradeActivityText> _texts(Object? value) => {
  if (value is Map)
    for (final entry in value.entries)
      if (entry.key is String && entry.value is Map && _text((entry.value as Map)['title']) != null)
        entry.key as String: TradeActivityText(
          title: (entry.value as Map)['title'] as String,
          body: _text((entry.value as Map)['body']) ?? '',
        ),
};

Map<String, String> _strings(Object? value) => {
  if (value is Map)
    for (final entry in value.entries)
      if (entry.key is String && _text(entry.value) != null) entry.key as String: entry.value as String,
};
