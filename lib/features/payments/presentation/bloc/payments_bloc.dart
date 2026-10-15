import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/export_payments_use_case.dart';

part 'payments_event.dart';
part 'payments_state.dart';

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository _paymentRepository;
  final ExportPaymentsUseCase _exportPaymentsUseCase;
  final TtsService _ttsService;
  final SharedPreferences _prefs;
  StreamSubscription<PaymentData>? _paymentSubscription;
  StreamSubscription<String>? _rawSubscription;

  PaymentsBloc(
    this._paymentRepository,
    this._exportPaymentsUseCase,
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
        AppLogger.d('PaymentsBloc: Notificación RAW recibida: $rawText');
      },
      onError: (error) {
        AppLogger.e('PaymentsBloc: Error escuchando stream RAW', error);
      },
    );
  }

  Future<void> _onLoadPayments(
      LoadPayments event, Emitter<PaymentsState> emit) async {
    // Solo emitir estado de carga si no hay pagos locales visibles
    if (state.payments.isEmpty) {
      emit(state.copyWith(status: PaymentsStatus.loading));
    }
    
    final result = await _paymentRepository.getPayments();
    
    result.fold(
      (failure) {
        AppLogger.e('PaymentsBloc: Error al cargar pagos: ${failure.message}');
        emit(state.copyWith(
          status: PaymentsStatus.success, // Mantener datos locales sin bloquear la pantalla
          error: failure.message,
        ));
      },
      (payments) {
        final now = DateTime.now();
        final todayPayments = payments.where((p) =>
            p.parsedAt.year == now.year &&
            p.parsedAt.month == now.month &&
            p.parsedAt.day == now.day).toList();
            
        final dailyTotal = todayPayments.fold<double>(
            0.0, (sum, item) => sum + item.amount);

        AppLogger.i('PaymentsBloc: ${payments.length} pagos cargados. Total hoy: S/ $dailyTotal');

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
    final updatedPayments = List<PaymentData>.from(state.payments)
      ..insert(0, event.payment);

    final now = DateTime.now();
    final todayPayments = updatedPayments.where((p) =>
        p.parsedAt.year == now.year &&
        p.parsedAt.month == now.month &&
        p.parsedAt.day == now.day).toList();
        
    final dailyTotal = todayPayments.fold<double>(
        0.0, (sum, item) => sum + item.amount);

    AppLogger.i('PaymentsBloc: Pago recibido en tiempo real. Nuevo total hoy: S/ $dailyTotal');

    emit(state.copyWith(
      status: PaymentsStatus.success,
      payments: updatedPayments,
      dailyTotal: dailyTotal,
    ));
  }

  Future<void> _onExportPayments(
      ExportPayments event, Emitter<PaymentsState> emit) async {
    final result = await _paymentRepository.getPayments();

    await result.fold(
      (failure) async {
        emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message));
      },
      (payments) async {
        final exportResult = await _exportPaymentsUseCase(
          ExportPaymentsParams(payments: payments),
        );
        exportResult.fold(
          (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
          (_) => emit(state.copyWith(status: PaymentsStatus.success)),
        );
      },
    );
  }

  Future<void> _onSaveManualPayment(
      SaveManualPayment event, Emitter<PaymentsState> emit) async {
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
        add(LoadPayments());
      },
    );
  }

  Future<void> _onClearOldPayments(
      ClearOldPayments event, Emitter<PaymentsState> emit) async {
    final result = await _paymentRepository.clearOldPayments(event.days);
    
    result.fold(
      (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
      (_) => add(LoadPayments()),
    );
  }

  Future<void> _onClearAllPaymentsRequested(
      ClearAllPaymentsRequested event, Emitter<PaymentsState> emit) async {
    final result = await _paymentRepository.deleteAllPayments();
    
    result.fold(
      (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
      (_) => add(LoadPayments()),
    );
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    _rawSubscription?.cancel();
    return super.close();
  }
}
