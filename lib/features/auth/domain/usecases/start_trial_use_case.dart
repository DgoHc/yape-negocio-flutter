
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_auth_repository.dart';

@injectable
class StartTrialUseCase implements UseCase<UserProfile, NoParams> {
  final UserAuthRepository _repository;

  StartTrialUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) {
    return _repository.startTrial();
  }
}
