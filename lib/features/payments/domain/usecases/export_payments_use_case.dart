
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/export_service.dart';
import '../../../notifications/domain/entities/payment_data.dart';

class ExportPaymentsParams {
  final List<PaymentData> payments;
  final DateTime? startDate;
  final DateTime? endDate;

  ExportPaymentsParams({
    required this.payments,
    this.startDate,
    this.endDate,
  });
}

@lazySingleton
class ExportPaymentsUseCase extends UseCase<void, ExportPaymentsParams> {
  final ExportService _exportService;

  ExportPaymentsUseCase(this._exportService);

  @override
  Future<Either<Failure, void>> call(ExportPaymentsParams params) async {
    try {
      await _exportService.exportPaymentsToExcel(
        params.payments,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}

