import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class GoogleAuthService {
  // ID Web Maestro del nuevo proyecto
  static const String _webId = '755217691056-9kdndpota25tk2b177t5mi0gitl2e6a7.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webId, // VOLVEMOS A PONERLO: Es obligatorio para ID Tokens en producción
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      AppLogger.i('GoogleAuthService: Iniciando sesión en Producción (Vínculo Play)...');
      
      // Limpieza total
      await _googleSignIn.signOut();
      
      final account = await _googleSignIn.signIn();
      
      if (account != null) {
        // Verificamos que obtuvimos la autenticación correctamente
        final auth = await account.authentication;
        if (auth.idToken == null) {
          AppLogger.w('GoogleAuthService: Advertencia - ID Token no recibido.');
        } else {
          AppLogger.i('GoogleAuthService: Token recibido con éxito.');
        }
      }
      return account;
    } catch (error) {
      AppLogger.e('GoogleAuthService: Error 10 persistente: $error');
      throw Exception(error.toString());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
