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
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      AppLogger.e('Error reading secure token (possible BAD_DECRYPT). Clearing token.', e);
      await deleteToken();
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      AppLogger.e('Invalid token format', e);
      return false;
    }
  }

  Future<DateTime?> getExpirationDate() async {
    final token = await getToken();
    if (token == null) return null;
    return JwtDecoder.getExpirationDate(token);
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
    await _storage.delete(key: _tokenKey);
  }
}
