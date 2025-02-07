import 'package:encrypt/encrypt.dart';

class Crypto {
  Crypto({required this.key, required this.iv}) {
    _key = Key.fromUtf8(key);
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
  }

  final String key;
  final IV iv;

  late Key _key;
  late Encrypter _encrypter;

  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  String decrypt(String plainText) {
    final decrypted = _encrypter.decrypt(Encrypted.from64(plainText), iv: iv);

    return decrypted;
  }
}
