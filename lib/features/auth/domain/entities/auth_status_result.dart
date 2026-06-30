
import '../entities/user_profile.dart';

enum AuthStatusResult {
  initial,
  authenticatedAdmin,
  authenticatedDriver,
  unauthenticated,
  needsSubscription,
  noAccess,
}

class CheckAuthStatusResult {
  final AuthStatusResult status;
  final String? error;
  final String? userRole;
  final String? deviceId;
  final UserProfile? userProfile;

  CheckAuthStatusResult({
    required this.status,
    this.error,
    this.userRole,
    this.deviceId,
    this.userProfile,
  });
}
