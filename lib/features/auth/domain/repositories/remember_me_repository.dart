abstract class RememberMeRepository {
  Future<void> saveEmail(String email);
  Future<String?> getEmail();
  Future<void> clearEmail();
}
