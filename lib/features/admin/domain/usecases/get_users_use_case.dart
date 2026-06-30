import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetUsersUseCase extends UseCase<List<Map<String, dynamic>>, NoParams> {
  final AdminRepository _repository;

  GetUsersUseCase(this._repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) async {
    return await _repository.getUsers();
  }
}
