
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/export_payments_use_case.dart';
import '../../../notifications/domain/entities/payment_data.dart';
import '../../../../core/utils/app_logger.dart';

// Events
abstract class PaymentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentsEvent {}

class RawNotificationReceived extends PaymentsEvent {
  final String rawText;
  RawNotificationReceived(this.rawText);

  @override
  List<Object?> get props => [rawText];
}

class PaymentReceived extends PaymentsEvent {
  final PaymentData payment;
  PaymentReceived(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ExportPayments extends PaymentsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  ExportPayments({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class SaveManualPayment extends PaymentsEvent {
  final PaymentData payment;
  SaveManualPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ClearOldPayments extends PaymentsEvent {}

// States
enum PaymentsStatus { initial, loading, success, failure, exporting }

class PaymentsState extends Equatable {
  final PaymentsStatus status;
  final List<PaymentData> payments;
  final double dailyTotal;
  final String? error;
  final String? lastRawNotification;

  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.payments = const [],
    this.dailyTotal = 0.0,
    this.error,
    this.lastRawNotification,
  });

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<PaymentData>? payments,
    double? dailyTotal,
    String? error,
    String? lastRawNotification,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      dailyTotal: dailyTotal ?? this.dailyTotal,
      error: error ?? this.error,
      lastRawNotification: lastRawNotification ?? this.lastRawNotification,
    );
  }

  @override
  List<Object?> get props =>
      [status, payments, dailyTotal, error, lastRawNotification];
}

@injectable
class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentRepository _paymentRepository;
  final ExportPaymentsUseCase _exportPaymentsUseCase;
  final TtsService _ttsService;
  final SharedPreferences _prefs;
  StreamSubscription? _paymentSubscription;
  StreamSubscription? _rawSubscription;

  PaymentsBloc(
    this._paymentRepository,
    this._exportPaymentsUseCase,
    this._ttsService,
    this._prefs,
  ) : super(const PaymentsState()) {
    on<LoadPayments>(_onLoadPayments);
    on<PaymentReceived>(_onPaymentReceived);
    on<RawNotificationReceived>(_onRawNotificationReceived);
    on<ExportPayments>(_onExportPayments);
    on<SaveManualPayment>(_onSaveManualPayment);
    on<ClearOldPayments>(_onClearOldPayments);

    _paymentSubscription = _paymentRepository.onPaymentReceived.listen((payment) {
      AppLogger.d('PaymentsBloc: Recibido evento de pago: ${payment.senderName}');
      add(PaymentReceived(payment));
    });

    _rawSubscription = _paymentRepository.onRawNotificationReceived.listen((rawText) {
      add(RawNotificationReceived(rawText));
    });
  }

  void _onRawNotificationReceived(
      RawNotificationReceived event, Emitter<PaymentsState> emit) {
    emit(state.copyWith(lastRawNotification: event.rawText));
  }

  Future<void> _onLoadPayments(
      LoadPayments event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    
    // Ejecutar limpieza antes de cargar
    final days = _prefs.getInt('history_retention_days') ?? 30;
    if (days > 0) {
      await _paymentRepository.clearOldPayments(days);
    }

    final result = await _paymentRepository.getPayments();
    
    result.fold(
      (failure) => emit(state.copyWith(status: PaymentsStatus.failure, error: failure.message)),
      (payments) {
        final total = _calculateDailyTotal(payments);
        emit(state.copyWith(status: PaymentsStatus.success, payments: payments, dailyTotal: total));
      },
    );
  }

  void _onPaymentReceived(PaymentReceived event, Emitter<PaymentsState> emit) {
    AppLogger.i('PaymentsBloc: Actualizando estado con nuevo pago...');
    final updatedPayments = [event.payment, ...state.payments];
    final total = _calculateDailyTotal(updatedPayments);
    emit(state.copyWith(
      payments: updatedPayments, 
      dailyTotal: total,
      status: PaymentsStatus.success // Aseguramos que el estado sea success
    ));
  }

  double _calculateDailyTotal(List<PaymentData> payments) {
    final now = DateTime.now();
    return payments
        .where((p) => p.parsedAt.year == now.year && p.parsedAt.month == now.month && p.parsedAt.day == now.day)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  Future<void> _onExportPayments(ExportPayments event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(status: PaymentsStatus.exporting));
    
    final result = await _exportPaymentsUseCase(ExportPaymentsParams(
      payments: state.payments,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

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
        _ttsService.speak(
          "${event.payment.senderName} envió ${event.payment.amount} soles",
          isMuted: isMuted,
        );
        add(PaymentReceived(event.payment));
      },
    );
  }

  Future<void> _onClearOldPayments(
      ClearOldPayments event, Emitter<PaymentsState> emit) async {
    final days = _prefs.getInt('history_retention_days') ?? 30;
    if (days > 0) {
      await _paymentRepository.clearOldPayments(days);
      add(LoadPayments());
    }
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    _rawSubscription?.cancel();
    return super.close();
  }
}
