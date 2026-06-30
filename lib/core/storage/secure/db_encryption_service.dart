import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DbEncryptionService {
  final FlutterSecureStorage _storage;
  static const _encryptionKeyName = 'db_encryption_key';

  DbEncryptionService(this._storage);

  Future<Uint8List> getOrCreateEncryptionKey() async {
    final storedKey = await _storage.read(key: _encryptionKeyName);
    if (storedKey != null) {
      return base64Url.decode(storedKey);
    }

    final newKey = _generateSecureKey();
    await _storage.write(key: _encryptionKeyName, value: base64Url.encode(newKey));
    return newKey;
  }

  Uint8List _generateSecureKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
  }
}
