import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  UserService? userService;

  setUp(() async {
    c = await r.connect(host: "localhost", port: 28015);
    await createDB(r, c!);
    userService = UserService(r, c!);
  });

  tearDown(() async {
    // await cleanDB(r, c!);
  });

  test("Creates a new user document in database", () async {
    final user = User(
        username: 'test',
        photoUrl: 'url',
        active: true,
        lastSeen: DateTime.now());
    final userWithId = await userService!.connect(user);
    expect(userWithId.id, isNotEmpty);
  });

  test("get online users", () async {
    final user = User(
        username: 'test2',
        photoUrl: 'url',
        active: true,
        lastSeen: DateTime.now());
    await userService!.connect(user);
    final onlineUsers = await userService!.online();
    expect(onlineUsers.length, 1);
  });
}
