import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service.dart';
import 'package:chat/src/services/encryption/encryption_service_interface.dart';
import 'package:chat/src/services/message/message_service.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  MessageService? messageService;
  IEncryptionService encryptionService;

  setUp(() async {
    c = await r.connect(host: "localhost", port: 28015);
    await createDB(r, c!);
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    encryptionService = EncryptionService(encrypter);
    messageService = MessageService(r, c!, encryptionService);
  });

  tearDown(() async {
    messageService?.dispose();
    await cleanDB(r, c!);
  });

  final user1 = User.fromJson({
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

  test('Send message successfully', () async {
    Message message = Message(
        from: user1.id,
        to: user2.id,
        timeStamp: DateTime.now(),
        content: "test");

    final res = await messageService?.send(message);
    expect(res, true);
  });

  test('successfully subscribed and receive messages', () async {
    messageService!.messages(user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    Message message1 = Message(
        from: user1.id,
        to: user2.id,
        timeStamp: DateTime.now(),
        content: "from 1 to 2");
    Message message2 = Message(
        from: user1.id,
        to: user2.id,
        timeStamp: DateTime.now(),
        content: "from 1 to 2 again");

    await messageService?.send(message1);
    await messageService?.send(message2);
  });

  test('successfully subscribed and receive new messages', () async {
    Message message1 = Message(
        from: user1.id,
        to: user2.id,
        timeStamp: DateTime.now(),
        content: "from 1 to 2");
    Message message2 = Message(
        from: user1.id,
        to: user2.id,
        timeStamp: DateTime.now(),
        content: "from 1 to 2 again");

    await messageService?.send(message1);
    await messageService?.send(message2).whenComplete(
          () => messageService?.messages(user2).listen(
                expectAsync1((message) {
                  expect(message.to, user2.id);
                }, count: 2),
              ),
        );
  });
}
