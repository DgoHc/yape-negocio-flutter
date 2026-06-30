import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/export_service.dart';
import '../../../auth/domain/entities/user_profile.dart';

class ExportAdminDataParams {
  final List<UserProfile> userProfiles;
  final List<Map<String, dynamic>> devices;

  ExportAdminDataParams({
    required this.userProfiles,
    required this.devices,
  });
}

@lazySingleton
class ExportAdminDataUseCase extends UseCase<void, ExportAdminDataParams> {
  final ExportService _exportService;

  ExportAdminDataUseCase(this._exportService);

  @override
  Future<Either<Failure, void>> call(ExportAdminDataParams params) async {
    try {
      await _exportService.exportAdminDataToExcel(
        userProfiles: params.userProfiles,
        devices: params.devices,
      );
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
