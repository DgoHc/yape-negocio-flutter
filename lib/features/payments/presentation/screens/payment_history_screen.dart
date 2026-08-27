import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../bloc/payments_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      body: BlocBuilder<PaymentsBloc, PaymentsState>(
        builder: (context, state) {
          if (state.status == PaymentsStatus.loading) {
            return const Center(child: YtLoader());
          }

          final filteredPayments = _selectedDate == null
              ? state.payments
              : state.payments.where((p) {
                  return p.parsedAt.year == _selectedDate!.year &&
                      p.parsedAt.month == _selectedDate!.month &&
                      p.parsedAt.day == _selectedDate!.day;
                }).toList();

          if (filteredPayments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDate == null 
                      ? 'No hay historial registrado' 
                      : 'No hay pagos para esta fecha',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredPayments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payment = filteredPayments[index];
              return _PaymentHistoryItem(payment: payment);
            },
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
    return YtCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                  const Color(0xFF00E5FF).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.1)),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF7C4DFF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '${payment.parsedAt.day}/${payment.parsedAt.month} • ${payment.parsedAt.hour}:${payment.parsedAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF00C853),
                ),
              ),
              if (payment.operationNumber != null)
                Text(
                  '#${payment.operationNumber}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
