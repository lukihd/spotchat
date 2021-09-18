enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values
        .firstWhere((element) => element.value() == status);
  }
}

class Receipt {
  // fields
  dynamic _id;
  final String recipient;
  final String messageId;
  final ReceiptStatus receiptStatus;
  final DateTime timeStamp;

  // getter
  String get id => _id;

  // constructor
  Receipt(
      {required this.recipient,
      required this.messageId,
      required this.receiptStatus,
      required this.timeStamp});

  // Convert from dart object to json object for database
  Map<String, dynamic> toJson() => {
        'recipient': recipient,
        'messageId': messageId,
        'receiptStatus': receiptStatus.value(),
        'timeStamp': timeStamp
      };

  // convert from JSON to dart object from database
  factory Receipt.fromJson(Map<String, dynamic> json) {
    final receipt = Receipt(
        recipient: json['recipient'],
        messageId: json['messageId'],
        receiptStatus: EnumParsing.fromString(json['receiptStatus']),
        timeStamp: json['timeStamp']);
    receipt._id = json['id'];
    return receipt;
  }
}
