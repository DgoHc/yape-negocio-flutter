import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../utils/app_logger.dart';

@lazySingleton
class TokenManager {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';

  TokenManager(this._storage);

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      AppLogger.e('Critical error writing token, wiping storage', e);
      await _storage.deleteAll();
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      // Este catch captura el famoso BAD_DECRYPT de Android
      AppLogger.e('BAD_DECRYPT detected. Secure storage is corrupted. Wiping...', e);
      await _storage.deleteAll(); // Borrado nuclear para resetear el Keystore
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      AppLogger.w('Token format is invalid, treating as unauthenticated.');
      return false;
    }
  }

  Future<DateTime?> getExpirationDate() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserRole() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['role'] as String?;
    } catch (e) {
      AppLogger.e('Error decoding token role', e);
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      await _storage.deleteAll();
    }
  }
}
