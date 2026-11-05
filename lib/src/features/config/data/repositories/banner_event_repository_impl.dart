import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';
import 'package:rendezvous_community/src/features/config/domain/repositories/banner_event_repository.dart';

class BannerEventRepositoryImpl implements BannerEventRepository {
  BannerEventRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  @override
  Future<void> record(String bannerId, CommunityBannerEvent event) async {
    await _api.rpcValue('record_banner_event', {'p_banner_id': bannerId, 'p_event': event.name});
  }
}
