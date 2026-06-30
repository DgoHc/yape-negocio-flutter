import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final int? id;
  final String uuid;
  final String alias;
  final bool isApproved;
  final DateTime? lastConnectedAt;

  const DeviceEntity({
    this.id,
    required this.uuid,
    required this.alias,
    required this.isApproved,
    this.lastConnectedAt,
  });

  @override
  List<Object?> get props => [id, uuid, alias, isApproved, lastConnectedAt];
}
