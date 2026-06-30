
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_auth_repository.dart';

@injectable
class UpdateProfileUseCase
    implements UseCase<UserProfile, UpdateProfileParams> {
  final UserAuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(
    UpdateProfileParams params,
  ) {
    return _repository.updateProfile(
      name: params.name,
      phone: params.phone,
      businessType: params.businessType,
    );
  }
}

class UpdateProfileParams {
  final String? name;
  final String? phone;
  final String? businessType; // Rubro: transporte, librería, etc.

  UpdateProfileParams({
    this.name,
    this.phone,
    this.businessType,
  });
}
