import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { initial, connected, disconnected }

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  final List<ConnectivityResult> results;

  const ConnectivityState({
    this.status = ConnectivityStatus.initial,
    this.results = const [],
  });

  bool get isConnected => status == ConnectivityStatus.connected;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    List<ConnectivityResult>? results,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [status, results];
}
