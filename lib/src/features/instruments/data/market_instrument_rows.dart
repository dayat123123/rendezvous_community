import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';

MarketInstrument? marketInstrumentFromRow(Map<String, dynamic> row) {
  final code = row['code'];
  if (code is! String || code.isEmpty) return null;
  final kind = MarketInstrumentKind.fromWire(row['kind'] ?? MarketInstrumentKind.stockIndex.wire);
  if (kind == null) return null;
  final name = row['name'];
  return MarketInstrument(
    code: code.toUpperCase(),
    name: name is String && name.trim().isNotEmpty ? name : code.toUpperCase(),
    kind: kind,
    description: row['description'] as String?,
    aliases: [
      for (final alias in row['aliases'] as List<dynamic>? ?? const <dynamic>[])
        if (alias is String && alias.isNotEmpty) alias.toUpperCase(),
    ],
    position: (row['position'] as num?)?.toInt() ?? 0,
    roomEnabled: row['room_enabled'] as bool? ?? true,
  );
}
