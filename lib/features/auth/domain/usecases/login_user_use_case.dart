
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_auth_repository.dart';

@injectable
class LoginUserUseCase
    implements UseCase<({String token, UserProfile profile}), LoginUserParams> {
  final UserAuthRepository _repository;

  LoginUserUseCase(this._repository);

  @override
  Future<Either<Failure, ({String token, UserProfile profile})>> call(
    LoginUserParams params,
  ) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginUserParams {
  final String email;
  final String password;

  LoginUserParams({
    required this.email,
    required this.password,
  });
}
