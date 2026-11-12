import 'package:flutter/widgets.dart';
import 'package:rendezvous_community/src/app/community_scope.dart';
import 'package:rendezvous_community/src/features/instruments/domain/services/market_instrument_directory.dart';

abstract final class CommunityInstruments {
  static MarketInstrumentDirectory? maybeOf(BuildContext context) {
    final dependencies = CommunityScope.maybeOf(context);
    if (dependencies == null) return null;
    return MarketInstrumentDirectory.forSource(dependencies.stocks)..ensureLoaded();
  }

  static MarketInstrumentDirectory of(BuildContext context) =>
      maybeOf(context) ?? MarketInstrumentDirectory.forSource(CommunityScope.of(context).stocks);
}
