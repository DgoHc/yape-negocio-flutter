import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/admin_repository.dart';
import '../remote_data_source/admin_remote_data_source.dart';

@Injectable(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDevices() async {
    try {
      final devices = await _remoteDataSource.getDevices();
      return Right(devices);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDevice(String id, {bool? isApproved, String? status, String? alias}) async {
    try {
      await _remoteDataSource.updateDevice(id, isApproved: isApproved, status: status, alias: alias);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDevice(String id) async {
    try {
      await _remoteDataSource.deleteDevice(id);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> adminRegisterDevice(String uuid, String alias, String? phoneNumber) async {
    try {
      await _remoteDataSource.adminRegisterDevice(uuid, alias, phoneNumber);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers() async {
    try {
      final users = await _remoteDataSource.getUsers();
      return Right(users);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(String username, String pin, String role) async {
    try {
      await _remoteDataSource.createUser(username, pin, role);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(String id, {String? role, String? status}) async {
    try {
      await _remoteDataSource.updateUser(id, role: role, status: status);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAppUsers() async {
    try {
      final users = await _remoteDataSource.getAppUsers();
      return Right(users);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppUserSubscription(String id, bool isSubscribed) async {
    try {
      await _remoteDataSource.updateAppUserSubscription(id, isSubscribed);
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
