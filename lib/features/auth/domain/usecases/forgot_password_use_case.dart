import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/user_auth_repository.dart';

@injectable
class ForgotPasswordUseCase implements UseCase<void, String> {
  final UserAuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await _repository.forgotPassword(email);
  }
}
