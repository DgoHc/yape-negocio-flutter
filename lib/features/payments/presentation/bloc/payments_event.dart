part of 'payments_bloc.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentsEvent {}

class PaymentReceived extends PaymentsEvent {
  final PaymentData payment;

  const PaymentReceived(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ExportPayments extends PaymentsEvent {}

class SaveManualPayment extends PaymentsEvent {
  final PaymentData payment;

  const SaveManualPayment(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ClearOldPayments extends PaymentsEvent {}

class ClearAllPaymentsRequested extends PaymentsEvent {}
