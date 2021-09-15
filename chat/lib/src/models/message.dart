class Message {
  // fields
  dynamic _id;
  final String from;
  final String to;
  final DateTime timeStamp;
  final String content;

  // getters
  dynamic get id => _id;

  // contrstructor
  Message(
      {required this.from,
      required this.to,
      required this.timeStamp,
      required this.content});

  toJson() =>
      {'from': from, 'to': to, 'timeStamp': timeStamp, 'content': content};

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
        from: json['from'],
        to: json['to'],
        timeStamp: json['timeStamp'],
        content: json['content']);
    message._id = json['id'];
    return message;
  }
}
