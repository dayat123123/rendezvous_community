import 'package:rendezvous_community/src/features/config/domain/entities/client_config.dart';

abstract interface class BannerEventRepository {
  Future<void> record(String bannerId, CommunityBannerEvent event);
}
