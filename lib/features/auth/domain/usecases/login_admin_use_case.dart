import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginAdminUseCase {
  final AuthRepository _repository;

  LoginAdminUseCase(this._repository);

  Future<Either<Failure, String>> call(String username, String pin) {
    return _repository.loginAdmin(username, pin);
  }
}
