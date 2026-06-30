import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class CreateUserParams {
  final String username;
  final String pin;
  final String role;

  CreateUserParams({
    required this.username,
    required this.pin,
    required this.role,
  });
}

@lazySingleton
class CreateUserUseCase extends UseCase<void, CreateUserParams> {
  final AdminRepository _repository;

  CreateUserUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateUserParams params) async {
    return await _repository.createUser(
      params.username,
      params.pin,
      params.role,
    );
  }
}
