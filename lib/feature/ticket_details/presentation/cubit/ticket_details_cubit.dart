import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/core/shared/models/ticket_model.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';
import 'package:repair_hub/feature/ticket_details/data/repository/ticket_details_repo.dart';

part 'ticket_details_state.dart';

class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  final TicketDetailsRepository repository;
  TicketDetailsCubit(this.repository) : super(TicketDetailsInitial());

  // 1. Fetch Initial Data
  Future<void> loadTicket(String id) async {
    emit(TicketDetailsLoading());
    final result = await repository.fetchTicketDetails(id);
    result.fold(
      (error) => emit(TicketDetailsFailure(error)),
      (ticket) => emit(TicketDetailsSuccess(ticket)),
    );
  }

  // 2. Update Internal Notes , Status
  Future<void> updateTicket(
    String id,
    String notes,
    TicketStatus newStatus,
  ) async {
    emit(TicketDetailsLoading());
    try {
      await repository.updateTicket(id, notes, newStatus);
      final result = await repository.fetchTicketDetails(id);
      result.fold(
        (error) => emit(TicketDetailsFailure(error)),
        (ticket) => emit(TicketDetailsSuccess(ticket)),
      );
    } catch (e) {
      emit(TicketDetailsFailure("Update failed: ${e.toString()}"));
    }
  }
}
