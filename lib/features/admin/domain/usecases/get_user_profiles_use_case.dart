import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/data/dtos/user_profile_dto.dart';
import '../../../auth/data/mappers/user_profile_mapper.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetUserProfilesUseCase extends UseCase<List<UserProfile>, NoParams> {
  final AdminRepository _repository;

  GetUserProfilesUseCase(this._repository);

  @override
  Future<Either<Failure, List<UserProfile>>> call(NoParams params) async {
    final result = await _repository.getAppUsers();
    return result.map((list) {
      return list.map((json) {
        final dto = UserProfileDto.fromJson(json);
        return UserProfileMapper.fromDto(dto);
      }).toList();
    });
  }
}
