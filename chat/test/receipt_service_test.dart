import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipt_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  ReceiptService? receiptService;

  setUp(() async {
    c = await r.connect(host: "localhost", port: 28015);
    await createDB(r, c!);
    receiptService = ReceiptService(r, c!);
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

  test('Sent receipt successfuly', () async {
    Receipt receipt = Receipt(
        recipient: '2',
        messageId: '1',
        receiptStatus: ReceiptStatus.delivered,
        timeStamp: DateTime.now());

    final res = await receiptService!.send(receipt);
    expect(res, true);
  });

  test('Successfully subscribe and receive receipts', () async {
    receiptService!.receipts(user).listen(expectAsync1((receipt) {
          expect(receipt.recipient, user.id);
        }, count: 2));
    Receipt receipt = Receipt(
        recipient: user.id,
        messageId: '1',
        receiptStatus: ReceiptStatus.delivered,
        timeStamp: DateTime.now());
    Receipt receipt2 = Receipt(
        recipient: user.id,
        messageId: '1',
        receiptStatus: ReceiptStatus.read,
        timeStamp: DateTime.now());

    await receiptService!.send(receipt);
    await receiptService!.send(receipt2);
  });
}
