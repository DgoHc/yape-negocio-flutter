import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateUserParams {
  final String id;
  final String? role;
  final String? status;

  UpdateUserParams({
    required this.id,
    this.role,
    this.status,
  });
}

@lazySingleton
class UpdateUserUseCase extends UseCase<void, UpdateUserParams> {
  final AdminRepository _repository;

  UpdateUserUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserParams params) async {
    return await _repository.updateUser(
      params.id,
      role: params.role,
      status: params.status,
    );
  }
}
