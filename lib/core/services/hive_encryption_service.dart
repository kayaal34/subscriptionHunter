import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _encryptionKeyName = 'encryption_key';
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

Future<List<int>> getHiveEncryptionKey() async {
  final storedKey = await _secureStorage.read(key: _encryptionKeyName);

  if (storedKey == null || storedKey.isEmpty) {
    final generatedKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64UrlEncode(generatedKey),
    );
    return generatedKey;
  }

  return base64Url.decode(storedKey);
}

Future<HiveAesCipher> getHiveEncryptionCipher() async {
  final encryptionKey = await getHiveEncryptionKey();
  return HiveAesCipher(encryptionKey);
}

Future<Box<T>> openEncryptedBox<T>(String name) async {
  final cipher = await getHiveEncryptionCipher();
  return Hive.openBox<T>(name, encryptionCipher: cipher);
}