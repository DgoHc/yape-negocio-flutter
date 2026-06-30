import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> loginAdmin(String username, String pin);
  Future<Either<Failure, bool>> checkDeviceStatus(String uuid);
  Future<Either<Failure, void>> registerDevice(Map<String, dynamic> deviceInfo);
  Future<Either<Failure, void>> unapproveDevice(String uuid);
  Future<Either<Failure, List<Map<String, dynamic>>>> getDevices();
  Future<Either<Failure, void>> updateDevice(String id, {bool? isApproved, String? status, String? alias});
  Future<Either<Failure, void>> deleteDevice(String id);
  Future<Either<Failure, void>> adminRegisterDevice(String uuid, String alias, String? phoneNumber);

  // User Management
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers();
  Future<Either<Failure, void>> createUser(String username, String pin, String role);
  Future<Either<Failure, void>> updateUser(String id, {String? role, String? status});
  Future<Either<Failure, void>> deleteUser(String id);
}
