import 'package:rendezvous_community/src/features/notices/domain/entities/community_notice.dart';

abstract interface class NoticeRepository {
  Future<CommunityNotice> get(String id);
}
