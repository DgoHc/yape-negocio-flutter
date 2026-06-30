import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/remember_me_repository.dart';

@Injectable(as: RememberMeRepository)
class RememberMeRepositoryImpl implements RememberMeRepository {
  final SharedPreferences _prefs;
  static const String _key = 'remembered_email';

  RememberMeRepositoryImpl(this._prefs);

  @override
  Future<void> saveEmail(String email) async {
    await _prefs.setString(_key, email);
  }

  @override
  Future<String?> getEmail() async {
    return _prefs.getString(_key);
  }

  @override
  Future<void> clearEmail() async {
    await _prefs.remove(_key);
  }
}
