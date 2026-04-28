import 'package:equatable/equatable.dart';

enum AddTicketStatus { initial, loading, success, failure }

class AddTicketState extends Equatable {
  final String brand;
  final List<String> photoPaths;
  final AddTicketStatus status;
  final String? errorMessage;
  final String? successTicketId;

  const AddTicketState({
    this.brand = 'Apple',
    this.photoPaths = const ['', ''], 
    this.status = AddTicketStatus.initial,
    this.errorMessage,
    this.successTicketId,
  });

  AddTicketState copyWith({
    String? brand,
    List<String>? photoPaths,
    AddTicketStatus? status,
    String? errorMessage,
    String? successTicketId,
  }) {
    return AddTicketState(
      brand: brand ?? this.brand,
      photoPaths: photoPaths ?? this.photoPaths,
      status: status ?? this.status,
      errorMessage: errorMessage, 
      successTicketId: successTicketId ?? this.successTicketId,
    );
  }

  @override
  List<Object?> get props => [brand, photoPaths, status, errorMessage, successTicketId];
}