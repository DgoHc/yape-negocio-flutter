
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_link_entities.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mappers/notification_link_mapper.dart';
import '../remote_data_source/notification_remote_data_source.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, String>> getMyNotificationCode() async {
    final result = await _remoteDataSource.getMyNotificationCode();
    return result.map((dto) => dto.code);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> findUserByCode(String code) async {
    return _remoteDataSource.findUserByCode(code);
  }

  @override
  Future<Either<Failure, LinkRequest>> sendLinkRequest(String code) async {
    final result = await _remoteDataSource.sendLinkRequest(code);
    return result.map((dto) => NotificationLinkMapper.fromLinkRequestDto(dto));
  }

  @override
  Future<Either<Failure, List<LinkRequest>>> getLinkRequests() async {
    final result = await _remoteDataSource.getLinkRequests();
    return result.map((list) => list.map((dto) => NotificationLinkMapper.fromLinkRequestDto(dto)).toList());
  }

  @override
  Future<Either<Failure, void>> acceptLinkRequest(String requestId) async {
    return _remoteDataSource.acceptLinkRequest(requestId);
  }

  @override
  Future<Either<Failure, void>> rejectLinkRequest(String requestId) async {
    return _remoteDataSource.rejectLinkRequest(requestId);
  }

  @override
  Future<Either<Failure, List<UserLink>>> getLinkedUsers() async {
    final result = await _remoteDataSource.getLinkedUsers();
    return result.map((list) => list.map((dto) => NotificationLinkMapper.fromUserLinkDto(dto)).toList());
  }

  @override
  Future<Either<Failure, UserLink>> updateLink(String linkId, String? alias, String? status) async {
    final result = await _remoteDataSource.updateLink(linkId, alias, status);
    return result.map((dto) => NotificationLinkMapper.fromUserLinkDto(dto));
  }

  @override
  Future<Either<Failure, void>> deleteLink(String linkId) async {
    return _remoteDataSource.deleteLink(linkId);
  }

  @override
  Future<Either<Failure, void>> registerFcmToken(String token, String? deviceId, String? deviceName) async {
    return _remoteDataSource.registerFcmToken(token, deviceId, deviceName);
  }
}
