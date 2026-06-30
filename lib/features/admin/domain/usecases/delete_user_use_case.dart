import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class DeleteUserUseCase extends UseCase<void, String> {
  final AdminRepository _repository;

  DeleteUserUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await _repository.deleteUser(id);
  }
}
