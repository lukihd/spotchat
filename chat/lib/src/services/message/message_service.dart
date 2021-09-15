import 'dart:async';

import 'package:chat/src/models/user.dart';
import 'package:chat/src/models/message.dart';
import 'package:chat/src/services/message/message_service_interface.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  // fields
  final RethinkDb r;
  final Connection _connection;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription? _changeFeed;

  MessageService(this.r, this._connection);

  @override
  dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  @override
  Stream<Message> messages(User activeUser) {
    _startReceivingMessages(activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> send(Message message) async {
    Map record =
        await r.table('messages').insert(message.toJson()).run(_connection);
    return record['inserted'] == 1;
  }

  void _startReceivingMessages(User activeUser) {
    _changeFeed = r
        .table('messages')
        .filter({'to': activeUser.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) {
                  return;
                }
                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
                _removeDistributedMessage(message);
              })
              .catchError((err) => print("Error receiving message : " + err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message _messageFromFeed(feedData) {
    return Message.fromJson(feedData['new_val']);
  }

  void _removeDistributedMessage(Message message) {
    r
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
