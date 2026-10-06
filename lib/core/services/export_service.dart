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
      final start = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      paymentsToExport = payments.where((p) {
        return p.parsedAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
               p.parsedAt.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    }

    final excel = Excel.createExcel();
    final sheet = excel['Historial de Pagos'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('N°');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Fecha y Hora');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Remitente / Pagador');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Monto');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Moneda');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('N° Operación');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Texto Notificación');

    double totalAmount = 0.0;

    // Rows
    for (int i = 0; i < paymentsToExport.length; i++) {
      final p = paymentsToExport[i];
      totalAmount += p.amount;
      final dateStr = '${p.parsedAt.day.toString().padLeft(2, '0')}/${p.parsedAt.month.toString().padLeft(2, '0')}/${p.parsedAt.year} ${p.parsedAt.hour.toString().padLeft(2, '0')}:${p.parsedAt.minute.toString().padLeft(2, '0')}';

      sheet.cell(CellIndex.indexByString('A${i + 2}')).value = TextCellValue('${i + 1}');
      sheet.cell(CellIndex.indexByString('B${i + 2}')).value = TextCellValue(dateStr);
      sheet.cell(CellIndex.indexByString('C${i + 2}')).value = TextCellValue(p.senderName);
      sheet.cell(CellIndex.indexByString('D${i + 2}')).value = TextCellValue(p.amount.toStringAsFixed(2));
      sheet.cell(CellIndex.indexByString('E${i + 2}')).value = TextCellValue(p.currency);
      sheet.cell(CellIndex.indexByString('F${i + 2}')).value = TextCellValue(p.operationNumber ?? '-');
      sheet.cell(CellIndex.indexByString('G${i + 2}')).value = TextCellValue(p.rawText);
    }

    // Row de Total
    final totalRowIndex = paymentsToExport.length + 3;
    sheet.cell(CellIndex.indexByString('B$totalRowIndex')).value = TextCellValue('TOTAL GENERAL:');
    sheet.cell(CellIndex.indexByString('D$totalRowIndex')).value = TextCellValue('S/ ${totalAmount.toStringAsFixed(2)}');

    await _saveAndOpenExcel(excel, 'reporte_pagos_sonopay');
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
