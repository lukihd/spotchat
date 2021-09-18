import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing_notification/typing_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  TypingNotification? typingNotification;

  setUp(() async {
    c = await r.connect(host: "localhost", port: 28015);
    await createDB(r, c!);
    typingNotification = TypingNotification(r, c!);
  });

  tearDown(() async {
    await cleanDB(r, c!);
  });

  final user = User.fromJson({
    'id': '1',
    'active': true,
    'lastSeen': DateTime.now(),
    'username': 'user1',
    'photoUrl': ''
  });

  final user2 = User.fromJson({
    'id': '2',
    'active': true,
    'lastSeen': DateTime.now(),
    'username': 'user2',
    'photoUrl': ''
  });

  test('sent typing notification successfully', () async {
    TypingEvent typingEvent =
        TypingEvent(from: user2.id, to: user.id, event: Typing.start);
    final res =
        await typingNotification!.send(typingEvent: typingEvent, to: user);
    expect(res, true);
  });

  test('successfully subscribed and receiving typing events ', () async {
    typingNotification!
        .subscribe(user2, [user.id]).listen(expectAsync1((event) {
      expect(event.from, user.id);
    }, count: 2));
    TypingEvent start =
        TypingEvent(from: user.id, to: user2.id, event: Typing.start);
    TypingEvent stop =
        TypingEvent(from: user.id, to: user2.id, event: Typing.stop);

    await typingNotification!.send(to: user2, typingEvent: start);
    await typingNotification!.send(to: user2, typingEvent: stop);
  });
}
