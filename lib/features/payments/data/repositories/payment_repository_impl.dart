
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
import '../../../../core/storage/drift/app_database.dart' as db;
import '../../domain/repositories/payment_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../remote_data_source/payment_remote_data_source.dart';
import '../local_data_source/payment_local_data_source.dart';
import '../mappers/payment_mapper.dart';
import '../dtos/payment_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/data/mappers/user_profile_mapper.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../../auth/data/models/auth_models.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final PaymentLocalDataSource localDataSource;
  final ConnectivityBloc connectivityBloc;
  final NotificationPlatformService notificationService;
  final TtsService ttsService;
  final db.SecondaryNumberDao secondaryNumberDao;
  final db.SyncDao syncDao;
  final db.UserProfileDao userProfileDao;
  final SharedPreferences prefs;
  final _paymentController = StreamController<PaymentData>.broadcast();
  final _rawNotificationController = StreamController<String>.broadcast();

  PaymentRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.connectivityBloc,
    this.notificationService,
    this.ttsService,
    this.secondaryNumberDao,
    this.syncDao,
    this.userProfileDao,
    this.prefs,
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
        // 1. Verificar si la detección está habilitada globalmente
        final isDetectionEnabled = prefs.getBool('detection_enabled') ?? true;
        if (!isDetectionEnabled) {
          AppLogger.d('PaymentRepository: Detección desactivada por el usuario.');
          return;
        }

        // 2. Verificar si el usuario tiene acceso (Plan o Prueba activa)
        final profileModel = await userProfileDao.getProfile();
        if (profileModel == null) return;
        
        final profile = UserProfileMapper.fromModel(UserProfileModel.fromDb(profileModel));
        if (!profile.hasAccess) {
          AppLogger.w('PaymentRepository: El usuario no tiene acceso activo (Plan expirado). Bloqueando detección propia.');
          return;
        }

        AppLogger.d('PaymentRepository: Payload recibido de nativo: $payload');

        final pkg = payload['debugPackage'] ?? 'Desconocido';
        final title = payload['debugTitle'] ?? '';
        final body = payload['debugBody'] ?? '';

        _rawNotificationController.add("App: $pkg\nTítulo: $title\nCuerpo: $body");

        String contentToParse = payload['rawBody'] as String? ?? body;
        AppLogger.d('PaymentRepository: contentToParse = "$contentToParse"');

        if (contentToParse.isEmpty) {
          AppLogger.w('PaymentRepository: Notificación vacía, ignorando.');
          return;
        }

        AppLogger.d('PaymentRepository: Intentando parsear contenido: "$contentToParse"');
        var result = PaymentParser.parse(contentToParse);
        AppLogger.i('PaymentRepository: result.isRight() = ${result.isRight()}');

        if (result.isLeft() && title.isNotEmpty) {
          AppLogger.d('PaymentRepository: Falló cuerpo, intentando con título: "$title"');
          result = PaymentParser.parse(title);
          AppLogger.d('PaymentRepository: result después de título: ${result.isRight()}');
        }

        result.fold(
          (failure) => AppLogger.e('PaymentRepository: No se pudo procesar el pago: ${failure.message}'),
          (payment) async {
            AppLogger.i('PaymentRepository: ¡PAGO VÁLIDO DETECTADO! Guardando...');
            await savePayment(payment);
            AppLogger.i('PaymentRepository: Pago guardado.');
            _paymentController.add(payment);
            AppLogger.i('PaymentRepository: Pago agregado a controller.');
            
            final isMuted = prefs.getBool('is_muted') ?? false;
            ttsService.speak(
              "${payment.senderName} envió ${payment.amount} soles",
              isMuted: isMuted,
            );

            AppLogger.i('PaymentRepository: TTS llamado.');
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
          "_Enviado automáticamente por Yape Transporte_";

      for (final number in secondaryNumbers) {
        if (number.type == 'whatsapp') {
          // Limpiar el número de espacios, guiones, etc.
          final cleanPhone = number.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          final url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");
          
          AppLogger.i('Abriendo WhatsApp para: $cleanPhone');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            // Esperar un poco antes del siguiente para no saturar el sistema
            await Future.delayed(const Duration(seconds: 2));
          } else {
            AppLogger.w('No se pudo abrir WhatsApp para el número: $cleanPhone');
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
          final dto = PaymentMapper.toDto(payment, externalId);
          await remoteDataSource.createPayment(dto);
          await localDataSource.markAsSynced(externalId);
        } catch (e) {
          AppLogger.w('Failed to sync payment immediately, enqueued: $e');
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
      })),
      status: const Value('pending'),
    );
    await syncDao.insertToQueue(syncEntry);
  }

  @override
  Future<Either<Failure, void>> syncPayments() async {
    try {
      final pending = await syncDao.getPendingSyncs();

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
          ));

          await localDataSource.markAsSynced(externalId);
          await syncDao.deleteSynced(entry.id);
        } catch (e) {
          AppLogger.w('Failed to sync payment, trying again later: $e');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

