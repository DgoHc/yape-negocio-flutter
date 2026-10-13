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

  void _showDeleteHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Borrar Historial', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas eliminar todo tu historial local de pagos? Esta acción liberará espacio en tu teléfono.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              context.read<PaymentsBloc>().add(ClearAllPaymentsRequested());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial local de pagos eliminado.')),
              );
            },
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

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
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Borrar Historial',
            onPressed: () => _showDeleteHistoryDialog(context),
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
                  final pDate = DateTime(p.parsedAt.year, p.parsedAt.month, p.parsedAt.day);
                  final startDate = DateTime(
                    _selectedDateRange!.start.year,
                    _selectedDateRange!.start.month,
                    _selectedDateRange!.start.day,
                  );
                  final endDate = DateTime(
                    _selectedDateRange!.end.year,
                    _selectedDateRange!.end.month,
                    _selectedDateRange!.end.day,
                  );
                  return (pDate.isAfter(startDate) || pDate.isAtSameMomentAs(startDate)) &&
                      (pDate.isBefore(endDate) || pDate.isAtSameMomentAs(endDate));
                }).toList();

          if (filteredPayments.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron pagos.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final totalFiltered = filteredPayments.fold(0.0, (sum, p) => sum + p.amount);

          return Column(
            children: [
              // BANNER DE RESUMEN DEL FILTRO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: const Color(0xFFFFF8D6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDateRange == null
                          ? 'Total acumulado registrado:'
                          : 'Total en rango seleccionado:',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A6800),
                      ),
                    ),
                    Text(
                      'S/ ${totalFiltered.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C2200),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = filteredPayments[index];
                    return _HistoryItemCard(payment: payment);
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

class _HistoryItemCard extends StatelessWidget {
  final PaymentData payment;

  const _HistoryItemCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${payment.parsedAt.day.toString().padLeft(2, '0')}/${payment.parsedAt.month.toString().padLeft(2, '0')}/${payment.parsedAt.year} ${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}';

    return YtCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${payment.currency} ${payment.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF00893E),
            ),
          ),
        ],
      ),
    );
  }
}
