
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:injectable/injectable.dart';
import '../../features/notifications/domain/entities/payment_data.dart';
import '../../features/auth/domain/entities/user_profile.dart';

@lazySingleton
class ExportService {
  Future<void> exportPaymentsToExcel(
    List<PaymentData> payments, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var paymentsToExport = payments;
    
    if (startDate != null && endDate != null) {
      paymentsToExport = payments.where((p) {
        return p.parsedAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
               p.parsedAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    final excel = Excel.createExcel();
    final sheet = excel['Pagos'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Fecha');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Remitente');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Monto');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Moneda');

    // Rows
    for (int i = 0; i < paymentsToExport.length; i++) {
      final p = paymentsToExport[i];
      sheet.cell(CellIndex.indexByString('A${i+2}')).value = TextCellValue('${p.parsedAt.day}/${p.parsedAt.month}/${p.parsedAt.year} ${p.parsedAt.hour}:${p.parsedAt.minute}');
      sheet.cell(CellIndex.indexByString('B${i+2}')).value = TextCellValue(p.senderName);
      sheet.cell(CellIndex.indexByString('C${i+2}')).value = TextCellValue(p.amount.toStringAsFixed(2));
      sheet.cell(CellIndex.indexByString('D${i+2}')).value = TextCellValue(p.currency);
    }

    await _saveAndOpenExcel(excel, 'pagos');
  }

  Future<void> exportAdminDataToExcel({
    required List<UserProfile> userProfiles,
    required List<Map<String, dynamic>> devices,
  }) async {
    final excel = Excel.createExcel();

    // Export User Profiles
    if (userProfiles.isNotEmpty) {
      final sheet = excel['Perfiles de Usuarios'];
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Nombre'),
        TextCellValue('Email'),
        TextCellValue('Teléfono'),
        TextCellValue('UUID'),
        TextCellValue('Suscripto'),
        TextCellValue('Fecha de Inicio de Prueba'),
        TextCellValue('Fecha de Fin de Prueba'),
        TextCellValue('Fecha de Inicio de Suscripción'),
        TextCellValue('Fecha de Fin de Suscripción'),
        TextCellValue('Fecha de Creación'),
      ]);

      for (final profile in userProfiles) {
        sheet.appendRow([
          if (profile.id != null) TextCellValue(profile.id!),
          TextCellValue(profile.name),
          if (profile.email != null) TextCellValue(profile.email!),
          if (profile.phone != null) TextCellValue(profile.phone!),
          if (profile.uuid != null) TextCellValue(profile.uuid!),
          TextCellValue(profile.isSubscribed ? 'Sí' : 'No'),
          if (profile.trialStartDate != null)
            DateCellValue(
              year: profile.trialStartDate!.year,
              month: profile.trialStartDate!.month,
              day: profile.trialStartDate!.day,
            ),
          if (profile.trialEndDate != null)
            DateCellValue(
              year: profile.trialEndDate!.year,
              month: profile.trialEndDate!.month,
              day: profile.trialEndDate!.day,
            ),
          if (profile.subscriptionStartDate != null)
            DateCellValue(
              year: profile.subscriptionStartDate!.year,
              month: profile.subscriptionStartDate!.month,
              day: profile.subscriptionStartDate!.day,
            ),
          if (profile.subscriptionEndDate != null)
            DateCellValue(
              year: profile.subscriptionEndDate!.year,
              month: profile.subscriptionEndDate!.month,
              day: profile.subscriptionEndDate!.day,
            ),
          DateCellValue(
            year: profile.createdAt.year,
            month: profile.createdAt.month,
            day: profile.createdAt.day,
          ),
        ]);
      }
    }

    // Export Devices
    if (devices.isNotEmpty) {
      final sheet = excel['Dispositivos'];
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('UUID'),
        TextCellValue('Alias'),
        TextCellValue('Aprobado'),
        TextCellValue('Última Conexión'),
      ]);
      for (final device in devices) {
        final lastConnectedAt = _parseDateTime(device['lastConnectedAt']);
        sheet.appendRow([
          if (device['id'] != null) TextCellValue(device['id'].toString()),
          TextCellValue(device['uuid'] ?? ''),
          TextCellValue(device['alias'] ?? ''),
          TextCellValue((device['isApproved'] ?? false) ? 'Sí' : 'No'),
          if (lastConnectedAt != null)
            DateCellValue(
              year: lastConnectedAt.year,
              month: lastConnectedAt.month,
              day: lastConnectedAt.day,
            ),
        ]);
      }
    }

    await _saveAndOpenExcel(excel, 'admin_data');
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<void> _saveAndOpenExcel(Excel excel, String prefix) async {
    final directory = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final fileName = '${prefix}_${now.day}${now.month}${now.year}_${now.hour}${now.minute}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      await OpenFilex.open(filePath);
    }
  }
}
