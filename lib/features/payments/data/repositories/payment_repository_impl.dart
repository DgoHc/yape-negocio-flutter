import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/drift/app_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../connectivity/presentation/bloc/connectivity_bloc.dart';
import '../../../connectivity/presentation/bloc/connectivity_state.dart';
import '../../../notifications/data/notification_platform_service.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../../../notifications/domain/parsers/payment_parser.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/storage/drift/app_database.dart' as db;
import '../../domain/repositories/payment_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../remote_data_source/payment_remote_data_source.dart';
import '../local_data_source/payment_local_data_source.dart';
import '../mappers/payment_mapper.dart';
import '../dtos/payment_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/data/mappers/user_profile_mapper.dart';
import '../../../auth/data/models/auth_models.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final PaymentLocalDataSource localDataSource;
  final ConnectivityBloc connectivityBloc;
  final NotificationPlatformService notificationService;
  final TtsService ttsService;
  final db.PaymentDao paymentDao;
  final db.SecondaryNumberDao secondaryNumberDao;
  final db.SyncDao syncDao;
  final db.UserProfileDao userProfileDao;
  final SharedPreferences prefs;
  final DeviceInfoService deviceInfoService;
  final _paymentController = StreamController<PaymentData>.broadcast();
  final _rawNotificationController = StreamController<String>.broadcast();

  PaymentRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.connectivityBloc,
    this.notificationService,
    this.ttsService,
    this.paymentDao,
    this.secondaryNumberDao,
    this.syncDao,
    this.userProfileDao,
    this.prefs,
    this.deviceInfoService,
  ) {
    _initNotificationListener();
  }

  @override
  Stream<PaymentData> get onPaymentReceived => _paymentController.stream;

  @override
  Stream<String> get onRawNotificationReceived => _rawNotificationController.stream;

  void _initNotificationListener() {
    AppLogger.i('PaymentRepository: Iniciando escucha de notificaciones...');
    notificationService.notificationStream.listen(
      (payload) async {
        final isDetectionEnabled = prefs.getBool('detection_enabled') ?? true;
        if (!isDetectionEnabled) return;

        final profileModel = await userProfileDao.getProfile();
        if (profileModel == null) return;
        
        final profile = UserProfileMapper.fromModel(UserProfileModel.fromDb(profileModel));
        if (!profile.hasAccess) return;

        final pkg = payload['packageName'] ?? payload['debugPackage'] ?? 'Desconocido';
        final title = payload['rawTitle'] ?? payload['debugTitle'] ?? '';
        final body = payload['rawBody'] ?? payload['debugBody'] ?? '';
        final scraped = payload['scrapedContent'] as String?;

        _rawNotificationController.add("App: $pkg\nTítulo: $title\nCuerpo: $body${scraped != null ? '\nScraped: $scraped' : ''}");

        String contentToParse = payload['rawBody'] as String? ?? scraped ?? body;
        if (contentToParse.isEmpty) return;

        var result = PaymentParser.parse(contentToParse);
        if (result.isLeft() && title.isNotEmpty) {
          result = PaymentParser.parse(title);
        }

        result.fold(
          (failure) => AppLogger.e('PaymentRepository: No se pudo procesar el pago: ${failure.message}'),
          (payment) async {
            await savePayment(payment);
            _paymentController.add(payment);
            
            final isMuted = prefs.getBool('is_muted') ?? false;
            ttsService.speak(
              "${payment.senderName} envió ${payment.amount} soles",
              isMuted: isMuted,
            );

            await _notifySecondaryNumbers(payment);
          },
        );
      },
      onError: (error) {
        AppLogger.e('PaymentRepository: Error en el stream de notificaciones', error);
      },
    );
  }

  Future<void> _notifySecondaryNumbers(PaymentData payment) async {
    try {
      final secondaryNumbers = await secondaryNumberDao.getAll();
      if (secondaryNumbers.isEmpty) return;

      final message = "✅ *Nuevo Pago Detectado*\n\n"
          "👤 *De:* ${payment.senderName}\n"
          "💰 *Monto:* ${payment.currency} ${payment.amount.toStringAsFixed(2)}\n"
          "🕒 *Hora:* ${payment.parsedAt.hour}:${payment.parsedAt.minute.toString().padLeft(2, '0')}\n\n"
          "_Enviado automáticamente por SonoPay_";

      for (final number in secondaryNumbers) {
        if (number.type == 'whatsapp') {
          final cleanPhone = number.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          final url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    } catch (e) {
      AppLogger.e('Error notifying secondary numbers', e);
    }
  }

  @override
  Future<Either<Failure, List<PaymentData>>> getPayments() async {
    try {
      final modelPayments = await localDataSource.getAllPayments();
      final domainPayments = modelPayments.map((m) => PaymentMapper.fromModel(m)).toList();
      return Right(domainPayments);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePayment(PaymentData payment) async {
    try {
      final externalId = DateTime.now().millisecondsSinceEpoch.toString();
      final model = PaymentMapper.toModel(payment, externalId, false);
      await localDataSource.savePayment(model);

      if (connectivityBloc.state.status == ConnectivityStatus.connected) {
        try {
          final deviceId = await deviceInfoService.getDeviceUUID() ?? '';
          final dto = PaymentMapper.toDto(payment, externalId, deviceId);
          await remoteDataSource.createPayment(dto);
          await localDataSource.markAsSynced(externalId);
        } catch (e) {
          await _addToSyncQueue(externalId, payment);
        }
      } else {
        await _addToSyncQueue(externalId, payment);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<void> _addToSyncQueue(String externalId, PaymentData payment) async {
    final syncEntry = SyncQueueTableCompanion(
      actionType: const Value('payment_sync'),
      payload: Value(jsonEncode({
        'senderName': payment.senderName,
        'amount': payment.amount,
        'currency': payment.currency,
        'createdAt': payment.parsedAt.toIso8601String(),
        'externalId': externalId,
        'operationNumber': payment.operationNumber,
        'rawText': payment.rawText,
      })),
      status: const Value('pending'),
    );
    await syncDao.insertToQueue(syncEntry);
  }

  @override
  Future<Either<Failure, void>> clearOldPayments(int days) async {
    if (days <= 0) return const Right(null);
    try {
      final before = DateTime.now().subtract(Duration(days: days));
      await paymentDao.deleteOldPayments(before);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPayments() async {
    try {
      final pending = await syncDao.getPendingSyncs();
      final deviceId = await deviceInfoService.getDeviceUUID() ?? '';

      for (final entry in pending) {
        try {
          final payload = jsonDecode(entry.payload);
          final externalId = payload['externalId'] as String;

          await remoteDataSource.createPayment(PaymentDto(
            senderName: payload['senderName'] as String,
            amount: (payload['amount'] as num).toDouble(),
            currency: payload['currency'] as String,
            externalId: externalId,
            createdAt: DateTime.parse(payload['createdAt'] as String),
            operationNumber: payload['operationNumber'] as String?,
            rawText: payload['rawText'] as String?,
            deviceId: deviceId,
          ));

          await localDataSource.markAsSynced(externalId);
          await syncDao.deleteSynced(entry.id);
        } catch (e) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
