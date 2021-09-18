enum Typing { start, stop }

extension TypingParser on Typing {
  String value() {
    return toString().split('.').first;
  }

  static Typing fromString(String event) {
    return Typing.values.firstWhere((element) => element.value() == event);
  }
}

class TypingEvent {
  // fields
  dynamic _id;
  final String from;
  final String to;
  final Typing event;

  // getter
  String get id => _id;

  // constructor
  TypingEvent({required this.from, required this.to, required this.event});

  Map<String, dynamic> toJson() =>
      {'from': from, 'to': to, 'event': event.value()};

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final event = TypingEvent(
        from: json['from'],
        to: json['to'],
        event: TypingParser.fromString(json['event']));
    event._id = json['id'];
    return event;
  }
}
