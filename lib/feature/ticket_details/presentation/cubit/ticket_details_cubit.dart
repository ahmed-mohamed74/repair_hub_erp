

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/core/shared/models/ticket_model.dart';
import 'package:repair_hub/core/shared/models/ticket_status_enum.dart';
import 'package:repair_hub/feature/ticket_details/data/ticket_details_repo.dart';

part 'ticket_details_state.dart';


class TicketDetailsCubit extends Cubit<TicketDetailsState> {
  final TicketDetailsRepository repository;
  TicketDetailsCubit(this.repository) : super(TicketDetailsInitial());

  Future<void> loadTicket(String id) async {
    emit(TicketDetailsLoading());
    final result = await repository.fetchTicketDetails(id);
    result.fold(
      (error) => emit(TicketDetailsFailure(error)),
      (ticket) => emit(TicketDetailsSuccess(ticket)),
    );
  }

  Future<void> changeStatus(String id, TicketStatus newStatus) async {
    final result = await repository.updateStatus(id, newStatus);
    result.fold(
      (error) => null, // Handle error via a secondary state if needed
      (_) => loadTicket(id), // Refresh data on success
    );
  }
}