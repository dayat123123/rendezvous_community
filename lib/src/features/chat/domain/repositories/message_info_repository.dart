import 'package:rendezvous_community/src/features/chat/domain/entities/message_info.dart';

abstract interface class MessageInfoRepository {
  Future<MessageInfo> getMessageInfo(String messageId);
}
