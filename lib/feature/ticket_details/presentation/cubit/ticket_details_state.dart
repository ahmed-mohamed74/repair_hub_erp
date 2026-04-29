part of 'ticket_details_cubit.dart';

sealed class TicketDetailsState extends Equatable {
  const TicketDetailsState();
  @override
  List<Object?> get props => [];
}

final class TicketDetailsInitial extends TicketDetailsState {}

final class TicketDetailsLoading extends TicketDetailsState {}

final class TicketDetailsSuccess extends TicketDetailsState {
  final TicketModel ticket;
  const TicketDetailsSuccess(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

final class TicketDetailsFailure extends TicketDetailsState {
  final String message;
  const TicketDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
