// ignore_for_file: file_names

class User {
  // fields
  dynamic _id;
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;

  // getters
  dynamic get id => _id;

  // constructors
  User(
      {required this.username,
      required this.photoUrl,
      required this.active,
      required this.lastSeen});

  // convert from dart User object to json
  toJson() => {
        'username': username,
        'photoUrl': photoUrl,
        'active': active,
        'lastSeen': lastSeen
      };

  // convert JSON User object to dart object
  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        username: json['username'],
        photoUrl: json['photoUrl'],
        active: json['active'],
        lastSeen: json['lastSeen']);
    user._id = json['id'];
    return user;
  }
}
