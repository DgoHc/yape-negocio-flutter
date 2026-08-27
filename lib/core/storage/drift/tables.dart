import 'package:drift/drift.dart';

@DataClassName('Payment')
class PaymentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique()(); // ID único generado
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('S/'))();
  TextColumn get senderName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get operationNumber => text().nullable()(); // Número de operación extraído
  TextColumn get rawText => text().nullable()(); // Texto original de la notificación
}

@DataClassName('Device')
class DevicesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get alias => text()();
  BoolColumn get isApproved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
}

class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actionType => text()(); // 'payment_sync', 'device_reg'
  TextColumn get payload => text()(); // JSON data
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, processing, done, failed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SecondaryNumbersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phoneNumber => text()();
  TextColumn get type => text().withDefault(const Constant('whatsapp'))(); // whatsapp, telegram
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserProfile')
class UserProfilesTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get id => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get uuid => text().nullable()(); // UUID del dispositivo
  TextColumn get businessType => text().nullable()(); // Rubro: transporte, librería, etc.
  TextColumn get notificationCode => text().nullable()(); // Código único para vinculación de notificaciones
  DateTimeColumn get trialStartDate => dateTime().nullable()();
  DateTimeColumn get trialEndDate => dateTime().nullable()();
  DateTimeColumn get subscriptionStartDate => dateTime().nullable()();
  DateTimeColumn get subscriptionEndDate => dateTime().nullable()();
  BoolColumn get isSubscribed => boolean().withDefault(const Constant(false))();
  TextColumn get subscriptionPlan => text().nullable()(); // 'basic' o 'premium'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
