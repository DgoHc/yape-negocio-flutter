import 'package:injectable/injectable.dart';
import '../../../../core/storage/drift/app_database.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/payment_models.dart';

abstract class PaymentLocalDataSource {
  Future<List<PaymentModel>> getAllPayments();
  Future<int> savePayment(PaymentModel model);
  Future<int> markAsSynced(String externalId);
  Stream<List<PaymentModel>> watchRecentPayments();
}

@LazySingleton(as: PaymentLocalDataSource)
class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final AppDatabase db;

  PaymentLocalDataSourceImpl(this.db);

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    final dbPayments = await db.paymentDao.getAllPayments();
    return dbPayments.map((p) => PaymentModel.fromDb(p)).toList();
  }

  @override
  Future<int> savePayment(PaymentModel model) async {
    final existing = await db.paymentDao.getAllPayments();
    final isDuplicate = existing.any((p) {
      final sameExternalId = p.externalId.isNotEmpty && p.externalId == model.externalId;
      final sameSender = p.senderName.trim().toLowerCase() == model.senderName.trim().toLowerCase();
      final sameAmount = (p.amount - model.amount).abs() < 0.01;
      final sameTime = p.createdAt.difference(model.createdAt).inSeconds.abs() < 60; // 60s de protección anti-duplicado por sincronización
      return sameExternalId || (sameSender && sameAmount && sameTime);
    });

    if (isDuplicate) {
      AppLogger.w('PaymentLocalDataSource: Ignorando duplicado de pago idéntico en menos de 60s para ${model.senderName} S/ ${model.amount}');
      return 0;
    }

    final id = await db.paymentDao.insertPayment(model.toDbCompanion());
    AppLogger.i('PaymentLocalDataSource: Pago guardado exitosamente en SQLite [id=$id, sender=${model.senderName}, amount=${model.amount}]');
    return id;
  }

  @override
  Future<int> markAsSynced(String externalId) async {
    return await db.paymentDao.markAsSynced(externalId);
  }

  @override
  Stream<List<PaymentModel>> watchRecentPayments() async* {
    final stream = db.paymentDao.watchRecentPayments();
    yield* stream.map((list) => list.map((p) => PaymentModel.fromDb(p)).toList());
  }
}
