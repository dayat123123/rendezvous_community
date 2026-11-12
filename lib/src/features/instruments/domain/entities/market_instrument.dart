import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_instrument.freezed.dart';

enum MarketInstrumentKind {
  stockIndex('index');

  const MarketInstrumentKind(this.wire);

  final String wire;

  static MarketInstrumentKind? fromWire(Object? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}

@freezed
abstract class MarketInstrument with _$MarketInstrument {
  const factory MarketInstrument({
    required String code,
    required String name,
    @Default(MarketInstrumentKind.stockIndex) MarketInstrumentKind kind,
    String? description,
    @Default(<String>[]) List<String> aliases,
    @Default(0) int position,
    @Default(true) bool roomEnabled,
  }) = _MarketInstrument;
}
