import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_interface.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  // fields
  final RethinkDb r;
  final Connection _connection;

  // constructor
  UserService(this.r, this._connection);

  // Create user if not exist in db and return the user.
  @override
  Future<User> connect(User user) async {
    dynamic data = user.toJson();
    if (user.id != null) {
      data['id'] = user.id;
    }

    final result = await r.table('users').insert(
        data, {'conflict': 'update', 'return_changes': true}).run(_connection);

    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnect(User user) async {
    await r.table('users').update({
      'id': user.id,
      'active': false,
      'lastSeen': DateTime.now()
    }).run(_connection);
    if (!_connection.isClosed) {
      _connection.close();
    }
  }

  @override
  Future<List<User>> online() async {
    Cursor onlineUsers =
        await r.table('users').filter({'active': true}).run(_connection);
    final onlineUsersList = await onlineUsers.toList();
    return onlineUsersList.map((item) => User.fromJson(item)).toList();
  }
}
