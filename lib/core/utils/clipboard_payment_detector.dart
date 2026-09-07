import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notifications/domain/entities/payment_data.dart';
import '../../features/notifications/domain/parsers/payment_parser.dart';
import '../../features/payments/presentation/bloc/payments_bloc.dart';
import '../widgets/yt_design_system.dart';
import '../theme/app_theme.dart';
import '../di/injection_container.dart';
import '../utils/app_logger.dart';

class ClipboardPaymentDetector {
  static String? _lastCheckedText;

  static Future<void> checkClipboard(BuildContext context) async {
    try {
      final isDetectionEnabled = sl<SharedPreferences>().getBool('detection_enabled') ?? true;
      if (!isDetectionEnabled) return;

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data == null || data.text == null || data.text!.isEmpty) return;

      final text = data.text!.trim();
      
      if (text == _lastCheckedText) return;
      _lastCheckedText = text;

      final result = PaymentParser.parse(text);
      result.fold(
        (failure) {},
        (payment) {
          _showConfirmationBottomSheet(context, payment);
        },
      );
    } catch (e) {
      AppLogger.e('Error checking clipboard', e);
    }
  }

  static void _showConfirmationBottomSheet(BuildContext context, PaymentData payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.textPlaceholder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.successColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pago Detectado (SonoPay)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Encontrado en el portapapeles',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              YtCard(
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Remitente:', payment.senderName, isTitle: true),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context,
                      'Monto:',
                      'S/ ${payment.amount.toStringAsFixed(2)}',
                      valueColor: AppTheme.successColor,
                      isBoldValue: true,
                    ),
                    if (payment.operationNumber != null) ...[
                      const Divider(height: 24),
                      _buildDetailRow(context, 'N° Operación:', payment.operationNumber!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Ignorar',
                      isSecondary: true,
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      label: 'Registrar',
                      onPressed: () {
                        context.read<PaymentsBloc>().add(SaveManualPayment(payment));
                        Navigator.pop(bottomSheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pago de ${payment.senderName} registrado'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTitle = false,
    Color? valueColor,
    bool isBoldValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: isTitle ? 16 : 14,
            fontWeight: isTitle || isBoldValue ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
