
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure/token_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_auth_repository.dart';
import '../remote_data_source/auth_remote_data_source.dart';
import '../mappers/user_profile_mapper.dart';

@Injectable(as: UserAuthRepository)
class UserAuthRepositoryImpl implements UserAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;

  UserAuthRepositoryImpl(this._remoteDataSource, this._tokenManager);

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType, // Rubro: transporte, librería, etc.
  }) async {
    final result = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      businessType: businessType,
    );

    return await result.fold(
      (failure) async => Left(failure),
      (data) async {
        await _tokenManager.saveToken(data.token);
        final profile = UserProfileMapper.fromDto(data.profile);
        return Right((token: data.token, profile: profile));
      },
    );
  }

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    return await result.fold(
      (failure) async => Left(failure),
      (data) async {
        await _tokenManager.saveToken(data.token);
        final profile = UserProfileMapper.fromDto(data.profile);
        return Right((token: data.token, profile: profile));
      },
    );
  }

  @override
  Future<Either<Failure, UserProfile>> startTrial() async {
    final result = await _remoteDataSource.startTrial();

    return result.fold(
      (failure) => Left(failure),
      (profileDto) => Right(UserProfileMapper.fromDto(profileDto)),
    );
  }

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    final result = await _remoteDataSource.getProfile();

    return result.fold(
      (failure) => Left(failure),
      (profileDto) => Right(UserProfileMapper.fromDto(profileDto)),
    );
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? phone,
    String? businessType,
  }) async {
    final result = await _remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      businessType: businessType,
    );

    return result.fold(
      (failure) => Left(failure),
      (profileDto) => Right(UserProfileMapper.fromDto(profileDto)),
    );
  }

  @override
  Future<Either<Failure, UserProfile>> activateSubscription(UserProfile profile) async {
    final result = await _remoteDataSource.activateSubscription(UserProfileMapper.toDto(profile));

    return result.fold(
      (failure) => Left(failure),
      (profileDto) => Right(UserProfileMapper.fromDto(profileDto)),
    );
  }

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final result = await _remoteDataSource.verifyEmail(email: email, code: code);
    return await result.fold(
      (failure) async => Left(failure),
      (data) async {
        await _tokenManager.saveToken(data.token);
        final profile = UserProfileMapper.fromDto(data.profile);
        return Right((token: data.token, profile: profile));
      },
    );
  }

  @override
  Future<Either<Failure, void>> resendOtp(String email) async {
    return await _remoteDataSource.resendOtp(email);
  }

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> googleLogin({
    required String email,
    required String name,
    required String googleId,
  }) async {
    final result = await _remoteDataSource.googleLogin(email: email, name: name, googleId: googleId);
    return await result.fold(
      (failure) async => Left(failure),
      (data) async {
        await _tokenManager.saveToken(data.token);
        final profile = UserProfileMapper.fromDto(data.profile);
        return Right((token: data.token, profile: profile));
      },
    );
  }
}
