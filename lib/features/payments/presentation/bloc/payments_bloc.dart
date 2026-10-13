import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../../domain/repositories/payment_repository.dart';

part 'payments_event.dart';
part 'payments_state.dart';

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository _paymentRepository;
  final TtsService _ttsService;
  final SharedPreferences _prefs;
  StreamSubscription<PaymentData>? _paymentSubscription;
  StreamSubscription<String>? _rawSubscription;

  PaymentsBloc(
    this._paymentRepository,
    this._ttsService,
    this._prefs,
  ) : super(const PaymentsState()) {
    on<LoadPayments>(_onLoadPayments);
    on<PaymentReceived>(_onPaymentReceived);
    on<ExportPayments>(_onExportPayments);
    on<SaveManualPayment>(_onSaveManualPayment);
    on<ClearOldPayments>(_onClearOldPayments);
    on<ClearAllPaymentsRequested>(_onClearAllPaymentsRequested);

    _listenToPayments();
    _listenToRawNotifications();
  }

  void _listenToPayments() {
    _paymentSubscription?.cancel();
    _paymentSubscription = _paymentRepository.onPaymentReceived.listen(
      (payment) {
        add(PaymentReceived(payment));
      },
      onError: (error) {
        AppLogger.e('PaymentsBloc: Error escuchando stream de pagos', error);
      },
    );
  }

  void _listenToRawNotifications() {
    _rawSubscription?.cancel();
    _rawSubscription = _paymentRepository.onRawNotificationReceived.listen(
      (rawText) {
        AppLogger.d('PaymentsBloc: Notificación cruda recibida: $rawText');
      },
      onError: (error) {
        AppLogger.e('PaymentsBloc: Error escuchando notificaciones crudas', error);
      },
    );
  }

  Future<void> _onLoadPayments(
      LoadPayments event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.loading));

    final days = _prefs.getInt('history_retention_days') ?? 0;
    if (days > 0) {
      await _paymentRepository.clearOldPayments(days);
    }

    final result = await _paymentRepository.getPayments();

    result.fold(
      (failure) => emit(state.copyWith(
        status: PaymentsStatus.failure,
        error: failure.message,
      )),
      (payments) {
        final now = DateTime.now();
        final dailyTotal = payments
            .where((p) =>
                p.parsedAt.year == now.year &&
                p.parsedAt.month == now.month &&
                p.parsedAt.day == now.day)
            .fold(0.0, (sum, p) => sum + p.amount);

        emit(state.copyWith(
          status: PaymentsStatus.success,
          payments: payments,
          dailyTotal: dailyTotal,
        ));
      },
    );
  }

  Future<void> _onPaymentReceived(
      PaymentReceived event, Emitter<PaymentsState> emit) async {
    final updatedPayments = List<PaymentData>.from(state.payments)..insert(0, event.payment);

    final now = DateTime.now();
    final dailyTotal = updatedPayments
        .where((p) =>
            p.parsedAt.year == now.year &&
            p.parsedAt.month == now.month &&
            p.parsedAt.day == now.day)
        .fold(0.0, (sum, p) => sum + p.amount);

    emit(state.copyWith(
      status: PaymentsStatus.success,
      payments: updatedPayments,
      dailyTotal: dailyTotal,
    ));
  }

  Future<void> _onExportPayments(
      ExportPayments event, Emitter<PaymentsState> emit) async {
    final result = await _paymentRepository.getPayments();

    result.fold(
      (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
      (_) => emit(state.copyWith(status: PaymentsStatus.success)),
    );
  }

  Future<void> _onSaveManualPayment(
      SaveManualPayment event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    final result = await _paymentRepository.savePayment(event.payment);
    
    result.fold(
      (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
      (_) {
        final isMuted = _prefs.getBool('is_muted') ?? false;
        final cleanTtsName = event.payment.senderName
            .replaceAll(RegExp(r'[*＊#_~^•·¡!]+'), ' ')
            .replaceAll(RegExp(r"[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+$"), "")
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        _ttsService.speak(
          "$cleanTtsName envió ${event.payment.amount} soles",
          isMuted: isMuted,
        );
        add(PaymentReceived(event.payment));
      },
    );
  }

  Future<void> _onClearOldPayments(
      ClearOldPayments event, Emitter<PaymentsState> emit) async {
    final days = _prefs.getInt('history_retention_days') ?? 0;
    if (days > 0) {
      await _paymentRepository.clearOldPayments(days);
      add(LoadPayments());
    }
  }

  Future<void> _onClearAllPaymentsRequested(
      ClearAllPaymentsRequested event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    await _paymentRepository.deleteAllPayments();
    add(LoadPayments());
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    _rawSubscription?.cancel();
    return super.close();
  }
}
