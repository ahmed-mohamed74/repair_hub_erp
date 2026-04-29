import 'package:equatable/equatable.dart';
import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';

class TicketModel extends Equatable {
  final String id;
  final int ticketNumber;
  final String customerId;
  final String deviceId;
  final TicketStatus status;
  final double estimatedPrice;
  final String? publicNotes;
  final String? internalNotes;
  final List<String> imageUrls;
  final String? description;
  final DateTime createdAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.deviceId,
    required this.status,
    required this.estimatedPrice,
    this.publicNotes,
    this.internalNotes,
    required this.imageUrls,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    ticketNumber,
    status,
    estimatedPrice,
    publicNotes,
    internalNotes,
    imageUrls,
    description,
  ];

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: (map[DbKeys.id] ?? map[DbKeys.ticketId] ?? '') as String,
      ticketNumber: map[DbKeys.ticketNumber] as int,
      customerId: map[DbKeys.customerId] as String,
      deviceId: map[DbKeys.deviceId] as String,
      status: TicketStatus.fromString(map[DbKeys.status] as String),
      estimatedPrice: (map[DbKeys.estimatedPrice] ?? 0.0).toDouble(),
      publicNotes: map[DbKeys.publicNotes] as String?,
      internalNotes: map[DbKeys.internalNotes] as String?,
      imageUrls:
          (map[DbKeys.imageUrls] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: map[DbKeys.description] as String?,
      createdAt: map[DbKeys.createdAt] != null
          ? DateTime.parse(map[DbKeys.createdAt] as String)
          : DateTime.now(),
    );
  }
}
