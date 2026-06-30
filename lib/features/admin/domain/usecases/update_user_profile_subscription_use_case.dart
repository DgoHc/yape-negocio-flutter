import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateUserProfileSubscriptionParams {
  final String id;
  final bool isSubscribed;

  UpdateUserProfileSubscriptionParams({required this.id, required this.isSubscribed});
}

@lazySingleton
class UpdateUserProfileSubscriptionUseCase extends UseCase<void, UpdateUserProfileSubscriptionParams> {
  final AdminRepository _repository;

  UpdateUserProfileSubscriptionUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileSubscriptionParams params) async {
    return await _repository.updateAppUserSubscription(params.id, params.isSubscribed);
  }
}
