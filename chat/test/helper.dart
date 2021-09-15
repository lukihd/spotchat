import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDB(RethinkDb r, Connection c) async {
  await r.dbCreate('test').run(c).catchError((err) => {});
  await r.tableCreate('users').run(c).catchError((err) => {});
  await r.tableCreate('messages').run(c).catchError((err) => {});
}

Future<void> cleanDB(RethinkDb r, Connection c) async {
  await r.table('users').delete().run(c);
  await r.table('messages').delete().run(c);
}
