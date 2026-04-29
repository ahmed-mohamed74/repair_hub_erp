import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/feature/customer_website/data/repository/web_tracking_repo.dart';

part 'web_tracking_state.dart';

class WebTrackingCubit extends Cubit<WebTrackingState> {
  final WebTrackingRepository repository;

  WebTrackingCubit(this.repository) : super(TrackingInitial());

  Future<void> searchTicket(String query) async {
    if (query.isEmpty) {
      emit(TrackingInitial());
      return;
    }

    emit(TrackingLoading());

    final result = await repository.fetchTicketByIdOrImei(query);
    result.fold((error) => emit(TrackingFailure(error)), (ticket) {
      if (ticket != null) {
        emit(TrackingSuccess(ticket));
      } else {
        emit(TrackingNotFound());
      }
    });
  }
}
