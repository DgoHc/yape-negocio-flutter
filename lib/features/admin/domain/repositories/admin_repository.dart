import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getDevices();
  Future<Either<Failure, void>> updateDevice(String id, {bool? isApproved, String? status, String? alias});
  Future<Either<Failure, void>> deleteDevice(String id);
  Future<Either<Failure, void>> adminRegisterDevice(String uuid, String alias, String? phoneNumber);

  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers();
  Future<Either<Failure, void>> createUser(String username, String pin, String role);
  Future<Either<Failure, void>> updateUser(String id, {String? role, String? status});
  Future<Either<Failure, void>> deleteUser(String id);

  Future<Either<Failure, List<Map<String, dynamic>>>> getAppUsers();
  Future<Either<Failure, void>> updateAppUserSubscription(String id, bool isSubscribed);
  Future<Either<Failure, void>> createAppUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
    bool isSubscribed = true,
  });
  Future<Either<Failure, void>> updateAppUser(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? businessType,
    bool? isSubscribed,
    String? subscriptionPlan,
  });
  Future<Either<Failure, void>> deleteAppUser(String id);
}
