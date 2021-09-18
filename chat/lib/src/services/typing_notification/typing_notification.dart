import 'dart:async';

import 'package:chat/src/models/user.dart';
import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/services/typing_notification/typing_notification_inteface.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingNotification implements ITypingNotification {
  // fields
  final RethinkDb _r;
  final Connection _connection;

  final _controller = StreamController<TypingEvent>.broadcast();
  StreamSubscription? _changeFeed;

  // constructor
  TypingNotification(this._r, this._connection);

  @override
  Future<bool> send(
      {required TypingEvent typingEvent, required User to}) async {
    if (!to.active) {
      return false;
    }
    Map record = await _r
        .table('typing_events')
        .insert(typingEvent.toJson(), {'conflict': 'update'}).run(_connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> usersIds) {
    _startReceivingTypingEvents(user, usersIds);
    return _controller.stream;
  }

  @override
  void dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  void _startReceivingTypingEvents(User user, List<String> usersIds) {
    _changeFeed = _r
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(user.id)
              .and(_r.expr(usersIds).contains(event('from')));
        })
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
                final typing = _eventFromFeed(feedData);
                _controller.sink.add(typing);
                _removeTypingEvent(typing);
              })
              .catchError((err) => print("Error receiving receipt : " + err))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  void _removeTypingEvent(TypingEvent typingEvent) {
    _r
        .table('typing_events')
        .get(typingEvent.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
