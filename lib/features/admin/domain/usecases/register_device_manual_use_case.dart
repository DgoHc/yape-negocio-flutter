import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class RegisterDeviceManualParams {
  final String uuid;
  final String alias;
  final String? phoneNumber;

  RegisterDeviceManualParams({
    required this.uuid,
    required this.alias,
    this.phoneNumber,
  });
}

@lazySingleton
class RegisterDeviceManualUseCase extends UseCase<void, RegisterDeviceManualParams> {
  final AdminRepository _repository;

  RegisterDeviceManualUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RegisterDeviceManualParams params) async {
    return await _repository.adminRegisterDevice(
      params.uuid,
      params.alias,
      params.phoneNumber,
    );
  }
}
