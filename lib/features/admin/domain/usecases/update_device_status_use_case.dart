import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateDeviceStatusParams {
  final String id;
  final bool? isApproved;
  final String? status;
  final String? alias;

  UpdateDeviceStatusParams({required this.id, this.isApproved, this.status, this.alias});
}

@lazySingleton
class UpdateDeviceStatusUseCase extends UseCase<void, UpdateDeviceStatusParams> {
  final AdminRepository _repository;

  UpdateDeviceStatusUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateDeviceStatusParams params) async {
    return await _repository.updateDevice(
      params.id,
      isApproved: params.isApproved,
      status: params.status,
      alias: params.alias,
    );
  }
}
