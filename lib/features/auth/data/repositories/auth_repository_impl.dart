
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure/token_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remote_data_source/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;
  final Dio _dio;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenManager, this._dio);

  @override
  Future<Either<Failure, String>> loginAdmin(String username, String pin) async {
    final result = await _remoteDataSource.loginAdmin(username, pin);
    return result.fold(
      (failure) => Left(failure),
      (token) async {
        await _tokenManager.saveToken(token);
        return Right(token);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> checkDeviceStatus(String uuid) async {
    return await _remoteDataSource.checkDeviceStatus(uuid);
  }

  @override
  Future<Either<Failure, void>> registerDevice(Map<String, dynamic> deviceInfo) async {
    return await _remoteDataSource.registerDevice(deviceInfo);
  }

  @override
  Future<Either<Failure, void>> unapproveDevice(String uuid) async {
    return await _remoteDataSource.unapproveDevice(uuid);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDevices() async {
    try {
      final response = await _dio.get('/admin/devices');
      return Right(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDevice(String id, {bool? isApproved, String? status, String? alias}) async {
    try {
      await _dio.patch(
        '/admin/devices/$id',
        data: {
          if (isApproved != null) 'isApproved': isApproved,
          if (status != null) 'status': status,
          if (alias != null) 'alias': alias,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDevice(String id) async {
    try {
      await _dio.delete('/admin/devices/$id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return Right(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(String username, String pin, String role) async {
    try {
      await _dio.post(
        '/admin/users',
        data: {'username': username, 'pin': pin, 'role': role},
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(String id, {String? role, String? status}) async {
    try {
      await _dio.patch(
        '/admin/users/$id',
        data: {
          if (role != null) 'role': role,
          if (status != null) 'status': status,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String id) async {
    try {
      await _dio.delete('/admin/users/$id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> adminRegisterDevice(String uuid, String alias, String? phoneNumber) async {
    try {
      await _dio.post(
        '/admin/devices',
        data: {
          'uuid': uuid,
          'alias': alias,
          'phoneNumber': phoneNumber,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
