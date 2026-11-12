import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';

part 'stock_suggestion.freezed.dart';

@freezed
abstract class StockSuggestion with _$StockSuggestion {
  const factory StockSuggestion({required String code, String? name, MarketInstrumentKind? kind}) = _StockSuggestion;
}
