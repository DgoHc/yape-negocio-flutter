
import 'package:injectable/injectable.dart';
import '../../../../core/storage/drift/app_database.dart';
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
    return await db.paymentDao.insertPayment(model.toDbCompanion());
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
