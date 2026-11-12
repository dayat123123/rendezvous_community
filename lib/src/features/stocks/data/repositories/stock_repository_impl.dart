import 'package:logging/logging.dart';
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/logging/community_logger.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/features/instruments/data/market_instrument_rows.dart';
import 'package:rendezvous_community/src/features/instruments/domain/entities/market_instrument.dart';
import 'package:rendezvous_community/src/features/instruments/domain/repositories/market_instrument_repository.dart';
import 'package:rendezvous_community/src/features/stocks/data/models/stock_model.dart';
import 'package:rendezvous_community/src/features/stocks/domain/entities/stock.dart';
import 'package:rendezvous_community/src/features/stocks/domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository, MarketInstrumentRepository {
  StockRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  @override
  Future<Stock?> getStock(String code) async {
    final rows = await _api.rpcRows('get_stock', {'p_code': code});
    return rows.isEmpty ? null : StockModel.fromJson(rows.first).toEntity();
  }

  @override
  Future<void> watch(String code) async {
    final me = await _api.requireUserId();
    await _api.insertIgnoringDuplicate('stock_watchers', {'user_id': me, 'stock_code': code.toUpperCase()});
  }

  @override
  Future<void> unwatch(String code) async {
    final me = await _api.requireUserId();
    await _api.delete('stock_watchers', {'user_id': me, 'stock_code': code.toUpperCase()});
  }

  @override
  Future<List<MarketInstrument>> getMarketInstruments() async {
    try {
      final rows = await _api.rpcRows('get_market_instruments', const {});
      return [for (final row in rows) ?marketInstrumentFromRow(row)];
    } on CommunityException catch (e) {
      if (e.code != 'PGRST202') rethrow;
      CommunityLoggers.feed.event(
        Level.INFO,
        'Server has no market instrument directory yet',
        fields: {'code': e.code},
      );
      return const [];
    }
  }
}
