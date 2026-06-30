import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_auth_repository.dart';
import '../repositories/user_profile_repository.dart';

class ActivateSubscriptionParams {
  final UserProfile profile;

  ActivateSubscriptionParams({required this.profile});
}

@injectable
class ActivateSubscriptionUseCase implements UseCase<UserProfile, ActivateSubscriptionParams> {
  final UserAuthRepository _authRepository;
  final UserProfileRepository _profileRepository;

  ActivateSubscriptionUseCase(this._authRepository, this._profileRepository);

  @override
  Future<Either<Failure, UserProfile>> call(ActivateSubscriptionParams params) async {
    final result = await _authRepository.activateSubscription(params.profile);
    
    return await result.fold(
      (failure) async => Left(failure),
      (updatedProfile) async {
        await _profileRepository.saveProfile(updatedProfile);
        return Right(updatedProfile);
      },
    );
  }
}
