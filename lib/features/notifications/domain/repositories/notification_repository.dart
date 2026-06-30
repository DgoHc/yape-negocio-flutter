
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_link_entities.dart';

abstract class NotificationRepository {
  Future<Either<Failure, String>> getMyNotificationCode();
  Future<Either<Failure, Map<String, dynamic>>> findUserByCode(String code);
  Future<Either<Failure, LinkRequest>> sendLinkRequest(String code);
  Future<Either<Failure, List<LinkRequest>>> getLinkRequests();
  Future<Either<Failure, void>> acceptLinkRequest(String requestId);
  Future<Either<Failure, void>> rejectLinkRequest(String requestId);
  Future<Either<Failure, List<UserLink>>> getLinkedUsers();
  Future<Either<Failure, UserLink>> updateLink(String linkId, String? alias, String? status);
  Future<Either<Failure, void>> deleteLink(String linkId);
  Future<Either<Failure, void>> registerFcmToken(String token, String? deviceId, String? deviceName);
}
