import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_auth_repository.dart';

class ResetPasswordParams {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

@injectable
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final UserAuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await _repository.resetPassword(
      email: params.email,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}
