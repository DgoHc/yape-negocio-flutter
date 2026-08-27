import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [PaymentsTable, DevicesTable, SyncQueueTable, SecondaryNumbersTable, UserProfilesTable],
  daos: [PaymentDao, DeviceDao, SyncDao, SecondaryNumberDao, UserProfileDao],
)
@lazySingleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(userProfilesTable);
          }
          if (from < 3) {
            await m.addColumn(userProfilesTable, userProfilesTable.uuid);
          }
          if (from < 4) {
            await m.deleteTable(userProfilesTable.actualTableName);
            await m.createTable(userProfilesTable);
          }
          if (from < 5) {
            await m.deleteTable(userProfilesTable.actualTableName);
            await m.createTable(userProfilesTable);
          }
          if (from < 6) {
            await m.addColumn(userProfilesTable, userProfilesTable.businessType);
          }
          if (from < 7) {
            await m.addColumn(userProfilesTable, userProfilesTable.notificationCode);
          }
          if (from < 8) {
            await m.addColumn(paymentsTable, paymentsTable.operationNumber);
            await m.addColumn(paymentsTable, paymentsTable.rawText);
          }
        },
      );
}

@DriftAccessor(tables: [PaymentsTable])
class PaymentDao extends DatabaseAccessor<AppDatabase> with _$PaymentDaoMixin {
  PaymentDao(super.db);

  Future<List<Payment>> getAllPayments() => select(paymentsTable).get();
  Stream<List<Payment>> watchRecentPayments() => 
      (select(paymentsTable)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();
  Future<int> insertPayment(PaymentsTableCompanion payment) => into(paymentsTable).insert(payment);
  Future<int> markAsSynced(String externalId) => 
      (update(paymentsTable)..where((t) => t.externalId.equals(externalId)))
          .write(const PaymentsTableCompanion(isSynced: Value(true)));
  
  Future<int> deleteOldPayments(DateTime before) =>
      (delete(paymentsTable)..where((t) => t.createdAt.isSmallerThanValue(before))).go();

  Future<void> deleteAllPayments() => delete(paymentsTable).go();
}

@DriftAccessor(tables: [DevicesTable])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Future<Device?> getDeviceByUuid(String uuid) => 
      (select(devicesTable)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  Future<int> upsertDevice(DevicesTableCompanion device) => 
      into(devicesTable).insertOnConflictUpdate(device);
}

@DriftAccessor(tables: [SyncQueueTable])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<List<SyncQueueTableData>> getPendingSyncs() => (select(syncQueueTable)
        ..where((t) => t.status.equals('pending') | t.status.equals('failed'))
        ..where((t) => t.retryCount.isSmallerThanValue(3))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
      .get();

  Future<int> insertToQueue(SyncQueueTableCompanion entry) =>
      into(syncQueueTable).insert(entry);

  Future<bool> updateSyncStatus(int id, String status, {int? retryCount}) {
    return (update(syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(
        status: Value(status),
        retryCount: retryCount != null ? Value(retryCount) : const Value.absent(),
        lastAttemptAt: Value(DateTime.now()),
      ),
    ).then((value) => value > 0);
  }

  Future<void> deleteSynced(int id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [SecondaryNumbersTable])
class SecondaryNumberDao extends DatabaseAccessor<AppDatabase> with _$SecondaryNumberDaoMixin {
  SecondaryNumberDao(super.db);

  Future<List<SecondaryNumbersTableData>> getAll() => select(secondaryNumbersTable).get();

  Future<int> insertNumber(SecondaryNumbersTableCompanion entry) =>
      into(secondaryNumbersTable).insert(entry);

  Future<int> deleteNumber(int id) =>
      (delete(secondaryNumbersTable)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [UserProfilesTable])
class UserProfileDao extends DatabaseAccessor<AppDatabase> with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<UserProfile?> getProfile() => select(userProfilesTable).getSingleOrNull();
  Future<List<UserProfile>> getAllProfiles() => select(userProfilesTable).get();
  Future<UserProfile?> getProfileById(String id) =>
      (select(userProfilesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<UserProfile?> findProfileByEmail(String email) =>
      (select(userProfilesTable)..where((t) => t.email.equals(email))).getSingleOrNull();
  Future<int> upsertProfile(UserProfilesTableCompanion profile) =>
      into(userProfilesTable).insertOnConflictUpdate(profile);
  Future<void> deleteProfile() => delete(userProfilesTable).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yape_transporte.db'));
    return NativeDatabase.createInBackground(file);
  });
}
