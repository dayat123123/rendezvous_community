import 'package:rendezvous_community/src/core/network/json_values.dart';
import 'package:rendezvous_community/src/core/network/social_remote_data_source.dart';
import 'package:rendezvous_community/src/features/notices/domain/entities/community_notice.dart';
import 'package:rendezvous_community/src/features/notices/domain/repositories/notice_repository.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  NoticeRepositoryImpl(this._api);

  final SocialRemoteDataSource _api;

  @override
  Future<CommunityNotice> get(String id) async {
    final data = jsonMap(await _api.rpcValue('get_app_notice', {'p_id': id}));
    return CommunityNotice.fromJson(data, id: id);
  }
}
