import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class CheckDeviceStatusUseCase {
  final AuthRepository _repository;

  CheckDeviceStatusUseCase(this._repository);

  Future<Either<Failure, bool>> call(String uuid) {
    return _repository.checkDeviceStatus(uuid);
  }
}
