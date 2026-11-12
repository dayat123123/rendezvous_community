import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';

abstract interface class MarketInstrumentRepository {
  Future<List<MarketInstrument>> getMarketInstruments();
}
