import 'package:chat/src/services/encryption/encryption_service_interface.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryptionService {
  final Encrypter _encrypter;
  final _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }
}
