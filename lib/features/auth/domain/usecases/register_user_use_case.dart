
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_auth_repository.dart';

@injectable
class RegisterUserUseCase
    implements
        UseCase<({String token, UserProfile profile}), RegisterUserParams> {
  final UserAuthRepository _repository;

  RegisterUserUseCase(this._repository);

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> call(
    RegisterUserParams params,
  ) {
    return _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phone: params.phone,
      businessType: params.businessType,
    );
  }
}

class RegisterUserParams {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? businessType; // Rubro: transporte, librería, etc.

  RegisterUserParams({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.businessType,
  });
}
