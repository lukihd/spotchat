import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';

abstract class IMessageService {
  Future<bool> send(Message message);
  Stream<Message> messages(User activeUser);
  dispose();
}
