import 'package:repair_hub/core/constants/db_constants.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';

class TicketModel {
  final String id;
  final int ticketNumber;
  final String customerId;
  final String deviceId;
  final TicketStatus status;
  final double estimatedPrice;
  final String? publicNotes;   // Nullable: Customer might not have notes yet
  final String? internalNotes; // Nullable: Technician might not have notes yet
  final List<String> imageUrls;
  final String? description;
  final DateTime createdAt;

  TicketModel({
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

  factory TicketModel.fromMap(Map<String, dynamic> map) {
  return TicketModel(
    // Handle both the raw table 'id' and the view 'ticket_id' alias
    id: (map[DbKeys.id] ?? map[DbKeys.ticketId] ?? '') as String,
    ticketNumber: map[DbKeys.ticketNumber] as int,
    customerId: map[DbKeys.customerId] as String,
    deviceId: map[DbKeys.deviceId] as String,
    status: TicketStatus.fromString(map[DbKeys.status] as String),
    estimatedPrice: (map[DbKeys.estimatedPrice] ?? 0.0).toDouble(),
    publicNotes: map[DbKeys.publicNotes] as String?,
    internalNotes: map[DbKeys.internalNotes] as String?,
    imageUrls: (map[DbKeys.imageUrls] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
    description: map[DbKeys.description] as String?,
    createdAt: map[DbKeys.createdAt] != null 
        ? DateTime.parse(map[DbKeys.createdAt] as String) 
        : DateTime.now(),
  );
}

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'device_id': deviceId,
      'status': status.name,
      'estimated_price': estimatedPrice,
      'public_notes': publicNotes,
      'internal_notes': internalNotes,
      'image_urls': imageUrls,
      'description': description,
    };
  }
}