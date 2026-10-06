import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../bloc/payments_bloc.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            tooltip: 'Filtrar por Rango de Fechas',
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                initialDateRange: _selectedDateRange ??
                    DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 7)),
                      end: DateTime.now(),
                    ),
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppTheme.primaryColor,
                        onPrimary: AppTheme.textPrimary,
                        surface: Colors.white,
                        onSurface: AppTheme.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                setState(() => _selectedDateRange = range);
              }
            },
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Limpiar Filtro',
              onPressed: () => setState(() => _selectedDateRange = null),
            ),
        ],
      ),
      body: BlocBuilder<PaymentsBloc, PaymentsState>(
        builder: (context, state) {
          if (state.status == PaymentsStatus.loading) {
            return const Center(child: YtLoader());
          }

          final filteredPayments = _selectedDateRange == null
              ? state.payments
              : state.payments.where((p) {
                  final start = DateTime(
                      _selectedDateRange!.start.year,
                      _selectedDateRange!.start.month,
                      _selectedDateRange!.start.day,
                      0,
                      0,
                      0);
                  final end = DateTime(
                      _selectedDateRange!.end.year,
                      _selectedDateRange!.end.month,
                      _selectedDateRange!.end.day,
                      23,
                      59,
                      59);
                  return p.parsedAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
                      p.parsedAt.isBefore(end.add(const Duration(seconds: 1)));
                }).toList();

          double totalAmount = filteredPayments.fold(0.0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              // BARRAS DE RESUMEN Y FILTRO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SoftCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDateRange == null
                                ? 'Mostrando Todo el Historial'
                                : 'Rango: ${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'S/ ${totalAmount.toStringAsFixed(2)} (${filteredPayments.length} cobros)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Excel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          context.read<PaymentsBloc>().add(
                                ExportPayments(
                                  startDate: _selectedDateRange?.start,
                                  endDate: _selectedDateRange?.end,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generando reporte Excel del rango seleccionado...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: filteredPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_rounded, size: 64, color: AppTheme.textPlaceholder),
                            const SizedBox(height: 16),
                            Text(
                              _selectedDateRange == null
                                  ? 'No hay historial de pagos registrado'
                                  : 'No se encontraron pagos en este rango de fechas',
                              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filteredPayments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final payment = filteredPayments[index];
                          return _PaymentHistoryItem(payment: payment);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final PaymentData payment;
  const _PaymentHistoryItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${payment.parsedAt.day.toString().padLeft(2, '0')}/${payment.parsedAt.month.toString().padLeft(2, '0')}/${payment.parsedAt.year} · ${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}';

    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ ${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.successColor,
                ),
              ),
              if (payment.operationNumber != null)
                Text(
                  '#${payment.operationNumber}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textPlaceholder),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
