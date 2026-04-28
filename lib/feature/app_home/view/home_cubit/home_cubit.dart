import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_hub/feature/app_home/data/repository/ticket_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TicketRepository repository;
  List<Map<String, dynamic>> _allTickets = [];

  String _currentSearchQuery = "";

  HomeCubit({required this.repository}) : super(HomeInitial());

  Future<void> loadTickets() async {
    // 1. Emit loading to clear the previous screen state
    emit(HomeLoading());

    final result = await repository.fetchAllTickets();

    result.fold((error) => emit(HomeFailure(error)), (tickets) {
      // 2. Clear local cache and update with fresh data
      _allTickets = List.from(tickets);
      emit(HomeSuccess(_allTickets));
    });
  }

  Future<void> search(String query) async {
    _currentSearchQuery = query;

    if (query.isEmpty) {
      emit(HomeSuccess(_allTickets));
      return;
    }

    // 1. INSTANT LOCAL FILTER
    final q = query.toLowerCase();
    final localFiltered = _allTickets.where((ticket) {
      // Ensure we handle nulls safely
      final name = (ticket['customer_name'] ?? '').toString().toLowerCase();
      final imei = (ticket['imei'] ?? '').toString().toLowerCase();
      final model = (ticket['model_name'] ?? '').toString().toLowerCase();
      final id = (ticket['ticket_id'] ?? '')
          .toString()
          .toLowerCase(); // Ticket ID

      return name.contains(q) ||
          imei.contains(q) ||
          model.contains(q) ||
          id.contains(q);
    }).toList();

    // Update UI immediately with local results
    emit(HomeSuccess(localFiltered));

    // 2. REMOTE FETCH
    try {
      final result = await repository.searchTickets(query);

      if (_currentSearchQuery == query) {
        result.fold((error) => null, (remoteResults) {
          // Update the list with server results if they differ
          if (remoteResults.isNotEmpty) {
            emit(HomeSuccess(remoteResults));
          }
        });
      }
    } catch (_) {
      // Fail silently on search to keep the local results visible
    }
  }
}
