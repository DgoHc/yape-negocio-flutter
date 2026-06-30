import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterDeviceUseCase {
  final AuthRepository _repository;

  RegisterDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> deviceInfo) {
    return _repository.registerDevice(deviceInfo);
  }
}
