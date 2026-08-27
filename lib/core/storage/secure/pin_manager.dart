import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PinManager {
  final FlutterSecureStorage _storage;
  static const _pinKey = 'hashed_pin';
  static const _attemptsKey = 'pin_attempts';
  static const _maxAttempts = 5;

  PinManager(this._storage);

  Future<void> savePin(String pin) async {
    final salt = _generateSecureSalt();
    final hashedPin = _hashPin(pin, salt);
    await _storage.write(key: _pinKey, value: '$hashedPin:$salt');
    await _resetAttempts();
  }

  String _generateSecureSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  Future<bool> verifyPin(String pin) async {
    final attempts = await _getAttempts();
    if (attempts >= _maxAttempts) return false;

    final storedData = await _storage.read(key: _pinKey);
    if (storedData == null) return false;

    final parts = storedData.split(':');
    final hashedPin = parts[0];
    final salt = parts[1];

    final inputHash = _hashPin(pin, salt);
    if (inputHash == hashedPin) {
      await _resetAttempts();
      return true;
    } else {
      await _incrementAttempts();
      return false;
    }
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }

  Future<int> _getAttempts() async {
    final val = await _storage.read(key: _attemptsKey);
    return int.tryParse(val ?? '0') ?? 0;
  }

  Future<void> _incrementAttempts() async {
    final attempts = await _getAttempts();
    await _storage.write(key: _attemptsKey, value: (attempts + 1).toString());
  }

  Future<void> _resetAttempts() async {
    await _storage.write(key: _attemptsKey, value: '0');
  }

  Future<bool> isLocked() async {
    final attempts = await _getAttempts();
    return attempts >= _maxAttempts;
  }
}
