import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';

class NetworkConfigService {
  final SharedPreferences _prefs;

  static const String _baseUrlKey = 'base_url';

  NetworkConfigService(this._prefs);

  Future<String> autoDetectBaseUrl() async {
    return EnvConfig.baseUrl;
  }

  Future<String> getBaseUrl() async {
    final savedUrl = _prefs.getString(_baseUrlKey);
    final finalUrl = savedUrl ?? EnvConfig.baseUrl;
    return finalUrl;
  }

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_baseUrlKey, url);
  }

  Future<void> resetToAuto() async {
    await _prefs.remove(_baseUrlKey);
  }
}
