
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../utils/app_logger.dart';

@lazySingleton
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      AppLogger.d('GoogleAuthService: Starting signIn process...');
      // First sign out to ensure we can choose a new account
      await _googleSignIn.signOut();
      // Then sign in to prompt account selection
      final account = await _googleSignIn.signIn();
      if (account == null) {
        AppLogger.w('GoogleAuthService: User cancelled or sign-in failed (account is null)');
      } else {
        AppLogger.d('GoogleAuthService: Sign-in successful: ${account.email}');
      }
      return account;
    } catch (error) {
      AppLogger.e('GoogleAuthService: Error during signIn', error);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.d('GoogleAuthService: Signed out successfully');
    } catch (e) {
      AppLogger.e('GoogleAuthService: Error during signOut', e);
    }
  }
}
