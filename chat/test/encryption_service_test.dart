import 'package:chat/src/services/encryption/encryption_service.dart';
import 'package:chat/src/services/encryption/encryption_service_interface.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  IEncryptionService? encryptionService;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    encryptionService = EncryptionService(encrypter);
  });

  test('Encrypt plain text', () {
    const String text = 'my message';
    final encryptedByService = encryptionService!.encrypt(text);

    expect(
        RegExp(r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$')
            .hasMatch(encryptedByService),
        true);
  });

  test('decrypt text', () {
    const String text = 'my message';
    final encryptedByService = encryptionService!.encrypt(text);
    final decryptedByService = encryptionService!.decrypt(encryptedByService);

    expect(decryptedByService, text);
  });
}
