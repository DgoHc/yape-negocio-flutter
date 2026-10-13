part of 'payments_bloc.dart';

enum PaymentsStatus { initial, loading, success, failure }

class PaymentsState extends Equatable {
  final PaymentsStatus status;
  final List<PaymentData> payments;
  final double dailyTotal;
  final String? error;

  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.payments = const [],
    this.dailyTotal = 0.0,
    this.error,
  });

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<PaymentData>? payments,
    double? dailyTotal,
    String? error,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      dailyTotal: dailyTotal ?? this.dailyTotal,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, payments, dailyTotal, error];
}
